import 'package:flutter/material.dart';

class AddReviewPage extends StatelessWidget {
  const AddReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a Review',
          style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 3),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        centerTitle: true,
        actions: <Widget>[
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                enableFeedback: false,
                backgroundColor: Color.fromARGB(255, 97, 84, 158),
                minimumSize: const Size(10, 30),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pushNamed(context, '/reviewspage');
            },
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 164, 151, 219),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 100),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
