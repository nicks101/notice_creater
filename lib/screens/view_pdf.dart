import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String path;

  const PdfPreviewScreen({this.path});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PDFViewerScaffold(
        path: path,
      ),
    );
  }
}
