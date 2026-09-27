import 'package:flutter/material.dart';

import 'app_permissions_screen.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _infoCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            description:
                'Learn how My Book App uses and stores information '
                'related to your profile and app preferences.',
            onTap: () {
              _showPrivacyDialog(context);
            },
          ),

          const SizedBox(height: 14),

          _infoCard(
            icon: Icons.camera_alt_outlined,
            title: 'App Permissions',
            description:
                'Manage camera and photo permissions used by '
                'My Book App for profile photo features.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppPermissionsScreen()),
              );
            },
          ),

          const SizedBox(height: 14),

          _infoCard(
            icon: Icons.storage_outlined,
            title: 'Data & Storage',
            description:
                'View information about locally stored profile '
                'data and app preferences.',
            onTap: () {
              _showStorageDialog(context);
            },
          ),

          const SizedBox(height: 24),

          _securityCard(
            onTap: () {
              _showSecurityDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.black87),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securityCard({required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.green),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 7),

                    Text(
                      'View important information about privacy '
                      'and safe use of My Book App.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.privacy_tip_outlined, color: Colors.black87),
              SizedBox(width: 10),
              Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'My Book App uses information only for features '
              'provided inside the application.\n\n'
              'Profile name and email can be stored locally on '
              'your device for displaying your profile.\n\n'
              'Your selected profile photo is stored locally '
              'on your device.\n\n'
              'Favourite books are managed through the app '
              'service so that your saved books can be displayed.\n\n'
              'You can manage camera and photo permissions '
              'from the App Permissions section.',
              style: TextStyle(height: 1.5, fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.storage_outlined, color: Colors.black87),
              SizedBox(width: 10),
              Text(
                'Data & Storage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'My Book App can store profile information and '
            'app preferences locally on your device.\n\n'
            'Profile name, email and profile photo are used '
            'to display your profile inside the app.\n\n'
            'Favourite books are handled through the app '
            'service.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.green),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your Privacy Matters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Keep your device protected and review app '
            'permissions regularly.\n\n'
            'My Book App requests camera and photo access '
            'only when those features are used.\n\n'
            'You can change permissions at any time from '
            'your device App Settings.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
