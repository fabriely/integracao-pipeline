.PHONY: help install test clean etl lint format setup docs

# Variables
PYTHON := python3
PIP := pip3
PYTEST := pytest
BLACK := black
FLAKE8 := flake8
ISORT := isort

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)Pipeline ETL - Escolas Recife$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Instala todas as dependências
	@echo "$(GREEN)Instalando dependências...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)✓ Dependências instaladas com sucesso!$(NC)"

etl: ## Executa o pipeline ETL completo
	@echo "$(GREEN)Executando pipeline ETL...$(NC)"
	./scripts/run_etl.sh

setup: install ## Configura o ambiente completo
	@echo "$(GREEN)Configurando ambiente...$(NC)"
	chmod +x scripts/*.sh
	./scripts/setup_env.sh
	@echo "$(GREEN)✓ Ambiente configurado com sucesso!$(NC)"

extract: ## Executa apenas a etapa de extração
	@echo "$(GREEN)Executando extração...$(NC)"
	$(PYTHON) src/extract/main.py

transform: ## Executa apenas a etapa de transformação
	@echo "$(GREEN)Executando transformação...$(NC)"
	$(PYTHON) src/transform/main.py

load: ## Executa apenas a etapa de carga
	@echo "$(GREEN)Executando carga...$(NC)"
	$(PYTHON) src/load/main.py

.DEFAULT_GOAL := help
