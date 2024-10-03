import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BarcodeForm(),
    );
  }
}

class BarcodeForm extends StatefulWidget {
  @override
  _BarcodeFormState createState() => _BarcodeFormState();
}

class _BarcodeFormState extends State<BarcodeForm> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _netWeightController = TextEditingController();
  final _pickedDateController = TextEditingController();
  final _useByDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Generator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _netWeightController,
                decoration: InputDecoration(labelText: 'Net Weight'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the net weight';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pickedDateController,
                decoration: InputDecoration(
                  labelText: 'Picked Date',
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the picked date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _useByDateController,
                decoration: InputDecoration(
                  labelText: 'Use By Date',
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the use by date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generatePDF,
                child: Text('Generate PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePDF() async {
    if (_formKey.currentState!.validate()) {
      final pdf = pw.Document();
      final quantity = int.tryParse(_quantityController.text) ?? 1;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                ...List.generate(
                  quantity,
                  (index) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Item ${index + 1} of $quantity'),
                      pw.Text('Product: ${_productNameController.text}'),
                      pw.Text('NetWt: ${_netWeightController.text}'),
                      pw.Text('PKD: ${_pickedDateController.text}'),
                      pw.Text('Use By: ${_useByDateController.text}'),
                      pw.Text('₹${_amountController.text}',
                          style: pw.TextStyle(font: pw.Font.helvetica())),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: _productNameController.text,
                        width: 200,
                        height: 80,
                      ),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  }
}
