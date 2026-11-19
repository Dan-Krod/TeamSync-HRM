from abc import ABC, abstractmethod
from app import db
from app.models.models import Document

class IDocumentRepository(ABC):
    @abstractmethod
    def save(self, doc: Document) -> bool:
        pass

class SQLDocumentRepository(IDocumentRepository):
    def __init__(self, db_session=None):
        self._dbSession = db_session or db.session

    def save(self, doc: Document) -> bool:
        try:
            self._dbSession.add(doc)
            self._dbSession.commit()
            return True
        except Exception:
            self._dbSession.rollback()
            return False