import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';

class MapScreen extends StatefulWidget {
  final String mapStyle; // Accept mapStyle as a parameter

  const MapScreen({Key? key, required this.mapStyle}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng _initialPosition = const LatLng(14.303142147986497, 121.07613374318477); // Default to Manila
  LatLng? _selectedPosition;
  Location _location = Location(); // Create Location instance
  Marker? _currentLocationMarker; // Marker for current location
  Set<Marker> _markers = {}; // Set of markers to display on the map
  final AdminMapState adminMap = AdminMapState();
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkers(); // Load markers when the widget is initialized
    _loadCustomMarkerIcon(); 
  }

  Future<void> _loadCustomMarkerIcon() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/paid_CR_Tag.png',
    );
  }

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permission;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }
    }

    // Check if location permission is granted
    permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    // Get current position
    LocationData currentLocation = await _location.getLocation();

    // Update camera position to current location
    setState(() {
      _initialPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);

      // Add a marker at the current location (set to purple)
      _currentLocationMarker = Marker(
        markerId: MarkerId('current_location'),
        position: _initialPosition,
        infoWindow: InfoWindow(title: 'Your Location', snippet: 'This is where you are'),
        icon: BitmapDescriptor.defaultMarkerWithHue(255.0), // Purple color for the marker
      );
    });

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(_initialPosition));
    }
  }

  // Function to load markers from preferences or database
  Future<void> _loadMarkers() async {
    _markers = await adminMap.loadMarkersFromPrefs().then((markers) {
      print("Loaded markers: $markers");  // Debugging output
      return markers.map((marker) {
        return Marker(
          markerId: marker.markerId,
          position: marker.position,
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
        );
      }).toSet();
    });

    setState(() {}); // Update UI after loading markers
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (widget.mapStyle.isNotEmpty) {
      mapController?.setMapStyle(widget.mapStyle); // Apply map style
    }
    _getCurrentLocation(); // Get the current location when the map is created
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location', style: TextStyle(
              fontSize: 17,
              color: Colors.white,
            ),),
            backgroundColor: const Color.fromARGB(255, 97, 84, 158),
            actions: [
    IconButton(
      icon: const Icon(Icons.check, color: Colors.white),
      onPressed: () {
        // Use current location as the selected location if no position is selected
        final locationToReturn = _selectedPosition ?? _initialPosition;
        Navigator.pop(context, locationToReturn);
      },
    ),
  ],
            ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 13,
        ),
        onTap: _onTap,
        markers: {
          ..._markers,
          // Add the selected marker if it exists
          if (_selectedPosition != null)
            Marker(markerId: MarkerId('selected'), position: _selectedPosition!),
          // Optionally, add the current location marker if it's available
          if (_currentLocationMarker != null)
            _currentLocationMarker!,
        },
      ),
      
    );
  }
}