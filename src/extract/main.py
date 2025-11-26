"""
Script principal de extração de dados
Extrai dados do Portal de Dados Abertos do Recife
"""

import os
import sys
from pathlib import Path
from datetime import datetime
from loguru import logger
from dotenv import load_dotenv

# Adiciona o diretório raiz ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

from src.utils.config import Config
from src.extract.api_extractor import APIExtractor
from src.extract.file_handler import FileHandler


def setup_logging():
    """Configura o sistema de logging"""
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)
    
    logger.add(
        "logs/extract_{time}.log",
        rotation="1 day",
        retention="30 days",
        level="INFO"
    )


def main():
    """Função principal de extração"""
    try:
        # Configura logging
        setup_logging()
        logger.info("Iniciando processo de extração...")
        
        # Carrega configurações
        load_dotenv()
        config = Config()
        
        # Inicializa extrator
        extractor = APIExtractor(config)
        file_handler = FileHandler(config)
        
        # Extrai dados
        logger.info("Conectando ao Portal de Dados Abertos do Recife...")
        raw_data = extractor.extract_student_data()
        
        if raw_data is None or len(raw_data) == 0:
            logger.error("Nenhum dado foi extraído!")
            return False
        
        logger.info(f"Dados extraídos com sucesso: {len(raw_data)} registros")
        
        # Salva dados brutos
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = f"alunos_raw_{timestamp}.csv"
        
        file_handler.save_raw_data(raw_data, output_file)
        logger.info(f"Dados salvos em: {config.raw_data_path}/{output_file}")
        
        logger.info("Extração concluída com sucesso!")
        return True
        
    except Exception as e:
        logger.error(f"Erro durante a extração: {str(e)}")
        raise


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
