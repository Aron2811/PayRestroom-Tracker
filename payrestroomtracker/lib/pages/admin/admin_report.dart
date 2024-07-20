import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReport extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String username;
  final String report;
  AdminReport({required this.username, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              _createRoute(AdminPage(username: username, report: report)),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reports found.'));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final reportData = reports[index];
              return AllReviews(
                username: reportData['username'],
                photo: reportData['photo'],
                report: reportData['report'],
                child: reportData['report'],
              );
            },
          );
        },
      ),
    );
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
      },
    );
  }
}

class AllReviews extends StatelessWidget {
  final String username;
  final String report;
  final String? photo;
  AllReviews(
      {required this.username,
      required this.report,
      required this.photo,
      required this.child});

  final String child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 150,
        color: Colors.deepPurple[100],
        child: Row(
          children: [
            SizedBox(width: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Container(
                child: photo != null
                    ? Image.network(photo!,
                        height: 40, width: 40, fit: BoxFit.cover)
                    : Icon(
                        Icons.person_2_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                        size: 30,
                      ),
                color: Colors.white,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text(
                  username,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  report,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Report',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
