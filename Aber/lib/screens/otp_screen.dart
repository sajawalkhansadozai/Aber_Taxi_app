import 'package:aber/screens/location_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // 6 boxes ke liye 6 controllers
  final List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              color: Colors.yellow.shade300,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Phone Verification",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your OTP code here",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => otpInput(context, index)),
              ),
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: () async {
                  // Saare dabbo ka text jorrna
                  String smsCode = controllers.map((e) => e.text).join();
                  if (smsCode.length < 6) return;

                  setState(() => isVerifying = true);
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: smsCode,
                        );
                    await FirebaseAuth.instance.signInWithCredential(
                      credential,
                    );
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationScreen(),
                      ),
                    );
                  } catch (ex) {
                    if (!mounted) return;
                    setState(() => isVerifying = false);
                    final String msg = ex is FirebaseAuthException
                        ? (ex.message ?? 'Invalid OTP Code!')
                        : ex.toString();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade300,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isVerifying
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Verify Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget otpInput(BuildContext context, int index) {
    return SizedBox(
      width: 40,
      child: TextField(
        controller: controllers[index],
        autofocus: index == 0 ? true : false,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 3),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 3),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
