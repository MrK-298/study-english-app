import 'package:english/data/token.dart';
import 'package:english/view/account/changepassword.dart';
import 'package:english/view/account/editprofile.dart';
import 'package:english/view/account/login.dart';
import 'package:english/view/listword.dart';
import 'package:english/view/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "";
  String email = "";
  int userId = 0;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    decodetoken(TokenManager.getToken());
  }

  Future<void> logout(String Token) async {
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/Auth/Logout?token=$Token'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

  if (response.statusCode == 200) {
     return showDialog<void>(
     context: context,
     builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: <Widget>[
          TextButton(
            child: Text('Quay lại', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
          ),
          TextButton(
            child: Text('OK', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
              // Chuyển hướng đến trang đăng nhập
               Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(word:"fake")));
            },
          ),
        ],
      );
    },
  );
    
  } else {
     debugPrint("Error: ${response.statusCode}");
     debugPrint("Response body: ${response.body}");
  }
  }
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
        userName = responseData['fullName'];
        email = responseData['email'];
        userId = int.parse(responseData['userId']);
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
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Text('Hồ sơ tài khoản'),

        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 7,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35.0),
                          bottomRight: Radius.circular(35.0),
                        ),
                        color: Colors.blue,
                        gradient: LinearGradient(
                            colors: [
                              Color(0xFF00CCFF),
                              Color(0xFF3366FF),
                            ],
                            begin: FractionalOffset(0.0, 0.0),
                            end: FractionalOffset(1.0, 0.0),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp)),
                  ),
                  Positioned(
                    bottom: -50.0,
                    child: InkWell(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            child: Image.asset("assets/image/profile.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                      userId: userId,
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, side: BorderSide.none, shape: StadiumBorder()),
                      child: Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          title: Text('$userName')),
                    ),
                    Card(
                      elevation: 4,
                      child: ListTile(
                          leading: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          title: Text('$email')),
                    ),                  
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(
                          Icons.vpn_key,
                          color: Colors.black,
                        ),
                        title: Text("Đổi mật khẩu"),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChangePasswordPage(userId: userId)));
                        },
                      ),
                    ),
                    Card(
                      elevation: 4,
                      child: ListTile(
                          leading: Icon(
                            Icons.keyboard_return,
                            color: Colors.black,
                          ),
                          title: Text("Đăng xuất"),
                          onTap: () async {
                            await logout(TokenManager.getToken());
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ProfilePage()));
          }
        },
        ),
    );
  }
}
