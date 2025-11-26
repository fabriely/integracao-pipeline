"""
Script principal de transformação de dados
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
from src.transform.data_cleaner import DataCleaner
from src.transform.data_validator import DataValidator
from src.transform.data_enricher import DataEnricher


def setup_logging():
    """Configura o sistema de logging"""
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)
    
    logger.add(
        "logs/transform_{time}.log",
        rotation="1 day",
        retention="30 days",
        level="INFO"
    )


def main():
    """Função principal de transformação"""
    try:
        setup_logging()
        logger.info("Iniciando processo de transformação...")
        
        load_dotenv()
        config = Config()
        
        # Encontra o arquivo raw mais recente
        raw_path = Path(config.raw_data_path)
        raw_files = sorted(raw_path.glob("alunos_raw_*.csv"), reverse=True)
        
        if not raw_files:
            logger.error("Nenhum arquivo raw encontrado!")
            return False
        
        input_file = raw_files[0]
        logger.info(f"Processando arquivo: {input_file}")
        
        # Carrega dados
        df = pd.read_csv(input_file)
        logger.info(f"Dados carregados: {len(df)} registros")
        
        # Limpeza
        cleaner = DataCleaner(config)
        df_clean = cleaner.clean(df)
        logger.info(f"Limpeza concluída: {len(df_clean)} registros válidos")
        
        # Validação
        validator = DataValidator(config)
        is_valid, errors = validator.validate(df_clean)
        
        if not is_valid:
            logger.warning(f"Validação encontrou {len(errors)} problemas")
            for error in errors[:10]:  # Mostra primeiros 10 erros
                logger.warning(f"  - {error}")
        
        # Enriquecimento
        enricher = DataEnricher(config)
        df_enriched = enricher.enrich(df_clean)
        logger.info(f"Enriquecimento concluído: {df_enriched.shape[1]} colunas")
        
        # Salva dados processados
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = Path(config.processed_data_path) / f"alunos_processed_{timestamp}.csv"
        output_file.parent.mkdir(parents=True, exist_ok=True)
        
        df_enriched.to_csv(output_file, index=False)
        logger.info(f"Dados processados salvos em: {output_file}")
        
        # Salva também em parquet para melhor performance
        parquet_file = output_file.with_suffix('.parquet')
        df_enriched.to_parquet(parquet_file, index=False, compression='snappy')
        logger.info(f"Dados salvos em Parquet: {parquet_file}")
        
        logger.info("Transformação concluída com sucesso!")
        return True
        
    except Exception as e:
        logger.error(f"Erro durante a transformação: {str(e)}")
        raise


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
