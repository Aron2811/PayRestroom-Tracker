import 'package:flutter/material.dart';

class DirectionDialog extends StatelessWidget {
  const DirectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: [
      Center(
          child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Icon(Icons.check_circle_rounded,
              color: Color.fromARGB(255, 97, 84, 158), size: 50),
          const SizedBox(
            height: 30,
          ),
          const Text(
            "You Selected",
            style: TextStyle(
                color: Color.fromARGB(255, 97, 84, 158),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Direction report",
              style: TextStyle(
                  color: Color.fromARGB(255, 97, 84, 158),
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "We use your feedback to help our systems learn when something isn't right",
            style: TextStyle(
                color: Color.fromARGB(255, 97, 84, 158), fontSize: 17),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(
            height: 20,
          ),
          RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                  style: TextStyle(
                      color: Color.fromARGB(255, 97, 84, 158), fontSize: 13),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Note: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'We may inform the Paid Restroom to address this report',
                    )
                  ])),
          const SizedBox(
            height: 20,
          ),
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
                  foregroundColor: const Color.fromARGB(255, 135, 125, 186),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ))
        ],
      ))
    ]);
  }
}
