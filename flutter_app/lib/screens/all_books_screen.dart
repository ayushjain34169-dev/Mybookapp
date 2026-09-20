import 'package:flutter/material.dart';

import '../services/book_api.dart';
import 'book_details_screen.dart';

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({super.key});

  @override
  State<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends State<AllBooksScreen> {
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

  Future<void> changeCategory(
    BuildContext context,
    String bookId,
    String? category,
  ) async {
    try {
      await BookApi.updateBookCategory(bookId, category);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book category updated successfully')),
      );

      refreshBooks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String getCategoryName(dynamic category) {
    switch (category?.toString()) {
      case 'new_release':
        return '🆕 New Release';

      case 'trending':
        return '🔥 Trending';

      default:
        return 'No Category';
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

              final currentCategory = book['category'];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),

                child: ListTile(
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

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Author: ${book['author']?.toString() ?? ''}\n'
                          '₹${book['price']?.toString() ?? '0'}',
                        ),

                        const SizedBox(height: 6),

                        Text(
                          getCategoryName(currentCategory),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),

                    onSelected: (value) {
                      String? selectedCategory;

                      if (value == 'new_release') {
                        selectedCategory = 'new_release';
                      } else if (value == 'trending') {
                        selectedCategory = 'trending';
                      } else if (value == 'none') {
                        selectedCategory = null;
                      }

                      changeCategory(context, bookId, selectedCategory);
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'none',
                        child: Text('No Category'),
                      ),

                      const PopupMenuItem(
                        value: 'new_release',
                        child: Text('🆕 New Release'),
                      ),

                      const PopupMenuItem(
                        value: 'trending',
                        child: Text('🔥 Trending'),
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailsScreen(book: book),
                      ),
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
