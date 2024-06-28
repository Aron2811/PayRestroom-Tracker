import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';

class AdminReport extends StatelessWidget {
  final List _reviews = [
    'report 1',
    'report 2',
    'report 3',
    'report 4',
    'report 5',
    'report 6',
    'report 7',
    'report 8',
  ];
  final String username;
  AdminReport({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              _createRoute(AdminPage(username: username)),
            );
          },
        ),
        title: const Text(
          'Report',
          style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 3),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return AllReviews(child: _reviews[index]);
                }),
          ),
        ],
      ),
    );
  }
}

class AllReviews extends StatelessWidget {
  AllReviews({required this.child});

  final String child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 150,
        color: Colors.deepPurple[100],
        child: Row(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Container(
                child: const Icon(
                  Icons.person_2_rounded,
                  color: Color.fromARGB(255, 97, 84, 158),
                  size: 30,
                ),
                color: Colors.white,
                height: 40,
                width: 40,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Username",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Report",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Report",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
              ],
            ),
          ]),
        ]),
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
