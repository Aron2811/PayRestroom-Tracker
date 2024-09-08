import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart' as custom_rating_bar;

class AppRateDialog extends StatefulWidget {
  final String displayName;

  const AppRateDialog({super.key, required this.displayName});

  @override
  _AppRateDialogState createState() => _AppRateDialogState();
}

class _AppRateDialogState extends State<AppRateDialog> {
  bool _hasRated = false;
  String _userDisplayName = '';

  @override
  void initState() {
    super.initState();
    _hasUserRated();
    _fetchUsername();
  }
  //fetch username
  Future<void> _fetchUsername() async {
    if (widget.displayName != null && widget.displayName!.isNotEmpty) {
      setState(() {
        _userDisplayName = widget.displayName!;
      });
      await _hasUserRated();
    } else {
      // Fetch the current user's display name from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null) {
        setState(() {
          _userDisplayName = user.displayName!;
        });
        await _hasUserRated();
      } else {
        print('User is not logged in or display name is not available.');
      }
    }
  }
  // Checks if the user has already rated the app
  Future<bool> _hasUserRated() async {
    if (_userDisplayName.isNotEmpty) {
      try {
        DocumentSnapshot userRating = await FirebaseFirestore.instance
            .collection('apprating')
            .doc(_userDisplayName)
            .get();

        if (userRating.exists) {
          var data = userRating.data() as Map<String, dynamic>?;
          return data != null && data.containsKey('hasrated')
              ? data['hasrated'] as bool
              : false;
        }
      } catch (e) {
        print('Error checking user rating: $e');
      }
    }
    return false; // Return false if the user has not rated or an error occurred
  }
  // Submits the user rating to Firestore
  Future<void> _submitRating(BuildContext context, double rating) async {
    if (_userDisplayName.isNotEmpty) {
      // Check if the user has already rated
      bool hasRated = await _hasUserRated();

      if (!hasRated) {
        await FirebaseFirestore.instance
            .collection('apprating')
            .doc(_userDisplayName)
            .set({
          'username': _userDisplayName,
          'rating': rating,
        });
        setState(() {
          _hasRated = true; // Update local variable
        });
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already rated the app.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username is not available. Cannot submit rating.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Rate our App',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 106, 91, 169),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enjoyed the convenience? We'd love to hear your feedback—please rate our paid restroom app!",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          custom_rating_bar.RatingBar(
            size: 30,
            alignment: Alignment.center,
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            emptyColor: Colors.grey,
            filledColor: const Color.fromARGB(255, 97, 84, 158),
            halfFilledColor: const Color.fromARGB(255, 186, 176, 228),
            onRatingChanged: (rating) {
              _submitRating(context, rating);
            },
            initialRating: 0,
            maxRating: 5,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(children: [
          ElevatedButton(
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
              foregroundColor: const Color.fromARGB(255, 135, 125, 186),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            child: const Text(
              "Remind me Later",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(100, 40),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 149, 134, 225),
                      width: 2.0,
                    ),
                  ),
                  foregroundColor: const Color.fromARGB(255, 135, 125, 186),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(50, 40),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 149, 134, 225),
                      width: 2.0,
                    ),
                  ),
                  foregroundColor: const Color.fromARGB(255, 135, 125, 186),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  "Ok",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ]),
      ],
    );
  }
}
