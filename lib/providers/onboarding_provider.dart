import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  int currentPage = 0;

  void updatePage(int index) {
    currentPage = index;
    notifyListeners(); // Notify listeners to rebuild UI when the page changes
  }
}
