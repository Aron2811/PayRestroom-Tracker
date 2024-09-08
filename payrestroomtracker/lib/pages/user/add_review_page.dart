import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import ReviewsPage

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
  String _restroomName = "Paid Restroom Name";

  @override
  void initState() {
    super.initState();
    _fetchPaidRestroomName();
  }

  //gets the paid restroom name from the data base
  Future<void> _fetchPaidRestroomName() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .where('position',
              isEqualTo: GeoPoint(
                  widget.destination.latitude, widget.destination.longitude))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final fetchedName = data['Name'] as String? ?? "No name available";

        setState(() {
          _restroomName = fetchedName;
        });
      } else {
        setState(() {
          _restroomName = "No restroom found at this location";
        });
      }
    } catch (e) {
      setState(() {
        _restroomName = "Error fetching data";
      });
    }
  }

  // Stores a user review for a specific restroom, ensuring one review per day
  Future<void> storeReview() async {
    String reviewText = _textController.text;

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a review")),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user != null) {
      // Query Firestore to get the most recent review by the user for the specific restroom
      QuerySnapshot restroomReviewSnapshot = await _firestore
          .collection('reviews')
          .where('username', isEqualTo: user.displayName)
          .where('restroomName',
              isEqualTo:
                  _restroomName) // Check if the review is for the same restroom
          .orderBy('timestamp', descending: true) // Get the most recent review
          .limit(1) // Limit to the most recent review
          .get();

      if (restroomReviewSnapshot.docs.isNotEmpty) {
        // Get the timestamp of the most recent review
        Timestamp lastReviewTimestamp =
            restroomReviewSnapshot.docs.first['timestamp'];
        DateTime lastReviewDate = lastReviewTimestamp.toDate();

        // Get the start of the current day (midnight)
        DateTime startOfToday = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);

        // Check if the last review was made today
        if (lastReviewDate.isAfter(startOfToday)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "You can only post one review per day for this restroom")),
          );
          _textController.clear();
          return;
        }
      }

      // Check if the marker already exists in Firestore for the current destination
      QuerySnapshot tagSnapshot = await _firestore
          .collection('Tags')
          .where('position',
              isEqualTo: GeoPoint(
                  widget.destination.latitude, widget.destination.longitude))
          .get();

      if (tagSnapshot.docs.isNotEmpty) {
        final doc = tagSnapshot.docs.first;
        final data = doc.data()
            as Map<String, dynamic>?; // Cast data to Map<String, dynamic>
        final comments = data?.containsKey('comments') == true
            ? data!['comments'] as List<dynamic>
            : [];

        // Check if the user has already posted a review in the last 24 hours
        final now = Timestamp.now();
        final oneDayAgo = Timestamp.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch - 86400000);

        bool hasRecentReview = comments.any((comment) {
          final Timestamp commentTimestamp = comment['timestamp'];
          return comment['userId'] == user.uid &&
              commentTimestamp.millisecondsSinceEpoch >
                  oneDayAgo.millisecondsSinceEpoch;
        });

        if (hasRecentReview) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                   "You can only post one review per day for this restroom")),
          );
          _textController.clear();
          return;
        }
      }

      // If no comment was found for today, store the new comment
      await _firestore.collection('reviews').add({
        'userId': user.uid,
        'username': user.displayName,
        'photo': user.photoURL,
        'comment': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'restroomName': _restroomName,
        'position':
            GeoPoint(widget.destination.latitude, widget.destination.longitude),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your Review Will Be Checked By The Admin")),
      );
      _textController.clear();
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
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: storeReview,
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
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 115, 99, 183)),
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