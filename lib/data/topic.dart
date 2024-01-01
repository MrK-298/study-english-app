class Topic{
  final int id;
  final String title;
  final String content;
  Topic({
    required this.id,
    required this.title,
    required this.content
  });
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(     
      title: json['title'],
      content: json['content'],
      id: json['id'],
    );
  }
}