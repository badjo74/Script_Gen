import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:script/home_screen.dart'; // مكتبة أنيميشن رائعة

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية رايقة
      body: Center(
        child: ZoomIn(
          // أنيميشن ظهور باسمك
          duration: const Duration(seconds: 2),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ممكن تضيف هنا صورة اللوجو لو عندك
              Icon(Icons.auto_stories_rounded,
                  size: 100, color: Colors.redAccent),
              SizedBox(height: 20),
              Text(
                ' by Badjo',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
