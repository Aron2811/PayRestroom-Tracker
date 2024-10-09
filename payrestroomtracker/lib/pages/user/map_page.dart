import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/bottomsheet/map_paidrestroom_info.dart';
import 'package:flutter_button/pages/dialog/apprate_dialog.dart';
import 'package:flutter_button/pages/user/in_app_tutorial.dart';
import 'package:flutter_button/pages/user/user_loggedin_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_button/pages/dialog/user_profile_dialog.dart';
import 'package:flutter_button/pages/bottomsheet/recommendation_list.dart';
import 'package:flutter_button/algo/Astar.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'dart:math';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MarkerData {
  final Marker marker;
  final double distance;
  final double rating;

  MarkerData(this.marker, this.distance, this.rating);
}

class MapPageState extends State<MapPage> {
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
  BitmapDescriptor? _newMarkerIcon;
  BitmapDescriptor? dynamicIcon;
  Set<MarkerId> _clickedMarkerIds = Set<MarkerId>();
  late String _mapStyleString;
  Set<Polyline> _polylines = {};
  LatLng? end;
  String? _displayPaidRestroomName;
  String? estimatedTime;
  String? distanceInMiles;

  bool hasBeenListed = false;
  bool isVisible = false;
  bool isUserLocationVisible = false;
  bool _isLoading = false;
  bool isCommute = false;
  bool isByFoot = false;
  bool isCar = false;
  bool isDisplayed = true;

  final tagKey = GlobalKey();
  final findKey = GlobalKey();
  final profileKey = GlobalKey();
  final apptourKey = GlobalKey();
  final directionKey = GlobalKey();
  final reportKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  bool isMainTutorialDisplayed =
      true; // Default state for the main Positioned widget
  final String mainTutorialKey = "main_tutorial_completed";
  String imagePath = 'assets/paid_CR_Tag.png';

  int _backPressCount = 0;

