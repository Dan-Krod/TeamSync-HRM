from flask import Blueprint, jsonify
from app.models.models import Department, Employee
from app.services.organization_composite import DepartmentComposite, EmployeeLeaf

from app.models.models import LeaveRequest
from sqlalchemy import func

report_bp = Blueprint('report_bp', __name__, url_prefix='/api/reports')

@report_bp.route('/departments', methods=['GET'])
def get_department_reports():
    """
    Згенерувати звіт по відділах (Штат та Бюджет)
    ---
    responses:
      200:
        description: Звіт успішно згенеровано за допомогою патерну Composite
    """
    departments = Department.query.all()
    reports = []

    for dept in departments:
        dept_composite = DepartmentComposite(dept.name)
        
        employees = Employee.query.filter_by(department_id=dept.id).all()
        for emp in employees:
            dept_composite.add(EmployeeLeaf(emp))
            
        reports.append(dept_composite.generate_report())

    return jsonify({"department_reports": reports}), 200


@report_bp.route('/leaves-analytics', methods=['GET'])
def get_leaves_analytics():
    """
    Аналітика по відпустках і лікарняних
    ---
    responses:
      200:
        description: Згрупована статистика заявок за типами
    """
    analytics = db.session.query(
        LeaveRequest.type, 
        func.count(LeaveRequest.id).label('count')
    ).group_by(LeaveRequest.type).all()
    
    result = {item.type: item.count for item in analytics}
    return jsonify({"leaves_analytics": result}), 200