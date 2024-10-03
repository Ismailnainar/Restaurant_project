import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(Salesreport());
}

class Salesreport extends StatefulWidget {
  @override
  State<Salesreport> createState() => _SalesreportState();
}

class _SalesreportState extends State<Salesreport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  double totalSales = 0.0;
  @override
  void initState() {
    super.initState();
    fetchtotalCount();
    _calculateTotalSales();
  }

  void _calculateTotalSales() {
    double calculatedSales = 0.0;

    // Loop through the table data and sum the paid amounts
    for (var data in tableData) {
      double paidAmount = double.tryParse(data['paidamount'].toString()) ?? 0.0;
      calculatedSales += paidAmount;
      print('calculatedSales :$calculatedSales');
      print('paidAmount :$paidAmount');
    }

    // Update the totalSales variable and trigger a UI update
    setState(() {
      totalSales = calculatedSales;
      _totalSalesController.text = totalSales.toStringAsFixed(2);
      print('_totalSalesController :${_totalSalesController.text}');
    });
  }

  TextEditingController _enddateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController _startdateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  List<String> getDisplayedColumns() {
    return ['billno', 'dt', 'cusname', 'count', 'paidamount'];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData) {
    List<String> displayedColumns = getDisplayedColumns();
    return tableData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
  }

  TextEditingController _countController = TextEditingController();
  final TextEditingController _totalSalesController = TextEditingController();

  Future<void> fetchtotalCount() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/SalesRoundAndDetails/$cusid'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['count'] != null) {
        setState(() {
          _countController.text = jsonData['count'].toString();
        });
      }
      // print("count ${_countController.text}");
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchdatewisesales() async {
    String startdt = _startdateController.text;
    String enddt = _enddateController.text;
    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    String? cusid = await SharedPrefs.getCusId();
    // Format the dates to string

    String formatedlogreportstartdt =
        DateFormat('d MMMM,yyyy').format(startDate);
    String formatedlogreportenddt = DateFormat('d MMMM,yyyy').format(endDate);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      logreports(
          "SalesRepot: ${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");

      setState(() {
        tableData = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                // color: Subcolor,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arrow back icon and text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              'Sales Summary (Date Wise)',
                              style: HeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? 150
                                      : MediaQuery.of(context).size.width *
                                          0.32,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 30,
                                            child: DateTimePicker(
                                              controller: _startdateController,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                              dateLabelText: '',
                                              onChanged: (val) {
                                                // Update selectedDate when the date is changed
                                                setState(() {
                                                  selectedStartDate =
                                                      DateTime.parse(val);
                                                });
                                                print(val);
                                              },
                                              validator: (val) {
                                                print(val);
                                                return null;
                                              },
                                              onSaved: (val) {
                                                print(val);
                                              },
                                              style: textStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'To',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? 150
                                      : MediaQuery.of(context).size.width *
                                          0.32,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 30,
                                            child: DateTimePicker(
                                              controller: _enddateController,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                              dateLabelText: '',
                                              onChanged: (val) {
                                                // Update selectedDate when the date is changed
                                                setState(() {
                                                  selectedEndDate =
                                                      DateTime.parse(val);
                                                });
                                                print(val);
                                              },
                                              validator: (val) {
                                                print(val);
                                                return null;
                                              },
                                              onSaved: (val) {
                                                print(val);
                                              },
                                              style: textStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: Responsive.isMobile(context) ? 10 : 27.0,
                                left: Responsive.isMobile(context) ? 10 : 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                fetchdatewisesales();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: subcolor,
                                  minimumSize: Size(10, 30),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero)),
                              child: Icon(
                                Icons.search,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 20,
                            bottom: 20,
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 20,
                                                  ),
                                                  child: Container(
                                                    width: 200,
                                                    height: 100,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start, // Aligns children to the start of the row
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center, // Centers the text and text field vertically
                                                      children: [
                                                        Text(
                                                          'Total Sales ₹ :',
                                                          style:
                                                              textStyle, // Apply your text style here
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                10), // Adds some space between the text and text field
                                                        Expanded(
                                                          child: TextField(
                                                            controller:
                                                                _totalSalesController,
                                                            decoration:
                                                                InputDecoration(
                                                              border: InputBorder
                                                                  .none, // No border for the text field
                                                            ),
                                                            style: textStyle,
                                                            readOnly:
                                                                true, // Make the TextField read-only so users can't edit the value
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                            ]),
                                        ElevatedButton(
                                          onPressed: () async {
                                            List<Map<String, dynamic>>
                                                filteredData =
                                                getFilteredData(tableData);
                                            List<List<dynamic>> convertedData =
                                                filteredData
                                                    .map((map) =>
                                                        map.values.toList())
                                                    .toList();
                                            List<String> columnNames =
                                                getDisplayedColumns();
                                            await createExcel(
                                                columnNames, convertedData);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: subcolor,
                                              padding: EdgeInsets.only(
                                                  left: 7,
                                                  right: 7,
                                                  top: 3,
                                                  bottom: 3),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.zero)),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: SvgPicture.asset(
                                                  'assets/imgs/excel.svg',
                                                  width: 20,
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "Export",
                                                style: commonWhiteStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                  // child: Column(
                                  //   children: [
                                  //     SizedBox(height: 20),
                                  // Row(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     Padding(
                                  //       padding: const EdgeInsets.only(
                                  //         left: 20,
                                  //       ),
                                  //       child: Container(
                                  //           width: 200,
                                  //           height: 100,
                                  //           child: Row(
                                  //             mainAxisAlignment: MainAxisAlignment
                                  //                 .start, // Aligns children to the start of the row
                                  //             crossAxisAlignment: CrossAxisAlignment
                                  //                 .center, // Centers the text and text field vertically
                                  //             children: [
                                  //               Text(
                                  //                 'Total Sales ₹ :',
                                  //                 style:
                                  //                     textStyle, // Apply your text style here
                                  //               ),
                                  //               SizedBox(
                                  //                   width:
                                  //                       10), // Adds some space between the text and text field
                                  //               Expanded(
                                  //                 child: TextField(
                                  //                   controller:
                                  //                       _totalSalesController,
                                  //                   decoration: InputDecoration(
                                  //                     border: InputBorder
                                  //                         .none, // No border for the text field
                                  //                   ),
                                  //                   style: textStyle,
                                  //                   readOnly:
                                  //                       true, // Make the TextField read-only so users can't edit the value
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           )),
                                  //         ),
                                  //         Spacer(),
                                  //         // SizedBox(
                                  //         //   width: 6,
                                  //         // ),
                                  //     ElevatedButton(
                                  //       onPressed: () async {
                                  //         List<Map<String, dynamic>> filteredData =
                                  //             getFilteredData(tableData);
                                  //         List<List<dynamic>> convertedData =
                                  //             filteredData
                                  //                 .map((map) => map.values.toList())
                                  //                 .toList();
                                  //         List<String> columnNames =
                                  //             getDisplayedColumns();
                                  //         await createExcel(
                                  //             columnNames, convertedData);
                                  //       },
                                  //       style: ElevatedButton.styleFrom(
                                  //           backgroundColor: subcolor,
                                  //           padding: EdgeInsets.only(
                                  //               left: 7,
                                  //               right: 7,
                                  //               top: 3,
                                  //               bottom: 3),
                                  //           shape: RoundedRectangleBorder(
                                  //               borderRadius: BorderRadius.zero)),
                                  //       child: Row(
                                  //         children: [
                                  //           Padding(
                                  //             padding:
                                  //                 const EdgeInsets.only(right: 8),
                                  //             child: SvgPicture.asset(
                                  //               'assets/imgs/excel.svg',
                                  //               width: 20,
                                  //               height: 20,
                                  //               color: Colors.white,
                                  //             ),
                                  //           ),
                                  //           Text(
                                  //             "Export",
                                  //             style: commonWhiteStyle,
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [],
                                  ),
                                  Divider(
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  tableView(),
                                  SizedBox(height: 10),
                                  //   ],
                                  // ),
                                ],
                              )))
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> Purchasedetailstabledata = [];
  Future<void> fetchsalesdetails(Map<String, dynamic> data) async {
    String id = data["id"].toString(); // Convert Id to String
    final url = '$IpAddress/SalesRoundDetailsalldatas/$id';
    print("url : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('SalesDetails')) {
          try {
            String purchaseDetailsString = responseData['SalesDetails'];
            List<String> purchaseDetailsRecords = purchaseDetailsString
                .split('}{'); // Split by '}{' to separate records
            for (var record in purchaseDetailsRecords) {
              // Clean up the record by removing '{' and '}'
              record = record.replaceAll('{', '').replaceAll('}', '');
              List<String> keyValuePairs = record.split(',');
              Map<String, dynamic> purchaseDetail = {};
              for (var pair in keyValuePairs) {
                List<String> parts = pair.split(':');
                String key = parts[0].trim();
                String value = parts[1].trim();
                // Remove surrounding quotes if any
                if (value.startsWith("'") && value.endsWith("'")) {
                  value = value.substring(1, value.length - 1);
                }
                purchaseDetail[key] = value;
              }
              Purchasedetailstabledata.add({
                'Itemname': purchaseDetail['Itemname'],
                'rate': purchaseDetail['rate'],
                'qty': purchaseDetail['qty'],
                'amount': purchaseDetail['amount'],
                'retail': purchaseDetail['retail'],
              });
            }
            // Print Paymentdetailsamounts after setting state
            // print('purchase Payment Details: $Purchasedetailstabledata');
            Purchasedetails(data);
          } catch (e) {
            throw FormatException('Invalid purchasepaymentdetails format');
          }
        } else {
          throw Exception(
              'Invalid response format: purchasepaymentdetails not found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void Purchasedetails(Map<String, dynamic> data) {
    String timeString =
        data['time'] ?? ''; // Assuming time is present in the data

    // Parse the time string into a DateTime object
    DateTime time = DateTime.parse(timeString);

    // Format the DateTime object to display time in "02:57 PM" format
    String formattedTime = DateFormat('hh:mm a').format(time);

    Future<void> _printResult() async {
      try {
        // Parse 'dt' and 'time' strings into DateTime objects
        DateTime salesdate = DateTime.parse(data['dt']);
        DateTime salestime = DateTime.parse(data['time']);

// Format the DateTime objects as required
        String formattedDate = DateFormat('dd.MM.yyyy').format(salesdate);
        String formattedDateTime = DateFormat('hh:mm a').format(salestime);

        double totalQuantity =
            0.0; // Define total quantity variable outside the loop

        for (var data in Purchasedetailstabledata) {
          // Inside the loop, add each quantity to the totalQuantity variable
          totalQuantity += double.parse(data['qty'].toString());
        }
        String totalQuantityString = totalQuantity.toString();
        String billno = data['billno'];
        String date = formattedDate;
        String paytype = data['paytype'];
        String time = formattedDateTime;
        // String Customername = data['cusname'];
        // String CustomerContact = data['contact'];
        String Tableno = data['tableno'];
        // String tableservent = data['servent'];
        String count = data['count'];
        String totalQty = totalQuantityString;
        String totalamt = data['amount'];
        String discount = data['discount'];
        String FinalAmt = data['finalamount'];
        String Customername;
        if (data['cusname'] == "null") {
          Customername = "";
        } else {
          Customername = data['cusname'];
        }
        String CustomerContact;
        if (data['contact'] == "null") {
          CustomerContact = "";
        } else {
          CustomerContact = data['contact'];
        }

        String tableservent;
        if (data['servent'] == "null") {
          tableservent = "";
        } else {
          tableservent = data['servent'];
        }

        String sgst25;
        if (data['cgst25'] == "0.0") {
          sgst25 = "";
        } else {
          sgst25 = data['cgst25'];
        }
        String sgst6;
        if (data['cgst6'] == "0.0") {
          sgst6 = "";
        } else {
          sgst6 = data['cgst6'];
        }
        String sgst9;
        if (data['cgst9'] == "0.0") {
          sgst9 = "";
        } else {
          sgst9 = data['cgst9'];
        }
        String sgst14;
        if (data['cgst14'] == "0.0") {
          sgst14 = "";
        } else {
          sgst14 = data['cgst14'];
        }

        List<String> productDetails = [];
        for (var data in Purchasedetailstabledata) {
          // Format each product detail as "{productName},{amount}"
          productDetails.add(
              "${data['Itemname'].toString()}-${data['rate'].toString()}-${data['qty'].toString()}");
        }

        String productDetailsString = productDetails.join(',');
        // print("product details : $productDetailsString   ");
        // print(
        //     "billno : $billno   , date : $date ,  paytype : $paytype ,    time :$time    ,customername : $Customername,  customercontact : $CustomerContact  ,    table No : $Tableno,   Tableservent : $tableservent,    total count :  $count,  total qty : $totalQty,    totalamt : $totalamt,    discount amt : $discount,    finalamount:  $FinalAmt");
        print(
            "url : http://127.0.0.1:8000/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString");

        print(
            "sgst25 : $sgst25  ,  sgst6 :   $sgst6 , sgst 9 :   $sgst9  ,   sgst14:   $sgst14");

        final response = await http.get(Uri.parse(
            'http://127.0.0.1:8000/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString'));

        if (response.statusCode == 200) {
          // If the server returns a 200 OK response, print the response body.
          print('Response: ${response.body}');
        } else {
          // If the server did not return a 200 OK response, print the status code.
          print('Failed with status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle any potential errors.
        print('Error: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Sales Details', style: HeadingStyle),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      Purchasedetailstabledata = [];
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Responsive.isDesktop(context)
                    ? Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BillNo',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 100
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 27,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: data['billno'] ?? ''),
                                      onChanged: (newValue) {
                                        // BillnoController.text = newValue;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: textStyle),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Name',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.25,
                                child: Container(
                                  height: 29,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['cusname'] ?? ''),
                                    onChanged: (newValue) {
                                      // BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: textStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 100
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 27,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: formattedTime ?? ''),
                                      onChanged: (newValue) {
                                        // BillnoController.text = newValue;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: textStyle),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Table No',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.25,
                                child: Container(
                                  height: 29,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: data['tableno'] ?? ''),
                                      onChanged: (newValue) {
                                        // BillnoController.text = newValue;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: textStyle),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BillNo',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 27,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                              text: data['billno'] ?? ''),
                                          onChanged: (newValue) {
                                            // BillnoController.text = newValue;
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 7.0,
                                            ),
                                          ),
                                          style: textStyle),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Name',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.25,
                                    child: Container(
                                      height: 29,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                              text: data['cusname'] ?? ''),
                                          onChanged: (newValue) {
                                            // BillnoController.text = newValue;
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 7.0,
                                            ),
                                          ),
                                          style: textStyle),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 27,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                              text: formattedTime ?? ''),
                                          onChanged: (newValue) {
                                            // BillnoController.text = newValue;
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 7.0,
                                            ),
                                          ),
                                          style: textStyle),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Table No',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.25,
                                    child: Container(
                                      height: 29,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                              text: data['tableno'] ?? ''),
                                          onChanged: (newValue) {
                                            // BillnoController.text = newValue;
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 7.0,
                                            ),
                                          ),
                                          style: textStyle),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Responsive.isMobile(context)
                      ? Axis.horizontal
                      : Axis.vertical,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: SingleChildScrollView(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 350 : 350,
                            width: Responsive.isDesktop(context) ? 1000 : 450,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: subcolor,
                                              ),
                                              child: Center(
                                                child: Text("Item",
                                                    textAlign: TextAlign.center,
                                                    style: commonWhiteStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: subcolor,
                                              ),
                                              child: Center(
                                                child: Text("Rate",
                                                    textAlign: TextAlign.center,
                                                    style: commonWhiteStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: subcolor,
                                              ),
                                              child: Center(
                                                child: Text("Qty",
                                                    textAlign: TextAlign.center,
                                                    style: commonWhiteStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: subcolor,
                                              ),
                                              child: Center(
                                                child: Text("TotalRetail",
                                                    textAlign: TextAlign.center,
                                                    style: commonWhiteStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: subcolor,
                                              ),
                                              child: Center(
                                                child: Text("TotalAmt",
                                                    textAlign: TextAlign.center,
                                                    style: commonWhiteStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: subcolor,
                                              ),
                                              child: Center(
                                                child: Text("RetailRate",
                                                    textAlign: TextAlign.center,
                                                    style: commonWhiteStyle),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (Purchasedetailstabledata.isNotEmpty)
                                      ...Purchasedetailstabledata.asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        Map<String, dynamic> data = entry.value;
                                        var Itemname =
                                            data['Itemname'].toString();
                                        var rate = data['rate'].toString();

                                        var retailrate =
                                            data['retail'].toString();
                                        var qty = data['qty'].toString();
                                        var amount = data['amount'].toString();

                                        bool isEvenRow = index % 2 ==
                                            0; // Using index for row color
                                        Color? rowColor = isEvenRow
                                            ? Color.fromARGB(224, 255, 255, 255)
                                            : Color.fromARGB(
                                                224, 255, 255, 255);

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 10,
                                            bottom: 5.0,
                                            top: 5.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 226, 225, 225),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(Itemname,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 226, 225, 225),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(rate,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 226, 225, 225),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(qty,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 226, 225, 225),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(retailrate,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 226, 225, 225),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(amount,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 226, 225, 225),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(rate,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _printResult();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      child: Text("Print", style: commonWhiteStyle),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      child: Text("Preview", style: commonWhiteStyle),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      child: Text("Close", style: commonWhiteStyle),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tableView() {
    _calculateTotalSales();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection:
          Responsive.isMobile(context) ? Axis.horizontal : Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 365,
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 450,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.80
                        : MediaQuery.of(context).size.width * 1.8,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0, right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("BillNo",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Date",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Customers",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Count",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("PaidAmount",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tableData.isNotEmpty)
                            ...tableData.asMap().entries.map((entry) {
                              int index = entry.key;

                              Map<String, dynamic> data = entry.value;
                              var billno = data['billno'].toString();
                              var dt = data['dt'].toString();
                              var cusname = data['cusname'].toString();
                              var count = data['count'].toString();
                              var paidamount = data['paidamount'].toString();
                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 0.0, right: 0, top: 5.0, bottom: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // purchasePaymentDetails(data);
                                    fetchsalesdetails(data);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(billno,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(dt,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(cusname,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(count,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(paidamount,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()
                          else ...{
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 60.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/imgs/document.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      Center(
                                        child: Text(
                                            'No transactions available to generate report',
                                            style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          }
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> createExcel(
    List<String> columnNames, List<List<dynamic>> data) async {
  try {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
      final Range range = sheet.getRangeByIndex(1, colIndex + 1);
      range.setText(columnNames[colIndex]);
      range.cellStyle.backColor = '#550A35';
      range.cellStyle.fontColor = '#F5F5F5';
    }

    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final List<dynamic> rowData = data[rowIndex];
      for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
        range.setText(rowData[colIndex].toString());
      }
    }

    final List<int> bytes = workbook.saveAsStream();

    try {
      workbook.dispose();
    } catch (e) {
      print('Error during workbook disposal: $e');
    }

    final now = DateTime.now();
    final formattedDate =
        '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'SalesReport_DateWise ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel SalesReport_DateWise ($formattedDate).xlsx'
          : '$path/Excel SalesReport_DateWise ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
