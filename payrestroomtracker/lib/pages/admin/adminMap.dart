import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:flutter_button/pages/dialog/admin_tag_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';

class AdminMap extends StatefulWidget {
  const AdminMap({super.key, required this.username});
  final String username;
  @override
  State<AdminMap> createState() => _AdminMapState();
}

class _AdminMapState extends State<AdminMap> {
  static const LatLng _pGooglePlex =
      LatLng(14.303142147986497, 121.07613374318477);
  late GoogleMapController mapController;
  LatLng? _currentP = null;
  String? _currentAddress;
  Set<Marker> _markers = {};
  Location _locationController = new Location();
  BitmapDescriptor? _customMarkerIcon;
  BitmapDescriptor? _personMarkerIcon;
  late String _mapStyleString;
  Set<Polyline> _polylines = {};
  bool addclick = false;
  bool editclick = false;
  bool removeclick = false;

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
    _loadCustomMarkerIcon();
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
    if (_currentP != null) {
      print(_currentP);
      _markers.add(
        Marker(
          markerId: const MarkerId('User Location'),
          position: _currentP!,
          icon: _personMarkerIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    }

    var markers = {
      Marker(
          markerId: const MarkerId('1'),
          position: LatLng(14.315468626815898, 121.07064669023518),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('2'),
          position: LatLng(14.356239417708707, 121.04451720560752),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('3'),
          position: LatLng(14.355059500353084, 121.0442736161414),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('4'),
          position: LatLng(14.33120930591894, 121.06947036325884),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('5'),
          position: LatLng(14.31992161435816, 121.1176986169851),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('6'),
          position: LatLng(14.263368532549292, 121.04213554806316),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('7'),
          position: LatLng(14.247512370849535, 121.06340147747518),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('8'),
          position: LatLng(14.247352099793037, 121.06342553348516),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('9'),
          position: LatLng(14.169189623465543, 121.14310662338366),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
      Marker(
          markerId: const MarkerId('10'),
          position: LatLng(14.293578936541783, 121.07870252060286),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => showDialog(
              context: context, builder: (context) => AdminTagInformation())),
    };

    _markers.addAll(markers);

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
                    fontWeight: FontWeight.bold),
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
                                    Marker newMarker = Marker(
                                        markerId: MarkerId("value"),
                                        position: LatLng(
                                            latLng.latitude, latLng.longitude),
                                        icon: _customMarkerIcon ??
                                            BitmapDescriptor.defaultMarker);

                                   //for tapping the new marker tag this should appear
                                    // onTap:
                                    // () {
                                    //   Navigator.of(context).pop(true);
                                    //   showDialog(
                                    //       context: context,
                                    //       builder: (context) =>
                                    //           AdminTagInformation());
                                    // };

                                    _markers.add(newMarker);
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            ));
                  },
                  initialCameraPosition: const CameraPosition(
                    target: _pGooglePlex,
                    zoom: 13,
                  ),
                  zoomControlsEnabled:
                      false, // Disable zoom in and zoom out buttons
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    mapController.setMapStyle(_mapStyleString);
                  },
                ),
              ],
            )));
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
                    Navigator.push(context,
                        _createRoute(AdminPage(username: widget.username)));
                  },
                  child: const Text("Yes"),
                ),
              ],
            ));
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
