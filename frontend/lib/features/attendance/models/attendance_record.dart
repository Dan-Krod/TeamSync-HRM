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