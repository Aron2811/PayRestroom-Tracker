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
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) {
          return WillPopScope(
            onWillPop: () async =>
                false, // Prevent back button from closing the dialog
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
                    const SizedBox(height: 20),

                    Text(
                      'Note: If you want to get unbanned, pay 50 pesos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Pure white text
                      ),
                    ),

                     const SizedBox(height: 10),

                    // Clickable text with an icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white, // Pure white icon
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: GestureDetector(
                            onTap:
                                _showPaymentDialog, // Open the payment dialog
                            child: const Text(
                              'Click here to get Unban',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Pure white text
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
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
  }

// Payment dialog method
  void _showPaymentDialog() {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  const Icon(Icons.payment,
                      color: Colors.greenAccent, size: 60),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter amount to pay',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                   const Text(
                    '(50 pesos required)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter amount',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: () {
                      double amount =
                          double.tryParse(amountController.text) ?? 0;
                      _handlePayment(amount);
                    },
                    child: const Text('Pay Now', style: TextStyle(color: Colors.black),),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
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

  void _handlePayment(double amount) async {
    if (amount < 50) {
      double needed = 50 - amount;
      _showMessageDialog(
          'Insufficient amount. You need ${needed.toStringAsFixed(2)} more pesos.');
    } else {
      // Show message if overpaid
      if (amount > 50) {
        _showMessageDialog(
            'Only 50 pesos required. You paid ${amount.toStringAsFixed(2)}.');
      } else {
        _showMessageDialog('Payment of 50 pesos successful.');
      }

      // Record payment only if the amount is exactly 50 pesos
      if (amount == 50) {
        // Remove ban status from Firestore
        await _unbanUser();

        // Dismiss the current payment dialog and show the "Thank you" message
        Navigator.of(context).pop(); // Close the payment dialog
        _showThankYouDialog();

        // Record payment in Firestore (always 50 pesos)
        await _recordPaymentInFirestore(50); // Only record 50 pesos
      }
    }
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: const Color.fromARGB(
                255, 132, 119, 197), // Matching background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  20), // Rounded corners for a consistent look
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payment,
                      color: Colors.greenAccent, size: 60), // Payment icon
                  const SizedBox(height: 20),
                  Text(
                    message, // Custom message text
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close dialog on button press
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _recordPaymentInFirestore(double amount) async {
    if (user == null) return;

    // Only record the exact 50 pesos amount
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    await userDocRef.update({
      'paymentHistory': FieldValue.arrayUnion([
        {
          'amount':
              50, // Always record 50 pesos, regardless of how much was paid
          'date': Timestamp.now(),
          'status': 'Paid',
        }
      ])
    }).then((_) {
      print('Payment recorded successfully');
    }).catchError((error) {
      print('Error recording payment: $error');
    });
  }

  Future<void> _unbanUser() async {
    if (user == null) return;

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    // Remove the ban status from Firestore
    await userDocRef.update({
      'isBanned': false, //controls the ban status
    }).then((_) {
      print('User unbanned successfully');
    }).catchError((error) {
      print('Error unbanning user: $error');
    });
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  const Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 60),
                  const SizedBox(height: 20),
                  const Text(
                    'Thank you, you are unbanned now. Be good to others!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: () {
                      // Close the dialog and navigate to the LoggedInPage
                      Navigator.of(context)
                          .pop(); // Close the "Thank you" dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserLoggedInPage()), // Navigate to LoggedInPage
                      );
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
