{%- macro generate_columns_hash_md5(columns, delimiter='||', upper_case=False, replace_value='-1') -%}
  {%- set columns_list = generate_columns_list(columns, upper_case, delimiter, replace_value) -%}
  
  TO_BINARY(SHA1({{ columns_list }}))
{%- endmacro -%}

