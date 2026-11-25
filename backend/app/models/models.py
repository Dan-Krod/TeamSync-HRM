from app import db
from datetime import datetime

class Department(db.Model):
    __tablename__ = 'departments'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    manager_id = db.Column(db.Integer) 

    employees = db.relationship('Employee', backref='department', lazy=True, foreign_keys='Employee.department_id')

class Employee(db.Model):
    __tablename__ = 'employees'
    
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    position = db.Column(db.String(100), nullable=False)
    salary = db.Column(db.Float, nullable=False)
    hire_date = db.Column(db.Date, nullable=False)
    role = db.Column(db.String(20), nullable=False) # admin, hr, manager, user
    department_id = db.Column(db.Integer, db.ForeignKey('departments.id'))

    leave_requests = db.relationship('LeaveRequest', backref='employee', lazy=True)
    attendances = db.relationship('AttendanceRecord', backref='employee', lazy=True)
    payrolls = db.relationship('Payroll', backref='employee', lazy=True)
    documents = db.relationship('Document', backref='employee', lazy=True)

class LeaveRequest(db.Model):
    __tablename__ = 'leave_requests'
    
    id = db.Column(db.Integer, primary_key=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    type = db.Column(db.String(50), nullable=False)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    status = db.Column(db.String(20), nullable=False) 
    reason = db.Column(db.Text)

class AttendanceRecord(db.Model):
    __tablename__ = 'attendance_records'
    
    id = db.Column(db.Integer, primary_key=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    record_date = db.Column(db.Date, nullable=False)
    clock_in = db.Column(db.DateTime)
    clock_out = db.Column(db.DateTime)
    is_overtime = db.Column(db.Boolean, default=False)

class Payroll(db.Model):
    __tablename__ = 'payrolls'
    
    id = db.Column(db.Integer, primary_key=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    period_start = db.Column(db.Date, nullable=False)
    period_end = db.Column(db.Date, nullable=False)
    net_pay = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(20), nullable=False)

class Document(db.Model):
    __tablename__ = 'documents'
    
    id = db.Column(db.Integer, primary_key=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    doc_type = db.Column(db.String(50), nullable=False)
    file_path = db.Column(db.String(255), nullable=False)

class PerformanceReview(db.Model):
    __tablename__ = 'performance_reviews'
    
    id = db.Column(db.Integer, primary_key=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    reviewer_id = db.Column(db.Integer, db.ForeignKey('employees.id'), nullable=False)
    score = db.Column(db.Integer, nullable=False)
    comments = db.Column(db.Text)

class Candidate(db.Model):
    __tablename__ = 'candidates'
    
    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(100), nullable=False)
    status = db.Column(db.String(20), nullable=False)
    resume_url = db.Column(db.String(255))