# backend-api/app/services/database.py
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

# Initialize SQLAlchemy
db = SQLAlchemy()

# Initialize Migrate
migrate = Migrate()

def init_db(app):
    """Initialize database with the Flask app"""
    db.init_app(app)
    migrate.init_app(app, db)
    
    # Create tables
    with app.app_context():
        db.create_all()
    
    return db

def get_db():
    """Get database instance"""
    return db

class DatabaseService:
    """Service class for database operations"""
    
    @staticmethod
    def add_detection(user_id, detection_data):
        """Add a new disease detection"""
        from app.models.disease_model import DiseaseDetection
        
        detection = DiseaseDetection(
            user_id=user_id,
            plant_type=detection_data['plant_type'],
            disease_name=detection_data['disease_name'],
            confidence=detection_data['confidence'],
            severity=detection_data['severity'],
            image_path=detection_data.get('image_path'),
            location=detection_data.get('location'),
            treatments=detection_data.get('treatments', []),
            preventions=detection_data.get('preventions', []),
            is_synced=detection_data.get('is_synced', True),
            is_local_detection=detection_data.get('is_local_detection', False)
        )
        
        db.session.add(detection)
        db.session.commit()
        
        return detection
    
    @staticmethod
    def get_user_detections(user_id, limit=50, offset=0):
        """Get detections for a user with pagination"""
        from app.models.disease_model import DiseaseDetection
        
        detections = DiseaseDetection.query.filter_by(
            user_id=user_id
        ).order_by(
            DiseaseDetection.detected_at.desc()
        ).offset(offset).limit(limit).all()
        
        total = DiseaseDetection.query.filter_by(user_id=user_id).count()
        
        return {
            'detections': [detection.to_dict() for detection in detections],
            'total': total,
            'limit': limit,
            'offset': offset,
            'has_more': offset + limit < total
        }
    
    @staticmethod
    def get_detection_stats(user_id):
        """Get detection statistics for a user"""
        from app.models.disease_model import DiseaseDetection
        from sqlalchemy import func
        
        stats = db.session.query(
            func.count(DiseaseDetection.id).label('total_detections'),
            func.avg(DiseaseDetection.confidence).label('avg_confidence')
        ).filter_by(user_id=user_id).first()
        
        severity_stats = db.session.query(
            DiseaseDetection.severity,
            func.count(DiseaseDetection.id).label('count')
        ).filter_by(user_id=user_id).group_by(DiseaseDetection.severity).all()
        
        disease_stats = db.session.query(
            DiseaseDetection.disease_name,
            func.count(DiseaseDetection.id).label('count')
        ).filter_by(user_id=user_id).group_by(DiseaseDetection.disease_name).all()
        
        return {
            'total_detections': stats.total_detections or 0,
            'average_confidence': float(stats.avg_confidence or 0),
            'severity_breakdown': {stat.severity: stat.count for stat in severity_stats},
            'disease_breakdown': {stat.disease_name: stat.count for stat in disease_stats}
        }
    
    @staticmethod
    def get_platform_analytics():
        """Get platform-wide analytics"""
        from app.models.user_model import User
        from app.models.disease_model import DiseaseDetection
        from sqlalchemy import func
        
        total_users = User.query.count()
        total_detections = DiseaseDetection.query.count()
        active_today = DiseaseDetection.query.filter(
            func.date(DiseaseDetection.detected_at) == func.current_date()
        ).count()
        
        # Regional distribution
        regional_stats = db.session.query(
            User.region,
            func.count(DiseaseDetection.id).label('count')
        ).join(DiseaseDetection).group_by(User.region).all()
        
        # Common diseases
        common_diseases = db.session.query(
            DiseaseDetection.disease_name,
            func.count(DiseaseDetection.id).label('count')
        ).group_by(DiseaseDetection.disease_name).order_by(
            func.count(DiseaseDetection.id).desc()
        ).limit(10).all()
        
        return {
            'total_users': total_users,
            'total_detections': total_detections,
            'active_today': active_today,
            'regional_distribution': {stat.region: stat.count for stat in regional_stats},
            'common_diseases': [{'disease': disease.disease_name, 'count': disease.count} 
                              for disease in common_diseases]
        }
