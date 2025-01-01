import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'pagestate.dart';
import 'historyprovider.dart';

class AssessmentPage extends StatefulWidget {
  final Function(int) onTabTapped;

  const AssessmentPage({required this.onTabTapped, super.key});

  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  int? _igaScore;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _showSkinAnalysis = false;

  void _showIGAScoreDialog(BuildContext context, int score) {
    String scoreDescription;

    switch (score) {
      case 0:
        scoreDescription = 'Clear';
        break;
      case 1:
        scoreDescription = 'Almost Clear';
        break;
      case 2:
        scoreDescription = 'Mild Disease';
        break;
      case 3:
        scoreDescription = 'Moderate Disease';
        break;
      case 4:
        scoreDescription = 'Severe Disease';
        break;
      case 5:
        scoreDescription = 'Very Severe Disease';
        break;
      default:
        scoreDescription = 'Unknown';
    }

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: AlertDialog(
            title: Center(child: Text('IGA Score: $score', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Condition:'),
                Text('$scoreDescription', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan)),
              ],
            ),
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _igaScore = score;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Okay',
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                Center(child: Text(title, style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
                Text('Based on your IGA Score, EMS will recommend several recommendations to improve your skin condition.', style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('What is IGA Score?', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('IGA Score is a five point scale that can provide global clinical evaluation of AD (Atopic Dermatitis) severity.'),
              SizedBox(height: 10),
              Text('Investigator’s Global Assessment',style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Image.asset(
                'images/severity_table.png',
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
                    textStyle: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addHistory(int score) {
    final formattedDate = _selectedDate != null ? "${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}" : "Unknown Date";
    final formattedTime = _selectedTime != null ? "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}" : "Unknown Time";
    final treatmentStep = _getTreatmentStep(score);

    Provider.of<HistoryProvider>(context, listen: false).addHistory(score, formattedDate, formattedTime, treatmentStep);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getScoreDescription(int score) {
    switch (score) {
      case 0:
        return 'Clear';
      case 1:
        return 'Almost\nClear';
      case 2:
        return 'Mild\nDisease';
      case 3:
        return 'Moderate\nDisease';
      case 4:
        return 'Severe\nDisease';
      case 5:
        return 'Very\nSevere\nDisease';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(35.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'IGA Score',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showIGAScoreDialog(context, index);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _igaScore == index ? Colors.white : Colors.cyan,
                                          foregroundColor: _igaScore == index ? Colors.cyan : Colors.white,
                                          side: BorderSide(color: Colors.white),
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(20),
                                        ),
                                        child: Text(
                                          '$index',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  icon: Icon(Icons.calendar_today, color: Colors.cyan),
                                  label: Text(
                                    _selectedDate != null
                                        ? "${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                                        : "Pick a Date",
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
                                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                                  onPressed: () {
                                    _selectTime(context);
                                  },
                                  icon: Icon(Icons.access_time, color: Colors.cyan),
                                  label: Text(
                                    _selectedTime != null
                                        ? "${_selectedTime!.format(context)}"
                                        : "Pick a Time",
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
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    side: BorderSide(color: Colors.cyan),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_igaScore != null && _selectedDate != null && _selectedTime != null)
                                ? () {
                                    _addHistory(_igaScore!);
                                    setState(() {
                                      _showSkinAnalysis = true;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Success!'),
                                          content: Text('Assessment has been made successfully.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              backgroundColor: (_igaScore != null && _selectedDate != null && _selectedTime != null) ? Colors.cyan : AppColors.primaryColor,
                              foregroundColor: (_igaScore != null && _selectedDate != null && _selectedTime != null) ? Colors.white : Colors.cyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: Text(
                              'Send',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: (_igaScore != null && _selectedDate != null && _selectedTime != null) ? Colors.white : Colors.cyan,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_showSkinAnalysis)
              Container(
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
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skin Analysis',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'IGA Score',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            _showImageAlertDialog(context);
                          },
                        ),
                      ],
                    ),
                    if (_igaScore != null) IGAChart(score: _igaScore!, getScoreDescription: _getScoreDescription),
                    const SizedBox(height: 10),
                    Divider(
                      color: Colors.cyan[100],
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Treatment Step',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            _showHelpDialog(context, 'Treatment Step');
                          },
                        ),
                      ],
                    ),
                    if (_igaScore != null) TreatmentStepChart(step: _getTreatmentStep(_igaScore!)),
                    if (_igaScore != null)
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final pageState = Provider.of<PageState>(context, listen: false);
                            pageState.updateAssessment(_igaScore!, _getTreatmentStep(_igaScore!));
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            widget.onTabTapped(2);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'See Recommendations',
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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

class IGAChart extends StatelessWidget {
  final int score;
  final String Function(int) getScoreDescription;

  const IGAChart({required this.score, required this.getScoreDescription, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Column(
              children: [
                Text(
                  '$index',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: index == score ? Colors.blue : Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: index == score ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  getScoreDescription(index),
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: index == score ? Colors.blue : Colors.black,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class TreatmentStepChart extends StatelessWidget {
  final int step;

  const TreatmentStepChart({required this.step, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Column(
              children: [
                Text(
                  'Step ${index + 1}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: index + 1 == step ? Colors.blue : Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: index + 1 == step ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}