import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/user/userlogin_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  //check if user is logged in if user is then if user click the user it will direct them to map but if logged out it will direct to userloginpage
  void _handleUserButton(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, navigate to the map page
      Navigator.pushNamed(context, '/mappage');
    } else {
      // User is not logged in, navigate to the login page
      Navigator.push(context, _createRoute(UserLoginPage()));
    }
  }

  Route _createRoute(Widget page) {
    return MaterialPageRoute(builder: (context) => page);
  }

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
                // Animated Logo
                Image.asset('assets/Loading.gif'),

                const SizedBox(height: 30),

                // text to continuw
                Container(
                  height: 50,
                  width: 300,
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
                      _handleUserButton(context);
                    },
                  ),
                ),
              ]))
        ])));
  }
}

// transition frame
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
