import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfReaderScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfReaderScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: PdfViewer.uri(Uri.parse(pdfUrl)),
    );
  }
}
