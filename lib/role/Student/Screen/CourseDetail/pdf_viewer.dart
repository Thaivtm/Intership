import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class MyPdfViewer extends StatefulWidget {
  final String fileUrl;

  MyPdfViewer({super.key, required this.fileUrl});

  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  bool _isLoading = true;
  String? _filePath;
  bool _isError = false;
  int _totalPages = 0;
  int _currentPage = 1;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp.pdf';
      await Dio().download(widget.fileUrl, filePath);
      setState(() {
        _filePath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Error downloading file.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _downloadFile,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : PDFView(
                      filePath: _filePath!,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      onRender: (_pages) {
                        setState(() {
                          _totalPages = _pages!;
                        });
                      },
                      onViewCreated: (PDFViewController vc) {
                        _pdfViewController = vc;
                      },
                      onPageChanged: (int? page, int? total) {
                        setState(() {
                          _currentPage = page! + 1;
                        });
                      },
                    ),
          if (!_isLoading && !_isError)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_currentPage/$_totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_filePath != null) {
      File(_filePath!).delete();
    }
    super.dispose();
  }
}
