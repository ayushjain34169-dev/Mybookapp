import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/book_api.dart';

class BookDetailsScreen extends StatefulWidget {
  final dynamic book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  // Temporary user ID
  // Login system banne ke baad actual user ID yahan use hogi.
  static const String userId = 'demo_user';

  bool isFavourite = false;
  bool isFavouriteLoading = true;

  @override
  void initState() {
    super.initState();
    checkFavouriteStatus();
  }

  // CHECK FAVOURITE
  Future<void> checkFavouriteStatus() async {
    final String bookId = widget.book['_id']?.toString() ?? '';

    if (bookId.isEmpty) {
      setState(() {
        isFavouriteLoading = false;
      });
      return;
    }

    try {
      final result = await BookApi.checkFavourite(userId, bookId);

      if (!mounted) return;

      setState(() {
        isFavourite = result;
        isFavouriteLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isFavouriteLoading = false;
      });
    }
  }

  // ADD / REMOVE FAVOURITE
  Future<void> toggleFavourite() async {
    final String bookId = widget.book['_id']?.toString() ?? '';

    if (bookId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Book ID nahi mila')));
      return;
    }

    try {
      if (isFavourite) {
        await BookApi.removeFavourite(userId, bookId);

        if (!mounted) return;

        setState(() {
          isFavourite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book Favourite se remove ho gayi')),
        );
      } else {
        await BookApi.addFavourite(userId, bookId);

        if (!mounted) return;

        setState(() {
          isFavourite = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book Favourite mein add ho gayi ❤️')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Favourite update nahi hui: $e')));
    }
  }

  void openImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;

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

  Widget buildBookImage(
    BuildContext context,
    String imageUrl, {
    bool isBack = false,
  }) {
    return GestureDetector(
      onTap: () {
        openImage(context, imageUrl);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 120,
          height: 185,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isBack ? Colors.white : const Color(0xFFEDEBFF),
                      child: Icon(
                        isBack ? Icons.image_outlined : Icons.menu_book,
                        size: 60,
                        color: isBack ? Colors.grey : const Color(0xFF5B4BDB),
                      ),
                    );
                  },
                )
              : Container(
                  color: const Color(0xFFEDEBFF),
                  child: const Icon(
                    Icons.menu_book,
                    size: 60,
                    color: Color(0xFF5B4BDB),
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildAuthorSection() {
    final authorDetails =
        widget.book['authorDetails'] as Map<String, dynamic>? ?? {};

    final String authorName =
        authorDetails['name']?.toString().isNotEmpty == true
        ? authorDetails['name'].toString()
        : widget.book['author']?.toString() ?? 'Author';

    final String education = authorDetails['education']?.toString() ?? '';

    final String bio = authorDetails['bio']?.toString() ?? '';

    final String image = authorDetails['image']?.toString() ?? '';

    final String email = authorDetails['email']?.toString() ?? '';

    final String phone = authorDetails['phone']?.toString() ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (image.isNotEmpty)
              ClipOval(
                child: Image.network(
                  image,
                  width: 125,
                  height: 125,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 75);
                  },
                ),
              )
            else
              const Icon(Icons.person, size: 75),

            const SizedBox(height: 15),

            Text(
              authorName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            if (education.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined, size: 20),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      education,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About the Author',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                bio.isNotEmpty ? bio : 'No biography available.',
                style: const TextStyle(fontSize: 15.5, height: 1.6),
              ),
            ),

            if (email.isNotEmpty) ...[
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final emailUri = Uri(scheme: 'mailto', path: email);

                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(email, style: const TextStyle(fontSize: 15)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 15),
                  ],
                ),
              ),
            ],

            if (phone.isNotEmpty) ...[
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  final phoneUri = Uri(scheme: 'tel', path: phone);

                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(phone, style: const TextStyle(fontSize: 15)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 15),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String frontImage = widget.book['frontImage']?.toString() ?? '';

    final String backImage = widget.book['backImage']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FA),

      appBar: AppBar(
        title: const Text(
          'Book Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // ❤️ Favourite button
        actions: [
          isFavouriteLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: toggleFavourite,
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavourite ? Colors.red : null,
                  tooltip: isFavourite ? 'Remove Favourite' : 'Add Favourite',
                ),
        ],
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
                buildBookImage(context, frontImage),

                const SizedBox(width: 15),

                buildBookImage(context, backImage, isBack: true),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              widget.book['title']?.toString() ?? '',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              'Author: ${widget.book['author'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 12),

            Text(
              '₹${widget.book['price'] ?? 0}',
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
              widget.book['description'] ?? 'No description available',
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

            const SizedBox(height: 30),

            const Text(
              'About the Author',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            buildAuthorSection(),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
