from flask import Blueprint, request, jsonify
from app.models.models import Employee
from app.schemas.schemas import employee_schema, employees_schema
from app import db
from app.services.onboarding_facade import OnboardingFacade

employee_bp = Blueprint('employee_bp', __name__, url_prefix='/api/employees')

@employee_bp.route('/', methods=['GET'])
def get_employees():
    employees = Employee.query.all()
    return jsonify(employees_schema.dump(employees)), 200

@employee_bp.route('/<int:id>', methods=['GET'])
def get_employee(id):
    employee = Employee.query.get_or_404(id)
    return jsonify(employee_schema.dump(employee)), 200

@employee_bp.route('/', methods=['POST'])
def create_employee_basic():
    data = request.get_json()
    new_employee = Employee(**data)
    db.session.add(new_employee)
    db.session.commit()
    return jsonify(employee_schema.dump(new_employee)), 201

@employee_bp.route('/', methods=['POST'])
def create_employee():
    data = request.get_json()
    try:
        new_employee = OnboardingFacade.onboard_new_employee(data)
        return jsonify(employee_schema.dump(new_employee)), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400