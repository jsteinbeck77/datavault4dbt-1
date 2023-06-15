{% macro Load_Table_Template(Tenant_ID, BKCC, Source_Name, Table_Name) %}

SELECT 
    '{{ Tenant_ID }}'   AS Tenant_ID
    , '{{ BKCC }}'      AS BKCC
    , *
FROM 
    {{ source(Source_Name|upper, Table_Name|upper) }}

{% endmacro %}