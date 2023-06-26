WITH H_REGION_HK AS (
   {{- datavault4dbt.hash(columns=['N_REGIONKEY'], multi_active_key=False, main_hashkey_column=True) -}}   
)
, H_NATION_HK AS (
   {{- datavault4dbt.hash(columns=['N_NATIONKEY'], multi_active_key=False, main_hashkey_column=True)  -}}  
)
, L_NATIONAL_REGIONS_HK AS (
    {{- datavault4dbt.hash(columns=['N_NATIONKEY', 'N_REGIONKEY'], multi_active_key=False, main_hashkey_column=False) -}}             
)
, HASHDIFF AS (
   {{- datavault4dbt.hash(columns=['N_NAME', 'N_REGIONKEY', 'N_COMMENT'], multi_active_key=False, main_hashkey_column=False) -}}
)
SELECT 
    H_REGION_HK
    , H_NATION_HK
    , L_NATIONAL_REGIONS_HK
    , CURRENT_TIMESTAMP() AS LOAD_DATETIME
    , D.RECORD_SOURCE
    , D.TENANT_ID
    , D.BKCC
    , HASHDIFF
    , D.N_NAME
    , D.N_REGIONKEY
    , D.N_COMMENT
FROM 
    {{ ref('ld_tpch_NATION') }} D



