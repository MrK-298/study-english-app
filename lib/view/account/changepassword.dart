import 'dart:convert';
import 'package:english/view/account/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPage extends StatefulWidget {
  final int userId;
  ChangePasswordPage({required this.userId});
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController verificationPasswordController =
      TextEditingController();

//Chức năng reset password
  Future<void> changePassword() async {
    final Map<String, dynamic> data = {
      'id': widget.userId,
      'newPassword': newPasswordController.text,
      'oldPassword': oldPasswordController.text,
      'verifyNewPassword': verificationPasswordController.text,
    };

    final response = await http.put(
      Uri.parse('https://10.0.2.2:7142/api/Auth/ChangePassword'),
      body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
      headers: {
        'Content-Type':
            'application/json', // Đặt header Content-Type thành application/json
      },
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Xác nhận đổi mật khẩu'),
            content: Text('Bạn có chắc muốn đổi mật khẩu ?.'),
            actions: [
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage(word:"fake")));
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

  bool isObscurePassword1 = true;
  bool isObscurePassword2 = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Đổi mật khẩu')),
        body: Container(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              SizedBox(
                height: 140,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
                child: TextField(
                  controller: oldPasswordController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: 'Mật khẩu cũ',
                      prefixIcon: Container(
                        width: 50,
                        child: Image.asset('assets/image/ic_mail.png'),
                      ),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                ),
              ),
              Column(
                children: [
                  Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      TextField(
                        controller: newPasswordController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        obscureText: isObscurePassword1,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          prefixIcon: Container(
                            width: 50,
                            child: Image.asset('assets/image/ic_lock.png'),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffCED0D2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isObscurePassword1 = !isObscurePassword1;
                          });
                        },
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextField(
                          controller: verificationPasswordController,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          obscureText: isObscurePassword2,
                          decoration: InputDecoration(
                            labelText: 'Nhập lại mật khẩu mới',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_lock.png'),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffCED0D2),
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isObscurePassword2 = !isObscurePassword2;
                          });
                        },
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                    onPressed: changePassword,
                    child: Text(
                      'Đổi mật khẩu',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
