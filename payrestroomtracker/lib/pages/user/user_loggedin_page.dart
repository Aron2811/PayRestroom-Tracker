import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/tutorial_dialog.dart';
import 'package:flutter_button/pages/intro_page.dart';
import 'package:flutter_button/pages/user/map_page.dart';
// Import the intro page

class UserLoggedInPage extends StatefulWidget {
  const UserLoggedInPage({super.key});

  @override
  State<UserLoggedInPage> createState() => _UserLoggedInPageState();
}

class _UserLoggedInPageState extends State<UserLoggedInPage> {
  @override
  void initState() {
    super.initState();
    // Show the tutorial dialog when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => const TutorialDialog(),
      );
    });
  }

  Future<bool> onBackButtonPressed() async {
    // Navigate to the intro page
    Navigator.of(context).push(_createRoute(IntroPage(report: "",)));
    return false; // Prevents the app from closing
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackButtonPressed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            children: [
              // Background Image
              Container(
                decoration: const BoxDecoration(
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
                    const SizedBox(height: 130),

                    // Image
                    Image.asset(
                      'assets/PO_tag.png',
                      width: 250,
                      height: 250,
                    ),

                    const SizedBox(height: 60),

                    // Text
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                      child: Text(
                        'You are now logged in',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        enableFeedback: false,
                        backgroundColor: const Color.fromARGB(255, 226, 223, 229),
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 115, 99, 183),
                          width: 4.0,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, _createRoute(MapPage()));
                      },
                      label: const Text("View Map"),
                      icon: const Icon(
                        Icons.map_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ),

                    const SizedBox(
                      height: 50,
                    ),

                    GestureDetector(
                      child: Container(
                        height: 50,
                        width: 300,
                        color: Colors.transparent,
                        alignment: AlignmentDirectional.center,
                        child: const Text("How to use this app",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            )),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => const TutorialDialog());
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
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
