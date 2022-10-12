{%- macro snowflake__hub(hashkey, business_keys, src_ldts, src_rsrc, source_models) -%}

{%- set end_of_all_times = datavault4dbt.end_of_all_times() -%}
{%- set timestamp_format = datavault4dbt.timestamp_format() -%}

{%- set ns = namespace(last_cte= "", source_included_before = {}) -%}

{# Select the Business Key column from the first source model definition provided in the hub model and put them in an array. #}
{%- set business_keys = datavault4dbt.expand_column_list(columns=[business_keys]) -%}
{%- for source_model in source_models.keys() %}    
    {%- set bk_column_input = source_models[source_model]['bk_columns'] -%}
    {%- if 'bk_columns' is not in source_models[source_model].keys() -%}
        {%- do source_models[source_model].update({'bk_columns': business_keys}) -%}
    {%- elif not datavault4dbt.is_list(bk_column_input) -%}
        {%- set bk_list = datavault4dbt.expand_column_list(columns=[bk_column_input]) -%}
        {%- do source_models[source_model].update({'bk_columns': bk_list}) -%}
    {%- endif -%}
{% endfor %}

{%- if not (source_models is iterable and source_models is not string) -%}
    {{ exceptions.raise_compiler_error("Invalid Source Model definition. Needs to be defined as dictionary for each source model, having the keys 'rsrc_static' and 'bk_column' and optional 'hk_column'.") }}
{%- endif -%}

{%- set final_columns_to_select = [hashkey] + business_keys + [src_ldts] + [src_rsrc] -%}

{{ datavault4dbt.prepend_generated_by() }}
WITH
{% if is_incremental() -%}
{#- Get all distinct hub hashkeys out of the existing hub for later incremental logic. #}
distinct_target_hashkeys AS 
(    
    SELECT DISTINCT
         {{ hashkey }}
    FROM {{ this }}
),
{% for source_model in source_models.keys() %}
    {#- Create a new rsrc_static column for each source model. #}
    {%- set source_number = loop.index | string -%}
    {%- set rsrc_static = source_models[source_model]['rsrc_static'] -%}    
    {%- set rsrc_static_query_source -%}
        SELECT {{ this }}.{{ src_rsrc }},
        '{{ rsrc_static }}' AS rsrc_static
        FROM {{ this }}
        WHERE {{ src_rsrc }} LIKE '{{ rsrc_static }}'
    {% endset %}
rsrc_static_{{ source_number }} AS 
(        
    SELECT 
      *,
      '{{ rsrc_static }}' AS rsrc_static
    FROM 
      {{ this }}
    WHERE {{ src_rsrc }} LIKE '{{ rsrc_static }}'
    {%- set ns.last_cte = "rsrc_static_{}".format(source_number) -%}
),
    {%- set rsrc_static_result = run_query(rsrc_static_query_source) -%}
    {%- set source_in_target = true -%}
    {% if not rsrc_static_result %}
        {%- set source_in_target = false -%}
    {% endif %}
    {%- do ns.source_included_before.update({source_model: source_in_target}) -%}
{% endfor -%}

{%- if source_models.keys() | length > 1 %}
rsrc_static_union AS 
(
    {#-  Create one unionized table over all source, will be the same as the already existing
         hub, but extended by the rsrc_static column. #}
    {% for source_model in source_models.keys() %}
    {%- set source_number = loop.index | string -%}
    SELECT * FROM rsrc_static_{{ source_number }}
    {%- if not loop.last %}
    UNION ALL
    {% endif -%}
    {%- endfor %}
    {%- set ns.last_cte = "rsrc_static_union".format(source_number) -%}
),
{%- endif %}
max_ldts_per_rsrc_static_in_target AS 
(
    {#- Use the previously created CTE to calculate the max ldts per rsrc_static. #}
    SELECT
        rsrc_static,
        MAX({{ src_ldts }}) AS max_ldts
    FROM 
       {{ ns.last_cte }}
    WHERE {{ src_ldts }} != {{ datavault4dbt.string_to_timestamp(timestamp_format, end_of_all_times) }}
    GROUP BY rsrc_static
), 
{% endif -%}

{% for source_model in source_models.keys() %}
    {%- set source_number = loop.index | string -%}
    {%- set rsrc_static = source_models[source_model]['rsrc_static'] -%}
    {%- if 'hk_column' not in source_models[source_model].keys() %}
        {%- set hk_column = hashkey -%}
    {%- else -%}
        {%- set hk_column = source_models[source_model]['hk_column'] -%}
    {% endif %}

src_new_{{ source_number }} AS 
(
    SELECT 
       {{ hk_column }} AS {{ hashkey }},
       {% for bk in source_models[source_model]['bk_columns'] -%}
       {{ bk }},
       {%- endfor %}
       {{ src_ldts }},
       {{ src_rsrc }},
      '{{ rsrc_static }}' AS rsrc_static
    FROM 
       {{ ref(source_model) }} src

    {%- if is_incremental() and ns.source_included_before[source_model] %}

    INNER JOIN max_ldts_per_rsrc_static_in_target max 
    ON max.rsrc_static = '{{ rsrc_static }}'
    WHERE src.{{ src_ldts }} > max.max_ldts

    {%- endif %}

    {%- set ns.last_cte = "src_new_{}".format(source_number) %}
),

{%- endfor -%}

{%- if source_models.keys() | length > 1 %}

source_new_union AS 
(
    {#- Unionize the new records from all sources. #}
    {%- for source_model in source_models.keys() -%}
    {%- set source_number = loop.index | string -%}
    SELECT
        {{ hashkey }},
        {% for bk in source_models[source_model]['bk_columns'] %}
        {{ bk }} AS {{ business_keys[loop.index - 1] }},
        {% endfor -%}
        {{ src_ldts }},
        {{ src_rsrc }},
        rsrc_static
    FROM 
        src_new_{{ source_number }}
    {%- if not loop.last %}
    UNION ALL
    {% endif -%}
    {%- endfor -%}
    {%- set ns.last_cte = 'source_new_union' -%}
),
{%- endif %}

earliest_hk_over_all_sources AS 
(
    {#- Deduplicate the unionized records again to only insert the earliest one. #}
    SELECT
        lcte.*
    FROM 
       {{ ns.last_cte }} AS lcte
    QUALIFY ROW_NUMBER() OVER (PARTITION BY {{ hashkey }} ORDER BY {{ src_ldts }}) = 1
    {%- set ns.last_cte = 'earliest_hk_over_all_sources' -%}
),

records_to_insert AS 
(
    {#- Select everything from the previous CTE, if incremental filter for hashkeys that are not already in the hub. #}
    SELECT 
        {{ datavault4dbt.print_list(final_columns_to_select) }}
    FROM 
        {{ ns.last_cte }}
    {%- if is_incremental() %}
    WHERE {{ hashkey }} NOT IN (SELECT * FROM distinct_target_hashkeys)
    {% endif %}
)
SELECT 
  * 
FROM 
  records_to_insert

{%- endmacro -%}
