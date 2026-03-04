import 'package:aber/screens/otp_screen.dart';
import 'package:aber/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  String fullNumber = "";
  bool isLoading = false;

  void loginNow() async {
    if (fullNumber.isEmpty) return;

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationCompleted: (_) {},
        verificationFailed: (ex) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ex.message.toString())));
        },
        codeSent: (verificationId, resendToken) {
          setState(() => isLoading = false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(verificationId: verificationId)));
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(height: screenHeight * 0.3, color: Colors.yellow.shade300, width: double.infinity)
                ],
              ),
              Positioned(
                top: screenHeight * 0.20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 2)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                              child: const Text('SignUp', style: TextStyle(fontSize: 25, color: Colors.grey)),
                            ),
                            Column(
                              children: [
                                const Text('SignIn', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Container(height: 4, width: 40, color: Colors.yellow),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 20),
                      const Text('Login with your phone number', style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 30),
                      IntlPhoneField(
                        controller: phoneController,
                        initialCountryCode: 'PK',
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Enter phone number',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.yellow)),
                        ),
                        onChanged: (phone) {
                          fullNumber = phone.completeNumber;
                        },
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: loginNow,
                        child: Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.yellow.shade300),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text('Next', style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}