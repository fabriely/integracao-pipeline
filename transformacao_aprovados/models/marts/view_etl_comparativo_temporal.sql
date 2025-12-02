{{config(
    materialized = 'view', 
    schema='marts',
)}}

-- 
-- View para fornecer uma análise temporal detalhada dos indicadores educacionais,
-- permitindo comparar a evolução ano a ano

WITH dados_anuais AS (
    SELECT
        dt.ano AS ano_registro,
        COUNT(fm.matricula) AS total_matriculas,
        COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) AS aprovados,
        COUNT(CASE WHEN ds.categoria = 'REPROVADO' THEN 1 END) AS reprovados,
        COUNT(CASE WHEN ds.categoria = 'DESISTENTE' THEN 1 END) AS desistentes,
        ROUND(
            COUNT(CASE WHEN ds.categoria = 'APROVADO' THEN 1 END) * 100.0 / COUNT(fm.matricula), 
            2
        ) AS taxa_aprovacao,
        COUNT(DISTINCT de.codigo_escola) AS total_escolas,
        ROUND(AVG(da.idade), 2) AS idade_media
    FROM
        fato_matricula fm
    JOIN
        dim_aluno da ON fm.id_aluno = da.id_aluno
    JOIN
        dim_escola de ON fm.id_escola = de.id_escola
    JOIN
        dim_situacao ds ON fm.id_situacao = ds.id_situacao
    JOIN
        dim_tempo dt ON fm.id_tempo = dt.id_tempo
    GROUP BY
        dt.ano
)
SELECT
    ano_registro,
    total_matriculas,
    aprovados,
    reprovados,
    desistentes,
    taxa_aprovacao,
    total_escolas,
    idade_media,
    -- Comparações com o ano anterior
    LAG(total_matriculas) OVER (ORDER BY ano_registro) AS matriculas_ano_anterior,
    LAG(taxa_aprovacao) OVER (ORDER BY ano_registro) AS taxa_aprovacao_ano_anterior,
    -- Variações percentuais
    ROUND(
        (total_matriculas - LAG(total_matriculas) OVER (ORDER BY ano_registro)) * 100.0 / 
        NULLIF(LAG(total_matriculas) OVER (ORDER BY ano_registro), 0),
        2
    ) AS variacao_matriculas_percent,
    ROUND(
        taxa_aprovacao - LAG(taxa_aprovacao) OVER (ORDER BY ano_registro),
        2
    ) AS variacao_taxa_aprovacao_pontos,
    -- Tendências
    CASE 
        WHEN total_matriculas > LAG(total_matriculas) OVER (ORDER BY ano_registro) THEN 'CRESCIMENTO'
        WHEN total_matriculas < LAG(total_matriculas) OVER (ORDER BY ano_registro) THEN 'DECLÍNIO'
        ELSE 'ESTÁVEL'
    END AS tendencia_matriculas,
    CASE 
        WHEN taxa_aprovacao > LAG(taxa_aprovacao) OVER (ORDER BY ano_registro) THEN 'MELHORIA'
        WHEN taxa_aprovacao < LAG(taxa_aprovacao) OVER (ORDER BY ano_registro) THEN 'PIORA'
        ELSE 'ESTÁVEL'
    END AS tendencia_aprovacao
FROM
    dados_anuais
ORDER BY
    ano_registro
