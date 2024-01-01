import 'package:english/data/token.dart';
import 'package:english/view/account/profile.dart';
import 'package:english/view/word/listword.dart';
import 'package:english/view/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final int userId;
  EditProfilePage({required this.userId});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  void initState() {
    super.initState();
    getUserInfo(widget.userId);
  }

  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  String email = "";
  String userName = "";
  int _currentIndex = 2;
  Future<void> changeProfile() async {
    // Kiểm tra nếu chuyến đi đã được chấp nhận rồi

    final response = await http.put(
      Uri.parse('https://10.0.2.2:7142/api/Auth/ChangeProfile'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': widget.userId,
        'name': nameController.text.isNotEmpty ? nameController.text : userName,
        'email': emailController.text.isNotEmpty ? emailController.text : email,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        TokenManager.setToken(responseData['token']);
      }
      // Nếu cập nhật thành công, cập nhật trạng thái trong ứng dụng
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Xác nhận thay đổi thông tin'),
            content: Text('Bạn có muốn đổi thông tin không'),
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
                  getUserInfo(widget.userId);
                  Navigator.of(context).pop(); // Đóng hộp thoại
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getUserInfo(int id) async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7142/api/Auth/UserInfo?id=$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        userName = responseData['fullName'];
        email = responseData['email'];
      });
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
          padding: const EdgeInsets.all(80.0),
          child: Text('Chỉnh sửa hồ sơ'),
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
                  Positioned(
                    bottom: -35,
                    right: 130,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.yellowAccent),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ]),
            SizedBox(
              height: 50,
            ),
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        hintText: ('$userName'),
                        prefixIcon: Icon(Icons.person_outline_rounded)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: ('$email'),
                        prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        changeProfile();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: BorderSide.none,
                          shape: StadiumBorder()),
                      child: Text("Lưu hồ sơ",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          }
        },
      ),
    );
  }
}
