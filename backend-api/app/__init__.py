# backend-api/app/__init__.py
"""
Mkulima AI Flask Application Package
"""

from flask import Flask
from flask_cors import CORS
from .config import Config
from app.services.database import init_db

def create_app(config_class=Config):
    """
    Application factory pattern for creating Flask app
    """
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Enable CORS
    CORS(app)
    
    # Initialize database
    init_db(app)
    
    # Register blueprints
    from .routes.prediction import prediction_bp
    from .routes.users import users_bp
    from .routes.analytics import analytics_bp
    
    app.register_blueprint(prediction_bp, url_prefix='/api/v1')
    app.register_blueprint(users_bp, url_prefix='/api/v1')
    app.register_blueprint(analytics_bp, url_prefix='/api/v1')
    
    # Health check endpoint
    @app.route('/')
    def health_check():
        return {
            'status': 'healthy',
            'message': 'Mkulima AI API is running',
            'version': '1.0.0'
        }
    
    @app.route('/api/v1/health')
    def api_health():
        return {
            'status': 'healthy',
            'environment': app.config.get('ENV', 'production')
        }
    
    return app

# Import models and routes to make them available
from .models import user_model, disease_model
from .routes import prediction, users, analytics
