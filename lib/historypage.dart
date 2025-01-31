import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import 'historyprovider.dart';
import 'filterhistory.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  FilterType _currentFilter = FilterType.weekly;

  List<String> _getRecommendations(int step) {
    switch (step) {
      case 1:
        return [
          'Applying emollients such as hypoallergenic lotion',
          'Taking short (5 minutes) but frequent showers',
          'Identify your eczema aggravating trigger',
        ];
      case 2:
        return [
          'Applying emollients such as hypoallergenic lotion',
          'Taking short (5 minutes) but frequent showers',
          'Identify your eczema aggravating trigger',
          'Use mild topical corticosteroids (TCS) that has been prescribed by your dermatologist',
        ];
      case 3:
        return [
          'Applying emollients such as hypoallergenic lotion',
          'Taking short (5 minutes) but frequent showers',
          'Identify your eczema aggravating trigger',
          'Use moderate topical corticosteroids (TCS) that has been prescribed by your dermatologist',
          'Seek phototherapy treatment from a licensed dermatologist',
          'Apply Wet Wrap Therapy (WWT)',
        ];
      case 4:
        return [
          'Use moderate topical corticosteroids (TCS) that has been prescribed by your dermatologist',
          'Seek phototherapy treatment from a licensed dermatologist',
          'Apply Wet Wrap Therapy (WWT)',
          'Request systemic therapy from your dermatologist',
        ];
      default:
        return [];
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupHistoryByDate(
    List<Map<String, dynamic>> history, FilterType filterType) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var entry in history) {
      String key;
      // Parse the date correctly regardless of format
      DateTime date;
      try {
        date = DateFormat('d MMMM yyyy').parse(entry['date']);
      } catch (e) {
        continue; // Skip invalid dates
      }
      
      switch (filterType) {
        case FilterType.weekly:
          key = DateFormat('d MMMM yyyy').format(date);
          break;
        case FilterType.monthly:
          key = DateFormat('MMMM yyyy').format(date);
          break;
        case FilterType.yearly:
          key = DateFormat('yyyy').format(date);
          break;
      }
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(Map<String, dynamic>.from(entry)); // Create a deep copy
    }
    
    // Sort entries within each date group by date and time
    grouped.forEach((key, entries) {
      entries.sort((a, b) {
        DateTime dateA = DateFormat('d MMMM yyyy').parse(a['date']);
        DateTime dateB = DateFormat('d MMMM yyyy').parse(b['date']);
        
        // If dates are the same, sort by time
        if (dateA == dateB) {
          TimeOfDay timeA = _parseTime(a['time']);
          TimeOfDay timeB = _parseTime(b['time']);
          return _compareTime(timeA, timeB);
        }
        
        // Otherwise, sort by date
        return dateA.compareTo(dateB);
      });
    });
  
    // Sort date groups in descending order
    return Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) {
          DateTime dateA = DateFormat('d MMMM yyyy').parse(a.value.first['date']);
          DateTime dateB = DateFormat('d MMMM yyyy').parse(b.value.first['date']);
          return dateB.compareTo(dateA);
        })
    );
  }

  // Helper method to parse time
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final minuteParts = parts[1].split(' ');
    
    int hour = int.parse(parts[0]);
    int minute = int.parse(minuteParts[0]);
    
    // Adjust for PM
    if (minuteParts[1] == 'PM' && hour != 12) {
      hour += 12;
    }
    // Adjust for 12 AM
    if (minuteParts[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Helper method to compare times
  int _compareTime(TimeOfDay timeA, TimeOfDay timeB) {
    int minutesA = timeA.hour * 60 + timeA.minute;
    int minutesB = timeB.hour * 60 + timeB.minute;
    return minutesA.compareTo(minutesB);
  }


  Future<void> _exportHistory(String date, List<Map<String, dynamic>> entries) async {
  try {
    // Request storage permissions
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Get the external storage directory
      Directory directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      
      // Create a formatted filename with timestamp
      String timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^\w]'), '_');
      String filename = 'eczema_history__$timestamp.txt';
      
      // Create the file
      final File file = File('${directory.path}/$filename');

      // Generate the content and write to the file
      String content = 'Assessments Records for $date\n\n';
    
    for (var entry in entries) {
      content += '-----------------------------------------------\n';
      content += 'Date: ${entry['date']}\n';
      content += 'Time: ${entry['time']}\n';
      content += '-----------------------------------------------\n';
      content += 'IGA Score: ${entry['score']}\n';
      content += 'Condition: ${_getCondition(entry['score'])}\n';
      content += 'Treatment Step: ${entry['treatmentStep']}\n';
      content += 'Recommendations:\n';
      
      List<String> recommendations = _getRecommendations(entry['treatmentStep']);
      for (var rec in recommendations) {
        content += '- $rec\n';
      }
      content += '-----------------------------------------------\n\n';
    }

    // Write the content to file
    await file.writeAsString(content);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('History exported successfully to: ${file.path}'),
          backgroundColor: Colors.cyan,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export history: Storage permission denied'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  } catch (e) {
    print('Export error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to export history: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
  

  String _getCondition(int score) {
    switch (score) {
      case 0:
        return "Clear";
      case 1:
        return "Almost Clear";
      case 2:
        return "Mild";
      case 3:
        return "Moderate";
      case 4:
        return "Severe";
      case 5:
        return "Very Severe";
      default:
        return "Unknown";
    }
  }

  void _clearGroupHistory(String date, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear all history for $date?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Clear'),
            onPressed: () {
              provider.clearHistoryByDate(date, _currentFilter);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Consumer<HistoryProvider>(
          builder: (context, historyProvider, child) {
            final groupedHistory = _groupHistoryByDate(
              historyProvider.history,
              _currentFilter,
            );

            return Column(
              children: [
                // Filter buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var filterType in FilterType.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentFilter == filterType
                              ? Colors.cyan
                              : Colors.white,
                            foregroundColor: _currentFilter == filterType
                              ? Colors.white
                              : Colors.cyan,
                            elevation: _currentFilter == filterType ? 2 : 0,
                            side: BorderSide(color: Colors.cyan),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentFilter = filterType;
                            });
                          },
                          child: Text(filterType.name.capitalize()),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: groupedHistory.isEmpty
                    ? Center(
                      child: Text(
                        'No history available.',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                    itemCount: groupedHistory.length,
                    itemBuilder: (context, groupIndex) {
                      String date = groupedHistory.keys.elementAt(groupIndex);
                      List<Map<String, dynamic>> entries = groupedHistory[date]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.file_download, color: Colors.white),
                                  label: Text('Export', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  onPressed: () => _exportHistory(date, entries),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.delete_outline, color: Colors.white),
                                  label: Text('Clear All', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  onPressed: () => _clearGroupHistory(date, historyProvider),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return HistoryCard(
                                entry: entry,
                                showDate: _currentFilter != FilterType.weekly,
                                onView: () => _showViewDialog(context, entry),
                                onEdit: () => _showEditDialog(context, entry, index),
                                onDelete: () => historyProvider.deleteHistoryById(entry['id']),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    },
                  )
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Updated view dialog to include recommendations
  void _showViewDialog(BuildContext context, Map<String, dynamic> entry) {
    List<String> recommendations = _getRecommendations(entry['treatmentStep']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Text(
                  'IGA Score: ${entry['score']}',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Condition: ${_getCondition(entry['score'])}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Treatment Step: ${entry['treatmentStep']}'),
                Text('Date: ${entry['date']}'),
                Text('Time: ${entry['time']}'),
                SizedBox(height: 16),
                Text(
                  'Recommendations:',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...recommendations.map((rec) => Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('• $rec'),
                )),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // Shows a dialog to edit the selected history entry
  void _showEditDialog(BuildContext context, Map<String, dynamic> entry, int index) {
  final TextEditingController _scoreController =
      TextEditingController(text: entry['score'].toString());
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Parse the existing date from entry
  try {
    _selectedDate = DateFormat('d MMMM yyyy').parse(entry['date']);
  } catch (e) {
    print('Error parsing date: $e');
    _selectedDate = DateTime.now(); // Fallback to current date if parsing fails
  }

  // Parse the existing time from entry
  try {
    final timeStr = entry['time'];
    final timeParts = timeStr.split(':');
    if (timeParts.length == 2) {
      String hour = timeParts[0];
      String minute = timeParts[1].split(' ')[0]; // Remove AM/PM if present
      String period = timeParts[1].contains('PM') ? 'PM' : 'AM';
      
      // Convert to 24-hour format if needed
      int hourInt = int.parse(hour);
      if (period == 'PM' && hourInt != 12) {
        hourInt += 12;
      } else if (period == 'AM' && hourInt == 12) {
        hourInt = 0;
      }
      
      _selectedTime = TimeOfDay(
        hour: hourInt,
        minute: int.parse(minute),
      );
    }
  } catch (e) {
    print('Error parsing time: $e');
    _selectedTime = TimeOfDay.now(); // Fallback to current time if parsing fails
  }

  // Store original values to check if they've been modified
  final originalDate = _selectedDate;
  final originalTime = _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _selectedDate = picked;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _selectedTime = picked;
    }
  }
    
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(
              child: Text('Edit History',
              style: GoogleFonts.roboto(
              fontSize: 20, fontWeight: FontWeight.bold))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _scoreController,
                    decoration: InputDecoration(
                      hintText: 'Enter IGA Score (0-5)',
                      contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _selectDate(context);
                            setState(() {});
                          },
                          icon: Icon(Icons.calendar_today, color: Colors.cyan),
                          label: Text(
                            _selectedDate != null
                              ? "${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                              : entry['date'],
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.cyan,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 30),
                            side: BorderSide(color: Colors.cyan),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _selectTime(context);
                            setState(() {});
                          },
                          icon: Icon(Icons.access_time, color: Colors.cyan),
                          label: Text(
                            _selectedTime != null
                              ? "${_selectedTime!.format(context)}"
                              : entry['time'],
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.cyan,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 30),
                            side: BorderSide(color: Colors.cyan),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        int newScore = int.tryParse(_scoreController.text) ?? -1;
                        if (newScore >= 0 && newScore <= 5) {
                          // Find the entry by its unique ID using the provider's history
                          HistoryProvider historyProvider = Provider.of<HistoryProvider>(context, listen: false);
                          int entryIndex = historyProvider.history.indexWhere((e) => e['id'] == entry['id']);

                          if (entryIndex != -1) {
                            // Only update date if it was changed
                            if (_selectedDate != originalDate) {
                              entry['date'] = "${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}";
                            }
                            // Only update time if it was changed
                            if (_selectedTime != originalTime) {
                              entry['time'] = "${_selectedTime!.format(context)}";
                            }
                            entry['score'] = newScore;
                            
                            historyProvider.updateHistoryById(entry['id'], Map.from(entry));
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Get the month name from the month number
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDate;

  const HistoryCard({
    required this.entry,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.cyan[200]!),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IGA Score: ${entry['score']}',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: ${entry['time']}',
                  style: GoogleFonts.roboto(),
                ),
                if (showDate)
                  Text(
                    'Date: ${entry['date']}',
                    style: GoogleFonts.roboto(),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.cyan),
                onPressed: onView,
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.cyan),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.cyan),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}