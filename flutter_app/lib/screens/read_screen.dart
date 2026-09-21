import 'package:flutter/material.dart';

import '../services/book_api.dart';
import 'pdf_reader_screen.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReadBooks();
  }

  Future<void> loadReadBooks() async {
    try {
      final allBooks = await BookApi.getBooks();

      final readBooks = allBooks.where((book) {
        return book['appBookEnabled'] == true;
      }).toList();

      if (!mounted) return;

      setState(() {
        books = readBooks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void openBook(dynamic book) {
    final String pdfUrl = book['pdfUrl']?.toString().trim() ?? '';

    final bool isFree = book['isFree'] == true;

    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Is book ki PDF available nahi hai')),
      );
      return;
    }

    if (!isFree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ye paid book hai. Payment required.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfReaderScreen(
          pdfUrl: pdfUrl,
          title: book['title']?.toString() ?? 'Read Book',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Read Books',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
          ? const Center(
              child: Text(
                'No books available to read',
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                final bool isFree = book['isFree'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),

                      child: Image.network(
                        book['coverImage']?.toString() ?? '',
                        width: 55,
                        height: 75,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 55,
                            height: 75,
                            child: Icon(Icons.menu_book, size: 35),
                          );
                        },
                      ),
                    ),

                    title: Text(
                      book['title']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(isFree ? 'FREE • Read Now' : 'Paid Book'),

                    trailing: const Icon(Icons.menu_book, size: 25),

                    onTap: () {
                      openBook(book);
                    },
                  ),
                );
              },
            ),
    );
  }
}
