# backend-api/app/models/__init__.py
"""
Database Models Package
"""

from .user_model import User
from .disease_model import DiseaseDetection, Plant

__all__ = ['User', 'DiseaseDetection', 'Plant']
