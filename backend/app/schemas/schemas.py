from app import ma
from app.models.models import Employee, Department, LeaveRequest

class DepartmentSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Department
        include_fk = True

class EmployeeSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Employee
        include_fk = True

class LeaveRequestSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = LeaveRequest
        include_fk = True

# Ініціалізація об'єктів для використання в контролерах
employee_schema = EmployeeSchema()
employees_schema = EmployeeSchema(many=True)
department_schema = DepartmentSchema()
departments_schema = DepartmentSchema(many=True)