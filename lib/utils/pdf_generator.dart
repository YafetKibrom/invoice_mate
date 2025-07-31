import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/ticket.dart';
import '../models/company_info.dart';

final _currencyFormat = NumberFormat.simpleCurrency();

Future<Uint8List> generateInvoicePdf({
  required CompanyInfo company,
  required String clientName,
  required String clientAddress,
  required String clientCity,
  required String clientPostalCode,
  required String clientPhone,
  required List<Ticket> tickets,
  File? logoFile,
}) async {
  final pdf = pw.Document();
  pw.ImageProvider? logoImage;

  if (logoFile != null && await logoFile.exists()) {
    final bytes = await logoFile.readAsBytes();
    logoImage = pw.MemoryImage(bytes);
  }

  final subtotal = tickets.fold(0.0, (sum, t) => sum + t.total);
  final gst = subtotal * 0.05;
  final total = subtotal + gst;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 24),
          _buildHeader(
            logo: logoImage,
            company: company,
            clientName: clientName,
            clientAddress: clientAddress,
            clientCity: clientCity,
            clientPostalCode: clientPostalCode,
            clientPhone: clientPhone,
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),
          _buildTicketTable(tickets),
          pw.SizedBox(height: 12),
          _buildTotals(subtotal, gst, total),
          pw.Spacer(),
          pw.Center(
            child: pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader({
  required pw.ImageProvider? logo,
  required CompanyInfo company,
  required String clientName,
  required String clientAddress,
  required String clientCity,
  required String clientPostalCode,
  required String clientPhone,
}) {
  final labelStyle = pw.TextStyle(
    fontSize: 10.5,
    fontWeight: pw.FontWeight.bold,
    decoration: pw.TextDecoration.underline,
  );
  final textStyle = pw.TextStyle(fontSize: 12);
  final spacing = 2.5;

  pw.Widget labeledColumn(
    String label,
    List<String> lines, {
    bool alignRight = false,
  }) {
    return pw.SizedBox(
      width: 156,
      child: pw.Column(
        crossAxisAlignment: alignRight
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: labelStyle),
          pw.SizedBox(height: 3),
          ...lines.map(
            (line) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: spacing),
              child: pw.Text(
                line,
                style: textStyle,
                textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      // Company Info (From)
      labeledColumn('From', [
        company.name,
        company.address,
        '${company.city}, ${company.postalCode}',
        'Phone: ${company.phoneNumber}',
      ]),

      // Centered Logo
      if (logo != null) pw.Container(child: pw.Image(logo, height: 86)),

      // Client Info (Bill To)
      labeledColumn('Bill To', [
        clientName,
        clientAddress,
        '$clientCity, $clientPostalCode',
        'Phone: $clientPhone',
      ], alignRight: true),
    ],
  );
}

pw.Widget _buildTicketTable(List<Ticket> tickets) {
  final headers = [
    'Date',
    'Ticket #',
    'Contractor',
    'Locations',
    'Loads',
    'Hours',
    'Rate',
    'Total',
  ];

  final headerBgColor = PdfColors.grey500;
  final headerTextColor = PdfColors.black;

  final headerStyle = pw.TextStyle(fontSize: 12, color: headerTextColor);
  final cellStyle = pw.TextStyle(fontSize: 11);

  final columnWidths = {
    0: const pw.FlexColumnWidth(1.2),
    1: const pw.FlexColumnWidth(1.2),
    2: const pw.FlexColumnWidth(2.5),
    3: const pw.FlexColumnWidth(3.5),
    4: const pw.FlexColumnWidth(1),
    5: const pw.FlexColumnWidth(1),
    6: const pw.FlexColumnWidth(1.5),
    7: const pw.FlexColumnWidth(1.5),
  };

  pw.Widget cell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      color: isHeader ? headerBgColor : PdfColors.grey100,
      child: pw.Center(
        child: pw.Text(
          text,
          style: isHeader ? headerStyle : cellStyle,
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  return pw.Table(
    columnWidths: columnWidths,
    border: pw.TableBorder.symmetric(
      inside: pw.BorderSide(color: PdfColors.grey600, width: 0.5),
      outside: pw.BorderSide(color: PdfColors.grey600, width: 1),
    ),
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      // Header row
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerBgColor),
        children: headers.map((h) => cell(h, isHeader: true)).toList(),
      ),
      // Data rows
      ...tickets.map((t) {
        final values = [
          t.date,
          t.ticketNumber,
          t.contractor,
          t.locations,
          t.loads.toString(),
          t.hours.toStringAsFixed(2),
          _currencyFormat.format(t.rate),
          _currencyFormat.format(t.total),
        ];
        return pw.TableRow(
          decoration: const pw.BoxDecoration(), // clean, no shading
          children: values.map((v) => cell(v)).toList(),
        );
      }),
    ],
  );
}

pw.Widget _buildTotals(double subtotal, double gst, double total) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Divider(thickness: 1, color: PdfColors.grey600),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Sub-Total:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'GST:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Total:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(_currencyFormat.format(subtotal)),
              pw.SizedBox(height: 4),
              pw.Text(_currencyFormat.format(gst)),
              pw.SizedBox(height: 4),
              pw.Text(
                _currencyFormat.format(total),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
