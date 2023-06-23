{%- set hub_query = generate_hub_query('NATION', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'N_NAME'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_NATION') }}

{#
 select * FROM 
    {{ ref('ld_tpch_NATION') }}
#}    