{{
    config(
        materialized='table',
        schema='facts',
    )
}}

with source AS (
    SELECT * FROM {{ ref('transform_data') }} 
),

-- Dimensões com seus IDs
dim_aluno AS (
    SELECT id_aluno, matricula, sexo, idade, faixa_etaria 
    FROM {{ ref('dim_aluno') }}
),

dim_escola AS (
    SELECT id_escola, codigo_escola 
    FROM {{ ref('dim_escola') }}
),

dim_turma AS (
    SELECT id_turma, turma, turno, serie, mod_ens_codigo, modalidade_ensino 
    FROM {{ ref('dim_turma') }}
),

dim_situacao AS (
    SELECT id_situacao, situacao_nome 
    FROM {{ ref('dim_situacao') }}
),

dim_localizacao AS (
    SELECT id_locali, rpa, endereco_bairro 
    FROM {{ ref('dim_localizacao') }}
),

dim_tempo AS (
    SELECT id_tempo, ano 
    FROM {{ ref('dim_tempo') }}
),

-- Construindo a tabela fato
fato AS (
    SELECT
        da.id_aluno,
        de.id_escola,
        dt.id_turma,
        dsi.id_situacao,
        dl.id_locali,
        dte.id_tempo,
        s.matricula,
        1 AS qtd_alunos
    FROM source s
    
    LEFT JOIN dim_aluno da 
        ON s.matricula = da.matricula
        AND s.sexo = da.sexo
        AND s.idade = da.idade
    
    LEFT JOIN dim_escola de 
        ON s.codigo_escola = de.codigo_escola
    
    LEFT JOIN dim_turma dt 
        ON s.turma = dt.turma
        AND s.turno = dt.turno
        AND s.serie = dt.serie
        AND s.mod_ens_codigo = dt.mod_ens_codigo
        AND s.modalidade_ens = dt.modalidade_ensino
    
    LEFT JOIN dim_situacao dsi 
        ON s.situacao_nome = dsi.situacao_nome
    
    LEFT JOIN dim_localizacao dl 
        ON s.rpa = dl.rpa
        AND s.endereco_bairro = dl.endereco_bairro
    
    LEFT JOIN dim_tempo dte 
        ON s.ano = dte.ano
)

SELECT * FROM fato