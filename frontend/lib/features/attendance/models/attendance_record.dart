class AttendanceRecord {
  final int id;
  final String employeeName;
  final String date;
  final String clockIn;
  final String clockOut;

  AttendanceRecord({
    required this.id,
    required this.employeeName,
    required this.date,
    required this.clockIn,
    required this.clockOut,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0,
      employeeName: json['employee_name'] ?? json['full_name'] ?? 'Невідомо',
      date: json['date'] ?? '',
      clockIn: json['clock_in'] ?? '--:--',
      clockOut: json['clock_out'] ?? '--:--',
    );
  }
}

class WorkSchedule {
  final int id;
  final int employeeId;
  final String employeeName;
  final String position;
  final String workDays;
  final String startTime;
  final String endTime;
  final String shiftType;

  WorkSchedule({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.position,
    required this.workDays,
    required this.startTime,
    required this.endTime,
    required this.shiftType,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      employeeName: json['employee_name'] ?? 'Невідомо',
      position: json['position'] ?? '',
      workDays: json['work_days'] ?? 'Пн-Пт',
      startTime: json['start_time'] ?? '09:00',
      endTime: json['end_time'] ?? '18:00',
      shiftType: json['shift_type'] ?? 'Офіс',
    );
  }
}