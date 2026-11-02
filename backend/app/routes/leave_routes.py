from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.models import LeaveRequest
from app.schemas.schemas import LeaveRequestSchema
from app.services.leave_state import LeaveRequestManager
from app import db

leave_bp = Blueprint('leave_bp', __name__, url_prefix='/api/leaves')
leave_schema = LeaveRequestSchema()
leaves_schema = LeaveRequestSchema(many=True)

@leave_bp.route('/', methods=['POST'])
@jwt_required()
def create_leave():
    """Створення заявки працівником"""
    current_user = get_jwt_identity()
    data = request.get_json()
    
    new_leave = LeaveRequest(
        employee_id=current_user['id'],
        type=data.get('type', 'annual'),
        start_date=data['start_date'],
        end_date=data['end_date'],
        status='pending' # Початковий стан
    )
    db.session.add(new_leave)
    db.session.commit()
    return jsonify(leave_schema.dump(new_leave)), 201

@leave_bp.route('/', methods=['GET'])
@jwt_required()
def get_leaves():
    """Отримання списку заявок (HR бачить всі, юзер - лише свої)"""
    current_user = get_jwt_identity()
    if current_user['role'] in ['hr', 'admin']:
        leaves = LeaveRequest.query.all()
    else:
        leaves = LeaveRequest.query.filter_by(employee_id=current_user['id']).all()
    return jsonify(leaves_schema.dump(leaves)), 200

@leave_bp.route('/<int:id>/approve', methods=['PUT'])
@jwt_required()
def approve_leave(id):
    """Погодити заявку (лише HR/Admin)"""
    current_user = get_jwt_identity()
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
    """Відхилити заявку (лише HR/Admin)"""
    current_user = get_jwt_identity()
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