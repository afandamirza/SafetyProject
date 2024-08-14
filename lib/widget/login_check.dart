import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginCheck extends StatelessWidget {
  final Widget child;

  const LoginCheck({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Redirect to login page if not authenticated
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const SizedBox.shrink(); // Return an empty widget while redirecting
    }

    // If authenticated, show the requested page
    return child;
  }
}
