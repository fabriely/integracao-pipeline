{{config(
    materialized = 'view', 
    schema='marts',
)}}

-- View para análise de distribuição de alunos por faixa etária
SELECT
    dt.ano AS ano_registro,
    da.faixa_etaria,
    da.sexo,
    COUNT(fm.matricula) AS total_alunos,
    COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) AS aprovados,
    COUNT(CASE WHEN ds.categoria = 'REPROVADO' THEN 1 END) AS reprovados,
    COUNT(CASE WHEN ds.categoria = 'TRANSFERIDO' THEN 1 END) AS transferidos,
    COUNT(CASE WHEN ds.categoria = 'DESISTENTE' THEN 1 END) AS desistentes,
    ROUND(
        COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) * 100.0 / COUNT(fm.matricula), 
        2
    ) AS taxa_aprovacao_percent
FROM
    fato_matricula fm
JOIN
    dim_aluno da ON fm.id_aluno = da.id_aluno
JOIN
    dim_situacao ds ON fm.id_situacao = ds.id_situacao
JOIN
    dim_tempo dt ON fm.id_tempo = dt.id_tempo
GROUP BY
    dt.ano, da.faixa_etaria, da.sexo
ORDER BY
    dt.ano, da.faixa_etaria, da.sexo
