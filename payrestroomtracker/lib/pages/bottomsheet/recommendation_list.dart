import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_button/pages/bottomsheet/paidrestroom_info.dart';

class PaidRestroomRecommendationList extends StatefulWidget {
  final Function(LatLng, String) drawRouteToDestination;
  final LatLng destination;
  final Function toggleVisibility;

  const PaidRestroomRecommendationList({
    super.key,
    required this.drawRouteToDestination,
    required this.destination,
    required this.toggleVisibility,
  });

  @override
  _PaidRestroomRecommendationListState createState() =>
      _PaidRestroomRecommendationListState();
}

class _PaidRestroomRecommendationListState
    extends State<PaidRestroomRecommendationList> {
  late Future<double> _currentRatingFuture;

  @override
  void initState() {
    super.initState();
    _currentRatingFuture = fetchRating();
  }



  Future<double> fetchRating() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final fetchedRating = data?['rating'] as double? ?? 0.0;
      return fetchedRating;
    } else {
      return 0.0;
    }
  }

  void _updateRating(double newRating) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .where('position',
              isEqualTo: GeoPoint(
                  widget.destination.latitude, widget.destination.longitude))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final docRef =
            FirebaseFirestore.instance.collection('Tags').doc(doc.id);

        await docRef.update({
          'rating': newRating,
        });

        setState(() {
          _currentRatingFuture = Future.value(newRating);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No document found for the specified location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update rating')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Paid Restroom Name",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Location",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          FutureBuilder<double>(
                            future: _currentRatingFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text('Error loading rating');
                              } else if (!snapshot.hasData) {
                                return const Text('No rating available');
                              } else {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${snapshot.data}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                                    RatingBar(
                                      size: 20,
                                      alignment: Alignment.center,
                                      filledIcon: Icons.star,
                                      emptyIcon: Icons.star_border,
                                      emptyColor: Colors.white24,
                                      filledColor: const Color.fromARGB(
                                          255, 97, 84, 158),
                                      halfFilledColor: const Color.fromARGB(
                                          255, 186, 176, 228),
                                      onRatingChanged: _updateRating,
                                      initialRating: snapshot.data!,
                                      maxRating: 5,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(60, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () {
                    widget.toggleVisibility();
                    widget.drawRouteToDestination(
                        widget.destination, 'commute');
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.directions,
                    color: Color.fromARGB(255, 85, 70, 152),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
      onTap: () {
       showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        backgroundColor: Colors.transparent,
        builder: (context) => PaidRestroomInfo(
              drawRouteToDestination: widget.drawRouteToDestination,
              destination: widget.destination,
              toggleVisibility: widget.toggleVisibility,
            ));
      },
    );
  }
}
