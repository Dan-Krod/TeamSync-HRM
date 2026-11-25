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

class MonthlyLeaveStat {
  final String month;
  final int vacation;
  final int sick;
  final int businessTrip;

  MonthlyLeaveStat({
    required this.month,
    required this.vacation,
    required this.sick,
    required this.businessTrip,
  });

  factory MonthlyLeaveStat.fromJson(Map<String, dynamic> json) {
    return MonthlyLeaveStat(
      month: json['month'] ?? '',
      vacation: json['vacation'] ?? 0,
      sick: json['sick'] ?? 0,
      businessTrip: json['business_trip'] ?? 0,
    );
  }
}