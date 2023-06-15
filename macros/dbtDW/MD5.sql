{%- macro md5_hash_columns(columns, delimiter='||', upper_case=False) -%}
  {%- set columns_list = [] -%}
  
  {%- for column in columns -%}
    {%- if upper_case -%}
      {%- do columns_list.append("upper(replace(coalesce(" ~ column ~ "::varchar, ''), ' ', ''))") -%}
    {%- else -%}
      {%- do columns_list.append("replace(coalesce(" ~ column ~ "::varchar, ''), ' ', '')") -%}
    {%- endif -%}
  {%- endfor -%}
  
  md5(concat({{ columns_list | join(delimiter) }}))
{%- endmacro -%}
