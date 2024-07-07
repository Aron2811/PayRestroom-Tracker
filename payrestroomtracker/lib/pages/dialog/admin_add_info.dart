import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInfoDialog extends StatefulWidget {
  final MarkerId markerId;

  const AddInfoDialog({
    Key? key,
    required this.markerId,
  }) : super(key: key);

  @override
  _AddInfoDialogState createState() => _AddInfoDialogState();
}

class _AddInfoDialogState extends State<AddInfoDialog> {
  bool confirmPressed = false;

  Future<void> _uploadImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    if (pickedFiles.length > 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can upload a maximum of 3 images at a time'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      }
      return;
    }

    try {
      DocumentReference tagRef = FirebaseFirestore.instance
          .collection('Tags')
          .doc(widget.markerId.value);
      DocumentSnapshot tagSnapshot = await tagRef.get();
      Map<String, dynamic>? tagData =
          tagSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> imageUrls = tagData?['ImageUrls'] ?? [];

      // Check if adding new images would exceed the limit of 3
      if (imageUrls.length + pickedFiles.length > 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'You have reached the limit of 3 images. Please delete an image before uploading a new one.'),
              backgroundColor: Color.fromARGB(255, 115, 99, 183),
            ),
          );
        }
        return;
      }

      List<String> downloadURLs = [];

      for (var pickedFile in pickedFiles) {
        File imageFile = File(pickedFile.path);
        String fileName =
            '${widget.markerId.value}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        firebase_storage.Reference storageRef = firebase_storage
            .FirebaseStorage.instance
            .ref('Tags images')
            .child(fileName);

        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();
        downloadURLs.add(downloadURL);
      }

      imageUrls.addAll(downloadURLs);

      await tagRef.set(
        {
          'TagId': widget.markerId.value,
          'ImageUrls': imageUrls,
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images uploaded successfully'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload images'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        const SizedBox(height: 30),
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
        const SizedBox(height: 10),
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
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
              fillColor: Colors.white10,
              filled: true,
            ),
          ),
        ),
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
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
              fillColor: Colors.white10,
              filled: true,
            ),
          ),
        ),
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
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
              floatingLabelStyle: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
              fillColor: Colors.white10,
              filled: true,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: const BorderSide(
                color: Color.fromARGB(255, 149, 134, 225),
                width: 2.0,
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _uploadImages,
            icon: const Icon(Icons.upload_rounded,
                color: Color.fromARGB(255, 149, 134, 225)),
            label: const Text("Upload"),
          ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: const Size(150, 40),
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: Color.fromARGB(255, 149, 134, 225),
                  width: 2.0,
                ),
              ),
              foregroundColor: const Color.fromARGB(255, 149, 134, 225),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text(
              "Confirm",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              confirmPressed = true; // Set confirmation status
              Navigator.of(context).pop(confirmPressed);
            },
          ),
        ),
      ],
    );
  }
}
