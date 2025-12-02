{{
    config(
        materialized='table',
        schema='dimensions',
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),
situacoes_unicas AS (
    SELECT DISTINCT
        situacao_nome,
        CASE 
            WHEN situacao_nome = 'Aprovado' THEN 'APROVADO'
            WHEN situacao_nome = 'Reprovado' THEN 'REPROVADO'
            WHEN situacao_nome = 'Transferido' THEN 'TRANSFERIDO'
            WHEN situacao_nome = 'Desistente' THEN 'DESISTENTE'
            ELSE 'OUTROS'
        END AS categoria,
        CASE 
            WHEN situacao_nome = 'Aprovado' THEN 1
            ELSE 0
        END AS eh_aprovado,
        CASE 
            WHEN situacao_nome = 'Reprovado' THEN 1
            ELSE 0
        END AS eh_reprovado
    FROM source
),
versao_final AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY situacao_nome) - 1 AS id_situacao, -- Surrogate Key
        situacao_nome,
        categoria,
        eh_aprovado,
        eh_reprovado
    FROM situacoes_unicas
)

SELECT * FROM versao_final