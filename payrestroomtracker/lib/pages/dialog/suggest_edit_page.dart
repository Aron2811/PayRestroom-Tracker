import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SuggestEditPage extends StatefulWidget {
  final LatLng destination;

  const SuggestEditPage({required this.destination, Key? key}) : super(key: key);

  @override
  _SuggestEditPageState createState() => _SuggestEditPageState();
}

class _SuggestEditPageState extends State<SuggestEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _suggestedNameController = TextEditingController();
  final TextEditingController _suggestedCostController = TextEditingController();
  final TextEditingController _suggestedLocationController = TextEditingController();

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
          .where('position', isEqualTo: GeoPoint(widget.destination.latitude, widget.destination.longitude))
          .get();

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
          const SnackBar(content: Text('Restroom not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> _submitEdit() async {
  final suggestedData = {
    'SuggestedName': _suggestedNameController.text,
    'SuggestedCost': _suggestedCostController.text,
    'SuggestedLocation': _suggestedLocationController.text,
    'ImageUrls': _imageUrls, // List of image URLs
    'Position': GeoPoint(widget.destination.latitude, widget.destination.longitude), // Geopoint for the restroom's location
  };

  // Check if new images are uploaded and add them to Firestore
  if (_newImages.isNotEmpty) {
    for (var image in _newImages) {
      await _uploadImageToStorage(image); // Upload the new images to Firebase Storage
    }
  }

  try {
    // Add suggested data to Firestore
    await FirebaseFirestore.instance.collection('restroom_edit_suggestions').add(suggestedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit suggestion submitted successfully!')),
    );

    // Optionally, clear the form fields after submission
    _suggestedNameController.clear();
    _suggestedCostController.clear();
    _suggestedLocationController.clear();
    setState(() {
      _imageUrls.clear();
      _newImages.clear();
    });

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting suggestion: $e')),
    );
  }
}

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage(); // Allow multiple image selection

    for (var pickedFile in pickedImages) {
      _uploadImageToStorage(File(pickedFile.path));
    }
    }

  Future<void> _uploadImageToStorage(File image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance.ref().child('suggested_images/$fileName');

    try {
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _imageUrls.add(imageUrl); // Add uploaded image URL to the list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
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
        title: const Text('Suggest an Edit'),
        backgroundColor: const Color.fromARGB(255, 148, 139, 192),
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
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildFieldWithSuggestion(
                label: 'Restroom Name',
                existingValue: _nameController.text,
                suggestionController: _suggestedNameController,
              ),
              const SizedBox(height: 20),
              _buildFieldWithSuggestion(
                label: 'Cost (₱)',
                existingValue: _costController.text,
                suggestionController: _suggestedCostController,
                keyboardType: TextInputType.number,
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
                  backgroundColor: const Color.fromARGB(255, 148, 139, 192),
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
        const Text('Existing Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._imageUrls.map((url) => _buildImageWithDeleteIcon(url, false)),
            ..._newImages.map((file) => _buildImageWithDeleteIcon(file.path, true)),
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
              isNewImage ? _newImages.indexWhere((f) => f.path == imagePath) : _imageUrls.indexOf(imagePath),
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
        Text('$label (Existing):', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: TextEditingController(text: existingValue),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey,
          ),
          enabled: false,
        ),
        const SizedBox(height: 10),
        Text('$label (Your Suggestion):', style: const TextStyle(fontWeight: FontWeight.bold)),
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
