import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path;

import '../models/notice.dart';
import 'view_pdf.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText speech = stt.SpeechToText();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String fileName;

  String _title;
  String _description;
  String _party1;
  String _party2;
  String _party3;

  bool isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    speech.initialize();
  }

  Future<pw.Document> writeOnPdf(Notice notice) async {
    /// TODO: set custom fonts

    final pdf = pw.Document();

    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 50,
    );
    const paragraphStyle = pw.TextStyle(fontSize: 30);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Center(
              child: pw.Text(
                notice.title ?? "",
                style: headerStyle,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Paragraph(text: notice.description ?? '', style: paragraphStyle),
            pw.SizedBox(height: 10),
            pw.Paragraph(text: 'Between'.toUpperCase(), style: paragraphStyle),
            pw.SizedBox(height: 10),
            pw.Paragraph(text: notice.party1 ?? '', style: paragraphStyle),
            pw.SizedBox(height: 10),
            pw.Paragraph(text: notice.party2 ?? '', style: paragraphStyle),
            pw.SizedBox(height: 10),
            pw.Paragraph(text: notice.party3 ?? '', style: paragraphStyle),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<void> savePdf(pw.Document pdf) async {
    /// TODO: give user the option to set the name of file
    /// and other options like path to save, author, etc...

    final Directory documentDirectory =
        await path.getExternalStorageDirectory();
    final String documentPath = documentDirectory.path;

    fileName = "$documentPath/example.pdf";

    final File file = File(fileName);
    print(file.path);
    file.writeAsBytesSync(await pdf.save());
  }

  Future<void> generatePDF(Notice notice) async {
    await writeOnPdf(notice).then((pw.Document pdf) async {
      await savePdf(pdf);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Create PDF Draft'),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 20, children: [
              _speechButton('Title', () {
                speech.listen(onResult: (SpeechRecognitionResult result) {
                  setState(() {
                    _title = result.recognizedWords;
                  });
                });
              }),
              _speechButton('Description', () {
                speech.listen(onResult: (SpeechRecognitionResult result) {
                  setState(() {
                    _description = result.recognizedWords;
                  });
                });
              }),
              _speechButton('Party 1', () {
                speech.listen(onResult: (SpeechRecognitionResult result) {
                  setState(() {
                    _party1 = result.recognizedWords;
                  });
                });
              }),
              _speechButton('Party 2', () {
                speech.listen(onResult: (SpeechRecognitionResult result) {
                  setState(() {
                    _party2 = result.recognizedWords;
                  });
                });
              }),
              _speechButton('Party 3', () {
                speech.listen(onResult: (SpeechRecognitionResult result) {
                  setState(() {
                    _party3 = result.recognizedWords;
                  });
                });
              }),
            ]),
            _displayHeader(),
            _displayParagraph(_description?.toUpperCase() ?? ''),
            if (_description != null && _description.isNotEmpty)
              _displayParagraph('between'.toUpperCase()),
            _displayParagraph(_party1),
            _displayParagraph(_party2),
            _displayParagraph(_party3),
          ]),
        ),
      ),
      bottomNavigationBar: _bottomButton(),
    );
  }

  Widget _speechButton(String text, VoidCallback onPressed) {
    return RaisedButton(
      onPressed: onPressed,
      child: Text(text ?? ''),
    );
  }

  Widget _displayHeader() => Column(
        children: [
          const SizedBox(height: 20),
          Center(
              child: Text(
            _title?.toUpperCase() ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          )),
        ],
      );

  Widget _displayParagraph(String text) => Column(
        children: [
          const SizedBox(height: 10),
          Text(
            text ?? '',
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      );

  Widget _bottomButton() => FlatButton(
        color: Theme.of(context).primaryColor,
        onPressed: isGeneratingPDF
            ? null
            : () async {
                /// TODO: add a check for empty notice instance

                setState(() {
                  isGeneratingPDF = true;
                });

                final Notice notice = Notice(
                  title: _title,
                  description: _description,
                  party1: _party1,
                  party2: _party2,
                  party3: _party3,
                );

                await generatePDF(notice).then((_) async {
                  setState(() {
                    isGeneratingPDF = false;
                  });

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewScreen(
                          path: fileName,
                        ),
                      ));
                });
              },
        child: isGeneratingPDF
            ? const CircularProgressIndicator()
            : const Text('Convert to PDF'),
      );
}
