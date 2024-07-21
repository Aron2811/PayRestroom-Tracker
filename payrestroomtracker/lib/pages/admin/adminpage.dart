import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminMap.dart';
import 'package:flutter_button/pages/admin/admin_report.dart';
import 'package:flutter_button/pages/intro_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import to use GeoPoint

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
                  '$badgeCount',
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

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key, required this.username, required this.report}) : super(key: key);
  final String username;
  final String report;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  LatLng destination = LatLng(14.303142147986497, 121.07613374318477); // Default destination
  int unreadCount = 0; // Counter for unread reports

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('read', isEqualTo: false)
          .get();

      setState(() {
        unreadCount = querySnapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching unread count: $e");
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

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Future<bool> _onBackButtonPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to logout?"),
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
                _createRoute(IntroPage(report: '',)),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert LatLng to GeoPoint
    GeoPoint geoPoint = GeoPoint(destination.latitude, destination.longitude);

    return WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              // Background Image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60.0),
                    child: SizedBox.shrink(), // Placeholder for an empty child
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 50, right: 25), // Adjust the value to your needs
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                          Navigator.push(
                            context,
                            _createRoute(IntroPage(report: '',)),
                          );
                        },
                        child: Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  // Image
                  Image.asset(
                    'assets/PO_tag.png',
                    width: 230,
                    height: 230,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Hello',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${widget.username}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 25),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        enableFeedback: false,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(170, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        foregroundColor: Color.fromARGB(255, 97, 84, 158),
                        textStyle: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      label: const Text(
                        "View Map",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 132, 119, 197),
                        ),
                      ),
                      icon: const Icon(
                        Icons.map_rounded,
                        color: Color.fromARGB(255, 132, 119, 197),
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(AdminMap(
                            username: widget.username,
                            report: widget.report,
                          )),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: Badge(
                      badgeCount: unreadCount,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          enableFeedback: false,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(170, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          foregroundColor: Color.fromARGB(255, 97, 84, 158),
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        label: const Text(
                          "View Report",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 132, 119, 197),
                          ),
                        ),
                        icon: const Icon(
                          Icons.report_problem_rounded,
                          color: Color.fromARGB(255, 132, 119, 197),
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            _createRoute(AdminReport(
                              username: widget.username,
                              report: widget.report,
                              destination: geoPoint, // Pass the GeoPoint
                            )),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
