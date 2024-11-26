import 'package:flutter/material.dart';

class ReportUser extends StatelessWidget {
  const ReportUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report a User"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: const Text(
            'This is the Report a User page.\n\nHere you can report users.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
