import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../features/site_management/domain/entities/invoice.dart';

class InvoicePdfGenerator {
  Future<Uint8List> build(Invoice invoice) async {
    final document = PdfDocument();
    final page = document.pages.add();
    final content = page.graphics;

    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final font = PdfTrueTypeFont(
      fontData.buffer.asUint8List(),
      12,
      fontStyle: PdfFontStyle.regular,
    );

    final format = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    content.drawString(
      'Fatura ID: ${invoice.id}',
      font,
      bounds: const Rect.fromLTWH(0, 0, 500, 20),
    );
    content.drawString(
      'Dönem: ${invoice.periodName}',
      font,
      bounds: const Rect.fromLTWH(0, 20, 500, 20),
    );
    content.drawString(
      'Sakin: ${invoice.tenantName}',
      font,
      bounds: const Rect.fromLTWH(0, 40, 500, 20),
    );

    double offset = 80;
    for (final item in invoice.items) {
      content.drawString(
        '- ${item.description}: ${format.format(item.amount)}',
        font,
        bounds: Rect.fromLTWH(0, offset, 500, 20),
      );
      offset += 20;
    }

    content.drawString(
      'Toplam: ${format.format(invoice.total)}',
      font,
      bounds: Rect.fromLTWH(0, offset + 10, 500, 20),
    );

    final bytes = await document.save();
    document.dispose();
    return bytes;
  }
}
