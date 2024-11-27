import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_button/pages/dialog/map_screen.dart';
import 'package:flutter_button/pages/dialog/pesoformatter.dart';
import 'package:flutter_button/pages/dialog/owners_info.dart';

class OwnersPaidrestroomFillupform extends StatefulWidget {
  const OwnersPaidrestroomFillupform({super.key});

  @override
  OwnersPaidrestroomFillupformState createState() =>
      OwnersPaidrestroomFillupformState();
}

class OwnersPaidrestroomFillupformState
    extends State<OwnersPaidrestroomFillupform> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController =
      TextEditingController(); // New controller for cost
  List<File> _images = []; // To store the selected image
  LatLng?
      _selectedLocation; // To store the selected location (latitude and longitude)
  String _mapStyle = '';
  String dropdownValue = 'Cost';
  bool showCostField = true; // Variable to store map style
  String destination = "";

  // Function to pick multiple images from gallery
  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles =
        await _picker.pickMultiImage(); // Pick multiple images

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles
            .map((pickedFile) => File(pickedFile.path))
            .toList(); // Convert XFile to File and store
      });
    }
  }

  // Function to upload multiple images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    try {
      for (var image in _images) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        firebase_storage.Reference storageRef = firebase_storage
            .FirebaseStorage.instance
            .ref('Tags images/$fileName');

        await storageRef.putFile(image);
        String downloadURL = await storageRef.getDownloadURL();
        imageUrls.add(downloadURL); // Add the image URL to the list
      }
    } catch (e) {
      print("Error uploading images: $e");
    }
    return imageUrls;
  }

  Future<void> _submitSuggestion() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    String location = _selectedLocation != null
        ? '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'
        : '';
    String cost = dropdownValue == 'Pay Options'
        ? 'with pay options' // Store 'Pay Options' directly
        : '${_costController.text}';

    destination = location;

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        cost.isNotEmpty &&
        location.isNotEmpty) {
      try {
        // Upload images and get their URLs
        List<String> imageUrls = await _uploadImages();

        await FirebaseFirestore.instance.collection('owners_restrooms').add({
          'name': name,
          'location': description,
          'cost': cost,
          'position': location,
          'timestamp': FieldValue.serverTimestamp(),
          'ImageUrls': imageUrls, // Store the image URLs as an array
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Your Business information Submitted!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromARGB(255, 97, 84, 158)));
        Navigator.pop(context); // Close the suggestion page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error submitting business information: $e',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all fields',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }
  }

  // Function to load map style
  Future<void> _loadMapStyle() async {
    String mapStyle = await rootBundle.loadString('assets/map_style.json');
    setState(() {
      _mapStyle = mapStyle; // Store the loaded map style
    });
  }

  // Function to open the map and select a location
  Future<void> _openMap() async {
    await _loadMapStyle(); // Load the map style before opening the map
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(mapStyle: _mapStyle), // Pass the map style to MapScreen
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Business Information',
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              // Button to select location
              ElevatedButton(
                onPressed: _openMap,
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Keeps the button size compact
                  children: [
                    Text(
                      _selectedLocation != null
                          ? 'Location Selected: ${_selectedLocation!.latitude.toStringAsFixed(2)}, ${_selectedLocation!.longitude.toStringAsFixed(2)}'
                          : 'Select Location',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    if (_selectedLocation == null) ...[
                      const SizedBox(
                          width: 5), // Space between text and asterisk
                      const Text(
                        '*',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 236, 154, 148)),
                      ),
                    ],
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: null,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Description', // Replace this with the appropriate label
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
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 15),
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
                    title: const Text(
                      'Cost',
                      style: TextStyle(
                        color: Color.fromARGB(255, 115, 99, 183),
                      ),
                    ),
                    value: 'Cost',
                    groupValue: dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                        showCostField = true;
                      });
                    },
                  ),
                  if (showCostField)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: _costController,
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
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  RadioListTile<String>(
                    title: const Text(
                      'Pay Options',
                      style: TextStyle(
                        color: Color.fromARGB(255, 115, 99, 183),
                      ),
                    ),
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
              const SizedBox(height: 20),
              if (_images.isNotEmpty) ...[
                Wrap(
                  children: _images.map((image) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(
                        image,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
              Center(
                child: ElevatedButton(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Ensures the button size is not overly stretched
                    children: const [
                      Text(
                        'Pick Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          width:
                              5), // Adds a small space between text and asterisk
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 236, 154,
                              148), // Makes the asterisk red for visibility
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitSuggestion();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnersPaidRestroomFillupForm(
                            destination: destination),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Submit Your Business',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
