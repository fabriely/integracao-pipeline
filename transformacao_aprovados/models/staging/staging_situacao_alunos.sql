WITH source AS (
    SELECT * FROM {{ source('transformacao_matricula','staging_alunos_raw') }}
),

cleaning_renaming AS (
    SELECT
        ano,
        codigo_escola,
        matricula,
        escola AS nome_escola,
        endereco_logradouro AS endereco_logra,
        endereco_bairro,
        endereco_numero,
        rpa,
        modalidade_ensino_codigo AS mod_ens_codigo,
        -- Transformação da SÉRIE
        CASE
            -- Ensino Fundamental (1º ao 9º)
            WHEN serie LIKE '%1 ANO%' OR serie LIKE '%1º ANO%' THEN '1º ANO'
            WHEN serie LIKE '%2 ANO%' OR serie LIKE '%2º ANO%' THEN '2º ANO'
            WHEN serie LIKE '%3 ANO%' OR serie LIKE '%3º ANO%' THEN '3º ANO'
            WHEN serie LIKE '%4 ANO%' OR serie LIKE '%4º ANO%' THEN '4º ANO'
            WHEN serie LIKE '%5 ANO%' OR serie LIKE '%5º ANO%' THEN '5º ANO'
            WHEN serie LIKE '%6 ANO%' OR serie LIKE '%6º ANO%' THEN '6º ANO'
            WHEN serie LIKE '%7 ANO%' OR serie LIKE '%7º ANO%' THEN '7º ANO'
            WHEN serie LIKE '%8 ANO%' OR serie LIKE '%8º ANO%' THEN '8º ANO'
            WHEN serie LIKE '%9 ANO%' OR serie LIKE '%9º ANO%' THEN '9º ANO'
            -- Educação Infantil (Berçário e Grupos)
            WHEN serie LIKE '%BER%' THEN 'BERÇARIO'
            WHEN serie LIKE '%GRUPO I%' OR serie LIKE '%GRUPO 1%' THEN 'GRUPO I'
            WHEN serie LIKE '%GRUPO II%' THEN 'GRUPO II'
            WHEN serie LIKE '%GRUPO III%' THEN 'GRUPO III'
            WHEN serie LIKE '%GRUPO IV%' THEN 'GRUPO IV'
            WHEN serie LIKE '%GRUPO V%' THEN 'GRUPO V'
            -- EJA (Módulos 1 ao 5) 
            WHEN serie LIKE '%1%' AND (serie LIKE '%MÓDULO%' OR serie LIKE '%MDULO%' OR serie LIKE '%MODULO%') THEN 'MÓDULO 1'
            WHEN serie LIKE '%2%' AND (serie LIKE '%MÓDULO%' OR serie LIKE '%MDULO%' OR serie LIKE '%MODULO%') THEN 'MÓDULO 2'
            WHEN serie LIKE '%3%' AND (serie LIKE '%MÓDULO%' OR serie LIKE '%MDULO%' OR serie LIKE '%MODULO%') THEN 'MÓDULO 3'
            WHEN serie LIKE '%4%' AND (serie LIKE '%MÓDULO%' OR serie LIKE '%MDULO%' OR serie LIKE '%MODULO%') THEN 'MÓDULO 4'
            WHEN serie LIKE '%5%' AND (serie LIKE '%MÓDULO%' OR serie LIKE '%MDULO%' OR serie LIKE '%MODULO%') THEN 'MÓDULO 5'
            WHEN serie LIKE '%TRAVESSIA%' THEN 'TRAVESSIA RECIFE'
            WHEN serie LIKE '%CORRECAO%1%' THEN 'CORREÇÃO DE FLUXO 1 - ALFABETIZACAO'
            WHEN serie LIKE '%CORRECAO%2%' THEN 'CORREÇÃO DE FLUXO 2 - ACELERACAO'
            ELSE 'OUTROS'
        END AS serie,
        turma,
        turno,
        idade,
        -- transformação do SEXO
        CASE
            WHEN sexo = '1' THEN 'Masculino'
            WHEN sexo = '2' THEN 'Feminino'
            WHEN sexo = '3' THEN 'Outros'
            ELSE 'Não informado'
        END AS sexo,
        -- transformação de situacao
        CASE 
            WHEN situacao_nome LIKE '%APROV%' THEN 'Aprovado'
            WHEN situacao_nome LIKE '%RET%' OR situacao_nome LIKE '%REPRO%' THEN 'Reprovado'
            WHEN situacao_nome LIKE '%TR%' OR situacao_nome LIKE '%REMAN%' THEN 'Transferido'
            WHEN situacao_nome LIKE '%DESIST%' THEN 'Desistente'
            ELSE 'Outros'
        END AS sit_nome,
        -- Transformação da MODALIDADE
        CASE
            WHEN modalidade_ensino LIKE '%EDUCACAO INFANTIL%' THEN 'EDUCAÇÃO INFANTIL'
            WHEN modalidade_ensino LIKE '%ENSINO FUNDAMENTAL%' THEN 'ENSINO FUNDAMENTAL'
            WHEN modalidade_ensino LIKE '%EDUCACAO JOVENS E ADULTOS%' THEN 'EJA'
            WHEN modalidade_ensino LIKE '%CORRE%' THEN 'CORREÇÃO DE FLUXO'
            ELSE 'OUTROS'
        END AS modalidade_ens
    FROM source
)

SELECT * FROM cleaning_renaming