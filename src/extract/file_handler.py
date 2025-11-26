"""
Manipulador de arquivos para extração
"""

import pandas as pd
from pathlib import Path
from typing import Optional
from loguru import logger


class FileHandler:
    """Classe para manipulação de arquivos de dados"""
    
    def __init__(self, config):
        """
        Inicializa o handler
        
        Args:
            config: Objeto de configuração
        """
        self.config = config
        self.raw_path = Path(config.raw_data_path)
        self.raw_path.mkdir(parents=True, exist_ok=True)
    
    def save_raw_data(self, data: pd.DataFrame, filename: str) -> bool:
        """
        Salva dados brutos em CSV
        
        Args:
            data: DataFrame com os dados
            filename: Nome do arquivo
            
        Returns:
            True se sucesso, False caso contrário
        """
        try:
            filepath = self.raw_path / filename
            data.to_csv(filepath, index=False, encoding='utf-8')
            logger.info(f"Dados salvos em: {filepath}")
            return True
            
        except Exception as e:
            logger.error(f"Erro ao salvar dados: {str(e)}")
            return False
    
    def save_raw_parquet(self, data: pd.DataFrame, filename: str) -> bool:
        """
        Salva dados brutos em formato Parquet
        
        Args:
            data: DataFrame com os dados
            filename: Nome do arquivo
            
        Returns:
            True se sucesso, False caso contrário
        """
        try:
            filepath = self.raw_path / filename.replace('.csv', '.parquet')
            data.to_parquet(filepath, index=False, compression='snappy')
            logger.info(f"Dados salvos em formato Parquet: {filepath}")
            return True
            
        except Exception as e:
            logger.error(f"Erro ao salvar Parquet: {str(e)}")
            return False
    
    def load_raw_data(self, filename: str) -> Optional[pd.DataFrame]:
        """
        Carrega dados brutos
        
        Args:
            filename: Nome do arquivo
            
        Returns:
            DataFrame ou None em caso de erro
        """
        try:
            filepath = self.raw_path / filename
            
            if filepath.suffix == '.parquet':
                return pd.read_parquet(filepath)
            else:
                return pd.read_csv(filepath, encoding='utf-8')
                
        except Exception as e:
            logger.error(f"Erro ao carregar dados: {str(e)}")
            return None
    
    def list_raw_files(self) -> list:
        """
        Lista arquivos na pasta raw
        
        Returns:
            Lista de nomes de arquivos
        """
        return [f.name for f in self.raw_path.glob('*') if f.is_file()]
