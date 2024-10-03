import 'dart:typed_data';

import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:qr_flutter/qr_flutter.dart';

class PrintDocument extends StatefulWidget {
  final String billno;
  final String paytypee;
  final String datee;
  final String timee;
  final String cusname;
  final String cuscontact;
  final String tableno;
  final String sname;
  final String itemcount;
  final String totalqty;
  final String totamt;
  final String discountamt;
  final String finalamt;
  final String sgstt25;
  final String sgstt6;
  final String sgstt9;
  final String sgstt14;
  final List<Map<String, dynamic>> tableData;

  PrintDocument({
    required this.billno,
    required this.paytypee,
    required this.datee,
    required this.timee,
    required this.cusname,
    required this.cuscontact,
    required this.tableno,
    required this.sname,
    required this.itemcount,
    required this.totalqty,
    required this.totamt,
    required this.discountamt,
    required this.finalamt,
    required this.sgstt25,
    required this.sgstt6,
    required this.sgstt9,
    required this.sgstt14,
    required this.tableData,
  });

  @override
  State<PrintDocument> createState() => _PrintDocumentState();
}

class _PrintDocumentState extends State<PrintDocument> {
  String restaurantname = "";
  String address1 = "";
  String address2 = "";
  String city = "";
  String gstno = "";
  String fassai = "";
  String contact = "";
  String? shopLogoUrl;
  bool isLoading = true;
  String upiId = 'thilothinibca-1@okicici'; // Your UPI ID
  String payeeName = 'Your Name'; // Payee Name
  double totalAmount =
      0.0; // Total amount to be paid  String qrScanResult = ''; // For holding the scanned QR result
  bool isPayButtonEnabled = false; // Control button state

  late List<Map<String, dynamic>> tableData;

  @override
  void initState() {
    super.initState();
    fetchShopInfo();

    tableData = [];
  }

