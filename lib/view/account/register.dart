import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:english/view/account/login.dart';

class RegisterPage extends StatefulWidget {
  final String word;

  RegisterPage({required this.word});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  Future<void> register() async {
  final Map<String, dynamic> data = {
    'userName': usernameController.text,
    'passWord': passwordController.text,
    'email': emailController.text,
    'fullName' : fullNameController.text,
  };
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7142/api/Auth/Register'),
      body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
      headers: {
        'Content-Type':
            'application/json', // Đặt header Content-Type thành application/json
      },
    );

    if (response.statusCode == 200) {
      // Xử lý đăng nhập thành công
      // Lưu thông tin đăng nhập hoặc mã thông báo
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage(word:widget.word)));
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

  bool isObscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff327708)),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
          child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                     Image.asset('assets/image/logo.png',width: 300.0, height: 180.0,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                      child: Text(
                        'HEARTSTEEL',
                        style: TextStyle(fontSize: 30, color: Color(0xff333333), fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      'Đăng ký tài khoản với HeartSteel',
                      style: TextStyle(fontSize: 16, color: Color(0xff606470), fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                      child: TextField(
                        controller: usernameController,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Tài khoản',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_user.png')),
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(6)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: TextField(
                        controller: fullNameController,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Họ và tên',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_user.png')),
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(6)))),
                      ),
                    ),                
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_mail.png')),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(6)))),
                      ),
                    ),               
                    Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: TextField(
                            controller: passwordController,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            obscureText: isObscurePassword,
                            decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: Container(
                                    width: 50,
                                    child: Image.asset('assets/image/ic_lock.png')),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                                    borderRadius: BorderRadius.all(Radius.circular(6)))),
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            setState(() {
                              isObscurePassword = !isObscurePassword;
                            });},
                          icon: Icon(Icons.remove_red_eye, color: Colors.grey,),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: register,
                          child: Text(
                            'Đăng ký',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: RichText(
                          text: TextSpan(
                              text: 'Bạn đã có tài khoản? ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff606470)
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(word:widget.word)));
                                      },
                                    text: 'Đăng nhập ngay',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff3277D8)
                                    )
                                )
                              ]
                          )
                      )
                    )
                ],
              ),
          ),
      ),
    );
  }
}
