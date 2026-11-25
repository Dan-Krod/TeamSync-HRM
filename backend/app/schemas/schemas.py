from app import ma
from app.models.models import Employee, Department, LeaveRequest, AttendanceRecord, Candidate, Vacancy, WorkSchedule

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

class AttendanceSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = AttendanceRecord
        include_fk = True

class VacancySchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Vacancy
        include_fk = True

class CandidateSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Candidate
        include_fk = True
        
class WorkScheduleSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = WorkSchedule
        include_fk = True

attendance_schema = AttendanceSchema()
candidate_schema = CandidateSchema()
candidates_schema = CandidateSchema(many=True)
employee_schema = EmployeeSchema()
employees_schema = EmployeeSchema(many=True)
department_schema = DepartmentSchema()
departments_schema = DepartmentSchema(many=True)
vacancy_schema = VacancySchema()
vacancies_schema = VacancySchema(many=True)
work_schedule_schema = WorkScheduleSchema()
work_schedules_schema = WorkScheduleSchema(many=True)