import 'package:flutter/material.dart';

class ReportUser extends StatelessWidget {
  final String userName;
  final String location;
  final String restroomName; // Add restroomName

  const ReportUser({
    Key? key,
    required this.userName,
    required this.location,
    required this.restroomName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report User'),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Restroom Name: $restroomName',
                style: TextStyle(fontSize: 18)),
            Text('Username: $userName', style: TextStyle(fontSize: 18)),

            // Add your report functionality here
          ],
        ),
      ),
    );
  }
}
