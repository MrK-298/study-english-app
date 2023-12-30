class Word{
  final int id;
  final String word;
  final int userId;
  final String definition;
  final String phonetic;
  Word({
    required this.id,
    required this.word,
    required this.userId,
    required this.definition,
    required this.phonetic
  });
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(     
      userId: json['userId'],
      word: json['word'],
      id: json['id'],
      definition: json['definition'],
      phonetic: json['phonetic']
    );
  }
}