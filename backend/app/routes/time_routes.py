import json
from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from app import db
from app.models.models import TimeRecord, Employee

time_bp = Blueprint('time_bp', __name__, url_prefix='/api/time')

@time_bp.route('/clock-in', methods=['POST'])
@jwt_required()
def clock_in():
    current_user = get_jwt_identity()
    emp_id = current_user['id']
    
    # Перевіряємо, чи немає вже відкритої зміни сьогодні
    existing_record = TimeRecord.query.filter_by(
        employee_id=emp_id, 
        date=datetime.utcnow().date(),
        clock_out=None
    ).first()
    
    if existing_record:
        return jsonify({'error': 'Зміна вже розпочата'}), 400
        
    new_record = TimeRecord(employee_id=emp_id)
    db.session.add(new_record)
    db.session.commit()
    
    return jsonify({'message': 'Зміну успішно розпочато', 'clock_in': new_record.clock_in}), 200

@time_bp.route('/clock-out', methods=['PUT'])
@jwt_required()
def clock_out():
    current_user = get_jwt_identity()
    emp_id = current_user['id']
    
    # Шукаємо відкриту зміну
    record = TimeRecord.query.filter_by(
        employee_id=emp_id, 
        clock_out=None
    ).first()
    
    if not record:
        return jsonify({'error': 'Немає активної зміни для завершення'}), 404
        
    record.clock_out = datetime.utcnow()
    db.session.commit()
    
    return jsonify({'message': 'Зміну успішно завершено', 'clock_out': record.clock_out}), 200

@time_bp.route('/', methods=['GET'])
@jwt_required()
def get_attendance():
    current_user = json.loads(get_jwt_identity())
    
    # Перевірка доступу (тільки для HR та Admin)
    if current_user['role'] not in ['hr', 'admin']:
        return jsonify({"error": "Немає прав доступу"}), 403
        
    records = TimeRecord.query.all()
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