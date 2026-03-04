# Firebase Authentication - Implementation Guide

## Quick Fix: Implement Auth State Management in 3 Steps

### Step 1: Update main.dart to Use StreamBuilder

Replace your current `main.dart` with this version that properly listens to Firebase auth state:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/onboarding_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/ride_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OnboardingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // While checking auth state, show splash
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            // If user is logged in, go to home/location screen
            if (snapshot.hasData) {
              return const LocationScreen(); // Import this screen
            }

            // If user is NOT logged in, show onboarding
            return const RideScreen();
          },
        ),
      ),
    );
  }
}
```

**What this does:**
- Listens to Firebase authentication state changes in real-time
- Automatically shows the correct screen based on whether user is logged in
- User stays logged in even after app restart
- User is logged out automatically if session expires

---

### Step 2: Update login_screen.dart

Add proper verification handling and auth guard:

```dart
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

  @override
  void initState() {
    super.initState();
    // GUARD: If already logged in, go to home
    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LocationScreen()),
        );
      });
    }
  }

  void loginNow() async {
    if (fullNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone number")),
      );
      return;
    }

    // Validate phone number format
    if (!RegExp(r'^\+\d{1,3}\d{4,14}$').hasMatch(fullNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number format")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ✅ THIS WAS EMPTY BEFORE - NOW IT'S IMPLEMENTED
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LocationScreen()),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Auto-verification failed: $e")),
            );
          }
        },
        verificationFailed: (FirebaseAuthException ex) {
          setState(() => isLoading = false);
          
          String message = "Verification failed";
          if (ex.code == 'invalid-phone-number') {
            message = "Invalid phone number format";
          } else if (ex.code == 'too-many-requests') {
            message = "Too many requests. Try again later.";
          } else if (ex.code == 'network-request-failed') {
            message = "Network error. Check your connection.";
          } else {
            message = ex.message ?? message;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
                  Container(
                    height: screenHeight * 0.3,
                    color: Colors.yellow.shade300,
                    width: double.infinity,
                  )
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
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
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              ),
                              child: const Text(
                                'SignUp',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'SignIn',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 4,
                                  width: 40,
                                  color: Colors.yellow,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Login with your phone number',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 30),
                      IntlPhoneField(
                        controller: phoneController,
                        initialCountryCode: 'PK',
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Enter phone number',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(color: Colors.yellow),
                          ),
                        ),
                        onChanged: (phone) {
                          fullNumber = phone.completeNumber;
                        },
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: isLoading ? null : loginNow,
                        child: Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.yellow.shade300,
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                : const Text(
                                    'Next',
                                    style: TextStyle(fontSize: 15),
                                  ),
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

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
```

**Key changes:**
- ✅ Added auth guard in `initState()`
- ✅ Implemented `verificationCompleted` callback
- ✅ Added proper error handling with specific messages
- ✅ Added phone number validation
- ✅ Added timeout handling
- ✅ Disabled button while loading

---

### Step 3: Update signup_screen.dart

Similar fixes to signup screen:

```dart
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

  @override
  void initState() {
    super.initState();
    // GUARD: If already logged in, go to home
    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LocationScreen()),
        );
      });
    }
  }

  void sendOTP() async {
    if (fullNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone number")),
      );
      return;
    }

    // Validate phone number format
    if (!RegExp(r'^\+\d{1,3}\d{4,14}$').hasMatch(fullNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number format")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ✅ THIS WAS EMPTY BEFORE - NOW IT'S IMPLEMENTED
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LocationScreen(),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Auto-verification failed: $e")),
            );
          }
        },
        verificationFailed: (FirebaseAuthException ex) {
          setState(() => isLoading = false);
          
          String message = "Verification failed";
          if (ex.code == 'invalid-phone-number') {
            message = "Invalid phone number format";
          } else if (ex.code == 'too-many-requests') {
            message = "Too many requests. Try again later.";
          } else if (ex.code == 'network-request-failed') {
            message = "Network error. Check your connection.";
          } else {
            message = ex.message ?? message;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<bool> login() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();
      if (user == null) return false;

      final GoogleSignInAuthentication userAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: userAuth.idToken,
        accessToken: userAuth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      print("Google Sign-In error: $e");
      return false;
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
                            fullNumber = phone.completeNumber;
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: isLoading ? null : sendOTP,
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
                                builder: (context) =>
                                    const LocationScreen(),
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
                        child: const Text(
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

  @override
  void dispose() {
    email.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
```

---

## Additional Fixes: Update OTP Screen

Add auth guard to OTP screen:

```dart
@override
void initState() {
  super.initState();
  // GUARD: If already logged in, go to home
  if (FirebaseAuth.instance.currentUser != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LocationScreen()),
      );
    });
  }
}
```

---

## Critical: Fix Google Sign-In on Android

You need to **add SHA-1 fingerprint to Firebase Console**:

1. Get your SHA-1:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. Copy the SHA-1 value

3. Go to Firebase Console:
   - Project Settings → Android apps
   - Add the SHA-1 to your app configuration
   - Download the fresh `google-services.json`

4. Replace your local `google-services.json` with the new one

---

## Testing Procedure

After applying all changes:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Test Scenarios:**
1. ✅ Fresh install → Shows onboarding
2. ✅ Complete phone signup → Goes to LocationScreen
3. ✅ Kill app and reopen → Should stay logged in
4. ✅ Invalid phone number → Shows error
5. ✅ Google sign-in → Should work (after SHA-1 fix)
6. ✅ OTP verification → Should auto-complete when signal is good

---

