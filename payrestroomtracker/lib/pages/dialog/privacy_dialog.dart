import 'package:flutter/material.dart';

class PrivacyDialog extends StatelessWidget {
  const PrivacyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        const Text(
          "Your privacy is important to us and we want to make it easy for you to understand your data settings. You can check them now or at any time within the app. We will collect and use your personal data in accordance with our privacy policy. Please read this to understand the data we collect and why and your rights regarding this data.",
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 17,
            color: Color.fromARGB(255, 115, 99, 183),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                enableFeedback: false,
                backgroundColor: Colors.white,
                minimumSize: const Size(150, 40),
                alignment: Alignment.center,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: Color.fromARGB(
                        255, 149, 134, 225), // Set the border color
                    width: 2.0, // Set the border width
                  ),
                ),
                foregroundColor: Color.fromARGB(255, 135, 125, 186),
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
              child: const Text(
                "I Agree",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ))
      ],
      title: const Text(
        'Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 106, 91, 169),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
