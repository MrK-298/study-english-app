import 'package:english/view/word/WordDetail.dart';
import 'package:english/view/account/forgotpassword.dart';
import 'package:english/view/account/register.dart';
import 'package:english/view/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:english/data/token.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  final String word;

  LoginPage({required this.word});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPass = false;
  TextEditingController _userController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  var _userNameErr = "Invalid username";
  var _passErr = "Password must have 6 characters or more";
  var _userInvalid = false;
  var _passInvalid = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            constraints: BoxConstraints.expand(),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Container(
                      width: 140,
                      height: 140,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        'assets/image/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Hello\nWe Are Heartsteel",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: TextField(
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        controller: _userController,
                        decoration: InputDecoration(
                            labelText: "Tài khoản",
                            errorText: _userInvalid ? _userNameErr : null,
                            labelStyle: TextStyle(
                                color: Color(0xff888888), fontSize: 15))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        TextField(
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            controller: _passController,
                            obscureText: !_showPass,
                            decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                errorText: _passInvalid ? _passErr : null,
                                labelStyle: TextStyle(
                                    color: Color(0xff888888), fontSize: 15))),
                        GestureDetector(
                          onTap: onToggleSHowPass,
                          child: Text(
                            _showPass ? "HIDE" : "SHOW",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(
                                  word: widget.word,
                                )),
                      );
                    },
                    child: Container(
                      constraints:
                          BoxConstraints.loose(Size(double.infinity, 30)),
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        'Quên mật khẩu?',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xff3277D8)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onSignInClickecd,
                        child: Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: '    Bạn là người mới? ',
                            style: TextStyle(
                                color: Color(0xff606470), fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterPage(
                                                      word: widget.word)));
                                    },
                                  text: 'Đăng ký tài khoản mới',
                                  style: TextStyle(
                                      color: Color(0xff3277D8), fontSize: 16))
                            ])),
                  )
                ],
              ),
            )),
      ),
    );
  }

  void onToggleSHowPass() {
    setState(() {
      _showPass = !_showPass;
    });
  }

  void onSignInClickecd() {
    setState(() {
      if (_userController.text.length < 6) {
        _userInvalid = true;
      } else {
        _userInvalid = false;
      }
      if (_passController.text.length < 6) {
        _passInvalid = true;
      } else {
        _passInvalid = false;
      }
      if (!_userInvalid && !_passInvalid) {
        login();
      }
    });
  }

  Future<void> login() async {
    final Map<String, dynamic> data = {
      'userName': _userController.text,
      'passWord': _passController.text,
    };

    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/Auth/Login'),
      body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
      headers: {
        'Content-Type':
            'application/json', // Đặt header Content-Type thành application/json
      },
    );

    if (response.statusCode == 200) {
      // Xử lý đăng nhập thành công
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        TokenManager.setToken(responseData['token']);
        if (widget.word != "fake") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WordDetailPage(word: widget.word)));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MapSample()));
        }
      } else {
        debugPrint("Error: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    }
  }
}
