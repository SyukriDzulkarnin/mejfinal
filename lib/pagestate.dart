import 'package:flutter/material.dart';

class PageState with ChangeNotifier {
  int? _igaScore;
  int? _treatmentStep;

  int? get igaScore => _igaScore;
  int? get treatmentStep => _treatmentStep;

  void updateAssessment(int igaScore, int treatmentStep) {
    _igaScore = igaScore;
    _treatmentStep = treatmentStep;
    notifyListeners();
  }
}