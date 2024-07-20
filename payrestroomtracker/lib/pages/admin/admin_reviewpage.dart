import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminReviewsPage extends StatefulWidget {
  final LatLng destination;

  const AdminReviewsPage({
    Key? key,
    required this.destination, 
  }) : super(key: key);

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews(); // Fetch reviews when page initializes
  }

  Future<void> _fetchReviews() async {
    final user = FirebaseAuth.instance.currentUser;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final ratings = doc.data().containsKey('ratings')
          ? List<Map<String, dynamic>>.from(doc['ratings'] as List<dynamic>)
          : [];

      setState(() {
        reviews = List<Map<String, dynamic>>.from(doc.data()['comments'] ?? []);

        // Find the user's rating and update the initialRating
        if (user != null) {
          final userRating = ratings.firstWhere(
            (rating) => rating['userId'] == user.uid,
            orElse: () => {'rating': 0}, // Set default rating to 0 if not found
          );

          reviews.forEach((review) {
            if (review['userId'] == user.uid) {
              review['rating'] = userRating['rating'];
            }
          });
        }
      });
    } else {
      setState(() {
        reviews = [];
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Future<void> _deleteReview(int index) async {
    final reviewToDelete = reviews[index];

    // Find the document in Firestore to update
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final docRef = doc.reference;

      // Remove the review from the Firestore document
      await docRef.update({
        'comments': FieldValue.arrayRemove([reviewToDelete])
      });

      // Update the local state
      setState(() {
        reviews.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review has been deleted'),
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.push(
                context,
                _createRoute(AdminMap(
                  username: "", report: '', 
                )));
          },
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(fontSize: 20, color: Colors.white),
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
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              foregroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              backgroundColor:
                                  const Color.fromARGB(255, 162, 151, 211),
                              icon: Icons.delete_outline_rounded,
                              onPressed: (context) {
                                _showDeleteDialog(index);
                              },
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align children to the start (left)
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(review['photoURL'] ?? ''),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    review['userName'] ?? 'Anonymous',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 97, 84, 158),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  RatingBar.readOnly(
                                    size: 20,
                                    alignment: Alignment.center,
                                    filledIcon: Icons.star,
                                    emptyIcon: Icons.star_border,
                                    emptyColor: Colors.grey,
                                    filledColor:
                                        const Color.fromARGB(255, 97, 84, 158),
                                    halfFilledColor: const Color.fromARGB(
                                        255, 186, 176, 228),
                                    initialRating: review['rating'] ??
                                        0.0, // Update with review's actual rating
                                    maxRating: 5,
                                  ),
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
                              SizedBox(height: 10),
                              ReadMoreText(
                                review['comment'] ?? '',
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
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
              _deleteReview(index); // Call delete function
              Navigator.of(context).pop(true);
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
