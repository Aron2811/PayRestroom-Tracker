import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/intro_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_button/pages/dialog/user_profile_dialog.dart';
import 'package:flutter_button/pages/bottomsheet/recommendation_list.dart';
import 'package:flutter_button/pages/bottomsheet/paidrestroom_info.dart';
import 'package:flutter_button/pages/bottomsheet/draggablesheet.dart';
import 'package:flutter_button/algo/Astar.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _pGooglePlex =
      LatLng(14.303142147986497, 121.07613374318477);
  late GoogleMapController mapController;
  Location _locationController = new Location();
  LatLng? _currentP = null;
  String? _currentAddress;
  final AdminMapState adminMap = AdminMapState();
  Set<Marker> _markers = {};
  BitmapDescriptor? _customMarkerIcon;
  BitmapDescriptor? _jeepMarkerIcon;
  BitmapDescriptor? _personMarkerIcon;
  BitmapDescriptor? _carMarkerIcon;
  final Completer<GoogleMapController> _controller = Completer();
  late String _mapStyleString;
  Set<Polyline> _polylines = {};
  LatLng? end;

  bool hasBeenListed = false;
  bool isVisible = false;
  bool isUserLocationVisible = false;

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
    _loadCustomMarkerIcon();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    _markers = await adminMap.loadMarkersFromPrefs().then((markers) {
      return markers.map((marker) {
        return Marker(
          markerId: marker.markerId,
          position: marker.position,
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            _showPayToiletInformation(marker.position);
          },
        );
      }).toSet();
    });

    setState(() {}); // Update UI after loading markers
  }

  Future<void> _loadCustomMarkerIcon() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/paid_CR_Tag.png',
    );
    _jeepMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/jeep_Tag.png',
    );
    _personMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/person_Tag.png',
    );
    _carMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/car_Tag.png',
    );
  }

  Future<void> updateCurrentAddress() async {
    if (_currentP != null) {
      _currentAddress =
          await getAddressFromLatLng(_currentP!.latitude, _currentP!.longitude);
      setState(() {});
    } else {
      _currentAddress = null;
    }
  }

 Future<Map<Marker, double>> _fetchRatings(List<Marker> markers) async {
    Map<Marker, double> markerRatings = {};

    for (Marker marker in markers) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Tags')
          .where('position',
              isEqualTo: GeoPoint(marker.position.latitude, marker.position.longitude))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final fetchedRating = data?['rating'] as double? ?? 0.0;
        markerRatings[marker] = fetchedRating;
      } else {
        markerRatings[marker] = 0.0;
      }
    }

    return markerRatings;
  }

  Future<List<Marker>> getNearestMarkers(LatLng userPosition, int count, BitmapDescriptor customMarkerIcon) async {
    List<Marker> markers = _markers.where((marker) => marker.icon == customMarkerIcon).toList();

    // Fetch ratings for all markers
    Map<Marker, double> markerRatings = await _fetchRatings(markers);

    // Sort by distance first
    markers.sort((a, b) {
      final distanceA = _calculateDistance(userPosition, a.position);
      final distanceB = _calculateDistance(userPosition, b.position);
      return distanceA.compareTo(distanceB);
    });

    // Take the top 'count' markers by distance
    markers = markers.take(count).toList();

    // Sort by rating (highest rating first)
    markers.sort((a, b) {
      final ratingA = markerRatings[a]!;
      final ratingB = markerRatings[b]!;
      return ratingB.compareTo(ratingA);
    });

    return markers;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    var distance = sqrt(pow(end.latitude - start.latitude, 2) +
        pow(end.longitude - start.longitude, 2));
    return distance;
  }

  void _showFindNearestPayToilet() async {
    LatLng userPosition = _currentP!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<Marker>>(
          future: getNearestMarkers(userPosition, 10, _customMarkerIcon ?? BitmapDescriptor.defaultMarker),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No restrooms found.'));
            }

            final nearestMarkers = snapshot.data!;

            return MyDraggableSheet(
              child: Column(
                children: nearestMarkers.map((marker) {
                  return PaidRestroomRecommendationList(
                    drawRouteToDestination: _drawRouteToDestination,
                    destination: marker.position,
                    toggleVisibility: toggleVisibility,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }


  void _showPayToiletInformation(LatLng destination) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        backgroundColor: Colors.transparent,
        builder: (context) => PaidRestroomInfo(
              drawRouteToDestination: _drawRouteToDestination,
              destination: destination,
              toggleVisibility: toggleVisibility,
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentP != null) {
      print(_currentP);
      _markers.add(
        Marker(
          markerId: const MarkerId('User Location'),
          position: _currentP!,
          icon: _jeepMarkerIcon ??
              BitmapDescriptor.defaultMarker, // Set the custom icon here
        ),
      );
    }

    return WillPopScope(
        onWillPop: _onBackButtonPressed,
        child: Scaffold(
            body: Stack(children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _pGooglePlex,
              zoom: 13,
            ),
            zoomControlsEnabled: false, // Disable zoom in and zoom out buttons
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              mapController.setMapStyle(_mapStyleString);
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60.0),
              child: SizedBox.shrink(), // Placeholder for an empty child
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 50, right: 20), // Adjust the value to your needs
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                    side: const BorderSide(
                      color: Color.fromARGB(
                          255, 149, 134, 225), // Set the border color
                      width: 3.0, // Set the border width
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                        FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => UserProfileDialog());
                  },
                ),
              ),
            ),
          ]),
          Padding(
              padding: EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Visibility(
                  visible: isVisible,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                          color: Color.fromARGB(255, 172, 161, 228),
                          height: 70,
                          width: 153,
                          child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                        right: 10,
                                        left: 15,
                                      ),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            child: Container(
                                                height: 35,
                                                width: 35,
                                                child: Image.asset(
                                                    'assets/car.png')),
                                            onTap: () {
                                              _drawRouteToDestination(
                                                  end!, 'private');
                                              _markers.add(
                                                Marker(
                                                  markerId: const MarkerId(
                                                      'User Location'),
                                                  position: _currentP!,
                                                  icon: _carMarkerIcon ??
                                                      BitmapDescriptor
                                                          .defaultMarker, // Set the custom icon here
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '15m',
                                            // textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )),
                                  Column(children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 7),
                                        child: GestureDetector(
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            child:
                                                Image.asset('assets/jeep.png'),
                                          ),
                                          onTap: () {
                                            _drawRouteToDestination(
                                                end!, 'commute');
                                            _markers.add(
                                              Marker(
                                                markerId: const MarkerId(
                                                    'User Location'),
                                                position: _currentP!,
                                                icon: _jeepMarkerIcon ??
                                                    BitmapDescriptor
                                                        .defaultMarker, // Set the custom icon here
                                              ),
                                            );
                                          },
                                        )),
                                    SizedBox(height: 5),
                                    Text(
                                      '15m',
                                      // textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ]),
                                  Column(children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: GestureDetector(
                                          child: Container(
                                              height: 35,
                                              width: 35,
                                              child: Image.asset(
                                                  'assets/person.png')),
                                          onTap: () {
                                            _drawRouteToDestination(
                                                end!, 'byFoot');
                                            _markers.add(
                                              Marker(
                                                markerId: const MarkerId(
                                                    'User Location'),
                                                position: _currentP!,
                                                icon: _personMarkerIcon ??
                                                    BitmapDescriptor
                                                        .defaultMarker, // Set the custom icon here
                                              ),
                                            );
                                          },
                                        )),
                                    SizedBox(height: 5),
                                    Text(
                                      '15m',
                                      // textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ])
                                ],
                              )))))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 60.0),
                child: SizedBox.shrink(), // Placeholder for an empty child
              ),
              Container(
                margin: const EdgeInsets.only(
                    bottom: 20.0), // Adjust the value to your needs
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      enableFeedback: false,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(115, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: Color.fromARGB(
                              255, 149, 134, 225), // Set the border color
                          width: 4.0, // Set the border width
                        ),
                      ),
                      foregroundColor: Color.fromARGB(255, 97, 84, 158),
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    label: const Text(
                      "FIND NEAREST PAY TOILET",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Color.fromARGB(255, 97, 84, 158),
                    ),
                    onPressed: () {
                      _showFindNearestPayToilet();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          )
        ])));
  }

  void toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  Future<void> _ensureUserLocationVisible() async {
    if (_currentP != null && mapController != null) {
      // Get the current visible region
      LatLngBounds bounds = await mapController.getVisibleRegion();

      // Check if the user's location is within the bounds
      bool isUserLocationVisible = bounds.contains(_currentP!);

      if (!isUserLocationVisible) {
        // If the user's location is not visible, adjust the zoom level
        double zoomLevel = await mapController.getZoomLevel();
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _pGooglePlex,
              zoom: zoomLevel - 1, // Adjust zoom level as needed
            ),
          ),
        );
      }
    }
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        print('Location services disabled.');
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('Location permission denied.');
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        updateCurrentAddress();

        if (!isUserLocationVisible) {
          _ensureUserLocationVisible();
          isUserLocationVisible = true;
        }
      }
    });
  }

  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    const apiKey = 'AIzaSyATlFmBj-83JvPniLILsfpyawS8NlKIEDc';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final results = decoded['results'] as List<dynamic>;

        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'] as String?;
          return formattedAddress;
        } else {
          print('No results found for the provided coordinates.');
          return null;
        }
      } else {
        print('Failed to load address: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  Future<bool> _onBackButtonPressed() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Exit App"),
              content: const Text("Do you want to exit the app?"),
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
                    Navigator.push(context, _createRoute(IntroPage()));
                  },
                  child: const Text("Yes"),
                ),
              ],
            ));
  }

  Future<void> _drawRouteToDestination(
      LatLng destination, String option) async {
    end = destination;

    if (_currentP == null) {
      print('User location not available.');
      return;
    }

    AStar aStar = AStar('AIzaSyATlFmBj-83JvPniLILsfpyawS8NlKIEDc');

    // Calculate the path asynchronously
    List<LatLng> path =
        await aStar.findAndDrawPath(_currentP!, destination, option);

    // Check if the path is straight
    bool isStraightPath = _isStraightPath(path);

    // Update UI based on the path calculation result
    setState(() {
      _polylines.clear(); // Clear previous polylines

      if (path.isNotEmpty && !isStraightPath) {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          color: Color.fromARGB(255, 115, 99, 183),
          width: 5,
          points: path,
        ));
        _fitRouteOnMap(path); // Fit map bounds to the route
      } else {
        print('No valid or straight path found.');
        // Show a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The paid restroom is in the EXPRESSWAY'),
            duration: Duration(seconds: 3), // Adjust as needed
          ),
        );
      }
    });
  }

  bool _isStraightPath(List<LatLng> path) {
    if (path.length < 2)
      return true; // Single point or empty path is considered straight

    LatLng firstPoint = path.first;
    LatLng lastPoint = path.last;

    // Check if all points lie on a straight line (using a simple tolerance for angle)
    double tolerance = 0.001; // Adjust as needed
    for (int i = 1; i < path.length - 1; i++) {
      LatLng currentPoint = path[i];

      // Calculate the angles between the segments
      double angle1 = _calculateAngle(firstPoint, currentPoint);
      double angle2 = _calculateAngle(currentPoint, lastPoint);

      // Check if the angles are within tolerance of each other (considered straight)
      if ((angle2 - angle1).abs() > tolerance) {
        return false;
      }
    }

    return true;
  }

  double _calculateAngle(LatLng start, LatLng end) {
    double deltaX = end.longitude - start.longitude;
    double deltaY = end.latitude - start.latitude;
    return atan2(deltaY, deltaX);
  }

  void _fitRouteOnMap(List<LatLng> routeCoords) {
    LatLngBounds? bounds;
    if (routeCoords.isNotEmpty) {
      double minLat =
          routeCoords.map((e) => e.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat =
          routeCoords.map((e) => e.latitude).reduce((a, b) => a > b ? a : b);
      double minLng =
          routeCoords.map((e) => e.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng =
          routeCoords.map((e) => e.longitude).reduce((a, b) => a > b ? a : b);

      bounds = LatLngBounds(
        southwest: LatLng(minLat.toDouble(), minLng.toDouble()),
        northeast: LatLng(maxLat.toDouble(), maxLng.toDouble()),
      );

      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
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

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}