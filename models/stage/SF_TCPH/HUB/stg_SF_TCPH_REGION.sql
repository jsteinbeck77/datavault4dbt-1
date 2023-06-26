WITH H_REGION_HK AS (
   {{- datavault4dbt.hash(columns=['TENANT_ID', 'BKCC', 'R_REGIONKEY'], multi_active_key=False, main_hashkey_column=True) -}}   
)
, HASHDIFF AS (
   {{- datavault4dbt.hash(columns=['R_NAME', 'R_COMMENT'], multi_active_key=False, main_hashkey_column=False) -}}
)
SELECT 
    H_REGION_HK
    , CURRENT_TIMESTAMP()   AS LOAD_DATETIME
    , D.RECORD_SOURCE
    , D.TENANT_ID
    , D.BKCC
    , HASHDIFF
    , D.R_REGIONKEY         AS H_REGION_BK
    , D.R_NAME
    , D.R_COMMENT
FROM 
    {{ ref('ld_tpch_REGION') }} D

{#
SELECT 
    *
FROM 
    {{ ref('ld_tpch_REGION') }} D
#}
