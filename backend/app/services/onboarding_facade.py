from app.models.models import Employee, Document
from app.services.document_factory import HRDocumentFactory
from app.repositories.employee_repository import SQLEmployeeRepository
from app.repositories.document_repository import SQLDocumentRepository

class OnboardingFacade:
    @staticmethod
    def onboard_new_employee(data: dict) -> Employee:
        emp_repo = SQLEmployeeRepository()
        doc_repo = SQLDocumentRepository()

        new_employee = Employee(**data)
        emp_repo.save(new_employee)

        contract_generator = HRDocumentFactory.create_document("contract", new_employee)
        _, filename = contract_generator.generate_pdf()

        new_contract = Document(
            employee_id=new_employee.id,
            doc_type="contract",
            file_path=f"/storage/documents/{new_employee.id}/{filename}"
        )
        doc_repo.save(new_contract)

        return new_employee