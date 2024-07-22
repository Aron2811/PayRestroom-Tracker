import 'package:flutter/material.dart';

class ChangeUsernameDialog extends StatelessWidget {
  const ChangeUsernameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: [
      const SizedBox(
        height: 30,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Text(
          "Change Username",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 97, 84, 158),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Username',
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
              foregroundColor: const Color.fromARGB(255, 135, 125, 186),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
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