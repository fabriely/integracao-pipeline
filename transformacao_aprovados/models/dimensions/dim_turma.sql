{{
    config(
        materialized='table',
        schema='dimensions',
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),
turmas_unicas AS (
    SELECT DISTINCT
        turma,
        turno,
        serie,
        mod_ens_codigo,
        modalidade_ens
    FROM source
),
versao_final AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY turma, turno, serie) - 1 AS id_turma,
        turma,
        turno,
        NULL AS serie_codigo,
        serie,
        mod_ens_codigo,
        modalidade_ens AS modalidade_ensino
    FROM turmas_unicas
)

SELECT * FROM versao_final