import 'dart:io';
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
  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      String fileName =
          '${widget.markerId.value}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('Tags images')
          .child(fileName);

      await storageRef.putFile(imageFile);
      String downloadURL = await storageRef.getDownloadURL();

      DocumentReference tagRef = FirebaseFirestore.instance
          .collection('Tags')
          .doc(widget.markerId.value);

      DocumentSnapshot tagSnapshot = await tagRef.get();
      Map<String, dynamic>? tagData =
          tagSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> imageUrls = tagData?['ImageUrls'] ?? [];

      if (imageUrls.length >= 3) {
        imageUrls
            .removeAt(0); // Remove the oldest image URL if there are already 3
      }

      imageUrls.add(downloadURL);

      await tagRef.set(
        {
          'TagId': widget.markerId.value,
          'ImageUrls': imageUrls,
        },
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
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
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: Size(100, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: BorderSide(
                color: Color.fromARGB(255, 115, 99, 183),
                width: 2.0,
              ),
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _uploadImage,
            icon: Icon(Icons.upload_rounded,
                color: Color.fromARGB(255, 115, 99, 183)),
            label: Text("Upload"),
          ),
        ),
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