# backend-api/app/routes/users.py
from flask import Blueprint, request, jsonify
import uuid
from datetime import datetime

users_bp = Blueprint('users', __name__)

# In-memory storage for demo (replace with database in production)
users_db = {}
detections_db = {}

@users_bp.route('/users', methods=['POST'])
def create_user():
    """
    Create a new user
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': 'No data provided'
            }), 400
        
        required_fields = ['name', 'email', 'region']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'error': f'Missing required field: {field}'
                }), 400
        
        user_id = str(uuid.uuid4())
        
        user_data = {
            'id': user_id,
            'name': data['name'],
            'email': data['email'],
            'phone': data.get('phone', ''),
            'region': data['region'],
            'preferred_language': data.get('preferred_language', 'sw'),
            'farm_size': data.get('farm_size', 0),
            'main_crops': data.get('main_crops', ['maize']),
            'created_at': datetime.utcnow().isoformat(),
            'total_scans': 0,
            'successful_detections': 0
        }
        
        users_db[user_id] = user_data
        detections_db[user_id] = []
        
        return jsonify({
            'success': True,
            'user': user_data
        }), 201
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Failed to create user: {str(e)}'
        }), 500

@users_bp.route('/users/<user_id>', methods=['GET'])
def get_user(user_id):
    """
    Get user by ID
    """
    user = users_db.get(user_id)
    
    if not user:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    return jsonify({
        'success': True,
        'user': user
    })

@users_bp.route('/users/<user_id>/detections', methods=['GET'])
def get_user_detections(user_id):
    """
    Get detection history for a user
    """
    if user_id not in detections_db:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    detections = detections_db[user_id]
    
    # Add pagination parameters
    limit = min(int(request.args.get('limit', 50)), 100)
    offset = int(request.args.get('offset', 0))
    
    paginated_detections = detections[offset:offset + limit]
    
    return jsonify({
        'success': True,
        'detections': paginated_detections,
        'pagination': {
            'total': len(detections),
            'limit': limit,
            'offset': offset,
            'has_more': offset + limit < len(detections)
        }
    })

@users_bp.route('/users/<user_id>/stats', methods=['GET'])
def get_user_stats(user_id):
    """
    Get user statistics
    """
    user = users_db.get(user_id)
    
    if not user:
        return jsonify({
            'success': False,
            'error': 'User not found'
        }), 404
    
    user_detections = detections_db.get(user_id, [])
    
    # Calculate statistics
    total_detections = len(user_detections)
    high_severity = len([d for d in user_detections if d.get('severity') == 'High'])
    medium_severity = len([d for d in user_detections if d.get('severity') == 'Medium'])
    low_severity = len([d for d in user_detections if d.get('severity') == 'Low'])
    
    # Most common disease
    disease_counts = {}
    for detection in user_detections:
        disease = detection.get('disease', 'Unknown')
        disease_counts[disease] = disease_counts.get(disease, 0) + 1
    
    most_common_disease = max(disease_counts, key=disease_counts.get) if disease_counts else 'None'
    
    stats = {
        'total_detections': total_detections,
        'high_severity_count': high_severity,
        'medium_severity_count': medium_severity,
        'low_severity_count': low_severity,
        'most_common_disease': most_common_disease,
        'success_rate': user.get('successful_detections', 0) / max(user.get('total_scans', 1), 1),
        'last_detection': user_detections[0].get('timestamp') if user_detections else None
    }
    
    return jsonify({
        'success': True,
        'stats': stats
    })
