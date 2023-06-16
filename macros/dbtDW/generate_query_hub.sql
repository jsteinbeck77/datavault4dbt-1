{%- macro generate_hub_query(table_name, tenant_id, bkcc, columns, record_source) -%}
   {%- set record_hash = generate_columns_hash_md5(columns, "'||'", False, "'-1'") -%}
   {%- set column_values_string = generate_columns_list(columns, upper_case=False, delimiter="'||'") -%} 

  SELECT
    {{ record_hash }} AS {{ table_name }}_HK,
    CURRENT_TIMESTAMP() AS load_date,
    {{ record_source }} AS record_source,
    {{ tenant_id }} AS tenant_id,
    {{ bkcc }} AS bkcc,
    {{ column_values_string }} AS {{ table_name }}_BK

{%- endmacro -%}

