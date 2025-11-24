# backend-api/app/utils/auth.py
import jwt
import datetime
from functools import wraps
from flask import request, jsonify, current_app
from app.models.user_model import User

def generate_token(user_id):
    """Generate JWT token for user"""
    try:
        payload = {
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1),
            'iat': datetime.datetime.utcnow(),
            'sub': user_id
        }
        return jwt.encode(
            payload,
            current_app.config.get('SECRET_KEY'),
            algorithm='HS256'
        )
    except Exception as e:
        return e

def verify_token(token):
    """Verify JWT token"""
    try:
        payload = jwt.decode(
            token, 
            current_app.config.get('SECRET_KEY'),
            algorithms=['HS256']
        )
        return payload['sub']
    except jwt.ExpiredSignatureError:
        return 'Token expired. Please log in again.'
    except jwt.InvalidTokenError:
        return 'Invalid token. Please log in again.'

def token_required(f):
    """Decorator to require valid JWT token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Get token from header
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer <token>
            except IndexError:
                return jsonify({
                    'success': False,
                    'error': 'Invalid authorization header format'
                }), 401
        
        if not token:
            return jsonify({
                'success': False,
                'error': 'Authorization token is missing'
            }), 401
        
        # Verify token
        user_id = verify_token(token)
        if isinstance(user_id, str) and ('expired' in user_id or 'Invalid' in user_id):
            return jsonify({
                'success': False,
                'error': user_id
            }), 401
        
        # Get user from database
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 401
        
        # Add user to request context
        request.current_user = user
        return f(*args, **kwargs)
    
    return decorated

def admin_required(f):
    """Decorator to require admin privileges"""
    @wraps(f)
    def decorated(*args, **kwargs):
        # First check for valid token
        token_response = token_required(f)(*args, **kwargs)
        
        # If token check failed, return the error
        if isinstance(token_response, tuple) and token_response[1] != 200:
            return token_response
        
        # Check if user is admin (you might want to add an is_admin field to User model)
        if not getattr(request.current_user, 'is_admin', False):
            return jsonify({
                'success': False,
                'error': 'Admin privileges required'
            }), 403
        
        return f(*args, **kwargs)
    
    return decorated

def get_current_user():
    """Get current user from request context"""
    return getattr(request, 'current_user', None)

def validate_email(email):
    """Validate email format"""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_phone(phone):
    """Validate phone number format (Kenyan)"""
    import re
    # Supports formats: +254..., 254..., 07...
    pattern = r'^(\+?254|0)?[17]\d{8}$'
    return re.match(pattern, phone.replace(' ', '')) is not None
