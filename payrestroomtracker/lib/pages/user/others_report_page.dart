import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_button/pages/dialog/others_report.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OthersReportPage extends StatefulWidget {
  final LatLng destination;

  const OthersReportPage({super.key, required this.destination});

  @override
  State<OthersReportPage> createState() => _OthersReportPageState();
}

class _OthersReportPageState extends State<OthersReportPage> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _restroomName = ""; 

    @override
  void initState() {
    super.initState();
    _fetchPaidRestroomName();
    
  }
   // Fetch the restroom name from Firestore
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
  // Store the report in Firestore
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
        'reportContent': reportContent,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 193, 184, 236),
        appBar: AppBar(
          title: const Text(
            'Report',
            style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 3),
          ),
          backgroundColor: const Color.fromARGB(255, 97, 84, 158),
          centerTitle: true,
          actions: <Widget>[
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
              onPressed: () async {
                await storeReport('Others', _textController.text);
                showDialog(
                  context: context,
                  builder: (context) => OthersReportDialog(
                    reportContent: _textController.text,
                    destination: widget.destination,
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: Text(
                    'Others',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 97, 84, 158),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: Text(
                    'Report Description',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 97, 84, 158),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 115, 99, 183),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}