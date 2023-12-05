import 'package:dictionaryx/dictionary_reduced_msa.dart';
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
  String word ="";
  String pronunciation = "";
  List<String> pronunciations = [];
  List<String> partsOfSpeech = [];
  List<String> definitions = [];
  List<List<String>> synonymsList = [];
  List<List<String>> antonymsList = [];
  List<String> examples = [];
  @override
  void initState() {
    super.initState();
    var dMSAJson = DictionaryReducedMSA();
    entry = dMSAJson.getEntry(widget.word);
    getWordDetails();
  }
  Future<void> getWordDetails() async {
    final response = await http.get(
    Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/${widget.word}'),
    headers: {
      'Content-Type': 'application/json',
    },
);


    if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
        word = data[0]['word'];
        
        for (var meaning in data[0]['meanings']) {
        // Kiểm tra xem có trường 'phonetics' không
        if (meaning.containsKey('phonetics')) {
          var phonetics = meaning['phonetics'];
          // Kiểm tra xem 'phonetics' có phải là mảng không rỗng không
          if (phonetics is List && phonetics.isNotEmpty) {
            // Kiểm tra xem có trường 'text' trong 'phonetics[0]' không
            var firstPhonetic = phonetics[0];
            if (firstPhonetic is Map && firstPhonetic.containsKey('text')) {
              pronunciations.add(firstPhonetic['text']);
            }
          }
        }

        partsOfSpeech.add(meaning['partOfSpeech']);
        // Kiểm tra và thêm 'synonyms' nếu nó không phải là null
        if (meaning.containsKey('synonyms')) {
          var synonyms = meaning['synonyms'];
          if (synonyms is List) {
            if (synonyms.isNotEmpty) {
              synonymsList.add(List<String>.from(synonyms));
            }
          }
        }

        // Kiểm tra và thêm 'antonyms' nếu nó không phải là null
        if (meaning.containsKey('antonyms')) {
          var antonyms = meaning['antonyms'];
          if (antonyms is List) {
            if (antonyms.isNotEmpty) {
              antonymsList.add(List<String>.from(antonyms));
            }
          }
        }

        // Lặp qua mỗi định nghĩa của từ
        for (var definition in meaning['definitions']) {
          // In ra mỗi định nghĩa
          definitions.add(definition['definition']);
          // Kiểm tra và thêm 'synonyms' nếu nó không phải là null
            if (definition.containsKey('synonyms')) {
              var synonyms = definition['synonyms'];
              if (synonyms is List) {
                if (synonyms.isNotEmpty) {
                  synonymsList.add(List<String>.from(synonyms));
                }
              }
            }
            if (definition.containsKey('antonyms')) {
              // Kiểm tra xem 'antonyms' có phải là List không
              var antonyms = definition['antonyms'];
              if (antonyms is List) {
                // Kiểm tra xem 'antonyms' có phần tử không
                if (antonyms.isNotEmpty) {
                  // Thêm danh sách 'antonyms' vào 'antonymsList'
                  antonymsList.add(List<String>.from(antonyms));
                }
              }
            }

           if (definition.containsKey('example') && definition['example'] != null) {
            examples.add(definition['example']);
          }
        }
        }
      });
  }
    else {
     debugPrint("Error: ${response.statusCode}");
     debugPrint("Response body: ${response.body}");
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon:Icon(Icons.arrow_back_ios),
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
            title: Text('Phát âm:', style: TextStyle(fontSize: 20)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pronunciations.map((pronunciation) => Text('- $pronunciation')).toList(),
            ),
          ),
          ListTile(
            title: Text('Loại từ:', style: TextStyle(fontSize: 20)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: partsOfSpeech.map((partOfSpeech) => Text('- $partOfSpeech')).toList(),
            ),
          ),
          ListTile(
            title: Text('Nghĩa:', style: TextStyle(fontSize: 20)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: definitions.map((definition) => Text('- $definition')).toList(),
            ),
          ),
          ListTile(
            title: Text('Đồng nghĩa:', style: TextStyle(fontSize: 20)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: synonymsList.expand((synonyms) => synonyms.map((synonym) => Text('- $synonym'))).toList(),
            ),
          ),
          ListTile(
            title: Text('Trái nghĩa:', style: TextStyle(fontSize: 20)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: antonymsList.expand((antonyms) => antonyms.map((antonym) => Text('- $antonym'))).toList(),
            ),
          ),
            ListTile(
              title: Text('Ví dụ:', style: TextStyle(fontSize: 20)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: examples.map((example) => Text('- $example')).toList(),
              ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}