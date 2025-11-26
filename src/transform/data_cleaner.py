"""
Limpeza e pré-processamento de dados
"""

import pandas as pd
import numpy as np
from typing import Optional
from loguru import logger


class DataCleaner:
    """Classe para limpeza de dados"""
    
    def __init__(self, config):
        self.config = config
        
    def clean(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Aplica limpezas nos dados
        
        Args:
            df: DataFrame com dados brutos
            
        Returns:
            DataFrame limpo
        """
        logger.info("Iniciando limpeza de dados...")
        
        df_clean = df.copy()
        
        # Remove duplicatas
        df_clean = self._remove_duplicates(df_clean)
        
        # Remove linhas com muitos valores nulos
        df_clean = self._remove_invalid_rows(df_clean)
        
        # Padroniza tipos de dados
        df_clean = self._standardize_types(df_clean)
        
        # Limpa strings
        df_clean = self._clean_strings(df_clean)
        
        # Trata valores faltantes
        df_clean = self._handle_missing_values(df_clean)
        
        logger.info(f"Limpeza concluída: {len(df_clean)} registros mantidos de {len(df)}")
        
        return df_clean
    
    def _remove_duplicates(self, df: pd.DataFrame) -> pd.DataFrame:
        """Remove registros duplicados"""
        initial_count = len(df)
        df_dedup = df.drop_duplicates()
        duplicates_removed = initial_count - len(df_dedup)
        
        if duplicates_removed > 0:
            logger.info(f"Removidas {duplicates_removed} linhas duplicadas")
        
        return df_dedup
    
    def _remove_invalid_rows(self, df: pd.DataFrame, threshold: float = 0.5) -> pd.DataFrame:
        """
        Remove linhas com muitos valores nulos
        
        Args:
            df: DataFrame
            threshold: Proporção máxima de valores nulos permitida
        """
        initial_count = len(df)
        null_ratio = df.isnull().sum(axis=1) / len(df.columns)
        df_filtered = df[null_ratio <= threshold]
        removed = initial_count - len(df_filtered)
        
        if removed > 0:
            logger.info(f"Removidas {removed} linhas com muitos valores nulos")
        
        return df_filtered
    
    def _standardize_types(self, df: pd.DataFrame) -> pd.DataFrame:
        """Padroniza tipos de dados das colunas"""
        df_typed = df.copy()
        
        # Colunas de data comuns
        date_columns = ['data_inicio', 'data_fim', 'ano_letivo']
        for col in date_columns:
            if col in df_typed.columns:
                df_typed[col] = pd.to_datetime(df_typed[col], errors='coerce')
        
        # Colunas numéricas
        numeric_columns = ['nota_final', 'faltas', 'media']
        for col in numeric_columns:
            if col in df_typed.columns:
                df_typed[col] = pd.to_numeric(df_typed[col], errors='coerce')
        
        return df_typed
    
    def _clean_strings(self, df: pd.DataFrame) -> pd.DataFrame:
        """Limpa e padroniza campos de texto"""
        df_clean = df.copy()
        
        # Identifica colunas de texto
        text_columns = df_clean.select_dtypes(include=['object']).columns
        
        for col in text_columns:
            # Remove espaços extras
            df_clean[col] = df_clean[col].str.strip()
            
            # Padroniza para maiúsculas (ou minúsculas conforme necessário)
            # df_clean[col] = df_clean[col].str.upper()
            
            # Remove caracteres especiais se necessário
            # df_clean[col] = df_clean[col].str.replace(r'[^\w\s]', '', regex=True)
        
        return df_clean
    
    def _handle_missing_values(self, df: pd.DataFrame) -> pd.DataFrame:
        """Trata valores faltantes"""
        df_filled = df.copy()
        
        # Estratégias por tipo de coluna
        numeric_cols = df_filled.select_dtypes(include=[np.number]).columns
        categorical_cols = df_filled.select_dtypes(include=['object']).columns
        
        # Numéricos: preenche com mediana ou 0
        for col in numeric_cols:
            if df_filled[col].isnull().sum() > 0:
                df_filled[col].fillna(df_filled[col].median(), inplace=True)
        
        # Categóricos: preenche com "Não Informado"
        for col in categorical_cols:
            if df_filled[col].isnull().sum() > 0:
                df_filled[col].fillna("Não Informado", inplace=True)
        
        return df_filled
