{{
    config(
        materialized='table',
        schema='dimensions',
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),
alunos_unicos AS (
    SELECT DISTINCT
        matricula,
        sexo,
        idade,
        faixa_etaria
    FROM source
),
versao_final AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY matricula) - 1 AS id_aluno, -- Surrogate Key
        matricula,
        sexo,
        idade,
        faixa_etaria
    FROM alunos_unicos
)

SELECT * FROM versao_final