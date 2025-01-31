import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'filterhistory.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> get history => _history;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final historyRef = _databaseRef.child('users/${user.uid}/history');
      final snapshot = await historyRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is List) {
          _history = List<Map<String, dynamic>>.from(data.map((item) => Map<String, dynamic>.from(item)));
          notifyListeners();
        }
      }
    }
  }

  Future<void> _saveHistory() async {
  final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final historyRef = _databaseRef.child('users/${user.uid}/history');
      await historyRef.set(_history);
    }
  }

  void addHistory(int score, String date, String time, int treatmentStep) {
  final newEntry = {
    'id': DateTime.now().millisecondsSinceEpoch,
    'score': score,
    'date': date,
    'time': time,
    'treatmentStep': treatmentStep,
  };
  _history.add(newEntry);
  _saveHistory();
  notifyListeners();
}



  void deleteHistoryById(int id) {
    _history.removeWhere((entry) => entry['id'] == id);
    _saveHistory();
    notifyListeners();
  }

  void updateHistoryById(int id, Map<String, dynamic> updatedEntry) {
    final index = _history.indexWhere((entry) => entry['id'] == id);
    if (index != -1) {
      _history[index] = updatedEntry;
      _saveHistory();
      notifyListeners();
    }
  }

  void clearHistoryByDate(String date, FilterType filterType) {
    switch (filterType) {
      case FilterType.weekly:
        _history.removeWhere((entry) => entry['date'] == date);
        break;
      case FilterType.monthly:
        final targetDate = DateFormat('MMMM yyyy').parse(date);
        _history.removeWhere((entry) {
          final entryDate = DateFormat('d MMMM yyyy').parse(entry['date']);
          return entryDate.year == targetDate.year && 
                 entryDate.month == targetDate.month;
        });
        break;
      case FilterType.yearly:
        final year = int.parse(date);
        _history.removeWhere((entry) {
          final entryDate = DateFormat('d MMMM yyyy').parse(entry['date']);
          return entryDate.year == year;
        });
        break;
    }
    _saveHistory();
    notifyListeners();
  }
}