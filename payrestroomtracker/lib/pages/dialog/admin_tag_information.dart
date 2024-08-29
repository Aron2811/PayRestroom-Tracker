import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/admin_reviewpage.dart';
import 'package:flutter_button/pages/dialog/admin_edit_info.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTagInformation extends StatefulWidget {
  final MarkerId markerId;
  final Future<void> Function(MarkerId) deleteMarker;
  final LatLng destination;

  const AdminTagInformation({
    Key? key,
    required this.markerId,
    required this.deleteMarker,
    required this.destination,
  }) : super(key: key);

  @override
  _AdminTagInformationState createState() => _AdminTagInformationState();
}

class _AdminTagInformationState extends State<AdminTagInformation> {
  List<String> imageUrls = [];
  String _name = "Paid Restroom Name";
  String _location = "Location";
  String _cost = "Cost";
  double rating = 0; // Default rating
  String ratingText = "0.0"; // Default rating text

  @override
  void initState() {
    super.initState();
    fetchImageUrls(context);
    _fetchPaidRestroomName();
    _fetchPaidRestroomLocation();
    _fetchPaidRestroomCost();
    _fetchRating(); // Fetch rating
  }

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

   Future<void> _fetchRating() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(
                widget.destination.latitude, widget.destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final fetchedRating = data['Rating'] as String? ?? "0.0";

      setState(() {
        rating = double.parse(fetchedRating);
        ratingText = fetchedRating;
      });
    }
  }

  Future<void> fetchImageUrls(BuildContext context) async {
    try {
      DocumentSnapshot tagSnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .doc(widget.markerId.value)
          .get();

      if (tagSnapshot.exists) {
        List<dynamic> urls = tagSnapshot.get('ImageUrls') ?? [];
        setState(() {
          imageUrls = List<String>.from(urls);
        });
      } else {
        setState(() {
          imageUrls = []; // or set to a default value as needed
        });
      }
    } catch (e) {
      // Display error message as a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching image URLs: Add Image'),
          duration: Duration(seconds: 3),
          backgroundColor: Color.fromARGB(
              255, 115, 99, 183), // Adjust the duration as needed
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      actions: [
        SizedBox(height: 30),
        Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  _name,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 97, 84, 158),
                    fontWeight: FontWeight.bold,
                  ),
                ))),
        const SizedBox(height: 10),
        Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  _location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 97, 84, 158),
                  ),
                ))),
        const SizedBox(height: 10),
        Align(
            alignment: Alignment.center,
            child: Text(
              _cost,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 97, 84, 158),
              ),
            )),
        const SizedBox(height: 10),
        Column(
          children: [
            FullScreenWidget(
                disposeLevel: DisposeLevel.High,
                child: Center(
                    child: SizedBox(
                  height: 250,
                  width: 300,
                  child: AnotherCarousel(
                    autoplay: false,
                    borderRadius: true,
                    boxFit: BoxFit.cover,
                    radius: Radius.circular(10),
                    images: imageUrls.map((url) => NetworkImage(url)).toList(),
                    showIndicator: false,
                  ),
                ))),
            const SizedBox(height: 30),
            Padding(
                padding: EdgeInsets.only(left: 60, right: 30),
                child: Row(children: [
                ])),
            SizedBox(height: 20),
            Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: const Text(
                    "View All Reviews",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 97, 84, 158),
                      letterSpacing: 2,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        _createRoute(
                            AdminReviewsPage(destination: widget.destination)));
                  },
                )),
            const SizedBox(height: 15),
            Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        showDialog(
                            context: context,
                            builder: (context) =>
                                ChangeInfoDialog(markerId: widget.markerId));
                      },
                      icon: Icon(Icons.edit_location_alt_outlined),
                      color: Color.fromARGB(255, 115, 99, 183),
                      iconSize: 30,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);

                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text(
                                    "Are you sure you want to delete this tag",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 115, 99, 183),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
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
                                        Navigator.of(context).pop(true);
                                        widget.deleteMarker(widget.markerId);
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                ));
                      },
                      icon: Icon(Icons.remove_circle_outline_rounded),
                      color: Color.fromARGB(255, 115, 99, 183),
                      iconSize: 30,
                    ),
                  ],
                )),
          ],
        ),
      ],
    )));
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