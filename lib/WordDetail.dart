import 'package:dictionaryx/dictionary_reduced_msa.dart';
import 'package:english/data/partofspeechdata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordDetailPage extends StatefulWidget {
  final String word;

  WordDetailPage({required this.word});
  @override
  _WordDetailState createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetailPage> {
  var entry;
  String word = "";
  String pronunciation = "";
  List<String> pronunciations = [];
  List<PartOfSpeechData> partsOfSpeech = [];
  List<String> definitions = [];
  List<List<String>> synonymsList = [];
  List<List<String>> antonymsList = [];
  List<String> examples = [];
  List<PartOfSpeechData> partOfSpeechDataList = [];
  @override
  void initState() {
    super.initState();
    var dMSAJson = DictionaryReducedMSA();
    entry = dMSAJson.getEntry(widget.word);
    getWordDetails();
  }

  Future<void> getWordDetails() async {
    final response = await http.get(
      Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${widget.word}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        word = data[0]['word'];
        pronunciations.add(data[0]['phonetic'].toString());
        for (var meaning in data[0]['meanings']) {
          List<DefinitionData> meaningDefinitions = [];

          for (var definition in meaning['definitions']) {
            List<String> synonyms = definition['synonyms'] != null
                ? List<String>.from(definition['synonyms'])
                : [];
            List<String> antonyms = definition['antonyms'] != null
                ? List<String>.from(definition['antonyms'])
                : [];

            meaningDefinitions.add(DefinitionData(
              definition: definition['definition'],
              synonyms: synonyms,
              antonyms: antonyms,
              example: definition['example'] ?? '',
            ));
          }

          List<String> synonymsAtMeaningLevel = meaning['synonyms'] != null
              ? List<String>.from(meaning['synonyms'])
              : [];
          List<String> antonymsAtMeaningLevel = meaning['antonyms'] != null
              ? List<String>.from(meaning['antonyms'])
              : [];

          meaningDefinitions.add(DefinitionData(
            definition:
                '', // Nếu có synonyms và antonyms ở cấp độ cao hơn, bạn có thể để definition là chuỗi trống hoặc điều gì đó phù hợp
            synonyms: synonymsAtMeaningLevel,
            antonyms: antonymsAtMeaningLevel,
            example: '',
          ));

          partsOfSpeech.add(PartOfSpeechData(
            partOfSpeech: meaning['partOfSpeech'],
            definitions: meaningDefinitions,
          ));
        }
      });
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Text('Word'),
        ),
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text('$word', style: TextStyle(fontSize: 20)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pronunciations
                        .map((pronunciation) => Text('$pronunciation'))
                        .toList(),
                  ),
                ),
                for (var partOfSpeechData in partsOfSpeech)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('Loại từ: ${partOfSpeechData.partOfSpeech}',
                            style: TextStyle(fontSize: 20)),
                      ),
                      for (var definitionData in partOfSpeechData.definitions)
                        ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (definitionData.definition.isNotEmpty)
                                Text(
                                    'Nghĩa: ${definitionData.definition.isNotEmpty ? definitionData.definition : ''}',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black)),
                              if (definitionData.synonyms.isNotEmpty)
                                Text(
                                    '\nTừ đồng nghĩa: ${definitionData.synonyms.join('\t,')}',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black)),
                              if (definitionData.antonyms.isNotEmpty)
                                Text(
                                    '\nTừ trái nghĩa: ${definitionData.antonyms.join('\t,')}',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black)),
                              if (definitionData.example.isNotEmpty)
                                Text('\nVí dụ: ${definitionData.example}',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          )),
    );
  }
}
