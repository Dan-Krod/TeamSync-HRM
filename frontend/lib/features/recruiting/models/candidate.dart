class Candidate {
  final int id;
  final String fullName;
  final String status;
  final String resumeUrl;

  Candidate({
    required this.id,
    required this.fullName,
    required this.status,
    required this.resumeUrl,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      status: json['status'] ?? 'pending',
      resumeUrl: json['resume_url'] ?? '',
    );
  }
}