import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter_button/pages/user/user_loggedin_page.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,

      // for tutorial dialog details
      actions: [
        SizedBox(
          height: 300,
          width: 250,
          child: AnotherCarousel(
            borderRadius: false,
            boxFit: BoxFit.cover,
            //radius: const Radius.circular(10),
            autoplay: false,
            dotBgColor: Colors.transparent,
            dotIncreaseSize: 1.5,
            dotSpacing: 15,
            images: const [
              AssetImage('assets/tutorial1.png'),
              AssetImage('assets/tutorial4.png'),
              AssetImage('assets/tutorial2.png'),
              AssetImage('assets/tutorial5.png'),
              AssetImage('assets/tutorial3.png'),
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
               // Navigator.push(context, _createRoute(const UserLoggedInPage()));
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

Route _createRoute(Widget child) {
  return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}
