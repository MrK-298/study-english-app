import 'dart:io';
import 'package:english/data/token.dart';
import 'package:english/view/WordDetail.dart';
import 'package:english/view/account/profile.dart';
import 'package:english/view/listword.dart';
import 'package:flutter/material.dart';
import 'package:english/sdk/DictReduceSA.dart';

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
  TextEditingController textEditing = new TextEditingController();
  @override
  void initState() {
    super.initState();
    if (TokenManager.getToken() != "") {
      shouldShowButton = true;
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Màu xám
                    borderRadius: BorderRadius.circular(8.0),
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
                          builder: (context) =>
                              WordDetailPage(word: selectedItem),
                        ),
                      );
                    },
                  ),
                ),
                //-------------
                SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      'Trắc nghiệm',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Exam 1'),
                    subtitle: Text('Ngữ pháp'),
                    trailing: IconButton(
                      icon: Icon(Icons.create),
                      onPressed: () {
                        // Xử lý khi nút được nhấn
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Exam 2'),
                    subtitle: Text('Mệnh đề quan hệ'),
                    trailing: IconButton(
                      icon: Icon(Icons.create),
                      onPressed: () {
                        // Xử lý khi nút được nhấn
                      },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Exam 3'),
                    subtitle: Text('Câu bị động'),
                    trailing: IconButton(
                      icon: Icon(Icons.create),
                      onPressed: () {
                        // Xử lý khi nút được nhấn
                      },
                    ),
                    leading: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'option1',
                          child: Row(
                            children: [
                              Icon(Icons.timer),
                              SizedBox(width: 8),
                              Text('10 phút'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'option2',
                          child: Row(
                            children: [
                              Icon(Icons.timer),
                              SizedBox(width: 8),
                              Text('20 phút'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'option3',
                          child: Row(
                            children: [
                              Icon(Icons.timer),
                              SizedBox(width: 8),
                              Text('30 phút'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (String value) {
                        // Xử lý khi lựa chọn được thực hiện
                        print('Selected: $value');
                      },
                    ),
                  ),
                ),

                //----------
              ],
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
