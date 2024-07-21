import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/direction_report.dart';
import 'package:flutter_button/pages/dialog/lackdetails_report.dart';
import 'package:flutter_button/pages/user/map_page.dart';
import 'package:flutter_button/pages/dialog/facilities_report.dart';
import 'package:flutter_button/pages/dialog/taglocation_report.dart';
import 'package:flutter_button/pages/user/others_report_page.dart';
import 'package:flutter_button/pages/admin/admin_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeReport(String reportType) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('reports').add({
        'username': user.displayName, 
        'photo': user.photoURL,
        'report': reportType,
        'timestamp': FieldValue.serverTimestamp(),
        
      });
    }
  }

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
          style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 3),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            reportOption(
                context, 'Facilities and amenities report', FacilitiesDialog()),
            SizedBox(height: 20),
            reportOption(context, 'Tag Location report', TagLocationDialog()),
            SizedBox(height: 20),
            reportOption(context, 'Lack of location details report',
                LackDetailsDialog()),
            SizedBox(height: 20),
            reportOption(context, 'Direction report', DirectionDialog()),
            SizedBox(height: 20),
            reportOption(context, 'Others', OthersReportPage()),
            SizedBox(height: 250),
          ],
        ),
      ),
    );
  }

  Widget reportOption(BuildContext context, String reportType, Widget dialog) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () async {
          await storeReport(reportType);
          showDialog(
            context: context,
            builder: (context) => dialog,
          );
        },
        child: Container(
          color: Colors.deepPurple[100],
          width: 343,
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 20),
              Text(
                reportType,
                style: TextStyle(
                  color: Color.fromARGB(255, 97, 84, 158),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color.fromARGB(255, 97, 84, 158),
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
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