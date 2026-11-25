from abc import ABC, abstractmethod
from datetime import datetime
from app.models.models import LeaveRequest


class ILeaveObserver(ABC):
    @abstractmethod
    def update(self, leave_request: LeaveRequest, event: str):
        pass


class EmailNotificationObserver(ILeaveObserver):
    def update(self, leave_request: LeaveRequest, event: str):
        emp = leave_request.employee
        recipient = emp.email if emp else f"employee_id={leave_request.employee_id}"
        print(
            f"[EMAIL OBSERVER] To: {recipient} | "
            f"Вашу заявку на відпустку #{leave_request.id} "
            f"({leave_request.start_date} – {leave_request.end_date}) "
            f"переведено у статус: {event.upper()}"
        )


class AuditLogObserver(ILeaveObserver):
    def update(self, leave_request: LeaveRequest, event: str):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(
            f"[AUDIT OBSERVER] [{timestamp}] "
            f"LeaveRequest #{leave_request.id} (Employee #{leave_request.employee_id}) "
            f"-> status changed to '{event}'"
        )