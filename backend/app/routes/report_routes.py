from flask import Blueprint, jsonify
from app.models.models import Department, Employee
from app.services.organization_composite import DepartmentComposite, EmployeeLeaf

report_bp = Blueprint('report_bp', __name__, url_prefix='/api/reports')

@report_bp.route('/departments', methods=['GET'])
def get_department_reports():
    departments = Department.query.all()
    reports = []

    for dept in departments:
        dept_composite = DepartmentComposite(dept.name)
        
        employees = Employee.query.filter_by(department_id=dept.id).all()
        for emp in employees:
            dept_composite.add(EmployeeLeaf(emp))
            
        reports.append(dept_composite.generate_report())

    return jsonify({"department_reports": reports}), 200