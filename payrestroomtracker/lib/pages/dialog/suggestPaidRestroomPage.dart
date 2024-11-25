import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_button/pages/dialog/map_screen.dart';
import 'package:flutter_button/pages/dialog/pesoformatter.dart';

class SuggestPaidRestroomPage extends StatefulWidget {
  const SuggestPaidRestroomPage({super.key});

  @override
  _SuggestPaidRestroomPageState createState() =>
      _SuggestPaidRestroomPageState();
}

class _SuggestPaidRestroomPageState extends State<SuggestPaidRestroomPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController(); // New controller for cost
  File? _image; // To store the selected image
  LatLng? _selectedLocation; // To store the selected location (latitude and longitude)
  String _mapStyle = ''; 
  String dropdownValue = 'Cost';
  bool showCostField = true;// Variable to store map style

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to upload the image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref('restroom_images/$fileName');

      await storageRef.putFile(_image!);
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Function to submit the restroom suggestion to Firestore
  Future<void> _submitSuggestion() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    String cost = _costController.text.trim(); // Get cost from the controller
    String location = _selectedLocation != null
        ? '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}' // Store lat/lng as a string
        : '';

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        cost.isNotEmpty &&
        location.isNotEmpty) {
      try {
        // Upload image and get its URL
        String? imageUrl = await _uploadImage();

        await FirebaseFirestore.instance.collection('suggested_restrooms').add({
          'name': name,
          'description': description,
          'cost': cost,
          'location': location, // Save location in Firestore
          'timestamp': FieldValue.serverTimestamp(),
          'image': imageUrl, // Store the image URL in Firestore
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restroom suggestion submitted!'), backgroundColor: Color.fromARGB(255, 115, 99, 183),));
        Navigator.pop(context); // Close the suggestion page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting suggestion: $e'), backgroundColor: Colors.red,));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'),backgroundColor: Colors.red,));
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
        builder: (context) => MapScreen(mapStyle: _mapStyle), // Pass the map style to MapScreen
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
        title: const Text('Suggest a Paid Restroom',  style: TextStyle(
              fontSize: 17,
              color: Colors.white,
            ),),
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
                  label:  Row(
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
                child: Text(
                  _selectedLocation != null
                      ? 'Location Selected: ${_selectedLocation!.latitude.toStringAsFixed(2)}, ${_selectedLocation!.longitude.toStringAsFixed(2)}'
                      : 'Select Location',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: null,
                  label:  Row(
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
              // Image preview
              if (_image != null) ...[
                Image.file(
                  _image!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
              ],
              // Button to pick an image
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Pick Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Submit Suggestion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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