import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/admin_report.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;

  ReportDetailPage({required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  LatLng destination = LatLng(14.303142147986497, 121.07613374318477);
  //formats the timestamp to dd, MMM, yyyy, hh:mm, a
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    GeoPoint geoPoint = GeoPoint(destination.latitude, destination.longitude);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 193, 184, 236),
          appBar: AppBar(
            title: const Text(
              'Report Detail',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            leading: BackButton(
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  _createRoute(AdminReport(
                    username: "",
                    report: "",
                    destination: geoPoint,
                  )),
                );
              },
            ),
            backgroundColor: const Color.fromARGB(255, 97, 84, 158),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Creates a row displaying a user profile picture, username, and timestamp, with appropriate styling and spacing.
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(widget.report['photo'] ?? ''),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.report['username'] ?? 'Anonymous',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 97, 84, 158),
                                    ),
                                  ),
                                  Text(
                                    widget.report['timestamp'] != null
                                        ? _formatTimestamp(widget
                                            .report['timestamp'] as Timestamp)
                                        : '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(height: 70),
                      // Displays a centered column with restroom name and report details, styled with specific colors and fonts.
                      Center(
                        child: Column(
                          children: [
                            Text(
                              widget.report['restroomName'] ??
                                  'Unknown Restroom',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 97, 84, 158),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.report['report'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 97, 84, 158),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      //displays the report content of the user
                      Text(
                        widget.report['reportContent'] ?? '',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontSize: 15,
                          wordSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 150),
                      //dispalys the confirmation of the report
                      Text(
                        'Thank you for your attention to this matter. We appreciate your prompt action in addressing the issues reported. Your efforts are greatly valued.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Text(
                        'If you require any further information or assistance, please do not hesitate to reach out. Thank you once again for your cooperation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 84, 158),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
