{%- set hub_query = generate_hub_query('Test_Name', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'R_NAME'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM {{ ref('ld_tpch_REGION') }}