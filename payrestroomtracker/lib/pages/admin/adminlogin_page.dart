import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/pages/admin/adminpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key, required this.report}) : super(key: key);
  final String report;

  @override
  State<StatefulWidget> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  var _isObscured;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _usernameError = '';
  String _passwordError = '';
  bool _isLoading = false; // For handling loading
  bool _isCheckingLoginStatus = true; // For checking login status

  @override
  void initState() {
    super.initState();
    _isObscured = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  //method for login
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Start showing loading indicator
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return Center();
      },
    );
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    bool usernameValid = false;
    bool passwordValid = false;

    try {
      // Check if username exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var adminDoc = querySnapshot.docs.first;
        var storedPassword = adminDoc['password'];

        if (storedPassword == password) {
          await _saveLoginDetails(username, password);
          Navigator.of(context).pop(); // Close the loading dialog
          Navigator.pushReplacement(
            context,
            _createRoute(AdminPage(
              username: username,
              report: widget.report,
            )),
          );
        } else {
          passwordValid = false;
          Navigator.of(context).pop(); // Close the loading dialog
        }
        usernameValid = true;
      } else {
        usernameValid = false;
        Navigator.of(context).pop(); // Close the loading dialog
      }
    } catch (e) {
      debugPrint('Error: $e');
      Navigator.of(context).pop(); // Close the loading dialog
    }

    // Update UI to show errors
    setState(() {
      _usernameError = usernameValid ? '' : 'Username not found';
      _passwordError = passwordValid ? '' : 'Incorrect password';
      _isLoading = false; // Stop loading indicator
    });
  }

  //method for saving the login details
  Future<void> _saveLoginDetails(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  //method for checking the login status
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('admin')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var adminDoc = querySnapshot.docs.first;
          var storedPassword = adminDoc['password'];

          if (storedPassword == password) {
            Navigator.of(context).pushReplacement(
              _createRoute(AdminPage(
                username: username,
                report: widget.report,
              )),
            );
            return; // Exit the method if user is logged in
          }
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    }

    // If not logged in, set this flag to false
    setState(() {
      _isCheckingLoginStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 115, 99, 183),
        body: _isCheckingLoginStatus
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Please wait...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          "Please wait...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          Image.asset('assets/PO_tag.png',
                              width: 200, height: 200),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 20.0),
                            child: Text(
                              'Login as Admin',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Username Field
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_2_rounded,
                                    color: Color.fromARGB(255, 211, 203, 252)),
                                labelText: 'Username',
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelStyle: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                                fillColor:
                                    const Color.fromARGB(255, 115, 99, 183),
                                filled: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 5.0),
                            child: Text(
                              _usernameError,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 236, 154, 148)),
                            ),
                          ),
                          // Password Field
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _isObscured,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color.fromARGB(255, 211, 203, 252)),
                                suffixIcon: IconButton(
                                  icon: _isObscured
                                      ? const Icon(Icons.visibility_off_rounded)
                                      : const Icon(Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isObscured = !_isObscured;
                                    });
                                  },
                                ),
                                labelText: 'Password',
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelStyle: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                                fillColor:
                                    const Color.fromARGB(255, 115, 99, 183),
                                filled: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 5.0),
                            child: Text(
                              _passwordError,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 236, 154, 148)),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(315, 60),
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
                            onPressed: _login,
                            child: const Text("Login"),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Route _createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) =>
          child,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
