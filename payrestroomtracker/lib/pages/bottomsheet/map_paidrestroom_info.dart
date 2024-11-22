import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart' as custom_rating_bar;
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter_button/pages/user/add_review_page.dart';
import 'package:flutter_button/pages/user/report_page.dart';
import 'package:flutter_button/pages/user/reviews_page.dart';
import 'package:flutter_button/pages/bottomsheet/draggablesheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_button/pages/user/street_view.dart';

class MapPaidRestroomInfo extends StatefulWidget {
  final Function(LatLng, String) drawRouteToDestination;
  final LatLng destination;
  final Function toggleVisibility;

  const MapPaidRestroomInfo({
    Key? key,
    required this.drawRouteToDestination,
    required this.destination,
    required this.toggleVisibility,
  }) : super(key: key);

  @override
  _MapPaidRestroomInfoState createState() => _MapPaidRestroomInfoState();
}

class _MapPaidRestroomInfoState extends State<MapPaidRestroomInfo> {
  late Future<double> _userRatingFuture;
  String _name = "Paid Restroom Name";
  String _location = "Location";
  String _cost = "Cost";

  @override
  void initState() {
    super.initState();
    _userRatingFuture = fetchUserRating();
    _fetchPaidRestroomName();
    _fetchPaidRestroomLocation();
    _fetchPaidRestroomCost();
  }

  double calculateAverageRating(List<dynamic> ratings) {
    if (ratings.isEmpty) {
      return 0.0; // Return 0 if there are no ratings yet
    }

    // Calculate total sum of ratings
    double totalRating =
        ratings.fold(0, (sum, rating) => sum + rating['rating']);

    // Calculate average rating
    return totalRating / ratings.length;
  }

  // Updates or adds a rating for a location and calculates the average rating.
  void _updateRating(double newRating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need to be logged in to rate'),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
        return;
      }

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

        // Check if the user has already rated this location
        final userRatingIndex =
            ratings.indexWhere((rating) => rating['userId'] == user.uid);

        if (userRatingIndex != -1) {
          // Update existing rating
          ratings[userRatingIndex]['rating'] = newRating;
          ratings[userRatingIndex]['timestamp'] = Timestamp.now();
        } else {
          // Add new rating
          ratings.add({
            'userId': user.uid,
            'rating': newRating,
            'timestamp': Timestamp.now(),
          });
        }

        // Calculate average rating
        double averageRatingValue = calculateAverageRating(ratings);

        await FirebaseFirestore.instance.collection('Tags').doc(doc.id).update({
          'ratings': ratings,
          'averageRating': averageRatingValue,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rating updated successfully"),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      } else {
        // Create a new marker document with the rating
        await FirebaseFirestore.instance.collection('Tags').add({
          'position': GeoPoint(
              widget.destination.latitude, widget.destination.longitude),
          'ratings': [
            {
              'userId': user.uid,
              'rating': newRating,
              'timestamp': Timestamp.now(),
            }
          ],
          'averageRating': newRating, // Initial average rating
          'Rating': newRating.toString(), // Store the rating as a string
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rating added successfully"),
            backgroundColor: Color.fromARGB(255, 115, 99, 183),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update rating: $e'),
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
        ),
      );
    }
  }

   //gets the restroom name from the database
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

  //gets the restroom location from the database
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

  //gets the restroom cost from the database
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

  //gets the image of the restroom from the database
  Future<List<String>> _fetchImageUrls() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final imageUrls = data['ImageUrls'] as List<dynamic>? ?? [];
      return List<String>.from(imageUrls);
    } else {
      return [];
    }
  }

  //gets the user rating in the restroom if there is any from the data base
  Future<double> fetchUserRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0.0; // Default rating if the user is not logged in
    }

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

      final userRating = ratings.firstWhere(
          (rating) => rating['userId'] == user.uid,
          orElse: () => {'rating': 0.0}); // Default rating if not found

      return userRating['rating'] as double? ?? 0.0;
    } else {
      return 0.0;
    }
  }

  // Streams the average rating for a specific location from Firestore.
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

  Widget build(BuildContext context) {
    return MyDraggableSheet(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              _name,
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 64, 55, 107),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              _location,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _cost,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: const Color.fromARGB(255, 226, 223, 229),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 97, 84, 158),
                      width: 2.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    widget.toggleVisibility();
                    widget.drawRouteToDestination(
                        widget.destination, 'commute');
                  },
                  label: const Text(
                    'Directions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(
                    Icons.directions,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: const Color.fromARGB(255, 226, 223, 229),
                    minimumSize: const Size(130, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 97, 84, 158),
                      width: 2.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        _createRoute(ReportPage(
                          destination: widget.destination,
                        )));
                  },
                  label: const Text(
                    'Report',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(
                    Icons.report_problem_outlined,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              enableFeedback: false,
              backgroundColor: const Color.fromARGB(255, 226, 223, 229),
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: const BorderSide(
                color: Color.fromARGB(255, 97, 84, 158),
                width: 2.0,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                _createRoute(
                  StreetViewPage(
                      location: widget.destination, locationGuide: _location),
                ),
              );
            },
            label: const Text(
              'View Street',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(
              Icons.streetview,
              color: Color.fromARGB(255, 97, 84, 158),
            ),
          ),
          const SizedBox(height: 30),
          FutureBuilder<List<String>>(  // Displays a carousel of images fetched from a future with loading and error handling.
            future: _fetchImageUrls(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading images: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No images available');
              } else {
                return SizedBox(
                  height: 250,
                  width: 300,
                  child: AnotherCarousel(
                    borderRadius: true,
                    boxFit: BoxFit.cover,
                    radius: const Radius.circular(10),
                    images:
                        snapshot.data!.map((url) => NetworkImage(url)).toList(),
                    showIndicator: false,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  enableFeedback: false,
                  backgroundColor: const Color.fromARGB(255, 148, 139, 192),
                  minimumSize: const Size(250, 45),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 115, 99, 183),
                      width: 2.0,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      _createRoute(
                          AddReviewPage(destination: widget.destination)));
                },
                label: const Text(
                  'Add a Review',
                  style: TextStyle(
                      fontSize: 17, color: Colors.white, letterSpacing: 3),
                ),
                icon: const Icon(
                  Icons.person_2_rounded,
                  color: Color.fromARGB(255, 97, 84, 158),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: const Text(
                  "View All Reviews",
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      _createRoute(
                          ReviewsPage(destination: widget.destination)));
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Share your experience to help others",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 15),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      FirebaseAuth.instance.currentUser?.photoURL ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  FutureBuilder<double>(
                    future: _userRatingFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error loading user rating: ${snapshot.error}');
                      } else {
                        double userRating = snapshot.data ??
                            0.0; // Default to 0.0 if snapshot.data is null
                        return custom_rating_bar.RatingBar(
                          size: 30,
                          alignment: Alignment.center,
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          emptyColor: Colors.white24,
                          filledColor: const Color.fromARGB(255, 97, 84, 158),
                          halfFilledColor:
                              const Color.fromARGB(255, 186, 176, 228),
                          onRatingChanged: _updateRating,
                          initialRating: userRating,
                          maxRating: 5,
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// Creates a slide transition route from the bottom of the screen to the center.
Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}