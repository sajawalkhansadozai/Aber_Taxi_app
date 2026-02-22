import 'package:aber/model/onboarding_model.dart';
import 'package:flutter/material.dart';

class OnboardingWidgets {

  //yahan hm pages k widgets store ken gy
  static Widget buildPageContent(OnboardingModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //yahan model se image ly gy
          Image.asset(model.image,
              height: 280,
          ),
          const SizedBox(height: 40),

          //yahan title
          Text(
            model.title,
            style: const TextStyle(
              fontSize: 26,
                fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          //or yahan text
          Text(
            model.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  // yahan Get Started Button ka widget bnaen gy
  static Widget getStartedButton({required bool isVisible, required VoidCallback onTap}) {
    //last screen pe show kren gy
    if (!isVisible) {
      return const SizedBox(height: 50);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, width: 200,
        decoration: BoxDecoration(
          color: Colors.yellow.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Indicators parameters bnaen gy.. k user kis page pe hai or kitny pages hn
  static Widget pageIndicators({required int current, required int total}) {
    //ab indicator k liye row bnaen gy
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(right: 8),
        height: 8,
        //yahan hm logic lgane gy k agr user jis page pe hai to wo page ka indicator lamba ho jye
        //wrna chota rhy
        width: current == index ? 35 : 15,
        decoration: BoxDecoration(

          //yahan hm color k liye logic lgaen gy k active color yellow ho
          color: current == index ? Colors.yellow : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      ),
    );
  }
}