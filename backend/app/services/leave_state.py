from abc import ABC, abstractmethod
from app.models.models import LeaveRequest
from app import db

class ILeaveState(ABC):
    @abstractmethod
    def process(self, request: LeaveRequest):
        pass

class PendingState(ILeaveState):
    def process(self, request: LeaveRequest):
        request.status = "approved"

class ApprovedState(ILeaveState):
    def process(self, request: LeaveRequest):
        raise ValueError("Заявка вже погоджена і не може бути оброблена повторно")

class LeaveRequestManager:
    def __init__(self, request_model: LeaveRequest):
        self.request = request_model
        self.state = self._get_state_object()

    def _get_state_object(self) -> ILeaveState:
        if self.request.status == "pending":
            return PendingState()
        elif self.request.status == "approved":
            return ApprovedState()
        return PendingState()

    def approve(self):
        self.state.process(self.request)
        db.session.commit()