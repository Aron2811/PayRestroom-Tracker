import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:flutter_button/pages/dialog/admin_tag_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_button/pages/dialog/admin_add_info.dart';
import 'package:badges/badges.dart';

class AdminMap extends StatefulWidget {
  const AdminMap({Key? key, required this.username, required this.report})
      : super(key: key);
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
  Set<Marker> _markers = {};
  Location _locationController = Location();
  BitmapDescriptor? _customMarkerIcon;
  BitmapDescriptor? _personMarkerIcon;

  late String _mapStyleString;
  Set<Polyline> _polylines = {};

  bool isUserLocationVisible = false;

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

  // Loads custom marker icons for the map from asset images.
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

  Future<void> _showSuggestedRestrooms(BuildContext context) async {
  final restrooms = await FirebaseFirestore.instance
      .collection('suggested_restrooms') // Replace with your collection name
      .get();

  final restroomList = restrooms.docs.map((doc) => doc).toList();

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suggested Restrooms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: restroomList.length,
                itemBuilder: (context, index) {
                  final doc = restroomList[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['name'] ?? 'Unnamed Restroom'),
                    subtitle: Text(data['location'] ?? 'No description provided.'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
  showRestroomDetails(context, doc.id, data); // Show details dialog
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

 Future<void> showRestroomDetails(
    BuildContext context, String docId, Map<String, dynamic> data) {
  return showDialog(
    context: context,
    builder: (context) {
      // Check if 'images' is a list and display them accordingly
      var images = data['ImageUrls'];
      List<Widget> imageWidgets = [];

      // If the images are in an array
      if (images is List) {
        for (var imageUrl in images) {
          imageWidgets.add(
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
          imageWidgets.add(const SizedBox(height: 10));
        }
      } else if (images != null) {
        // If only one image exists
        imageWidgets.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              images,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        );
        imageWidgets.add(const SizedBox(height: 10));
      }

      return AlertDialog(
        title: Text(data['name'] ?? 'Unnamed Restroom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display images
            if (imageWidgets.isNotEmpty) ...imageWidgets,
            Text('Cost: ${data['cost'] ?? 'N/A'}'),
            const SizedBox(height: 5),
            Text('Location: ${data['location'] ?? 'No description provided.'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              acceptRestroom(context, data);
            
              Navigator.pop(context);
            },
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () {
              rejectRestroom(docId);
              Navigator.pop(context);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Future<void> rejectRestroom(String docId) async {
  await FirebaseFirestore.instance
      .collection('suggested_restrooms')
      .doc(docId)
      .delete();
}

Future<void> acceptRestroom(BuildContext context, Map<String, dynamic> data) async {
  final markerId = MarkerId('marker_${DateTime.now().millisecondsSinceEpoch}');

  try {
    DocumentReference tagRef = FirebaseFirestore.instance
        .collection('Tags')
        .doc(markerId.value);

    DocumentSnapshot tagSnapshot = await tagRef.get();
    Map<String, dynamic>? tagData = tagSnapshot.data() as Map<String, dynamic>?;

    // Fetch existing images from the Tags collection, or initialize an empty list
    List<dynamic> existingImageUrls = tagData?['ImageUrls'] ?? [];

    // If there are images in the current suggestion, merge them with the existing images in Tags
    List<String> updatedImageUrls = [
      ...existingImageUrls,
      ...(data['ImageUrls'] is List ? List<String>.from(data['ImageUrls']) : [data['ImageUrls']]), // Add suggested images
    ];

    // Handle cost
    String costValue = data['cost'] ?? 'Free';

    // Handle position: Split the position string into latitude and longitude
    String? position = data['position']; // This should be the 'position' field
    double? latitude;
    double? longitude;

    if (position != null) {
      List<String> coords = position.split(',');
      if (coords.length == 2) {
        latitude = double.tryParse(coords[0].trim());
        longitude = double.tryParse(coords[1].trim());
      }
    }

    if (latitude == null || longitude == null) {
      throw Exception('Position data (latitude or longitude) is invalid.');
    }

    // Create GeoPoint from latitude and longitude
    GeoPoint geoPoint = GeoPoint(latitude, longitude);
    LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
    addMarker(latLng, markerId);

    // Save the data to Firestore with GeoPoint and the updated image URLs
    await tagRef.set(
      {
        'TagId': markerId.value,
        'ImageUrls': updatedImageUrls,  // Transfer the images to the Tags collection
        'Name': data['name'],
        'Location': data['location'] ?? 'Unknown location',
        'Cost': costValue,
        'position': geoPoint, // Store as GeoPoint
      },
      SetOptions(merge: true), // Merge with existing data to avoid overwriting other fields
    );

    // Optionally delete from 'suggested_restrooms' after adding it to 'Tags'
    await FirebaseFirestore.instance
        .collection('suggested_restrooms')
        .doc(markerId.value)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restroom information added successfully with position and images.'),
          backgroundColor: Color.fromARGB(255, 115, 99, 183),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save restroom information: $e'),
          backgroundColor: Color.fromARGB(255, 240, 148, 142),
        ),
      );
    }
  }
}

  // Loads markers from Firestore and converts them into a set of Marker objects for the map.
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
              report: widget.report,
              username: widget.username,
              deleteMarker: _deleteMarker,
              destination: latLng,
            ),
          );
        },
      );
    }).toSet();

