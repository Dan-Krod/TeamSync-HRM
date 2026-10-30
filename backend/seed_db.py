from app import create_app, db
from app.models.models import Department, Employee, LeaveRequest
from faker import Faker
import random
from datetime import timedelta

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

        for emp in employees:
            if random.choice([True, False]):
                start = fake.date_between(start_date='today', end_date='+30d')
                leave = LeaveRequest(
                    employee_id=emp.id,
                    type=random.choice(['vacation', 'sick']),
                    start_date=start,
                    end_date=start + timedelta(days=random.randint(3, 14)),
                    status=random.choice(['pending', 'approved', 'rejected']),
                    reason=fake.sentence()
                )
                db.session.add(leave)
        db.session.commit()
        print("Базу даних успішно наповнено (50 працівників, 5 відділів, відпустки)!")

if __name__ == '__main__':
    seed()