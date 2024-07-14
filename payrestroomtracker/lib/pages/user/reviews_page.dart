import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class ReviewsPage extends StatefulWidget {
  final LatLng destination;

  const ReviewsPage({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Map<String, dynamic>> reviews = [];
  double userRating = 0;

  /// List to store reviews

  @override
  void initState() {
    super.initState();
    _fetchReviews();// Fetch reviews when page initializes
  }

  Future<void> _fetchReviews() async {
    // Query Firestore for reviews at the marker's position
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      setState(() {
        reviews = List<Map<String, dynamic>>.from(data['comments'] ?? []);
      });
    } else {
      setState(() {
        reviews = []; // Clear reviews if none found
      });
    }
  }


  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/mappage');
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
                      'Be the first to review!',
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
                                  halfFilledColor:
                                      const Color.fromARGB(255, 186, 176, 228),
                                  initialRating: (review['userRating'] ?? 0.0).toDouble(), // Update with review's actual rating if available
                                  maxRating: 5,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  review['timestamp'] != null
                                      ? _formatTimestamp(
                                          review['timestamp'] as Timestamp)
                                      : '',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
