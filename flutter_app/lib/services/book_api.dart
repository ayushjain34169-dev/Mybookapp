import 'dart:convert';

import 'package:http/http.dart' as http;

class BookApi {
  static const String baseUrl = 'https://mybookapp-3is1.onrender.com';

  // GET ALL BOOKS
  static Future<List<dynamic>> getBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Books load nahi hui');
    }
  }

  // DELETE BOOK
  static Future<void> deleteBook(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode != 200) {
      String message = 'Book delete nahi hui';

      try {
        final data = jsonDecode(response.body);
        message = data['message'] ?? message;
      } catch (_) {}

      throw Exception(message);
    }
  }

  // UPDATE BOOK CATEGORY
  static Future<void> updateBookCategory(String id, String? category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id/category'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': category}),
    );

    if (response.statusCode != 200) {
      String message = 'Category update nahi hui';

      try {
        final data = jsonDecode(response.body);
        message = data['message'] ?? message;
      } catch (_) {}

      throw Exception(message);
    }
  }

  // ADD BOOK TO FAVOURITES
  static Future<void> addFavourite(String userId, String bookId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favourites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'bookId': bookId}),
    );

    if (response.statusCode != 200 && response.statusCode != 409) {
      throw Exception('Favourite add nahi hui');
    }
  }

  // REMOVE BOOK FROM FAVOURITES
  static Future<void> removeFavourite(String userId, String bookId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favourites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'bookId': bookId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Favourite remove nahi hui');
    }
  }

  // GET USER FAVOURITES
  static Future<List<dynamic>> getFavourites(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/favourites/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['favourites'] ?? [];
    } else {
      throw Exception('Favourites load nahi hui');
    }
  }

  // CHECK FAVOURITE STATUS
  static Future<bool> checkFavourite(String userId, String bookId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/favourites/check'
        '?userId=$userId&bookId=$bookId',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['isFavourite'] == true;
    } else {
      throw Exception('Favourite status check nahi hui');
    }
  }
}
