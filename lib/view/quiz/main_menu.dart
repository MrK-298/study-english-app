import 'package:english/data/homework.dart';
import 'package:english/view/quiz/quiz_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english/color/color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class MainMenu extends StatefulWidget {
  final int topicId;
  final int homeworkId;
  MainMenu({required this.topicId,required this.homeworkId});
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<Homework> homeworks = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    @override
    void initState() {
      super.initState();
      getAllHomeworks();
    }
  Future<void> getAllHomeworks() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7142/api/Topic/GetHomework?id=${widget.topicId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> homeworksData = json.decode(response.body);
      setState(() {
          homeworks = homeworksData.map((data) => Homework.fromJson(data)).toList();    
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Quizz app'),       
      ),
      drawer: Drawer(
      backgroundColor: Color.fromARGB(255, 121, 210, 142) ,
      shadowColor: Colors.white,
      child: ListView.builder(
        itemCount: homeworks.length,
        itemBuilder: (context, index) {
          final homework = homeworks[index];
          return ListTile(
            title: Text(homework.title),
            onTap: () {
              Navigator.pop(context);
            },
          );
        },
      ),
    ),
      backgroundColor: AppColor.pripmaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 48.0,
          horizontal: 12.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [          
            Expanded(
              child: Center(
                child: RawMaterialButton(
                  onPressed: () {
                    //Navigating the the Quizz Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizzScreen(homeworkId: widget.homeworkId,),
                        ));
                  },
                  shape: const StadiumBorder(),
                  fillColor: AppColor.secondaryColor,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Text(
                      "Start the Quizz",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Center(
              child: Text(
                "Made with ❤ by HeartSteel",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}