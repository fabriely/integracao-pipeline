{{config(
    materialized = 'view', 
    schema='marts',
)}}

-- View para análise regional
SELECT
    dt.ano AS ano_registro,
    dl.desc_rpa,
    dl.endereco_bairro AS bairro,
    COUNT(DISTINCT de.codigo_escola) AS total_escolas,
    COUNT(fm.matricula) AS total_matriculas,
    COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) AS aprovados,
    COUNT(CASE WHEN ds.categoria = 'REPROVADO' THEN 1 END) AS reprovados,
    COUNT(CASE WHEN ds.categoria = 'TRANSFERIDO' THEN 1 END) AS transferidos,
    COUNT(CASE WHEN ds.categoria = 'DESISTENTE' THEN 1 END) AS desistentes,
    ROUND(
        COUNT(fm.matricula) * 1.0 / COUNT(DISTINCT de.codigo_escola), 
        2
    ) AS media_alunos_por_escola,
    ROUND(
        COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) * 100.0 / COUNT(fm.matricula), 
        2
    ) AS taxa_aprovacao_regional
FROM
    fato_matricula fm
JOIN
    dim_localizacao dl ON fm.id_locali = dl.id_locali
JOIN
    dim_escola de ON fm.id_escola = de.id_escola
JOIN
    dim_situacao ds ON fm.id_situacao = ds.id_situacao
JOIN
    dim_tempo dt ON fm.id_tempo = dt.id_tempo
GROUP BY
    dt.ano, dl.desc_rpa, dl.endereco_bairro
ORDER BY
    dt.ano, dl.desc_rpa, total_matriculas DESC
