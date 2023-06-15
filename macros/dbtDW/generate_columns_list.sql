{%- macro generate_columns_list(columns, upper_case=False, delimiter='||') -%}
  {%- set columns_list = [] -%}
  
  {%- for column in columns -%}
    {%- if upper_case -%}
      {%- do columns_list.append("upper(replace(coalesce(" ~ column ~ "::varchar, ''), ' ', ''))") -%}
    {%- else -%}
      {%- do columns_list.append("replace(coalesce(" ~ column ~ "::varchar, ''), ' ', '')") -%}
    {%- endif -%}
  {%- endfor -%}
  
  {{ columns_list | join(delimiter) }}{{ delimiter }}
{%- endmacro -%}

 