import io
from flask import send_file
from reportlab.pdfgen import canvas
from flask import Blueprint, jsonify
from app.models.models import Department, Employee, LeaveRequest
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
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

@report_bp.route('/export', methods=['GET'])
@jwt_required()
def export_report():
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer)
    
    c.setFont("Helvetica-Bold", 16)
    c.drawString(50, 800, "Company HR & Financial Report")
    
    c.setFont("Helvetica", 12)
    total_employees = Employee.query.count()
    total_payroll = db.session.query(db.func.sum(Employee.salary)).scalar() or 0
    
    c.drawString(50, 760, f"Total Employees: {total_employees}")
    c.drawString(50, 740, f"Total Monthly Payroll: {total_payroll:,.2f} UAH")
    
    c.setFont("Helvetica-Bold", 14)
    c.drawString(50, 700, "Department Breakdown:")
    
    c.setFont("Helvetica", 12)
    depts = Department.query.all()
    y = 670
    for dept in depts:
        emp_count = Employee.query.filter_by(department_id=dept.id).count()
        dept_payroll = db.session.query(db.func.sum(Employee.salary)).filter_by(department_id=dept.id).scalar() or 0
        c.drawString(70, y, f"- {dept.name}: {emp_count} employees, Payroll: {dept_payroll:,.2f} UAH")
        y -= 20
        
    c.setFont("Helvetica-Bold", 14)
    c.drawString(50, y - 20, "Leave Analytics:")
    
    c.setFont("Helvetica", 12)
    leaves = db.session.query(LeaveRequest.type, db.func.count(LeaveRequest.id)).group_by(LeaveRequest.type).all()
    y -= 50
    for l_type, count in leaves:
        c.drawString(70, y, f"- {l_type.capitalize()}: {count} requests")
        y -= 20
        
    c.showPage()
    c.save()
    buffer.seek(0)
    
    return send_file(buffer, as_attachment=True, download_name='HR_Report_EN.pdf', mimetype='application/pdf')