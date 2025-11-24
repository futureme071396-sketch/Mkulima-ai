# backend-api/main.py
from flask import Flask, jsonify
from flask_cors import CORS
from app.routes.prediction import prediction_bp
from app.routes.users import users_bp
from app.routes.analytics import analytics_bp
from app.config import Config
import os

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Enable CORS for all domains
    CORS(app)
    
    # Register blueprints
    app.register_blueprint(prediction_bp, url_prefix='/api/v1')
    app.register_blueprint(users_bp, url_prefix='/api/v1')
    app.register_blueprint(analytics_bp, url_prefix='/api/v1')
    
    # Health check endpoint
    @app.route('/')
    def health_check():
        return jsonify({
            'status': 'healthy',
            'message': 'Mkulima AI API is running',
            'version': '1.0.0'
        })
    
    @app.route('/api/v1/health')
    def api_health():
        return jsonify({
            'status': 'healthy',
            'timestamp': '2024-01-01T00:00:00Z',
            'environment': os.getenv('FLASK_ENV', 'development')
        })
    
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=5000, debug=os.getenv('FLASK_DEBUG', False))
