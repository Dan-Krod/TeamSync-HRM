from flask import Blueprint, request, jsonify
from app.models.models import LeaveRequest
from app.schemas.schemas import LeaveRequestSchema
from app.services.leave_state import LeaveRequestManager
from app import db

leave_bp = Blueprint('leave_bp', __name__, url_prefix='/api/leaves')
leave_schema = LeaveRequestSchema()

@leave_bp.route('/<int:id>/approve', methods=['PUT'])
def approve_leave(id):
    """
    Погодити заявку на відпустку (Зміна стану)
    ---
    parameters:
      - in: path
        name: id
        type: integer
        required: true
    responses:
      200:
        description: Заявку погоджено через патерн State
    """
    leave_req = LeaveRequest.query.get_or_404(id)
    try:
        manager = LeaveRequestManager(leave_req)
        manager.approve()
        return jsonify(leave_schema.dump(leave_req)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400