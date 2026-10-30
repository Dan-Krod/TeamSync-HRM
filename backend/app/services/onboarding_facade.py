from app.models.models import Employee
from app import db

class OnboardingFacade:
    @staticmethod
    def onboard_new_employee(data: dict) -> Employee:
        new_employee = Employee(**data)
        
        db.session.add(new_employee)
        db.session.commit()
        
        
        return new_employee