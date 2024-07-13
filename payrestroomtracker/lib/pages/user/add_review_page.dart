import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_button/pages/user/reviews_page.dart'; // Import ReviewsPage

class AddReviewPage extends StatefulWidget {
  final LatLng destination;

  const AddReviewPage({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _postReview() async {
    String reviewText = _textController.text;

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a review")),
      );
      return;
    }

    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Check if the marker already exists in Firestore
        final querySnapshot = await _firestore
            .collection('Tags')
            .where('position', isEqualTo: GeoPoint(widget.destination.latitude, widget.destination.longitude))
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final comments = doc.data().containsKey('comments')
              ? doc['comments'] as List<dynamic>
              : [];

          // Check if the user has already posted a review in the last 24 hours
          final now = Timestamp.now();
          final oneDayAgo = Timestamp.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - 86400000);

          bool hasRecentReview = comments.any((comment) {
            final Timestamp commentTimestamp = comment['timestamp'];
            return comment['userId'] == user.uid && commentTimestamp.millisecondsSinceEpoch > oneDayAgo.millisecondsSinceEpoch;
          });

          if (hasRecentReview) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("You can only post one review per day for this destination")),
            );
            return;
          }

          // Update existing marker document with the comment
          await _firestore.collection('Tags').doc(doc.id).update({
            'comments': FieldValue.arrayUnion([
              {
                'userId': user.uid,
                'userName': user.displayName ?? 'Anonymous',
                'photoURL': user.photoURL ?? '',
                'comment': reviewText,
                'timestamp': Timestamp.now(),
              }
            ]),
          });
        } else {
          // Create a new marker document with the comment
          await _firestore.collection('Tags').add({
            'position': GeoPoint(widget.destination.latitude, widget.destination.longitude),
            'comments': [
              {
                'userId': user.uid,
                'userName': user.displayName ?? 'Anonymous',
                'photoURL': user.photoURL ?? '',
                'comment': reviewText,
                'timestamp': Timestamp.now(),
              }
            ],
          });
        }

        // Navigate to ReviewsPage after posting review
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewsPage(destination: widget.destination),
          ),
        );
      } catch (e) {
        print('Error posting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post review")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a Review',
          style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 3),
        ),
        backgroundColor: const Color.fromARGB(255, 97, 84, 158),
        centerTitle: true,
        actions: <Widget>[
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: Color.fromARGB(255, 97, 84, 158),
              minimumSize: const Size(10, 30),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: _postReview,
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 164, 151, 219),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 17),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 115, 99, 183)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
