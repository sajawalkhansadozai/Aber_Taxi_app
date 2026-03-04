import 'package:aber/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class SetupLocation extends StatefulWidget {
  const SetupLocation({super.key});

  @override
  State<SetupLocation> createState() => _SetupLocationState();
}

// here we create location setup page
class _SetupLocationState extends State<SetupLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: Container(
                child: Image.asset('assets/images/location.png'),
                height: 500,
                width: 300,
              ),
            ),
            SizedBox(height: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Hi, nice to meet you!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                SizedBox(height: 15,),
                Text('Choose your location to start find restaurants around you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Colors.grey),),
                SizedBox(height: 20,),
              ],
            ),

            //Now container for current location
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 50,
              width: 270,

              // ab row mn dono widgets add kren gy
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Use Current Location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            //ab GesterDetector use kren gy ta k ye clckable ho.. or user is pe click kr k next screen pe move ho jye
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text('Select it Manually', style: TextStyle(color: Colors.red),),
            )
          ],
        ),
      ),
    );
  }
}
