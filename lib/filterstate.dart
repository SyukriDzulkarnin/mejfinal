import 'package:flutter/material.dart';

class FilterState with ChangeNotifier {
  // Private variable to store the current filter
  String _currentFilter = 'Weekly';
  // Access the current filter
  String get currentFilter => _currentFilter;
  // Method to update the filter value
  void updateFilter(String newFilter) {
    _currentFilter = newFilter; // Update the current filter
    notifyListeners();
  }
}