import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'book_details_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String baseUrl = 'http://localhost:3000';

  List<dynamic> books = [];

  bool isLoading = true;

  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();

    loadBooks();
    loadUnreadNotificationCount();
  }

  // =====================================
  // LOAD BOOKS
  // =====================================

  Future<void> loadBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          books = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Books Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =====================================
  // LOAD UNREAD NOTIFICATION COUNT
  // =====================================

  Future<void> loadUnreadNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/unread-count'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          unreadNotificationCount = data['count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Unread Notification Error: $e');
    }
  }

  // =====================================
  // OPEN NOTIFICATIONS
  // =====================================

  Future<void> openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );

    loadUnreadNotificationCount();
  }

  // =====================================
  // BOOK IMAGE
  // =====================================

  String getBookImage(dynamic book) {
    final image = book['coverImage'];

    if (image == null || image.toString().isEmpty) {
      return '';
    }

    if (image.toString().startsWith('http')) {
      return image.toString();
    }

    return '$baseUrl${image.toString()}';
  }
  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: openNotifications,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF5B4BDB),
                  size: 27,
                ),
              ),

              if (unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadNotificationCount > 9
                            ? '9+'
                            : unreadNotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await loadBooks();
          await loadUnreadNotificationCount();
        },

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),

          children: [
            // =====================================
            // WELCOME BANNER
            // =====================================

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.20),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Welcome 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Discover books that inspire, inform and entertain.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.90),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================================
            // FEATURED BOOKS TITLE
            // =====================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Featured Books',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2C),
                  ),
                ),

                TextButton(
                  onPressed: () {},

                  child: const Text(
                    'Explore',
                    style: TextStyle(
                      color: Color(0xFF5B4BDB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================
            // BOOK LOADING
            // =====================================
            if (isLoading)
              const SizedBox(
                height: 220,

                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF5B4BDB)),
                ),
              )
            // =====================================
            // NO BOOKS
            // =====================================
            else if (books.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Column(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 55,
                      color: Color(0xFF5B4BDB),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'No books available',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            // =====================================
            // BOOK LIST
            // =====================================
            else
              ...books.map((book) {
                final String imageUrl = getBookImage(book);

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsScreen(book: book),
                        ),
                      );
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // =====================================
                          // BOOK IMAGE
                          // =====================================

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),

                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,

                                    width: 90,
                                    height: 135,

                                    fit: BoxFit.cover,

                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 90,
                                        height: 135,
                                        color: const Color(0xFFEDEBFF),
                                        child: const Icon(
                                          Icons.menu_book_rounded,
                                          size: 38,
                                          color: Color(0xFF5B4BDB),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 90,
                                    height: 135,
                                    color: const Color(0xFFEDEBFF),
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      size: 38,
                                      color: Color(0xFF5B4BDB),
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 14),

                          // =====================================
                          // BOOK INFORMATION
                          // =====================================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  book['title'] ?? 'Untitled Book',

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1E2C),
                                  ),
                                ),

                                const SizedBox(height: 7),

                                Text(
                                  book['author'] ?? 'Unknown Author',

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  book['description'] ?? '',

                                  maxLines: 3,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),

                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0EEFF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),

                                      child: Text(
                                        '₹${book['price'] ?? 0}',

                                        style: const TextStyle(
                                          color: Color(0xFF5B4BDB),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Color(0xFF5B4BDB),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            // =====================================
            // APP INFORMATION CARD
            // =====================================

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFF),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFF5B4BDB),
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'AJ Reads',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E2C),
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Explore books and discover your next favourite read.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // =====================================
            // AUTHOR / APP INFO
            // =====================================
          ],
        ),
      ),
    );
  }
}
