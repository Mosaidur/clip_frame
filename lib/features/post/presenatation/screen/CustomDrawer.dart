import 'package:flutter/material.dart';

class CustomDrawerPage extends StatelessWidget {
  const CustomDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with user info
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEBC894),
                  Color(0xFFB49EF4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            accountName: const Text(
              "John Doe",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("john.doe@example.com"),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.blue),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              // Example navigation:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.blue),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              // Example navigation:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text("About"),
            onTap: () {
              Navigator.pop(context);
              // Example navigation:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your logout logic here
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
