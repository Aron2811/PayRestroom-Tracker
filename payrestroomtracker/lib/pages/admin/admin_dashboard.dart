import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? selectedUser; // To track the selected user

  void _showUserDetailsDialog(
      String displayName, String userId, bool isHeld, bool isBanned) {
    // Show the dialog with the hold button only after ensuring the widget context is mounted
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 132, 119, 197),
            title: const SizedBox.shrink(),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You can choose to ban or hold/unhold the user.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current dialog
                        if (isBanned) {
                          _unbanUser(
                              displayName, userId); // If already banned, unban
                        } else {
                          _banUser(displayName, userId); // If not banned, ban
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 132, 119, 197),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 25),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: Text(isBanned ? 'Unban' : 'Ban'),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current dialog
                        // Check the current hold status and show appropriate dialog
                        if (isHeld) {
                          // If the user is held, unhold the user
                          _unholdUser(displayName, userId);
                        } else {
                          // If the user is not held, show the hold dialog
                          _showHoldDialog(displayName, userId);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 132, 119, 197),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 25),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: Text(isHeld ? 'Unhold' : 'Hold'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Ban user in Firestore
  void _banUser(String displayName, String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isBanned': true, // Set 'isBanned' to true
    }).then((_) {
      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$displayName has been banned'),
        backgroundColor: Colors.red,
      ));
    }).catchError((error) {
      // Handle errors if the update fails
      print('Failed to ban user: $error');
    });
  }

// Unban user in Firestore
  void _unbanUser(String displayName, String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isBanned': false, // Set 'isBanned' to false
    }).then((_) {
      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$displayName has been unbanned'),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      // Handle errors if the update fails
      print('Failed to unban user: $error');
    });
  }

  // Update Firestore to unhold user
  void _unholdUser(String displayName, String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isHeld': false,
      'holdDuration': 0, // Optionally reset hold duration to 0
      'holdTimestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      // Rebuild the widget to reflect the change
      setState(() {
        // Update local variables or states that control the UI
      });
      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$displayName is no longer on hold'),
        backgroundColor: Colors.red,
      ));
    }).catchError((error) {
      // Handle errors if the update fails
      print('Failed to remove hold: $error');
    });
  }

  // Update Firestore with hold information
  void _holdUser(String displayName, String userId, int hours) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isHeld': true,
      'holdDuration': hours,
      'holdTimestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$displayName is now on hold for $hours hours'),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      // Handle errors if the update fails
      print('Failed to hold user: $error');
    });
  }

  // Show dialog to input hours for hold
  void _showHoldDialog(String displayName, String userId) {
    final TextEditingController hoursController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 132, 119, 197),
          title: const Text('Set Hold Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter number of hours',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                String hoursInput = hoursController.text.trim();
                if (hoursInput.isNotEmpty) {
                  int hours = int.tryParse(hoursInput) ?? 0;
                  if (hours > 0) {
                    // Set hold in Firestore
                    _holdUser(displayName, userId, hours);
                    Navigator.of(context).pop(); // Close dialog
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 132, 119, 197),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hold'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without action
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 132, 119, 197),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users'));
          }

          // Get the list of users
          final users = snapshot.data!.docs;

          return Row(
            children: [
              // User List Section (Left)
              Expanded(
                flex: 1,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    String displayName = users[index]
                        ['displayName']; // Assumes 'displayName' field exists

                    // Safely access the data to check if 'isHeld' exists
                    bool isHeld = false;
                    bool isBanned = false;
                    Timestamp? holdTimestamp;
                    int holdDuration = 0;

                    try {
                      // Cast data to Map<String, dynamic>
                      Map<String, dynamic> userData =
                          users[index].data() as Map<String, dynamic>;

                      // Initialize fields safely
                      isHeld = userData['isHeld'] ?? false;
                      isBanned = userData['isBanned'] ?? false;
                      holdTimestamp = userData['holdTimestamp'];
                      holdDuration = userData['holdDuration'] ?? 0;
                    } catch (e) {
                      print("Error accessing user data: $e");
                    }

                    // Check if hold has expired
                    if (isHeld && holdTimestamp != null) {
                      DateTime holdEndTime = holdTimestamp
                          .toDate()
                          .add(Duration(hours: holdDuration));
                      if (DateTime.now().isAfter(holdEndTime)) {
                        // Auto-unhold if hold duration has expired
                        _unholdUser(displayName, users[index].id);
                      }
                    }

                    String userId = users[index]
                        .id; // Get the Firestore document ID (userId)

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedUser =
                                  displayName; // Update selected user
                            });

                            // Show a SnackBar with the tapped user details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Tapped user: $displayName, userId: $userId'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Call the dialog function with the three parameters
                            _showUserDetailsDialog(
                                displayName, userId, isHeld, isBanned);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                  255, 132, 119, 197), // Set background color
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: <Widget>[
                                // Display user's photo if available, otherwise fall back to a default icon
                                users[index]['photoURL'] != null &&
                                        users[index]['photoURL'] != ''
                                    ? CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                            users[index]['photoURL']),
                                      )
                                    : const Icon(
                                        Icons.account_circle,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Space between list items
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
