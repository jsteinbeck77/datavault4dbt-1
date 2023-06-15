{%- macro md5_hash_columns(columns, delimiter='||', upper_case=False) -%}
  {%- set columns_list = generate_columns_list(columns, upper_case) -%}
  
  "md5(concat({{ columns_list | join("'" ~ delimiter ~ "'") }}))"
{%- endmacro -%}