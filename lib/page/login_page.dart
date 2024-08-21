import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safetyreport/components/my_texfield.dart';
import 'package:safetyreport/user_auth/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400, // Set the maximum width for the container
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 0.2)
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // Logo
                        Container(
                          child: Image.asset('lib/images/safety.png'),
                          height: 100,
                        ),
                        const SizedBox(height: 30),
                        // Welcome Back
                        const Text(
                          'Welcome Back',
                          style: TextStyle(color: Colors.black87, fontSize: 20),
                        ),
                        const SizedBox(height: 30),
                        // Email Textfield
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: MyTexfield(
                            controller: emailController,
                            hintText: 'Email',
                            obscureText: false,
                            onSubmitted: (_) => _signIn()
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Password Textfield
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: MyTexfield(
                            controller: passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            onSubmitted: (_) => _signIn(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign In Button
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              backgroundColor: const Color(0xFF36618E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Forgot Password Text
                        const Text(
                          "Safety Report",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      print("User successfully signed in");
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to sign in. Please check your credentials.")),
      );
    }
  }
}
