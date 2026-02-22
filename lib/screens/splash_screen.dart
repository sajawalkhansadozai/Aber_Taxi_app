import 'package:flutter/material.dart';
import 'ride_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  // sb se pehly idhr splash screen k liye duration set kren gy.. or loop lagaen gy k
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RideScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade300,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //for image
            const CircleAvatar(
              radius: 120,
              backgroundImage: AssetImage('assets/images/car.jpg'),
            ),

            const SizedBox(height: 20),

            //for text
            const Text(
              'Aber',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            // ye progress indicator use kren gy jb tk splash screen show hogi
            SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}