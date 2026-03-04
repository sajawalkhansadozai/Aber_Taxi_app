import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(

                    // Bcz 40% Yellow k liye screen bny gi
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: Colors.yellow.shade300,
                    width: double.infinity,

                    // Now creating circle avatar for logo
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/images/car.jpg'),
                      ),
                    ),
                  ),
                  // or baki 60% part for white screen
                  Expanded(
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Ab Overlapping Card use kren gy jo thora sa yellow pe hoga.. or baki white area pe.
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35, // Yellow ke thora upar se shuru
                left: 20,
                right: 20,

                //ab card bnaen gy or usi apni heigh deni hogi
                child: Container(
                  height: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  // Yahan ab Form design karen gy
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Signup', style: TextStyle(fontSize: 25),textAlign: TextAlign.left,),
                            SizedBox(height: 5,),
                            Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                              ),
                              
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text('Sign In', style: TextStyle(fontSize: 20, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
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
