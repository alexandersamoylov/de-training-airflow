-- ods_mdm_user

TRUNCATE asamoilov.ods_mdm_user;

INSERT INTO asamoilov.ods_mdm_user
SELECT
    id AS user_id,
    legal_type AS legal_type,
    district AS district,
    registered_at AS registered_at,
    billing_mode AS billing_mode,
    is_vip AS is_vip
FROM mdm.user;


-- dds_hub_user

INSERT INTO asamoilov.dds_hub_user
WITH source_data AS (
    SELECT
        sd.user_pk, 
        sd.user_key, 
        sd.load_date, 
        sd.record_source
    FROM (
        SELECT
            s.user_pk,
            s.user_key, 
            s.load_date, 
            s.record_source,
            row_number() OVER (PARTITION BY s.user_pk ORDER BY s.effective_from ASC) AS row_number
        FROM asamoilov.ods_mdm_user_hash s
        -- WHERE s.date_part_year = {{ execution_date.year }}
    ) sd
    WHERE sd.row_number = 1
)
SELECT sd0.user_pk, 
    sd0.user_key, 
    sd0.load_date, 
    sd0.record_source
FROM source_data sd0
LEFT JOIN asamoilov.dds_hub_user ud0 ON sd0.user_pk = ud0.user_pk
WHERE ud0.user_pk IS NULL;


-- dds_sat_user_mdm

INSERT INTO asamoilov.dds_sat_user_mdm
WITH source_data AS (
    SELECT 
        sd.user_pk, 
        sd.user_hashdiff, 
        sd.legal_type,
        sd.district,
        sd.billing_mode,
        sd.is_vip,
        sd.effective_from, 
        sd.load_date, 
        sd.record_source
    FROM (
        SELECT s.user_pk, 
            s.user_hashdiff, 
            s.legal_type,
            s.district,
            s.billing_mode,
            s.is_vip,
            s.effective_from, 
            s.load_date, 
            s.record_source,
            row_number() OVER (PARTITION BY s.user_pk, s.user_hashdiff ORDER BY s.effective_from ASC) AS row_number
        FROM asamoilov.ods_mdm_user_hash s
        -- WHERE s.date_part_year = {{ execution_date.year }}
    ) sd
    WHERE sd.row_number = 1
)
SELECT 
    sd0.user_pk,
    sd0.user_hashdiff,
    sd0.legal_type,
    sd0.district,
    sd0.billing_mode,
    sd0.is_vip,
    sd0.effective_from, 
    sd0.load_date, 
    sd0.record_source
FROM source_data sd0
LEFT JOIN asamoilov.dds_sat_user_mdm ud0 ON sd0.user_pk = ud0.user_pk
    AND sd0.user_hashdiff = ud0.user_hashdiff
WHERE ud0.user_hashdiff IS NULL;

