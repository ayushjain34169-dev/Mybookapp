import 'package:flutter/material.dart';

import '../services/book_api.dart';
import 'book_details_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  static const String userId = 'demo_user';

  late Future<List<dynamic>> favouritesFuture;

  @override
  void initState() {
    super.initState();
    favouritesFuture = BookApi.getFavourites(userId);
  }

  void refreshFavourites() {
    setState(() {
      favouritesFuture = BookApi.getFavourites(userId);
    });
  }

  Future<void> removeFavourite(String bookId) async {
    try {
      await BookApi.removeFavourite(userId, bookId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book Favourite se remove ho gayi')),
      );

      refreshFavourites();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Favourite remove nahi hui: $e')));
    }
  }

  String getBookImage(dynamic book) {
    final imagePath = book['coverImage']?.toString() ?? '';

    if (imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    return 'https://mybookapp-3is1.onrender.com$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Favourite Books',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E2C),
          ),
        ),

        actions: [
          IconButton(
            onPressed: refreshFavourites,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: favouritesFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Favourites load nahi hui',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: refreshFavourites,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final favouriteRecords = snapshot.data ?? [];

          final List<dynamic> books = [];

          for (final favourite in favouriteRecords) {
            if (favourite is Map && favourite['bookId'] is Map) {
              books.add(favourite['bookId']);
            }
          }

          if (books.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEF),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'No Favourite Books Yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2C),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Books you add to your favourites\n'
                      'will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Browse Books'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              refreshFavourites();
              await favouritesFuture;
            },

            child: ListView(
              padding: const EdgeInsets.all(16),

              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 15),
                  child: Text(
                    'Your saved books',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),

                ...books.map((book) {
                  final imageUrl = getBookImage(book);

                  final bookId = book['_id']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

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

                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsScreen(book: book),
                          ),
                        );

                        refreshFavourites();
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),

                              child: SizedBox(
                                width: 75,
                                height: 105,

                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
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
                                        color: const Color(0xFFEDEBFF),
                                        child: const Icon(
                                          Icons.menu_book_rounded,
                                          size: 38,
                                          color: Color(0xFF5B4BDB),
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['title']?.toString() ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E2C),
                                    ),
                                  ),

                                  const SizedBox(height: 7),

                                  Text(
                                    book['author']?.toString() ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    '₹${book['price']?.toString() ?? '0'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5B4BDB),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: bookId.isEmpty
                                  ? null
                                  : () {
                                      removeFavourite(bookId);
                                    },

                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 27,
                              ),

                              tooltip: 'Remove Favourite',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
