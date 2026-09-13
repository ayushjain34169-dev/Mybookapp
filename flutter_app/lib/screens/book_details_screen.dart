import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailsScreen extends StatelessWidget {
  final dynamic book;

  const BookDetailsScreen({super.key, required this.book});

  static const String baseUrl = 'http://localhost:3000';

  void openImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(15),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String frontImage = '$baseUrl/uploads/book_cover.jpg';

    final String backImage = '$baseUrl/uploads/book_back.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          'Book Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                GestureDetector(
                  onTap: () {
                    openImage(context, frontImage);
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),

                    child: SizedBox(
                      width: 120,
                      height: 185,

                      child: Image.network(
                        frontImage,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFEDEBFF),

                            child: const Icon(
                              Icons.menu_book,
                              size: 60,
                              color: Color(0xFF5B4BDB),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                GestureDetector(
                  onTap: () {
                    openImage(context, backImage);
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),

                    child: SizedBox(
                      width: 120,
                      height: 185,

                      child: Image.network(
                        backImage,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white,

                            child: const Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              book['title'] ?? '',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              'Author: ${book['author'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 12),

            Text(
              '₹${book['price'] ?? 0}',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B4BDB),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Description',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              book['description'] ?? 'No description available',

              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri amazonUrl = Uri.parse('https://amzn.in/d/0dnHQtdj');

                  if (await canLaunchUrl(amazonUrl)) {
                    await launchUrl(
                      amazonUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Amazon link open nahi ho rahi'),
                        ),
                      );
                    }
                  }
                },

                icon: const Icon(Icons.shopping_cart_outlined),

                label: const Text('Buy Book', style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
