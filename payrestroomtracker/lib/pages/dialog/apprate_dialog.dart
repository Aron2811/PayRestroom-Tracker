import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart' as custom_rating_bar;

class AppRateDialog extends StatelessWidget {
  const AppRateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Rate our App',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 106, 91, 169),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enjoyed the convenience? We'd love to hear your feedback—please rate our paid restroom app!",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          custom_rating_bar.RatingBar(
            size: 30,
            alignment: Alignment.center,
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            emptyColor: Colors.grey,
            filledColor: const Color.fromARGB(255, 97, 84, 158),
            halfFilledColor: const Color.fromARGB(255, 186, 176, 228),
            onRatingChanged: (p0) {},
            initialRating: 0,
            maxRating: 5,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: const Size(150, 40),
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: Color.fromARGB(255, 149, 134, 225),
                  width: 2.0,
                ),
              ),
              foregroundColor: const Color.fromARGB(255, 135, 125, 186),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            child: const Text(
              "Remind me Later",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(100, 40),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 149, 134, 225),
                      width: 2.0,
                    ),
                  ),
                  foregroundColor: const Color.fromARGB(255, 135, 125, 186),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(50, 40),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 149, 134, 225),
                      width: 2.0,
                    ),
                  ),
                  foregroundColor: const Color.fromARGB(255, 135, 125, 186),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  "Ok",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ]),
      ],
    );
  }
}