    return loadedMarkers;
  }

  // Saves the current markers' data to SharedPreferences.
  Future<void> _saveMarkersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final markerData = _markers.map((marker) {
      return '${marker.markerId.value},${marker.position.latitude},${marker.position.longitude}';
    }).toList();
    await prefs.setStringList('markers', markerData);
  }

  // Deletes a marker from the map and Firestore, and updates the saved markers in SharedPreferences.
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

  @override
  Widget build(BuildContext context) {
    final markerId_ =
        MarkerId('marker_${DateTime.now().millisecondsSinceEpoch}');

    // Adds a marker at the user's current location and prompts the user to confirm adding a tag.
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
                                destination: _currentP!,
                              ),
                            ).then((confirmed) {
                              print(confirmed);
                              if (confirmed == true) {
                                addMarker(_currentP!, markerId_);
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
            actions: [
            IconButton(
              icon: const Icon(Icons.assignment_outlined, color: Colors.white),
              onPressed: () => _showSuggestedRestrooms(context),
            ),
          ],
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
                                  builder: (context) => AddInfoDialog(
                                    markerId: markerId_,
                                    destination: latLng,
                                  ),
                                ).then((confirmed) {
                                  print(confirmed);
                                  if (confirmed == true) {
                                    addMarker(latLng, markerId_);
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

  // Shows a confirmation dialog when the back button is pressed and navigates to the AdminPage if confirmed.
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
                _createRoute(AdminPage(
                  username: widget.username,
                  report: widget.report,
                )),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // Requests location permissions and service enablement, then listens for location updates.
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

        if (!isUserLocationVisible) {
          _ensureUserLocationVisible();
          isUserLocationVisible = true;
        }
      }
    });
  }

  // Centers the camera on the user's current location and maintains the current zoom level.
  Future<void> _ensureUserLocationVisible() async {
    if (_currentP != null) {
      // Center the camera on the user's location
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentP!, // center on the user's current position
            zoom: await mapController
                .getZoomLevel(), // Maintain the current zoom level
          ),
        ),
      );
    }
  }

   // Adds a marker to the map, updates the markers list, and saves it to Firestore and SharedPreferences.
  void addMarker(LatLng latLng, MarkerId markerId_) {
    Marker newMarker = Marker(
      markerId: markerId_,
      position: latLng,
      icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AdminTagInformation(
            markerId: markerId_,
            report: widget.report,
            username: widget.username,
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
  // Creates a custom route with a slide transition from the bottom to the top.
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
