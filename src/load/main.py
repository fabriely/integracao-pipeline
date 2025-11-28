"""
Script principal de carga de dados
"""

import os
import sys
from pathlib import Path
from datetime import datetime
from loguru import logger
from dotenv import load_dotenv
import pandas as pd

sys.path.append(str(Path(__file__).parent.parent.parent))

from src.utils.config import Config
from src.load.database_loader import DatabaseLoader
from src.load.staging_loader import StagingLoader


def setup_logging():
    """Configura o sistema de logging"""
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)
    
    logger.add(
        "logs/load_{time}.log",
        rotation="1 day",
        retention="30 days",
        level="INFO"
    )


def main():
    """Função principal de carga"""
    try:
        setup_logging()
        logger.info("Iniciando processo de carga...")
        
        load_dotenv()
        config = Config()
        
        # Encontra arquivo processado mais recente
        processed_path = Path(config.processed_data_path)
        processed_files = sorted(processed_path.glob("alunos_processed_*.parquet"), reverse=True)
        
        if not processed_files:
            # Tenta CSV se parquet não encontrado
            processed_files = sorted(processed_path.glob("alunos_processed_*.csv"), reverse=True)
        
        if not processed_files:
            logger.error("Nenhum arquivo processado encontrado!")
            return False
        
        input_file = processed_files[0]
        logger.info(f"Carregando arquivo: {input_file}")
        
        # Carrega dados
        if input_file.suffix == '.parquet':
            df = pd.read_parquet(input_file)
        else:
            df = pd.read_csv(input_file)
        
        logger.info(f"Dados carregados: {len(df)} registros")
        
        # Carrega em staging primeiro
        staging_loader = StagingLoader(config)
        staging_loader.load(df)
        logger.info("Dados carregados na staging area")
        
        # Carrega no Data Warehouse
        db_loader = DatabaseLoader(config)
        db_loader.load_to_warehouse(df)
        logger.info("Dados carregados no Data Warehouse")
        
        # Salva cópia final
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        final_file = Path(config.final_data_path) / f"alunos_final_{timestamp}.parquet"
        final_file.parent.mkdir(parents=True, exist_ok=True)
        df.to_parquet(final_file, index=False, compression='snappy')
        logger.info(f"Cópia final salva em: {final_file}")
        
        logger.info("Carga concluída com sucesso!")
        return True
        
    except Exception as e:
        logger.error(f"Erro durante a carga: {str(e)}")
        raise


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
