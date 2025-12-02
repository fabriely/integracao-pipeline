{{
    config(
        materialized='table',
        schema='dimensions'
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),

anos_unicos AS (
    SELECT DISTINCT
        ano,
        'Registro Anual' AS ano_ensino
    FROM source
),

versao_final AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ano) - 1 AS id_tempo, -- Surrogate Key
        ano,
        ano_ensino
    FROM anos_unicos
)
SELECT * FROM versao_final