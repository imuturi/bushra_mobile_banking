import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shimmer/shimmer.dart';
import 'open-account-3-verify-id.dart';
import 'package:flutter/services.dart';

class OpenAccountTerms extends StatefulWidget {
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const OpenAccountTerms({
    super.key,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth
  });
  @override
  State<OpenAccountTerms> createState() => _OpenAccountTermsStateScreenState();
}

class _OpenAccountTermsStateScreenState extends State<OpenAccountTerms> {
  String? localPath;
  bool isAtEnd = false;
  PdfController? _pdfController;
  int _currentPage = 0;
  int _totalPages = 1;
  bool _showScrollButton = true;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> loadPDF() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/terms.pdf");
      // Copy from assets
      final data = await rootBundle.load("assets/pdf/terms.pdf");
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      // Pass Future<PdfDocument> directly
      final controller = PdfController(
        document: PdfDocument.openFile(file.path),
      );
      // listen for page changes / page count ready
      controller.pageListenable.addListener(() {
        final count = controller.pagesCount;
        if (count != null && mounted) {
          setState(() {
            _totalPages = count;
          });
        }
      });

      if (mounted) {
        setState(() {
          localPath = file.path;
          _pdfController = controller;
          _totalPages = controller.pagesCount ?? 1; // safe default
        });
      }
    } catch (e, stack) {
      print("Error loading PDF: $e");
      print(stack);
    }
  }

  // Function to scroll to bottom
  void _scrollToBottom() {
    if (_pdfController != null && _totalPages > 1) {
      _pdfController!.jumpToPage(_totalPages - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Term & conditions", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Last updated Jan 30TH 2024",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(thickness: 2),

              // WebView for PDF
              Expanded(
                child: localPath == null || _pdfController == null
                    ? _buildShimmerLoader()
                    : Stack(
                  children: [
                    PdfView(
                      controller: _pdfController!,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                          isAtEnd = (_currentPage == _totalPages - 1);
                          // Hide scroll button when reaching near the end
                          if (page >= _totalPages - 2) {
                            _showScrollButton = false;
                          } else {
                            _showScrollButton = true;
                          }
                        });
                      },
                    ),
                    _buildScrollIndicator(),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "DECLINE",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAtEnd ? Colors.red.shade900 : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isAtEnd
                            ? () {
                          if (widget.accountType == 'XYZ') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OpenAccountVerifyIdentityScreen3(
                                  accountType: widget.accountType,
                                  passportNumber: widget.passportNumber,
                                  phoneNumber: widget.phoneNumber,
                                  dateOfBirth: widget.dateOfBirth,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OpenAccountVerifyIdentityScreen3(
                                  accountType: widget.accountType,
                                  passportNumber: widget.passportNumber,
                                  phoneNumber: widget.phoneNumber,
                                  dateOfBirth: widget.dateOfBirth,
                                ),
                              ),
                            );
                          }
                        }
                            : null,
                        child: const Text(
                          "ACCEPT",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating scroll to bottom button
          if (_showScrollButton && _pdfController != null && _totalPages > 1)
            Positioned(
              bottom: 80, // Position above the accept/decline buttons
              right: 16,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Positioned(
      right: 4,
      top: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;
          double scrollProgress = _totalPages > 1 ? _currentPage / (_totalPages - 1) : 0;

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 4,
              height: height,
              color: Colors.grey.withOpacity(0.2),
              child: Align(
                alignment: Alignment(0, (scrollProgress * 2) - 1),
                child: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}