# backend-api/app/routes/prediction.py
from flask import Blueprint, request, jsonify
from app.services.ai_predictor import AIPredictor
from app.services.image_processor import ImageProcessor
from app.utils.helpers import allowed_file, validate_image
import os
import uuid
from datetime import datetime

prediction_bp = Blueprint('prediction', __name__)
ai_predictor = AIPredictor()
image_processor = ImageProcessor()

@prediction_bp.route('/predict', methods=['POST'])
def predict_disease():
    """
    Predict plant disease from uploaded image
    """
    try:
        # Check if image file is present
        if 'image' not in request.files:
            return jsonify({
                'success': False,
                'error': 'No image file provided'
            }), 400
        
        image_file = request.files['image']
        
        # Check if file is selected
        if image_file.filename == '':
            return jsonify({
                'success': False,
                'error': 'No file selected'
            }), 400
        
        # Validate file type
        if not allowed_file(image_file.filename):
            return jsonify({
                'success': False,
                'error': 'Invalid file type. Only PNG, JPG, JPEG allowed'
            }), 400
        
        # Get plant type from form data
        plant_type = request.form.get('plant_type', 'maize').lower()
        location = request.form.get('location')
        user_id = request.form.get('user_id')
        
        # Validate image
        validation_error = validate_image(image_file)
        if validation_error:
            return jsonify({
                'success': False,
                'error': validation_error
            }), 400
        
        # Process image and make prediction
        processed_image = image_processor.preprocess(image_file)
        prediction = ai_predictor.predict(processed_image, plant_type)
        
        # Generate unique ID for this detection
        detection_id = str(uuid.uuid4())
        
        # Prepare response
        response_data = {
            'success': True,
            'detection_id': detection_id,
            'disease': prediction['disease_name'],
            'confidence': float(prediction['confidence']),
            'severity': prediction['severity'],
            'treatment': prediction['treatments'],
            'prevention': prediction['preventions'],
            'plant_type': plant_type,
            'timestamp': prediction['timestamp']
        }
        
        # Add location if provided
        if location:
            response_data['location'] = location
        
        return jsonify(response_data)
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Prediction failed: {str(e)}'
        }), 500

@prediction_bp.route('/plants', methods=['GET'])
def get_supported_plants():
    """
    Get list of supported plants and their diseases
    """
    plants = {
        'maize': {
            'name': 'Maize',
            'local_name': 'Mahindi',
            'diseases': [
                'Maize Lethal Necrosis',
                'Northern Leaf Blight', 
                'Common Rust',
                'Gray Leaf Spot',
                'Healthy'
            ]
        },
        'coffee': {
            'name': 'Coffee',
            'local_name': 'Kahawa',
            'diseases': [
                'Coffee Leaf Rust',
                'Coffee Berry Disease',
                'Healthy'
            ]
        },
        'tomato': {
            'name': 'Tomato', 
            'local_name': 'Nyanya',
            'diseases': [
                'Tomato Early Blight',
                'Tomato Late Blight',
                'Tomato Leaf Mold',
                'Bacterial Spot',
                'Healthy'
            ]
        },
        'banana': {
            'name': 'Banana',
            'local_name': 'Ndizi', 
            'diseases': [
                'Banana Sigatoka',
                'Banana Bunchy Top',
                'Healthy'
            ]
        }
    }
    
    return jsonify({
        'success': True,
        'plants': plants
    })

@prediction_bp.route('/detections/<detection_id>', methods=['GET'])
def get_detection(detection_id):
    """
    Get specific detection by ID
    """
    # This would typically fetch from database
    # For now, return mock data
    return jsonify({
        'success': True,
        'detection': {
            'id': detection_id,
            'disease': 'Maize Lethal Necrosis',
            'confidence': 0.85,
            'severity': 'High',
            'plant_type': 'maize',
            'timestamp': datetime.utcnow().isoformat()
        }
    })
