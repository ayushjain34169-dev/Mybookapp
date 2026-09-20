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
  static const String userId = 'demo_user';

  bool isFavourite = false;
  bool isFavouriteLoading = true;

  @override
  void initState() {
    super.initState();
    checkFavouriteStatus();
  }

  Future<void> checkFavouriteStatus() async {
    final String bookId = widget.book['_id']?.toString() ?? '';

    if (bookId.isEmpty) {
      if (!mounted) return;

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

  Future<void> openAmazonBook() async {
    final url = widget.book['amazonUrl']?.toString().trim() ?? '';

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amazon link available nahi hai')),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void openReadBook() {
    final bool isFree = widget.book['isFree'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFree
              ? 'Free book reading screen next step me open hogi.'
              : 'Payment ke baad book read kar sakenge.',
        ),
      ),
    );
  }

  Widget buildAuthorSection() {
    final author = widget.book['authorDetails'] is Map
        ? Map<String, dynamic>.from(widget.book['authorDetails'])
        : {};

    final name =
        author['name']?.toString() ??
        widget.book['author']?.toString() ??
        'Author';

    final education = author['education']?.toString() ?? '';

    final bio = author['bio']?.toString() ?? '';

    final image = author['image']?.toString() ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            image.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      image,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person, size: 75),

            const SizedBox(height: 15),

            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            if (education.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(education),
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
              child: Text(bio.isNotEmpty ? bio : 'No biography available.'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frontImage = widget.book['frontImage']?.toString() ?? '';

    final backImage = widget.book['backImage']?.toString() ?? '';

    final amazonUrl = widget.book['amazonUrl']?.toString().trim() ?? '';

    final appBookEnabled = widget.book['appBookEnabled'] == true;

    final isFree = widget.book['isFree'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FA),

      appBar: AppBar(
        title: const Text(
          'Book Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

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
              widget.book['description']?.toString() ??
                  'No description available',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),
            if (amazonUrl.isNotEmpty || appBookEnabled)
              Column(
                children: [
                  if (amazonUrl.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: openAmazonBook,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text(
                          'Buy Book on Amazon',
                          style: TextStyle(fontSize: 17),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  if (amazonUrl.isNotEmpty && appBookEnabled)
                    const SizedBox(height: 12),

                  if (appBookEnabled)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: openReadBook,
                        icon: const Icon(Icons.menu_book),
                        label: Text(
                          isFree ? 'Read Book • FREE' : 'Read Book',
                          style: const TextStyle(fontSize: 17),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4BDB),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
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
