import 'package:flutter/material.dart';
import 'package:shelp/authentication_service.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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
                  "Sign Up",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                ),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(gapPadding: 5),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    context
                        .read<AuthenticationService>()
                        .signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim())
                        .then((value) {
                      setState(() {
                        alertText = value;
                        emailController.text = null;
                        passwordController.text = null;
                        confirmPasswordController.text = null;
                      });
                      if (value == "Signed Up!") {
                        Navigator.pushNamed(context, "/items");
                      }
                    });
                  } else {
                    setState(() {
                      alertText = "Passwords don't match!";
                    });
                  }
                },
                child: Text("Sign Up"),
                elevation: 5.0,
                color: Color(0xff7de8ac),
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
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text("Sign In"),
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
