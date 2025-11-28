#!/bin/bash

# ========================================
# Script de Execução do Pipeline ETL
# ========================================

set -e  # Exit on error

echo "Executando Pipeline ETL..."

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "${BLUE}Iniciado em: ${TIMESTAMP}${NC}"

# Ativa ambiente virtual
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo -e "${RED}Ambiente virtual não encontrado. Execute: ./scripts/setup_env.sh${NC}"
    exit 1
fi

# Verifica .env
if [ ! -f ".env" ]; then
    echo -e "${RED}Arquivo .env não encontrado!${NC}"
    exit 1
fi

# Função para log
log_step() {
    echo -e "${BLUE}[$(date +"%H:%M:%S")] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[$(date +"%H:%M:%S")] ✓ $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +"%H:%M:%S")] ✗ $1${NC}"
}

# ========================================
# ETAPA 1: EXTRACT
# ========================================
log_step "Etapa 1/3: Extração de Dados"
if python src/extract/main.py; then
    log_success "Extração concluída"
else
    log_error "Erro na extração"
    exit 1
fi

# ========================================
# ETAPA 2: TRANSFORM
# ========================================
log_step "Etapa 2/3: Transformação de Dados"
if python src/transform/main.py; then
    log_success "Transformação concluída"
else
    log_error "Erro na transformação"
    exit 1
fi

# ========================================
# ETAPA 3: LOAD
# ========================================
log_step "Etapa 3/3: Carga de Dados"
if python src/load/main.py; then
    log_success "Carga concluída"
else
    log_error "Erro na carga"
    exit 1
fi

# ========================================
# FINALIZAÇÃO
# ========================================
TIMESTAMP_END=$(date +"%Y-%m-%d %H:%M:%S")
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Pipeline ETL Concluído!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}Início:  ${TIMESTAMP}${NC}"
echo -e "${BLUE}Término: ${TIMESTAMP_END}${NC}"
echo ""

# Estatísticas (opcional)
echo -e "${YELLOW}Estatísticas:${NC}"
echo "- Logs disponíveis em: logs/"
echo "- Dados finais em: data/final/"
echo ""

