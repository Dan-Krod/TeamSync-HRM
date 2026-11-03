class Candidate {
  final int id;
  final String fullName;
  final String resumeUrl;
  final String status;

  Candidate({
    required this.id,
    required this.fullName,
    required this.resumeUrl,
    required this.status,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 'Невідомо',
      resumeUrl: json['resume_url'] ?? '',
      status: json['status'] ?? 'new',
    );
  }
}
