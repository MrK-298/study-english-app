import 'package:english/data/homework.dart';
import 'package:english/data/token.dart';
import 'package:english/view/quiz/quiz_screen.dart';
import 'package:english/view/quiz/seeresult.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailTopicPage extends StatefulWidget {
  final int topicId;

  DetailTopicPage({required this.topicId});
  @override
  _DetailTopicPageState createState() => _DetailTopicPageState();
}

class _DetailTopicPageState extends State<DetailTopicPage> {
  List<Homework> homeworks = [];
  List<Homework> userHomeworks = [];
  String content = "";
  String title = "";
  int userId = 0;
  @override
  void initState() {
    super.initState();
    decodetoken(TokenManager.getToken());
    getAllHomeworks();
    getTopic();
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
        userId = int.parse(responseData['userId']);
      });
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

  Future<void> getAllHomeworks() async {
    final response = await http.get(
      Uri.parse(
          'https://10.0.2.2:7142/api/Topic/GetHomework?id=${widget.topicId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> homeworksData = json.decode(response.body);
      homeworks = homeworksData.map((data) => Homework.fromJson(data)).toList();
      await getHomeworksByUserId();
      setState(() {
        for (var homework in homeworks) {
          var userHomework = userHomeworks.firstWhere(
            (userHomework) => userHomework.id == homework.id,
            orElse: () => homework,
          );
          if (userHomework != homework) {
            homework.isDone = true;
            homework.score = userHomework.score;
          }
        }
      });
    }
  }

  Future<void> getHomeworksByUserId() async {
    final response = await http.get(
      Uri.parse(
          'https://10.0.2.2:7142/api/Homework/GetUserHomeworks?userId=$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> userHomeworksData = json.decode(response.body);
      userHomeworks =
          userHomeworksData.map((data) => Homework.fromJson(data)).toList();
    }
  }

  Future<void> getTopic() async {
    final response = await http.get(
      Uri.parse(
          'https://10.0.2.2:7142/api/Topic/GetTopicWithId?id=${widget.topicId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        title = data['title'];
        content = data['content'];
      });
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
              Text('$title'),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(25.25),
              child: Text(
                '$content',
                style: TextStyle(fontSize: 20),
                // textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Text('Bài tập', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: homeworks.length,
                itemBuilder: (context, index) {
                  final homework = homeworks[index];
                  Color cardColor;

                  // Xác định màu sắc dựa trên score và isDone
                  if (homework.isDone == false) {
                    cardColor = Colors.white;
                  } else if (homework.score < 5) {
                    cardColor =
                        Color.fromARGB(255, 204, 87, 87); // Đỏ nếu score < 5
                  } else if (homework.score < 8) {
                    cardColor = Color.fromARGB(
                        255, 201, 190, 94); // Vàng nếu 5 <= score < 8
                  } else {
                    cardColor = Color.fromARGB(
                        255, 121, 210, 142); // Xanh lá nếu score >= 8
                  }

                  return Card(
                    color: cardColor,
                    elevation: 3, // Độ nâng của Card
                    margin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16), // Khoảng cách giữa các Card
                    child: ListTile(
                      title: Text(homework.title),
                      onTap: () {
                        if (homework.isDone == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizzScreen(
                                topicId: widget.topicId,
                                homeworkId: homework.id,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeeResultScreen(
                                topicId: widget.topicId,
                                homeworkId: homework.id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
