import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/ownersRestroomFillupForm.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy",style: TextStyle(color: Colors.white)),
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
                      "Privacy Policy for Paid Restroom Listings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "1. Data Collection",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "We collect your contact details, restroom information, and proof of ownership (e.g., lease or license) during submission.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "2. Purpose",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Data is used for verification, legal compliance, and ensuring only verified restrooms are listed.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "3. Storage and Security",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Your data is securely stored and accessed only by authorized personnel for verification.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "4. Data Usage",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Proof documents are used for verification only and shared with third parties only as required by law. Restroom details may be displayed to app users.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "5. Payment",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Payments are processed by third-party gateways; we do not store payment details.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "6. Data Retention",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Proof documents are kept only for verification purposes. Listing data stays active during your subscription and may be archived after termination.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "7. Your Rights",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "You can request access, changes, or deletion of your data. Deleting proof documents may remove your listing.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "8. Consent",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "By submitting a listing, you agree to the collection and use of your data as outlined.",
                    ),
                    SizedBox(height: 8),
                    Text(
                      "9. Policy Updates",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "We may update this policy; changes will be communicated to registered owners.",
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
                    builder: (context) => const OwnersPaidrestroomFillupform(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 97, 84, 158), // Button color
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
