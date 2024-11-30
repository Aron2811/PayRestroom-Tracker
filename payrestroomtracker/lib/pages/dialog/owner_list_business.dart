import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_button/pages/dialog/owner_tag_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OwnerListBusiness extends StatefulWidget {
  @override
  _OwnerListBusinessState createState() => _OwnerListBusinessState();
}

class _OwnerListBusinessState extends State<OwnerListBusiness> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to fetch the restrooms for the current owner
  Stream<QuerySnapshot> _fetchOwnerBusinessesStream() {
    String? userEmail = _auth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in.");
    }

    return _firestore
        .collection('accepted_restrooms')
        .where('owner_email', isEqualTo: userEmail)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Paid Restrooms',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        iconTheme: const IconThemeData(
            color:
                Colors.white), // Optional: Change app bar icon color to white
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchOwnerBusinessesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No businesses found for your account.'),
            );
          }

          final businesses = snapshot.data!.docs;
          return ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                    title: Text(business['name'] ?? 'Unnamed Restroom'),
                    subtitle: Text('Location: ${business['location']}'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      try {
                        String position = business['position'];

                        // Ensure position is not null or empty
                        if (position.isEmpty) {
                          throw FormatException("Position is not available.");
                        }

                        // Split the string into latitude and longitude parts
                        List<String> latLngParts = position.split(',');

                        if (latLngParts.length != 2) {
                          throw FormatException("Position format is invalid.");
                        }

                        // Parse the parts into doubles
                        double latitude = double.parse(latLngParts[0].trim());
                        double longitude = double.parse(latLngParts[1].trim());

                        // Create a LatLng object
                        LatLng latLng = LatLng(latitude, longitude);

                        // Navigate to OwnerTagInformation
                        showDialog(
                          context: context,
                          builder: (context) => OwnerTagInformation(
                            markerId: MarkerId(business['TagId'] ??
                                'Unknown'), // Handle missing TagId
                            destination: latLng,
                          ),
                        );
                      } catch (e) {
                        // Show an error message if parsing fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }),
              );
            },
          );
        },
      ),
    );
  }
}
