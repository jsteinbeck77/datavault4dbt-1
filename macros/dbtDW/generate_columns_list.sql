{%- macro generate_columns_list(columns, upper_case=False, delimiter="'||'", replace_value="'-1'") -%}
  {%- set columns_list = [] -%}
  
  {%- for column in columns -%}
    {%- if upper_case -%}
      {%- do columns_list.append("upper(coalesce(nullif(trim(" ~ column ~ "::varchar), ''), " ~ replace_value ~ "))") -%}
    {%- else -%}
      {%- do columns_list.append("coalesce(nullif(trim(" ~ column ~ "::varchar), ''), " ~ replace_value ~ ")") -%}
    {%- endif -%}
  {%- endfor -%}
  
   {{ columns_list | join(" || " ~ delimiter ~ " || ") }} || {{ delimiter }}
{%- endmacro -%}



