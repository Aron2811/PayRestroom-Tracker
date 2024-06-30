import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/admin_add_info.dart';
import 'package:flutter_button/pages/dialog/admin_edit_info.dart';
import 'package:flutter_button/pages/dialog/change_username_dialog.dart';

class AdminTagInformation extends StatelessWidget {
  const AdminTagInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        SizedBox(height: 30),
        TextField(
          textAlign: TextAlign.center,
          enabled: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Paid Restroom Name',
            hintStyle: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 115, 99, 183),
            ),
          ),
          //
        ),
        SizedBox(height: 5),
        TextField(
          textAlign: TextAlign.center,
          enabled: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Location',
            hintStyle: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 115, 99, 183),
            ),
          ),
          //
        ),
        
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                showDialog(
                    context: context, builder: (context) => AddInfoDialog());

              },
              icon: Icon(Icons.add_location_outlined),
              color: Color.fromARGB(255, 115, 99, 183),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                showDialog(
                    context: context, builder: (context) => ChangeInfoDialog());
              },
              icon: Icon(Icons.edit_location_alt_outlined),
              color: Color.fromARGB(255, 115, 99, 183),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              icon: Icon(Icons.remove_circle_outline_rounded),
              color: Color.fromARGB(255, 115, 99, 183),
              iconSize: 30,
            ),
          ],
        )
      ],
      contentPadding: const EdgeInsets.all(20.0),
    );
  }
}
