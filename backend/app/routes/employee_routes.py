from flask import Blueprint, request, jsonify
from app.models.models import Employee
from app.schemas.schemas import employee_schema, employees_schema
from app import db
from app.services.onboarding_facade import OnboardingFacade

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
def create_employee():
    """
    Створити нового співробітника (Онбординг)
    ---
    parameters:
      - in: body
        name: body
        required: true
        schema:
          id: EmployeeInput
          type: object
          properties:
            first_name:
              type: string
            last_name:
              type: string
            email:
              type: string
            position:
              type: string
            salary:
              type: number
            hire_date:
              type: string
              format: date
            role:
              type: string
            department_id:
              type: integer
    responses:
      201:
        description: Співробітника успішно створено (відпрацював Facade та Factory Method)
      400:
        description: Помилка валідації або збереження в БД
    """
    data = request.get_json()
    try:
        new_employee = OnboardingFacade.onboard_new_employee(data)
        return jsonify(employee_schema.dump(new_employee)), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400