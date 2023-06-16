{%- set hub_query = generate_hub_query('CUSTOMER', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'C_CUSTKEY'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_CUSTOMER') }}

{#
 select * FROM 
    {{ ref('ld_tpch_CUSTOMER') }}
#}