import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';

class CustomDrawerPage extends StatelessWidget {
  const CustomDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<MyProfileController>();

    return Drawer(
      child: Obx(() {
        final user = profileController.userModel.value;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with user info
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEBC894), Color(0xFFB49EF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.image != null && user!.image!.isNotEmpty
                    ? NetworkImage(user.image!) as ImageProvider
                    : const AssetImage('assets/images/profile.jpg'),
                child: user?.image == null || user!.image!.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              accountName: Text(
                user?.name ?? "User",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(user?.email ?? "email@example.com"),
            ),

            // Menu Items
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.blue),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.blue),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
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
        );
      }),
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
