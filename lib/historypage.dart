import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'historyprovider.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Consumer<HistoryProvider>(
          builder: (context, historyProvider, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: historyProvider.history.isEmpty
                ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No history available.',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                itemCount: historyProvider.history.length,
                itemBuilder: (context, index) {
                  final entry = historyProvider.history[historyProvider.history.length - 1 - index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
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
                    child: ListTile(
                      title: Text(
                        'IGA Score: ${entry['score']}',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${_formatDate(entry['date'])}',
                            style: GoogleFonts.roboto(),
                          ),
                          Text(
                            'Time: ${_formatTime(entry['time'])}',
                            style: GoogleFonts.roboto(),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.cyan),
                            onPressed: () => _showViewDialog(context, entry),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.cyan),
                            onPressed: () => _showEditDialog(context, entry, index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.cyan),
                            onPressed: () => historyProvider.deleteHistory(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showViewDialog(BuildContext context, Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('IGA Score: ${entry['score']}', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Treatment Step: ${entry['treatmentStep']}'),
              Text('Date: ${_formatDate(entry['date'])}'),
              Text('Time: ${_formatTime(entry['time'])}'),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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

  void _showEditDialog(BuildContext context, Map<String, dynamic> entry, int index) {
    final TextEditingController _scoreController = TextEditingController(text: entry['score'].toString());
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    try {
      _selectedDate = DateTime.parse(entry['date']);
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    try {
      _selectedTime = TimeOfDay(
        hour: int.parse(entry['time'].split(':')[0]),
        minute: int.parse(entry['time'].split(':')[1]),
      );
    } catch (e) {
      _selectedTime = TimeOfDay.now();
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _selectedDate) {
        _selectedDate = picked;
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );
      if (picked != null && picked != _selectedTime) {
        _selectedTime = picked;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Edit History', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _scoreController,
                decoration: InputDecoration(
                  hintText: 'Enter IGA Score (0-5)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(_selectedDate != null
                    ? "${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                    : "Pick a Date"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text(_selectedTime != null
                    ? "${_selectedTime!.format(context)}"
                    : "Pick a Time"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int newScore = int.tryParse(_scoreController.text) ?? -1;
                if (newScore >= 0 && newScore <= 5) {
                  entry['score'] = newScore;
                  entry['date'] = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                  entry['time'] = "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
                  Provider.of<HistoryProvider>(context, listen: false).updateHistory(index, entry);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateHistory(BuildContext context, int newScore, int index) {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    final entry = historyProvider.history[index];
    final treatmentStep = _getTreatmentStep(newScore);

    historyProvider.history[index] = {
      'score': newScore,
      'date': entry['date'],
      'time': entry['time'],
      'treatmentStep': treatmentStep,
    };

    historyProvider.notifyListeners();
  }

  int _getTreatmentStep(int score) {
    if (score == 0 || score == 1) {
      return 1;
    } else if (score == 2) {
      return 2;
    } else if (score == 3) {
      return 3;
    } else {
      return 4;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final TimeOfDay parsedTime = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      );
      final now = DateTime.now();
      final formattedTime = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
      return DateFormat('hh:mm a').format(formattedTime);
    } catch (e) {
      return time;
    }
  }
}