import 'package:flutter/material.dart';

import '../services/book_api.dart';
import 'book_details_screen.dart';

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({super.key});

  @override
  State<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends State<AllBooksScreen> {
  static const String userId = 'demo_user';

  late Future<List<dynamic>> booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = BookApi.getBooks();
  }

  void refreshBooks() {
    setState(() {
      booksFuture = BookApi.getBooks();
    });
  }

  Future<bool> checkFavourite(String bookId) async {
    if (bookId.isEmpty) return false;

    try {
      return await BookApi.checkFavourite(userId, bookId);
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleFavourite(
    BuildContext context,
    String bookId,
    bool isFavourite,
  ) async {
    if (bookId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Book ID nahi mila')));
      return;
    }

    try {
      if (isFavourite) {
        await BookApi.removeFavourite(userId, bookId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book Favourite se remove ho gayi')),
        );
      } else {
        await BookApi.addFavourite(userId, bookId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book Favourite mein add ho gayi ❤️')),
        );
      }

      refreshBooks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Favourite update nahi hui: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Books',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: booksFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Books load nahi hui\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text('No books found', style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,

            itemBuilder: (context, index) {
              final book = books[index];

              final imagePath = book['coverImage']?.toString() ?? '';

              String imageUrl = '';

              if (imagePath.isNotEmpty) {
                if (imagePath.startsWith('http')) {
                  imageUrl = imagePath;
                } else {
                  imageUrl = 'https://mybookapp-3is1.onrender.com$imagePath';
                }
              }

              final bookId = book['_id']?.toString() ?? '';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),

                child: FutureBuilder<bool>(
                  future: checkFavourite(bookId),

                  builder: (context, favouriteSnapshot) {
                    final isFavourite = favouriteSnapshot.data ?? false;

                    return ListTile(
                      contentPadding: const EdgeInsets.all(10),

                      leading: SizedBox(
                        width: 65,
                        height: 85,

                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.book, size: 50);
                                },
                              )
                            : const Icon(Icons.book, size: 50),
                      ),

                      title: Text(
                        book['title']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),

                        child: Text(
                          'Author: ${book['author']?.toString() ?? ''}\n'
                          '₹${book['price']?.toString() ?? '0'}',
                        ),
                      ),

                      trailing: IconButton(
                        onPressed:
                            favouriteSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? null
                            : () {
                                toggleFavourite(context, bookId, isFavourite);
                              },

                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          color: isFavourite ? Colors.red : Colors.grey,
                          size: 28,
                        ),

                        tooltip: isFavourite
                            ? 'Remove Favourite'
                            : 'Add Favourite',
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsScreen(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
