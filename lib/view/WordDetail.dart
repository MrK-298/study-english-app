import 'package:dictionaryx/dictionary_reduced_msa.dart';
import 'package:english/data/partofspeechdata.dart';
import 'package:english/data/token.dart';
import 'package:english/data/word.dart';
import 'package:english/view/listword.dart';
import 'package:english/view/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class WordDetailPage extends StatefulWidget {
  final String word;

  WordDetailPage({required this.word});
  @override
  _WordDetailState createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetailPage>{
  var entry;
  String word = "";
  String pronunciationword = "";
  List<String> pronunciations = [];
  List<PartOfSpeechData> partsOfSpeech = [];
  List<String> definitions = [];
  List<List<String>> synonymsList = [];
  List<List<String>> antonymsList = [];
  List<String> examples = [];
  List<PartOfSpeechData> partOfSpeechDataList = [];
  late FlutterTts _flutterTts;
  late StreamController<String> wordSavedController;
  int userid = 0;
  int wordid = 0;
  String out = "";
  bool isWordSaved = false;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    var dMSAJson = DictionaryReducedMSA();
    entry = dMSAJson.getEntry(widget.word);
    wordSavedController = StreamController<String>.broadcast();
    _flutterTts = FlutterTts();
    resetstatus();
    getWordDetails();
  }
  @override
  void dispose() {
    wordSavedController.close();
    super.dispose();
  }
  //Chức năng đọc từ vựng
   speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(0.8);
    await _flutterTts.speak(text);
  }
  //Chức năng thông báo
   Future<void> showNotification(String message) async {
    wordSavedController.add(message);
    await Future.delayed(Duration(seconds: 3));
    wordSavedController.add(""); // Đóng thông báo sau 3 giây
  }
  //Chức năng giải mã
   Future<void> decodetoken(String Token) async {
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/Auth/DecodeToken?token=$Token'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        userid = int.parse(responseData['userId']);
      });
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }
  //Lưu từ
  Future<void> saveword() async{
    if(TokenManager.getToken()!="")
    {
        if (userid == 0) {
          print('Token không hợp lệ hoặc không có thông tin user');
          return;
        }
        final Map<String, dynamic> data = {
        'word': word,
        'definition': out,
        'userId': userid, 
        'phonetic': pronunciationword,
      };
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/ManagerWord/SaveWord'),
      body: jsonEncode(data), 
      headers: {
        'Content-Type':
            'application/json', 
      },
    );
    if (response.statusCode == 200){
      Map<String, dynamic> data = json.decode(response.body);       
        showNotification("Từ đã được lưu thành công");
        setState(() {
           wordid = data['id'];
           isWordSaved = true;
        });
    }
    else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
    }
    else
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bạn muốn lưu từ vựng vào danh sách?'),
            content: Text('Bạn phải đăng nhập mới sử dụng được chức năng này'),
            actions: <Widget>[
              TextButton(
                child: Text('Quay lại', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                },
              ),
              TextButton(
                child: Text('Có', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage(word: widget.word,)));
                },
              ),
            ],
          );
        },
      );
    }
  }
  //Bỏ lưu từ
  Future<void> unsaveword() async{
     final response = await http.delete(
      Uri.parse('https://10.0.2.2:7142/api/ManagerWord/UnSaveWord?id=$wordid'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
     if (response.statusCode == 200){
        showNotification("Đã xóa từ khỏi danh sách đã lưu");
        setState(() {
           isWordSaved = false;
        });
    }
    else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }
  //Translate chuỗi
  Future<String> translatetext(String text) async {
    final response = await http.get(
      Uri.parse('https://api.mymemory.translated.net/get?q=$text&langpair=en|vi'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('responseData')) {
        return data['responseData']['translatedText'];
      }
    }
    return '';
  }
  //Translate từ
  void translateword(String Word) async {
    String translatedText = await translatetext(Word);
    setState(() {
      out = translatedText;
    });
  }
  //Lấy danh sách từ
  Future<void> getAllWords() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7142/api/ManagerWord/GetAllWords'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
       final List<dynamic> wordData = json.decode(response.body);
        List<Word> words = [];
        words = wordData.map((data) => Word.fromJson(data)).toList();
          for (var wordsave in words){
        if (wordsave.word == widget.word && wordsave.userId == userid) {
            setState(() {
              wordid = wordsave.id;
              isWordSaved = true;
            });
          }
        }
      } else {
        print("Error: ${response.statusCode}");
        print(response.body);
      }
    }
  //danh sách từ đã lưu
  void resetstatus() async{
    if(TokenManager.getToken()!="")
    {
      final out2 = await decodetoken(TokenManager.getToken());
    }
  }
  //Lấy chi tiết từ
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
      setState(()  {
        word = data[0]['word'];       
        pronunciationword = data[0]['phonetic'].toString();
        translateword(word);
        getAllWords();
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
          title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [ 
            SizedBox(width: 0),
            Text('$word'),
            
            IconButton(
              icon: Icon(
                isWordSaved ? Icons.star : Icons.star_border,
                color: Colors.yellow,
              ),
              onPressed: () {              
                if (isWordSaved==false) {
                  saveword();
                } else {
                  unsaveword();
                }
              },
            ),
          ],
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
                    title: Text('$word\t:\t$out', style: TextStyle(fontSize: 20)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pronunciations
                          .map((pronunciation) => Text('$pronunciation'))
                          .toList(),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.volume_up),
                      onPressed: () {
                        speak(word);
                      },
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
                                FutureBuilder<String>(
                                  future:
                                      translatetext(definitionData.definition),
                                      builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      // Hiển thị Text khi Future hoàn thành
                                      return Text(
                                        'Định nghĩa: ${definitionData.definition}\n(${snapshot.data})',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      );
                                    } else {
                                      // Hiển thị một Widget khác trong quá trình loading
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
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
                  StreamBuilder<String>(
                    stream: wordSavedController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // Hiển thị thông báo
                        return Text(snapshot.data!);
                      } else {
                        return Container();
                      }
                    },
                  ),
              ],
            ),
          )),
        bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Home',
            backgroundColor: Colors.pink,
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Thống kê',
            backgroundColor: Colors.pink,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài Khoản',
            backgroundColor: Colors.cyanAccent,
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ListWordPage()));
          }
        }
        ),
    );
  }
}
