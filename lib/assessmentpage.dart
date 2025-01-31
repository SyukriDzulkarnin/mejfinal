import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'theme.dart';
import 'pagestate.dart';
import 'historyprovider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AssessmentPage extends StatefulWidget {
  final Function(int) onTabTapped;

  const AssessmentPage({required this.onTabTapped, super.key});

  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  int? _igaScore;
  File? _image;
  String? _webImage;
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Interpreter? _interpreter;
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions()..threads = 1;
      _interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
        options: interpreterOptions,
      );
    } catch (e) {
      print('Error loading model: $e');
      // Show error dialog to user
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Model Loading Error'),
            content:
                Text('Unable to load the AI model. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String> classifyImage(File image) async {
    try {
      print('Starting image classification...');

      // Validate image n decode to byte then to image object
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
      if (imageInput == null) {
        print('Failed to decode image');
        return 'error';
      }
      print('Image decoded successfully');

      // Resize and normalize with 1 batch size and 3 class
      img.Image resizedImg =
          img.copyResize(imageInput, width: 224, height: 224);
      var inputArray =
          List.filled(1 * 224 * 224 * 3, 0.0).reshape([1, 224, 224, 3]);

      // iterate throught each pixel and extract rgb for each pixel
      for (var y = 0; y < resizedImg.height; y++) {
        for (var x = 0; x < resizedImg.width; x++) {
          var pixel = resizedImg.getPixel(x, y);
          inputArray[0][y][x][0] = pixel.getChannel(img.Channel.red) / 255.0;
          inputArray[0][y][x][1] = pixel.getChannel(img.Channel.green) / 255.0;
          inputArray[0][y][x][2] = pixel.getChannel(img.Channel.blue) / 255.0;
        }
      }

      print('Image preprocessing completed');

      // Check if interpreter is initialized
      if (_interpreter == null) {
        print('Interpreter is null');
        return 'error';
      }

      // Run inference with 1 output and 3 possible class
      var outputArray = List.filled(1 * 3, 0.0).reshape([1, 3]);
      _interpreter!.run(inputArray, outputArray);

      print('Model output: ${outputArray[0]}');

      // Get model output
      var outputs = outputArray[0];
      double maxScore = outputs[0];
      int predictedClass = 0;

      for (var i = 1; i < outputs.length; i++) {
        if (outputs[i] > maxScore) {
          maxScore = outputs[i];
          predictedClass = i;
        }
      }

      print('Predicted class: $predictedClass with score: $maxScore');

      // Map prediction to severity
      switch (predictedClass) {
        case 0:
          print('Classified as mild');
          return 'mild';
        case 1:
          print('Classified as moderate');
          return 'moderate';
        case 2:
          print('Classified as severe');
          return 'severe';
        default:
          print('Classification error');
          return 'error';
      }
    } catch (e) {
      print('Error during classification: $e');
      return 'error';
    }
  }

  // Picks an image from the specified source
  Future<void> _getImage(ImageSource source) async {
    if (_isPickerActive) {
      return;
    }

    try {
      _isPickerActive = true;
      final XFile? selectedImage = await _picker.pickImage(source: source);

      if (selectedImage != null) {
        setState(() {
          if (kIsWeb) {
            _webImage = selectedImage.path;
          } else {
            _image = File(selectedImage.path);
          }
        });
        if (_image != null) {
          await classifyImage(_image!);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      _isPickerActive = false;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Opens a date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Opens a time picker dialog
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Resets the date and time to the current date and time
  void _resetDateTime() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  // Sends the assessment by classifying the image and showing the IGA score dialog
  void _sendAssessment() async {
    if (_image != null || _webImage != null) {
      File imageFile = _image ?? File(_webImage!);
      print('Starting assessment...');
      String classification = await classifyImage(imageFile);
      print('Classification result: $classification');

      if (classification != 'error') {
        setState(() {
          switch (classification) {
            case 'mild':
              _igaScore = 2;
              break;
            case 'moderate':
              _igaScore = 3;
              break;
            case 'severe':
              _igaScore = 4;
              break;
          }
        });
        _showIGAScoreDialog(context, _igaScore!);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Could not classify image. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Shows a dialog with the IGA score and its description
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
            title: Center(
                child: Text('IGA Score: $score',
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.bold))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Condition:'),
                Text('$scoreDescription',
                    style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan)),
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
                    _addHistory(score);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
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

  // Shows a help dialog with information about the IGA score
  void _showHelpDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                Center(
                    child: Text(title,
                        style: GoogleFonts.roboto(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
                Text(
                    'Based on your IGA Score, EMS will recommend several recommendations to improve your skin condition.',
                    style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
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

  // Shows an alert dialog with information about the IGA score that have a image of the IGA Table
  void _showImageAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text('What is IGA Score?',
                  style: GoogleFonts.roboto(
                      fontSize: 20, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'IGA Score is a five point scale that can provide global clinical evaluation of AD (Atopic Dermatitis) severity.'),
              SizedBox(height: 10),
              Text('Investigator’s Global Assessment',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Image.asset(
                'assets/severity_table.png',
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

  // Adds the assessment history to the provider
  void _addHistory(int score) {
    final formattedDate =
        "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}";
    final formattedTime = "${_selectedTime.format(context)}";
    final treatmentStep = _getTreatmentStep(score);

    Provider.of<HistoryProvider>(context, listen: false)
        .addHistory(score, formattedDate, formattedTime, treatmentStep);
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

  // Get the treatment step based on the score
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                width: double.infinity,
                child: Column(
                  children: [
                    if (kIsWeb && _webImage != null)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.network(
                          _webImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (!kIsWeb && _image != null)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _getImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library,
                                color: Colors.white),
                            label: const Text('Upload Image',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.white),
                            label: const Text('Select Date',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.access_time,
                                color: Colors.white),
                            label: const Text('Select Time',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Date: ${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ),
                                Text(
                                  'Time: ${_selectedTime.format(context)}',
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _resetDateTime,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 25),
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendAssessment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 20),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Send Assessment',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_igaScore != null)
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
                      if (_igaScore != null) IGAChart(score: _igaScore!),
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
                      if (_igaScore != null)
                        TreatmentStepChart(step: _getTreatmentStep(_igaScore!)),
                      if (_igaScore != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                final pageState = Provider.of<PageState>(
                                    context,
                                    listen: false);
                                pageState.updateAssessment(
                                    _igaScore!, _getTreatmentStep(_igaScore!));
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                widget.onTabTapped(2);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 20),
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'See Recommendations',
                                style: GoogleFonts.roboto(
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Determines the treatment step based on the IGA score
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

// Display the IGA score chart
class IGAChart extends StatelessWidget {
  final int score;

  const IGAChart({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return Expanded(
              child: Column(
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
                  SizedBox(
                    width: 60,
                    height: 30,
                    child: Text(
                      _getScoreDescription(index),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: index == score ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // Get the description of the IGA score
  String _getScoreDescription(int score) {
    switch (score) {
      case 0:
        return 'Clear';
      case 1:
        return 'Almost\nClear';
      case 2:
        return 'Mild';
      case 3:
        return 'Moderate';
      case 4:
        return 'Severe';
      case 5:
        return 'Very\nSevere';
      default:
        return '';
    }
  }
}

// Display the treatment step chart
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