  // Initializes and configures the main tutorial with TutorialCoachMark
  void initMainTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: components(
          findKey: findKey,
          tagKey: tagKey,
          profileKey: profileKey,
          apptourKey: apptourKey,
          directionKey: directionKey,
          reportKey: reportKey),
      colorShadow: Color.fromARGB(230, 98, 84, 158),
      paddingFocus: 10,
      hideSkip: false,
      onSkip: () {
        setState(() {
          isMainTutorialDisplayed = false;
        });
        return true;
      },
      opacityShadow: 0.8,
      onClickTarget: (tagKey) {
        setState(() {
          isMainTutorialDisplayed = false;
        });
      },
      onFinish: () async {
        print("Main Tutorial Completed");
        await _saveTutorialState(mainTutorialKey, true);
      },
    );
  }

  // Displays the main tutorial with a delay
  void _showMainTutorial() {
    Future.delayed(const Duration(seconds: 2), () {
      tutorialCoachMark.show(context: context);
    });
  }

  // Loads the tutorial state and shows the main tutorial if it hasn't been completed
  Future<void> _loadTutorialState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? mainTutorialCompleted = prefs.getBool(mainTutorialKey);

    if (mainTutorialCompleted == null || !mainTutorialCompleted) {
      initMainTutorial();
      _showMainTutorial();
    } else {
      setState(() {
    
      });
    }
  }

  // Saves the state of the tutorial completion
  Future<void> _saveTutorialState(String key, bool isCompleted) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, isCompleted);
  }

  Future<void> _resetTutorialStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(mainTutorialKey); // Clear the main tutorial state

    // Reset component 1 tutorial state using the instance
    // await widget.paidRestroomInfo.resetTutorialStates(); // Call reset method from PaidRestroomInfo

    setState(() {
      isMainTutorialDisplayed = true; // Reset main tutorial component state
    });
    _loadTutorialState(); // Re-initialize and show the main tutorial
  }

  // Returns the appropriate background image based on the transportation mode
  AssetImage getBackgroundImage() {
    print(isCommute);
    if (isCommute) {
      return AssetImage('assets/jeep.png');
    } else if (isByFoot) {
      return AssetImage('assets/person.png');
    } else if (isCar) {
      return AssetImage('assets/car.png');
    } else {
      return AssetImage('assets/jeep.jpg');
    }
  }

  //apprate related
  Future<bool> _hasUserRated(String username) async {
    // Check if the user has already rated the app based on the username
    QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
        .collection('apprating')
        .where('username', isEqualTo: username)
        .get();

    return ratingSnapshot.docs.isNotEmpty;
  }

  Future<void> _markUserAsRated(String username) async {
    // Update the user's rating status in Firestore
    await FirebaseFirestore.instance.collection('apprating').doc(username).set({
      'hasRated': true,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  //handle both method because i cant put 2 methods in onWillPop
  Future<bool> _handleBackButton() async {
    _backPressCount++;

    if (_backPressCount == 5) {
      _backPressCount = 0; // Reset counter after checking

      // Fetch the username in real-time
      String username = await _getCurrentUsername();

      if (username.isEmpty) {
        // Handle the case where username is not available
        return false; // Prevent the actual back navigation
      }

      // Check if the user has already rated based on the fetched username
      bool hasRated = await _hasUserRated(username);

      if (!hasRated) {
        // If user hasn't rated, show the rating dialog
        await _showRateDialog(); // Ensure dialog interaction is awaited
        return false; // Prevent the actual back navigation
      }
    }

    // If the back button press count is less than 5, continue with normal back behavior
    return await _onBackButtonPressed(); // Allow or prevent back navigation based on user choice
  }

  Future<void> _showRateDialog() async {
    // Fetch the username in real-time
    String username = await _getCurrentUsername();

    // Check if the user has already rated
    bool hasRated = await _hasUserRated(username);

    if (!hasRated) {
      // Show the rating dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AppRateDialog(displayName: username);
        },
      );

      // Mark user as rated after they interact with the dialog
      await _markUserAsRated(username);
    }
  }

  // Fetches the current user's display name from Firestore
  Future<String> _getCurrentUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.get('displayName') as String? ?? '';
    }
    return '';
  }

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
    // TODO: implement initState
    super.initState();
    // _checkAndShowTutorial();

    isMainTutorialDisplayed = false;
    _loadTutorialState();
    // initAddInAppTour();
    // _showAppTour();

    getLocationUpdates();
    _loadCustomMarkerIcon();
    _loadMarkers();
  }

  void _onMarkerTap(MarkerId markerId) {
    setState(() {
      _clickedMarkerIds.add(markerId); // Track the clicked marker

      _markers = _markers.map((marker) {
        if (marker.markerId == markerId) {
          // Change the icon of the clicked marker
          return marker.copyWith(
            iconParam: _newMarkerIcon ?? BitmapDescriptor.defaultMarker,
          );
        }
        return marker;
      }).toSet();
    });

    final clickedMarker = _markers.firstWhere((m) => m.markerId == markerId);
    _showPayToiletInformation(clickedMarker.position);
  }

  // Updates the estimated time based on the selected mode of transportation
  void _updateDuration(String mode, String duration) {
    setState(() {
      if (mode == 'private') {
        estimatedTime = duration;
      } else if (mode == 'commute') {
        estimatedTime = duration;
      } else if (mode == 'byFoot') {
        estimatedTime = duration;
      }
    });
  }

  // Loads markers from preferences and updates the UI
  Future<void> _loadMarkers() async {
    _markers = await adminMap.loadMarkersFromPrefs().then((markers) {
      return markers.map((marker) {
        return Marker(
          markerId: marker.markerId,
          position: marker.position,
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            _onMarkerTap(marker.markerId);
          },
        );
      }).toSet();
    });

    setState(() {}); // Update UI after loading markers
  }

  // Loads custom marker icons from asset images
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
    _newMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/tag2.png',
    );
  }

  // Updates the current address based on the current location
  Future<void> updateCurrentAddress() async {
    if (_currentP != null) {
      String? fullAddress =
          await getAddressFromLatLng(_currentP!.latitude, _currentP!.longitude);
      if (fullAddress != null) {
        _currentAddress = formatAddress(fullAddress);
        setState(() {});
      } else {
        _currentAddress = null;
      }
    } else {
      _currentAddress = null;
    }
  }

  String? formatAddress(String fullAddress) {
    // Split the address by comma and trim whitespace
    List<String> addressParts =
        fullAddress.split(',').map((part) => part.trim()).toList();

    // Assign components based on the known order
    String municipality = addressParts.length > 2 ? addressParts[1] : '';
    String province = addressParts.length > 3 ? addressParts[2] : '';
    String country = addressParts.length > 3 ? addressParts[3] : '';

    return "$municipality, $province, $country";
  }

