class Gradle {

  int? id;
  final String subject;
  final String phase;
  final double value;

  Gradle({this.id, required this.subject, required this.phase, required this.value});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'phase': phase,
      'value': value,
    };
  }

}