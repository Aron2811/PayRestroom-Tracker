import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAllReviewsPage extends StatefulWidget {
  final LatLng destination;
  final String username;
  final String report;

  const AdminAllReviewsPage({
    Key? key,
    required this.destination,
    required this.username,
    required this.report,
  }) : super(key: key);

  @override
  State<AdminAllReviewsPage> createState() => _AdminAllReviewsPageState();
}

class _AdminAllReviewsPageState extends State<AdminAllReviewsPage> {
  List<Map<String, dynamic>> reviews = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchReviews(); // Fetch reviews when page initializes
  }

  Future<void> _fetchReviews() async {
    final querySnapshot = await _firestore
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      reviews = querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  bool _isReviewOlderThanOneDay(Timestamp timestamp) {
    final reviewDate = timestamp.toDate();
    final currentDate = DateTime.now();
    final difference = currentDate.difference(reviewDate);
    return difference.inHours >= 24;
  }

  Future<void> _postReview(String review, String username, String photo,
      GeoPoint position, String userId) async {
    String reviewText = review;

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a review")),
      );
      return;
    }

    try {
      // Check if the marker already exists in Firestore
      final querySnapshot = await _firestore
          .collection('Tags')
          .where('position', isEqualTo: position)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        // Update existing marker document with the comment
        await _firestore.collection('Tags').doc(doc.id).update({
          'comments': FieldValue.arrayUnion([
            {
              'userId': userId,
              'userName': username,
              'photoURL': photo,
              'comment': reviewText,
              'timestamp': Timestamp.now(),
            }
          ]),
        });
      } else {
        // Create a new marker document with the comment
        await _firestore.collection('Tags').add({
          'position': GeoPoint(
              widget.destination.latitude, widget.destination.longitude),
          'comments': [
            {
              'userId': userId,
              'userName': username,
              'photoURL': photo,
              'comment': reviewText,
              'timestamp': Timestamp.now(),
            }
          ],
        });
      }
    } catch (e) {
      print('Error posting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post review")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reviews',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                _createRoute(AdminPage(
                    username: widget.username, report: widget.report)),
              );
            },
          ),
          backgroundColor: const Color.fromARGB(255, 97, 84, 158),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: reviews.isEmpty
                  ? Center(
                      child: Text(
                        'No Review Available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final isOldReview = _isReviewOlderThanOneDay(
                            review['timestamp'] as Timestamp);
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align children to the start (left)
                            children: [
                              Row(
                                children: [
                                  // Avatar and username on the left
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              review['photo'] ?? ''),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          review['username'] ?? 'Anonymous',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(
                                                255, 97, 84, 158),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Icon buttons on the right
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Color.fromARGB(255, 97, 84, 158),
                                    ),
                                    onPressed: () {
                                      _postReview(
                                          review['comment'],
                                          review['username'],
                                          review['photo'],
                                          review['position'],
                                          review['userId']);
                                      _deleteReview(review['id'], index);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.cancel_outlined,
                                      color: isOldReview ? Color.fromARGB(255, 97, 84, 158) : Colors.grey,
                                    ),
                                    onPressed: isOldReview
                                        ? () {
                                            _showDeleteDialog(
                                                review['id'], index);
                                          }
                                        : () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "The reject button will enable after one day"),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                review['restroomName'] ?? 'Unknown location',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 10),
                                  Text(
                                    review['timestamp'] != null
                                        ? _formatTimestamp(
                                            review['timestamp'] as Timestamp)
                                        : '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ReadMoreText(
                                review['comment'] ?? 'No comment provided',
                                textAlign:
                                    TextAlign.left, // Align text to the left
                                trimLines: 2,
                                trimMode: TrimMode.Line,
                                trimExpandedText: ' Show less',
                                moreStyle: const TextStyle(
                                  color: Color.fromARGB(255, 97, 84, 158),
                                  fontWeight: FontWeight.bold,
                                ),
                                trimCollapsedText: ' Show more',
                                lessStyle: const TextStyle(
                                  color: Color.fromARGB(255, 97, 84, 158),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReview(String reviewId, int index) async {
    try {
      // Delete the review from Firestore using the document ID
      await _firestore.collection('reviews').doc(reviewId).delete();

      // Remove the review from the local list and update the state
      setState(() {
        reviews.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review deleted successfully")),
      );
    } catch (e) {
      print('Error deleting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete review")),
      );
    }
  }

  void _showDeleteDialog(String reviewId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Are you sure you want to delete this review?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(255, 115, 99, 183),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              // Call delete function
              _deleteReview(reviewId, index);
              Navigator.of(context).pop(false);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
