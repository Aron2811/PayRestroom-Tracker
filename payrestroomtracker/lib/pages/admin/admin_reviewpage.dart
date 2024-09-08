import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminReviewsPage extends StatefulWidget {
  final String username;
  final String report;
  final LatLng destination;

  const AdminReviewsPage({
    Key? key,
    required this.username,
    required this.report,
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

  // Fetches reviews and ratings for a specific location from Firestore, updating the state with the results.
  Future<void> _fetchReviews() async {
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

        reviews.forEach((review) {
          final userRating = ratings.firstWhere(
            (rating) => rating['userId'] == review['userId'],
            orElse: () =>
                {'rating': 0.0}, // Set default rating to 0 if not found
          );

          review['rating'] = userRating['rating'];
        });
      });
    } else {
      setState(() {
        reviews = [];
      });
    }
  }

  //formats the timestamp to dd, MMM, yyyy, hh:mm, a
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  void _deleteReview(int index) async {
    // Fetch the document for the given position
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final docRef = doc.reference;

      // Remove the comment from the list of comments
      List<Map<String, dynamic>> updatedComments =
          List<Map<String, dynamic>>.from(doc.data()['comments']);
      updatedComments.removeAt(index);

      // Update the document with the new list of comments
      await docRef.update({'comments': updatedComments});

      setState(() {
        reviews.removeAt(index); // Update the local state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review deleted successfully'),
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
        ),
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
                        return Padding(
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
                                    review['userName'] ?? 'Anonymous',  //displays the user name
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Displays a confirmation dialog for deleting a review, and calls the delete function if confirmed.
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

  // Creates a custom route with a slide transition animation from the bottom to the top.
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