{%- set hub_query = generate_hub_query('PART', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'P_PARTKEY', 'P_MFGR', 'P_BRAND'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_PART') }}

{#
 select * FROM 
    {{ ref('ld_tpch_PART') }}
#}        