import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/apprate_dialog.dart';
import 'package:flutter_button/pages/intro_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
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
                Image.asset('assets/Loading.gif'),

                const SizedBox(height: 30),
                // Text

                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
                //   child:
                Container(
                  height: 50,
                  width: 300,
                 /// color: Colors.black,
                  child: GestureDetector(
                    child: Text(
                      'Tap here to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          _createRoute(IntroPage(
                            report: '',
                          )));
                    },
                  ),
                ),
                //  ),
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
