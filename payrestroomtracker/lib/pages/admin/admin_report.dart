import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/admin_detail_report.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminReport extends StatefulWidget {
  final String username;
  final String report;
  final GeoPoint destination;

  AdminReport({
    required this.username,
    required this.report,
    required this.destination,
  });

  @override
  _AdminReportState createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    final querySnapshot = await _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      reports = querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    });
  }

  Future<void> _updateReadStatus(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({'read': true});
    _fetchReports();
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              _createRoute(
                  AdminPage(username: widget.username, report: widget.report)),
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
            child: reports.isEmpty
                ? Center(
                    child: Text(
                      'No reports found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];

                      return ListTile(
                        tileColor: report['read']
                            ? const Color.fromARGB(0, 255, 255, 255)
                            : Color.fromARGB(209, 181, 167, 243),
                        title: Text(
                          report['restroomName'] ?? 'Unknown Restroom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: report['read']
                                ? Color.fromARGB(255, 97, 84, 158)
                                : const Color.fromARGB(230, 80, 77, 81),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          report['report'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: report['read']
                                ? Color.fromARGB(255, 97, 84, 158)
                                : const Color.fromARGB(230, 80, 77, 81),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          _updateReadStatus(report['id']);
                          Navigator.push(
                            context,
                            _createRoute(ReportDetailPage(report: report)),
                          );
                        },
                        leading: Container(
                          width: 50, // Adjust the width as needed
                          child: Text(
                            report['username'] ?? 'Anonymous',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        trailing: Text(
                          report['timestamp'] != null
                              ? _formatTimestamp(
                                  report['timestamp'] as Timestamp)
                              : '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    },
                  ),
          ),
        ],
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
