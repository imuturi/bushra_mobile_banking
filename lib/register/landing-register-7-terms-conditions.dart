import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pdfx/pdfx.dart';
import '../l10n/app_localizations.dart';
import 'landing-register-1.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});
  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String? localPath;
  bool isAtEnd = false;
  PdfController? _pdfController;
  int _currentPage = 0;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = true;

  @override
  void initState() {
    super.initState();
    loadPDF();

    // Listen to scroll position to hide/show the floating button
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Show button if not at bottom, hide if at bottom
      if (currentScroll >= maxScroll * 0.95) { // 95% scrolled
        if (_showScrollButton) {
          setState(() {
            _showScrollButton = false;
          });
        }
      } else {
        if (!_showScrollButton) {
          setState(() {
            _showScrollButton = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _scrollController.dispose();
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.lastUpdatedJan30Th2024,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(thickness: 2),
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
                          }
                        });
                      },
                    ),
                    _buildScrollIndicator(),
                  ],
                ),
              ),
              _buildButtons(),
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
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
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

  Widget _buildButtons() {
    return Padding(
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
              child: Text(
                AppLocalizations.of(context)!.decline,
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
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()))
                  : null,
              child: Text(
                AppLocalizations.of(context)!.accept,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}