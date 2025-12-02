{{config(
    materialized = 'view', 
    schema='marts',
)}}
SELECT
    dtemp.ano AS ano_registro,
    de.nome_escola,
    de.codigo_escola,
    ds.situacao_nome,
    COUNT(fm.matricula) AS contagem_situacao
FROM
    {{ ref('fato_matricula') }} fm
JOIN
    {{ ref('dim_escola') }} de ON fm.id_escola = de.id_escola
JOIN
    {{ ref('dim_situacao') }} ds ON fm.id_situacao = ds.id_situacao
JOIN
    {{ ref('dim_tempo') }} dtemp ON fm.id_tempo = dtemp.id_tempo
GROUP BY
    dtemp.ano, de.nome_escola, de.codigo_escola, ds.situacao_nome
ORDER BY
    dtemp.ano, de.nome_escola, contagem_situacao DESC