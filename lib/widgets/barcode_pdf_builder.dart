import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'box_barcode_entry.dart';

/// Generates a print-ready multi-page A4 PDF containing only Box QR codes & Box names
Future<Uint8List> generateBarcodePdf({
  required String title,
  required int printFormat,
  required List<BoxBarcodeEntry> entries,
}) async {
  final pdf = pw.Document();

  // Load Unicode Inter font with fallback to standard Helvetica
  pw.Font? regularFont;
  pw.Font? boldFont;
  try {
    regularFont = await PdfGoogleFonts.interRegular();
    boldFont = await PdfGoogleFonts.interBold();
  } catch (_) {
    regularFont = null;
    boldFont = null;
  }

  if (printFormat == 1) {
    // Thermal 50x30mm Single Label Format
    final thermalFormat = PdfPageFormat(
      50 * PdfPageFormat.mm,
      30 * PdfPageFormat.mm,
      marginAll: 2.5 * PdfPageFormat.mm,
    );
    for (final entry in entries) {
      pdf.addPage(
        pw.Page(
          pageFormat: thermalFormat,
          build: (context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              padding: const pw.EdgeInsets.all(3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: entry.code,
                    width: 22 * PdfPageFormat.mm,
                    height: 22 * PdfPageFormat.mm,
                  ),
                  pw.SizedBox(width: 2.5 * PdfPageFormat.mm),
                  pw.Expanded(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          entry.name,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                          maxLines: 2,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Personal Inventory',
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 5.5,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return pdf.save();
  }

  final dateStr = DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      header: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Storage Box Labels - ${entries.length} Containers',
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '${entries.length} Labels',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8.5,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 12),
          ],
        );
      },
      footer: (context) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Personal Inventory - Storage QR Labels',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        );
      },
      build: (context) {
        return [
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: entries.map((entry) {
              return pw.Container(
                width: 172,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Crisp Vector QR Code
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: entry.code,
                      width: 85,
                      height: 85,
                    ),
                    pw.SizedBox(height: 8),

                    // Box Name ONLY
                    pw.Text(
                      entry.name,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      maxLines: 2,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}
