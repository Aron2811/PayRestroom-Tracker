import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_button/pages/admin/admin_report.dart';
import 'package:flutter_button/pages/intro_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key, required this.username});
  final String username;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Stack(children: [
      // Background Image
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60.0),
          child: SizedBox.shrink(), // Placeholder for an empty child
        ),
        Container(
          margin: const EdgeInsets.only(
              top: 50, right: 25), // Adjust the value to your needs
          child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                  Navigator.push(context, _createRoute(IntroPage()));
                },
                child: Icon(Icons.logout_rounded, color: Colors.white),
              )),
        ),
      ]),

      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 150),

        // Image
        Image.asset(
          'assets/PO_tag.png',
          width: 230,
          height: 230,
        ),

        SizedBox(height: 30),
        Text(
          'Hello',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: 5),
        Text(
          '$username',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: EdgeInsets.only(
                    top: 230,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20)),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                _createRoute(AdminMap(
                                  username: username,
                                )));
                          },
                          child: Container(
                            color: Colors.white,
                            width: 175,
                            height: 50,
                            child: Row(children: [
                              SizedBox(
                                width: 35,
                                height: 10,
                              ),
                              Icon(
                                Icons.map_rounded,
                                color: Color.fromARGB(255, 132, 119, 197),
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "View Map",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 132, 119, 197),
                                ),
                              ),
                            ]),
                          )))),
              SizedBox(
                width: 5,
              ),
              Padding(
                  padding: EdgeInsets.only(
                    top: 230,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Container(
                          color: Colors.white,
                          width: 180,
                          height: 50,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  _createRoute(AdminReport(
                                    username: username,
                                  )));
                            },
                            child: Row(children: [
                              SizedBox(
                                width: 35,
                                height: 10,
                              ),
                              Icon(
                                Icons.report_problem_rounded,
                                color: Color.fromARGB(255, 132, 119, 197),
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "View Report",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 132, 119, 197)),
                              ),
                            ]),
                          )))),
            ]),
          ],
        )
      ])
    ])));
  }
}
