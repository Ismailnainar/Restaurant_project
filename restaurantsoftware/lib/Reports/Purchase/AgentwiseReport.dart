import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
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
  runApp(AgentwisePurchasereport());
}

class AgentwisePurchasereport extends StatefulWidget {
  @override
  State<AgentwisePurchasereport> createState() =>
      _AgentwisePurchasereportState();
}

class _AgentwisePurchasereportState extends State<AgentwisePurchasereport> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> PaymenttableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  late DateTime selecteddt;
  @override
  void initState() {
    super.initState();

    fetchSuppliername();
  }

  TextEditingController Suppliernamecontroller = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController totalBalanceController = TextEditingController();

  Future<void> fetchcustomerPaymentdetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchasePayments/$cusid';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
          jsonData['results']); // Extract 'results' from JSON

      String Suppliername = Suppliernamecontroller.text;

      // Filter the results where 'agentname' matches Suppliername
      List<Map<String, dynamic>> filteredResults = results
          .where((payment) => payment['agentname'] == Suppliername)
          .toList();
      logreports("PurchaseAgentReport: ${Suppliername}_Viewd");

      setState(() {
        PaymenttableData = filteredResults;
      });
    }
  }

  Future<void> fetchPurchaseDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String Suppliername = Suppliernamecontroller.text;
    String apiUrl = '$IpAddress/AgentwiseSalesReport/$cusid/$Suppliername';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData);
      setState(() {
        tableData = results;
      });
    }
  }

  Future<void> fetchtotalamtdetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String Suppliername = Suppliernamecontroller.text;
    String apiUrl = '$IpAddress/AgentwiseSalesReport/$cusid/$Suppliername';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData);

      double finalAmount = 0;
      double balanceamount = 0;
      double paidAmount = 0;

      for (var result in results) {
        finalAmount += double.parse(result['total'] ?? '0');
        paidAmount += double.parse(result['total'] ?? '0');
        balanceamount += double.parse(result['total'] ?? '0');
      }

      setState(() {
        tableData = results;
        finalAmountController.text = finalAmount.toStringAsFixed(2);
        paidAmountController.text = paidAmount.toStringAsFixed(2);
        totalBalanceController.text = balanceamount.toStringAsFixed(2);
      });
    }
  }

  List<String> SuppliernameList = [];

  Future<void> fetchSuppliername() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PurchaseSupplierNames/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          SuppliernameList.addAll(
              results.map<String>((item) => item['name'].toString()));

          hasNextPage = data['name'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $SuppliernameList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? selectedValue;

  int? _selectedEmpIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget SuppliernameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                SuppliernameList.indexOf(Suppliernamecontroller.text);
            if (currentIndex < SuppliernameList.length - 1) {
              setState(() {
                _selectedEmpIndex = currentIndex + 1;
                Suppliernamecontroller.text =
                    SuppliernameList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                SuppliernameList.indexOf(Suppliernamecontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedEmpIndex = currentIndex - 1;
                Suppliernamecontroller.text =
                    SuppliernameList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: Suppliernamecontroller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return SuppliernameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return SuppliernameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = SuppliernameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedEmpIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedEmpIndex == null &&
                          SuppliernameList.indexOf(
                                  Suppliernamecontroller.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion,
                    style: DropdownTextStyle,
                  ),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) async {
          setState(() {
            Suppliernamecontroller.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
          });

          await logreports(
              "PurchaseAgentReport: ${Suppliernamecontroller.text}_Viewd");
          await fetchcustomerPaymentdetails();
          await fetchPurchaseDetails();
          await fetchpaymentData();
          await fetchPurchaseRoundAmount(
              double.parse(finalAmountController.text));
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> Salesdetailstabledata = [];

  Future<void> FetchPaymentdetailsamounts(Map<String, dynamic> data) async {
    String id = data["id"].toString(); // Convert Id to String
    final url = '$IpAddress/PurchaseRoundDetailsalldatas/$id';
    print("url : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('PurchaseDetails')) {
          try {
            String salesDetailsString = responseData['PurchaseDetails'];
            List<String> salesDetailsRecords = salesDetailsString
                .split('}{'); // Split by '}{' to separate records
            for (var record in salesDetailsRecords) {
              // Clean up the record by removing '{' and '}'
              record = record.replaceAll('{', '').replaceAll('}', '');
              List<String> keyValuePairs = record.split(',');
              Map<String, dynamic> salesDetail = {};
              for (var pair in keyValuePairs) {
                List<String> parts = pair.split(':');
                String key = parts[0].trim();
                String value = parts[1].trim();
                // Remove surrounding quotes if any
                if (value.startsWith("'") && value.endsWith("'")) {
                  value = value.substring(1, value.length - 1);
                }
                salesDetail[key] = value;
              }
              Salesdetailstabledata.add({
                'item': salesDetail['item'],
                'rate': salesDetail['rate'],
                'qty': salesDetail['qty'],
                'total': salesDetail['total'],
              });
            }
            // Print Paymentdetailsamounts after setting state
            print('Sales Payment Details: $Salesdetailstabledata');
            SalesPaymentDetails(data);
          } catch (e) {
            throw FormatException('Invalid salespaymentdetails format');
          }
        } else {
          throw Exception(
              'Invalid response format: salespaymentdetails not found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void SalesPaymentDetails(Map<String, dynamic> data) {
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
                  Text(
                    'Purchase Payments',
                    style: HeadingStyle,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      Salesdetailstabledata = [];
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
                                          text: data['serialno'] ?? ''),
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
                                'Supplier Name',
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
                                          text: data['purchasername'] ?? ''),
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
                                              text: data['serialno'] ?? ''),
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
                                    'Supplier Name',
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
                                              text:
                                                  data['purchasername'] ?? ''),
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
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 350 : 350,
                      width: MediaQuery.of(context).size.width * 0.7,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          child: Text("Amount",
                                              textAlign: TextAlign.center,
                                              style: commonWhiteStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (Salesdetailstabledata.isNotEmpty)
                                ...Salesdetailstabledata.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> data = entry.value;
                                  var item = data['item'].toString();
                                  var rate = data['rate'].toString();
                                  var qty = data['qty'].toString();
                                  var total = data['total'].toString();
                                  var date = data['dt'].toString();

                                  bool isEvenRow = index % 2 ==
                                      0; // Using index for row color
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

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
                                              child: Text(item,
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
                                              child: Text(rate,
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
                                              child: Text(qty,
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
                                              child: Text(total,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
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
          actions: [],
        ),
      ),
    );
  }

  Future<void> fetchpaymentData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchasePayments/$cusid';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalPayAMount =
        0; // Variable to store total amount for agentname "jasim"

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Iterate through each entry in the results
      for (var entry in results) {
        // Check if agentname is "jasim"
        if (entry['agentname'] == Suppliernamecontroller.text) {
          // Parse and add the amount to totalPayAMount
          double amount = double.parse(entry['amount'] ?? '0');
          totalPayAMount += amount;
        }
      }
      // print("totalamnont:: $totalPayAMount");
      paidAmountController.text = totalPayAMount.toString();
      fetchPurchaseRoundAmount(totalPayAMount);
    }
  }

  Future<void> fetchPurchaseRoundAmount(double totalPayAmount) async {
    String? cusid = await SharedPrefs
        .getCusId(); // Assuming SharedPrefs is correctly implemented
    double totalPurchasePayment = 0;

    String apiUrl = '$IpAddress/PurchaseRoundDetails/$cusid';

    try {
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        // Check if jsonData is not null and contains 'results' array
        if (jsonData != null && jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            String? purchaserName = entry['purchasername'];
            double amount = double.parse(entry['total'] ?? '0');

            // Assuming Suppliernamecontroller is accessible in this scope
            if (purchaserName != null &&
                purchaserName == Suppliernamecontroller.text) {
              totalPurchasePayment += amount;
            }
          }
        } else {
          throw Exception('Invalid or empty response from server');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

      double differencePaymentAmount = totalPurchasePayment - totalPayAmount;

      // print(
      //     "$differencePaymentAmount = $totalPurchasePayment - $totalPayAmount");

      // Assuming finalAmountController and totalBalanceController are correctly defined
      finalAmountController.text = totalPurchasePayment.toString();
      totalBalanceController.text = differencePaymentAmount.toString();
    } catch (e) {
      print('Error fetching data: $e');
      // Handle errors as needed, e.g., show error message to the user
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
                          Text(
                            'Purchase Report (AgentWise Purchase)',
                            style: HeadingStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Agent Name',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? 150
                                      : MediaQuery.of(context).size.width *
                                          0.35,
                                  child: Container(
                                    height: 24,
                                    width: 200,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Container(
                                          child: SuppliernameDropdown()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: ElevatedButton(
                              onPressed: () {
                                fetchcustomerPaymentdetails();
                                fetchPurchaseDetails();
                                // fetchtotalamtdetails();
                                fetchpaymentData();
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
                                size: 18,
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
                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      List<Map<String, dynamic>> tableData1 =
                                          tableData
                                              .map((data) => {
                                                    'serialno':
                                                        data['serialno'],
                                                    'date': data['date'],
                                                    'count': data['count'],
                                                    'total': data['total']
                                                  })
                                              .toList();

                                      List<Map<String, dynamic>> tableData2 =
                                          PaymenttableData.map((data) => {
                                                'id': data['id'],
                                                'date': data['date'],
                                                'paytype': data['paytype'],
                                                'amount': data['amount']
                                              }).toList();

                                      List<List<dynamic>> purchaseDetailsData =
                                          tableData1
                                              .map((map) => map.values.toList())
                                              .toList();
                                      List<String> purchaseDetailsColumnNames =
                                          tableData1.isNotEmpty
                                              ? tableData1.first.keys.toList()
                                              : [];

                                      List<List<dynamic>>
                                          purcahsePaymentDetailsData =
                                          tableData2
                                              .map((map) => map.values.toList())
                                              .toList();
                                      List<String>
                                          purchasePaymentDetailsColumnNames =
                                          tableData2.isNotEmpty
                                              ? tableData2.first.keys.toList()
                                              : [];

                                      await createExcel(
                                          purchaseDetailsColumnNames,
                                          purchaseDetailsData,
                                          purchasePaymentDetailsColumnNames,
                                          purcahsePaymentDetailsData);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: subcolor,
                                        padding: EdgeInsets.only(
                                            left: 7,
                                            right: 7,
                                            top: 3,
                                            bottom: 3),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: SvgPicture.asset(
                                            'assets/imgs/excel.svg',
                                            width: 20,
                                            height: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text("Export", style: commonWhiteStyle),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              _tableview(),
                              SizedBox(height: 20),
                              Responsive.isDesktop(context)
                                  ? Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            'Sales Amt:   ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(finalAmountController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            'Paid Amt:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(paidAmountController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            'Total Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(totalBalanceController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            'Sales Amt:   ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(finalAmountController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, top: 10),
                                          child: Text(
                                            'Paid Amt:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(paidAmountController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, top: 10),
                                          child: Text(
                                            'Total Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(totalBalanceController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      )
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

  Widget _tableview() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (Responsive.isDesktop(context)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: SingleChildScrollView(
              child: Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
                width: Responsive.isDesktop(context) ? screenWidth * 0.45 : 500,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Purchase Report Details',
                                style: commonLabelTextStyle,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "RecNo",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Date",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Itemcount",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Amount",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
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
                            var paymentid = data['id'].toString();

                            var billno = data['serialno'].toString();
                            var dt = data['date'].toString();
                            var count = data['count'].toString();

                            var amount = data['total'].toString();
                            bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                            Color? rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return GestureDetector(
                              onTap: () {
                                // SalesPaymentDetails(data);
                                FetchPaymentdetailsamounts(data);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                    bottom: 5.0,
                                    top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          child: Text(amount,
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
                                        style: textStyle,
                                      ),
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
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: SingleChildScrollView(
              child: Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
                width: Responsive.isDesktop(context) ? 600 : 550,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text('Purchase Payment Details',
                                  style: commonLabelTextStyle),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text("PayNo",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
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
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text("PayType",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text("Amount",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (PaymenttableData.isNotEmpty)
                          ...PaymenttableData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> data = entry.value;
                            var paymentid = data['id'].toString();
                            var dt = data['date'].toString();
                            var paymenttype = data['paytype'].toString();
                            var amount = data['amount'].toString();
                            bool isEvenRow =
                                PaymenttableData.indexOf(data) % 2 == 0;
                            Color? rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return GestureDetector(
                              onTap: () {
                                // SalesPaymentDetails(data);

                                // FetchPaymentdetailsamounts(data);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                    bottom: 5.0,
                                    top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          child: Text(paymentid,
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
                                          child: Text(paymenttype,
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
                                          child: Text(amount,
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
                                        style: textStyle,
                                      ),
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
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection:
                Responsive.isMobile(context) ? Axis.horizontal : Axis.vertical,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 365 : 365,
                      width: Responsive.isDesktop(context) ? 1000 : 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('Purchase Report Details',
                                        style: commonLabelTextStyle),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text("RecNo",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
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
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text("Itemcount",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text("Amount",
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
                                  var paymentid = data['id'].toString();

                                  var billno = data['serialno'].toString();
                                  var dt = data['date'].toString();
                                  var count = data['count'].toString();

                                  var amount = data['total'].toString();
                                  bool isEvenRow =
                                      tableData.indexOf(data) % 2 == 0;
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

                                  return GestureDetector(
                                    onTap: () {
                                      // SalesPaymentDetails(data);
                                      // FetchPaymentdetailsamounts(data);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 10,
                                          bottom: 5.0,
                                          top: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 30,
                                              width: 255.0,
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
                                              width: 255.0,
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
                                              width: 255.0,
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
                                              width: 255.0,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(amount,
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
          SingleChildScrollView(
            scrollDirection:
                Responsive.isMobile(context) ? Axis.horizontal : Axis.vertical,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 365 : 365,
                      width: Responsive.isDesktop(context) ? 1000 : 450,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Purchase Payment Details',
                                      style: HeadingStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "PayNo",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Date",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "PayType",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Amount",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (PaymenttableData.isNotEmpty)
                                ...PaymenttableData.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> data = entry.value;
                                  var paymentid = data['id'].toString();
                                  var dt = data['date'].toString();
                                  var paymenttype = data['paytype'].toString();
                                  var amount = data['amount'].toString();
                                  bool isEvenRow =
                                      PaymenttableData.indexOf(data) % 2 == 0;
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

                                  return GestureDetector(
                                    onTap: () {
                                      // SalesPaymentDetails(data);

                                      FetchPaymentdetailsamounts(data);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 10,
                                          bottom: 5.0,
                                          top: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 30,
                                              width: 255.0,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(paymentid,
                                                    textAlign: TextAlign.center,
                                                    style: TableRowTextStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 30,
                                              width: 255.0,
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
                                              width: 255.0,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(paymenttype,
                                                    textAlign: TextAlign.center,
                                                    style: TableRowTextStyle),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 30,
                                              width: 255.0,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(amount,
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
        ],
      );
    }
  }
}

Future<void> createExcel(List<String> columnNames1, List<List<dynamic>> data1,
    List<String> columnNames2, List<List<dynamic>> data2) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  // Add heading for Sales Details
  final Range salesDetailsHeading = sheet.getRangeByIndex(1, 1);
  salesDetailsHeading.setText('Purchase Report Details');
  salesDetailsHeading.cellStyle.bold = true;

  // Write Sales Details column names
  for (int colIndex = 0; colIndex < columnNames1.length; colIndex++) {
    final Range range = sheet.getRangeByIndex(2, colIndex + 1);
    range.setText(columnNames1[colIndex]);
    range.cellStyle.backColor = '#550A35';
    range.cellStyle.fontColor = '#F5F5F5';
  }

  // Write Sales Details data
  for (int rowIndex = 0; rowIndex < data1.length; rowIndex++) {
    final List<dynamic> rowData = data1[rowIndex];
    for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
      final Range range = sheet.getRangeByIndex(rowIndex + 3, colIndex + 1);
      range.setText(rowData[colIndex].toString());
    }
  }

  int startRow = data1.length + 5;

  // Add heading for Sales Payment Details
  final Range salesPaymentDetailsHeading = sheet.getRangeByIndex(startRow, 1);
  salesPaymentDetailsHeading.setText('Purchase Payment Details');
  salesPaymentDetailsHeading.cellStyle.bold = true;

  // Write Sales Payment Details column names
  for (int colIndex = 0; colIndex < columnNames2.length; colIndex++) {
    final Range range = sheet.getRangeByIndex(startRow + 1, colIndex + 1);
    range.setText(columnNames2[colIndex]);
    range.cellStyle.backColor = '#550A35';
    range.cellStyle.fontColor = '#F5F5F5';
  }

  // Write Sales Payment Details data
  for (int rowIndex = 0; rowIndex < data2.length; rowIndex++) {
    final List<dynamic> rowData = data2[rowIndex];
    for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
      final Range range =
          sheet.getRangeByIndex(rowIndex + startRow + 2, colIndex + 1);
      range.setText(rowData[colIndex].toString());
    }
  }

  try {
    final List<int> bytes = workbook.saveAsStream();
    final now = DateTime.now();
    final formattedDate =
        '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute(
            'download', 'PurchaseReport_AgentWise ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel PurchaseReport_AgentWise ($formattedDate).xlsx'
          : '$path/Excel PurchaseReport_AgentWise ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } finally {
    workbook.dispose();
  }
}
