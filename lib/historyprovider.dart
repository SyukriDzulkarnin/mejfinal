import 'package:flutter/material.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _history = [];

  List<Map<String, dynamic>> get history => _history;

  void addHistory(int score, String date, String time, int treatmentStep) {
    _history.add({
      'score': score,
      'date': date,
      'time': time,
      'treatmentStep': treatmentStep,
    });
    notifyListeners();
  }

  void deleteHistory(int index) {
    _history.removeAt(index);
    notifyListeners();
  }

  void updateHistory(int index, Map<String, dynamic> updatedEntry) {
    _history[index] = updatedEntry;
    notifyListeners();
  }
}