-- ========================================
-- Schema da Staging Area
-- Base de dados temporária para dados brutos
-- ========================================

-- Cria schema staging se não existir
CREATE SCHEMA IF NOT EXISTS staging;

-- Tabela de staging para dados brutos
CREATE TABLE IF NOT EXISTS staging.alunos_raw (
    id SERIAL PRIMARY KEY,
    matricula VARCHAR(50),
    nome_aluno VARCHAR(255),
    data_nascimento DATE,
    genero VARCHAR(20),
    codigo_escola VARCHAR(50),
    nome_escola VARCHAR(255),
    regional VARCHAR(100),
    tipo_escola VARCHAR(50),
    ano_letivo INTEGER,
    periodo_letivo VARCHAR(50),
    data_inicio DATE,
    data_fim DATE,
    situacao_final VARCHAR(100),
    nota_final DECIMAL(5,2),
    faltas INTEGER,
    total_aulas INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX idx_staging_matricula ON staging.alunos_raw(matricula);
CREATE INDEX idx_staging_escola ON staging.alunos_raw(codigo_escola);
CREATE INDEX idx_staging_ano ON staging.alunos_raw(ano_letivo);
CREATE INDEX idx_staging_loaded ON staging.alunos_raw(loaded_at);

-- Tabela de metadados de carga
CREATE TABLE IF NOT EXISTS staging.load_metadata (
    id SERIAL PRIMARY KEY,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    records_loaded INTEGER,
    load_status VARCHAR(50),
    error_message TEXT,
    load_duration_seconds INTEGER
);

-- Comentários das tabelas
COMMENT ON TABLE staging.alunos_raw IS 'Tabela de staging para dados brutos de alunos';
COMMENT ON TABLE staging.load_metadata IS 'Metadados das cargas realizadas';
