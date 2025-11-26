"""
Sistema de logging configurável
"""

import sys
from pathlib import Path
from loguru import logger


def setup_logger(
    log_file: str = "logs/pipeline.log",
    level: str = "INFO",
    rotation: str = "1 day",
    retention: str = "30 days"
):
    """
    Configura o logger do projeto
    
    Args:
        log_file: Caminho do arquivo de log
        level: Nível de log (DEBUG, INFO, WARNING, ERROR)
        rotation: Rotação do arquivo
        retention: Tempo de retenção
    """
    # Remove handlers padrão
    logger.remove()
    
    # Cria diretório de logs se não existir
    log_path = Path(log_file).parent
    log_path.mkdir(parents=True, exist_ok=True)
    
    # Console output
    logger.add(
        sys.stderr,
        format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level=level,
        colorize=True
    )
    
    # File output
    logger.add(
        log_file,
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
        level=level,
        rotation=rotation,
        retention=retention,
        compression="zip"
    )
    
    return logger


def get_logger(name: str = None):
    """
    Retorna uma instância do logger
    
    Args:
        name: Nome do módulo
        
    Returns:
        Logger configurado
    """
    return logger.bind(name=name) if name else logger
