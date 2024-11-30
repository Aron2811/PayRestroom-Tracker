import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class OwnersPaidRestroomFillupForm extends StatefulWidget {
  final String destination;

  const OwnersPaidRestroomFillupForm({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  State<OwnersPaidRestroomFillupForm> createState() =>
      _OwnersPaidRestroomFillupFormState();
}

class _OwnersPaidRestroomFillupFormState
    extends State<OwnersPaidRestroomFillupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _businessPermit;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _businessPermit = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _businessPermit != null) {
      try {
        // Get current user's email from FirebaseAuth
        User? user = FirebaseAuth.instance.currentUser;
        String userEmail = user?.email ?? 'No email'; // Default if not logged in

        // Upload business permit image to Firebase Storage
        String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        String imagePath = 'business_permits/$uniqueId.jpg';
        TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref(imagePath)
            .putFile(_businessPermit!);
        String imageUrl = await uploadTask.ref.getDownloadURL();

        // Check if a restroom with the same destination exists
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('owners_restrooms')
            .where('position', isEqualTo: widget.destination)
            .get();

        if (snapshot.docs.isEmpty) {
          // No existing restroom, add new entry
          await FirebaseFirestore.instance.collection('owners_restrooms').add({
            'ownername': _nameController.text,
            'gcash_number': _phoneNumberController.text,
            'business_permit_image': imageUrl,
            'fee': 150.00, // Total cost in pesos
            'owner_email': userEmail, // Store the user's email
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("New restroom information added.")),
          );
        } else {
          // Destination exists, update existing entry
          DocumentReference restroomDoc = snapshot.docs.first.reference;

          await restroomDoc.update({
            'ownername': _nameController.text,
            'gcash_number': _phoneNumberController.text,
            'business_permit_image': imageUrl,
            'fee': 150.00, // Total cost in pesos
            'owner_email': userEmail, // Store the user's email
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restroom information updated.")),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else if (_businessPermit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your business permit.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paid Restroom Owner Form',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Owner's Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Owner's Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: "GCash Number (11 digits)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.length != 11 ||
                        int.tryParse(value) == null) {
                      return "Please enter a valid 11-digit phone number.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  child: _businessPermit == null
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
                              image: FileImage(_businessPermit!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Center(
                  child: const Text(
                    "Total Cost: ₱150.00",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Note: The total cost shown represents the balance to be paid for tagging your business location.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700], // Adjust color to fit your theme
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 97, 84, 158), // Button color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    child: const Text(
                      "Pay & Submit Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
