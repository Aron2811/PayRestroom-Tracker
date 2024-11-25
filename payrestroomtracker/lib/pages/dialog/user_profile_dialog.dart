import 'package:flutter/material.dart';

class UserProfileDrawer extends StatefulWidget {
  @override
  _UserProfileDrawerState createState() => _UserProfileDrawerState();
}

class _UserProfileDrawerState extends State<UserProfileDrawer> {
  bool _isDrawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Drawer Example'),
        leading: IconButton(
          icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu),
          onPressed: _toggleDrawer,
        ),
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: const Text('Main Content'),
          ),
          // Sliding Drawer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 0 : -screenWidth * 0.7,
            top: 0,
            bottom: 0,
            child: Container(
              width: screenWidth * 0.7,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blueAccent,
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 30),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'User Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    onTap: () {
                      // Handle edit profile
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      // Handle settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      // Handle logout
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleDrawer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
