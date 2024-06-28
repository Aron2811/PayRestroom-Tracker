import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/others_report.dart';

class OthersReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 193, 184, 236),
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
            icon: Icon(
              Icons.send_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context, builder: (context) => OthersReportDialog());
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
                child: const Text(
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
                child: const Text(
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    side: BorderSide(
                      color: Color.fromARGB(
                          255, 115, 99, 183), //Set the border color
                      width: 2.0,
                    ),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                onPressed: () {},
                icon: Icon(Icons.upload_rounded,
                    color: Color.fromARGB(255, 115, 99, 183)),
                label: const Text("Upload"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
