import 'dart:io';

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChangeInfoDialog extends StatefulWidget {
  final MarkerId markerId;

  const ChangeInfoDialog({
    Key? key,
    required this.markerId,
  }) : super(key: key);

  @override
  State<ChangeInfoDialog> createState() => _ChangeInfoDialogState();
}

class _ChangeInfoDialogState extends State<ChangeInfoDialog> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

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

  Future<void> _deleteImage(int index) async {
    try {
      DocumentReference tagRef = FirebaseFirestore.instance
          .collection('Tags')
          .doc(widget.markerId.value);

      // Fetch current imageUrls from Firestore
      DocumentSnapshot tagSnapshot = await tagRef.get();
      Map<String, dynamic>? tagData =
          tagSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> currentImageUrls = tagData?['ImageUrls'] ?? [];

      // Ensure index is within bounds
      if (index >= 0 && index < currentImageUrls.length) {
        // Remove the specified imageUrl from the list
        String imageUrlToDelete = currentImageUrls[index];
        currentImageUrls.removeAt(index);

        // Update Firestore with the new imageUrls
        await tagRef.set(
          {
            'TagId': widget.markerId.value,
            'ImageUrls': currentImageUrls,
          },
          SetOptions(merge: true),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image deleted successfully'),
              backgroundColor: Color.fromARGB(255, 115, 99, 183),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid index provided for deletion'),
              backgroundColor: Color.fromARGB(255, 241, 138, 130),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete image'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: AlertDialog(actions: [
      const SizedBox(
        height: 30,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          "Update Paid Restroom Information",
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
            minLines: 1,
            maxLines: 2,
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
            minLines: 1,
            maxLines: 3,
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
            minLines: 1,
            maxLines: 2,
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
      const SizedBox(height: 15),
      Column(children: [
        FullScreenWidget(
            disposeLevel: DisposeLevel.High,
            child: Center(
              child: SizedBox(
                height: 250,
                width: 300,
                child: Stack(
                  children: [
                    AnotherCarousel(
                      borderRadius: true,
                      boxFit: BoxFit.cover,
                      radius: Radius.circular(10),
                      images:
                          imageUrls.map((url) => NetworkImage(url)).toList(),
                      showIndicator: false,
                    ),
                    Positioned(
                        bottom: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(Icons.delete,
                              color: Color.fromARGB(255, 115, 99, 183)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  "Are you sure you want to delete this image",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 115, 99, 183),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      for (int index = 0;
                                          index < imageUrls.length;
                                          index++) {
                                        _deleteImage(index);
                                      }
                                    },
                                    child: const Text("Yes"),
                                  )
                                ],
                              ),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ))
      ]),
      const SizedBox(height: 20),
      Align(
          alignment: Alignment.center,
          child: RatingBar(
            size: 20,
            alignment: Alignment.center,
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            emptyColor: const Color.fromARGB(255, 153, 149, 149),
            filledColor: Color.fromARGB(255, 97, 84, 158),
            halfFilledColor: Color.fromARGB(255, 148, 139, 185),
            onRatingChanged: (p0) {},
            initialRating: 3,
            maxRating: 5,
          )),
      const SizedBox(height: 15),
      Align(
          alignment: Alignment.center,
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
            onPressed: _uploadImages,
            icon: Icon(Icons.upload_rounded,
                color: Color.fromARGB(255, 149, 134, 225)),
            label: const Text("Upload"),
          )),
      const SizedBox(height: 10),
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
    ]));
  }
}
