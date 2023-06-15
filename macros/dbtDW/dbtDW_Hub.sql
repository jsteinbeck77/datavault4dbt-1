{%- macro generate_hub_query(table_name, tenant_id, bkcc, columns, record_source) -%}
   {%- set record_hash = 'md5(concat(' ~ md5_hash_columns(columns) ~ '))' -%}
   {%- set column_values_string = columns | map(attribute="'") | join(" || '||' || ") | replace("'", "''") -%} 

  SELECT
    {{ record_hash }} AS {{ table_name }}_HK,
    CURRENT_TIMESTAMP() AS load_date,
    {{ record_source }} AS record_source,
    CONCAT({{ tenant_id }}, '||', {{ bkcc }}, {{ column_values_string }}) AS {{ table_name }}_BK
{%- endmacro -%}


