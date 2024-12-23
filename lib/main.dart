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

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PageState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  static final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePageContent(),
      AssessmentPage(onTabTapped: _onTabTapped),
      const RecommendedPage(),
      const HistoryPage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomePage.homePageKey,
      body: Column(
        children: [
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
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: GNav(
              backgroundColor: AppColors.primaryColor,
              color: Colors.white,
              activeColor: Colors.cyan,
              tabBackgroundColor: Colors.white,
              gap: 8,
              selectedIndex: _currentIndex,
              onTabChange: _onTabTapped,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.assessment,
                  text: 'Assessment',
                ),
                GButton(
                  icon: Icons.book,
                  text: 'Recommendation',
                ),
                GButton(
                  icon: Icons.history,
                  text: 'History',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 20),
        DateButton(),
        SizedBox(height: 20),
        GraphSevere(),
        SizedBox(height: 20),
        RecentAssessmentHistory(),
      ],
    );
  }
}

class DateButton extends StatefulWidget {
  const DateButton({super.key});

  @override
  State<DateButton> createState() => _DateButtonState();
}

class _DateButtonState extends State<DateButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OverflowBar(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
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
                'Weekly',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 25,
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                'Monthly',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 25),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                'Yearly',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class GraphSevere extends StatefulWidget {
  const GraphSevere({super.key});

  @override
  State<GraphSevere> createState() => _GraphSevereState();
}

class _GraphSevereState extends State<GraphSevere> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Center(
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
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Eczema Severity Score',
              textStyle: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: ChartAlignment.center,
              borderWidth: 1,
            ),
            primaryXAxis: const CategoryAxis(
              title: AxisTitle(text: 'Month'),
            ),
            primaryYAxis: const NumericAxis(
              title: AxisTitle(text: 'Scorad Score'),
              interval: 5,
              minimum: 20,
            ),
            series: <LineSeries<SeverityScoreData, String>>[
              LineSeries<SeverityScoreData, String>(
                dataSource: <SeverityScoreData>[
                  SeverityScoreData('Jan', 35),
                  SeverityScoreData('Feb', 28),
                  SeverityScoreData('Mar', 34),
                  SeverityScoreData('Apr', 32),
                  SeverityScoreData('May', 40)
                ],
                xValueMapper: (SeverityScoreData severityScore, _) =>
                    severityScore.year,
                yValueMapper: (SeverityScoreData severityScore, _) =>
                    severityScore.severityScore,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SeverityScoreData {
  SeverityScoreData(this.year, this.severityScore);
  final String year;
  final double severityScore;
}

class RecentAssessmentHistory extends StatefulWidget {
  const RecentAssessmentHistory({super.key});

  @override
  _RecentAssessmentHistoryState createState() =>
      _RecentAssessmentHistoryState();
}

class _RecentAssessmentHistoryState extends State<RecentAssessmentHistory> {
  final List<Map<String, String>> history = [
    {'date': '23 November 2024', 'score': '0'},
    {'date': '24 November 2024', 'score': '1'},
    {'date': '25 November 2024', 'score': '2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Assessment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          ...history.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['date']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'IGA Score: ${entry['score']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}