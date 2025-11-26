"""
Enriquecimento de dados
Adiciona features derivadas e agregações
"""

import pandas as pd
from loguru import logger


class DataEnricher:
    """Classe para enriquecimento de dados"""
    
    def __init__(self, config):
        self.config = config
        
    def enrich(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Enriquece dados com features derivadas
        
        Args:
            df: DataFrame limpo
            
        Returns:
            DataFrame enriquecido
        """
        logger.info("Iniciando enriquecimento de dados...")
        
        df_enriched = df.copy()
        
        # Adiciona features derivadas
        df_enriched = self._add_status_flags(df_enriched)
        df_enriched = self._add_temporal_features(df_enriched)
        df_enriched = self._add_performance_metrics(df_enriched)
        df_enriched = self._add_categorical_encodings(df_enriched)
        
        logger.info(f"Enriquecimento concluído: {df_enriched.shape[1]} features")
        
        return df_enriched
    
    def _add_status_flags(self, df: pd.DataFrame) -> pd.DataFrame:
        """Adiciona flags de status"""
        df_flags = df.copy()
        
        # Flag de aprovação
        if 'situacao_final' in df_flags.columns:
            df_flags['aprovado'] = df_flags['situacao_final'].isin(
                ['APROVADO', 'APROVADO POR CONSELHO']
            ).astype(int)
        
        # Flag de frequência adequada
        if 'faltas' in df_flags.columns and 'total_aulas' in df_flags.columns:
            df_flags['frequencia_adequada'] = (
                (df_flags['faltas'] / df_flags['total_aulas']) <= 0.25
            ).astype(int)
        
        return df_flags
    
    def _add_temporal_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Adiciona features temporais"""
        df_temporal = df.copy()
        
        # Extrai componentes da data
        if 'data_inicio' in df_temporal.columns:
            df_temporal['mes_inicio'] = pd.to_datetime(
                df_temporal['data_inicio']
            ).dt.month
            df_temporal['trimestre_inicio'] = pd.to_datetime(
                df_temporal['data_inicio']
            ).dt.quarter
        
        # Calcula duração do período letivo
        if 'data_inicio' in df_temporal.columns and 'data_fim' in df_temporal.columns:
            df_temporal['dias_periodo'] = (
                pd.to_datetime(df_temporal['data_fim']) - 
                pd.to_datetime(df_temporal['data_inicio'])
            ).dt.days
        
        return df_temporal
    
    def _add_performance_metrics(self, df: pd.DataFrame) -> pd.DataFrame:
        """Adiciona métricas de desempenho"""
        df_metrics = df.copy()
        
        # Taxa de aproveitamento
        if 'nota_final' in df_metrics.columns:
            df_metrics['taxa_aproveitamento'] = (df_metrics['nota_final'] / 10.0) * 100
            
            # Categoria de desempenho
            df_metrics['categoria_desempenho'] = pd.cut(
                df_metrics['nota_final'],
                bins=[0, 5, 7, 9, 10],
                labels=['Insuficiente', 'Regular', 'Bom', 'Excelente'],
                include_lowest=True
            )
        
        # Taxa de frequência
        if 'faltas' in df_metrics.columns and 'total_aulas' in df_metrics.columns:
            df_metrics['taxa_frequencia'] = (
                (df_metrics['total_aulas'] - df_metrics['faltas']) / 
                df_metrics['total_aulas']
            ) * 100
        
        return df_metrics
    
    def _add_categorical_encodings(self, df: pd.DataFrame) -> pd.DataFrame:
        """Adiciona encodings de variáveis categóricas"""
        df_encoded = df.copy()
        
        # Mapeia situações finais para códigos numéricos
        if 'situacao_final' in df_encoded.columns:
            status_map = {
                'APROVADO': 1,
                'APROVADO POR CONSELHO': 2,
                'REPROVADO': 3,
                'REPROVADO POR FALTA': 4,
                'TRANSFERIDO': 5,
                'ABANDONO': 6
            }
            df_encoded['situacao_codigo'] = df_encoded['situacao_final'].map(status_map)
        
        return df_encoded
