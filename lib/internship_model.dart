class Internship {
  final int id;
  final String title;
  final String companyName;
  final String companyLogo;
  final String profileName;
  final String startDate;
  final String duration;
  final String stipend;
  final String applicationDeadline;
  final List<String> locationNames;

  Internship({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyLogo,
    required this.profileName,
    required this.startDate,
    required this.duration,
    required this.stipend,
    required this.applicationDeadline,
    required this.locationNames,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'],
      title: json['title'],
      companyName: json['company_name'],
      companyLogo: json['company_logo'],
      profileName: json['profile_name'],
      startDate: json['start_date'],
      duration: json['duration'],
      stipend: json['stipend']['salary'],
      applicationDeadline: json['application_deadline'],
      locationNames: List<String>.from(json['location_names']),
    );
  }
}
