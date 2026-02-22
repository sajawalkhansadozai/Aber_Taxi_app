import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  int currentPage = 0;

  void updatePage(int index) {
    currentPage = index;
    notifyListeners();
  }
}