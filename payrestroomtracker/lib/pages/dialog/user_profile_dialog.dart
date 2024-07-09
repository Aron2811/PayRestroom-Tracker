import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({Key? key}) : super(key: key);

  @override
  _UserProfileDialogState createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  String? _displayName;
  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDisplayName();
  }

  Future<void> _fetchUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.displayName ?? "Username";
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            controller: _usernameController,
            textAlign: TextAlign.center,
            enabled: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '$_displayName',
              hintStyle: TextStyle(
                fontSize: 17,
                color: Color.fromARGB(255, 115, 99, 183),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Change Username',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 97, 84, 158),
                    ),
                  ),
                  content: TextField(
                    textAlign: TextAlign.center,
                    controller: _usernameController,
                    decoration: InputDecoration(
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
            child: const Text(
              "Change Username",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Colors.white,
              minimumSize: const Size(150, 40),
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: Color.fromARGB(255, 149, 134, 225),
                  width: 2.0,
                ),
              ),
              foregroundColor: Color.fromARGB(255, 135, 125, 186),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            label: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            icon: const Icon(
              Icons.logout_rounded,
              color: Color.fromARGB(255, 97, 84, 158),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/intropage');
            },
          ),
        ),
      ],
      title: const Text(
        'User Profile',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 106, 91, 169),
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.all(20.0),
    );
  }
}
