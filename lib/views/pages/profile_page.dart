import 'package:flutter/material.dart';
import 'package:flutterassignment/app/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterassignment/views/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const ProfilePage({super.key, required this.toggleTheme});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  String? _userEmail;
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final user = authServices.value.currentUser; // Firebase user
      setState(() {
        _userName = user?.displayName ?? "Guest User";
        _userEmail = user?.email ?? "No email available";
        _profilePicUrl = user?.photoURL;
      });
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close popup
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close popup
              _logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await authServices.value.signOut(); // Firebase sign out
    print("User logged out!");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(toggleTheme: widget.toggleTheme),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Profile Section
          Center(
            child: Column(
              children: [
CircleAvatar(
  radius: 50,
  child: _profilePicUrl == null
      ? const Icon(Icons.person, size: 50, color: Colors.white)
      : null,
  backgroundImage: _profilePicUrl != null
      ? NetworkImage(_profilePicUrl!)
      : null,
  backgroundColor: Colors.orange,
),
                const SizedBox(height: 12),
                Text(
                  _userName ?? "Loading...",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Divider(),

          // About App
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text('About App'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Work Tracker',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 Work Tracker App',
              );
            },
          ),

          // Terms & Conditions
          ListTile(
            leading: Icon(
              Icons.description,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text('Terms and Conditions'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Terms and Conditions'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Here would be your app\'s terms and conditions...\n\n'
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Nullam auctor, nisl eget ultricies tincidunt, nisl nisl '
                      'aliquam nisl, eget ultricies nisl nisl eget nisl.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}