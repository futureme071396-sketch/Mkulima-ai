# backend-api/app/models/disease_model.py
from app.services.database import db
from datetime import datetime
import uuid

class DiseaseDetection(db.Model):
    """Disease detection model for storing scan results"""
    __tablename__ = 'disease_detections'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    plant_type = db.Column(db.String(50), nullable=False)  # maize, coffee, tomato, etc.
    disease_name = db.Column(db.String(100), nullable=False)
    confidence = db.Column(db.Float, nullable=False)  # 0.0 to 1.0
    severity = db.Column(db.String(20), nullable=False)  # Low, Medium, High
    image_path = db.Column(db.String(255))  # Path to stored image
    location = db.Column(db.String(100))  # GPS coordinates or region
    treatments = db.Column(db.JSON, default=list)  # List of treatment recommendations
    preventions = db.Column(db.JSON, default=list)  # List of prevention tips
    detected_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_synced = db.Column(db.Boolean, default=True)  # For offline sync
    is_local_detection = db.Column(db.Boolean, default=False)  # Local vs server detection
    
    def to_dict(self):
        """Convert detection object to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'plant_type': self.plant_type,
            'disease_name': self.disease_name,
            'confidence': self.confidence,
            'severity': self.severity,
            'image_path': self.image_path,
            'location': self.location,
            'treatments': self.treatments,
            'preventions': self.preventions,
            'detected_at': self.detected_at.isoformat(),
            'is_synced': self.is_synced,
            'is_local_detection': self.is_local_detection
        }
    
    def __repr__(self):
        return f'<DiseaseDetection {self.disease_name} ({self.confidence:.2f})>'

class Plant(db.Model):
    """Plant model for storing plant information"""
    __tablename__ = 'plants'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False, unique=True)
    scientific_name = db.Column(db.String(100))
    local_name = db.Column(db.String(50))
    category = db.Column(db.String(20))  # cereal, vegetable, fruit, cash_crop
    common_diseases = db.Column(db.JSON, default=list)
    image_url = db.Column(db.String(255))
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert plant object to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'scientific_name': self.scientific_name,
            'local_name': self.local_name,
            'category': self.category,
            'common_diseases': self.common_diseases,
            'image_url': self.image_url,
            'description': self.description
        }
    
    def __repr__(self):
        return f'<Plant {self.name} ({self.scientific_name})>'
