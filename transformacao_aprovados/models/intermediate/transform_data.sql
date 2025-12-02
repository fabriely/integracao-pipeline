{{
    config(
        materialized='table',
    )
}}

with staged_data AS (
    SELECT * FROM {{ ref('staging_situacao_alunos') }}
),

transformed_data AS (
    SELECT
        CAST(ano AS INTEGER) AS ano,
        CAST(codigo_escola AS INTEGER) AS codigo_escola,
        CAST(matricula AS INTEGER) AS matricula,
        nome_escola,
        endereco_logra,
        endereco_bairro,
        endereco_numero,
        CAST(rpa AS INTEGER) AS rpa,
        CAST(mod_ens_codigo AS INTEGER) AS mod_ens_codigo,
        serie,
        turma,
        turno,
        CAST(idade AS INTEGER) AS idade,
        sexo,
        sit_nome AS situacao_nome,
        modalidade_ens,
        CASE
            WHEN CAST(idade AS INTEGER) <= 3 THEN '0-3 Anos (Educação Infantil)'
            WHEN CAST(idade AS INTEGER) <= 5 THEN '4-5 Anos (Pré-escola)'
            WHEN CAST(idade AS INTEGER) <= 10 THEN '6-10 Anos (Fundamental I)'
            WHEN CAST(idade AS INTEGER) <= 14 THEN '11-14 Anos (Fundamental II)'
            WHEN CAST(idade AS INTEGER) >= 15 THEN '15+ Anos (EJA e Outros)'
            ELSE 'Não Informado'
        END AS faixa_etaria
    FROM staged_data
)

SELECT * FROM transformed_data