  Future<void> fetchShopInfo() async {
    String? cusid = await SharedPrefs.getCusId();
    final String url = "$IpAddress/Shopinfo/?cusid=$cusid";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final shopInfo = data['results'][0];
          setState(() {
            restaurantname = shopInfo['shopname'] ?? restaurantname;
            address1 = shopInfo['doorno'] ?? address1;
            address2 = shopInfo['area2'] ?? address2;
            city =
                "${shopInfo['city'] ?? city} - ${shopInfo['pincode'] ?? city}";
            gstno = "GST No : ${shopInfo['gstno'] ?? gstno}";
            fassai = "FSSAI No : ${shopInfo['fssai'] ?? fassai}";
            contact = "Contact: ${shopInfo['contact'] ?? contact}";
            shopLogoUrl =
                "iVBORw0KGgoAAAANSUhEUgAAAXcAAAF3CAYAAABewAv+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3FpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDE0IDc5LjE1MTQ4MSwgMjAxMy8wMy8xMy0xMjowOToxNSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDowYWI2MDAwMS0wNTM3LWRkNDItOTRiZi00ZTRlOWUwN2Q5NWUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NTE5RUI3Njk4MDFFMTFFQjk5RkZDQUM4NTcwQkZCRjUiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NTE5RUI3Njg4MDFFMTFFQjk5RkZDQUM4NTcwQkZCRjUiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChXaW5kb3dzKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjJhNTI0MjAwLTg0OTQtMGU0Yy1hY2JlLWQ3YzAzNTZhOTIzMiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDowYWI2MDAwMS0wNTM3LWRkNDItOTRiZi00ZTRlOWUwN2Q5NWUiLz4gPC9y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";

            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load shop info');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['Amount']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List bytes = base64.decode(shopLogoUrl!);
    final String CustomerName = widget.cusname;
    final String CustomerContact = widget.cuscontact;
    final String Billno = widget.billno;
    final String paytype = widget.paytypee;
    final String date = widget.datee;
    final String kitchenTime = widget.timee;
    final String tableNo = widget.tableno;
    final String servent = widget.sname;
    final String totitem = widget.itemcount;
    final String totqty = widget.totalqty;
    final String sgst25 = widget.sgstt25;
    final String sgst6 = widget.sgstt6;
    final String sgst9 = widget.sgstt9;
    final String sgst14 = widget.sgstt14;
    final String discount = double.parse(widget.discountamt).toStringAsFixed(2);
    final String amount = double.parse(widget.totamt).toStringAsFixed(2);
    final String totamount = double.parse(widget.finalamt).toStringAsFixed(2);

    final items = widget.tableData.map<Map<String, String>>((data) {
      return {
        "name": data['productName'].toString(),
        "rate": data['amount'].toString(),
        "qty": data['quantity'].toString(),
        "amount": data['Amount'].toString(),
      };
    }).toList();
    String qrData = 'Amount: $totamount';
    String generateUPILink() {
      return 'upi://pay?pa=$upiId&pn=$payeeName&am=$totamount&cu=INR';
    }

    return Center(
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
        width: 3 * 96, // 3 inches width converted to pixels
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.memory(
                bytes,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Text('Error loading image'),
              ),
            ),
            Center(
              child: Text(
                '$restaurantname',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (address1.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$address1',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            if (address2.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$address2',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            if (city.isNotEmpty) // Conditional rendering for the city
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$city',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            if (gstno.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$gstno',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            if (fassai.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$fassai',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            if (contact.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$contact',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            _buildBillInfo("BillNo: $Billno", "Paytype: $paytype"),
            _buildBillInfo("Date: $date", "Time:$kitchenTime"),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            if (CustomerName.isNotEmpty || CustomerContact.isNotEmpty)
              _buildBillInfo("Customer: $CustomerName", ''),
            if (CustomerName.isNotEmpty || CustomerContact.isNotEmpty)
              _buildBillInfo("Contact: $CustomerContact", ""),
            if (CustomerName.isNotEmpty || CustomerContact.isNotEmpty)
              Divider(
                thickness: 1,
                color: Colors.black,
              ),
            if (tableNo.isNotEmpty || servent.isNotEmpty)
              _buildBillInfo("TableNo: $tableNo", "Servent: $servent"),
            if (tableNo.isNotEmpty || servent.isNotEmpty)
              Divider(
                thickness: 1,
                color: Colors.black,
              ),
            _buildProductHeader(),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            ...items.map((item) => _buildProductItem(item)).toList(),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            _buildBillInfo("Total Item: $totitem", "$amount"),
            _buildBillInfo("Total Qty: $totqty", "---------------"),
            SizedBox(
              height: 3,
            ),
            if (sgst25.isNotEmpty && sgst25 != '0.00')
              _buildBillInfo("SGST 2.5%-:", "$sgst25"),
            if (sgst25.isNotEmpty && sgst25 != '0.00')
              _buildBillInfo("CGST 2.5%-:", "$sgst25"),
            SizedBox(
              height: 3,
            ),
            if (sgst6.isNotEmpty && sgst6 != '0.00')
              _buildBillInfo("SGST 6%-:", "$sgst6"),
            if (sgst6.isNotEmpty && sgst6 != '0.00')
              _buildBillInfo("CGST 6%-:", "$sgst6"),
            SizedBox(
              height: 3,
            ),
            if (sgst9.isNotEmpty && sgst9 != '0.00')
              _buildBillInfo("SGST 9%-:", "$sgst9"),
            if (sgst9.isNotEmpty && sgst9 != '0.00')
              _buildBillInfo("CGST 9%-:", "$sgst9"),
            SizedBox(
              height: 3,
            ),
            if (sgst14.isNotEmpty && sgst14 != '0.00')
              _buildBillInfo("SGST 14%-:", "$sgst14"),
            if (sgst14.isNotEmpty && sgst14 != '0.00')
              _buildBillInfo("CGST 14%-:", "$sgst14"),
            // SizedBox(
            //   height: 3,
            // ),
            if (discount.isNotEmpty && discount != '0.00')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "-$discount",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: QrImageView(
                data: generateUPILink(),
                version: QrVersions.auto,
                size: 80.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total : ₹ $totamount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '**THANK YOU COME AGAIN**',
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Technology Partner Buyp - 1800 890 0803',
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label',
            style: TextStyle(fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Product",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              child: Text(
                "Rate",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
            Container(
              width: 30,
              child: Text(
                "Qty",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
            Container(
              width: 50,
              child: Text(
                "Amount",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                item['name']!,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Aligning vertically to the center
              children: [
                Container(
                  width: 40,
                  child: Text(
                    item['rate']!,
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign
                        .end, // Aligning text inside the container to the end
                  ),
                ),
                Container(
                  width: 30,
                  child: Text(
                    item['qty']!,
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign
                        .end, // Aligning text inside the container to the end
                  ),
                ),
                Container(
                  width: 50,
                  child: Text(
                    item['amount']!,
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign
                        .end, // Aligning text inside the container to the end
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