// Fetches ratings for a list of markers from Firestore
 Future<Map<Marker, double>> _fetchRatings(List<Marker> markers) async {
  final Map<GeoPoint, Marker> geoPointToMarkerMap = {};
  final List<GeoPoint> geoPoints = [];

  // Build mapping of GeoPoints to markers
  for (final marker in markers) {
    final geoPoint = GeoPoint(marker.position.latitude, marker.position.longitude);
    geoPointToMarkerMap[geoPoint] = marker;
    geoPoints.add(geoPoint);
  }

  final Map<Marker, double> markerRatings = {};

  // Fetch ratings in batches
  const int batchSize = 30;
  for (int i = 0; i < geoPoints.length; i += batchSize) {
    final batchGeoPoints = geoPoints.skip(i).take(batchSize).toList();
    
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position', whereIn: batchGeoPoints)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final geoPoint = GeoPoint(
        data['position'].latitude,
        data['position'].longitude,
      );
      final marker = geoPointToMarkerMap[geoPoint];
      if (marker != null) {
        markerRatings[marker] = data['averageRating'] as double? ?? 0.0;
      }
    }
  }

  // Assign default rating for markers without data
  for (final marker in markers) {
    if (!markerRatings.containsKey(marker)) {
      markerRatings[marker] = 0.0;
    }
  }

  return markerRatings;
}

Future<List<Marker>> getNearestMarkers(LatLng userPosition, int count, BitmapDescriptor customMarkerIcon) async {
  final List<Marker> markers = _markers
      .where((marker) => marker.icon == customMarkerIcon)
      .toList();

  // Fetch ratings for all markers
  final markerRatings = await _fetchRatings(markers);

  // Calculate distances and sort markers
  markers.sort((a, b) {
    final distanceA = _calculateDistance(userPosition, a.position);
    final distanceB = _calculateDistance(userPosition, b.position);
    return distanceA.compareTo(distanceB);
  });

  // Take top 'count' markers by distance
  final nearestMarkers = markers.take(count).toList();

  // Sort the nearest markers by rating (highest first)
  nearestMarkers.sort((a, b) => (markerRatings[b] ?? 0.0).compareTo(markerRatings[a] ?? 0.0));

  return nearestMarkers;
}

