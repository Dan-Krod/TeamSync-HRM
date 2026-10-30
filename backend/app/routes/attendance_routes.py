from flask import Blueprint, request, jsonify
from datetime import datetime
from app.models.models import AttendanceRecord
from app.schemas.schemas import attendance_schema
from app import db

attendance_bp = Blueprint('attendance_bp', __name__, url_prefix='/api/attendance')

@attendance_bp.route('/clock-in', methods=['POST'])
def clock_in():
    """
    Відмітка прибуття на роботу (Clock-in)
    ---
    parameters:
      - in: body
        name: body
        schema:
          type: object
          properties:
            employee_id:
              type: integer
    responses:
      201:
        description: Час прибуття зафіксовано
    """
    data = request.get_json()
    record = AttendanceRecord(
        employee_id=data['employee_id'],
        record_date=datetime.today().date(),
        clock_in=datetime.now()
    )
    db.session.add(record)
    db.session.commit()
    return jsonify(attendance_schema.dump(record)), 201