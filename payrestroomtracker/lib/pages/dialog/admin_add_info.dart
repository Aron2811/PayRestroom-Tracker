import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddInfoDialog extends StatefulWidget {
  final MarkerId markerId;
  final LatLng destination;

  const AddInfoDialog({
    Key? key,
    required this.markerId,
    required this.destination,
  }) : super(key: key);

  @override
  _AddInfoDialogState createState() => _AddInfoDialogState();
}

class _AddInfoDialogState extends State<AddInfoDialog> {
  bool isVisible = false;
  List<String> imageUrls = [];
  bool confirmPressed = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  double rating = 0.0; // Added for storing rating value
  String ratingText = ''; // Added for displaying rating text

  @override
  void initState() {
    super.initState();
    fetchImageUrls(context);
  }

  void _confirmedPressed() async {
    if (_validateInputs()) {
      confirmPressed = true; // Set confirmation status
      Navigator.of(context).pop(confirmPressed);

      try {
        DocumentReference tagRef = FirebaseFirestore.instance
            .collection('Tags')
            .doc(widget.markerId.value);
        DocumentSnapshot tagSnapshot = await tagRef.get();
        Map<String, dynamic>? tagData =
            tagSnapshot.data() as Map<String, dynamic>?;

        List<dynamic> existingImageUrls = tagData?['ImageUrls'] ?? [];

        List<String> updatedImageUrls = [...existingImageUrls, ...imageUrls];

        await tagRef.set(
          {
            'TagId': widget.markerId.value,
            'ImageUrls': updatedImageUrls,
            'Name': nameController.text,
            'Location': locationController.text,
            'Cost': costController.text,
            'Rating': rating.toString(), // Store rating in Firestore
          },
          SetOptions(merge: true),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paid restroom information added successfully'),
              backgroundColor: Color.fromARGB(255, 115, 99, 183),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save paid restroom information'),
              backgroundColor: Color.fromARGB(255, 240, 148, 142),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Incomplete Information'),
              content: Text(
                  'Please fill in all fields, upload an image and provide a rating.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  bool _validateInputs() {
    return nameController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        costController.text.isNotEmpty &&
        imageUrls.isNotEmpty &&
        rating > 0.0;
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
        Navigator.of(context).pop(false);
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
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

      setState(() {
        imageUrls.addAll(downloadURLs);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images uploaded successfully'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
        setState(() {
          isVisible = !isVisible;
        });
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload images'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
        Navigator.of(context).pop(false);
      }
    }
  }

  Future<void> fetchImageUrls(BuildContext context) async {
    try {
      DocumentSnapshot tagSnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .doc(widget.markerId.value)
          .get();

      if (tagSnapshot.exists) {
        List<dynamic> urls = tagSnapshot.get('ImageUrls') ?? [];
        setState(() {
          imageUrls = List<String>.from(urls);
        });
        String ratingString = tagSnapshot.get('Rating') ?? '0.0';
        setState(() {
          rating = double.tryParse(ratingString) ?? 0.0;
        });
      } else {
        setState(() {
          imageUrls = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching image URLs: Add Image'),
          duration: Duration(seconds: 3),
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
        ),
      );
      Navigator.of(context).pop(false);
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

        //update image in realtime
        await fetchImageUrls(context);
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

  Widget _buildCarousel() {
    return FullScreenWidget(
      disposeLevel: DisposeLevel.High,
      child: Center(
        child: SizedBox(
          height: 250,
          width: 350,
          child: imageUrls.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No images available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                )
              : AnotherCarousel(
                  showIndicator: false,
                  images: List<Widget>.generate(
                    imageUrls.length,
                    (index) {
                      return Stack(
                        children: [
                          Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 164, 152, 219),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      "Are you sure you want to delete this image",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 115, 99, 183),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text("No"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          _deleteImage(index);
                                          setState(() {
                                            imageUrls.removeAt(index);
                                          });
                                        },
                                        child: Text("Yes"),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  borderRadius: true,
                  autoplay: false,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          actions: [
            SizedBox(height: 30),
            Padding(
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
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: nameController,
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
                      fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
                  fillColor: Colors.white10,
                  filled: true,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: locationController,
                minLines: 1,
                maxLines: 2,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Paid Restroom Location',
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
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: costController,
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
                      fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
                  floatingLabelStyle: TextStyle(
                      fontSize: 15, color: Color.fromARGB(255, 115, 99, 183)),
                  fillColor: Colors.white10,
                  filled: true,
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildCarousel(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$ratingText', // Display current rating text
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                SizedBox(width: 8),
                RatingBar(
                  size: 20,
                  alignment: Alignment.center,
                  filledIcon: Icons.star,
                  emptyIcon: Icons.star_border,
                  emptyColor: Colors.grey,
                  filledColor: Color.fromARGB(255, 97, 84, 158),
                  halfFilledColor: Color.fromARGB(255, 186, 176, 228),
                  initialRating: rating,
                  onRatingChanged: (newRating) {
                    setState(() {
                      rating = newRating;
                      // Update rating text based on the selected rating
                      ratingText = '$newRating';
                    });
                  },
                  maxRating: 5,
                ),
              ],
            ),
            SizedBox(height: 15),
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
                  side: BorderSide(
                    color: Color.fromARGB(255, 149, 134, 225),
                    width: 2.0,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _uploadImages,
                icon: Icon(Icons.upload_rounded,
                    color: Color.fromARGB(255, 149, 134, 225)),
                label: const Text("Upload"),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: Colors.white,
                  minimumSize: Size(150, 40),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: Color.fromARGB(255, 149, 134, 225),
                      width: 2.0,
                    ),
                  ),
                  foregroundColor: Color.fromARGB(255, 149, 134, 225),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(
                  "Confirm",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _confirmedPressed();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}