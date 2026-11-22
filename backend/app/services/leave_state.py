from abc import ABC, abstractmethod
from typing import List
from app.models.models import LeaveRequest
from app.repositories.leave_repository import SQLLeaveRepository
from app.services.observers import ILeaveObserver


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
    def __init__(self, request_model: LeaveRequest, repo=None):
        self.request = request_model
        self.state = self._get_state_object()
        self.repo = repo or SQLLeaveRepository()
        self._observers: List[ILeaveObserver] = []

    def attach(self, observer: ILeaveObserver):
        if observer not in self._observers:
            self._observers.append(observer)

    def detach(self, observer: ILeaveObserver):
        if observer in self._observers:
            self._observers.remove(observer)

    def _notify(self, event: str):
        for observer in self._observers:
            observer.update(self.request, event)

    def _get_state_object(self) -> ILeaveState:
        if self.request.status == "pending":
            return PendingState()
        elif self.request.status == "approved":
            return ApprovedState()
        return PendingState()

    def approve(self):
        self.state.process(self.request)
        self.repo.save(self.request)
        self._notify("approved")

    def reject(self):
        self.request.status = "rejected"
        self.repo.save(self.request)
        self._notify("rejected")