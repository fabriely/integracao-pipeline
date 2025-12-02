{{config(
    materialized = 'view', 
    schema='marts',
)}}

-- View para análise de performance por modalidade de ensino
SELECT
    dt.ano AS ano_registro,
    dtu.modalidade_ens AS modalidade_ensino,
    dtu.serie,
    COUNT(fm.matricula) AS total_matriculas,
    COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) AS total_aprovados,
    COUNT(CASE WHEN ds.categoria = 'REPROVADO' THEN 1 END) AS total_reprovados,
    COUNT(CASE WHEN ds.categoria = 'TRANSFERIDO' THEN 1 END) AS total_transferidos,
    COUNT(CASE WHEN ds.categoria = 'DESISTENTE' THEN 1 END) AS total_desistentes,
    ROUND(
        COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) * 100.0 / COUNT(fm.matricula), 
        2
    ) AS taxa_aprovacao,
    ROUND(
        COUNT(CASE WHEN ds.categoria = 'REPROVADO' THEN 1 END) * 100.0 / COUNT(fm.matricula), 
        2
    ) AS taxa_reprovacao,
    ROUND(
        COUNT(CASE WHEN ds.categoria = 'DESISTENTE' THEN 1 END) * 100.0 / COUNT(fm.matricula), 
        2
    ) AS taxa_desistencia
FROM
    fato_matricula fm
JOIN
    dim_turma dtu ON fm.id_turma = dtu.id_turma
JOIN
    dim_situacao ds ON fm.id_situacao = ds.id_situacao
JOIN
    dim_tempo dt ON fm.id_tempo = dt.id_tempo
GROUP BY
    dt.ano, dtu.modalidade_ens, dtu.serie
ORDER BY
    dt.ano, dtu.modalidade_ens, dtu.serie
