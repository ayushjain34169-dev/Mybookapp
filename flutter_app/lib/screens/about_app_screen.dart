import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'About App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // ================= APP HEADER =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF7),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'My Book App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Discover • Read • Enjoy',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ================= ABOUT =================
            _sectionCard(
              icon: Icons.info_outline,
              title: 'About My Book App',
              text:
                  'My Book App is a digital reading platform designed '
                  'to make discovering and reading books simple, convenient '
                  'and enjoyable.\n\n'
                  'The app allows users to explore available books, view '
                  'book details and access reading content from one place. '
                  'The goal is to provide a clean and easy-to-use reading '
                  'experience for book lovers.',
            ),

            const SizedBox(height: 14),

            // ================= PURPOSE =================
            _sectionCard(
              icon: Icons.lightbulb_outline,
              title: 'Why This App Was Created',
              text:
                  'My Book App was created to provide readers with a simple '
                  'digital platform where they can discover books and read '
                  'available content without unnecessary complexity.\n\n'
                  'The app focuses on keeping the reading experience '
                  'organised, accessible and user friendly.',
            ),

            const SizedBox(height: 14),

            // ================= FEATURES =================
            _featuresCard(),

            const SizedBox(height: 14),

            // ================= DEVELOPER =================
            _sectionCard(
              icon: Icons.person_outline,
              title: 'Developer',
              text:
                  'My Book App is developed as a digital book reading '
                  'application with a focus on providing a simple and '
                  'modern user experience.\n\n'
                  'Developer: Ayush Jain\n'
                  'Education: MCA',
            ),

            const SizedBox(height: 24),

            // ================= COPYRIGHT =================
            const Text(
              '© 2026 My Book App',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            const Text(
              'Made for readers',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= SECTION CARD =================

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.black87),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FEATURES =================

  Widget _featuresCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.star_outline, color: Colors.black87),
              ),

              const SizedBox(width: 12),

              const Text(
                'App Features',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _featureItem(Icons.explore_outlined, 'Discover Books'),

          _featureItem(Icons.menu_book_outlined, 'Read Available Books'),

          _featureItem(Icons.favorite_border, 'Save Favourite Books'),

          _featureItem(Icons.description_outlined, 'View Book Details'),

          _featureItem(Icons.picture_as_pdf_outlined, 'Digital PDF Reading'),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 21, color: Colors.black87),

          const SizedBox(width: 12),

          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
