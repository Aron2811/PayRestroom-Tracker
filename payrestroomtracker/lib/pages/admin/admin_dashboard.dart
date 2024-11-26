import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  String? selectedUser; // To track the selected user

  void _showUserDetailsDialog(String displayName, String userId, bool isHeld,
      bool isBanned, String tab) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 132, 119, 197),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                // Update text based on whether the user is banned or held
                Text(
                  isBanned
                      ? 'Do you wish to unban $displayName?'
                      : isHeld
                          ? 'Do you wish to unhold $displayName?'
                          : 'You can choose to ban or hold/unhold the user.',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 132, 119, 197),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tab == 'allUsers' || tab == 'bannedUsers') ...[
                      // Ban/Unban Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (isBanned) {
                            _unbanUser(displayName, userId);
                          } else {
                            _banUser(displayName, userId);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 132, 119, 197),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isBanned ? 'Unban' : 'Ban'),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (tab == 'allUsers' || tab == 'heldUsers') ...[
                      // Hold/Unhold Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (isHeld) {
                            _unholdUser(displayName, userId);
                          } else {
                            _showHoldDialog(displayName, userId);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 132, 119, 197),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isHeld ? 'Unhold' : 'Hold'),
                      ),
                    ],
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
      setState(() {
        // Update local variables or states that control the UI
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$displayName is no longer on hold'),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$displayName is now on hold for $hours hours'),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
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

  // Method to show a blank dialog for now
  void _showBlankUserDialog(String displayName, String userId) async {
    // Get the user's document from Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if the document exists and has the 'reportHistory' field
    List<dynamic> reportHistory =
        userDoc.exists && userDoc['reportHistory'] != null
            ? List.from(userDoc['reportHistory']) // Convert to a list
            : [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // White background for the content
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16.0), // Rounded corners for the dialog
          ),
          elevation: 10, // Shadow effect to make the dialog stand out
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Reported User: $displayName',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Bold deep purple title
              ),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16.0), // Padding inside the content
            child: SingleChildScrollView(
              // Make the content scrollable
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REPORT HISTORY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          Colors.deepPurple, // Darker purple for section header
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (reportHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'No reports found.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )
                  else
                    // Loop through the report history and display each one with a divider
                    ...reportHistory.map<Widget>((report) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reporter: ${report['reporterName']}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors
                                    .deepPurple, // Deep purple for reporter name
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reasons: ${report['reasons'].join(', ')}', // Joining reasons with commas
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Small space before the divider
                            const Divider(
                              color:
                                  Colors.deepPurple, // Deep purple for divider
                              thickness: 1.2,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14), // Larger padding for the button
                  ),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 16),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors
                      .deepPurple.shade200), // Light purple button background
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // White text on button
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded button
                    ),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'User Dashboard',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(
                  text: "All Users",
                ),
                Tab(text: "Banned\nUsers"),
                Tab(text: "Hold\nUsers"),
                Tab(text: "Reported\nUsers"),
              ]),
          backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching users'));
                  }
                  // Get the list of users
                  final users = snapshot.data!.docs;

                  return Row(children: [
                    Expanded(
                        flex: 1,
                        child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              String displayName = users[index]['displayName'];

                              // Safely access user data
                              bool isHeld = false;
                              bool isBanned = false;
                              Timestamp? holdTimestamp;
                              int holdDuration = 0;

                              try {
                                Map<String, dynamic> userData =
                                    users[index].data() as Map<String, dynamic>;
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
                                  _unholdUser(displayName, users[index].id);
                                }
                              }
                              String userId =
                                  users[index].id; // Firestore document ID

                              return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedUser =
                                          displayName; // Update selected user
                                    });

                                    // Show user details dialog
                                    _showUserDetailsDialog(displayName, userId,
                                        isHeld, isBanned, 'allUsers');
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 1,
                                          horizontal:
                                              1), // Reduced vertical spacing
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 132, 119, 197),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(children: [
                                        // User photo or default icon
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
                                        // User name
                                        Expanded(
                                            child: Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ))
                                      ])));
                            }))
                  ]);
                }),
            // Banned Users Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('isBanned', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching banned users'));
                }
                final bannedUsers = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bannedUsers.length,
                  itemBuilder: (context, index) {
                    String displayName = bannedUsers[index]['displayName'];
                    String userId = bannedUsers[index].id;

                    return GestureDetector(
                      onTap: () {
                        _showUserDetailsDialog(
                            displayName, userId, false, true, 'bannedUsers');
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 132, 119, 197),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: bannedUsers[index]['photoURL'] !=
                                    null
                                ? NetworkImage(bannedUsers[index]['photoURL'])
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Hold Users Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('isHeld', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching held users'));
                }
                final heldUsers = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: heldUsers.length,
                  itemBuilder: (context, index) {
                    String displayName = heldUsers[index]['displayName'];
                    String userId = heldUsers[index].id;

                    return GestureDetector(
                      onTap: () {
                        _showUserDetailsDialog(
                            displayName, userId, true, false, 'heldUsers');
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 132, 119, 197),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: heldUsers[index]['photoURL'] !=
                                    null
                                ? NetworkImage(heldUsers[index]['photoURL'])
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Reported Users Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('reportCount',
                      isGreaterThan: 0) // Filter users with report count > 0
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching reported users'));
                }
                final reportedUsers = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reportedUsers.length,
                  itemBuilder: (context, index) {
                    String displayName = reportedUsers[index]['displayName'];
                    String userId = reportedUsers[index].id;
                    int reportCount = reportedUsers[index]['reportCount'] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        // Show blank dialog frame for now
                        _showBlankUserDialog(displayName, userId);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 132, 119, 197),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: reportedUsers[index]['photoURL'] !=
                                    null
                                ? NetworkImage(reportedUsers[index]['photoURL'])
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Reports: $reportCount', // Show report count
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
