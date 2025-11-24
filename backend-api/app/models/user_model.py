# backend-api/app/models/user_model.py
from app.services.database import db
from datetime import datetime
import uuid

class User(db.Model):
    """User model for storing farmer information"""
    __tablename__ = 'users'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    preferred_language = db.Column(db.String(10), default='sw')  # sw, en, kik, luo
    region = db.Column(db.String(50), nullable=False)
    farm_size = db.Column(db.Float, default=0.0)  # in acres
    main_crops = db.Column(db.JSON, default=list)  # List of crops like ['maize', 'coffee']
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    total_scans = db.Column(db.Integer, default=0)
    successful_detections = db.Column(db.Integer, default=0)
    is_premium = db.Column(db.Boolean, default=False)
    
    # Relationship with detections
    detections = db.relationship('DiseaseDetection', backref='user', lazy=True)
    
    def to_dict(self):
        """Convert user object to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'preferred_language': self.preferred_language,
            'region': self.region,
            'farm_size': self.farm_size,
            'main_crops': self.main_crops,
            'created_at': self.created_at.isoformat(),
            'total_scans': self.total_scans,
            'successful_detections': self.successful_detections,
            'is_premium': self.is_premium,
            'success_rate': self.successful_detections / max(self.total_scans, 1)
        }
    
    def update_stats(self, scan_successful=True):
        """Update user statistics after a scan"""
        self.total_scans += 1
        if scan_successful:
            self.successful_detections += 1
        self.updated_at = datetime.utcnow()
    
    def __repr__(self):
        return f'<User {self.name} ({self.email})>'
