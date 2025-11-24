# backend-api/app/routes/__init__.py
"""
API Routes Package
"""

from .prediction import prediction_bp
from .users import users_bp
from .analytics import analytics_bp

__all__ = ['prediction_bp', 'users_bp', 'analytics_bp']
