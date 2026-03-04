import 'package:aber/screens/location_screen.dart';
import 'package:aber/screens/login_screen.dart';
import 'package:aber/screens/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String fullNumber = "";
  bool isLoading = false;

  // SMS bhejne ka function
  void sendOTP() async {
    if (fullNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone number")),
      );
      return;
    }

    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        setState(() => isLoading = false);
      },
      verificationFailed: (FirebaseAuthException ex) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ex.message.toString())));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => isLoading = false);
        // OTP screen par jana verificationId ke sath
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
                  Container(
                    height: screenHeight * 0.4,
                    color: Colors.yellow.shade300,
                    width: double.infinity,
                    child: const Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/images/car.jpg'),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(child: Container(color: Colors.white)),
                ],
              ),
              Positioned(
                top: screenHeight * 0.33,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Signup',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 5,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        IntlPhoneField(
                          controller: phoneController,
                          initialCountryCode: 'PK',
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: 'Phone Number',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.yellow,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (phone) {
                            fullNumber =
                                phone.completeNumber; // +92 save ho rha hai
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: sendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade300,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(250, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  'SignUp',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 60,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    SizedBox(
                      height: 55,
                      width: 350,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool islogged = await login();

                          if (islogged) {
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationScreen(),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google sign-in failed'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Connect with Google',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "By clicking start, you agree to our Terms and Conditions",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> login() async {
    final GoogleSignInAccount? user = await GoogleSignIn().signIn();
    if (user == null) return false;

    final GoogleSignInAuthentication userAuth = await user.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: userAuth.idToken,
      accessToken: userAuth.accessToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    return FirebaseAuth.instance.currentUser != null;
  }
}
