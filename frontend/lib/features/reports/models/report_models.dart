class DepartmentReport {
  final String department;
  final int totalEmployees;
  final double totalBudget;

  DepartmentReport({
    required this.department,
    required this.totalEmployees,
    required this.totalBudget,
  });

  factory DepartmentReport.fromJson(Map<String, dynamic> json) {
    return DepartmentReport(
      department: json['department_name'] ?? 'Невідомо',
      totalEmployees: json['headcount'] ?? 0,
      totalBudget: (json['total_budget'] ?? 0).toDouble(),
    );
  }
}
