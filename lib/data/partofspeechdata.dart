class PartOfSpeechData {
  String partOfSpeech;
  List<DefinitionData> definitions;

  PartOfSpeechData({
    required this.partOfSpeech,
    required this.definitions,
  });
}

class DefinitionData {
  String definition;
  List<String> synonyms;
  List<String> antonyms;
  String example;

  DefinitionData({
    required this.definition,
    required this.synonyms,
    required this.antonyms,
    required this.example,
  });
}
