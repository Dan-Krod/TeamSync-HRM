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
    
@review_bp.route('/employee/<int:emp_id>', methods=['GET'])
@jwt_required()
def get_employee_reviews(emp_id):
    reviews = (
        PerformanceReview.query
        .filter_by(employee_id=emp_id)
        .order_by(PerformanceReview.id.desc())
        .all()
    )
    result = []
    for r in reviews:
        reviewer = Employee.query.get(r.reviewer_id)
        reviewer_name = (
            f"{reviewer.first_name} {reviewer.last_name}"
            if reviewer else f"ID #{r.reviewer_id}"
        )
        result.append({
            "id": r.id,
            "score": r.score,
            "comments": r.comments or "",
            "reviewer_name": reviewer_name,
        })
    return jsonify({"reviews": result}), 200