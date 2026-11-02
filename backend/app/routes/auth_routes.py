import json
from flask import Blueprint, request, jsonify
from app.models.models import Employee
from flask_jwt_extended import create_access_token
from flask_jwt_extended import jwt_required, get_jwt_identity

auth_bp = Blueprint('auth_bp', __name__, url_prefix='/api/auth')

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    emp = Employee.query.filter_by(email=data.get('email')).first()
    
    if emp and emp.check_password(data.get('password')):
        identity_str = json.dumps({'id': emp.id, 'role': emp.role})
        access_token = create_access_token(identity=identity_str)
        
        return jsonify({
            'token': access_token, 
            'role': emp.role, 
            'name': f"{emp.first_name} {emp.last_name}",
            "salary": emp.salary
        }), 200

    return jsonify({'error': 'Невірний email або пароль'}), 401

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_me():
    # Парсимо токен
    import json
    current_user = json.loads(get_jwt_identity())
    
    # Шукаємо працівника в базі
    from app.models.models import Employee
    emp = Employee.query.get(current_user['id'])
    
    if not emp:
        return jsonify({"error": "Користувача не знайдено"}), 404
        
    return jsonify({
        "name": f"{emp.first_name} {emp.last_name}",
        "salary": emp.salary
    }), 200