import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/privacy&policy.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Terms and Conditions for Paid Restroom Listings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "1. Agreement to Terms",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "By submitting a restroom for listing, you ('Owner') agree to these terms. Non-compliance may result in removal or suspension of your listing.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "2. Submission Requirements",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Provide accurate restroom details, including address, amenities, and hours. Upload proof of ownership (e.g., lease or business license).",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "3. Verification",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Listings are reviewed for authenticity. Approval or rejection will be communicated within 7 business days.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "4. Payment",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Pay a monthly subscription for your listing to remain visible. Late or non-payment may lead to suspension.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "5. Tag and Visibility",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Approved listings get a tag (e.g., 'Verified') to improve visibility, based on your subscription plan.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "6. Refunds",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Payments are non-refundable unless required by law. Rejected listings will have any initial payment refunded.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "7. Content Rights",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "You grant the app rights to use submitted information for promotional and operational purposes. Ensure uploaded files don’t infringe on third-party rights.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "8. Termination",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Listings may be removed for misuse or policy violations.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "9. Changes to Terms",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Terms may be updated. Continued use indicates acceptance of changes.",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text(
                "I Agree",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
