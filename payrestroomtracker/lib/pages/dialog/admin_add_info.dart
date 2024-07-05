import 'package:flutter/material.dart';

class AddInfoDialog extends StatelessWidget {
  const AddInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: [
      const SizedBox(
        height: 30,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          "Paid Restroom Information",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 97, 84, 158),
          ),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Paid Restroom Name',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              labelStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)
                  // Change this color to the desired color,
                  ),
              fillColor: Colors.white10,
              filled: true,
            ),
          )),
      const SizedBox(height: 10),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Location',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              labelStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)
                  // Change this color to the desired color,
                  ),
              fillColor: Colors.white10,
              filled: true,
            ),
          )),
          const SizedBox(height: 10),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Cost',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
              ),
              labelStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)
                  // Change this color to the desired color,
                  ),
              fillColor: Colors.white10,
              filled: true,
            ),
          )),
      const SizedBox(height: 20),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 70.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                enableFeedback: false,
                backgroundColor: Colors.white,
                minimumSize: const Size(100, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                side: BorderSide(
                  color:
                      Color.fromARGB(255, 149, 134, 225), //Set the border color
                  width: 2.0,
                ),
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: () {},
            icon: Icon(Icons.upload_rounded,
                color: Color.fromARGB(255, 149, 134, 225)),
            label: const Text("Upload"),
          )),
      const SizedBox(height: 20),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: const Size(150, 40),
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: Color.fromARGB(
                      255, 149, 134, 225), // Set the border color
                  width: 2.0, // Set the border width
                ),
              ),
              foregroundColor: Color.fromARGB(255, 149, 134, 225),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text(
              "Confirm",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ))
    ]);
  }
}