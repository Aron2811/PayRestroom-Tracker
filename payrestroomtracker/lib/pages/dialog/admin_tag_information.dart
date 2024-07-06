import 'dart:io';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/admin_add_info.dart';
import 'package:flutter_button/pages/dialog/admin_edit_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTagInformation extends StatefulWidget {
  final MarkerId markerId;
  final Future<void> Function(MarkerId) deleteMarker;

  const AdminTagInformation({
    Key? key,
    required this.markerId,
    required this.deleteMarker,
  }) : super(key: key);

  @override
  _AdminTagInformationState createState() => _AdminTagInformationState();
}

class _AdminTagInformationState extends State<AdminTagInformation> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    DocumentSnapshot tagSnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .doc(widget.markerId.value)
        .get();

    if (tagSnapshot.exists) {
      List<dynamic> urls = tagSnapshot.get('ImageUrls') ?? [];
      setState(() {
        imageUrls = List<String>.from(urls);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
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
        ),
        SizedBox(height: 5),
        TextField(
          textAlign: TextAlign.center,
          enabled: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Cost',
            hintStyle: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 115, 99, 183),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(
              height: 250,
              width: 300,
              child: AnotherCarousel(
                borderRadius: true,
                boxFit: BoxFit.cover,
                radius: Radius.circular(10),
                images: imageUrls.map((url) => NetworkImage(url)).toList(),
                showIndicator: false,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        //
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
                widget.deleteMarker(widget.markerId);
              },
              icon: Icon(Icons.remove_circle_outline_rounded),
              color: Color.fromARGB(255, 115, 99, 183),
              iconSize: 30,
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
