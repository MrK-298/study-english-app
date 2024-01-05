import 'package:english/data/homework.dart';
import 'package:english/data/models/question_model.dart';
import 'package:english/view/homework/homework_screen.dart';
import 'package:english/view/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:english/color/color.dart';
import 'package:english/data/question_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class SeeResultScreen extends StatefulWidget {
  final int topicId;
  final int homeworkId;
  SeeResultScreen({required this.topicId,required this.homeworkId});
  @override
  _SeeResultScreenState createState() => _SeeResultScreenState();
}

class _SeeResultScreenState extends State<SeeResultScreen> {
  List<Homework> homeworks = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int question_pos = 0;
  int score = 0;
  int userId = 0;
  bool btnPressed = false;
  PageController? _controller;
  String btnText = "Next Question";
  bool answered = true;
   Map<int, List<QuestionModel>> homeworkQuestionsMap = {
    14: questions,
    15: questions1,
    16: questions2,
  };

  List<QuestionModel> selectedQuestions = [];
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: 0);
    getAllHomeworks();
    List<QuestionModel>? questions = homeworkQuestionsMap[widget.homeworkId];
    if (questions != null) {
      selectedQuestions = questions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(         
          title: Text('Quizz app'),          
        ),
       drawer:Drawer(
          child: Container(
            color: Color.fromARGB(255, 121, 210, 142),
            child: ListView(
              children: [
                // Thêm nút quay lại
                ListTile(
                  leading: Icon(Icons.arrow_back, color: Colors.white),
                  title: Text('Back', style: TextStyle(color: Colors.white)),
                  onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTopicPage(topicId: widget.topicId),
                          ),
                        ); // Đóng Drawer
                  },
                ),
                // Danh sách các mục khác trong Drawer
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: homeworks.length,
                  itemBuilder: (context, index) {
                    final homework = homeworks[index];
                    return ListTile(
                      title: Text(homework.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeResultScreen(topicId: widget.topicId, homeworkId: homework.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      backgroundColor: AppColor.pripmaryColor,
      body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: PageView.builder(
            controller: _controller!,
            onPageChanged: (page) {
              if (page == selectedQuestions.length - 1) {
                setState(() {
                  btnText = "Do it again";
                });
              }
              setState(() {
                answered = true;
              });
            },
            physics: new NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Question ${index + 1}/10",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.0,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 200.0,
                    child: Text(
                      "${selectedQuestions[index].question}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                  for (int i = 0; i < selectedQuestions[index].answers!.length; i++)
                  Container(
                    width: double.infinity,
                    height: 50.0,
                    margin: EdgeInsets.only(bottom: 20.0, left: 12.0, right: 12.0),
                    child: RawMaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      fillColor: (answered && selectedQuestions[index].answers!.values.toList()[i])
                          ? Colors.green // Màu xanh cho đáp án đúng
                          : (answered && !selectedQuestions[index].answers!.values.toList()[i])
                              ? Colors.red // Màu đỏ cho đáp án sai
                              : AppColor.secondaryColor, // Màu mặc định
                      onPressed: null, // Không cần thiết để bắt sự kiện
                      child: Text(
                        selectedQuestions[index].answers!.keys.toList()[i],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      if (_controller!.page?.toInt() == questions.length - 1) {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizzScreen(topicId: widget.topicId, homeworkId: widget.homeworkId),
                          ),
                        );
                      } else {
                        _controller!.nextPage(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInExpo);

                        setState(() {
                          btnPressed = false;
                        });
                      }
                    },
                    shape: StadiumBorder(),
                    fillColor: Colors.blue,
                    padding: EdgeInsets.all(18.0),
                    elevation: 0.0,
                    child: Text(
                      btnText,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              );
            },
            itemCount: selectedQuestions.length,
          )),
    );
  }
}