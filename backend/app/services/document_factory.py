from abc import ABC, abstractmethod
from app.models.models import Employee, Document
import uuid

class IDocument(ABC):
    @abstractmethod
    def generate(self, employee: Employee) -> Document:
        pass

class ContractDocument(IDocument):
    def generate(self, employee: Employee) -> Document:
        file_name = f"contract_{employee.id}_{uuid.uuid4().hex[:6]}.pdf"
        return Document(
            employee_id=employee.id,
            doc_type="contract",
            file_path=f"/storage/contracts/{file_name}"
        )

class DocumentFactory(ABC):
    @abstractmethod
    def create_document(self, doc_type: str) -> IDocument:
        pass

class HRDocumentFactory(DocumentFactory):
    def create_document(self, doc_type: str) -> IDocument:
        if doc_type == "contract":
            return ContractDocument()
        raise ValueError(f"Невідомий тип документу: {doc_type}")