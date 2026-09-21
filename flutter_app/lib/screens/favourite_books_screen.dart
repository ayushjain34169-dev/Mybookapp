import 'package:flutter/material.dart';

class FavouriteBooksScreen extends StatelessWidget {
  const FavouriteBooksScreen({super.key});

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
          'Favourite Books',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey),

              SizedBox(height: 18),

              Text(
                'No Favourite Books',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Text(
                'Books that you save as favourites will '
                'appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
