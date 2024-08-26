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
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportPage extends StatefulWidget {
  final LatLng? selectedMarkerPosition;
  final LatLng destination;

  const ReportPage({Key? key, this.selectedMarkerPosition, required this.destination}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}



class _ReportPageState extends State<ReportPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _restroomName = "Paid Restroom Name";

  @override
  void initState() {
    super.initState();
    _fetchPaidRestroomName();
    
  }

  Future<void> _fetchPaidRestroomName() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .where('position', isEqualTo: GeoPoint(widget.destination.latitude, widget.destination.longitude))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final fetchedName = data['Name'] as String? ?? "No name available";

        setState(() {
          _restroomName = fetchedName;
        });
      } else {
        setState(() {
          _restroomName = "No restroom found at this location";
        });
      }
    } catch (e) {
      setState(() {
        _restroomName = "Error fetching data";
      });
    }
  }

  Future<void> storeReport(String reportType, String reportContent) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('reports').add({
        'username': user.displayName,
        'photo': user.photoURL,
        'report': reportType,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'restroomName': _restroomName,
        'reportContent' : reportContent,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        appBar: AppBar(
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
                  context, 
                  'Facilities and amenities report',
                  "The restroom lacks necessary facilities and amenities according to the user's concern. The user is concerned about these deficiencies and hopes for a prompt response to address and rectify these issues. Your attention to this matter would be greatly appreciated to ensure that the restroom meets the necessary standards of comfort and hygiene.", 
                  FacilitiesDialog()
              ),
              SizedBox(height: 20),
              reportOption(
                  context, 
                  'Tag Location report', 
                  "The restroom tag location is not accurate according to the user's concern. The user is concerned about these deficiencies and hopes for a prompt response to address and rectify these issues. Your attention to this matter would be greatly appreciated to ensure that the restroom meets the necessary accuracy of the location.", 
                  TagLocationDialog()
              ),
              SizedBox(height: 20),
              reportOption(
                  context, 
                  'Lack of location details report',
                  "The restroom lacks of location details according to the user's concern. The user is concerned about these deficiencies and hopes for a prompt response to address and rectify these issues. Your attention to this matter would be greatly appreciated to ensure that the restroom meets the accuracy of location details", 
                  LackDetailsDialog()
              ),
              SizedBox(height: 20),
              reportOption(
                  context, 
                  'Direction report', 
                  "The restroom direction is not accurate according to the user's concern. The user is concerned about these deficiencies and hopes for a prompt response to address and rectify these issues. Your attention to this matter would be greatly appreciated to ensure that the restroom meets the accuracy of the direction.", 
                  DirectionDialog()
              ),
              SizedBox(height: 20),
              reportOption(
                  context, 
                  'Others', 
                  "", 
                  OthersReportPage(destination: widget.destination,)
              ),
              SizedBox(height: 250),
            ],
          ),
        ),
      ),
    );
  }

  Widget reportOption(BuildContext context, String reportType, String reportContent, Widget dialog) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () async {
          if (reportType != 'Others') {
            await storeReport(reportType, reportContent);
          }
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