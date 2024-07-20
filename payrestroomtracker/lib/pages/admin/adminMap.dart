import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:flutter_button/pages/dialog/admin_tag_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_button/pages/dialog/admin_add_info.dart';

class AdminMap extends StatefulWidget {
  const AdminMap({Key? key, required this.username, required this.report}) : super(key: key);
  final String username;
  final String report;

  @override
  State<AdminMap> createState() => AdminMapState();
}

class AdminMapState extends State<AdminMap> {
  static const LatLng _pGooglePlex =
      LatLng(14.303142147986497, 121.07613374318477);
  late GoogleMapController mapController;
  LatLng? _currentP;
  String? _currentAddress;
  Set<Marker> _markers = {};
  Location _locationController = Location();
  BitmapDescriptor? _customMarkerIcon;
  BitmapDescriptor? _personMarkerIcon;
  late String _mapStyleString;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
    getLocationUpdates();
    _loadCustomMarkerIcon();
    loadMarkersFromPrefs();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    _markers = await loadMarkersFromPrefs();
    setState(() {}); // Update UI after loading markers
  }

  Future<void> _loadCustomMarkerIcon() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/paid_CR_Tag.png',
    );
    _personMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/person_Tag.png',
    );
  }

  Future<Set<Marker>> loadMarkersFromPrefs() async {
    final firestoreMarkers =
        await FirebaseFirestore.instance.collection('Tags').get();
    Set<Marker> loadedMarkers = firestoreMarkers.docs.map((doc) {
      final data = doc.data();
      final id = data['TagId'] as String?;
      final position = data['position'] as GeoPoint?;
      LatLng latLng;

      if (position != null) {
        latLng = LatLng(position.latitude, position.longitude);
      } else {
        latLng = LatLng(0.0, 0.0); // Default value if position is null
      }

      return Marker(
        markerId: MarkerId(id ?? 'unknown'),
        position: latLng,
        icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AdminTagInformation(
              markerId: MarkerId(id ?? 'unknown'),
              deleteMarker: _deleteMarker,
              destination: latLng,
            ),
          );
        },
      );
    }).toSet();

    return loadedMarkers;
  }

  Future<void> _saveMarkersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final markerData = _markers.map((marker) {
      return '${marker.markerId.value},${marker.position.latitude},${marker.position.longitude}';
    }).toList();
    await prefs.setStringList('markers', markerData);
  }

  Future<void> _deleteMarker(MarkerId markerId) async {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
    });
    await _saveMarkersToPrefs();

    // Remove the marker from Firestore
    await FirebaseFirestore.instance
        .collection('Tags')
        .doc(markerId.value)
        .delete();
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

  @override
  Widget build(BuildContext context) {
    final markerId_ =
        MarkerId('marker_${DateTime.now().millisecondsSinceEpoch}');

    if (_currentP != null) {
      _markers.add(
        Marker(
            markerId: const MarkerId('User Location'),
            position: _currentP!,
            icon: _personMarkerIcon ?? BitmapDescriptor.defaultMarker,
            onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text(
                        "Are you sure you want to add a tag",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 115, 99, 183),
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
                            showDialog(
                              context: context,
                              builder: (context) => AddInfoDialog(
                                markerId: markerId_,
                              ),
                            ).then((confirmed) {
                              print(confirmed);
                              if (confirmed == true) {
                                _addMarker(_currentP!, markerId_);
                              }
                            });
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    ))),
      );
    }

    return WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Admin Map',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 97, 84, 158),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            GoogleMap(
              markers: _markers,
              polylines: _polylines,
              onTap: (LatLng latLng) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text(
                            "Are you sure you want to add a tag",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color.fromARGB(255, 115, 99, 183),
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
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AddInfoDialog(markerId: markerId_),
                                ).then((confirmed) {
                                  print(confirmed);
                                  if (confirmed == true) {
                                    _addMarker(latLng, markerId_);
                                  }
                                });
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        ));
              },
              initialCameraPosition: CameraPosition(
                target: _pGooglePlex,
                zoom: 13,
              ),
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                mapController.setMapStyle(_mapStyleString);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackButtonPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Map"),
        content: const Text("Do you want to exit this page?"),
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
                _createRoute(AdminPage(username: widget.username, report: widget.report,)),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
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
      }
    });
  }

  void _addMarker(LatLng latLng, MarkerId markerId_) {
    Marker newMarker = Marker(
      markerId: markerId_,
      position: latLng,
      icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AdminTagInformation(
            markerId: markerId_,
            deleteMarker: _deleteMarker,
            destination: latLng,
          ),
        );
      },
    );
    setState(() {
      _markers.add(newMarker);
    });

    _saveMarkersToPrefs();
    // Add the marker to Firestore as well
    FirebaseFirestore.instance.collection('Tags').doc(markerId_.value).set({
      'TagId': markerId_.value,
      'position': GeoPoint(latLng.latitude, latLng.longitude),
    });
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
