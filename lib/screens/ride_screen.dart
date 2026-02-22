import 'package:aber/data/onboarding_data.dart';
import 'package:aber/providers/onboarding_provider.dart';
import 'package:aber/screens/setup_location.dart';
import 'package:aber/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RideScreen extends StatelessWidget {
  const RideScreen({super.key});

  // yahan hm provider or data ko access krna
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    // jo data pages ki list bnai h usko access kren gy
    final pages = OnboardingData.pages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              //pages ki swiping k liye pageview.builder use kren gy
              child: PageView.builder(
                onPageChanged: provider.updatePage,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return OnboardingWidgets.buildPageContent(pages[index]);
                },
              ),
            ),

            // yahan Get Started Button ka widget len gy
            // Ye button sirf aakhri page par nazar aayega
            OnboardingWidgets.getStartedButton(
              isVisible: provider.currentPage == pages.length - 1,
              onTap: () {
                // Navigation kren gy Next screen pr jany k liye
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SetupLocation()),
                );
                print("Navigating to Location Screen");
              },
            ),

            const SizedBox(height: 40),

            // Indicators use kren gy last dots k liye..
            //or usko page indicator k sath connect kren gy ta k jb user swipe kry to ye b chnage ho
            OnboardingWidgets.pageIndicators(
              current: provider.currentPage,
              total: pages.length,
            ),
            //height den gy ta k bottom bar pe na jye
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}