import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_screen.dart';
import 'favourite_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? profileImage;
  String userName = 'My Book App User';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final savedName = prefs.getString('profile_name');
    final savedEmail = prefs.getString('profile_email');
    final savedImagePath = prefs.getString('profile_image');

    if (!mounted) return;

    setState(() {
      if (savedName != null && savedName.isNotEmpty) {
        userName = savedName;
      }

      if (savedEmail != null) {
        userEmail = savedEmail;
      }

      if (savedImagePath != null &&
          savedImagePath.isNotEmpty &&
          File(savedImagePath).existsSync()) {
        profileImage = File(savedImagePath);
      }
    });
  }

  // =========================
  // OPEN EDIT PROFILE
  // =========================
  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    // Edit Profile se wapas aane par
    // latest photo/name load hoga
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        child: Column(
          children: [
            // =========================
            // PROFILE CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFE9EEF7),
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : null,
                        child: profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 62,
                                color: Colors.grey,
                              )
                            : null,
                      ),

                      Positioned(
                        right: 0,
                        bottom: 2,
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: _openEditProfile,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Welcome',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    userName,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],

                  const SizedBox(height: 4),

                  const Text(
                    'Discover • Read • Enjoy',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // LIBRARY
            // =========================
            _sectionTitle('Library'),

            const SizedBox(height: 10),

            // FAVOURITES
            _profileTile(
              icon: Icons.favorite_border,
              title: 'Favourite Books',
              subtitle: 'View the books you have saved',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavouriteScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            // UPDATE APP
            _profileTile(
              icon: Icons.system_update_outlined,
              title: 'Update App',
              subtitle: 'Check for the latest version of My Book App',
              onTap: () {
                _showMessage(
                  context,
                  'App update will open from Google Play Store.',
                );
              },
            ),

            const SizedBox(height: 24),

            // =========================
            // SETTINGS
            // =========================
            _sectionTitle('Settings'),

            const SizedBox(height: 10),

            _profileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Privacy, security and app information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PROFILE TILE
  // =========================
  static Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================
  static Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // =========================
  // MESSAGE
  // =========================
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
