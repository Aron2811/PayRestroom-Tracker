import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  ReportDetailPage({required this.report});

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(report['photo'] ?? ''),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['username'] ?? 'Anonymous',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 97, 84, 158),
                                ),
                              ),
                              Text(
                                report['timestamp'] != null
                                    ? _formatTimestamp(
                                        report['timestamp'] as Timestamp)
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
                  Center(
                    child: Column(
                      children: [
                        Text(
                          report['restroomName'] ?? 'Unknown Restroom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 97, 84, 158),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          report['report'] ?? '',
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
                  Text(
                    report['reportContent'] ?? '',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Color.fromARGB(255, 97, 84, 158),
                      fontSize: 15,
                      wordSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 150),
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
    );
  }
}