import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

void main() {
  runApp(MaterialApp(
    home: ShopBillPdf(),
  ));
}

class ShopBillPdf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Bill PDF Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final pdf = pw.Document();

            // Define page size in points (3 inches wide)
            final double pageWidth = 3 * 72.0; // 3 inches in points
            final double pageHeight =
                8.5 * 72.0; // Example height in points (8.5 inches)

            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat(pageWidth, pageHeight),
                build: (context) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Shop Name', style: pw.TextStyle(fontSize: 24)),
                    pw.SizedBox(height: 10),
                    pw.Text('Customer Name: John Doe',
                        style: pw.TextStyle(fontSize: 18)),
                    pw.Text('Date: 2024-07-10',
                        style: pw.TextStyle(fontSize: 18)),
                    pw.SizedBox(height: 20),
                    pw.Text(
                        '------------------------------------------------------------------------------------------------------------------------'),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 10),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                              child: pw.Text('Product',
                                  style: pw.TextStyle(fontSize: 16))),
                          pw.Expanded(
                              child: pw.Text('Price',
                                  style: pw.TextStyle(fontSize: 16),
                                  textAlign: pw.TextAlign.center)),
                          pw.Expanded(
                              child: pw.Text('Qty',
                                  style: pw.TextStyle(fontSize: 16),
                                  textAlign: pw.TextAlign.center)),
                          pw.Expanded(
                              child: pw.Text('Amount',
                                  style: pw.TextStyle(fontSize: 16),
                                  textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ),
                    pw.Text(
                        '------------------------------------------------------------------------------------------------------------------------'),
                    buildRow('Briyani', '100', '2', '200'),
                    buildRow('Mushroom', '50', '1', '50'),
                    buildRow('Parotta', '10', '3', '30'),
                    pw.Text(
                        '------------------------------------------------------------------------------------------------------------------------'),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 10),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('Total: \$50',
                          style: pw.TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );

            if (kIsWeb) {
              await _generateAndDownloadWeb(pdf);
            } else {
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdf.save(),
              );
            }
          },
          child: Text('Generate PDF'),
        ),
      ),
    );
  }

  pw.Widget buildRow(String item, String qty, String price, String total) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(item, style: pw.TextStyle(fontSize: 14))),
          pw.Expanded(
              child: pw.Text(qty,
                  style: pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.center)),
          pw.Expanded(
              child: pw.Text(price,
                  style: pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.center)),
          pw.Expanded(
              child: pw.Text(total,
                  style: pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }
}

Future<void> _generateAndDownloadWeb(pw.Document pdf) async {
  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'shop_bill.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}
