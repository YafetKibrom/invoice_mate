import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/ticket.dart';
import '../providers/company_provider.dart';
import '../utils/pdf_generator.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final String? clientName;
  final String? clientAddress;
  final String? clientCity;
  final String? clientPostalCode;
  final String? clientPhone;
  final List<Ticket>? tickets;
  final String? filePath;

  const InvoicePreviewScreen({
    Key? key,
    this.clientName,
    this.clientAddress,
    this.clientCity,
    this.clientPostalCode,
    this.clientPhone,
    this.tickets,
    this.filePath,
  }) : super(key: key);

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  Uint8List? _pdfData;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  double _currentZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (widget.filePath != null) {
      final file = File(widget.filePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() => _pdfData = bytes);
        return;
      }
    }

    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );
    final company = companyProvider.companyInfo;
    if (company == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company information missing.')),
      );
      return;
    }

    final logoFile = company.logoPath != null ? File(company.logoPath!) : null;

    final pdfBytes = await generateInvoicePdf(
      company: company,
      clientName: widget.clientName ?? '',
      clientAddress: widget.clientAddress ?? '',
      clientCity: widget.clientCity ?? '',
      clientPostalCode: widget.clientPostalCode ?? '',
      clientPhone: widget.clientPhone ?? '',
      tickets: widget.tickets ?? [],
      logoFile: logoFile,
    );

    setState(() => _pdfData = pdfBytes);
  }

  String sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  Future<String> _savePdf(Uint8List data) async {
    final dir = await getApplicationDocumentsDirectory();

    final clientFolderName = widget.clientName ?? 'Saved';
    final clientFolder = Directory(
      '${dir.path}${Platform.pathSeparator}Invoices${Platform.pathSeparator}${sanitizeFileName(clientFolderName)}',
    );

    if (!await clientFolder.exists()) {
      await clientFolder.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath =
        '${clientFolder.path}${Platform.pathSeparator}invoice_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(data);
    return file.path;
  }

  Future<void> _sharePdf() async {
    if (_pdfData != null) {
      try {
        final path = await _savePdf(_pdfData!);
        await Share.shareXFiles([XFile(path)], text: 'Invoice');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share PDF: $e')));
      }
    }
  }

  Future<void> _printPdf() async {
    if (_pdfData != null) {
      try {
        await Printing.layoutPdf(onLayout: (_) => _pdfData!);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to print PDF: $e')));
      }
    }
  }

  // Zoom level limits
  static const double minZoom = 1.0;
  static const double maxZoom = 5.0;

  void _zoomBy(double delta) {
    setState(() {
      _currentZoomLevel = (_currentZoomLevel + delta).clamp(minZoom, maxZoom);
      _pdfViewerController.zoomLevel = _currentZoomLevel;
    });
  }

  // Listen for Ctrl + scroll on desktop platforms for zooming
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Only handle Ctrl+scroll zoom on desktop platforms
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final isCtrlPressed =
            RawKeyboard.instance.keysPressed.contains(
              LogicalKeyboardKey.controlLeft,
            ) ||
            RawKeyboard.instance.keysPressed.contains(
              LogicalKeyboardKey.controlRight,
            );

        if (isCtrlPressed) {
          final scrollDelta = event.scrollDelta.dy;
          if (scrollDelta > 0) {
            _zoomBy(-0.25); // Zoom out
          } else if (scrollDelta < 0) {
            _zoomBy(0.25); // Zoom in
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice'), centerTitle: true),
      body: _pdfData == null
          ? const Center(child: CircularProgressIndicator())
          : Listener(
              onPointerSignal: _handlePointerSignal,
              child: SfPdfViewer.memory(
                _pdfData!,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                pageLayoutMode: PdfPageLayoutMode.single,
                initialZoomLevel: 1.0,
              ),
            ),
      bottomNavigationBar: _pdfData == null
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: 'Print',
                      onPressed: _printPdf,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Share',
                      onPressed: _sharePdf,
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: 'Save',
                      onPressed: () async {
                        final path = await _savePdf(_pdfData!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved to $path')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
