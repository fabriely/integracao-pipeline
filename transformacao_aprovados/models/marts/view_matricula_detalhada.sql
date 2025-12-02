{{config(
    materialized = 'view', 
    schema='marts',
)}}
SELECT
    fm.matricula,
    da.sexo,
    da.idade,
    da.faixa_etaria,
    de.nome_escola,
    de.codigo_escola,
    dt.turma,
    dt.turno,
    dt.serie,
    dt.modalidade_ensino,
    ds.situacao_nome,
    ds.categoria AS categoria_situacao,
    ds.eh_aprovado,
    ds.eh_reprovado,
    dl.desc_rpa,
    dl.endereco_bairro AS bairro_localizacao,
    dtemp.ano AS ano_registro
FROM
    {{ ref('fato_matricula') }} fm
JOIN
    {{ ref('dim_aluno') }} da ON fm.id_aluno = da.id_aluno
JOIN
    {{ ref('dim_escola') }} de ON fm.id_escola = de.id_escola
JOIN
    {{ ref('dim_turma') }} dt ON fm.id_turma = dt.id_turma
JOIN
    {{ ref('dim_situacao') }} ds ON fm.id_situacao = ds.id_situacao
JOIN
    {{ ref('dim_localizacao') }} dl ON fm.id_locali = dl.id_locali
JOIN
    {{ ref('dim_tempo') }} dtemp ON fm.id_tempo = dtemp.id_tempo