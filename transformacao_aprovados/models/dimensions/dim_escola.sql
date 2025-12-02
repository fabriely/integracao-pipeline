{{
    config(
        materialized='table',
        schema='dimensions',
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),
escolas_unicas AS (
    SELECT DISTINCT
        codigo_escola,
        nome_escola,
        endereco_logra,
        endereco_bairro,
        endereco_numero,
        rpa
    FROM source
),
versao_final AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY codigo_escola) - 1 AS id_escola, -- Surrogate Key
        codigo_escola,
        nome_escola,
        endereco_logra,
        endereco_bairro,
        endereco_numero,
        rpa
    FROM escolas_unicas
)

SELECT * FROM versao_final