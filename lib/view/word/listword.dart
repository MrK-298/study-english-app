import 'package:english/data/token.dart';
import 'package:english/view/word/WordDetail.dart';
import 'package:english/view/account/profile.dart';
import 'package:english/view/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:english/data/word.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class ListWordPage extends StatefulWidget {
  @override
  _ListWordState createState() => _ListWordState();
}

class _ListWordState extends State<ListWordPage> {
  late StreamController<String> wordSavedController;
  late Future<List<Word>> futureWords;
  int userid = 0;
  late FlutterTts _flutterTts;
  int _currentIndex = 1;
  @override
  void initState() {
    super.initState();
    getuser();
    futureWords = getWordsByUserId();
    wordSavedController = StreamController<String>.broadcast();
    _flutterTts = FlutterTts();
  }

  speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(0.8);
    await _flutterTts.speak(text);
  }

  void getuser() async {
    if (TokenManager.getToken() != "") {
      final out = await decodetoken(TokenManager.getToken());
    }
  }

  //Chức năng thông báo
  Future<void> showNotification(String message) async {
    wordSavedController.add(message);
    await Future.delayed(Duration(seconds: 3));
    wordSavedController.add(""); // Đóng thông báo sau 3 giây
  }

  //Chức năng xóa từ
  Future<void> unsaveword(int wordid) async {
    final response = await http.delete(
      Uri.parse('https://10.0.2.2:7142/api/ManagerWord/UnSaveWord?id=$wordid'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      showNotification("Đã xóa từ khỏi danh sách đã lưu");
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

  //Lấy danh sách từ
  Future<List<Word>> getWordsByUserId() async {
    final response = await http
        .get(Uri.parse('https://10.0.2.2:7142/api/ManagerWord/GetAllWords'));

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
      body: Column(children: [
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WordDetailPage(
                              word: snapshot.data![index].word,
                            ),
                          ),
                        );
                      },
                      leading: Icon(
                        Icons.bookmark,
                        color: Colors.orangeAccent,
                      ),
                      title: Text(snapshot.data![index].word,
                          style: TextStyle(fontSize: 20)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.data![index].phonetic,
                              style: TextStyle(fontSize: 15)),
                          Text(snapshot.data![index].definition,
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Đảm bảo rằng chiều ngang của Row chỉ lớn nhất cần thiết
                        children: [
                          IconButton(
                            icon: Icon(Icons.volume_up),
                            color: Colors.blueAccent,
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
                            onSelected: (value) async {
                              if (value == 1) {
                                int wordId = snapshot.data![index].id;
                                setState(() {
                                  snapshot.data!.removeAt(index);
                                });
                                await unsaveword(wordId);
                              } else if (value == 2) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WordDetailPage(
                                            word: snapshot.data![index].word)));
                              }
                            },
                          ),
                        ],
                      ),
                    ));
                  },
                );
              }
            },
          ),
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
      ]),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
            backgroundColor: Colors.pink,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Danh sách từ',
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
                context, MaterialPageRoute(builder: (context) => MapSample()));
          }
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ListWordPage()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          }
        },
      ),
    );
  }
}
