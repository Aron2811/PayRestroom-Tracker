import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/apprate_dialog.dart';
import 'package:flutter_button/pages/intro_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Stack(children: [
      // Background Image
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),

      // Foreground content
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            // Image
            GestureDetector(
              child: Image.asset('assets/Loading.gif'),
              onTap: () {
                Navigator.push(
                    context,
                    _createRoute(IntroPage(
                      report: '',
                    )));
              },
            ),
            const SizedBox(height: 10),
            // Text

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Text(
                'Tap the logo to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => const AppRateDialog());
              },
              child: Text(
                'Rate App',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            )
          ]))
    ])));
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
