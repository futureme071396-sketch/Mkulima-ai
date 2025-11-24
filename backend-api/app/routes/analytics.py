# backend-api/app/routes/analytics.py
from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta

analytics_bp = Blueprint('analytics', __name__)

# Mock data for analytics (replace with database queries)
@analytics_bp.route('/analytics/overview', methods=['GET'])
def get_analytics_overview():
    """
    Get overview analytics for the platform
    """
    # This would typically query the database
    # For now, return mock data
    
    overview = {
        'total_users': 1250,
        'total_detections': 8920,
        'active_today': 187,
        'success_rate': 0.78,
        'common_diseases': [
            {'disease': 'Maize Lethal Necrosis', 'count': 2340},
            {'disease': 'Coffee Leaf Rust', 'count': 1876},
            {'disease': 'Tomato Late Blight', 'count': 1567},
            {'disease': 'Banana Sigatoka', 'count': 1234}
        ],
        'regional_distribution': {
            'Central': 450,
            'Rift Valley': 320,
            'Eastern': 280,
            'Western': 200
        }
    }
    
    return jsonify({
        'success': True,
        'overview': overview
    })

@analytics_bp.route('/analytics/disease-trends', methods=['GET'])
def get_disease_trends():
    """
    Get disease trends over time
    """
    # Get time range from query parameters
    days = int(request.args.get('days', 30))
    
    # Generate mock trend data
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=days)
    
    trends = []
    current_date = start_date
    
    while current_date <= end_date:
        trends.append({
            'date': current_date.strftime('%Y-%m-%d'),
            'maize_diseases': 50 + (current_date.day % 20),
            'coffee_diseases': 30 + (current_date.day % 15),
            'tomato_diseases': 25 + (current_date.day % 10),
            'banana_diseases': 20 + (current_date.day % 8)
        })
        current_date += timedelta(days=1)
    
    return jsonify({
        'success': True,
        'trends': trends,
        'period': {
            'start': start_date.strftime('%Y-%m-%d'),
            'end': end_date.strftime('%Y-%m-%d'),
            'days': days
        }
    })

@analytics_bp.route('/analytics/regional-insights', methods=['GET'])
def get_regional_insights():
    """
    Get disease insights by region
    """
    regional_insights = {
        'Central': {
            'total_detections': 1250,
            'top_diseases': [
                {'disease': 'Maize Lethal Necrosis', 'count': 450},
                {'disease': 'Coffee Berry Disease', 'count': 320},
                {'disease': 'Tomato Early Blight', 'count': 280}
            ],
            'success_rate': 0.82
        },
        'Rift Valley': {
            'total_detections': 980,
            'top_diseases': [
                {'disease': 'Maize Common Rust', 'count': 380},
                {'disease': 'Wheat Rust', 'count': 290},
                {'disease': 'Maize Gray Leaf Spot', 'count': 210}
            ],
            'success_rate': 0.75
        },
        'Eastern': {
            'total_detections': 760,
            'top_diseases': [
                {'disease': 'Coffee Leaf Rust', 'count': 320},
                {'disease': 'Maize Northern Leaf Blight', 'count': 240},
                {'disease': 'Tomato Late Blight', 'count': 150}
            ],
            'success_rate': 0.79
        }
    }
    
    return jsonify({
        'success': True,
        'regional_insights': regional_insights
    })
