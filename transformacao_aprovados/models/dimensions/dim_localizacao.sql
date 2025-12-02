{{
    config(
        materialized='table',
        schema='dimensions',
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),
localizacoes_unicas AS (
    SELECT DISTINCT
        rpa,
        endereco_bairro,
        CASE rpa
            WHEN 1 THEN 'RPA 1 (Centro)'
            WHEN 2 THEN 'RPA 2 (Zona Norte)'
            WHEN 3 THEN 'RPA 3 (Zona Oeste)'
            WHEN 4 THEN 'RPA 4 (Zona Sudoeste)'
            WHEN 5 THEN 'RPA 5 (Zona Sul)'
            WHEN 6 THEN 'RPA 6 (Zona Sudeste)'
            ELSE 'RPA Não Identificada'
        END AS desc_rpa
    FROM source
),
versao_final AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY rpa, endereco_bairro) - 1 AS id_locali, -- Surrogate Key
        rpa,
        endereco_bairro,
        desc_rpa
    FROM localizacoes_unicas
)

SELECT * FROM versao_final