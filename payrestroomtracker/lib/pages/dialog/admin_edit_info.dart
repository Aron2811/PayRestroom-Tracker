import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter_button/pages/dialog/pesoformatter.dart';
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
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController costController = TextEditingController();
  bool isLoading = true;
  bool confirmPressed = false;
  String dropdownValue = 'Pay Options'; // Default value
  bool showCostField = false; // Default to false

  @override
  void initState() {
    super.initState();
    fetchRestroomInfo();
  }

  Future<void> fetchRestroomInfo() async {
    try {
      DocumentSnapshot tagSnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .doc(widget.markerId.value)
          .get();

      if (tagSnapshot.exists) {
        setState(() {
          nameController.text = tagSnapshot.get('Name') ?? '';
          locationController.text = tagSnapshot.get('Location') ?? '';
          String cost = tagSnapshot.get('Cost') ?? '';
          // If cost doesn't include the peso sign, add it
          costController.text = cost.startsWith('₱') ? cost : '₱$cost';
          imageUrls = List<String>.from(tagSnapshot.get('ImageUrls') ?? []);

          // Set dropdownValue and showCostField based on fetched data
          dropdownValue =
              cost.isEmpty || cost == 'Pay Options' ? 'Pay Options' : cost;
          showCostField = dropdownValue == '₱' || dropdownValue.startsWith('₱');
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching restroom info: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop(false);
    }
  }
  //method for uploading an image
  Future<void> _uploadImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    const int maxFileSizeInBytes = 3 * 1024 * 1024; // 3MB in bytes

    // Check if any image exceeds 3MB
    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > maxFileSizeInBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image must be less than 3MB'),
              backgroundColor: Color.fromARGB(255, 115, 99, 183),
            ),
          );
        }
        return;
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

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
      await fetchImageUrls(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images uploaded successfully'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
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
  //method to fetch image urls in firestore
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
      } else {
        setState(() {
          imageUrls = []; // or set to a default value as needed
        });
      }
    } catch (e) {
      // Display error message as a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching image URLs: Add Image'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
      Navigator.of(context).pop(false);
    }
  }
  //method for deleting an image
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
  //method to update restroom info
  Future<void> _updateRestroomInfo() async {
    if (_validateInputs()) {
      confirmPressed = true; // Set confirmation status
      Navigator.of(context).pop(confirmPressed);
      try {
        DocumentReference tagRef = FirebaseFirestore.instance
            .collection('Tags')
            .doc(widget.markerId.value);

        String newName = nameController.text.isEmpty ? '' : nameController.text;
        String newLocation =
            locationController.text.isEmpty ? '' : locationController.text;
        String newCost = dropdownValue == 'Pay Options'
            ? 'Pay Options'
            : costController.text;

        await tagRef.set(
          {
            'Name': newName,
            'Location': newLocation,
            'Cost': newCost,
            
          },
          SetOptions(merge: true),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restroom information updated successfully'),
              backgroundColor: Color.fromARGB(255, 115, 99, 183),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update restroom information'),
              backgroundColor: Color.fromARGB(255, 115, 99, 183),
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
              title: Text(
                'Incomplete Information',
                textAlign: TextAlign.center,
              ),
              titleTextStyle: TextStyle(
                  color: Color.fromARGB(255, 115, 99, 183),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              content: Text(
                'Please fill in all fields and upload an image. Note: The cost field should have a "₱" peso sign.',
                style: TextStyle(
                  color: Color.fromARGB(255, 115, 99, 183),
                ),
              ),
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
    // Check if the required fields are not empty
    bool areFieldsFilled = nameController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        imageUrls.isNotEmpty;

    // Check if cost is needed and is not empty
    bool isCostValid = !showCostField || costController.text.isNotEmpty;

    return areFieldsFilled && isCostValid;
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
                                color: Color.fromARGB(255, 115, 99, 183),
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
                  showIndicator: false,
                  borderRadius: true,
                  autoplay: false,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                    color: Color.fromARGB(255, 97, 61, 189),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: nameController,
                    minLines: 1,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: null,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Paid Restroom Name', // Replace this with the appropriate label
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 115, 99, 183),
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Color.fromARGB(255, 236, 154, 148),
                            ),
                          ),
                        ],
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 115, 99, 183)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 115, 99, 183)),
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
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: locationController,
                    minLines: 1,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: null,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Paid Restroom Location', // Replace this with the appropriate label
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 115, 99, 183),
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Color.fromARGB(255, 236, 154, 148),
                            ),
                          ),
                        ],
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 115, 99, 183)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 115, 99, 183)),
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
              SizedBox(height: 20),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '      Choose Options ', // Replace this with the appropriate label
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 115, 99, 183),
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          color: Color.fromARGB(255, 236, 154, 148),
                        ),
                      ),
                    ],
                  ),
                  RadioListTile<String>(
                    title: const Text('Cost'),
                    value: 'Cost',
                    groupValue: showCostField ? 'Cost' : null,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                        showCostField = true;
                      });
                    },
                    activeColor: showCostField
                        ? Color.fromARGB(255, 115, 99, 183)
                        : Colors.grey,
                  ),
                  if (showCostField)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: costController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          PesoInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: null,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Enter the Cost ', // Replace this with the appropriate label
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 115, 99, 183),
                                ),
                              ),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 236, 154, 148),
                                ),
                              ),
                            ],
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 115, 99, 183)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 115, 99, 183)),
                          ),
                          labelStyle: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 115, 99, 183)),
                        ),
                      ),
                    ),
                  RadioListTile<String>(
                    title: const Text('Pay Options'),
                    value: 'Pay Options',
                    groupValue: dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                        showCostField = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildCarousel(),
              const SizedBox(height: 20),
              const SizedBox(height: 15),
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
                    confirmPressed ? 'Please wait' : 'Confirm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: confirmPressed ? null : _updateRestroomInfo,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color.fromARGB(255, 115, 99, 183),
                    ),
                  ),
                ),
              ),
            ]),
          );
  }
}