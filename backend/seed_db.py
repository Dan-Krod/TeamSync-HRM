from app import create_app, db
from app.models.models import (Department, Employee, LeaveRequest, 
                                AttendanceRecord, Payroll, Document, 
                                PerformanceReview, Candidate)
from faker import Faker
import random
from datetime import timedelta, datetime

fake = Faker('uk_UA')
app = create_app()

def seed():
    with app.app_context():
        db.drop_all() 
        db.create_all()

        departments = []
        dept_names = ['IT', 'HR', 'Фінанси', 'Маркетинг', 'Продажі']
        for name in dept_names:
            dept = Department(name=name, description=fake.catch_phrase())
            db.session.add(dept)
            departments.append(dept)
        db.session.commit()

        employees = []
        roles = ['admin', 'hr', 'manager', 'user']
        for _ in range(50):
            emp = Employee(
                first_name=fake.first_name(),
                last_name=fake.last_name(),
                email=fake.unique.email(),
                phone=fake.phone_number(),
                position=fake.job(),
                salary=round(random.uniform(15000, 80000), 2),
                hire_date=fake.date_between(start_date='-5y', end_date='today'),
                role=random.choice(roles),
                department_id=random.choice(departments).id
            )
            db.session.add(emp)
            employees.append(emp)
        db.session.commit()

        manager_ids = [e.id for e in employees if e.role in ['admin', 'manager', 'hr']]
        if not manager_ids:
            manager_ids = [employees[0].id] 

        for emp in employees:
            if random.choice([True, False]):
                start = fake.date_between(start_date='-1y', end_date='+30d')
                leave = LeaveRequest(
                    employee_id=emp.id,
                    type=random.choice(['vacation', 'sick', 'business_trip']),
                    start_date=start,
                    end_date=start + timedelta(days=random.randint(3, 14)),
                    status=random.choice(['pending', 'approved', 'rejected']),
                    reason=fake.sentence()
                )
                db.session.add(leave)

            for i in range(5):
                record_date = datetime.today().date() - timedelta(days=i)
                clock_in = datetime.combine(record_date, datetime.strptime(f"0{random.randint(8,9)}:{random.randint(10,59)}", "%H:%M").time())
                clock_out = clock_in + timedelta(hours=random.randint(7, 9))
                attendance = AttendanceRecord(
                    employee_id=emp.id,
                    record_date=record_date,
                    clock_in=clock_in,
                    clock_out=clock_out,
                    is_overtime=random.choice([True, False, False, False]) 
                )
                db.session.add(attendance)

            payroll = Payroll(
                employee_id=emp.id,
                period_start=fake.date_between(start_date='-2m', end_date='-1m'),
                period_end=fake.date_between(start_date='-1m', end_date='today'),
                net_pay=round(emp.salary * random.uniform(0.8, 1.0), 2),
                status=random.choice(['paid', 'pending'])
            )
            db.session.add(payroll)

            doc_types = ['contract', 'nda', 'order']
            for doc_type in random.sample(doc_types, random.randint(1, 2)):
                doc = Document(
                    employee_id=emp.id,
                    doc_type=doc_type,
                    file_path=f"/storage/docs/emp_{emp.id}_{doc_type}.pdf"
                )
                db.session.add(doc)

            if random.choice([True, False]):
                review = PerformanceReview(
                    employee_id=emp.id,
                    reviewer_id=random.choice(manager_ids),
                    score=random.randint(2, 5),
                    comments=fake.text(max_nb_chars=100)
                )
                db.session.add(review)

        for _ in range(15):
            candidate = Candidate(
                full_name=f"{fake.first_name()} {fake.last_name()}",
                status=random.choice(['pending', 'interviewed', 'hired', 'rejected']),
                resume_url=fake.url()
            )
            db.session.add(candidate)

        db.session.commit()
        print("Базу даних успішно наповнено! Заповнено всі 8 таблиць.")

if __name__ == '__main__':
    seed()