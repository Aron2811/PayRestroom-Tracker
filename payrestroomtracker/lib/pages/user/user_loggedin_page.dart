import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_button/pages/dialog/tutorial_dialog.dart';
import 'package:flutter_button/pages/loading_page.dart';
import 'package:flutter_button/pages/user/map_page.dart';
import 'package:flutter_button/pages/user/report_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLoggedInPage extends StatefulWidget {
  const UserLoggedInPage({super.key});

  @override
  State<UserLoggedInPage> createState() => _UserLoggedInPageState();
}

class _UserLoggedInPageState extends State<UserLoggedInPage> {
  // we r using Firebase Auth to get the current users ID
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Check if the user is banned when the page is loaded
    _checkIfUserIsBanned();
  }

  void _showTutorialDialog() {
    // Call this function only if the user is confirmed unbanned
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => const TutorialDialog(),
      );
    });
  }

  void _checkBannedStatusFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isBanned = prefs.getBool('isBanned') ?? false;

    if (isBanned) {
      _showBannedDialog(); // Trigger only if banned
    } else {
      // Safe to show the tutorial here if needed
      _showTutorialDialog();
    }
  }

  // Function to check if the user is banned from Firestore
  void _checkIfUserIsBanned() async {
    try {
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        bool isBanned = userDoc['isBanned'] ?? false;

        // Update SharedPreferences with the latest value
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isBanned', isBanned);

        // Only show the banned dialog if isBanned is true
        if (isBanned) {
          _showBannedDialog(); // Show banned dialog
        } else {
          print('User is not banned. No dialog shown.');
        }
      } else {
        _navigateToLoginPage(); // Handle no user scenario
      }
    } catch (e) {
      print('Error checking user ban status: $e');
    }
  }

  // Show the banned user dialog with only a logout button
  void _showBannedDialog() {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent dismissing the dialog by tapping outside
        builder: (context) {
          return WillPopScope(
            onWillPop: () async =>
                false, // Prevent back button from closing the dialog
            child: Dialog(
              backgroundColor: const Color.fromARGB(255, 132, 119, 197),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.block, // Block icon
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'You are banned from using this app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Button color
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _logOutUser(); // Trigger the logout process
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _logOutUser() async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase sign out
      print('User logged out');
      _navigateToLoginPage(); // Navigate to login page after logout
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Function to navigate to the login page
  void _navigateToLoginPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoadingPage(),
        ));
  }

  void _navigateToReportUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ReportUser(), // Navigate to your ReportUser class
      ),
    );
  }

  // back button function
  Future<bool> onBackButtonPressed() async {
    Navigator.of(context).push(_createRoute(UserLoggedInPage()));
    return false; // Prevents the app from closing
  }

  void _checkIfUserIsHeld() async {
    try {
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        // Safely extract fields from Firestore document and set defaults if missing (the fields cuz it doesnt work if no field is found)
        var data = userDoc.data() as Map<String, dynamic>?;
        bool isHeld = data?['isHeld'] ?? false; // Default to false if missing
        Timestamp? holdTimestamp = data?['holdTimestamp'];
        int holdDuration =
            data?['holdDuration'] ?? 0; // Default to 0 if missing

        // If user is held and the hold end time hasn't passed, show the hold dialog
        if (isHeld && holdTimestamp != null) {
          DateTime holdEndTime =
              holdTimestamp.toDate().add(Duration(hours: holdDuration));
          if (DateTime.now().isBefore(holdEndTime)) {
            // Show hold dialog if the user is still held
            _showHoldDialog(holdEndTime);
            return;
          }
        }
        // Navigate to Map if not held or hold duration has passed
        Navigator.push(context, _createRoute(MapPage()));
      }
    } catch (e) {
      print('Error checking hold status: $e');
    }
  }

  void _showHoldDialog(DateTime holdEndTime) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: const Color.fromARGB(255, 132, 119, 197),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hourglass_bottom,
                    color: Colors.orangeAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'You are currently on hold.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hold ends at: ${holdEndTime.toLocal().toString().split('.')[0]}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackButtonPressed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
              // Foreground content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 130),

                    // Paid restroom logo
                    Image.asset(
                      'assets/PO_tag.png',
                      width: 250,
                      height: 250,
                    ),

                    const SizedBox(height: 60),

                    // Text
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 20.0),
                      child: Text(
                        'You are now logged in',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        enableFeedback: false,
                        backgroundColor:
                            const Color.fromARGB(255, 226, 223, 229),
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 115, 99, 183),
                          width: 4.0,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _checkIfUserIsHeld,
                      label: const Text("View Map"),
                      icon: const Icon(
                        Icons.map_rounded,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // Report a User Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        enableFeedback: false,
                        backgroundColor:
                            const Color.fromARGB(255, 226, 223, 229),
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 115, 99, 183),
                          width: 4.0,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _navigateToReportUser,
                      label: const Text("Report a User"),
                      icon: const Icon(
                        Icons.report_problem,
                        color: Color.fromARGB(255, 97, 84, 158),
                      ),
                    ),

                    const SizedBox(
                      height: 50,
                    ),

                    // for showing the tutorial dialog
                    GestureDetector(
                      child: Container(
                        height: 50,
                        width: 300,
                        color: Colors.transparent,
                        alignment: AlignmentDirectional.center,
                        child: const Text("How to use this app",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            )),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => const TutorialDialog());
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
