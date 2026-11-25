class Candidate {
  final int id;
  final String fullName;
  final String resumeUrl;
  final String status;
  final int? vacancyId;

  Candidate({
    required this.id,
    required this.fullName,
    required this.resumeUrl,
    required this.status,
    this.vacancyId,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 'Невідомо',
      resumeUrl: json['resume_url'] ?? '',
      status: json['status'] ?? 'new',
      vacancyId: json['vacancy_id'],
    );
  }
}

class Vacancy {
  final int id;
  final String title;
  final String salaryRange;
  final String description;
  final String status;

  Vacancy({
    required this.id,
    required this.title,
    required this.salaryRange,
    required this.description,
    required this.status,
  });

  factory Vacancy.fromJson(Map<String, dynamic> json) {
    return Vacancy(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Без назви',
      salaryRange: json['salary_range'] ?? 'За домовленістю',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
    );
  }
}