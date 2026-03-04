import 'package:aber/model/onboarding_model.dart';

//yahan hm ne onboarding pages ka data likhen gy
class OnboardingData {
  static final List<OnboardingModel> pages = [
    OnboardingModel(
      title: "Request Ride",
      text: "Request a ride get picked up by a nearby community driver",
      image: "assets/images/ride.png",
    ),
    OnboardingModel(
      title: "Confirm Your Driver",
      text: "Huge drivers network helps you find comfortable, safe and cheap ride",
      image: "assets/images/taxi-driver.png",
    ),
    OnboardingModel(
      title: "Track your ride",
      text: "Know your driver in advance and see their location on the map",
      image: "assets/images/track_ride.png",
    ),
  ];
}