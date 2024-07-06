import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/dialog/privacy_dialog.dart';
import 'package:flutter_button/pages/user/user_loggedin_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  const SizedBox(height: 70),

                  // Image
                  Image.asset(
                    'assets/PO_tag.png',
                    width: 250,
                    height: 250,
                  ),

                  const SizedBox(height: 70),

                  // Text
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: Text(
                      'Login to your Google Account',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Google Sign-In Button
                  FloatingActionButton(
                    child: Image.asset('assets/Google_flutter.png'),
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      await signInWithGoogle(context);
                    },
                  ),

                  const SizedBox(height: 50),

                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            "By creating an account, you are ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  "agreeing to our ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  child: const Text("Privacy Policy",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const PrivacyDialog());
                                  },
                                )
                              ])
                        ]),
                  ),
                ],
              ),
            ),
          ],
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

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Sign out the current user
    await GoogleSignIn().signOut();
    print('User signed out');

    // Sign in with Google
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      print('Google Sign-In was cancelled.');
      return; // The user canceled the sign-in
    }
    print('Google user signed in: ${googleUser.email}');

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    if (googleAuth.accessToken == null && googleAuth.idToken == null) {
      print('Error: accessToken and idToken are both null.');
      return; // Neither token is available, cannot proceed
    }
    print('Google authentication tokens received');

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print('Firebase user signed in with Google credentials');

    User? user = userCredential.user;

    if (user != null) {
      // Store user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'lastSignInTime': user.metadata.lastSignInTime,
      }, SetOptions(merge: true));
      print('User information stored in Firestore');

      // Navigate to UserLoggedInPage upon successful sign-in
      Navigator.push(context, _createRoute(UserLoggedInPage()));
      print('Navigated to UserLoggedInPage');
    } else {
      print('Error: Firebase user is null');
    }

    print('User displayName: ${user?.displayName}');
  } catch (e) {
    print("Error during Google sign-in: $e");
  }
}
