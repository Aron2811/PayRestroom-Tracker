import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  //late TabController _tabController;
  
  String? selectedUser; // To track the selected user

  void _showUserDetailsDialog(
      String displayName, String userId, bool isHeld, bool isBanned) {
    // Show the dialog with the hold button only after ensuring the widget context is mounted
    if (context.mounted) {
      showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Set background color to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
       
          const SizedBox(height: 10), // Space below the avatar
          // Display name
          Text(
            displayName,
            style: const TextStyle(
              color: Color.fromARGB(255, 132, 119, 197), // Custom color
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15), // Space below the display name
          const Text(
            'You can choose to ban or hold/unhold the user.',
            style: TextStyle(
              color: Color.fromARGB(255, 132, 119, 197),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20), // Space before the buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ban/Unban Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  if (isBanned) {
                    _unbanUser(displayName, userId); // Logic for unban
                  } else {
                    _banUser(displayName, userId); // Logic for ban
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 132, 119, 197),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isBanned ? 'Unban' : 'Ban'),
              ),
              const SizedBox(width: 10), // Space between buttons
              // Hold/Unhold Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  if (isHeld) {
                    _unholdUser(displayName, userId); // Logic for unhold
                  } else {
                    _showHoldDialog(displayName, userId); // Logic for hold
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 132, 119, 197),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
  

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
   child:   Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard', style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 3,
              
            ),),
 bottom: TabBar(
         labelColor: Colors.white,
         unselectedLabelColor: Colors.white,
         indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "All Users", ),
            Tab(text: "Banned Users"),
            Tab(text: "Hold Users"),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
      
      ),
 
    
      body: TabBarView(
       
        children: [
         
              StreamBuilder<QuerySnapshot>(
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
        Map<String, dynamic> userData = users[index].data() as Map<String, dynamic>;
        isHeld = userData['isHeld'] ?? false;
        isBanned = userData['isBanned'] ?? false;
        holdTimestamp = userData['holdTimestamp'];
        holdDuration = userData['holdDuration'] ?? 0;
      } catch (e) {
        print("Error accessing user data: $e");
      }

      // Check if hold has expired
      if (isHeld && holdTimestamp != null) {
        DateTime holdEndTime = holdTimestamp.toDate().add(Duration(hours: holdDuration));
        if (DateTime.now().isAfter(holdEndTime)) {
          _unholdUser(displayName, users[index].id);
        }
      }
String userId = users[index].id; // Firestore document ID

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedUser = displayName; // Update selected user
          });

          // Show user details dialog
          _showUserDetailsDialog(displayName, userId, isHeld, isBanned);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1), // Reduced vertical spacing
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 132, 119, 197),
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // User photo or default icon
              users[index]['photoURL'] != null && users[index]['photoURL'] != ''
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(users[index]['photoURL']),
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
                  ),))])));

    }))]);
          }

              
            ),
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
      return const Center(child: Text('Error fetching banned users'));
    }

    final bannedUsers = snapshot.data!.docs;

 
    return ListView.builder(
      itemCount: bannedUsers.length,
      itemBuilder: (context, index) {
        String displayName = bannedUsers[index]['displayName'];
        String? photoURL = bannedUsers[index]['photoURL'];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 132, 119, 197), // Background color
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                  ? NetworkImage(photoURL)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider, // Default avatar image if no URL
            ),
            title: Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  },
),

StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .where('isHeld', isEqualTo: true) // Fetch only held users
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
        String? photoURL = heldUsers[index]['photoURL'];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 132, 119, 197), // Background color
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                  ? NetworkImage(photoURL)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider, // Default avatar image if no URL
            ),
            title: Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  },
),





       ],),)
    );
  }
}




