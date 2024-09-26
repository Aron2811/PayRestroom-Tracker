import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

class AStar {
  final String googleMapsApiKey;
  final Function(String, String) updateDurationCallback;

  AStar(this.googleMapsApiKey, this.updateDurationCallback);

  Future<List<LatLng>> findAndDrawPath(
      LatLng start, LatLng goal, String options) async {
    // Align the goal to the nearest road
    goal = await _snapToRoad(goal);

    var pathPoints = await _fetchRouteFromGoogleMaps(start, goal, options);
    print('Path points from Google Maps Directions API:');
    for (var point in pathPoints) {
      print('$point');
    }
    if (pathPoints.isEmpty) {
      print('No valid route found from Google Maps Directions API.');
      return [start, goal];
    }

    PriorityQueue<Node> openSet =
        PriorityQueue<Node>((a, b) => a.f.compareTo(b.f));
    Set<LatLng> closedSet = {};
    Map<LatLng, LatLng> cameFrom = {};
    Map<LatLng, double> gScore = {start: 0.0};
    Map<LatLng, double> fScore = {start: _heuristic(start, goal)};
    openSet.add(Node(start, fScore[start]!));
    Set<LatLng> openSetPositions = {start};

    // Print the initial state of the open set and closed set
    print('Initial open set:');
    openSet.toList().forEach((node) {
      print('${node.position}');
    });
    print('Initial closed set:');
    for (var position in closedSet) {
      print('$position');
    }

    while (openSet.isNotEmpty) {
      // Step a: Find the Node with the Lowest f Value
      Node current = openSet.removeFirst();
      openSetPositions.remove(current.position);

      // Print the current node being processed
      print('Processing node: ${current.position}');

      // Step b: Move the Current Node from the Open List to the Closed List
      closedSet.add(current.position);

      // Step c: Check if the Current Node is the Goal
      if (current.position == goal) {
        print('Goal reached at ${current.position}!');
        return _interpolate(
            _reconstructPath(cameFrom, current.position), options);
      }

      // Step d: Process Each Neighbor of the Current Node
      for (LatLng neighbor in pathPoints) {
        if (closedSet.contains(neighbor)) continue; // Ignore if in closed set

        // Calculate tentative g score
        double tentativeGScore =
            gScore[current.position]! + _distance(current.position, neighbor);

        // Step e: Update Scores if Better Path Found
        if (!openSetPositions.contains(neighbor)) {
          // Add neighbor to open set if not already there
          cameFrom[neighbor] = current.position;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = gScore[neighbor]! + _heuristic(neighbor, goal);
          openSet.add(Node(neighbor, fScore[neighbor]!));
          openSetPositions.add(neighbor);
        } else if (tentativeGScore < gScore[neighbor]!) {
          // Update neighbor if new path is better
          cameFrom[neighbor] = current.position;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = gScore[neighbor]! + _heuristic(neighbor, goal);

          // Reorder openSet with updated fScores
          openSet = PriorityQueue<Node>((a, b) => a.f.compareTo(b.f));
          openSet
              .addAll(openSetPositions.map((pos) => Node(pos, fScore[pos]!)));
        }
      }
    }

    // Print message when no valid path to the goal is found
    print('No valid path found from $start to $goal.');
    return [start, goal]; // or handle the case appropriately
  }

