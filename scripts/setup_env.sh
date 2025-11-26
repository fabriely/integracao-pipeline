#!/bin/bash

# ========================================
# Script de Configuração do Ambiente
# Setup inicial do projeto
# ========================================

set -e  # Exit on error

echo "Configurando ambiente do projeto..."

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verifica Python
echo -e "${BLUE}Verificando Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 não encontrado. Instale Python 3.8+ e tente novamente.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python encontrado: $(python3 --version)${NC}"

# Verifica PostgreSQL
echo -e "${BLUE}Verificando PostgreSQL...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${RED}PostgreSQL não encontrado. Instale PostgreSQL 12+ e tente novamente.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL encontrado${NC}"

# Cria ambiente virtual
echo -e "${BLUE}Criando ambiente virtual...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✓ Ambiente virtual criado${NC}"
else
    echo -e "${GREEN}✓ Ambiente virtual já existe${NC}"
fi

# Ativa ambiente virtual
echo -e "${BLUE}Ativando ambiente virtual...${NC}"
source venv/bin/activate

# Instala dependências
echo -e "${BLUE}Instalando dependências...${NC}"
pip install --upgrade pip
pip install -r requirements.txt
echo -e "${GREEN}✓ Dependências instaladas${NC}"

# Cria estrutura de diretórios
echo -e "${BLUE}Criando estrutura de diretórios...${NC}"
mkdir -p data/raw data/processed data/final
mkdir -p logs
touch data/raw/.gitkeep
touch data/processed/.gitkeep
touch data/final/.gitkeep
echo -e "${GREEN}✓ Diretórios criados${NC}"

# Verifica arquivo .env
echo -e "${BLUE}Configurando variáveis de ambiente...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Arquivo .env criado (configure com suas credenciais)${NC}"
    echo -e "${RED}⚠️  IMPORTANTE: Edite o arquivo .env com suas configurações!${NC}"
else
    echo -e "${GREEN}✓ Arquivo .env já existe${NC}"
fi

# Configura banco de dados
echo -e "${BLUE}Configurando bancos de dados...${NC}"
read -p "Deseja criar os bancos de dados agora? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    # Carrega variáveis de ambiente
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs)
    fi
    
    # Define usuário padrão se não estiver no .env
    DB_USER=${STAGING_DB_USER:-$USER}
    DB_HOST=${STAGING_DB_HOST:-localhost}
    DB_PORT=${STAGING_DB_PORT:-5432}
    
    echo -e "${BLUE}Usando usuário: ${DB_USER}${NC}"
    
    # Cria bancos (conectando ao banco postgres padrão)
    echo -e "${BLUE}Criando banco staging...${NC}"
    psql -U ${DB_USER} -h ${DB_HOST} -p ${DB_PORT} -d postgres -c "CREATE DATABASE escolas_staging;" 2>/dev/null && echo -e "${GREEN}✓ Banco staging criado${NC}" || echo -e "${BLUE}Banco staging já existe${NC}"
    
    echo -e "${BLUE}Criando banco DW...${NC}"
    psql -U ${DB_USER} -h ${DB_HOST} -p ${DB_PORT} -d postgres -c "CREATE DATABASE escolas_dw;" 2>/dev/null && echo -e "${GREEN}✓ Banco DW criado${NC}" || echo -e "${BLUE}Banco DW já existe${NC}"
    
    # Aguarda um momento para os bancos serem criados
    sleep 1
    
    # Executa scripts SQL no banco staging (se existirem)
    if [ -f "database/staging.sql" ]; then
        echo -e "${BLUE}Criando schemas staging...${NC}"
        if psql -U ${DB_USER} -h ${DB_HOST} -p ${DB_PORT} -d escolas_staging -f database/staging.sql 2>/dev/null; then
            echo -e "${GREEN}✓ Schemas staging criados${NC}"
        else
            echo -e "${RED}⚠️  Erro ao criar schemas staging${NC}"
        fi
    else
        echo -e "${BLUE}Arquivo database/staging.sql não encontrado - pulando criação de schemas${NC}"
    fi
    
    # Executa scripts SQL no banco DW (se existirem)
    if [ -f "database/dw.sql" ]; then
        echo -e "${BLUE}Criando schemas DW...${NC}"
        if psql -U ${DB_USER} -h ${DB_HOST} -p ${DB_PORT} -d escolas_dw -f database/dw.sql 2>/dev/null; then
            echo -e "${GREEN}✓ Schemas DW criados${NC}"
        else
            echo -e "${RED}⚠️  Erro ao criar schemas DW${NC}"
        fi
    else
        echo -e "${BLUE}Arquivo database/dw.sql não encontrado - pulando criação de schemas${NC}"
    fi
    
    # Insere dados de exemplo (se existir)
    if [ -f "database/seeds/sample_data.sql" ]; then
        echo -e "${BLUE}Inserindo dados de exemplo...${NC}"
        if psql -U ${DB_USER} -h ${DB_HOST} -p ${DB_PORT} -d escolas_dw -f database/seeds/sample_data.sql 2>/dev/null; then
            echo -e "${GREEN}✓ Dados de exemplo inseridos${NC}"
        else
            echo -e "${BLUE}Pulando dados de exemplo${NC}"
        fi
    fi
    
    echo -e "${GREEN}✓ Bancos de dados configurados${NC}"
fi

# Torna scripts executáveis
echo -e "${BLUE}Configurando permissões de scripts...${NC}"
chmod +x scripts/*.sh
echo -e "${GREEN}✓ Scripts configurados${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Configuração concluída com sucesso!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo "1. Edite o arquivo .env com suas configurações (se necessário)"
echo "2. Execute: source venv/bin/activate"
echo "3. Execute o pipeline: make etl"
echo ""
echo -e "${BLUE}Comandos úteis:${NC}"
echo "  make help     - Ver todos os comandos disponíveis"
echo "  make test     - Executar testes"
echo "  make notebook - Abrir Jupyter Notebook"
echo ""