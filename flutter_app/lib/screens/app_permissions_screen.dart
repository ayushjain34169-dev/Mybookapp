import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionsScreen extends StatefulWidget {
  const AppPermissionsScreen({super.key});

  @override
  State<AppPermissionsScreen> createState() => _AppPermissionsScreenState();
}

class _AppPermissionsScreenState extends State<AppPermissionsScreen> {
  PermissionStatus cameraStatus = PermissionStatus.denied;
  PermissionStatus photosStatus = PermissionStatus.denied;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final camera = await Permission.camera.status;
    final photos = await Permission.photos.status;

    if (!mounted) return;

    setState(() {
      cameraStatus = camera;
      photosStatus = photos;
      loading = false;
    });
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();

    if (!mounted) return;

    setState(() {
      cameraStatus = status;
    });

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        'Camera Permission',
        'Camera permission permanently denied hai. '
            'App Settings se permission allow kar sakte ho.',
      );
    }
  }

  Future<void> _requestPhotos() async {
    final status = await Permission.photos.request();

    if (!mounted) return;

    setState(() {
      photosStatus = status;
    });

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        'Photos Permission',
        'Photos permission permanently denied hai. '
            'App Settings se permission allow kar sakte ho.',
      );
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  void _showSettingsDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: const TextStyle(height: 1.5)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  String _statusText(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return 'Allowed';
    }

    if (status.isPermanentlyDenied) {
      return 'Blocked';
    }

    return 'Not Allowed';
  }

  IconData _statusIcon(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return Icons.check_circle;
    }

    if (status.isPermanentlyDenied) {
      return Icons.block;
    }

    return Icons.info_outline;
  }

  Color _statusColor(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return Colors.green;
    }

    if (status.isPermanentlyDenied) {
      return Colors.redAccent;
    }

    return Colors.orange;
  }

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
          'App Permissions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.security_outlined,
                        size: 32,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Permissions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'My Book App uses permissions only when '
                              'you choose features that require them, '
                              'such as taking or selecting a profile photo.',
                              style: TextStyle(
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
                ),

                const SizedBox(height: 22),

                const Text(
                  'Permissions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _permissionTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  description: 'Used when you choose to take a profile photo.',
                  status: cameraStatus,
                  onTap: _requestCamera,
                ),

                const SizedBox(height: 12),

                _permissionTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Photos',
                  description:
                      'Used when you choose a profile photo from your gallery.',
                  status: photosStatus,
                  onTap: _requestPhotos,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text(
                      'Open App Settings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String description,
    required PermissionStatus status,
    required VoidCallback onTap,
  }) {
    final color = _statusColor(status);

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),

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

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(_statusIcon(status), size: 16, color: color),
                const SizedBox(width: 5),
                Text(
                  _statusText(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
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
}
