import 'dart:io';
import 'package:english/WordDetail.dart';
import 'package:flutter/material.dart';
import 'package:english/sdk/DictReduceSA.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(
    MaterialApp(
      home: MapSample(), // Đây là trang chạy đầu tiên
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Stydy English'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditing) {
                    if (textEditing.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return dict.words.where((String item) {
                      return item.contains(textEditing.text.toLowerCase());
                    });
                  },
                  onSelected: (String selectedItem) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WordDetailPage(word: selectedItem)));
                  },
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
