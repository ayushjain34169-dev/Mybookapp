import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';

class PdfReaderScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfReaderScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  Uint8List? pdfBytes;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          pdfBytes = response.bodyBytes;
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          errorMessage = 'PDF load nahi hui. Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'PDF load karne mein problem hui:\n$e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Book load ho rahi hai...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 55),
                    const SizedBox(height: 15),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        loadPdf();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : pdfBytes == null
          ? const Center(child: Text('PDF available nahi hai'))
          : PdfViewer.data(
              pdfBytes!,
              sourceName: widget.title,
              params: PdfViewerParams(
                margin: 10,

                errorBannerBuilder: (context, error, stackTrace, document) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'PDF Error:\n$error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
