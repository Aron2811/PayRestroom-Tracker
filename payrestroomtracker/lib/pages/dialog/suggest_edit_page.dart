import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_button/pages/dialog/pesoformatter.dart';

class SuggestEditPage extends StatefulWidget {
  final LatLng destination;

  const SuggestEditPage({required this.destination, Key? key})
      : super(key: key);

  @override
  _SuggestEditPageState createState() => _SuggestEditPageState();
}

class _SuggestEditPageState extends State<SuggestEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _suggestedNameController =
      TextEditingController();
  final TextEditingController _suggestedCostController =
      TextEditingController();
  final TextEditingController _suggestedLocationController =
      TextEditingController();
      String? TagId;

  String dropdownValue = 'Cost';
  bool showCostField = true;

  List<String> _imageUrls = [];
  List<File> _newImages = [];

  @override
  void initState() {
    super.initState();
    _fetchRestroomDetails();
  }

  Future<void> _fetchRestroomDetails() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .where('position',
              isEqualTo: GeoPoint(
                  widget.destination.latitude, widget.destination.longitude))
          .get();

          TagId = querySnapshot.docs.first['TagId'];

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        setState(() {
          _nameController.text = data['Name'] ?? '';
          _costController.text = data['Cost']?.toString() ?? '';
          _locationController.text = data['Location'] ?? '';
          _imageUrls = (data['ImageUrls'] as List<dynamic>?)
                  ?.map((url) => url.toString())
                  .toList() ??
              [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restroom not found!'),
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e'),
        backgroundColor: Colors.red,),
        
      );
    }
  }

  Future<void> _submitEdit() async {
    String costValue = dropdownValue == 'Pay Options'
        ? 'with pay options' // Store 'Pay Options' directly
        : (_suggestedCostController.text.isEmpty
            ? "No Suggestion" // If suggested cost is empty, use existing cost
            : _suggestedCostController.text);

    final suggestedData = {
      'SuggestedName': _suggestedNameController.text.isEmpty
          ? "No Suggestion" // If suggested name is empty, use existing name
          : _suggestedNameController.text,

      'SuggestedCost': costValue,
      
      'SuggestedLocation': _suggestedLocationController.text.isEmpty
          ? "No Suggestion" // If suggested location is empty, use existing location
          : _suggestedLocationController.text,

      'ImageUrls': _imageUrls.isEmpty
          ? []
          : _imageUrls, // Use existing image URLs if new images are empty
      'Position':
          GeoPoint(widget.destination.latitude, widget.destination.longitude),
      'TagId': TagId,
    };

    // Check if new images are uploaded and add them to Firestore
    if (_newImages.isNotEmpty) {
      for (var image in _newImages) {
        await _uploadImageToStorage(
            image); // Upload the new images to Firebase Storage
      }
    }

    try {
      // Add suggested data to Firestore
      await FirebaseFirestore.instance
          .collection('restroom_edit_suggestions')
          .add(suggestedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Edit suggestion submitted successfully!'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),),
      );

      // Optionally, clear the form fields after submission
      _suggestedNameController.clear();
      _suggestedCostController.clear();
      _suggestedLocationController.clear();
      setState(() {
        _imageUrls.clear();
        _newImages.clear();
      });

      // Close the current page and return to the previous one
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting suggestion: $e'),
        backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImages =
        await picker.pickMultiImage(); // Allow multiple image selection

    if (pickedImages.isNotEmpty) {
      for (var pickedFile in pickedImages) {
        _uploadImageToStorage(File(pickedFile.path));
      }
    }
  }

  Future<void> _uploadImageToStorage(File image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef =
        FirebaseStorage.instance.ref().child('suggested_images/$fileName');

    try {
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _imageUrls.add(imageUrl); // Add uploaded image URL to the list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e'),
        backgroundColor: Colors.red,),
      );
    }
  }

  Future<void> _deleteImage(int index, {bool isNewImage = false}) async {
    if (isNewImage) {
      // Remove new image
      setState(() {
        _newImages.removeAt(index);
      });
    } else {
      // Remove existing image (Firestore logic can be added here if needed)
      setState(() {
        _imageUrls.removeAt(index);
      });
      // Optionally delete from Firebase Storage if linked
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggest an Edit',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Restroom Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildImageGallery(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file, color: Colors.white,),
                label: const Text('Upload Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 97, 84, 158),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildFieldWithSuggestion(
                label: 'Restroom Name',
                existingValue: _nameController.text,
                suggestionController: _suggestedNameController,
              ),
              const SizedBox(height: 20),
              Text('Cost (₱) (Existing):',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(text: _costController.text),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color.fromARGB(255, 156, 144, 207),
                ),
                enabled: false,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Options', // Replace this with the appropriate label
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 115, 99, 183),
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: _suggestedCostController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          PesoInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: null,
                          label: Text(
                            'Enter the Cost', // Replace this with the appropriate label
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 115, 99, 183),
                            ),
                          ),
                          border: const OutlineInputBorder(),
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
              _buildFieldWithSuggestion(
                label: 'Location',
                existingValue: _locationController.text,
                suggestionController: _suggestedLocationController,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submitEdit,
                child: const Text(
                  'Submit Edit Suggestion',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Existing Images:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._imageUrls.map((url) => _buildImageWithDeleteIcon(url, false)),
            ..._newImages
                .map((file) => _buildImageWithDeleteIcon(file.path, true)),
          ],
        ),
      ],
    );
  }

  Widget _buildImageWithDeleteIcon(String imagePath, bool isNewImage) {
    return Stack(
      children: [
        isNewImage
            ? Image.file(
                File(imagePath),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
            : Image.network(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteImage(
              isNewImage
                  ? _newImages.indexWhere((f) => f.path == imagePath)
                  : _imageUrls.indexOf(imagePath),
              isNewImage: isNewImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithSuggestion({
    required String label,
    required String existingValue,
    required TextEditingController suggestionController,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (Existing):',
            style: const TextStyle(fontWeight: FontWeight.bold,)),
        const SizedBox(height: 5),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: TextEditingController(text: existingValue),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color.fromARGB(255, 156, 144, 207),
          ),
          enabled: false,
        ),
        const SizedBox(height: 10),
        Text('$label (Your Suggestion):',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: suggestionController,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _locationController.dispose();
    _suggestedNameController.dispose();
    _suggestedCostController.dispose();
    _suggestedLocationController.dispose();
    super.dispose();
  }
}
