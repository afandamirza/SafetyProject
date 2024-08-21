import 'package:flutter/material.dart';

class MyTexfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
    final void Function(String)? onSubmitted; // Add this parameter


  const MyTexfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onSubmitted
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54, width: 0.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF36618E)),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.black38)),
            onSubmitted: onSubmitted, // Handle the onSubmitted event
      ),
      
    );
  }
}
