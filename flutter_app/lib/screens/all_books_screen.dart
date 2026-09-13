import 'package:flutter/material.dart';

import '../services/book_api.dart';
import 'book_details_screen.dart';

class AllBooksScreen extends StatelessWidget {
  const AllBooksScreen({super.key});

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
        future: BookApi.getBooks(),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Books load nahi hui\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final books = snapshot.data ?? [];

          // No books
          if (books.isEmpty) {
            return const Center(
              child: Text('No books found', style: TextStyle(fontSize: 18)),
            );
          }

          // Books list
          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: books.length,

            itemBuilder: (context, index) {
              final book = books[index];

              final imagePath = book['coverImage'] ?? '';

              return Card(
                elevation: 4,

                margin: const EdgeInsets.only(bottom: 15),

                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),

                  // Book Cover
                  leading: SizedBox(
                    width: 65,
                    height: 85,

                    child: imagePath.isNotEmpty
                        ? Image.network(
                            'http://localhost:3000$imagePath',
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.book, size: 50);
                            },
                          )
                        : const Icon(Icons.book, size: 50),
                  ),

                  // Book Title
                  title: Text(
                    book['title'] ?? '',

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  // Author + Price
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),

                    child: Text(
                      'Author: ${book['author'] ?? ''}\n'
                      '₹${book['price'] ?? 0}',
                    ),
                  ),

                  // Only Details Arrow
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                  // Open Book Details
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
