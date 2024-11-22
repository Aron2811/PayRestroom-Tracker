import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_button/pages/bottomsheet/paidrestroom_info.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  String _name = "Paid Restroom Name";
  String _location = "Location";
  String _cost = "Cost";

  @override
  void initState() {
    super.initState();
    _fetchPaidRestroomName();
    _fetchPaidRestroomLocation();
    _fetchPaidRestroomCost();
  }

  //gets the paid restroom name from the database
  Future<void> _fetchPaidRestroomName() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final fetchedName = data['Name'] as String? ?? "Paid Restroom Name";

      setState(() {
        _name = fetchedName;
      });
    }
  }

  //gets the paid restroom location from the database
  Future<void> _fetchPaidRestroomLocation() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final fetchedLocation = data['Location'] as String? ?? "Location";

      setState(() {
        _location = fetchedLocation;
      });
    }
  }

  //gets the paid restroom cost from the database
  Future<void> _fetchPaidRestroomCost() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final fetchedCost = data['Cost'] as String? ?? "Cost";

      setState(() {
        _cost = fetchedCost;
      });
    }
  }

  //gets the average rating from the database
Stream<double> averageRatingStream() {
    return FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final averageRating = data['averageRating'] as double? ?? 0.0;

        return averageRating;
      } else {
        return 0.0;
      }
    });
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
                      Text(
                        _name,
                        maxLines: 3,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 64, 55, 107),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _location,
                        maxLines: 3,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _cost,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          StreamBuilder<double>(  // Displays the average rating using a StreamBuilder with a RatingBar indicator.
            stream: averageRatingStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading rating: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No rating available');
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${snapshot.data!.toStringAsFixed(1)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    RatingBarIndicator(
                      
                      rating: snapshot.data!,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: const Color.fromARGB(255, 97, 84, 158),
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      unratedColor: Colors.white24,
                      direction: Axis.horizontal,
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
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: ElevatedButton(
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
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
      onTap: () {
        // Displays a modal bottom sheet with information about a paid restroom
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