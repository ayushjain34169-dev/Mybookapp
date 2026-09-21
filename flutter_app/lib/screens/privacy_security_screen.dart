import 'package:flutter/material.dart';

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
            icon: Icons.security_outlined,
            title: 'Account Security',
            description:
                'Your account information should be kept secure. '
                'Always use a strong password and avoid sharing your '
                'login details with anyone.',
          ),

          const SizedBox(height: 14),

          _infoCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            description:
                'Your personal information is used to provide and '
                'improve the features of My Book App. We aim to keep '
                'your information secure and private.',
          ),

          const SizedBox(height: 14),

          _infoCard(
            icon: Icons.lock_outline,
            title: 'Password & Login',
            description:
                'Keep your login credentials private. If you believe '
                'your account has been accessed by someone else, '
                'secure your account as soon as possible.',
          ),

          const SizedBox(height: 24),

          _deleteAccountCard(context),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        ],
      ),
    );
  }

  Widget _deleteAccountCard(BuildContext context) {
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
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.redAccent),
        ),

        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),

        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Permanently remove your account',
            style: TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),

        onTap: () {
          _showDeleteDialog(context);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: const Text(
            'Account deletion will permanently remove your '
            'account and associated information. This action '
            'cannot be undone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion will be connected here.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
