from app.models.models import Employee
from app.services.document_factory import HRDocumentFactory
from app import db

class OnboardingFacade:
    @staticmethod
    def onboard_new_employee(data: dict) -> Employee:

        new_employee = Employee(**data)
        db.session.add(new_employee)
        db.session.flush()
        
        factory = HRDocumentFactory()
        contract_generator = factory.create_document("contract")
        new_contract = contract_generator.generate(new_employee)
        
        db.session.add(new_contract)
        db.session.commit()
        
        return new_employee