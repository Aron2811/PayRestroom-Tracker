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

class AdminMap extends StatefulWidget {
  const AdminMap({Key? key, required this.username, required this.report})
      : super(key: key);
  final String username;
  final String report;

  @override
  State<AdminMap> createState() => AdminMapState();
}

// Custom Badge Widget
class Badge extends StatelessWidget {
  final Widget child;
  final int badgeCount;

  Badge({required this.child, required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (badgeCount > 0)
          Positioned(
            right: 0,
            top: -5,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 226, 99, 90),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  '$badgeCount', //display badge count
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
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

  void _navigateToRestroom(QueryDocumentSnapshot restroom) {
    final GeoPoint position = restroom['position'];
    final LatLng target = LatLng(position.latitude, position.longitude);

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
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
              Text(
                  'Location: ${data['location'] ?? 'No description provided.'}'),
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
                acceptRestroom(context, docId, data);
                rejectRestroom(docId);
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog when tapped
            },
            child: Container(
              color: Colors.black, // Background color
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain, // Fit the image within the dialog
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOwnersRestrooms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Text(
                  'Owners and Restrooms',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                // Content with StreamBuilder
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('owners_restrooms')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Error loading data.',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final owners = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: owners.length,
                          itemBuilder: (context, index) {
                            final ownerData = owners[index];
                            final data =
                                ownerData.data() as Map<String, dynamic>;

                            final ownerName =
                                ownerData['ownername'] ?? 'Unknown Owner';
                            final gcashNumber =
                                ownerData['gcash_number'] ?? 'No GCash Number';
                            final businessPermitImage =
                                ownerData['business_permit_image'] ?? '';
                            final restroomName =
                                ownerData['name'] ?? 'No Restroom Name';
                            final location =
                                ownerData['location'] ?? 'No Location';
                            final cost =
                                ownerData['cost'] ?? 'No Cost Available';
                            final imageUrls =
                                ownerData['ImageUrls'] as List<dynamic>? ?? [];

                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Owner Details
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Business Permit Image
                                        GestureDetector(
                                          onTap: () {
                                            _showFullScreenImage(
                                                context, businessPermitImage);
                                          },
                                          child: businessPermitImage.isNotEmpty
                                              ? Image.network(
                                                  businessPermitImage,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(Icons.business,
                                                  size: 100),
                                        ),

                                        const SizedBox(width: 12),
                                        // Owner Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ownerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text('GCash: $gcashNumber'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Restroom Details
                                    ListTile(
                                      leading: imageUrls.isNotEmpty
                                          ? Image.network(
                                              imageUrls[0],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 80,
                                              color: Colors.grey),
                                      title: Text(
                                        restroomName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                          'Location: $location\nCost: $cost |'),
                                      onTap: () {
                                        showRestroomDetails(
                                            context, ownerData.id, data);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const Center(
                        child: Text('No owner restrooms available.'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> rejectRestroom(String docId) async {
    await FirebaseFirestore.instance
        .collection('suggested_restrooms')
        .doc(docId)
        .delete();

    await FirebaseFirestore.instance
        .collection('owners_restrooms')
        .doc(docId)
        .delete();
  }

  Future<void> acceptRestroom(
      BuildContext context, String docId, Map<String, dynamic> data) async {
    final markerId =
        MarkerId('marker_${DateTime.now().millisecondsSinceEpoch}');

    try {
      DocumentReference tagRef =
          FirebaseFirestore.instance.collection('Tags').doc(markerId.value);

      DocumentSnapshot tagSnapshot = await tagRef.get();
      Map<String, dynamic>? tagData =
          tagSnapshot.data() as Map<String, dynamic>?;

      // Fetch existing images from the Tags collection, or initialize an empty list
      List<dynamic> existingImageUrls = tagData?['ImageUrls'] ?? [];

      // If there are images in the current suggestion, merge them with the existing images in Tags
      List<String> updatedImageUrls = [
        ...existingImageUrls,
        ...(data['ImageUrls'] is List
            ? List<String>.from(data['ImageUrls'])
            : [data['ImageUrls']]), // Add suggested images
      ];

      // Handle cost
      String costValue = data['cost'] ?? 'Free';

      // Handle position: Split the position string into latitude and longitude
      String? position =
          data['position']; // This should be the 'position' field
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
          'ImageUrls':
              updatedImageUrls, // Transfer the images to the Tags collection
          'Name': data['name'],
          'Location': data['location'] ?? 'Unknown location',
          'Cost': costValue,
          'position': geoPoint, // Store as GeoPoint
        },
        SetOptions(
            merge:
                true), // Merge with existing data to avoid overwriting other fields
      );

      data['TagId'] = markerId.value;
      // Add the data to 'accepted_restrooms'
      await FirebaseFirestore.instance
          .collection('accepted_restrooms')
          .doc(markerId.value)
          .set(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Restroom information added successfully and moved to accepted_restrooms.'),
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

  Future<void> _showSuggestedRestrooms(BuildContext context) async {
    final restrooms = await FirebaseFirestore.instance
        .collection('suggested_restrooms') // Suggested restrooms collection
        .get();

    final restroomList = restrooms.docs.map((doc) => doc).toList();

    // Fetch the restroom_edit_suggestions data
    final editSuggestions = await FirebaseFirestore.instance
        .collection('restroom_edit_suggestions') // Edit suggestions collection
        .get();

    final editSuggestionList = editSuggestions.docs.map((doc) => doc).toList();

    // Fetch the restroom_delete_suggestions data
    final removalSuggestions = await FirebaseFirestore.instance
        .collection(
            'restroom_delete_suggestions') // Removal suggestions collection
        .get();

    final removalSuggestionList =
        removalSuggestions.docs.map((doc) => doc).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DefaultTabController(
          length: 3, // Three tabs
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: Color.fromARGB(255, 115, 99, 183), // Purple background color
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center content
              children: [
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'User Suggestions and Removals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                    textAlign: TextAlign.center, // Center title
                  ),
                ),
                const SizedBox(height: 20),
                // TabBar for switching between tabs
                const TabBar(
                  tabs: [
                    Tab(
                      child: Text(
                        'Restroom\nSuggestion',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Restroom\nEdit Requests',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Restroom\nRemoval',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Suggested Restrooms Tab
                      ListView.builder(
                        itemCount: restroomList.length,
                        itemBuilder: (context, index) {
                          final doc = restroomList[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(data['name'] ?? 'Unnamed Restroom',
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                                data['location'] ?? 'No description provided.',
                                style: TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            onTap: () {
                              Navigator.pop(context); // Close the bottom sheet
                              showRestroomDetails(
                                  context, doc.id, data); // Show details dialog
                            },
                          );
                        },
                      ),
                      // Suggested Edit Requests Tab
                      ListView.builder(
                        itemCount: editSuggestionList.length,
                        itemBuilder: (context, index) {
                          final doc = editSuggestionList[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(
                                data['SuggestedName'] ?? 'Unnamed Restroom',
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                                data['SuggestedLocation'] ??
                                    'No description provided.',
                                style: TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            onTap: () {
                              Navigator.pop(context); // Close the bottom sheet
                              // Show the suggested restroom details
                              showEditRequestDetails(context, data, doc.id);
                            },
                          );
                        },
                      ),
                      // Restroom Removal Tab
                      ListView.builder(
                        itemCount: removalSuggestionList.length,
                        itemBuilder: (context, index) {
                          final doc = removalSuggestionList[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(
                                data['restroomName'] ?? 'Unnamed Restroom',
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                                data['reason'] ?? 'No reason provided.',
                                style: TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            onTap: () {
                              Navigator.pop(context); // Close the bottom sheet
                              showRemovalDetails(context, data, doc.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showRemovalDetails(
      BuildContext context, Map<String, dynamic> data, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data['restroomName'] ?? 'Unnamed Restroom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reason: ${data['reason'] ?? 'No reason provided.'}'),
              const SizedBox(height: 10),
              data['image'] != null
                  ? Container(
                      height: 200, // Set a max height for the image
                      width: double
                          .infinity, // Make the image stretch horizontally
                      child: Image.network(
                        data['image'],
                        fit: BoxFit
                            .cover, // Ensure the image scales appropriately
                      ),
                    )
                  : const Text('No image provided.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Trigger map focus using location from the edit suggestion
                if (data['destination'] != null) {
                  final position = data['destination'];
                  if (position is GeoPoint) {
                    focusMapCameraToPosition(
                        position); // Focus on the location in the map
                  } else {
                    print("Invalid position format");
                  }
                }
                Navigator.of(context)
                    .pop(); // Close the dialog after tagging the location
              },
              child: Text('Navigate'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the document from Firestore
                  await FirebaseFirestore.instance
                      .collection('restroom_delete_suggestions')
                      .doc(docId)
                      .delete();

                  // Show a confirmation Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Restroom removal suggestion deleted.')),
                  );

                  // Close the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any errors during deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete. Please try again.')),
                  );
                }
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showEditRequestDetails(
      BuildContext context, Map<String, dynamic> data, String docId) {
    // Show a dialog or another screen with the edit request details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['SuggestedName'] ?? 'Unnamed Restroom'),
          content: SingleChildScrollView(
            // Allows scrolling if content overflows
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Suggested Name: ${data['SuggestedName'] ?? 'No location provided.'}'),
                Text(
                    'Suggested Location: ${data['SuggestedLocation'] ?? 'No location provided.'}'),
                Text(
                    'Suggested Cost: ${data['SuggestedCost'] ?? 'No cost provided.'}'),
                SizedBox(height: 10),
                Text('Images:'),
                // Display image URLs if available
                data['ImageUrls'] != null && data['ImageUrls'] is List
                    ? Column(
                        children: (data['ImageUrls'] as List).map((url) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Image.network(
                              url,
                              height: 200, // Set a fixed height for the images
                              width: double
                                  .infinity, // Set width to take full available width
                              fit: BoxFit
                                  .cover, // Ensures image scales without distortion
                            ),
                          );
                        }).toList(),
                      )
                    : Text('No images available.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
            // Option to focus map on the tagged location
            TextButton(
              onPressed: () {
                // Trigger map focus using location from the edit suggestion
                if (data['Position'] != null) {
                  final position = data['Position'];
                  if (position is GeoPoint) {
                    focusMapCameraToPosition(
                        position); // Focus on the location in the map
                  } else {
                    print("Invalid position format");
                  }
                }
                Navigator.of(context)
                    .pop(); // Close the dialog after tagging the location
              },
              child: Text('Navigate'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the document from Firestore
                  await FirebaseFirestore.instance
                      .collection('restroom_edit_suggestions')
                      .doc(docId)
                      .delete();

                  // Show a confirmation Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Restroom removal suggestion deleted.')),
                  );

                  // Close the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any errors during deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete. Please try again.')),
                  );
                }
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

// Function to focus the map camera based on the position (assuming a map controller is available)
  void focusMapCameraToPosition(GeoPoint position) {
    // Check if position is valid
    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18.0, // Adjust the zoom level if needed
    );

    // Assuming you have a reference to your map controller (GoogleMapController)
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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

  print("Deleting marker with ID: ${markerId.value}");

  try {
    // Remove the marker from Firestore in the 'Tags' collection
    await FirebaseFirestore.instance
        .collection('Tags')
        .doc(markerId.value)
        .delete();

    // Remove the marker from Firestore in the 'accepted_restrooms' collection
    await FirebaseFirestore.instance
        .collection('accepted_restrooms')
        .doc(markerId.value)
        .delete();
    
    // Remove the corresponding document in 'restroom_delete_suggestions' where TagId matches markerId.value
    var querySnapshot = await FirebaseFirestore.instance
        .collection('restroom_delete_suggestions')
        .where('TagId', isEqualTo: markerId.value)
        .get();

    print("Found ${querySnapshot.docs.length} documents to delete in restroom_delete_suggestions.");

    // Delete each matching document
    for (var doc in querySnapshot.docs) {
      print("Deleting document with ID: ${doc.id}");
      await doc.reference.delete();
    }
  } catch (e) {
    print("Error deleting marker: $e");
  }
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
            Align(
              alignment: Alignment.center,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('suggested_restrooms')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Loading indicator
                  }

                  if (snapshot.hasError) {
                    return const Icon(Icons.error_outline,
                        color: Colors.red); // Error indicator
                  }

                  if (snapshot.hasData) {
                    int count =
                        snapshot.data!.docs.length; // Total document count
                    return Padding(
                        padding:
                            const EdgeInsets.only(right: 10.0), // Right padding
                        child: Badge(
                          badgeCount:
                              count, // Pass the badge count to the custom Badge widget
                          child: IconButton(
                            icon: const Icon(Icons.assignment_outlined,
                                color: Colors.white),
                            onPressed: () {
                              _showSuggestedRestrooms(context);
                            },
                          ),
                        ));
                  }

                  // Fallback for no data
                  return const Icon(Icons.assignment_outlined,
                      color: Colors.grey);
                },
              ),
            ),
          ],
          leading: Align(
            alignment: Alignment.center,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('owners_restrooms')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Loading indicator
                }

                if (snapshot.hasError) {
                  return const Icon(Icons.error_outline,
                      color: Colors.red); // Error indicator
                }

                if (snapshot.hasData) {
                  int count =
                      snapshot.data!.docs.length; // Total document count
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0), // Left padding
                    child: Badge(
                      badgeCount:
                          count, // Pass the badge count to the custom Badge widget
                      child: IconButton(
                        icon: const Icon(Icons.store_mall_directory_outlined,
                            color: Colors.white),
                        onPressed: () {
                          _showOwnersRestrooms(context);
                        },
                      ),
                    ),
                  );
                }

                // Fallback for no data
                return const Icon(Icons.store_mall_directory_outlined,
                    color: Colors.grey);
              },
            ),
          ),
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
