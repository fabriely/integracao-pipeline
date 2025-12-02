{{config(
    materialized = 'view', 
    schema='marts',
)}}
SELECT
    dtemp.ano AS ano_registro,
    dt.modalidade_ensino,
    COUNT(fm.matricula) AS total_matriculas,
    SUM(ds.eh_aprovado) AS total_aprovados,
    SUM(ds.eh_reprovado) AS total_reprovados,
    -- Calcula a taxa de aprovação (como porcentagem)
    CAST(SUM(ds.eh_aprovado) AS DECIMAL) * 100 / COUNT(fm.matricula) AS taxa_aprovacao_percentual,
    -- Calcula a taxa de reprovação (como porcentagem)
    CAST(SUM(ds.eh_reprovado) AS DECIMAL) * 100 / COUNT(fm.matricula) AS taxa_reprovacao_percentual
FROM
    {{ ref('fato_matricula') }} fm
JOIN
    {{ ref('dim_situacao') }} ds ON fm.id_situacao = ds.id_situacao
JOIN
    {{ ref('dim_turma') }} dt ON fm.id_turma = dt.id_turma
JOIN
    {{ ref('dim_tempo') }} dtemp ON fm.id_tempo = dtemp.id_tempo
GROUP BY
    dtemp.ano, dt.modalidade_ensino
ORDER BY
    dtemp.ano, dt.modalidade_ensino