// Calculates the Euclidean distance between two LatLng points
double _calculateDistance(LatLng start, LatLng end) {
  final latDiff = end.latitude - start.latitude;
  final lngDiff = end.longitude - start.longitude;
  return sqrt(latDiff * latDiff + lngDiff * lngDiff);
}

  // Displays a bottom sheet with a list of the nearest pay toilets
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
        return DraggableScrollableSheet(
          initialChildSize: 0.4, // Initial height of the sheet
          minChildSize: 0.2, // Minimum height of the sheet
          maxChildSize: 0.9, // Maximum height of the sheet
          builder: (context, scrollController) {
            return FutureBuilder<List<Marker>>(
              future: getNearestMarkers(userPosition, 10,
                  _customMarkerIcon ?? BitmapDescriptor.defaultMarker),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No restrooms found.'));
                }

                final nearestMarkers = snapshot.data!;

                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 148, 139, 192),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ListView(
                    controller: scrollController,
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
      },
    );
  }

  // Displays a bottom sheet with information about the selected pay toilet
  void _showPayToiletInformation(LatLng destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => MapPaidRestroomInfo(
        drawRouteToDestination: _drawRouteToDestination,
        destination: destination,
        toggleVisibility: toggleVisibility,
      ),
    ).whenComplete(() {
      setState(() {
        // Restore the original icons for clicked markers
        _markers = _markers.map((marker) {
          if (_clickedMarkerIds.contains(marker.markerId)) {
            // Restore the original icon
            return marker.copyWith(
              iconParam: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
            );
          }
          return marker;
        }).toSet();
        _clickedMarkerIds.clear(); // Clear the clicked marker ids
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Adds a marker for the user's current location if it's available
    if (_currentP != null) {
      print(_currentP);
      _markers.add(
        Marker(
          markerId: const MarkerId('User Location'),
          position: _currentP!,
          icon: dynamicIcon ??
              BitmapDescriptor.defaultMarkerWithHue(255.0),
        ),
      );
    }

    return WillPopScope(
        onWillPop: _handleBackButton,
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
          Visibility(
            visible: isMainTutorialDisplayed,
            child: Positioned(
                top: 300,
                left: 85,
                child: Container(
                  width: 50,
                  height: 50,
                  key: tagKey,
                  child: Image.asset(imagePath),
                )),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 30,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton.filled(
                  key: apptourKey,
                  iconSize: 15,
                  onPressed: () {
                    _resetTutorialStates(); // Call this to reset and refresh the tutorial
                  },
                  icon: Icon(
                    Icons.question_mark_rounded,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(
                      color: Color.fromARGB(
                          255, 149, 134, 225), // Set the border color
                      width: 3.0, // Set the border width
                    ),
                  ),
                  child: CircleAvatar(
                    key: profileKey,
                    radius: 22,
                    backgroundImage: NetworkImage(
                        FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => UserProfileDialog());
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60, left: 30, right: 10),
            child: FractionallySizedBox(
              widthFactor: 0.94, // Adjust the factor for different widths

              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 149, 134, 225),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color.fromARGB(
                        111, 255, 255, 255), // Set the border color here
                    width: 2, // Adjust the border width as needed
                  ), // Adjust the radius value as needed
                ),
                height: 30,
                width: 300,
                margin: const EdgeInsets.only(top: 30, left: 0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _currentAddress ?? 'Fetching user location...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 95, left: 10, right: 10),
              child: Visibility(
                  visible: isVisible,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Column(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10,
                        left: 0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 0.94,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 149, 134, 225),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color.fromARGB(111, 255, 255,
                                  255), // Set the border color here
                              width: 2, // Adjust the border width as needed
                            ), // Adjust the radius value as needed
                          ),
                          height: 30,
                          width: 300,
                          margin: const EdgeInsets.only(top: 30, left: 20),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              _displayPaidRestroomName ??
                                  'Fetching destination...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]))),
          Padding(
              padding: EdgeInsets.only(bottom: 80, left: 20),
              child: Visibility(
                visible: isVisible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Container(
                                  color: Color.fromARGB(255, 172, 161, 228),
                                  height: 55,
                                  width: 153,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                      _isLoading = false;
                                                      _drawRouteToDestination(
                                                          end!, 'private');

                                                    },
                                                  ),
                                                  SizedBox(height: 5),
                                                ],
                                              )),
                                          Column(children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(right: 7),
                                                child: GestureDetector(
                                                  child: Container(
                                                    height: 35,
                                                    width: 35,
                                                    child: Image.asset(
                                                        'assets/jeep.png'),
                                                  ),
                                                  onTap: () {
                                                    _isLoading = false;
                                                    _drawRouteToDestination(
                                                        end!, 'commute');
                                                  },
                                                )),
                                            SizedBox(height: 5),
                                          ]),
                                          Column(children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: GestureDetector(
                                                  child: Container(
                                                      height: 35,
                                                      width: 35,
                                                      child: Image.asset(
                                                          'assets/person.png')),
                                                  onTap: () {
                                                    _isLoading = false;

                                                    _drawRouteToDestination(
                                                        end!, 'byFoot');
                                                  },
                                                )),
                                            SizedBox(height: 5),
                                          ])
                                        ],
                                      )))),
                          SizedBox(width: 5),
                          Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      bottomLeft: Radius.circular(50),
                                      topRight: Radius.circular(25),
                                      bottomRight: Radius.circular(25)),
                                  child: Container(
                                      color: Colors.white,
                                      height: 45,
                                      width: 120,
                                      child: Row(children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundImage: getBackgroundImage(),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Align(
                                            alignment: Alignment.center,
                                            child: Column(children: [
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                '${estimatedTime ?? '15 min'}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 97, 84, 158),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                distanceInMiles ?? '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 97, 84, 158),
                                                ),
                                              )
                                            ]))
                                      ])))),
                          SizedBox(width: 5),
                          FloatingActionButton.small(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(Icons.close_rounded),
                            onPressed: () {
                              _hidePath();
                              _polylines.clear();
                              dynamicIcon = null;

                            },
                          ),
                        ])),
              )),
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
                    key: findKey,
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

  // makes the isVisible into true
  void toggleVisibility() {
    setState(() {
      isVisible = true;
    });
  }

  // Hides the path
  void _hidePath() {
    setState(() {
      isVisible = false;
    });
  }

  // Ensures the camera is centered on the user's current location
  Future<void> _ensureUserLocationVisible() async {
    if (_currentP != null) {
      //Center the camera on the user's location
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentP!, //center on the user's current position
            zoom: await mapController
                .getZoomLevel(), //Maintain the current zoom level
          ),
        ),
      );
    }
  }

  // Monitors location updates and updates the map and address accordingly
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

  // Retrieves a formatted address from latitude and longitude
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    const apiKey = 'AIzaSyC1Ooxwod2ykAO6R99jhnXoYA3ubvkrB9M';
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

  // Shows a confirmation dialog when the back button is pressed, allowing the user to exit the app or stay
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
                    Navigator.push(
                        context,
                        _createRoute(UserLoggedInPage(
                          
                        )));
                  },
                  child: const Text("Yes"),
                ),
              ],
            ));
  }

  // Fetches the name of a paid restroom from Firestore based on its location
  Future<void> _fetchPaidRestroomName(LatLng destination) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tags')
        .where('position',
            isEqualTo: GeoPoint(destination.latitude, destination.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final fetchedName = data['Name'] as String? ?? "Paid Restroom Name";

      setState(() {
        _displayPaidRestroomName = fetchedName;
      });
    }
  }

  // Draws the route to the destination based on the selected transportation option
  Future<void> _drawRouteToDestination(
      LatLng destination, String option) async {
    setState(() {
      if (option == 'commute') {
        isCommute = true;
        isByFoot = false;
        isCar = false;
        dynamicIcon = _jeepMarkerIcon;
      } else if (option == 'byFoot') {
        isCommute = false;
        isByFoot = true;
        isCar = false;
        dynamicIcon = _personMarkerIcon;
      } else if (option == 'private') {
        isCommute = false;
        isByFoot = false;
        isCar = true;
        dynamicIcon = _carMarkerIcon;
      }
    });

    end = destination;

    if (_currentP == null) {
      print('User location not available.');
      return;
    }

    _fetchPaidRestroomName(destination);

    AStar aStar =
        AStar('AIzaSyC1Ooxwod2ykAO6R99jhnXoYA3ubvkrB9M', _updateDuration);

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
            content: Text('The paid restroom is in the EXPRESSWAY')
            ,
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
            duration: Duration(seconds: 3), // Adjust as needed
          ),
        );
      }

      // Update the marker with the selected transportation option icon
      _markers.removeWhere(
          (marker) => marker.markerId == MarkerId('User Location'));
      distanceInMiles = aStar.getDistanceInMiles(_currentP!, destination);
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

  // Calculates the angle in radians between two LatLng points
  double _calculateAngle(LatLng start, LatLng end) {
    double deltaX = end.longitude - start.longitude;
    double deltaY = end.latitude - start.latitude;
    return atan2(deltaY, deltaX);
  }

  // Adjusts the map view to fit the route coordinates
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

// Creates a custom route with a slide transition animation
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