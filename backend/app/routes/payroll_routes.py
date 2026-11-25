import json
from datetime import datetime
import calendar
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.models import Employee, Payroll
from app.services.payroll_strategy import PayrollService, FullTimeStrategy, HourlyStrategy

payroll_bp = Blueprint('payroll_bp', __name__, url_prefix='/api/payrolls')

@payroll_bp.route('/calculate/<int:emp_id>', methods=['POST'])
@jwt_required()
def calculate_and_save_payroll(emp_id):
    current_user = json.loads(get_jwt_identity())
    
    if current_user['role'] not in ['hr', 'admin']:
        return jsonify({"error": "Немає прав доступу"}), 403

    emp = Employee.query.get_or_404(emp_id)
    
    strategy = FullTimeStrategy() if emp.salary > 5000 else HourlyStrategy()
    service = PayrollService(strategy)
    
    net_pay = service.calculate_salary(emp)
    
    today = datetime.today()
    first_day = today.replace(day=1)
    last_day = today.replace(day=calendar.monthrange(today.year, today.month)[1])

    try:
        new_payroll = Payroll(
            employee_id=emp.id,
            period_start=first_day.date(),
            period_end=last_day.date(),
            net_pay=net_pay,
            status='paid'
        )
        db.session.add(new_payroll)
        db.session.commit()

        return jsonify({
            "msg": "Зарплату успішно нараховано", 
            "net_pay": net_pay, 
            "period": f"{first_day.date()} - {last_day.date()}"
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400