import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
  runApp(CustomerWiseReports());
}

class CustomerWiseReports extends StatefulWidget {
  @override
  State<CustomerWiseReports> createState() => _CustomerWiseReportsState();
}

class _CustomerWiseReportsState extends State<CustomerWiseReports> {
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

    fetchCustomerName();
  }

  TextEditingController CustomerNamecontroller = TextEditingController();
  TextEditingController CustomerContactController = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  TextEditingController creditAmountController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  Future<void> fetchcustomerPaymentdetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/SalesPaymentRoundDetails/$cusid';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData);
      String customername = CustomerNamecontroller.text;

      List<Map<String, dynamic>> filteredResults =
          results.where((payment) => payment['name'] == customername).toList();

      // print("Filtered table data of payments: $filteredResults");

      setState(() {
        logreports(
            "SalesCustomerWiseReport: ${CustomerContactController.text}_Viewd");

        PaymenttableData = filteredResults;
      });
      // print("paymentdetails L $PaymenttableData");
    }
  }

  Future<void> fetchSalesDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String customerName = CustomerNamecontroller.text;
    String apiUrl = '$IpAddress/CusnamewiseSalesReport/$cusid/$customerName';
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
    String customerName = CustomerNamecontroller.text;
    String apiUrl = '$IpAddress/CusnamewiseSalesReport/$cusid/$customerName';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData);

      double finalAmount = 0;
      double creditAmount = 0;
      double paidAmount = 0;

      for (var result in results) {
        finalAmount += double.parse(result['finalamount'] ?? '0');
        if (result['paytype'] == 'Credit') {
          creditAmount += double.parse(result['finalamount'] ?? '0');
        }
        paidAmount += double.parse(result['paidamount'] ?? '0');
      }

      double totalAmount = finalAmount - paidAmount;

      print("$totalAmount  =  $finalAmount  -  $paidAmount");
      setState(() {
        tableData = results;
        finalAmountController.text = finalAmount.toStringAsFixed(2);
        creditAmountController.text = creditAmount.toStringAsFixed(2);
        paidAmountController.text = paidAmount.toStringAsFixed(2);
        totalAmountController.text = totalAmount.toStringAsFixed(2);
      });
    }
  }

  List<String> CustomerNameList = [];

  Future<void> fetchCustomerName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/SalesCustomer/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          CustomerNameList.addAll(
              results.map<String>((item) => item['cusname'].toString()));

          hasNextPage = data['cusname'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $CustomerNameList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? selectedValue;

  int? _selectedProdIndex;

  bool _ProdNamefilterEnabled = true;
  int? _ProdNamehoveredIndex;

  Widget CustomerNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNamecontroller.text);
            if (currentIndex < CustomerNameList.length - 1) {
              setState(() {
                _selectedProdIndex = currentIndex + 1;
                CustomerNamecontroller.text =
                    CustomerNameList[currentIndex + 1];
                _ProdNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNamecontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProdIndex = currentIndex - 1;
                CustomerNamecontroller.text =
                    CustomerNameList[currentIndex - 1];
                _ProdNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedValue = suggestion;
              CustomerNamecontroller.text = suggestion!;
              _ProdNamefilterEnabled = false;
            });
            await logreports(
                "SalesCustomerWiseReport: ${CustomerContactController.text}_Viewd");

            await fetchCustomerContact();
            await fetchcustomerPaymentdetails();
            await fetchSalesDetails();
            await fetchtotalamtdetails();
          },
          controller: CustomerNamecontroller,
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
              _ProdNamefilterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_ProdNamefilterEnabled && pattern.isNotEmpty) {
            return CustomerNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return CustomerNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = CustomerNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProdNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProdNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProdIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProdIndex == null &&
                          CustomerNameList.indexOf(
                                  CustomerNamecontroller.text) ==
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
        onSuggestionSelected: (String? suggestion) async {
          setState(() {
            selectedValue = suggestion;
            CustomerNamecontroller.text = suggestion!;
            _ProdNamefilterEnabled = false;
          });
          await logreports(
              "SalesCustomerWiseReport: ${CustomerContactController.text}_Viewd");

          await fetchCustomerContact();
          await fetchcustomerPaymentdetails();
          await fetchSalesDetails();
          await fetchtotalamtdetails();
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

  Future<void> fetchCustomerContact() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/SalesCustomer/$cusid';
    String cusname = CustomerNamecontroller.text;
    bool contactFound = false;

    try {
      String url = baseUrl;
      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each supplier entry
          for (var entry in results) {
            if (entry['cusname'] == cusname) {
              // Retrieve the contact number for the supplier
              String contactno = entry['contact'];

              if (contactno.isNotEmpty) {
                CustomerContactController.text = contactno;
                // print("Contact number for $supplierName: $contactno");
                contactFound = true;
                break; // Exit the loop once the contact number is found
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or contact number found
            break;
          }
        } else {
          throw Exception(
              'Failed to load supplier contact information: ${response.reasonPhrase}');
        }
      }

      // Print a message if contact number not found
      if (!contactFound) {
        print("No contact number found for $cusname");
      }
    } catch (e) {
      print('Error fetching supplier contact information: $e');
    }
  }

  List<Map<String, dynamic>> Salesdetailstabledata = [];

  Future<void> FetchPaymentdetailsamounts(Map<String, dynamic> data) async {
    String? cusid = await SharedPrefs.getCusId();
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
            String salesDetailsString = responseData['SalesDetails'];
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
                'billno': salesDetail['salesbillno'],
                'amount': salesDetail['amount'],
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
                  Text('Sales Payments', style: HeadingStyle),
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
                                  height: 24,
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
                                  height: 24,
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
                                'Contact',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: data['contact'] ?? ''),
                                      onChanged: (newValue) {
                                        CustomerContactController.text =
                                            newValue;
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
                                'Date',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: DateTimePicker(
                                    controller: TextEditingController(
                                        text: data['dt'] ?? ''),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    dateLabelText: '',
                                    onChanged: (val) {
                                      // Update selectedDate when the date is changed
                                      setState(() {
                                        selecteddt = DateTime.parse(val);
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
                                    textInputAction: TextInputAction.next,
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
                                'Paytype',
                                style: commonLabelTextStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  color: Colors.grey[200],
                                  child: TextFormField(
                                    textInputAction: TextInputAction.next,
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['paytype'] ?? ''),
                                    onChanged: (newValue) {
                                      // BalanceAmtController.text = newValue;
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
                                'Amount',
                                style: textStyle,
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  color: Colors.grey[200],
                                  child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      // onFieldSubmitted: (_) => _fieldFocusChange(
                                      //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: data['finalamount'] ?? ''),
                                      onChanged: (newValue) {
                                        // BalanceAmtController.text = newValue;
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
                                      height: 24,
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
                                      height: 24,
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
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextFormField(
                                          textInputAction: TextInputAction.next,
                                          readOnly: true,
                                          controller: TextEditingController(
                                              text: data['contact'] ?? ''),
                                          onChanged: (newValue) {
                                            CustomerContactController.text =
                                                newValue;
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
                                    'Date',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: DateTimePicker(
                                        controller: TextEditingController(
                                            text: data['dt'] ?? ''),

                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        dateLabelText: '',
                                        onChanged: (val) {
                                          // Update selectedDate when the date is changed
                                          setState(() {
                                            selecteddt = DateTime.parse(val);
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
                                        textInputAction: TextInputAction.next,
                                        // onFieldSubmitted: (_) => _fieldFocusChange(
                                        //     context,
                                        //     DateFocuNode,
                                        //     BalanceFocuNode), // Switch focus to the next field
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Paytype',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      color: Colors.grey[200],
                                      child: TextFormField(
                                        textInputAction: TextInputAction.next,
                                        // onFieldSubmitted: (_) => _fieldFocusChange(
                                        //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['paytype'] ?? ''),
                                        onChanged: (newValue) {
                                          // BalanceAmtController.text = newValue;
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
                                    'Amount',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      color: Colors.grey[200],
                                      child: TextFormField(
                                        textInputAction: TextInputAction.next,
                                        // onFieldSubmitted: (_) => _fieldFocusChange(
                                        //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['finalamount'] ?? ''),
                                        onChanged: (newValue) {
                                          // BalanceAmtController.text = newValue;
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
                        color: Colors.grey[50],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Sales Billno",
                                                textAlign: TextAlign.center,
                                                style: commonWhiteStyle,
                                              ),
                                            ],
                                          ),
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Amount",
                                                textAlign: TextAlign.center,
                                                style: commonWhiteStyle,
                                              ),
                                            ],
                                          ),
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
                                  var billno = data['billno'].toString();
                                  var amount = data['amount'].toString();
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
                                              child: Text(
                                                billno,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle,
                                              ),
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
                                              child: Text(
                                                amount,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle,
                                              ),
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
                          Text('Sales Report (CustomerWise Sales)',
                              style: HeadingStyle),
                        ],
                      ),
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
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
                                      height: 24,
                                      width: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Container(
                                            child: CustomerNameDropdown()),
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
                                    'Contact',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.25,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextFormField(
                                          // focusNode: AmountFocusNode,
                                          textInputAction: TextInputAction.next,
                                          // onFieldSubmitted: (_) =>
                                          //     _fieldFocusChange(
                                          //         context,
                                          //         AmountFocusNode,
                                          //         saveButtonFocusNode),
                                          controller: CustomerContactController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
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
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  fetchCustomerContact();
                                  fetchcustomerPaymentdetails();
                                  fetchSalesDetails();
                                  fetchtotalamtdetails();
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
                                                    'id': data['id'],
                                                    'billno': data['billno'],
                                                    'dt': data['dt'],
                                                    'count': data['count'],
                                                    'finalamount':
                                                        data['finalamount']
                                                  })
                                              .toList();

                                      List<Map<String, dynamic>> tableData2 =
                                          PaymenttableData.map((data) => {
                                                'id': data['id'],
                                                'billno': data['billno'],
                                                'dt': data['dt'],
                                                'paymenttype':
                                                    data['paymenttype'],
                                                'reference': data['reference'],
                                                'amount': data['amount']
                                              }).toList();

                                      List<List<dynamic>> salesDetailsData =
                                          tableData1
                                              .map((map) => map.values.toList())
                                              .toList();
                                      List<String> salesDetailsColumnNames =
                                          tableData1.isNotEmpty
                                              ? tableData1.first.keys.toList()
                                              : [];

                                      List<List<dynamic>>
                                          salesPaymentDetailsData = tableData2
                                              .map((map) => map.values.toList())
                                              .toList();
                                      List<String>
                                          salesPaymentDetailsColumnNames =
                                          tableData2.isNotEmpty
                                              ? tableData2.first.keys.toList()
                                              : [];

                                      await createExcel(
                                          salesDetailsColumnNames,
                                          salesDetailsData,
                                          salesPaymentDetailsColumnNames,
                                          salesPaymentDetailsData);
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
                                  // Padding(
                                  //   padding: const EdgeInsets.only(
                                  //     right: 10.0,
                                  //   ),
                                  //   child: Container(
                                  //     height: 30,
                                  //     width: 110,
                                  //     child: TextField(
                                  //       onChanged: (value) {
                                  //         setState(() {
                                  //           searchText = value;
                                  //         });
                                  //       },
                                  //       decoration: InputDecoration(
                                  //         labelText: 'Search',
                                  //         suffixIcon: Icon(
                                  //           Icons.search,
                                  //           color: Colors.grey,
                                  //         ),
                                  //         floatingLabelBehavior:
                                  //             FloatingLabelBehavior.never,
                                  //         border: OutlineInputBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(1),
                                  //         ),
                                  //         enabledBorder: OutlineInputBorder(
                                  //           borderSide: BorderSide(
                                  //               color: Colors.grey, width: 1.0),
                                  //           borderRadius:
                                  //               BorderRadius.circular(1),
                                  //         ),
                                  //         focusedBorder: OutlineInputBorder(
                                  //           borderSide: BorderSide(
                                  //               color: Colors.grey, width: 1.0),
                                  //           borderRadius:
                                  //               BorderRadius.circular(1),
                                  //         ),
                                  //         contentPadding: EdgeInsets.only(
                                  //             left: 10.0, right: 4.0),
                                  //       ),
                                  //       style: TextStyle(fontSize: 12),
                                  //     ),
                                  //   ),
                                  // ),
                                  // Add Spacer to occupy the available space
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
                                            'Credit Amt:   ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(creditAmountController.text ?? '0') ?? 0)} /-',
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
                                            'Total Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(totalAmountController.text ?? '0') ?? 0)} /-',
                                            style: textStyle,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Wrap(
                                          alignment: WrapAlignment.start,
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
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  top: Responsive.isMobile(
                                                          context)
                                                      ? 10
                                                      : 0),
                                              child: Text(
                                                'Credit Amt:   ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(creditAmountController.text ?? '0') ?? 0)} /-',
                                                style: textStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  top: Responsive.isMobile(
                                                          context)
                                                      ? 10
                                                      : 0),
                                              child: Text(
                                                'Paid Amt:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(paidAmountController.text ?? '0') ?? 0)} /-',
                                                style: textStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  top: Responsive.isMobile(
                                                          context)
                                                      ? 10
                                                      : 0),
                                              child: Text(
                                                'Total Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(totalAmountController.text ?? '0') ?? 0)} /-',
                                                style: textStyle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
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

    if (Responsive.isDesktop(context)) {
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
                      Responsive.isDesktop(context) ? screenHeight * 0.60 : 300,
                  width: Responsive.isDesktop(context) ? 600 : 450,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
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
                                child:
                                    Text('Sales Details', style: HeadingStyle),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
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
                          if (tableData.isNotEmpty)
                            ...tableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> data = entry.value;
                              var paymentid = data['id'].toString();

                              var billno = data['billno'].toString();
                              var dt = data['dt'].toString();
                              var count = data['count'].toString();
                              ;
                              var amount = data['finalamount'].toString();
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
                    color: Colors.grey[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
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
                                child: Text('Sales Payment Details',
                                    style: HeadingStyle),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
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
                                      child: Text("Billno",
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
                                      child: Text("dt",
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
                                      child: Text("PayType",
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
                                      child: Text("Reference",
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
                          if (PaymenttableData.isNotEmpty)
                            ...PaymenttableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> data = entry.value;
                              var paymentid = data['id'].toString();

                              var billno = data['billno'].toString();

                              var dt = data['dt'].toString();
                              var paymenttype = data['paymenttype'].toString();

                              var reference = data['reference'].toString();
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            child: Text(reference,
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
          ],
        ),
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
                      height: Responsive.isDesktop(context) ? 345 : 300,
                      width: Responsive.isDesktop(context) ? 1000 : 350,
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
                                      'Sales Details',
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

                                  var billno = data['billno'].toString();
                                  var dt = data['dt'].toString();
                                  var count = data['count'].toString();
                                  ;
                                  var amount = data['amount'].toString();
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
                                                child: Text(
                                                  billno,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle,
                                                ),
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
                                                child: Text(
                                                  dt,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle,
                                                ),
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
                                                child: Text(
                                                  count,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle,
                                                ),
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
                                                child: Text(
                                                  amount,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle,
                                                ),
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
                  padding: Responsive.isMobile(context)
                      ? EdgeInsets.only(left: 20, right: 20, top: 10)
                      : EdgeInsets.only(left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 345 : 300,
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
                                    child: Text('Sales Payment Details',
                                        style: HeadingStyle),
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
                                          child: Text("Billno",
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
                                          child: Text("dt",
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
                                          child: Text("PayType",
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
                                          child: Text("Reference",
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
                              if (PaymenttableData.isNotEmpty)
                                ...PaymenttableData.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> data = entry.value;
                                  var paymentid = data['id'].toString();

                                  var billno = data['billno'].toString();

                                  var dt = data['dt'].toString();
                                  var paymenttype =
                                      data['paymenttype'].toString();

                                  var reference = data['reference'].toString();
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
                                                child: Text(reference,
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
  salesDetailsHeading.setText('Sales Details');
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
  salesPaymentDetailsHeading.setText('Sales Payment Details');
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
            'download', 'SalesReport_CustomerWise ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel SalesReport_CustomerWise ($formattedDate).xlsx'
          : '$path/Excel SalesReport_CustomerWise ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } finally {
    workbook.dispose();
  }
}
