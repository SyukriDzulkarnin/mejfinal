import 'package:flutter/material.dart';

class PageState with ChangeNotifier {
  // Private variables to store IGA score and treatment step
  int? _igaScore;
  int? _treatmentStep;
  // Access the IGA score
  int? get igaScore => _igaScore;
  // Access the treatment step
  int? get treatmentStep => _treatmentStep;
  // Method to update the assessment values
  void updateAssessment(int igaScore, int treatmentStep) {
    _igaScore = igaScore; // Update the IGA score
    _treatmentStep = treatmentStep; // Update the treatment step
    notifyListeners(); // Notify listeners to update the UI
  }
}