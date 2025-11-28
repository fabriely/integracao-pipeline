# Pipeline ETL - Situação Final dos Alunos do Recife

## Início Rápido

### Pré-requisitos

- **Python 3.8+**
- **PostgreSQL 12+** 
- **Git**
- **Jupyter Notebook** (opcional, mas recomendado)

### Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/fabriely/integracao-pipeline.git
cd integracao-pipeline
```

2. **Configure o ambiente:**
```bash
make setup
```

3. **Configure o banco de dados:**
```bash
cp .env.example .env
# Edite o arquivo .env com suas credenciais PostgreSQL
```

### Execução Rápida

**Opção 1: Jupyter Notebook (Recomendado)**
```bash
jupyter notebook src/notebooks/ETL.ipynb
# Execute todas as células sequencialmente
```

**Opção 2: Comandos Make**
```bash
make etl          # Pipeline completo
make extract      # Apenas extração
make help         # Ver todos os comandos
```

## Estrutura do Projeto

```
integracao-pipeline/
├── data/                     # Dados do pipeline
│   ├── raw/                    # Dados brutos extraídos das APIs
│   ├── processed/              # Dados limpos e transformados
│   └── final/                  # Dados finais e backups
├── database/                # Scripts SQL e schemas
│   ├── staging.sql            # Schema do banco staging
│   └── dw.sql                 # Schema do data warehouse
├── src/
│   ├── notebooks/          # Jupyter Notebooks
│   │   └── ETL.ipynb          # Pipeline ETL interativo completo
│   ├── extract/            # Módulos de extração
│   ├── transform/          # Módulos de transformação  
│   ├── load/               # Módulos de carregamento
│   └── utils/              # Utilitários e configurações
├── logs/                    # Logs de execução
├── scripts/                # Scripts de automação
├── .env.example               # Template de variáveis de ambiente
├── Makefile                   # Comandos de automação
└── requirements.txt           # Dependências Python
```

## Estrutura do Data Warehouse

O pipeline cria automaticamente um **esquema dimensional (estrela)** no PostgreSQL:

### Dimensões
- **`dw.dim_tempo`** - Dimensão temporal (datas de processamento)
- **`dw.dim_ano`** - Dimensão dos anos letivos (2022-2024)
- **`dw.dim_caracteristicas`** - Características categóricas dos dados

### Tabela Fato
- **`dw.fato_situacao_alunos`** - Fatos da situação final dos alunos

## Configuração

### Variáveis de Ambiente (.env)

```bash
# Configurações do PostgreSQL
DB_HOST=localhost
DB_PORT=5432  
DB_NAME=escolas_dw
DB_USER=postgres
DB_PASSWORD=sua_senha_aqui

# Configurações opcionais
DB_SCHEMA=dw
DB_POOL_SIZE=5
```

### PostgreSQL Setup

1. **Instale o PostgreSQL** (se não instalado):
```bash
# macOS
brew install postgresql

# Ubuntu/Debian  
sudo apt install postgresql postgresql-contrib

# Windows
# Baixe do site oficial: https://www.postgresql.org/download/
```

2. **Inicie o serviço:**
```bash
# macOS
brew services start postgresql

# Linux
sudo systemctl start postgresql
```

3. **Crie usuário e banco** (opcional - o pipeline cria automaticamente):
```sql
CREATE USER etl_user WITH PASSWORD 'senha_segura';
CREATE DATABASE escolas_dw OWNER etl_user;
```

## Dados Processados

O pipeline extrai e processa dados do **Portal de Dados Abertos do Recife**:

### Dataset: Situação Final dos Alunos
- **Fonte**: Portal de Dados Abertos - Prefeitura do Recife
- **Período**: 2022, 2023, 2024
- **Conteúdo**: 
  - Situação final dos alunos (aprovado/reprovado/transferido)
  - Informações das escolas municipais
  - Dados demográficos dos estudantes
  - Métricas educacionais consolidadas

### Processo ETL

1. **Extract (E)**: 
   - Requisições HTTP para APIs públicas
   - Download automático dos CSVs por ano
   - Validação de integridade dos dados

2. **Transform (T)**:
   - Limpeza e padronização dos dados
   - Remoção de duplicatas e valores inválidos  
   - Criação de colunas derivadas
   - Validação de qualidade

3. **Load (L)**:
   - Criação automática do schema dimensional
   - Carregamento otimizado com índices
   - Validação da integridade referencial
   - Backup automático em caso de falha

### Logs e Monitoramento

Os logs são salvos automaticamente em:
- `logs/etl_YYYYMMDD.log` - Logs diários do pipeline  
- `data/final/ultima_carga.txt` - Timestamp da última execução
- Console output com status detalhado