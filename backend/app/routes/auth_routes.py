from flask import Blueprint, request, jsonify
from app.models.models import Employee
from flask_jwt_extended import create_access_token

auth_bp = Blueprint('auth_bp', __name__, url_prefix='/api/auth')

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    emp = Employee.query.filter_by(email=email).first()
    if emp and emp.check_password(password):
        # Зашиваємо ID та роль у токен
        access_token = create_access_token(identity={'id': emp.id, 'role': emp.role})
        return jsonify({
            'token': access_token, 
            'role': emp.role, 
            'name': f"{emp.first_name} {emp.last_name}"
        }), 200

    return jsonify({'error': 'Невірний email або пароль'}), 401