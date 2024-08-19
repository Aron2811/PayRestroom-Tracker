import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          height: 586,
          width: 300,
          child: AnotherCarousel(
            borderRadius: true,
            boxFit: BoxFit.cover,
            radius: const Radius.circular(10),
            autoplay: false,
            dotBgColor: Colors.transparent,
            dotIncreaseSize: 1.5,
            images: const [
              AssetImage('assets/1.png'),
              AssetImage('assets/2.png'),
              AssetImage('assets/3.png'),
              AssetImage('assets/4.png'),
              AssetImage('assets/5.png'),
              AssetImage('assets/6.png'),
              AssetImage('assets/7.png'),
              AssetImage('assets/8.png'),
            ],
            showIndicator: true,
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
                "Close",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ))
      ],
      title: const Text(
        'Tutorial',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 106, 91, 169),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}