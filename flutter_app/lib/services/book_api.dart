import 'dart:convert';

import 'package:http/http.dart' as http;

class BookApi {
  static const String baseUrl = 'http://localhost:3000';

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
}
