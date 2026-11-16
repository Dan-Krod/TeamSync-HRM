from abc import ABC, abstractmethod
from app.models.models import Employee

class IPayrollStrategy(ABC):
    @abstractmethod
    def calculate(self, employee: Employee) -> float:
        pass

class FullTimeStrategy(IPayrollStrategy):
    def calculate(self, employee: Employee) -> float:
        return employee.salary * 0.80

class HourlyStrategy(IPayrollStrategy):
    def calculate(self, employee: Employee) -> float:
        return (employee.salary * 160) * 0.95

class PayrollService:
    def __init__(self, strategy: IPayrollStrategy):
        self.strategy = strategy

    def set_strategy(self, strategy: IPayrollStrategy):
        self.strategy = strategy

    def calculate_salary(self, employee: Employee) -> float:
        return self.strategy.calculate(employee)