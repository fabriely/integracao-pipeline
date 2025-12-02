{{config(
    materialized = 'view', 
    schema='marts',
)}}
SELECT
    dtemp.ano AS ano_registro,
    dl.desc_rpa,
    da.faixa_etaria,
    COUNT(fm.matricula) AS total_alunos
FROM
    {{ ref('fato_matricula') }} fm
JOIN
    {{ ref('dim_aluno') }} da ON fm.id_aluno = da.id_aluno
JOIN
    {{ ref('dim_localizacao') }} dl ON fm.id_locali = dl.id_locali
JOIN
    {{ ref('dim_tempo') }} dtemp ON fm.id_tempo = dtemp.id_tempo
GROUP BY
    dtemp.ano, dl.desc_rpa, da.faixa_etaria
ORDER BY
    dtemp.ano, dl.desc_rpa, da.faixa_etaria