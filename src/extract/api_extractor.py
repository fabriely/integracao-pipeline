"""
Extrator de dados da API do Portal de Dados Abertos
"""

import requests
import pandas as pd
from typing import Optional, Dict, List
from loguru import logger
import time


class APIExtractor:
    """Classe para extração de dados do Portal de Dados Abertos do Recife"""
    
    # URLs diretas dos arquivos CSV por ano
    URLS_CSV = {
        "2024": "http://dados.recife.pe.gov.br/dataset/ce5168d4-d925-48f5-a193-03d4e0f587c7/resource/96f8a467-12b1-4340-b19c-281907fabaae/download/situacaofinal2024.csv",
        "2023": "http://dados.recife.pe.gov.br/dataset/ce5168d4-d925-48f5-a193-03d4e0f587c7/resource/854da2d7-c34b-457f-97b9-ba217d489621/download/situacaofinal2023.csv",
        "2022": "http://dados.recife.pe.gov.br/dataset/ce5168d4-d925-48f5-a193-03d4e0f587c7/resource/9e22fc25-716f-4454-8d95-998894b6ce01/download/situacaofinal2022.csv",
    }
    
    def __init__(self, config):
        """
        Inicializa o extrator
        
        Args:
            config: Objeto de configuração com parâmetros da API
        """
        self.config = config
        self.timeout = config.api_timeout
        self.retry_attempts = config.api_retry_attempts
        
    def _make_request(self, url: str, params: Optional[Dict] = None) -> Optional[requests.Response]:
        """
        Faz requisição HTTP com retry
        
        Args:
            url: URL da API
            params: Parâmetros da requisição
            
        Returns:
            Response object ou None em caso de erro
        """
        for attempt in range(self.retry_attempts):
            try:
                logger.info(f"Tentativa {attempt + 1} de {self.retry_attempts}")
                response = requests.get(
                    url,
                    params=params,
                    timeout=self.timeout
                )
                response.raise_for_status()
                return response
                
            except requests.exceptions.RequestException as e:
                logger.warning(f"Erro na tentativa {attempt + 1}: {str(e)}")
                if attempt < self.retry_attempts - 1:
                    wait_time = 2 ** attempt  # Backoff exponencial
                    logger.info(f"Aguardando {wait_time} segundos antes de tentar novamente...")
                    time.sleep(wait_time)
                else:
                    logger.error("Todas as tentativas falharam")
                    return None
    
    def extract_year_data(self, year: str) -> Optional[pd.DataFrame]:
        """
        Extrai dados de situação final dos alunos para um ano específico
        
        Args:
            year: Ano dos dados (2022, 2023 ou 2024)
            
        Returns:
            DataFrame com os dados ou None em caso de erro
        """
        try:
            if year not in self.URLS_CSV:
                logger.error(f"Ano {year} não disponível. Anos válidos: {list(self.URLS_CSV.keys())}")
                return None
            
            url = self.URLS_CSV[year]
            logger.info(f"Extraindo dados de situação final dos alunos - Ano {year}...")
            logger.info(f"URL: {url}")
            
            response = self._make_request(url)
            
            if response is None:
                return None
            
            # Lê CSV direto da resposta
            df = pd.read_csv(
                pd.io.common.BytesIO(response.content),
                encoding='utf-8',
                sep=';',  # Arquivos do Portal geralmente usam ponto-e-vírgula
                decimal=','
            )
            
            # Adiciona coluna com o ano de referência
            df['ano_referencia'] = int(year)
            
            logger.info(f"Extraídos {len(df)} registros do ano {year}")
            logger.info(f"Colunas: {list(df.columns)}")
            
            return df
            
        except Exception as e:
            logger.error(f"Erro ao extrair dados do ano {year}: {str(e)}")
            return None
    
    def extract_student_data(self) -> Optional[pd.DataFrame]:
        """
        Extrai dados de situação final dos alunos de todos os anos disponíveis
        
        Returns:
            DataFrame consolidado com os dados de todos os anos ou None em caso de erro
        """
        try:
            logger.info("Extraindo dados de situação final dos alunos - Todos os anos...")
            
            dataframes = []
            
            for year in sorted(self.URLS_CSV.keys()):
                df_year = self.extract_year_data(year)
                if df_year is not None:
                    dataframes.append(df_year)
                else:
                    logger.warning(f"Não foi possível extrair dados do ano {year}")
            
            if not dataframes:
                logger.error("Nenhum dado foi extraído")
                return None
            
            # Consolida todos os anos em um único DataFrame
            df_consolidated = pd.concat(dataframes, ignore_index=True)
            
            logger.info(f"Total de {len(df_consolidated)} registros extraídos de {len(dataframes)} anos")
            logger.info(f"Anos extraídos: {sorted([year for year in self.URLS_CSV.keys() if any(df['ano_referencia'].iloc[0] == int(year) for df in dataframes if len(df) > 0)])}")
            
            return df_consolidated
            
        except Exception as e:
            logger.error(f"Erro ao consolidar dados: {str(e)}")
            return None
    
    def get_metadata(self) -> Optional[Dict]:
        """
        Obtém metadados do dataset
        
        Returns:
            Dicionário com metadados ou None
        """
        try:
            endpoint = f"{self.base_url}/dataset/situacao-final-alunos/metadata"
            response = self._make_request(endpoint)
            
            if response:
                return response.json()
            return None
            
        except Exception as e:
            logger.error(f"Erro ao obter metadados: {str(e)}")
            return None
