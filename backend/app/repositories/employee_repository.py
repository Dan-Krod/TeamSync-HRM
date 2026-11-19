from abc import ABC, abstractmethod
from app import db
from app.models.models import Employee

class IEmployeeRepository(ABC):
    @abstractmethod
    def save(self, emp: Employee) -> bool:
        pass

    @abstractmethod
    def findById(self, id: int) -> Employee:
        pass

class SQLEmployeeRepository(IEmployeeRepository):
    def __init__(self, db_session=None):
        self._dbSession = db_session or db.session

    def save(self, emp: Employee) -> bool:
        try:
            self._dbSession.add(emp)
            self._dbSession.commit()
            return True
        except Exception:
            self._dbSession.rollback()
            return False

    def findById(self, id: int) -> Employee:
        return Employee.query.get(id)