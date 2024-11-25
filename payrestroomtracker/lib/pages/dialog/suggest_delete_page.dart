import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SuggestDeletePage extends StatefulWidget {
  final LatLng destination;

  const SuggestDeletePage({Key? key, required this.destination})
      : super(key: key);

  @override
  _SuggestDeletePageState createState() => _SuggestDeletePageState();
}

class _SuggestDeletePageState extends State<SuggestDeletePage> {
  final TextEditingController _reasonController = TextEditingController();
  File? _selectedImage;
  String? _restroomName;

  @override
  void initState() {
    super.initState();
    _fetchRestroomName();
  }

    Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

 Future<void> _fetchRestroomName() async {
  try {
    // Query the Firestore collection for the restroom using the GeoPoint
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags') // Assuming 'Tags' contains restroom data
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Fetch the 'name' field from the first document
      setState(() {
        _restroomName = querySnapshot.docs.first['Name'];
      });
    } else {
      // Handle case where no matching restroom is found
      setState(() {
        _restroomName = 'Restroom not found';
      });
    }
  } catch (e) {
    // Handle any errors that occur during the query
    setState(() {
      _restroomName = 'Error fetching restroom name';
    });
    print('Error fetching restroom name: $e');
  }
}


Future<void> _submitSuggestion() async {
  if (_reasonController.text.isEmpty || _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please provide a reason and upload an image.'),
      ),
    );
    return;
  }

  try {
    // Generate a unique identifier based on the current timestamp
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    String imagePath = 'business_permits/$uniqueId.jpg';

    // Upload image to Firebase Storage
    TaskSnapshot uploadTask = await FirebaseStorage.instance
        .ref(imagePath)
        .putFile(_selectedImage!);
    String imageUrl = await uploadTask.ref.getDownloadURL();

    // Save suggestion data to Firestore
    await FirebaseFirestore.instance.collection('restroom_delete_suggestions').add({
      'reason': _reasonController.text,
      'image': imageUrl,
      'destination': GeoPoint(widget.destination.latitude, widget.destination.longitude),
      'restroomName': _restroomName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion submitted successfully!'),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error submitting suggestion: $e'),
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Removal Request'),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restroom: ${_restroomName ?? "Loading..."}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reason for Deletion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Provide a detailed reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload Business Permit Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 97, 84, 158),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Suggestion',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Only the owner of the paid restroom can delete the restroom. Please upload a valid image of your business permit for verification.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
