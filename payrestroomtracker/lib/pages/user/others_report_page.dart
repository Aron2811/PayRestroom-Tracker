import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/others_report.dart';

class OthersReportPage extends StatelessWidget {
  const OthersReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => const OthersReportDialog());
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
              const Padding(
                padding: EdgeInsets.all(30),
                child: TextField(
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 115, 99, 183)),
                      ),
                    )),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ],
      ),
    );
  }
}
