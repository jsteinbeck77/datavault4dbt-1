{%- set hub_query = generate_hub_query('REGION', 'TENANT_ID', 'BKCC', ['TENANT_ID', 'BKCC', 'R_NAME'], 'RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_REGION') }}

{#
 select * FROM 
    {{ ref('ld_tpch_REGION') }}
#}     
UNION

{% set hub_query = generate_hub_query('REGION', 'N.TENANT_ID', 'N.BKCC', ['N.TENANT_ID', 'N.BKCC', 'R.R_NAME'], 'N.RECORD_SOURCE') -%}

{{ hub_query }}
FROM 
    {{ ref('ld_tpch_NATION') }} AS N 
INNER JOIN 
    (
        SELECT DISTINCT
            R.R_REGIONKEY
            , R.R_NAME
            , R.RECORD_SOURCE
        FROM 
            {{ ref('ld_tpch_REGION') }} R
    ) R 
ON
    N.N_REGIONKEY = R.R_REGIONKEY

{#
 select * FROM 
    {{ ref('ld_tpch_NATION') }}
#}        