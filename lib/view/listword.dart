import 'package:english/data/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:english/data/word.dart';
import 'package:flutter_tts/flutter_tts.dart';
class ListWordPage extends StatefulWidget {
  @override
  _ListWordState createState() => _ListWordState();
}

class _ListWordState extends State<ListWordPage>{
  late Future<List<Word>> futureWords;
  int userid = 0;
  late FlutterTts _flutterTts;
  @override
  void initState() {
    super.initState();
    getuser();
    futureWords = getWordsByUserId();
    _flutterTts = FlutterTts();
  }
  speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(0.8);
    await _flutterTts.speak(text);
  }
  void getuser() async{
    if(TokenManager.getToken()!="")
    {
      final out = await decodetoken(TokenManager.getToken());
    }
  }
  //Lấy danh sách từ
  Future<List<Word>> getWordsByUserId() async {
  final response = await http.get(Uri.parse('https://10.0.2.2:7142/api/ManagerWord/GetAllWords'));
  
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    
    // Lọc danh sách từ theo userId
    List<Word> words = data
        .where((word) => word['userId'] == userid)
        .map((word) => Word.fromJson(word))
        .toList();

    return words;
    } else {
      throw Exception('Failed to load words');
    }
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
            Text('Từ của bạn'),
          ],
        ),
      ),
        body: Column(
        children: [
           Expanded(
            child: FutureBuilder<List<Word>>(
        future: futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Không có từ nào được tìm thấy.');
          } else {
            // Hiển thị danh sách từ bằng ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
               return Card(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(snapshot.data![index].word,style: TextStyle(fontSize: 20)),
                  subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data![index].phonetic,
                        style: TextStyle(fontSize: 15)),
                    Text(snapshot.data![index].definition, style: TextStyle(fontSize: 15)),
                            ],                    
                          ),
                   trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Đảm bảo rằng chiều ngang của Row chỉ lớn nhất cần thiết
                    children: [
                    IconButton(
                        icon: Icon(Icons.volume_up),
                            onPressed: () {
                              speak(snapshot.data![index].word);
                            },
                          ),
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                            child: Row(
                              children: [
                                  Icon(Icons.delete),
                                  SizedBox(width: 8),
                                  Text("Xóa từ"),
                                  ],
                                ),
                         ),
                        PopupMenuItem(
                            value: 2,
                            child: Row(
                            children: [
                            Icon(Icons.info),
                            SizedBox(width: 8),
                            Text("Chi tiết từ"),
                             ],
                            ),
                           ),
                        ],
                      onSelected: (value) {
                        if (value == 1) {
                          // Xử lý chức năng xóa từ
                          } else if (value == 2) {
                          // Xử lý chức năng chuyển đến chi tiết từ
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        );
                      },
                    );
                  }
                },
              ),
            )
          ]
        ),
    );
  }
}