{%- set hub_query = generate_hub_query('REGION', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'R_NAME'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_REGION') }}