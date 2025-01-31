import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pagestate.dart';
import 'assessmentpage.dart';
import 'recommendedpage.dart';
import 'historypage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'historyprovider.dart';
import 'filterstate.dart';
import 'authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "apikey",
        authDomain: "flutter-auth-cc778.firebaseapp.com",
        projectId: "flutter-auth-cc778",
        storageBucket: "flutter-auth-cc778.appspot.com",
        messagingSenderId: "352348488843",
        appId: "1:352348488843:web:1c447c1b3e9e2ca22e408e",
        databaseURL:
            "https://flutter-auth-cc778-default-rtdb.asia-southeast1.firebasedatabase.app", // Correct URL
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        // Provides HistoryProvider to the widget tree
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        // Provides PageState to the widget tree
        ChangeNotifierProvider(create: (context) => PageState()),
        // Provides FilterState to the widget tree
        ChangeNotifierProvider(create: (_) => FilterState()),
      ],
      // Starts the app with AuthPage
      child: const AuthPage(),
    ),
  );
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

// HomePage widget with state management
class HomePage extends StatefulWidget {
  static final GlobalKey<_HomePageState> homePageKey =
      GlobalKey<_HomePageState>();

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex =
      0; // Tracks the current index of the bottom navigation bar

  late final List<Widget> _pages; // List of pages for navigation

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePageContent(),
      AssessmentPage(onTabTapped: _onTabTapped),
      const RecommendedPage(),
      HistoryPage(),
    ];
  }

  // Updates the current index when a tab is tapped
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Change Password',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildEditButton(
                      context,
                      'Password',
                      Icons.lock_outline,
                      () => _showPasswordEditDialog(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: AppColors.primaryColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'Success!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text('Your password has been successfully updated.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordEditDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isCurrentPasswordVisible = false;
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: !isCurrentPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Current password',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrentPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isCurrentPasswordVisible =
                                !isCurrentPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: !isNewPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'New password',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isNewPasswordVisible = !isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (newPasswordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('New passwords do not match'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  final credential =
                                      EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: currentPasswordController.text,
                                  );
                                  await user
                                      .reauthenticateWithCredential(credential);
                                  await user.updatePassword(
                                      newPasswordController.text);
                                  Navigator.pop(context);
                                  _showSuccessDialog(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Password updated successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error updating password: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() => isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Log Out'),
          content: Text('Are you sure you want to log out?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomePage.homePageKey,
      body: Column(
        children: [
          // Custom AppBar with logout button
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(30, 187, 215, 1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: AppBar(
              title: const Text('My Eczema Journal'),
              elevation: 0,
              titleTextStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                wordSpacing: 1.5,
              ),
              backgroundColor: AppColors.primaryColor,
              centerTitle: true,
              toolbarHeight: 80,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Edit Profile') {
                      _showEditProfileDialog(context);
                    } else if (value == 'Log Out') {
                      _showLogoutConfirmationDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'Edit Profile',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Edit Profile'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Log Out',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Log Out'),
                          ],
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
          ),
          // Displays the current page based on the selected tab
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      // Bottom navigation bar with tabs
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            color: AppColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: GNav(
              backgroundColor: AppColors.primaryColor,
              color: Colors.white,
              activeColor: Colors.cyan,
              tabBackgroundColor: Colors.white,
              gap: 4,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              selectedIndex: _currentIndex,
              onTabChange: _onTabTapped,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.assessment,
                  text: 'Assessment',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.book,
                  text: 'Recommendation',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.history,
                  text: 'History',
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Content of the HomePage
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Removed Welcome message
            const DateButton(),
            const SizedBox(height: 16),
            const GraphSevere(),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: RecentAssessmentHistory(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Date filter buttons
class DateButton extends StatelessWidget {
  const DateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterState>(
      builder: (context, filterState, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: OverflowBar(
                spacing: 10,
                children: [
                  _buildFilterButton(context, 'Weekly', filterState),
                  _buildFilterButton(context, 'Monthly', filterState),
                  _buildFilterButton(context, 'Yearly', filterState),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Build filter buttons
  Widget _buildFilterButton(
      BuildContext context, String filter, FilterState filterState) {
    final isSelected = filterState.currentFilter == filter;

    return ElevatedButton(
      onPressed: () {
        filterState.updateFilter(filter);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.cyan[700] : AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
          vertical: 25,
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Text(
        filter,
        style: GoogleFonts.roboto(
          textStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Display a graph of severity scores
class GraphSevere extends StatefulWidget {
  const GraphSevere({super.key});

  @override
  State<GraphSevere> createState() => _GraphSevereState();
}

class _GraphSevereState extends State<GraphSevere> {
  // Method to calculate average scores based on the filter
  List<SeverityScoreData> _calculateAverageScores(
      List<Map<String, dynamic>> history, String filter) {
    if (history.isEmpty) return []; // Return an empty list if history is empty

    Map<String, List<int>> groupedScores =
        {}; // Map to group scores by time period

    for (var entry in history) {
      // Split the date string into day, month, and year
      List<String> dateParts = entry['date'].toString().split(' ');
      int day = int.parse(dateParts[0]);
      int month = _getMonthNumber(dateParts[1]);
      int year = int.parse(dateParts[2]);

      String key; // Key to group scores by time period
      // Determine the key based on the filter
      switch (filter) {
        case 'Weekly':
          int weekNumber = (day / 7).ceil();
          key = '${_getMonthName(month)} W$weekNumber';
          break;
        case 'Monthly':
          key = '${_getMonthName(month)} $year';
          break;
        case 'Yearly':
          key = year.toString();
          break;
        default:
          key = '${_getMonthName(month)} W1';
      }
      // Initialize the list if the key does not exist
      if (!groupedScores.containsKey(key)) {
        groupedScores[key] = [];
      }

      groupedScores[key]!.add(entry['score'] as int);
    }
    // Calculate the average scores for each time period
    List<SeverityScoreData> averageScores = groupedScores.entries.map((entry) {
      double average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return SeverityScoreData(entry.key, average);
    }).toList();
    // Sort the average scores by year
    averageScores.sort((a, b) => a.year.compareTo(b.year));
    return averageScores;
  }

  // Get month number from month name
  int _getMonthNumber(String monthName) {
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
    return months.indexOf(monthName) + 1;
  }

  // Get month name from month number
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoryProvider, FilterState>(
      builder: (context, historyProvider, filterState, child) {
        final averageScores = _calculateAverageScores(
            historyProvider.history, filterState.currentFilter);

        return Padding(
          padding: const EdgeInsets.all(14.0),
          child: Center(
            child: Container(
              height: 300,
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
              child: SfCartesianChart(
                margin: const EdgeInsets.all(10),
                title: ChartTitle(
                  text: 'Average IGA Score (${filterState.currentFilter})',
                  textStyle: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  alignment: ChartAlignment.center,
                ),
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Time Period'),
                  labelRotation: 45,
                  maximumLabels: 5,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Average IGA Score'),
                  interval: 1,
                  minimum: 0,
                  maximum: 5,
                ),
                series: <LineSeries<SeverityScoreData, String>>[
                  LineSeries<SeverityScoreData, String>(
                    dataSource: averageScores,
                    xValueMapper: (SeverityScoreData score, _) => score.year,
                    yValueMapper: (SeverityScoreData score, _) =>
                        score.severityScore,
                    markerSettings: const MarkerSettings(isVisible: true),
                  )
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Data model for severity scores
class SeverityScoreData {
  SeverityScoreData(this.year, this.severityScore);
  final String year;
  final double severityScore;
}

// Display recent assessment history
class RecentAssessmentHistory extends StatefulWidget {
  const RecentAssessmentHistory({super.key});

  @override
  _RecentAssessmentHistoryState createState() =>
      _RecentAssessmentHistoryState();
}

class _RecentAssessmentHistoryState extends State<RecentAssessmentHistory> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double horizontalMargin = constraints.maxWidth < 400 ? 8.0 : 16.0;

            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              padding: EdgeInsets.all(horizontalMargin),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Assessment History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: historyProvider.history.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(horizontalMargin),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.cyan[200]!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'No history available.',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: historyProvider.history.length > 10
                                ? 10
                                : historyProvider
                                    .history.length, //set max length of 10
                            itemBuilder: (context, index) {
                              final entry = historyProvider.history[
                                  historyProvider.history.length - 1 - index];
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.cyan[200]!),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date: ${entry['date']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'IGA Score: ${entry['score']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
