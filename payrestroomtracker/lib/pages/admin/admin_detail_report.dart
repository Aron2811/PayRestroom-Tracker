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
            child: Column(
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
                const SizedBox(height: 30),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    report['report'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 97, 84, 158),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ]),
                const SizedBox(height: 20),
                Text(
                  'If theres another universe Please make some noise noise Give me a sign sign This cant be life If theres a point to losing love Repeating pain why? Its all the same I hate this place Stuck in this paradigm Dont believe in paradise This must be what Hell is like Theres got to be more got to be more Sick of this head of mine Intrusive thoughts they paralyze Nirvanas not as advertised Theres got to be more been here before',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      color: Color.fromARGB(255, 97, 84, 158),
                      fontSize: 15,
                      wordSpacing: 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
