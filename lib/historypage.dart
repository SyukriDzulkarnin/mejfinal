import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'historyprovider.dart';

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
                            'Date: ${entry['date']}',
                            style: GoogleFonts.roboto(),
                          ),
                          Text(
                            'Time: ${entry['time']}',
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
              Text('Date: ${entry['date']}'),
              Text('Time: ${entry['time']}'),
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
    final TextEditingController _controller = TextEditingController(text: entry['score'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Edit IGA Score', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter IGA Score (0-5)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  int newScore = int.tryParse(_controller.text) ?? -1;
                  if (newScore >= 0 && newScore <= 5) {
                    _updateHistory(context, newScore, index);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Update',
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
}