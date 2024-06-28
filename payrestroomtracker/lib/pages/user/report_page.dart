import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/direction_report.dart';
import 'package:flutter_button/pages/dialog/lackdetails_report.dart';
import 'package:flutter_button/pages/user/map_page.dart';
import 'package:flutter_button/pages/dialog/facilities_report.dart';
import 'package:flutter_button/pages/dialog/taglocation_report.dart';
import 'package:flutter_button/pages/user/others_report_page.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.push(context, _createRoute(MapPage()));
            },
          ),
          title: const Text(
            'Report',
            style:
                TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 3),
          ),
          backgroundColor: const Color.fromARGB(255, 97, 84, 158),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => FacilitiesDialog());
                  },
                  child: Container(
                    color: Colors.deepPurple[100],
                    width: 343,
                    height: 60,
                    child: Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Facilities and amenities report",
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 73,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => TagLocationDialog());
                  },
                  child: Container(
                    color: Colors.deepPurple[100],
                    width: 343,
                    height: 60,
                    child: Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Tag Location report",
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 145,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => LackDetailsDialog());
                  },
                  child: Container(
                    color: Colors.deepPurple[100],
                    width: 343,
                    height: 60,
                    child: Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Lack of location details report",
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 75,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => DirectionDialog());
                  },
                  child: Container(
                    color: Colors.deepPurple[100],
                    width: 343,
                    height: 60,
                    child: Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Direction report",
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 170,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, _createRoute(OthersReportPage()));
                  },
                  child: Container(
                    color: Colors.deepPurple[100],
                    width: 343,
                    height: 60,
                    child: Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Others",
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 230,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 250,
              ),
            ],
          ),
        ));
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
