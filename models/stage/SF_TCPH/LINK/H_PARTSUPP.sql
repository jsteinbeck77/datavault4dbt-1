SELECT 
    * 
FROM 
    {{ ref('ld_tpch_PARTSUPP') }}

{%- set hub_query = generate_hub_query('SUPPLIER', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'S_NAME'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_PARTSUPP') }}

{#
 select * FROM 
    {{ ref('ld_tpch_PARTSUPP') }}
#}        