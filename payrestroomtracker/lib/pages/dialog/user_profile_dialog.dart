import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // For BackdropFilter

class UserProfileDrawer extends StatefulWidget {
  const UserProfileDrawer({super.key});

  @override
  _UserProfileDrawerState createState() => _UserProfileDrawerState();
}

class _UserProfileDrawerState extends State<UserProfileDrawer> {
  String? _displayName;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDisplayName();
  }

  // Fetch the user display name from Firebase
  Future<void> _fetchUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.displayName ?? "Username";
      });
    }
  }

  // Update the user display name
  Future<void> _updateUsername(String newUsername) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(newUsername);
        await user.reload();
        setState(() {
          _displayName = newUsername;
        });
        await _updateFirestoreUsername(newUsername);
      } catch (e) {
        print("Error updating username: $e");
      }
    }
  }

  // Update the username in Firestore
  Future<void> _updateFirestoreUsername(String newUsername) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.update({'displayName': newUsername});
      } catch (e) {
        print("Error updating Firestore username: $e");
      }
    }
  }

  // Log out the user and navigate to the intro page
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, '/userloginpage', (route) => false);
    } catch (e) {
      // Handle the error accordingly, e.g., show a dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: FirebaseAuth.instance.currentUser?.photoURL != null
                    ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                    : AssetImage("assets/default_profile_image.png") as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Applying the blur effect to the background image
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0), // Transparent overlay
                  ),
                ),
                // Content
                Positioned(
                  top: 20,
                  left: 10,
                  child: CircleAvatar(
                    radius: 40, // Adjust the size of the circle
                    backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                        : AssetImage("assets/default_profile_image.png") as ImageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Welcome, $_displayName',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Change Username'),
            leading: Icon(Icons.edit_rounded),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Change Username',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 97, 84, 158),
                    ),
                  ),
                  content: TextField(
                    textAlign: TextAlign.center,
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new username',
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Update'),
                      onPressed: () {
                        String newUsername = _usernameController.text.trim();
                        if (newUsername.isNotEmpty) {
                          _updateUsername(newUsername);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: Text('Suggest a Paid Restroom'),
            leading: Icon(Icons.add_circle_rounded),
            onTap: () {
              Navigator.pushNamed(context, '/suggestPaidRestroomPage');
            },
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.logout_rounded),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
