import 'package:english/color/color.dart';
import 'package:english/view/account/profile.dart';
import 'package:english/view/main.dart';
import 'package:english/view/word/listword.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ResultScreen extends StatefulWidget {
  int score;
  ResultScreen({required this.score});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pripmaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              (widget.score > 7)
                ? "Congratulations"
                : "Nice try",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 45.0,
          ),
          Text(
            "You Score is",
            style: TextStyle(color: Colors.white, fontSize: 34.0),
          ),
          SizedBox(
            height: 20.0,
          ),              
          Text(
            "${widget.score}",
            style: TextStyle(
            color: (widget.score > 7)
                ? Colors.green 
                : (widget.score < 5)
                    ? Colors.red 
                    : Colors.orange,
              fontSize: 85.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 100.0,
          ),       
        ],
      ),
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