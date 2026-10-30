from abc import ABC, abstractmethod
from app.models.models import Employee, Department

class IOrganizationUnit(ABC):
    @abstractmethod
    def get_headcount(self) -> int:
        pass

    @abstractmethod
    def get_budget(self) -> float:
        pass

class EmployeeLeaf(IOrganizationUnit):
    def __init__(self, employee: Employee):
        self.employee = employee

    def get_headcount(self) -> int:
        return 1

    def get_budget(self) -> float:
        return self.employee.salary

class DepartmentComposite(IOrganizationUnit):
    def __init__(self, department_name: str):
        self.name = department_name
        self._units = []

    def add(self, unit: IOrganizationUnit):
        self._units.append(unit)

    def get_headcount(self) -> int:
        return sum(unit.get_headcount() for unit in self._units)

    def get_budget(self) -> float:
        return sum(unit.get_budget() for unit in self._units)
        
    def generate_report(self) -> dict:
        return {
            "department_name": self.name,
            "headcount": self.get_headcount(),
            "total_budget": self.get_budget()
        }