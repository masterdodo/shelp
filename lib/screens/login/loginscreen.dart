import 'package:flutter/material.dart';
import 'package:shelp/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String alertText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb7f08b),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Sign In",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(gapPadding: 5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(gapPadding: 5),
                  ),
                ),
              ),
              RaisedButton(
                elevation: 5.0,
                color: Color(0xff7de8ac),
                onPressed: () {
                  context
                      .read<AuthenticationService>()
                      .signIn(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim())
                      .then((value) {
                    setState(() {
                      alertText = value;
                    });
                    if (value == "Signed In!") {
                      Navigator.pushNamed(context, "/items");
                    }
                  });
                },
                child: Text("Sign In"),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(26.0)),
              ),
              Text(
                alertText,
                style: TextStyle(color: Colors.red[700]),
              ),
              RaisedButton(
                color: Color(0xff7de8ac),
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text("Sign Up"),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(26.0)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
