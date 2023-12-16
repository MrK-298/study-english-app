import 'package:english/main.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
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
                  SizedBox(height: 100),
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
                            labelText: "Username",
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
                                labelText: "Password",
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onSignInClickecd,
                        child: Text(
                          "SIGN IN",
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
                  Container(
                    height: 130,
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "NEW USER? SIGN UP",
                            style: TextStyle(
                                fontSize: 15, color: Color(0xff888888)),
                          ),
                          Text(
                            "FORGOT PASSWORD",
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                          )
                        ]),
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
      if (_userController.text.length < 6 ||
          !_userController.text.contains("@")) {
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
        Navigator.push(context, MaterialPageRoute(builder: gotoHome));
      }
    });
  }

  Widget gotoHome(BuildContext context) {
    return MapSample();
  }
}
