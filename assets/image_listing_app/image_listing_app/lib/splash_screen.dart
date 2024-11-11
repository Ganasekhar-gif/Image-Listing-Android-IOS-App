// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import your HomeScreen

class SplashScreen extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpg', // Replace with your actual logo path
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Image Listing App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
