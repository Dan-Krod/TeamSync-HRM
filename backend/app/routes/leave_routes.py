import json
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.models import LeaveRequest
from app.schemas.schemas import LeaveRequestSchema
from app.services.leave_state import LeaveRequestManager
from app import db
from datetime import datetime

leave_bp = Blueprint('leave_bp', __name__, url_prefix='/api/leaves')
leave_schema = LeaveRequestSchema()
leaves_schema = LeaveRequestSchema(many=True)

@leave_bp.route('/', methods=['POST'])
@jwt_required()
def create_leave():
    current_user = json.loads(get_jwt_identity())
    data = request.get_json()
    
    try:
        start = datetime.strptime(data['start_date'], '%Y-%m-%d').date()
        end = datetime.strptime(data['end_date'], '%Y-%m-%d').date()
        
        new_leave = LeaveRequest(
            employee_id=current_user['id'],
            type=data.get('type', 'annual'),
            start_date=start,
            end_date=end,
            status='pending',
            reason=data.get('reason', 'Заявка з кабінету')
        )
        db.session.add(new_leave)
        db.session.commit()
        return jsonify({"msg": "Заявку успішно подано"}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Помилка створення заявки: {str(e)}"}), 400

@leave_bp.route('/', methods=['GET'])
@jwt_required()
def get_leaves():
    current_user = json.loads(get_jwt_identity())
    if current_user['role'] in ['hr', 'admin']:
        leaves = LeaveRequest.query.all()
    else:
        leaves = LeaveRequest.query.filter_by(employee_id=current_user['id']).all()
    return jsonify(leaves_schema.dump(leaves)), 200

@leave_bp.route('/<int:id>/approve', methods=['PUT'])
@jwt_required()
def approve_leave(id):
    current_user = json.loads(get_jwt_identity())
    if current_user['role'] not in ['hr', 'admin']:
        return jsonify({"error": "Немає прав доступу"}), 403
    leave_req = LeaveRequest.query.get_or_404(id)
    try:
        manager = LeaveRequestManager(leave_req)
        manager.approve()
        db.session.commit()
        return jsonify(leave_schema.dump(leave_req)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@leave_bp.route('/<int:id>/reject', methods=['PUT'])
@jwt_required()
def reject_leave(id):
    current_user = json.loads(get_jwt_identity())
    if current_user['role'] not in ['hr', 'admin']:
        return jsonify({"error": "Немає прав доступу"}), 403
    leave_req = LeaveRequest.query.get_or_404(id)
    try:
        manager = LeaveRequestManager(leave_req)
        manager.reject()
        db.session.commit()
        return jsonify(leave_schema.dump(leave_req)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400