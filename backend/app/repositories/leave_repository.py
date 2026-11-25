from abc import ABC, abstractmethod
from typing import List
from app import db
from app.models.models import LeaveRequest

class ILeaveRepository(ABC):
    @abstractmethod
    def save(self, req: LeaveRequest) -> bool:
        pass

    @abstractmethod
    def getByEmployeeId(self, emp_id: int) -> List[LeaveRequest]:
        pass

class SQLLeaveRepository(ILeaveRepository):
    def __init__(self, db_session=None):
        self._dbSession = db_session or db.session

    def save(self, req: LeaveRequest) -> bool:
        try:
            self._dbSession.add(req)
            self._dbSession.commit()
            return True
        except Exception:
            self._dbSession.rollback()
            return False

    def getByEmployeeId(self, emp_id: int) -> List[LeaveRequest]:
        return LeaveRequest.query.filter_by(employee_id=emp_id).all()