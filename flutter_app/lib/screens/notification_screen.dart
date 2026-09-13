import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const String baseUrl = 'http://localhost:3000';

  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/notifications'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          notifications = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Notification Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await http.put(Uri.parse('$baseUrl/api/notifications/$id/read'));

      await loadNotifications();
    } catch (e) {
      debugPrint('Mark Read Error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await http.put(Uri.parse('$baseUrl/api/notifications/read-all'));

      await loadNotifications();
    } catch (e) {
      debugPrint('Read All Error: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await http.delete(Uri.parse('$baseUrl/api/notifications'));

      await loadNotifications();
    } catch (e) {
      debugPrint('Clear Error: $e');
    }
  }

  String formatDate(String? date) {
    if (date == null) return '';

    try {
      final d = DateTime.parse(date).toLocal();

      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}  '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  IconData getIcon(String type) {
    if (type == 'new_book') {
      return Icons.menu_book_rounded;
    }

    if (type == 'offer') {
      return Icons.local_offer_rounded;
    }

    return Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = notifications
        .where((n) => n['isRead'] == false)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E2C),
          ),
        ),

        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF5B4BDB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (notifications.isNotEmpty)
            IconButton(
              onPressed: clearAll,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? RefreshIndicator(
              onRefresh: loadNotifications,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),

                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: Color(0xFF5B4BDB),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "You're all caught up 🎉",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'No new notifications',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadNotifications,

              child: ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: notifications.length,

                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  final bool isRead = notification['isRead'] == true;

                  final String id = notification['_id'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFF0EEFF),

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(
                        color: isRead
                            ? Colors.transparent
                            : const Color(0xFFDDD8FF),
                      ),
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),

                      onTap: () {
                        if (!isRead && id.isNotEmpty) {
                          markAsRead(id);
                        }
                      },

                      leading: Stack(
                        clipBehavior: Clip.none,

                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFEDEBFF),

                            child: Icon(
                              getIcon(notification['type'] ?? 'general'),

                              color: const Color(0xFF5B4BDB),
                            ),
                          ),

                          if (!isRead)
                            Positioned(
                              right: -2,
                              top: -2,

                              child: Container(
                                width: 12,
                                height: 12,

                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),

                      title: Text(
                        notification['title'] ?? '',

                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const SizedBox(height: 5),

                          Text(notification['message'] ?? ''),

                          const SizedBox(height: 6),

                          Text(
                            formatDate(notification['createdAt']),

                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
