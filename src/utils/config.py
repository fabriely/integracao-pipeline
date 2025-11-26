"""
Configurações do projeto
Centraliza todas as configurações e variáveis de ambiente
"""

import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()


class Config:
    """Classe de configuração centralizada"""
    
    # Paths do projeto
    BASE_DIR = Path(__file__).parent.parent.parent
    DATA_DIR = BASE_DIR / "data"
    
    # Database Configuration
    db_host = os.getenv("DB_HOST", "localhost")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME", "escolas_dw")
    db_user = os.getenv("DB_USER", "postgres")
    db_password = os.getenv("DB_PASSWORD", "")
    
    
    # Staging Database Configuration
    staging_db_host = os.getenv("STAGING_DB_HOST", "localhost")
    staging_db_port = os.getenv("STAGING_DB_PORT", "5432")
    staging_db_name = os.getenv("STAGING_DB_NAME", "escolas_staging")
    staging_db_user = os.getenv("STAGING_DB_USER", "postgres")
    staging_db_password = os.getenv("STAGING_DB_PASSWORD", "")
    
    # API Configuration
    api_url = os.getenv("DADOS_ABERTOS_URL", "http://dados.recife.pe.gov.br")
    api_timeout = int(os.getenv("API_TIMEOUT", "30"))
    api_retry_attempts = int(os.getenv("API_RETRY_ATTEMPTS", "3"))
    
    # Data Paths
    raw_data_path = os.getenv("DATA_RAW_PATH", str(DATA_DIR / "raw"))
    processed_data_path = os.getenv("DATA_PROCESSED_PATH", str(DATA_DIR / "processed"))
    final_data_path = os.getenv("DATA_FINAL_PATH", str(DATA_DIR / "final"))
    
    # Logging
    log_level = os.getenv("LOG_LEVEL", "INFO")
    log_file = os.getenv("LOG_FILE", "logs/pipeline.log")
    
    # ETL Configuration
    batch_size = int(os.getenv("BATCH_SIZE", "1000"))
    max_workers = int(os.getenv("MAX_WORKERS", "4"))
    
    
    # Environment
    environment = os.getenv("ENVIRONMENT", "development")
    debug = os.getenv("DEBUG", "True").lower() == "true"
    
    @classmethod
    def get_database_url(cls) -> str:
        """Retorna URL completa de conexão do banco (retrocompatibilidade)"""
        return (
            f"postgresql://{cls.db_user}:{cls.db_password}"
            f"@{cls.db_host}:{cls.db_port}/{cls.db_name}"
        )

    @classmethod
    def get_staging_database_url(cls) -> str:
        """Retorna URL completa de conexão do staging"""
        return (
            f"postgresql://{cls.staging_db_user}:{cls.staging_db_password}"
            f"@{cls.staging_db_host}:{cls.staging_db_port}/{cls.staging_db_name}"
            f"@{cls.db_host}:{cls.db_port}/{cls.staging_db_name}"
        )
    
    @classmethod
    def validate(cls) -> bool:
        """Valida configurações obrigatórias"""
        required_vars = [
            cls.db_host,
            cls.db_name,
            cls.db_user
        ]
        return all(required_vars)
