import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pagestate.dart';
import 'package:provider/provider.dart';

class RecommendedPage extends StatelessWidget {
  const RecommendedPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<PageState>(context);
    final int? treatmentStep = pageState.treatmentStep;
    final List<String> recommendations = _getRecommendations(treatmentStep ?? 0);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40.0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendation for Step ${treatmentStep ?? ''}',
                style: GoogleFonts.roboto(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: treatmentStep == null ? Colors.white : Colors.cyan,
                ),
              ),
              Divider(
                color: treatmentStep == null ? Colors.white : Colors.grey[300],
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              const SizedBox(height: 10),
              Text(
                'Based on your treatment step, here are some recommendations:',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: treatmentStep == null ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: recommendations.isEmpty
                  ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Currently there is no assessment found for the recommendations.',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              recommendations[index],
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}