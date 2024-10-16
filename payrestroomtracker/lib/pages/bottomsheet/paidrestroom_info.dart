import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter_button/pages/user/add_review_page.dart';
import 'package:flutter_button/pages/bottomsheet/draggablesheet.dart';
import 'package:flutter_button/pages/user/report_page.dart';
import 'package:flutter_button/pages/user/reviews_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaidRestroomInfo extends StatelessWidget {
  final Function(LatLng, String) drawRouteToDestination;
  final LatLng destination;
  final Function toggleVisibility;

  const PaidRestroomInfo({
    Key? key,
    required this.drawRouteToDestination,
    required this.destination,
    required this.toggleVisibility,
  }) : super(key: key);

Future<List<String>> _fetchImageUrls() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Tags')
      .where('position', isEqualTo: GeoPoint(destination.latitude, destination.longitude))
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    final doc = querySnapshot.docs.first;
    final data = doc.data();
    final imageUrls = data?['ImageUrls'] as List<dynamic>? ?? [];
    return List<String>.from(imageUrls);
  } else {
    return [];
  }
}
  @override
  Widget build(BuildContext context) {
    return MyDraggableSheet(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Paid Restroom Name",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 64, 55, 107),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Location",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Cost",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 125),
              const Text(
                "3.1",
                textAlign: TextAlign.center,
                style: TextStyle(
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
                filledColor: Color.fromARGB(255, 97, 84, 158),
                halfFilledColor: Color.fromARGB(255, 186, 176, 228),
                onRatingChanged: (value) => debugPrint(''),
                initialRating: 3,
                maxRating: 5,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 30),
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
                  toggleVisibility();
                  drawRouteToDestination(destination, 'commute');
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
                  Navigator.push(context, _createRoute(ReportPage()));
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
          const SizedBox(height: 30),
          FutureBuilder<List<String>>(
            future: _fetchImageUrls(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading images');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No images available');
              } else {
                return SizedBox(
                  height: 250,
                  width: 300,
                  child: AnotherCarousel(
                    borderRadius: true,
                    boxFit: BoxFit.cover,
                    radius: const Radius.circular(10),
                    images: snapshot.data!.map((url) => NetworkImage(url)).toList(),
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
                  Navigator.push(context, _createRoute(const AddReviewPage()));
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
                  Navigator.push(context, _createRoute(ReviewsPage()));
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: Container(
                      color: Colors.white,
                      height: 40,
                      width: 40,
                      child: const Icon(
                        Icons.person_2_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RatingBar(
                    size: 30,
                    alignment: Alignment.center,
                    filledIcon: Icons.star,
                    emptyIcon: Icons.star_border,
                    emptyColor: Colors.white24,
                    filledColor: const Color.fromARGB(255, 97, 84, 158),
                    halfFilledColor: const Color.fromARGB(255, 186, 176, 228),
                    onRatingChanged: (p0) {},
                    initialRating: 3,
                    maxRating: 5,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
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

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
