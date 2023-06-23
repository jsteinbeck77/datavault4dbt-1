{%- set hub_query = generate_hub_query('ORDER', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'O_ORDERKEY', 'O_ORDERDATE'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_ORDERS') }}

{#
 select * FROM 
    {{ ref('ld_tpch_ORDERS') }}
#}            