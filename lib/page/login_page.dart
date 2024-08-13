import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safetyreport/user_auth/firebase_auth_service.dart';
import 'package:safetyreport/widget/form_container_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login", 
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
              isPasswordField: false,
            ),
            SizedBox(
              height: 10,
            ),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
            ),
            SizedBox(height: 30,),
            GestureDetector(
              onTap: _signIn,
              child:  Container(
                width: double.infinity,
                height: 45,
                decoration:  BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))
            )
            ),
          ],
          )
        )
      )
    );
  }

  void _signIn() async {

    String email = _emailController.text;
    String password = _passwordController.text;

    // if (email.isNotEmpty && password.isNotEmpty) {
    //   await _auth.signIn(email, password);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Email and password cannot be empty")),
    //   );
    // }
    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null){
      print("User successfully sign in");
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      print("User failed to sign in");
    }
  }
}