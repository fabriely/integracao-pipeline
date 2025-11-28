"""
Carregamento de dados no Data Warehouse
"""

import pandas as pd
from sqlalchemy import create_engine, text
from loguru import logger
from typing import Optional


class DatabaseLoader:
    """Classe para carga de dados no Data Warehouse"""
    
    def __init__(self, config):
        """
        Inicializa o loader
        
        Args:
            config: Objeto de configuração
        """
        self.config = config
        self.engine = self._create_engine()
        
    def _create_engine(self):
        """Cria engine SQLAlchemy"""
        connection_string = (
            f"postgresql://{self.config.dw_db_user}:{self.config.dw_db_password}"
            f"@{self.config.dw_db_host}:{self.config.dw_db_port}/{self.config.dw_db_name}"
        )
        return create_engine(connection_string)
    
    def load_to_warehouse(self, df: pd.DataFrame) -> bool:
        """
        Carrega dados no Data Warehouse dimensional
        
        Args:
            df: DataFrame com dados processados
            
        Returns:
            True se sucesso
        """
        try:
            logger.info("Carregando dados no Data Warehouse...")
            
            # Carrega dimensões primeiro
            self._load_dim_aluno(df)
            self._load_dim_escola(df)
            self._load_dim_tempo(df)
            
            # Depois carrega fato
            self._load_fato_situacao(df)
            
            logger.info("Dados carregados com sucesso no DW")
            return True
            
        except Exception as e:
            logger.error(f"Erro ao carregar no DW: {str(e)}")
            raise
    
    def _load_dim_aluno(self, df: pd.DataFrame):
        """Carrega dimensão de alunos"""
        logger.info("Carregando dimensão de alunos...")
        
        # Seleciona colunas da dimensão (usando nomes reais das colunas)
        dim_aluno = df[[
            'matricula',
            'sexo',
            'idade'
        ]].drop_duplicates()
        
        # Renomeia colunas para padronizar
        dim_aluno = dim_aluno.rename(columns={
            'sexo': 'genero'
        })
        
        # Carrega no banco (upsert)
        dim_aluno.to_sql(
            'dim_aluno',
            self.engine,
            if_exists='append',
            index=False,
            method='multi',
            chunksize=self.config.batch_size
        )
        
        logger.info(f"Dimensão aluno: {len(dim_aluno)} registros")
    
    def _load_dim_escola(self, df: pd.DataFrame):
        """Carrega dimensão de escolas"""
        logger.info("Carregando dimensão de escolas...")
        
        dim_escola = df[[
            'codigo_escola',
            'escola',
            'endereco_bairro',
            'rpa'
        ]].drop_duplicates()
        
        # Renomeia colunas para padronizar
        dim_escola = dim_escola.rename(columns={
            'escola': 'nome_escola',
            'endereco_bairro': 'bairro'
        })
        
        dim_escola.to_sql(
            'dim_escola',
            self.engine,
            if_exists='append',
            index=False,
            method='multi',
            chunksize=self.config.batch_size
        )
        
        logger.info(f"Dimensão escola: {len(dim_escola)} registros")
    
    def _load_dim_tempo(self, df: pd.DataFrame):
        """Carrega dimensão temporal"""
        logger.info("Carregando dimensão temporal...")
        
        dim_tempo = df[[
            'ano',
            'ano_referencia'
        ]].drop_duplicates()
        
        # Renomeia colunas para padronizar
        dim_tempo = dim_tempo.rename(columns={
            'ano': 'ano_letivo'
        })
        
        dim_tempo.to_sql(
            'dim_tempo',
            self.engine,
            if_exists='append',
            index=False,
            method='multi',
            chunksize=self.config.batch_size
        )
        
        logger.info(f"Dimensão tempo: {len(dim_tempo)} registros")
    
    def _load_fato_situacao(self, df: pd.DataFrame):
        """Carrega tabela fato de situação dos alunos"""
        logger.info("Carregando tabela fato...")
        
        # Seleciona métricas e chaves estrangeiras (usando colunas reais)
        fato = df[[
            'matricula',
            'codigo_escola',
            'ano',
            'situacao_codigo',
            'situacao_nome',
            'turma',
            'turno',
            'serie',
            'modalidade_ensino'
        ]]
        
        # Renomeia colunas para padronizar
        fato = fato.rename(columns={
            'ano': 'ano_letivo',
            'situacao_nome': 'situacao_final'
        })
        
        fato.to_sql(
            'fato_situacao_aluno',
            self.engine,
            if_exists='append',
            index=False,
            method='multi',
            chunksize=self.config.batch_size
        )
        
        logger.info(f"Tabela fato: {len(fato)} registros")
    
    def execute_query(self, query: str) -> Optional[pd.DataFrame]:
        """
        Executa query SQL
        
        Args:
            query: Query SQL
            
        Returns:
            DataFrame com resultados ou None
        """
        try:
            with self.engine.connect() as conn:
                result = pd.read_sql(query, conn)
            return result
        except Exception as e:
            logger.error(f"Erro ao executar query: {str(e)}")
            return None
