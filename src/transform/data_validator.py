"""
Validação de qualidade de dados
"""

import pandas as pd
from typing import Tuple, List
from loguru import logger


class DataValidator:
    """Classe para validação de dados"""
    
    def __init__(self, config):
        self.config = config
        self.errors = []
        
    def validate(self, df: pd.DataFrame) -> Tuple[bool, List[str]]:
        """
        Valida qualidade dos dados
        
        Args:
            df: DataFrame a validar
            
        Returns:
            Tupla (is_valid, lista_de_erros)
        """
        logger.info("Iniciando validação de dados...")
        
        self.errors = []
        
        # Validações
        self._validate_schema(df)
        self._validate_required_fields(df)
        self._validate_data_ranges(df)
        self._validate_data_integrity(df)
        
        is_valid = len(self.errors) == 0
        
        if is_valid:
            logger.info("Validação concluída: dados válidos!")
        else:
            logger.warning(f"Validação encontrou {len(self.errors)} problemas")
        
        return is_valid, self.errors
    
    def _validate_schema(self, df: pd.DataFrame):
        """Valida estrutura básica do DataFrame"""
        if df.empty:
            self.errors.append("DataFrame está vazio")
            return
        
        if len(df.columns) == 0:
            self.errors.append("DataFrame não possui colunas")
    
    def _validate_required_fields(self, df: pd.DataFrame):
        """Valida presença de campos obrigatórios"""
        # Defina campos obrigatórios conforme seu dataset
        required_fields = [
            'matricula', 
            'nome_aluno', 
            'escola',
            'ano_letivo',
            'situacao_final'
        ]
        
        missing_fields = [field for field in required_fields if field not in df.columns]
        
        if missing_fields:
            self.errors.append(f"Campos obrigatórios faltando: {missing_fields}")
    
    def _validate_data_ranges(self, df: pd.DataFrame):
        """Valida intervalos de valores"""
        # Exemplo: validar notas entre 0 e 10
        if 'nota_final' in df.columns:
            invalid_notes = df[
                (df['nota_final'] < 0) | (df['nota_final'] > 10)
            ]
            if len(invalid_notes) > 0:
                self.errors.append(
                    f"Encontradas {len(invalid_notes)} notas fora do intervalo [0, 10]"
                )
        
        # Exemplo: validar ano letivo
        if 'ano_letivo' in df.columns:
            current_year = pd.Timestamp.now().year
            invalid_years = df[
                (df['ano_letivo'] < 2000) | (df['ano_letivo'] > current_year + 1)
            ]
            if len(invalid_years) > 0:
                self.errors.append(
                    f"Encontrados {len(invalid_years)} anos letivos inválidos"
                )
    
    def _validate_data_integrity(self, df: pd.DataFrame):
        """Valida integridade dos dados"""
        # Verifica duplicatas em campos únicos
        if 'matricula' in df.columns:
            duplicates = df[df['matricula'].duplicated(keep=False)]
            if len(duplicates) > 0:
                self.errors.append(
                    f"Encontradas {len(duplicates)} matrículas duplicadas"
                )
        
        # Verifica consistência de relacionamentos
        # Adicione validações específicas do seu domínio
