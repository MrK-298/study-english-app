import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:english/view/account/login.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  final String word;

  ForgotPasswordPage({required this.word});
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  bool isVerificationCodeSent = false;
  //Chức năng gửi mã xác minh
  Future<void> sentCode() async {
    final Map<String, dynamic> data = {
      'email': emailController.text,
    };

    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/Auth/sentCode'),
      body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
      headers: {
        'Content-Type':
            'application/json', // Đặt header Content-Type thành application/json
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        isVerificationCodeSent = true;
      });
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

//Chức năng reset password
  Future<void> resetPassword() async {
    final Map<String, dynamic> data = {
      'email': emailController.text,
      'newPassword': newPasswordController.text,
      'verificationCode': verificationCodeController.text,
    };

    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/Auth/resetPassword'),
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
            title: Text('Đổi mật khẩu thành công'),
            content: Text(
                'Mật khẩu của bạn đã được đổi thành công. Vui lòng đăng nhập lại.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Đóng dialog
                  Navigator.of(context).pop();
                  // Chuyển về trang đăng nhập
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage(word:widget.word)));
                },
                child: Text('Đóng'),
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

  bool isObscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Quên mật khẩu')),
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
                  controller: emailController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: 'Email',
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
              if (isVerificationCodeSent)
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
                          obscureText: isObscurePassword,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isObscurePassword = !isObscurePassword;
                            });
                          },
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: TextField(
                        controller: verificationCodeController,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Mã xác minh',
                          prefixIcon: Container(
                            width: 50,
                            child: Image.asset('assets/image/ic_mail.png'),
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
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: sentCode,
                    child: Text(
                      'Gửi mã',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: resetPassword,
                    child: Text(
                      'Reset',
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
