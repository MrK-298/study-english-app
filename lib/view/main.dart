import 'dart:io';
import 'package:english/data/token.dart';
import 'package:english/data/topic.dart';
import 'package:english/view/account/login.dart';
import 'package:english/view/homework/homework_screen.dart';
import 'package:english/view/word/WordDetail.dart';
import 'package:english/view/account/profile.dart';
import 'package:english/view/word/listword.dart';
import 'package:flutter/material.dart';
import 'package:english/sdk/DictReduceSA.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(
    MaterialApp(
      home: MapSample(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final DictReducedSA dict = DictReducedSA();
  int _currentIndex = 0;
  bool shouldShowButton = false;
  List<Topic> topics = [];
  TextEditingController textEditing = new TextEditingController();
  @override
  void initState() {
    super.initState();
    if (TokenManager.getToken() != "") {
      shouldShowButton = true;
    }
    getAllTopics();
  }
  Future<void> getAllTopics() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7142/api/Topic/GetAllTopics'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> topicData = json.decode(response.body);
      setState(() {
        topics = topicData.map((data) => Topic.fromJson(data)).toList();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/logo.png', // Đường dẫn của ảnh
                height: 28, // Chiều cao của ảnh
                width: 28, // Chiều rộng của ảnh
              ),
              SizedBox(width: 80), // Khoảng trắng giữa ảnh và tiêu đề
              Text(
                'Study English',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 80), // Khoảng trắng giữa tiêu đề và icon
              Icon(
                Icons.facebook, // Thay đổi biểu tượng theo ý muốn
                color: Colors.white,
              ),
            ],
          ),
        ),
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6), // Điều chỉnh padding
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.0), // Điều chỉnh borderRadius
                    ),
                    child: Autocomplete<String>(
                      optionsBuilder: (textEditing) {
                        if (textEditing.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return dict.words.where((String item) {
                          return item.contains(textEditing.text.toLowerCase());
                        });
                      },
                      onSelected: (String selectedItem) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordDetailPage(word: selectedItem),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text(
                        'Chủ đề học tập',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ];
            },
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(topics[index].title),
                      subtitle: Text(topics[index].content),
                      onTap: () {
                        if(TokenManager.getToken()=="")
                        {
                         showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Bạn muốn xem những chủ đề học tập?'),
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
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LoginPage(
                                                    word: "fake",
                                                  )));
                                    },
                                  ),
                                ],
                              );
                            },
                          );                       
                        }
                        else{
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTopicPage(topicId: topics[index].id),
                          ),
                        );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        bottomNavigationBar: shouldShowButton
            ? BottomNavigationBar(
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MapSample()));
                  }
                  if (index == 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListWordPage()));
                  }
                  if (index == 2) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  }
                },
              )
            : null,
      ),
    );
  }
}
