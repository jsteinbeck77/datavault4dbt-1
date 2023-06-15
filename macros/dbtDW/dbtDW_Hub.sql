{%- macro generate_hub_query(table_name, tenant_id, bkcc, columns) -%}
  {%- set record_hash = 'md5(concat(' ~ md5_hash_columns(columns) ~ '))' -%}
  
  SELECT
    {{ tenant_id }} AS tenant_id,
    {{ bkcc }} AS bkcc,
    'Record Source' AS record_source,
    CURRENT_TIMESTAMP() AS load_date,
    {{ record_hash }} AS {{ table_name }}_BK
{%- endmacro -%}


