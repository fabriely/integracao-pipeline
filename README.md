# Pipeline ETL - Dados Educacionais do Recife

Pipeline de ETL (Extract, Transform, Load) para extração e processamento de dados do Portal de Dados Abertos do Recife, focado em dados educacionais.

## Início Rápido

### Pré-requisitos

- Python 3.8+
- PostgreSQL 12+
- Git

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/fabriely/integracao-pipeline.git
cd integracao-pipeline
```

2. Configure o ambiente:
```bash
make setup
```

Este comando irá:
- Criar um ambiente virtual Python
- Instalar todas as dependências
- Configurar os diretórios necessários

### Execução

Para executar apenas a extração de dados:
```bash
make extract
```

Para ver todos os comandos disponíveis:
```bash
make help
```

## Estrutura do Projeto

```
├── data/                    # Dados do pipeline
│   ├── raw/                # Dados brutos extraídos
│   ├── processed/          # Dados processados
│   └── final/             # Dados finais para carregamento
├── database/               # Scripts SQL e schemas
│   ├── staging.sql        # Schema do banco staging
│   └── dw.sql            # Schema do data warehouse
├── logs/                   # Logs de execução
├── scripts/               # Scripts de configuração
├── src/
│   ├── extract/          # Módulo de extração
│   └── utils/            # Utilitários e configurações
└── requirements.txt      # Dependências Python
```

## Configuração

As configurações do projeto estão em `src/utils/config.py`. Certifique-se de configurar as variáveis de ambiente necessárias antes da execução.

## Dados

O pipeline extrai dados educacionais do Portal de Dados Abertos do Recife, incluindo informações sobre:
- Escolas públicas
- Matrículas
- Infraestrutura educacional