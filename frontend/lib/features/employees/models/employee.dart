class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String position;
  final String role;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.position,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      position: json['position'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}