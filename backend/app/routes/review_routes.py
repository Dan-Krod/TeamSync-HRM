import json
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.models import PerformanceReview, Employee

review_bp = Blueprint('review_bp', __name__, url_prefix='/api/reviews')

@review_bp.route('/', methods=['POST'])
@jwt_required()
def add_review():
    current_user = json.loads(get_jwt_identity())
    
    if current_user['role'] not in ['manager', 'hr', 'admin']:
        return jsonify({"error": "Немає прав на проведення оцінки"}), 403

    data = request.get_json()
    
    Employee.query.get_or_404(data.get('employee_id'))
    
    try:
        new_review = PerformanceReview(
            employee_id=data['employee_id'],
            reviewer_id=current_user['id'],
            score=data.get('score', 0),
            comments=data.get('comments', '')
        )
        db.session.add(new_review)
        db.session.commit()
        
        return jsonify({"msg": "Оцінку продуктивності збережено"}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400