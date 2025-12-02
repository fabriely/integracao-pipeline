# Pipeline ETL/ELT - Situação Final dos Alunos do Recife

## Início Rápido

### Pré-requisitos

- **Python 3.8+**
- **PostgreSQL 12+** 

### Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/fabriely/integracao-pipeline.git
cd integracao-pipeline
```

2. ****

### Execução Rápida (ELT)

**Opção 1: Jupyter Notebook (Recomendado)**
```bash
jupyter notebook src/notebooks/ETL.ipynb
# Execute todas as células sequencialmente
```

### Execução ELT

Você precisa configurar sua conexão com o servidor PostgreSQL usando o arquivo `profiles.yml`.

1. Localize o arquivo `profiles.yml`:
   - **Linux/macOS:** `~/.dbt/profiles.yml`
   - **Windows:** `%USERPROFILE%\.dbt\profiles.yml`

2. Adicione essas configurações do profiles.yml caso não queira usar seu próprio banco:

```yaml
profile: transformacao_matricula

transformacao_matricula:
  target: transformacao_matricula_db
  outputs:
    transformacao_matricula_db:
      type: postgres
      host: aws-1-us-east-1.pooler.supabase.com
      user: postgres.jkgdzhpqywydnucbdfvp
      password: postgres
      port: 6543
      schema: staging  
      dbname: transformacao_matricula
      threads: 1
```

3. teste a sua conexão:

```bash
dbt debug
```

4. Se não criou o projeto dbt ainda, rode:

```bash
dbt init nome_do_projeto
```
### Executar o script ELT

1. Execute o script `ELT.ipynb`.
2. Você pode checar as tabelas do schema staging para verificar os dados enviados ao banco.

### ELT Pipeline
3. Rode o comando para os testes do schema.yml:
   ```bash
   dbt test
   ```
4. Rode o comando para gerar a estrutura final do esquema estrela:
   ```bash
   dbt run
   ```
Isso criará a estrutura base do dbt, cheque as tabelas novas.


## Estrutura do Data Warehouse

O pipeline cria automaticamente um **esquema dimensional (estrela)** no PostgreSQL:

### Dimensões
- **`dw.dim_tempo`** - Dimensão temporal
- **`dw.dim_aluno`** - Dimensão de Alunos com suas Informações
- **`dw.dim_escola`** - Dimensão de Escola com suuas informações
- **`dw.dim_localizacao`** - Dimensão de Localização com Informações geográficas
- **`dw.dim_turma`** - Dimensão de turma contendo as informações por turma

### Tabela Fato
- **`dw.fato_matricula`** - Fatos da matricula dos alunos

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
