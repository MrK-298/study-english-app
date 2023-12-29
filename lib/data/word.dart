class Word{
  final int id;
  final String word;
  final int userId;
  Word({
    required this.id,
    required this.word,
    required this.userId,
  });
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(     
      userId: json['userId'],
      word: json['word'],
      id: json['id'],
    );
  }
}