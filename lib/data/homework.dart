class Homework{
  final int id;
  final String title;
  int score = 0;
  bool isDone;
  Homework({
    required this.id,
    required this.title,
    required this.score,
    required this.isDone,
  });
  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(     
      title: json['title'],
      score: json['score'] ?? 0,
      id: json['id'],
      isDone: json['isDone'] ?? false,
    );
  }
}