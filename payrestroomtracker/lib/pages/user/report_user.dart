import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportUser extends StatefulWidget {
  final String userId; // Accept the userId which is unique for each user
  final String location;
  final String restroomName;

  const ReportUser({
    Key? key,
    required this.userId, // Accept userId
    required this.location,
    required this.restroomName,
  }) : super(key: key);

  @override
  _ReportUserState createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  Set<String> _selectedReasons = {}; // Set to store multiple selected reasons

  // two colors deep purple for default, green for clicked state
  final Color _defaultPurple = const Color(0xFF4B2F8C); // Deep purple color
  final Color _clickedGreen =
      const Color(0xFF4CAF50); // Green color when clicked

  void _submitReport(BuildContext context) async {
    if (_selectedReasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one reason for reporting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get the current authenticated user (the reporter)
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to report'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get reference to the reporter (the current logged-in user)
      final reporterRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Fetch the reporter's details (username)
      final reporterDoc = await reporterRef.get();
      if (!reporterDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching reporter data.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final reporterName = reporterDoc.data()?['displayName'] ??
          'Anonymous'; // Get the reporter's username

      // Get reference to the reported user's document (the user being reported)
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      // Get the current report data from Firestore
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        // Get current report history or initialize it to an empty array if not set
        final reportHistory = List<Map<String, dynamic>>.from(
            userDoc.data()?['reportHistory'] ?? []);

        // Check if the current reporter has already reported this user
        bool alreadyReported = reportHistory
            .any((report) => report['reporterName'] == reporterName);

        if (alreadyReported) {
          // If the user has already reported this user, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already reported this user.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Create the report with both reporter's name and reasons under the same entry
        final newReport = {
          'reporterName': reporterName, // Store the reporter's username here
          'reasons': _selectedReasons
              .toList(), // Store the selected reasons for reporting
        };

        // Check if the 'reportCount' and 'reportHistory' fields exist
        bool reportCountExists =
            userDoc.data()?.containsKey('reportCount') ?? false;
        bool reportHistoryExists =
            userDoc.data()?.containsKey('reportHistory') ?? false;

        // Initialize 'reportCount' and 'reportHistory' if they do not exist
        if (!reportCountExists || !reportHistoryExists) {
          await userRef.update({
            'reportCount': 0, // Initialize to 0 if not found
            'reportHistory': [], // Initialize to an empty array if not found
          });
        }

        // Update the reported user's report count and report history
        await userRef.update({
          'reportCount': (userDoc.data()?['reportCount'] ?? 0) + 1,
          'reportHistory':
              FieldValue.arrayUnion([newReport]), // Add the new report entry
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );

        // Exit the page after submitting the report
        Navigator.pop(
            context); // This will pop the current screen from the stack
      } else {
        // Handle case where user document does not exist
        print('User does not exist');
      }
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _defaultPurple, // Deep purple color for AppBar
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserDetails(widget.userId), // Fetch user details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('User not found.'));
          }

          final userData = snapshot.data!;
          final userName = userData['displayName'] ?? 'Anonymous';
          final userPhotoURL = userData['photoURL'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restroom Name
                Text(
                  'Restroom Name: ${widget.restroomName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // User Image and Username
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(userPhotoURL),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'User to be reported: $userName',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reporting Reason Buttons
                Wrap(
                  spacing: 10,
                  children: [
                    _buildReasonButton('Spamming Reviews'),
                    _buildReasonButton('False Reviews'),
                    _buildReasonButton('Inappropriate'),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitReport(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _defaultPurple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit Report',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch user details using the userId
  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // Use the userId as document ID
          .get();

      if (userDoc.exists) {
        return userDoc.data(); // Return the document data if it exists
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return null;
  }

  Widget _buildReasonButton(String reason) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (_selectedReasons.contains(reason)) {
            _selectedReasons.remove(reason); // Remove from selected reasons
          } else {
            _selectedReasons.add(reason); // Add to selected reasons
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedReasons.contains(reason)
            ? _clickedGreen // Green when selected
            : _defaultPurple, // Deep purple when not selected
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        reason,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