  // Snaps a given LatLng point or the goal to the nearest road
  Future<LatLng> _snapToRoad(LatLng point) async {
    final String url =
        'https://roads.googleapis.com/v1/snapToRoads?path=${point.latitude},${point.longitude}&key=$googleMapsApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['snappedPoints'] != null && data['snappedPoints'].isNotEmpty) {
        final snappedLocation = data['snappedPoints'][0]['location'];
        LatLng snappedPoint = LatLng(
            double.parse(snappedLocation['latitude'].toStringAsFixed(5)),
            double.parse(snappedLocation['longitude'].toStringAsFixed(5)));
        print('Snapped point: $snappedPoint');
        return snappedPoint;
      } else {
        print('No snapped point found.');
        return point;
      }
    } else {
      print('Error snapping to road: ${response.statusCode}');
      return point;
    }
  }

  Future<List<LatLng>> _fetchRouteFromGoogleMaps(
      LatLng start, LatLng goal, String options) async {
    final String travelMode =
        (options == 'byFoot' || options == 'commute') ? 'walking' : 'driving';

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${goal.latitude},${goal.longitude}&mode=$travelMode&key=$googleMapsApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> pathPoints = _decodeDetailedPolyline(
            data['routes'][0]['overview_polyline']['points']);
        print('Path points retrieved from Google Maps:');
        for (var point in pathPoints) {
          print('$point');
        }

        // Initialize durationString with a default value
        String durationString = '';

        // Extract the duration and store it in the appropriate variable
        int durationSeconds = data['routes'][0]['legs'][0]['duration']['value'];

        if (options == 'byFoot') {
          durationString =
              '${(durationSeconds ~/ 3600).toString().padLeft(2, '0')}hr ${(durationSeconds ~/ 60 % 60).toString().padLeft(2, '0')}min';
        } else if (options == 'commute') {
          // Calculate the distance between start and goal in miles
          String distanceMilesString = getDistanceInMiles(start, goal);

          double distanceMiles =
              double.parse(distanceMilesString.split(' ')[0]);

          // Calculate the number of 0.43-mile segments
          double segments = distanceMiles / 0.43;

          // Subtract 8 minutes (480 seconds) for each segment
          int commuteDurationSeconds =
              durationSeconds - (segments.floor() * 480);

          // Ensure that the duration doesn't go below zero
          commuteDurationSeconds =
              commuteDurationSeconds > 0 ? commuteDurationSeconds : 0;

          durationString =
              '${(commuteDurationSeconds ~/ 3600).toString().padLeft(2, '0')}hr ${(commuteDurationSeconds ~/ 60 % 60).toString().padLeft(2, '0')}min';
        } else if (options == 'private') {
          // Handle private mode, assuming it's driving
          durationString =
              '${(durationSeconds ~/ 3600).toString().padLeft(2, '0')}hr ${(durationSeconds ~/ 60 % 60).toString().padLeft(2, '0')}min';
        }

        // Use the callback to update the state in the parent widget
        updateDurationCallback(options, durationString);

        return pathPoints;
      } else {
        print('Error fetching route: ${data['status']}');
        return [];
      }
    } else {
      print('Error fetching route: ${response.statusCode}');
      return [];
    }
  }

  // Decodes an encoded polyline string into a list of LatLng points.
  List<LatLng> _decodeDetailedPolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;

      polyline.add(LatLng(latitude, longitude));
    }

    return polyline;
  }

  // Interpolates between consecutive LatLng points by fetching detailed route points and adds them to the list.
  Future<List<LatLng>> _interpolate(List<LatLng> points, String options) async {
    List<LatLng> interpolatedPoints = [];

    for (int i = 0; i < points.length - 1; i++) {
      LatLng current = points[i];
      LatLng next = points[i + 1];

      interpolatedPoints.add(current);

      List<LatLng> detailedRoutePoints =
          await _fetchDetailedRoute(current, next, options);

      interpolatedPoints.addAll(detailedRoutePoints);
    }

    interpolatedPoints.add(points.last);

    return interpolatedPoints;
  }

  // Fetches a detailed route between two LatLng points, or returns the original points if no route is found.
  Future<List<LatLng>> _fetchDetailedRoute(
      LatLng start, LatLng end, String options) async {
    var detailedRoute = await _fetchRouteFromGoogleMaps(start, end, options);
    if (detailedRoute.isNotEmpty) {
      return detailedRoute;
    } else {
      return [start, end];
    }
  }

  // Calculates the heuristic distance (Haversine formula) between two LatLng points in kilometers.
  double _heuristic(LatLng a, LatLng b) {
    const double radiusEarthKm = 6371.0; // Earth's radius in kilometers

    double lat1 = a.latitude * pi / 180.0;
    double lon1 = a.longitude * pi / 180.0;
    double lat2 = b.latitude * pi / 180.0;
    double lon2 = b.longitude * pi / 180.0;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double havTheta =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double distance = 2 * radiusEarthKm * asin(sqrt(havTheta));

    return distance;
  }

  // Calculates the great-circle distance between two LatLng points using the Haversine formula.
  double _distance(LatLng a, LatLng b) {
    const double earthRadiusKm = 6371.0; // Earth's radius in kilometers

    double lat1 = a.latitude * pi / 180.0;
    double lon1 = a.longitude * pi / 180.0;
    double lat2 = b.latitude * pi / 180.0;
    double lon2 = b.longitude * pi / 180.0;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double havTheta =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double distance = 2 * earthRadiusKm * asin(sqrt(havTheta));

    return distance;
  }

  // Reconstructs the path by backtracking from the current LatLng point using the 'cameFrom' map.
  List<LatLng> _reconstructPath(Map<LatLng, LatLng> cameFrom, LatLng current) {
    List<LatLng> totalPath = [current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      totalPath.add(current);
    }
    return totalPath.reversed.toList();
  }

  // New method to calculate the distance in miles
  String getDistanceInMiles(LatLng start, LatLng end) {
    const double earthRadiusMiles = 3958.8; // Earth's radius in miles

    double lat1 = start.latitude * pi / 180.0;
    double lon1 = start.longitude * pi / 180.0;
    double lat2 = end.latitude * pi / 180.0;
    double lon2 = end.longitude * pi / 180.0;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double havTheta =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double distance = 2 * earthRadiusMiles * asin(sqrt(havTheta));

    // Format the distance to 2 decimal places
    String formattedDistance = distance.toStringAsFixed(2);

    return '$formattedDistance miles';
  }
}

// A class representing a node with a LatLng position and an 'f' value (used for pathfinding algorithms like A*).
class Node {
  LatLng position;
  double f;

  Node(this.position, this.f);
}
