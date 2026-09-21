import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/book_api.dart';
import 'all_books_screen.dart';
import 'book_details_screen.dart';
import 'notification_screen.dart';
import 'favourite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String baseUrl = 'https://mybookapp-3is1.onrender.com';

  static const String userId = 'demo_user';

  List<dynamic> books = [];

  List<dynamic> favouriteBooks = [];

  bool isLoading = true;

  bool isFavouriteLoading = true;

  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();

    loadBooks();
    loadFavourites();
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
  // LOAD FAVOURITES FROM MONGODB
  // =====================================

  Future<void> loadFavourites() async {
    try {
      final favourites = await BookApi.getFavourites(userId);

      if (!mounted) return;

      final List<dynamic> loadedFavouriteBooks = [];

      for (final favourite in favourites) {
        if (favourite is Map &&
            favourite['bookId'] != null &&
            favourite['bookId'] is Map) {
          loadedFavouriteBooks.add(favourite['bookId']);
        }
      }

      setState(() {
        favouriteBooks = loadedFavouriteBooks.take(3).toList();

        isFavouriteLoading = false;
      });
    } catch (e) {
      debugPrint('Favourites Error: $e');

      if (!mounted) return;

      setState(() {
        favouriteBooks = [];
        isFavouriteLoading = false;
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
  // OPEN ALL BOOKS
  // =====================================

  void openAllBooks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllBooksScreen()),
    );
  }

  // =====================================
  // BOOK IMAGE
  // =====================================

  String getBookImage(dynamic book) {
    final image = book['coverImage'];

    debugPrint('BOOK IMAGE FROM API: $image');

    if (image == null || image.toString().isEmpty) {
      return '';
    }

    final imageString = image.toString();

    if (imageString.startsWith('http')) {
      return imageString;
    }

    return '$baseUrl$imageString';
  }

  // =====================================
  // OPEN BOOK DETAILS
  // =====================================

  void openBookDetails(dynamic book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)),
    );
  }

  // =====================================
  // BOOK CARD
  // =====================================

  Widget buildBookCard(dynamic book) {
    final String imageUrl = getBookImage(book);

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          openBookDetails(book);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 175,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 175,
                            color: const Color(0xFFEDEBFF),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 50,
                              color: Color(0xFF5B4BDB),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 175,
                        color: const Color(0xFFEDEBFF),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 50,
                          color: Color(0xFF5B4BDB),
                        ),
                      ),
              ),

              const SizedBox(height: 10),

              Text(
                book['title']?.toString() ?? 'Untitled Book',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2C),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                book['author']?.toString() ?? 'Unknown Author',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '₹${book['price'] ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFF5B4BDB),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // =====================================
  // BOOK SECTION
  // =====================================

  Widget buildBookSection({
    required String title,
    required String icon,
    required List<dynamic> sectionBooks,
    VoidCallback? onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),

                const SizedBox(width: 7),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2C),
                  ),
                ),
              ],
            ),

            TextButton(
              onPressed: onViewAll ?? openAllBooks,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF5B4BDB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sectionBooks.length,
            itemBuilder: (context, index) {
              return buildBookCard(sectionBooks[index]);
            },
          ),
        ),
      ],
    );
  }

  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {
    // =====================================
    // NEW RELEASE BOOKS
    // =====================================

    final newReleaseBooks = books
        .where(
          (book) => book['category']?.toString().toLowerCase() == 'new_release',
        )
        .take(3)
        .toList();

    // =====================================
    // TRENDING BOOKS
    // =====================================

    final trendingBooks = books
        .where(
          (book) => book['category']?.toString().toLowerCase() == 'trending',
        )
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      // =====================================
      // APP BAR
      // =====================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        // LEFT SIDE - APP NAME
        title: const Text(
          'AJ Reads',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B4BDB),
            letterSpacing: 0.3,
          ),
        ),

        // RIGHT SIDE - NOTIFICATION
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
      // =====================================
      // BODY
      // =====================================
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            loadBooks(),
            loadFavourites(),
            loadUnreadNotificationCount(),
          ]);
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
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.20),
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
                            color: Colors.white.withValues(alpha: 0.90),
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
            // LOADING
            // =====================================
            if (isLoading)
              const SizedBox(
                height: 300,
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
            // BOOK SECTIONS
            // =====================================
            else ...[
              // ⭐ FAVOURITE BOOKS

              if (isFavouriteLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF5B4BDB)),
                  ),
                )
              else if (favouriteBooks.isNotEmpty) ...[
                buildBookSection(
                  title: 'Favourite Books',
                  icon: '❤️',
                  sectionBooks: favouriteBooks,
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavouriteScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),
              ],

              // 🆕 NEW RELEASES
              if (newReleaseBooks.isNotEmpty) ...[
                buildBookSection(
                  title: 'New Releases',
                  icon: '🆕',
                  sectionBooks: newReleaseBooks,
                ),

                const SizedBox(height: 22),
              ],

              // 🔥 TRENDING BOOKS
              if (trendingBooks.isNotEmpty) ...[
                buildBookSection(
                  title: 'Trending Books',
                  icon: '🔥',
                  sectionBooks: trendingBooks,
                ),
              ],

              // =====================================
              // NO CATEGORIZED BOOKS
              // =====================================
              if (favouriteBooks.isEmpty &&
                  newReleaseBooks.isEmpty &&
                  trendingBooks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 55,
                        color: Color(0xFF5B4BDB),
                      ),

                      SizedBox(height: 12),

                      Text(
                        'No categorized books available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'Add a book or mark a book as Favourite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),

            // =====================================
            // APP INFORMATION CARD
            // =====================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
          ],
        ),
      ),
    );
  }
}
