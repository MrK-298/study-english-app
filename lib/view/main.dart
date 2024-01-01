import 'dart:io';
import 'package:english/data/token.dart';
import 'package:english/view/quiz/quiz_screen.dart';
import 'package:english/view/word/WordDetail.dart';
import 'package:english/view/account/profile.dart';
import 'package:english/view/word/listword.dart';
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
          title: Text('Stydy English'),
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
