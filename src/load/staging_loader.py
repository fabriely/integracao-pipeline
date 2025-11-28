"""
Carregamento de dados na Staging Area
"""

import pandas as pd
from sqlalchemy import create_engine
from loguru import logger


class StagingLoader:
    """Classe para carga de dados na staging area"""
    
    def __init__(self, config):
        """
        Inicializa o loader
        
        Args:
            config: Objeto de configuração
        """
        self.config = config
        self.engine = self._create_engine()
        
    def _create_engine(self):
        """Cria engine SQLAlchemy para staging"""
        connection_string = (
            f"postgresql://{self.config.staging_db_user}:{self.config.staging_db_password}"
            f"@{self.config.staging_db_host}:{self.config.staging_db_port}/{self.config.staging_db_name}"
        )
        return create_engine(connection_string)
    
    def load(self, df: pd.DataFrame, table_name: str = 'staging_alunos') -> bool:
        """
        Carrega dados na staging area
        
        Args:
            df: DataFrame com dados
            table_name: Nome da tabela staging
            
        Returns:
            True se sucesso
        """
        try:
            logger.info(f"Carregando {len(df)} registros na staging area...")
            
            # Trunca tabela antes de carregar (opcional)
            # self._truncate_table(table_name)
            
            # Carrega dados
            df.to_sql(
                table_name,
                self.engine,
                if_exists='replace',  # ou 'append' dependendo da estratégia
                index=False,
                method='multi',
                chunksize=self.config.batch_size
            )
            
            logger.info(f"Dados carregados na staging: {table_name}")
            return True
            
        except Exception as e:
            logger.error(f"Erro ao carregar staging: {str(e)}")
            raise
    
    def _truncate_table(self, table_name: str):
        """Trunca tabela staging"""
        try:
            with self.engine.connect() as conn:
                conn.execute(f"TRUNCATE TABLE {table_name};")
                conn.commit()
            logger.info(f"Tabela {table_name} truncada")
        except Exception as e:
            logger.warning(f"Não foi possível truncar tabela: {str(e)}")
    
    def load_incremental(self, df: pd.DataFrame, table_name: str = 'staging_alunos') -> bool:
        """
        Carga incremental (append)
        
        Args:
            df: DataFrame com novos dados
            table_name: Nome da tabela
            
        Returns:
            True se sucesso
        """
        try:
            logger.info(f"Carregando incremental: {len(df)} registros...")
            
            df.to_sql(
                table_name,
                self.engine,
                if_exists='append',
                index=False,
                method='multi',
                chunksize=self.config.batch_size
            )
            
            logger.info("Carga incremental concluída")
            return True
            
        except Exception as e:
            logger.error(f"Erro na carga incremental: {str(e)}")
            raise
