from datetime import datetime
from flask import Blueprint, request, jsonify
from app.models.models import Employee
from app.schemas.schemas import employee_schema, employees_schema
from app import db
from app.services.onboarding_facade import OnboardingFacade
from flask_jwt_extended import jwt_required, get_jwt_identity

employee_bp = Blueprint('employee_bp', __name__, url_prefix='/api/employees')

@employee_bp.route('/', methods=['GET'])
def get_employees():
    """
    Отримати список усіх співробітників
    ---
    responses:
      200:
        description: Список співробітників успішно отримано
    """
    employees = Employee.query.all()
    return jsonify(employees_schema.dump(employees)), 200

@employee_bp.route('/<int:id>', methods=['GET'])
def get_employee(id):
    """
    Отримати дані конкретного співробітника за ID
    ---
    parameters:
      - in: path
        name: id
        type: integer
        required: true
        description: Унікальний ідентифікатор співробітника
    responses:
      200:
        description: Детальні дані співробітника
      404:
        description: Співробітника не знайдено
    """
    employee = Employee.query.get_or_404(id)
    return jsonify(employee_schema.dump(employee)), 200

@employee_bp.route('/', methods=['POST'])
@jwt_required()
def create_employee():
    data = request.get_json()
    
    try:
        new_emp = Employee(
            first_name=data.get('first_name'),
            last_name=data.get('last_name'),
            email=data.get('email'),
            position=data.get('position'),
            salary=data.get('salary', 0.0),
            department_id=data.get('department_id', 1),
            # Додаємо автоматичне заповнення обов'язкових полів:
            hire_date=datetime.today().date(),
            role='user',
            phone=data.get('phone', '+380000000000') 
        )
        # Встановлюємо дефолтний пароль
        new_emp.set_password('password123')
        
        db.session.add(new_emp)
        db.session.commit()
        return jsonify({"msg": "Співробітника створено"}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400
      
@employee_bp.route('/<int:id>', methods=['PUT'])
def update_employee(id):
    """
    Оновити дані співробітника
    ---
    parameters:
      - in: path
        name: id
        required: true
        type: integer
      - in: body
        name: body
        required: true
        schema:
          id: EmployeeUpdate
          type: object
          properties:
            position:
              type: string
            salary:
              type: number
            role:
              type: string
    responses:
      200:
        description: Дані успішно оновлено
    """
    employee = Employee.query.get_or_404(id)
    data = request.get_json()
    
    for key, value in data.items():
        if hasattr(employee, key):
            setattr(employee, key, value)
            
    db.session.commit()
    return jsonify(employee_schema.dump(employee)), 200

@employee_bp.route('/<int:id>', methods=['DELETE'])
def delete_employee(id):
    """
    Видалити співробітника (Звільнення)
    ---
    parameters:
      - in: path
        name: id
        required: true
        type: integer
    responses:
      200:
        description: Співробітника видалено з системи
    """
    employee = Employee.query.get_or_404(id)
    db.session.delete(employee)
    db.session.commit()
    return jsonify({"message": f"Співробітника {id} успішно видалено"}), 200