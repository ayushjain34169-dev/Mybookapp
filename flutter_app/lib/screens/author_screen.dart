import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AuthorScreen extends StatefulWidget {
  const AuthorScreen({super.key});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  Map<String, dynamic>? author;

  bool isLoading = true;
  String errorMessage = "";

  // Chrome / Web ke liye
  final String apiUrl = "http://localhost:3000/api/author";

  @override
  void initState() {
    super.initState();
    fetchAuthor();
  }

  Future<void> fetchAuthor() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          author = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Author details not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Unable to connect to server";
        isLoading = false;
      });
    }
  }

  Future<void> openEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> openPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),

      appBar: AppBar(
        title: const Text(
          "About the Author",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60),
                  const SizedBox(height: 15),
                  Text(errorMessage, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: fetchAuthor,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchAuthor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    // AUTHOR PHOTO
                    Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                            color: Colors.black.withOpacity(0.12),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            author?["image"] != null &&
                                author!["image"].toString().isNotEmpty
                            ? Image.network(
                                "http://localhost:3000${author!["image"]}",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, size: 75);
                                },
                              )
                            : const Icon(Icons.person, size: 75),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // AUTHOR NAME
                    Text(
                      author?["name"] ?? "Author",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // EDUCATION
                    if (author?["education"] != null &&
                        author!["education"].toString().isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 20),
                          const SizedBox(width: 7),
                          Text(
                            author!["education"],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 25),

                    // ABOUT AUTHOR CARD
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_stories_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "About the Author",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Text(
                              author?["bio"] ?? "No biography available.",
                              style: const TextStyle(
                                fontSize: 15.5,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // CONTACT CARD
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Contact Author",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            // EMAIL
                            if (author?["email"] != null &&
                                author!["email"].toString().isNotEmpty)
                              InkWell(
                                onTap: () {
                                  openEmail(author!["email"]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.email_outlined),

                                      const SizedBox(width: 15),

                                      Expanded(
                                        child: Text(
                                          author!["email"],
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),

                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // PHONE
                            if (author?["phone"] != null &&
                                author!["phone"].toString().isNotEmpty)
                              InkWell(
                                onTap: () {
                                  openPhone(author!["phone"]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_outlined),

                                      const SizedBox(width: 15),

                                      Expanded(
                                        child: Text(
                                          author!["phone"],
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),

                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // CONTACT BUTTON
                  ],
                ),
              ),
            ),
    );
  }
}
