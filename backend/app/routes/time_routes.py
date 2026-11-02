import json
from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from app import db
from app.models.models import AttendanceRecord, Employee

time_bp = Blueprint('time_bp', __name__, url_prefix='/api/time')

@time_bp.route('/clock-in', methods=['POST'])
@jwt_required()
def clock_in():
    current_user = json.loads(get_jwt_identity())
    emp_id = current_user['id']
    
    today = datetime.today().date()
    existing = AttendanceRecord.query.filter_by(employee_id=emp_id, record_date=today).first()
    
    if existing and existing.clock_in:
        return jsonify({"error": "Зміну вже розпочато сьогодні"}), 400
        
    if not existing:
        new_record = AttendanceRecord(employee_id=emp_id, record_date=today, clock_in=datetime.now())
        db.session.add(new_record)
    else:
        existing.clock_in = datetime.now()
        
    db.session.commit()
    return jsonify({"msg": "Зміну розпочато успішно"}), 201

@time_bp.route('/clock-out', methods=['PUT'])
@jwt_required()
def clock_out():
    current_user = json.loads(get_jwt_identity())
    emp_id = current_user['id']
    
    today = datetime.today().date()
    existing = AttendanceRecord.query.filter_by(employee_id=emp_id, record_date=today).first()
    
    if not existing or not existing.clock_in:
        return jsonify({"error": "Спочатку потрібно почати зміну"}), 400
        
    if existing.clock_out:
        return jsonify({"error": "Зміну вже завершено"}), 400
        
    existing.clock_out = datetime.now()
    db.session.commit()
    return jsonify({"msg": "Зміну завершено успішно"}), 200

@time_bp.route('/', methods=['GET'])
@jwt_required()
def get_attendance():
    current_user = json.loads(get_jwt_identity())
    
    # Перевірка доступу (тільки для HR та Admin)
    if current_user['role'] not in ['hr', 'admin']:
        return jsonify({"error": "Немає прав доступу"}), 403
        
    records = AttendanceRecord.query.all()
    result = []
    
    for r in records:
        emp = Employee.query.get(r.employee_id)
        result.append({
            'id': r.id,
            'employee_name': f"{emp.first_name} {emp.last_name}" if emp else "Невідомо",
            'date': r.date.strftime('%Y-%m-%d') if hasattr(r, 'date') and r.date else '',
            'clock_in': r.clock_in.strftime('%H:%M') if hasattr(r, 'clock_in') and r.clock_in else '--:--',
            'clock_out': r.clock_out.strftime('%H:%M') if hasattr(r, 'clock_out') and r.clock_out else '--:--'
        })
        
    return jsonify(result), 200