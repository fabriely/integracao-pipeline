-- ========================================
-- Schema do Data Warehouse
-- Modelo Dimensional (Star Schema)
-- ========================================

-- Cria schema DW
CREATE SCHEMA IF NOT EXISTS dw;

-- ========================================
-- DIMENSÕES
-- ========================================

-- Dimensão Aluno
CREATE TABLE IF NOT EXISTS dw.dim_aluno (
    sk_aluno SERIAL PRIMARY KEY,
    matricula VARCHAR(50) UNIQUE NOT NULL,
    nome_aluno VARCHAR(255),
    data_nascimento DATE,
    genero VARCHAR(20),
    idade_atual INTEGER,
    faixa_etaria VARCHAR(50),
    data_inicio_vigencia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fim_vigencia TIMESTAMP,
    versao INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_dim_aluno_matricula ON dw.dim_aluno(matricula);
CREATE INDEX idx_dim_aluno_ativo ON dw.dim_aluno(ativo);

-- Dimensão Escola
CREATE TABLE IF NOT EXISTS dw.dim_escola (
    sk_escola SERIAL PRIMARY KEY,
    codigo_escola VARCHAR(50) UNIQUE NOT NULL,
    nome_escola VARCHAR(255),
    regional VARCHAR(100),
    tipo_escola VARCHAR(50),
    endereco VARCHAR(500),
    bairro VARCHAR(100),
    data_inicio_vigencia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fim_vigencia TIMESTAMP,
    versao INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_dim_escola_codigo ON dw.dim_escola(codigo_escola);
CREATE INDEX idx_dim_escola_regional ON dw.dim_escola(regional);
CREATE INDEX idx_dim_escola_ativo ON dw.dim_escola(ativo);

-- Dimensão Tempo
CREATE TABLE IF NOT EXISTS dw.dim_tempo (
    sk_tempo SERIAL PRIMARY KEY,
    data DATE UNIQUE NOT NULL,
    ano INTEGER,
    mes INTEGER,
    dia INTEGER,
    trimestre INTEGER,
    semestre INTEGER,
    dia_semana INTEGER,
    nome_dia_semana VARCHAR(20),
    nome_mes VARCHAR(20),
    ano_mes VARCHAR(7),
    eh_feriado BOOLEAN DEFAULT FALSE,
    eh_fim_semana BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_dim_tempo_data ON dw.dim_tempo(data);
CREATE INDEX idx_dim_tempo_ano_mes ON dw.dim_tempo(ano, mes);

-- Dimensão Período Letivo
CREATE TABLE IF NOT EXISTS dw.dim_periodo_letivo (
    sk_periodo SERIAL PRIMARY KEY,
    ano_letivo INTEGER,
    periodo_letivo VARCHAR(50),
    data_inicio DATE,
    data_fim DATE,
    dias_letivos INTEGER,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_dim_periodo_ano ON dw.dim_periodo_letivo(ano_letivo);

-- Dimensão Situação
CREATE TABLE IF NOT EXISTS dw.dim_situacao (
    sk_situacao SERIAL PRIMARY KEY,
    situacao_final VARCHAR(100) UNIQUE NOT NULL,
    categoria_situacao VARCHAR(50),
    eh_aprovado BOOLEAN,
    eh_reprovado BOOLEAN,
    descricao TEXT
);

-- ========================================
-- FATOS
-- ========================================

-- Fato Situação Final do Aluno
CREATE TABLE IF NOT EXISTS dw.fato_situacao_aluno (
    sk_fato SERIAL PRIMARY KEY,
    sk_aluno INTEGER REFERENCES dw.dim_aluno(sk_aluno),
    sk_escola INTEGER REFERENCES dw.dim_escola(sk_escola),
    sk_periodo INTEGER REFERENCES dw.dim_periodo_letivo(sk_periodo),
    sk_situacao INTEGER REFERENCES dw.dim_situacao(sk_situacao),
    sk_tempo_inicio INTEGER REFERENCES dw.dim_tempo(sk_tempo),
    sk_tempo_fim INTEGER REFERENCES dw.dim_tempo(sk_tempo),
    
    -- Métricas
    nota_final DECIMAL(5,2),
    faltas INTEGER,
    total_aulas INTEGER,
    taxa_frequencia DECIMAL(5,2),
    taxa_aproveitamento DECIMAL(5,2),
    
    -- Flags
    aprovado BOOLEAN,
    frequencia_adequada BOOLEAN,
    
    -- Metadados
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_carga INTEGER
);

-- Índices da tabela fato
CREATE INDEX idx_fato_aluno ON dw.fato_situacao_aluno(sk_aluno);
CREATE INDEX idx_fato_escola ON dw.fato_situacao_aluno(sk_escola);
CREATE INDEX idx_fato_periodo ON dw.fato_situacao_aluno(sk_periodo);
CREATE INDEX idx_fato_situacao ON dw.fato_situacao_aluno(sk_situacao);
CREATE INDEX idx_fato_data_carga ON dw.fato_situacao_aluno(data_carga);

-- ========================================
-- VIEWS AGREGADAS
-- ========================================

-- View: Taxa de aprovação por escola
CREATE OR REPLACE VIEW dw.vw_taxa_aprovacao_escola AS
SELECT 
    e.nome_escola,
    e.regional,
    p.ano_letivo,
    COUNT(*) as total_alunos,
    SUM(CASE WHEN f.aprovado THEN 1 ELSE 0 END) as alunos_aprovados,
    ROUND(
        100.0 * SUM(CASE WHEN f.aprovado THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) as taxa_aprovacao
FROM dw.fato_situacao_aluno f
JOIN dw.dim_escola e ON f.sk_escola = e.sk_escola
JOIN dw.dim_periodo_letivo p ON f.sk_periodo = p.sk_periodo
WHERE e.ativo = TRUE
GROUP BY e.nome_escola, e.regional, p.ano_letivo;

-- View: Desempenho por regional
CREATE OR REPLACE VIEW dw.vw_desempenho_regional AS
SELECT 
    e.regional,
    p.ano_letivo,
    COUNT(DISTINCT e.sk_escola) as total_escolas,
    COUNT(*) as total_alunos,
    ROUND(AVG(f.nota_final), 2) as media_nota,
    ROUND(AVG(f.taxa_frequencia), 2) as media_frequencia,
    ROUND(
        100.0 * SUM(CASE WHEN f.aprovado THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) as taxa_aprovacao
FROM dw.fato_situacao_aluno f
JOIN dw.dim_escola e ON f.sk_escola = e.sk_escola
JOIN dw.dim_periodo_letivo p ON f.sk_periodo = p.sk_periodo
WHERE e.ativo = TRUE
GROUP BY e.regional, p.ano_letivo;

-- ========================================
-- COMENTÁRIOS
-- ========================================

COMMENT ON SCHEMA dw IS 'Data Warehouse - Modelo Dimensional';
COMMENT ON TABLE dw.dim_aluno IS 'Dimensão de alunos com SCD Tipo 2';
COMMENT ON TABLE dw.dim_escola IS 'Dimensão de escolas com SCD Tipo 2';
COMMENT ON TABLE dw.dim_tempo IS 'Dimensão temporal padrão';
COMMENT ON TABLE dw.fato_situacao_aluno IS 'Fato transacional de situação final dos alunos';
