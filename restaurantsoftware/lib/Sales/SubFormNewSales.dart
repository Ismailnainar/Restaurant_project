import 'dart:async';
import 'dart:io';

import 'package:restaurantsoftware/Sales/PrinterPage.dart';
import 'package:restaurantsoftware/Sales/printpreview.dart';
import 'package:restaurantsoftware/Settings/StaffDetails.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sales/NewSales.dart';
import 'package:restaurantsoftware/Settings/AddProductsDetails.dart';
import 'package:restaurantsoftware/Settings/GstDetails.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

import 'package:url_launcher/url_launcher.dart';

TextEditingController FinallyyyAmounttts = TextEditingController();

class salestableview extends StatefulWidget {
  final TextEditingController ProductSalesTypeController;
  final List<Map<String, dynamic>> SALEStabledata;
  final TextEditingController BillNOreset;
  final TextEditingController tableno;

  final TextEditingController customername;

  final TextEditingController customercontact;

  final TextEditingController scode;

  final TextEditingController sname;

  final TextEditingController paytype;

  final Function(TextEditingController) onFinalAmountButtonPressed;

  final FocusNode codeFocusNode;

  salestableview({
    required this.ProductSalesTypeController,
    required this.BillNOreset,
    required this.tableno,
    required this.customername,
    required this.customercontact,
    required this.scode,
    required this.sname,
    required this.paytype,
    required this.SALEStabledata,
    required this.onFinalAmountButtonPressed,
    required this.codeFocusNode,
  });

  @override
  State<salestableview> createState() => _salestableviewState();
  // Widget finalamtRS() {
  //   return _salestableviewState().finalamtRS();
  // }
}

class _salestableviewState extends State<salestableview> {
  String? selectItem;
  String upiId = 'thilothinibca-1@okicici'; // Your UPI ID
  String payeeName = 'Your Name'; // Payee Name
  String restaurantname = '';
  String address1 = '';
  String address2 = '';
  String gstno = '';
  String fassai = '';
  String? _baseUrl;
  String doorno = '';
  String area = '';
  String city = '';
  String pincode = '';
  String contact = '';
  TextEditingController ProductCodeController = TextEditingController();
  TextEditingController ProductNameController = TextEditingController();
  TextEditingController ProductAmountController = TextEditingController();
  TextEditingController QuantityController = TextEditingController();
  TextEditingController TotalAmtController = TextEditingController();
  TextEditingController ProductMakingCostController = TextEditingController();

  TextEditingController CGSTperccontroller = TextEditingController();
  TextEditingController SGSTPercController = TextEditingController();
  TextEditingController CGSTAmtController = TextEditingController();
  TextEditingController SGSTAmtController = TextEditingController();
  TextEditingController FinalAmtController = TextEditingController();

  TextEditingController Taxableamountcontroller = TextEditingController();
  TextEditingController SalesGstMethodController = TextEditingController();
  TextEditingController ProductCategoryController = TextEditingController();

  late List<Map<String, dynamic>> tableData;
  double totalAmount = 0.0;

  // FocusNode codeFocusNode = FocusNode();
  FocusNode itemFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode quantityFocusNode = FocusNode();
  FocusNode finaltotalFocusNode = FocusNode();
  FocusNode addbuttonFocusNode = FocusNode();

  FocusNode discountpercFocusNode = FocusNode();
  FocusNode discountAmtFocusNode = FocusNode();
  FocusNode FinalAmtFocusNode = FocusNode();
  FocusNode SavebuttonFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void initState() {
    super.initState();
    fetchProductNameList();
    fetchGSTMethod();
    tableData = widget.SALEStabledata;
    TotalAmtController.text = "0";
    QuantityController.text = "0";
    ProductAmountController.text = "0";
    SalesDisPercentageController.text = "0";
    FinalAmtController.text = "0";
    SalesDisAMountController.text = "0";
    FinallllAmttControllerrrr.addListener(() {
      double someAmount =
          double.tryParse(FinallllAmttControllerrrr.text) ?? 0.0;
      calFinaltotalAmount(someAmount);
    });
  }

  @override
  void dispose() {
    // codeFocusNode.dispose();
    itemFocusNode.dispose();
    amountFocusNode.dispose();
    quantityFocusNode.dispose();
    finaltotalFocusNode.dispose();
    addbuttonFocusNode.dispose();
    discountpercFocusNode.dispose();
    discountAmtFocusNode.dispose();
    FinalAmtFocusNode.dispose();
    SavebuttonFocusNode.dispose();
    FinallllAmttControllerrrr.dispose();
    FinallllAmttNotifierrrrrrr.dispose();
    super.dispose();
  }

  List<String> ProductNameList = [];

  Future<void> fetchProductNameList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductNameList.addAll(
              results.map<String>((item) => item['name'].toString()));
          // print("payment List : $ProductNameList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $ProductNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? ProductNameSelected;

  int? _selectedProductnameIndex;

  bool _isProductnameOptionsVisible = false;
  int? _ProductnamehoveredIndex;
  Widget _buildProductnameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 15,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    color: Colors.grey[100],
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.095
                        : MediaQuery.of(context).size.width * 0.25,
                    child: ProductnameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: Container(
                        width: 1350,
                        height: 800,
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            AddProductDetailsPage(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchproductName();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(color: subcolor),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ProductnameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProductnameIndex = currentIndex + 1;
                ProductNameController.text = ProductNameList[currentIndex + 1];
                _isProductnameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductnameIndex = currentIndex - 1;
                ProductNameController.text = ProductNameList[currentIndex - 1];
                _isProductnameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            FocusScope.of(context).requestFocus(widget.codeFocusNode);
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: itemFocusNode,
          onSubmitted: (String? suggestion) async {
            // if (isProductAlreadyExists(ProductNameSelected!)) {
            //   ProductNameSelected = '';
            //   _fieldFocusChange(context, itemFocusNode, codeFocusNode);
            //   productalreadyexist();
            // } else {

            widget.ProductSalesTypeController.text;
            await fetchproductcode();
            updateTotal();
            updatetaxableamount();
            updateCGSTAmount();
            updateSGSTAmount();
            updateFinalAmount();
            _fieldFocusChange(context, itemFocusNode, quantityFocusNode);
          },
          controller: ProductNameController,
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
          onChanged: (text) async {
            setState(() {
              _isProductnameOptionsVisible = true;
              ProductNameSelected = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProductnameOptionsVisible && pattern.isNotEmpty) {
            return ProductNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProductnamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProductnamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductnameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductnameIndex == null &&
                          ProductNameList.indexOf(ProductNameController.text) ==
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
            // if (isProductAlreadyExists(ProductNameSelected!)) {
            //   ProductNameSelected = '';
            //   _fieldFocusChange(context, itemFocusNode, codeFocusNode);
            //   productalreadyexist();
            // } else {

            widget.ProductSalesTypeController.text;
            fetchproductcode();
            updateTotal();
            updatetaxableamount();
            updateCGSTAmount();
            updateSGSTAmount();
            updateFinalAmount();
            ProductNameController.text = suggestion!;
            ProductNameSelected = suggestion;
            _isProductnameOptionsVisible = false;

            FocusScope.of(context).requestFocus(quantityFocusNode);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  bool isProductAlreadyExists(String productName) {
    // Assuming table data is stored in a List<Map<String, dynamic>> called tableData
    for (var item in tableData) {
      if (item['productName'] == productName) {
        return true;
      }
    }
    return false;
  }

  void productalreadyexist() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'This product is already in the table data.',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  Future<void> fetchproductName() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
    String ProductCode =
        ProductCodeController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductCodeController Name: $ProductCode");

    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each customer entry
          for (var entry in results) {
            if (entry['code'].toString().toLowerCase() == ProductCode) {
              // Convert to lowercase
              // Retrieve the contact number and address for the customer
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }
              String name = entry['name'];
              String agentId = entry['id'].toString();
              String makingcost = entry['makingcost'];
              String category = entry['category'];

              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (ProductCode.isNotEmpty) {
                ProductNameController.text = name;
                ProductAmountController.text = amount;
                ProductMakingCostController.text = makingcost;
                ProductCategoryController.text = category;
                CGSTperccontroller.text = cgstperc;
                SGSTPercController.text = sgstperc;

                contactFound = true;
                break; // Exit the loop once the contact number is found
              }
            }
          }

          // print("CGst Percentages:${CGSTperccontroller.text}");
          // print("Sgst Percentages:${SGSTPercController.text}");
          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or contact number found
            break;
          }
        } else {
          throw Exception(
              'Failed to load customer contact information: ${response.reasonPhrase}');
        }
      }

      // Print a message if contact number not found
      if (!contactFound) {}
    } catch (e) {
      print('Error fetching customer contact information: $e');
    }
  }

  Future<void> fetchproductcode() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
    String productName =
        ProductNameController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductNameController Name: $productName");
    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each product entry
          for (var entry in results) {
            if (entry['name'].toString().toLowerCase() == productName) {
              // Convert to lowercase
              // Retrieve the code and id for the product
              String code = entry['code'];
              String agentId = entry['id'].toString();

              // Determine the amount based on the salestype
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }

              String makingcost = entry['makingcost'];
              String category = entry['category'];
              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (productName.isNotEmpty) {
                ProductCodeController.text = code;
                CGSTperccontroller.text = cgstperc;
                ProductMakingCostController.text = makingcost;
                ProductCategoryController.text = category;

                SGSTPercController.text = sgstperc;
                ProductAmountController.text = amount;

                contactFound = true;
                break; // Exit the loop once the product information is found
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or product information found
            break;
          }
        } else {
          throw Exception(
              'Failed to load product information: ${response.reasonPhrase}');
        }
      }

      // Print a message if product information not found
      if (!contactFound) {
        // print("No product information found for $productName");
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchGSTMethod() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/GstDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    String gstMethod = ''; // Initialize GST method to empty string

    // Iterate through each entry in the JSON data
    for (var entry in jsonData) {
      // Check if the name is "Sales"
      if (entry['name'] == "Sales") {
        // Retrieve the GST method for "Sales"
        gstMethod = entry['gst'];
        break; // Exit the loop once the entry is found
      }
    }

    // Update rateController if needed
    if (gstMethod.isNotEmpty) {
      SalesGstMethodController.text = gstMethod;
      // print("GST method for Sales: ${SalesGstMethodController.text}");
      // print("GST method for Sales: $gstMethod");
    } else {
      print("No GST method found for Sales");
    }
  }

  void updateCGSTAmount() {
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * cgstPercentage);
    // Calculate the CGST amount
    double cgstAmount = numerator / 100;

    // Update the CGST amount controller
    CGSTAmtController.text = cgstAmount.toStringAsFixed(2);
    // print("CGST amont = ${CGSTAmtController.text}");
  }

  void updateSGSTAmount() {
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * sgstPercentage);
    // Calculate the CGST amount
    double sgstAmount = numerator / 100;

    // Update the CGST amount controller
    SGSTAmtController.text = sgstAmount.toStringAsFixed(2);
    // print("SGZGST amont = ${SGSTAmtController.text}");
  }

  void updateTotal() {
    double rate = double.tryParse(ProductAmountController.text) ?? 0;
    double quantity = double.tryParse(QuantityController.text) ?? 0;
    double total = rate * quantity;
    TotalAmtController.text =
        total.toStringAsFixed(2); // Format total to 2 decimal places
    // Taxableamountcontroller.text = total.toStringAsFixed(2);
  }

  void updatetaxableamount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;
    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(SGSTPercController.text) ?? 0;

    double numeratorPart1 = total;

    if (SalesGstMethodController.text == "Excluding") {
      // Calculate taxable amount excluding GST
      double taxableAmount = numeratorPart1;
      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else if (SalesGstMethodController.text == "Including") {
      double cgstsgst = cgstPercentage + sgstPercentage;
      double cgstnumerator = numeratorPart1 * cgstPercentage;
      double cgstdenominator = 100 + cgstsgst;
      double cgsttaxable = cgstnumerator / cgstdenominator;
      double sgstnumerator = numeratorPart1 * sgstPercentage;
      double sgstdenominator = 100 + cgstsgst;
      double sgsttaxable = sgstnumerator / sgstdenominator;

      double taxableAmount = numeratorPart1 - (cgsttaxable + sgsttaxable);

      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("cgst taxable amount : $cgsttaxable");
      // print("sgst taxable amount : $sgsttaxable");
      // print("Total taxable amount : $taxableAmount");
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else {
      double taxableAmount = numeratorPart1;
      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    }
  }

  void updateFinalAmount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;

    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double denominator = cgstAmount + sgstAmount;

    if (SalesGstMethodController.text == "Excluding") {
      double finalAmount = taxableAmount + denominator;
      // print("FIanl amount = ${taxableAmount} + ${denominator}");

      // Update the final amount controller
      FinalAmtController.text = finalAmount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    } else if (SalesGstMethodController.text == "Including") {
      double totalfinalamount = total;
      FinalAmtController.text = totalfinalamount.toStringAsFixed(2);
    } else {
      double taxableAmount = total;
      FinalAmtController.text = taxableAmount.toStringAsFixed(2);
    }
  }

  int nextId = 1;
  bool updateenable = false;
  void saveData() {
    // Check if any required field is empty
    if (ProductCodeController.text.isEmpty ||
        ProductNameController.text.isEmpty ||
        ProductAmountController.text.isEmpty ||
        QuantityController.text.isEmpty ||
        FinalAmtController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (QuantityController.text == '0' ||
        QuantityController.text == '') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity Check'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text('Kindly enter the quantity , Quantity must above 0'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (widget.paytype.text.toLowerCase() == 'credit' &&
        widget.customername.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details , when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(widget.codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productCode = ProductCodeController.text;

      String productName = ProductNameController.text;
      String amount = ProductAmountController.text;
      String quantity = QuantityController.text;
      String makingcost = ProductMakingCostController.text;
      String category = ProductCategoryController.text;
      String totalamt = FinalAmtController.text;
      String taxable = Taxableamountcontroller.text;

      String cgstPercentage = SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTperccontroller.text;
      String sgstPercentage = SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTPercController.text;
      String cgstAmount = SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTAmtController.text;
      String sgstAmount = SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTAmtController.text;

      bool productExists = false;

      for (var item in tableData) {
        if (item['productName'] == productName) {
          item['quantity'] =
              (int.parse(item['quantity']) + int.parse(quantity)).toString();

          item['Amount'] =
              (double.parse(item['Amount']) + double.parse(totalamt))
                  .toString();
          item['retail'] =
              (double.parse(item['retail']) + double.parse(taxable)).toString();
          item['cgstAmt'] =
              (double.parse(item['cgstAmt']) + double.parse(cgstAmount))
                  .toString();
          item['sgstAmt'] =
              (double.parse(item['sgstAmt']) + double.parse(sgstAmount))
                  .toString();
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        setState(() {
          tableData.add({
            'id': nextId++,
            'productCode': productCode,
            'productName': productName,
            'amount': amount,
            'quantity': quantity,
            "cgstAmt": cgstAmount,
            "sgstAmt": sgstAmount,
            "Amount": totalamt,
            "retail": taxable,
            "retailrate": amount,
            "cgstperc": cgstPercentage,
            "sgstperc": sgstPercentage,
            "makingcost": makingcost,
            "category": category,
          });
        });
      }

      setState(() {
        ProductCodeController.clear();
        ProductNameController.clear();
        ProductAmountController.clear();
        QuantityController.clear();
        FinalAmtController.clear();
        ProductNameSelected = '';
        updateenable = false;
      });
      updatefinaltabletotalAmount();
      processNewSalesEntry(context, FINALAMTCONTROLLWE);
    }
  }

  TextEditingController FinallllAmttControllerrrr = TextEditingController();
  final ValueNotifier<String> FinallllAmttNotifierrrrrrr =
      ValueNotifier<String>("0");

  void calFinaltotalAmount(double finalamountcontroller) {
    FinallllAmttNotifierrrrrrr.value = finalamountcontroller.toString();
    TextEditingController finalamtcontrollersimply =
        TextEditingController(text: finalamountcontroller.toString());

    // Pass the text value of the TextEditingController to the callback
    widget.onFinalAmountButtonPressed(finalamtcontrollersimply);

    // Print the updated value to the console
    print("finalamountttttttttt ${finalamtcontrollersimply.text}");
  }

  Widget finalamtRS() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 15),
      child: Container(
        width: Responsive.isDesktop(context)
            ? 580
            : MediaQuery.of(context).size.width * 0.75,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 45,
              width: Responsive.isDesktop(context)
                  ? 260
                  : MediaQuery.of(context).size.width * 0.75,
              color: Color.fromARGB(255, 225, 225, 225),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 0 : 0, top: 0),
                    child: Container(
                      width: Responsive.isDesktop(context) ? 70 : 70,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button action
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          backgroundColor: subcolor,
                          minimumSize: Size(45.0, 31.0),
                        ),
                        child: Text(
                          'RS. ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 20 : 20, top: 11),
                    child: Container(
                      width: Responsive.isDesktop(context) ? 85 : 85,
                      child: ValueListenableBuilder<String>(
                        valueListenable: FinallllAmttNotifierrrrrrr,
                        builder: (context, value, child) {
                          return Container(
                            height: 24,
                            width: 100,
                            child: Text(
                              "${NumberFormat.currency(symbol: '', decimalDigits: 0).format(double.tryParse(value) ?? 0)} /-",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void UpdateData() {
    // Check if any required field is empty
    if (ProductCodeController.text.isEmpty ||
        ProductNameController.text.isEmpty ||
        ProductAmountController.text.isEmpty ||
        QuantityController.text.isEmpty ||
        FinalAmtController.text.isEmpty ||
        UpdateidController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (QuantityController.text == '0' ||
        QuantityController.text == '') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity Check'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text('Kindly enter the quantity, Quantity must be above 0'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (widget.paytype.text.toLowerCase() == 'credit' &&
        widget.customername.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details, when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(widget.codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productCode = ProductCodeController.text;
      String productName = ProductNameController.text;
      String amount = ProductAmountController.text;
      String quantity = QuantityController.text;
      String makingcost = ProductMakingCostController.text;
      String category = ProductCategoryController.text;
      String totalamt = FinalAmtController.text;
      String taxable = Taxableamountcontroller.text;

      String cgstPercentage = SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTperccontroller.text;
      String sgstPercentage = SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTPercController.text;
      String cgstAmount = SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTAmtController.text;
      String sgstAmount = SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTAmtController.text;

      // Convert UpdateidController.text to integer
      int idToUpdate = int.tryParse(UpdateidController.text) ?? -1;

      if (idToUpdate == -1) {
        WarninngMessage(context); // Invalid ID
        return;
      }

      bool entryExists = false;
      setState(() {
        for (var entry in tableData) {
          if (entry['id'] == idToUpdate) {
            // Update the existing entry
            entry['productCode'] = productCode;
            entry['productName'] = productName;
            entry['amount'] = amount;
            entry['quantity'] = quantity;
            entry['cgstAmt'] = cgstAmount;
            entry['sgstAmt'] = sgstAmount;
            entry['Amount'] = totalamt;
            entry['retail'] = taxable;
            entry['retailrate'] = amount;
            entry['cgstperc'] = cgstPercentage;
            entry['sgstperc'] = sgstPercentage;
            entry['makingcost'] = makingcost;
            entry['category'] = category;
            entryExists = true;
            break;
          }
        }

        if (!entryExists) {
          WarninngMessage(context); // ID not found
        }
      });

      // Clear text fields
      setState(() {
        updateenable = false;
        ProductCodeController.clear();
        ProductNameController.clear();
        ProductAmountController.clear();
        QuantityController.clear();
        FinalAmtController.clear();
        ProductNameSelected = '';
      });

      updatefinaltabletotalAmount();
      processNewSalesEntry(context, FINALAMTCONTROLLWE);
    }
  }

  TextEditingController UpdateidController = TextEditingController();
  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 0, top: 5),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            // height: 200,
            height: Responsive.isDesktop(context) ? screenHeight * 0.55 : 320,
            // height: Responsive.isDesktop(context) ? 300 : 240,
            decoration: BoxDecoration(
              color: Colors.white,
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
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.7
                    : MediaQuery.of(context).size.width * 1.8,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fastfood,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 1),
                                  Text("Item",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Rate",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_box,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_atm,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Cgst ₹",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_atm,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Sgst ₹",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.currency_exchange_outlined,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Amount",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.currency_exchange_outlined,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Retail",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   height: Responsive.isDesktop(context) ? 25 : 30,
                        //   width: 80,
                        //   decoration: TableHeaderColor,
                        //   child: Center(
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       children: [
                        //         Icon(
                        //           Icons.currency_exchange_sharp,
                        //           size: 15,
                        //           color: Colors.blue,
                        //         ),
                        //         SizedBox(width: 5),
                        //         Text("RetailRate",
                        //             textAlign: TextAlign.center,
                        //             style: commonLabelTextStyle),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 365.0,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pie_chart,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("CGST %",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pie_chart,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("SGST %",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Action",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // if (tableData.isNotEmpty)
                  //   ...tableData.map((data) {
                  if (tableData.isNotEmpty)
                    ...tableData.asMap().entries.map((entry) {
                      int index = entry.key;

                      Map<String, dynamic> data = entry.value;

                      var id = data['id'].toString();
                      var productCode = data['productCode'].toString();

                      var productName = data['productName'].toString();
                      var amount = data['amount'].toString();
                      var quantity = data['quantity'].toString();
                      var cgstAmt = data['cgstAmt'].toString();
                      var sgstAmt = data['sgstAmt'].toString();
                      var Amount = data['Amount'].toString();
                      var retail = data['retail'].toString();
                      var retailrate = data['retailrate'] ?? 0;

                      var cgstperc = data['cgstperc'].toString();
                      var sgstperc = data['sgstperc'] ?? 0;
                      var makingcost = data['makingcost'] ?? 0;
                      var category = data['category'].toString();
                      // print("categoryyy: $category");
                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, top: 3, bottom: 3, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Tooltip(
                                  message: productName,
                                  child: Center(
                                    child: Text(productName,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(amount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(quantity,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(cgstAmt,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(sgstAmt,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(Amount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(retail,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   child: Container(
                            //     height: 30,
                            //     width: 265.0,
                            //     decoration: BoxDecoration(
                            //       color: rowColor,
                            //       border: Border.all(
                            //         color: Color.fromARGB(255, 226, 225, 225),
                            //       ),
                            //     ),
                            //     child: Center(
                            //       child: Text(retailrate,
                            //           textAlign: TextAlign.center,
                            //           style: TableRowTextStyle),
                            //     ),
                            //   ),
                            // ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(cgstperc,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(sgstperc,
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
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Container(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.edit_square,
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              print(
                                                  "print the ungiueeeee : $id");
                                              ProductCodeController.text =
                                                  data['productCode']
                                                      .toString();
                                              ProductNameController.text =
                                                  data['productName']
                                                      .toString();
                                              ProductAmountController.text =
                                                  data['amount'].toString();
                                              QuantityController.text =
                                                  data['quantity'].toString();
                                              FinalAmtController.text =
                                                  data['Amount'].toString();
                                              UpdateidController.text =
                                                  data['id'].toString();
                                              setState(() {
                                                updateenable = true;
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        quantityFocusNode);
                                              });
                                            },
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Container(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  index);
                                            },
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int getProductCount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
  }

  double getTotalTaxable(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['retail']!) ?? 0.0;
      totalQuantity += quantity;
    }
    totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
    return totalQuantity;
  }

  double gettabletotalqty(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['quantity']!) ?? 0.0;
      totalQuantity += quantity;
    }
    totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
    return totalQuantity;
  }

  double getTotalFinalTaxable(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['retail']!) ?? 0.0;
      totalQuantity += quantity;
    }
    totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
    return totalQuantity;
  }

  double getTotalCGSTAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['cgstAmt']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  double getTotalSGSTAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['sgstAmt']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['Amount']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  double gettaxableAmtCGST0(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 0) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST25(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 2.5) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST6(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 6) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST9(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 9) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST14(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 14) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST0(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 0) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 0 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST25(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 2.5) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 2.5 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST6(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 6) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 6 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST9(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 9) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 9 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST14(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 14) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 14 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double getFinalAmtCGST0(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 0) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    // print("Total amount with CGST 0%: $totalAmountCGST0 ");
    return totalAmountCGST0;
  }

  double getFinalAmtCGST25(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 2.5) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtCGST6(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 6) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtCGST9(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 9) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtCGST14(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 14) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST0(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 0) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST25(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 2.5) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST6(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 6) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST9(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 9) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST14(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 14) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  TextEditingController SalesDisAMountController = TextEditingController();
  TextEditingController SalesDisPercentageController = TextEditingController();
  TextEditingController CGSTPercent0 = TextEditingController();

  TextEditingController CGSTPercent25 = TextEditingController();

  TextEditingController CGSTPercent6 = TextEditingController();

  TextEditingController CGSTPercent9 = TextEditingController();

  TextEditingController CGSTPercent14 = TextEditingController();
  TextEditingController SGSTPercent0 = TextEditingController();

  TextEditingController SGSTPercent25 = TextEditingController();

  TextEditingController SGSTPercent6 = TextEditingController();

  TextEditingController SGSTPercent9 = TextEditingController();

  TextEditingController SGSTPercent14 = TextEditingController();
  TextEditingController FINALAMTCONTROLLWE = TextEditingController();

  void updatefinaltabletotalAmount() {
    double finaltotalamount = getTotalFinalAmt(tableData);
    FINALAMTCONTROLLWE.text = finaltotalamount.toStringAsFixed(2);
  }

  Future<void> fetchShopInfo(Function updateShopInfo) async {
    String cusid = "BTRM_1"; // Replace with your actual logic to get cusid
    final String url = "$IpAddress/Shopinfo/?cusid=$cusid";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final shopInfo = data['results'][0];
          updateShopInfo(
            shopInfo['shopname'] ?? "null",
            shopInfo['doorno'] ?? "null",
            shopInfo['area2'] ?? "null",
            "${shopInfo['city'] ?? ""} - ${shopInfo['pincode'] ?? "null"}",
            "GST No : ${shopInfo['gstno'] ?? "null"}",
            "FSSAI No : ${shopInfo['fssai'] ?? "null"}",
            "Contact: ${shopInfo['contact'] ?? "null"}",
          );
        }
        // print("response data $data");
      } else {
        throw Exception('Failed to load shop info');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<pw.Widget>> _buildPdfContent(
      String billno,
      String paytypee,
      String datee,
      String timee,
      String cusname,
      String cuscontact,
      String tableno,
      String sname,
      String itemcount,
      String totalqty,
      String totamt,
      String Discountamt,
      String finalamt,
      String sgstt25,
      String sgstt6,
      String sgstt9,
      String sgstt14) async {
    var restaurantname = "";
    var address1 = "";
    var address2 = "";
    var city = "";
    var gstno = "";
    var fassai = "";
    var contact = "";

    String? shopLogoUrl;

    final CustomerName = cusname;
    final CustomerContact = cuscontact;
    final Billno = billno;
    final paytype = paytypee;
    final date = datee;
    final kitchenTime = timee;
    final tableNo = tableno;
    final servent = sname;
    final totitem = itemcount;
    final totqty = totalqty;
    final sgst25 = sgstt25;
    final sgst6 = sgstt6;
    final sgst9 = sgstt9;
    final sgst14 = sgstt14;
    final discount = double.parse(Discountamt).toStringAsFixed(2);
    final String amount = double.parse(totamt).toStringAsFixed(2);
    final String totamount = double.parse(finalamt).toStringAsFixed(2);
    // final totamount = finalamt;

    Future<void> fetchShopInfo() async {
      String cusid = "BTRM_1"; // Assuming cusid is hardcoded for this example.
      final String url = "$IpAddress/Shopinfo/?cusid=$cusid";

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final shopInfo = data['results'][0];

            restaurantname = shopInfo['shopname'] ?? "";
            address1 = shopInfo['doorno'] ?? "";
            address2 = shopInfo['area2'] ?? "";
            city = "${shopInfo['city'] ?? ""} - ${shopInfo['pincode'] ?? ""}";
            gstno = "GST No : ${shopInfo['gstno'] ?? ""}";
            fassai = "FSSAI No : ${shopInfo['fssai'] ?? ""}";
            contact = "Contact: ${shopInfo['contact'] ?? ""}";
            shopLogoUrl =
                "iVBORw0KGgoAAAANSUhEUgAAAXcAAAF3CAYAAABewAv+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3FpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDE0IDc5LjE1MTQ4MSwgMjAxMy8wMy8xMy0xMjowOToxNSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDowYWI2MDAwMS0wNTM3LWRkNDItOTRiZi00ZTRlOWUwN2Q5NWUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NTE5RUI3Njk4MDFFMTFFQjk5RkZDQUM4NTcwQkZCRjUiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NTE5RUI3Njg4MDFFMTFFQjk5RkZDQUM4NTcwQkZCRjUiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChXaW5kb3dzKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjJhNTI0MjAwLTg0OTQtMGU0Yy1hY2JlLWQ3YzAzNTZhOTIzMiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDowYWI2MDAwMS0wNTM3LWRkNDItOTRiZi00ZTRlOWUwN2Q5NWUiLz4gPC9y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";
          }
          print('Restaurant Name: $restaurantname');
          print('Address 1: $address1');
          print('Address 2: $address2');
          print('City and Pincode: $city');
          print('GST Number: $gstno');
          print('FSSAI Number: $fassai');
          print('Contact: $contact');
        } else {
          throw Exception('Failed to load shop info');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    // Fetch the shop information before building the content.
    await fetchShopInfo();

    final items = tableData.map<Map<String, String>>((data) {
      return {
        "name": data['productName'],
        "rate": data['amount'].toString(),
        "qty": data['quantity'].toString(),
        "amount": data['Amount'].toString(),
      };
    }).toList();
    String generateUPILink() {
      return 'upi://pay?pa=$upiId&pn=$payeeName&am=$totamount&cu=INR';
    }

    Uint8List bytes = base64.decode(shopLogoUrl!);
    return [
      pw.Padding(
          padding: pw.EdgeInsets.all(8), // Adjust the padding value as needed
          child: pw.Column(children: [
            pw.Center(
              child: bytes != null
                  ? pw.Image(
                      pw.MemoryImage(bytes),
                      width: 50,
                      height: 50,
                      fit: pw.BoxFit.cover,
                    )
                  : pw.Text('Error loading image'),
            ),
            pw.Center(
              child: pw.Text(
                restaurantname,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
            if (address1.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  address1,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            if (address1.isNotEmpty) pw.SizedBox(height: 2),
            if (address2.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  address2,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            if (address2.isNotEmpty) pw.SizedBox(height: 2),
            if (city.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  city,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            if (city.isNotEmpty) pw.SizedBox(height: 2),
            if (gstno.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  gstno,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            if (gstno.isNotEmpty) pw.SizedBox(height: 2),
            if (fassai.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  fassai,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            if (fassai.isNotEmpty) pw.SizedBox(height: 2),
            if (contact.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  contact,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            if (contact.isNotEmpty)
              pw.Divider(thickness: 1, color: PdfColors.black),
            _buildBillInfo("BillNo: $Billno", "Paytype: $paytype"),
            _buildBillInfo("Date: $date", "Time: $kitchenTime"),
            pw.Divider(thickness: 1, color: PdfColors.black),
            if (CustomerName.isNotEmpty || CustomerContact.isNotEmpty)
              _buildBillInfo("Customer: $CustomerName", ''),
            if (CustomerName.isNotEmpty || CustomerContact.isNotEmpty)
              _buildBillInfo("Contact: $CustomerContact", ""),
            if (CustomerName.isNotEmpty || CustomerContact.isNotEmpty)
              pw.Divider(thickness: 1, color: PdfColors.black),
            if (tableNo.isNotEmpty || servent.isNotEmpty)
              _buildBillInfo("TableNo: $tableNo", "Servent: $servent"),
            if (tableNo.isNotEmpty || servent.isNotEmpty)
              pw.Divider(thickness: 1, color: PdfColors.black),
            _buildProductHeader(),
            pw.Divider(thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: 4), // Space between header and first item
            ...items.map((item) => _buildProductItem(item)).toList(),
            pw.Divider(thickness: 1, color: PdfColors.black),
            _buildBillInfo("Total Item: $totitem", "$amount"),
            _buildBillInfo("Total Qty: $totqty", "---------------"),
            pw.SizedBox(height: 5),
            if (sgst25.isNotEmpty && sgst25 != '0.00')
              _buildBillInfo("SGST 2.5%-:", "$sgst25"),
            if (sgst25.isNotEmpty && sgst25 != '0.00')
              _buildBillInfo("CGST 2.5%-:", "$sgst25"),
            pw.SizedBox(height: 3),
            if (sgst6.isNotEmpty && sgst6 != '0.00')
              _buildBillInfo("SGST 6%-:", "$sgst6"),
            if (sgst6.isNotEmpty && sgst6 != '0.00')
              _buildBillInfo("CGST 6%-:", "$sgst6"),
            pw.SizedBox(height: 3),
            if (sgst9.isNotEmpty && sgst9 != '0.00')
              _buildBillInfo("SGST 9%-:", "$sgst9"),
            if (sgst9.isNotEmpty && sgst9 != '0.00')
              _buildBillInfo("CGST 9%-:", "$sgst9"),
            pw.SizedBox(height: 3),
            if (sgst14.isNotEmpty && sgst14 != '0.00')
              _buildBillInfo("SGST 14%-:", "$sgst14"),
            if (sgst14.isNotEmpty && sgst14 != '0.00')
              _buildBillInfo("CGST 14%-:", "$sgst14"),
            if (discount.isNotEmpty && discount != '0.00')
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Discount',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    "-$discount",
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: generateUPILink(),
                width: 65, // Adjust the size as needed
                height: 65, // Adjust the size as needed
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Total Rs : $totamount',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.black),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  '**THANK YOU COME AGAIN**',
                  style: pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Technology Partner Buyp - www.buyp.in',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ]))
    ];
  }

  pw.Widget _buildBillInfo(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(left, style: pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(right, style: pw.TextStyle(fontSize: 9)),
        )
      ],
    );
  }

  pw.Widget _buildProductHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text('Product',
              style:
                  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Row(
          children: [
            pw.Container(
              width: 40,
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Rate',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              width: 30,
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Qty',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              width: 50,
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Amount',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProductItem(Map<String, String> item) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              item['name']!,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Row(
            children: [
              pw.Container(
                width: 40,
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  double.parse(item['rate']!)
                      .toStringAsFixed(0), // Remove decimal places
                  style:
                      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(width: 5), // Horizontal space between columns
              pw.Container(
                width: 30,
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  item['qty']!,
                  style:
                      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Container(
                width: 50,
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  item['amount']!,
                  style:
                      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // pw.Widget _buildProductItem(Map<String, String> item) {
  //   return pw.Row(
  //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //     children: [
  //       pw.Row(children: [
  //         pw.Text(item['name']!,
  //             style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
  //       ]),
  //       pw.Row(children: [
  //         pw.Container(
  //           width: 40,
  //           alignment: pw.Alignment.centerRight,
  //           child: pw.Text(
  //             double.parse(item['rate']!).toStringAsFixed(
  //                 0), // Convert to integer by removing decimal places
  //             style: pw.TextStyle(
  //               fontSize: 9,
  //               fontWeight: pw.FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //         pw.Container(
  //           width: 30,
  //           alignment: pw.Alignment.centerRight,
  //           child: pw.Text(item['qty']!,
  //               style:
  //                   pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
  //         ),
  //         pw.Container(
  //           width: 50,
  //           alignment: pw.Alignment.centerRight,
  //           child: pw.Text(item['amount']!,
  //               style:
  //                   pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
  //         )
  //       ]),
  //     ],
  //   );
  // }

  Future<void> _generateAndDownloadWeb(pw.Document pdf) async {
    final pdfData = await pdf.save();
    final blob = html.Blob([pdfData]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'SalesBill.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Widget bottomcontainer() {
    TextEditingController QuantityContController = TextEditingController(
      // Set the initial text to the count of items
      text: gettabletotalqty(tableData).toString(),
    );
    TextEditingController itemCountController = TextEditingController(
      // Set the initial text to the count of items
      text: getProductCount(tableData).toString(),
    );
    TextEditingController taxableamountController = TextEditingController(
      // Set the initial text to the count of items
      text: getTotalTaxable(tableData).toString(),
    );
    TextEditingController finaltaxablecontroller = TextEditingController(
      // Set the initial text to the count of items
      text: getTotalFinalTaxable(tableData).toString(),
    );
    TextEditingController cgstamtcontroller = TextEditingController(
      // Set the initial text to the count of items
      text: getTotalCGSTAmt(tableData).toString(),
    );
    TextEditingController sgstamtcontroller = TextEditingController(
      // Set the initial text to the count of items
      text: getTotalSGSTAmt(tableData).toString(),
    );
    TextEditingController finalamtcontroller = TextEditingController(
      // Set the initial text to the count of items
      text: getTotalFinalAmt(tableData).toString(),
    );

    void calculateDiscountAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(SalesDisPercentageController.text.toString()) ?? 0.0;

      if (SalesGstMethodController.text == "Excluding") {
        double cgst0 =
            double.tryParse(gettaxableAmtSGST0(tableData).toString()) ?? 0.0;
        double cgst25 =
            double.tryParse(gettaxableAmtSGST25(tableData).toString()) ?? 0.0;
        double cgst6 =
            double.tryParse(gettaxableAmtSGST6(tableData).toString()) ?? 0.0;
        double cgst9 =
            double.tryParse(gettaxableAmtSGST9(tableData).toString()) ?? 0.0;
        double cgst14 =
            double.tryParse(gettaxableAmtSGST14(tableData).toString()) ?? 0.0;
        // print("Cgst 000:$cgst0");
        // print("Cgst 255:$cgst25");

        // print("Cgst 6666:$cgst6");
        // print("Cgst 9999:$cgst9");
        // print("Cgst 1444:$cgst14");

        // Perform calculations
        double part1 = cgst0 * disPercentage / 100;
        double part2 = cgst25 * disPercentage / 100;
        double part3 = cgst6 * disPercentage / 100;
        double part4 = cgst9 * disPercentage / 100;
        double part5 = cgst14 * disPercentage / 100;

        // Calculate total discount amount
        double discountAmount = part1 + part2 + part3 + part4 + part5;

        // Update the discount amount in the text controller
        SalesDisAMountController.text = discountAmount.toStringAsFixed(2);
        print("SalesDisAMountController   :${SalesDisAMountController.text}");
      } else if (SalesGstMethodController.text == "Including") {
        double cgst0 =
            double.tryParse(getFinalAmtCGST0(tableData).toString()) ?? 0.0;
        double cgst25 =
            double.tryParse(getFinalAmtCGST25(tableData).toString()) ?? 0.0;
        double cgst6 =
            double.tryParse(getFinalAmtCGST6(tableData).toString()) ?? 0.0;
        double cgst9 =
            double.tryParse(getFinalAmtCGST9(tableData).toString()) ?? 0.0;
        double cgst14 =
            double.tryParse(getFinalAmtCGST14(tableData).toString()) ?? 0.0;

        // print("Cgst 000:$cgst0");
        // print("Cgst 255:$cgst25");

        // print("Cgst 6666:$cgst6");
        // print("Cgst 9999:$cgst9");
        // print("Cgst 1444:$cgst14");
        // Perform calculations
        double part1 = cgst0 * disPercentage / 100;
        double part2 = cgst25 * disPercentage / 100;
        double part3 = cgst6 * disPercentage / 100;
        double part4 = cgst9 * disPercentage / 100;
        double part5 = cgst14 * disPercentage / 100;

        // Calculate total discount amount
        double discountAmount = part1 + part2 + part3 + part4 + part5;

        // Update the discount amount in the text controller
        SalesDisAMountController.text = discountAmount.toStringAsFixed(2);
        // print("DiscountAmount : ${SalesDisAMountController.text}");
      } else {
        double taxableamount =
            double.tryParse(getTotalFinalTaxable(tableData).toString()) ?? 0.0;

        double discountamount = taxableamount * disPercentage / 100;

        SalesDisAMountController.text = discountamount.toStringAsFixed(2);
      }
    }

    void calculateDiscountPercentage() {
      // Get the discount amount from the controller
      double discountAmount =
          double.tryParse(SalesDisAMountController.text) ?? 0.0;

      if (SalesGstMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double totalTaxable =
            double.tryParse(getTotalTaxable(tableData).toString()) ?? 0.0;

        // Calculate the discount percentage
        double discountPercentage = (discountAmount * 100) / totalTaxable;

        // Update the discount percentage in the appropriate controller
        SalesDisPercentageController.text =
            discountPercentage.toStringAsFixed(2);
      } else if (SalesGstMethodController.text == "Including") {
        double totalTaxable =
            double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;

        // Calculate the discount percentage
        double discountPercentage = (discountAmount * 100) / totalTaxable;

        // Update the discount percentage in the appropriate controller
        SalesDisPercentageController.text =
            discountPercentage.toStringAsFixed(2);
      } else {
        double taxableamount =
            double.tryParse(getTotalFinalTaxable(tableData).toString()) ?? 0.0;

        double discountamount = discountAmount * 100 / taxableamount;

        SalesDisPercentageController.text = discountamount.toStringAsFixed(2);
      }
    }

    void CalculateCGSTFinalAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(SalesDisPercentageController.text.toString()) ?? 0.0;

      if (SalesGstMethodController.text == "Excluding") {
        double cgst0 =
            double.tryParse(gettaxableAmtCGST0(tableData).toString()) ?? 0.0;
        double cgst25 =
            double.tryParse(gettaxableAmtCGST25(tableData).toString()) ?? 0.0;
        double cgst6 =
            double.tryParse(gettaxableAmtCGST6(tableData).toString()) ?? 0.0;
        double cgst9 =
            double.tryParse(gettaxableAmtCGST9(tableData).toString()) ?? 0.0;
        double cgst14 =
            double.tryParse(gettaxableAmtCGST14(tableData).toString()) ?? 0.0;
        // Perform calculations
        double cgst0part1 = cgst0 * disPercentage / 100;
        double cgst25part2 = cgst25 * disPercentage / 100;
        double cgst6part3 = cgst6 * disPercentage / 100;
        double cgst9part4 = cgst9 * disPercentage / 100;
        double cgst14part5 = cgst14 * disPercentage / 100;

        double finalcgst0amt = cgst0 - cgst0part1;
        double finalcgst25amt = cgst25 - cgst25part2;
        double finalcgst6amt = cgst6 - cgst6part3;
        double finalcgst9amt = cgst9 - cgst9part4;
        double finalcgst14amt = cgst14 - cgst14part5;

        double FinameFormulaCGST0 = finalcgst0amt * 0 / 100;
        double FinameFormulaCGST25 = finalcgst25amt * 2.5 / 100;
        double FinameFormulaCGST6 = finalcgst6amt * 6 / 100;
        double FinameFormulaCGST9 = finalcgst9amt * 9 / 100;
        double FinameFormulaCGST14 = finalcgst14amt * 14 / 100;

        CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
        CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
        CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
        CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
        CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

        double FinalCGSTAmounts = FinameFormulaCGST0 +
            FinameFormulaCGST25 +
            FinameFormulaCGST6 +
            FinameFormulaCGST9 +
            FinameFormulaCGST14;

        cgstamtcontroller.text = FinalCGSTAmounts.toStringAsFixed(2);
      } else if (SalesGstMethodController.text == "Including") {
        double cgst0 =
            double.tryParse(getFinalAmtCGST0(tableData).toString()) ?? 0.0;
        double cgst25 =
            double.tryParse(getFinalAmtCGST25(tableData).toString()) ?? 0.0;
        double cgst6 =
            double.tryParse(getFinalAmtCGST6(tableData).toString()) ?? 0.0;
        double cgst9 =
            double.tryParse(getFinalAmtCGST9(tableData).toString()) ?? 0.0;
        double cgst14 =
            double.tryParse(getFinalAmtCGST14(tableData).toString()) ?? 0.0;

        // Perform calculations
        double cgst0part1 = cgst0 * disPercentage / 100;
        double cgst25part2 = cgst25 * disPercentage / 100;
        double cgst6part3 = cgst6 * disPercentage / 100;
        double cgst9part4 = cgst9 * disPercentage / 100;
        double cgst14part5 = cgst14 * disPercentage / 100;

        double finalcgst0amt = cgst0 - cgst0part1;
        double finalcgst25amt = cgst25 - cgst25part2;
        double finalcgst6amt = cgst6 - cgst6part3;
        double finalcgst9amt = cgst9 - cgst9part4;
        double finalcgst14amt = cgst14 - cgst14part5;

        double denominator0 = 100 + 0;
        double denominator25 = 100 + 5;
        double denominator6 = 100 + 12;
        double denominator9 = 100 + 18;
        double denominator14 = 100 + 28;

        double FinameFormulaCGST0 = finalcgst0amt * 0 / denominator0;
        double FinameFormulaCGST25 = finalcgst25amt * 2.5 / denominator25;
        double FinameFormulaCGST6 = finalcgst6amt * 6 / denominator6;
        double FinameFormulaCGST9 = finalcgst9amt * 9 / denominator9;
        double FinameFormulaCGST14 = finalcgst14amt * 14 / denominator14;

        CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
        CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
        CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
        CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
        CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

        // print("cgsttttttt 00000 : ${CGSTPercent0.text}");
        // print("cgsttttttt 25555 : ${CGSTPercent25.text}");
        // print("cgsttttttt 6666 : ${CGSTPercent6.text}");
        // print("cgsttttttt 999 : ${CGSTPercent9.text}");
        // print("cgsttttttt 14444 : ${CGSTPercent14.text}");

        double FinalCGSTAmounts = FinameFormulaCGST0 +
            FinameFormulaCGST25 +
            FinameFormulaCGST6 +
            FinameFormulaCGST9 +
            FinameFormulaCGST14;

        cgstamtcontroller.text = FinalCGSTAmounts.toStringAsFixed(2);
      } else {
        CGSTPercent0.text = 0.toStringAsFixed(2);
        CGSTPercent25.text = 0.toStringAsFixed(2);
        CGSTPercent6.text = 0.toStringAsFixed(2);
        CGSTPercent9.text = 0.toStringAsFixed(2);
        CGSTPercent14.text = 0.toStringAsFixed(2);

        double FinalCGSTAmounts = 0;

        cgstamtcontroller.text = FinalCGSTAmounts.toStringAsFixed(2);
      }
    }

    void CalculateSGSTFinalAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(SalesDisPercentageController.text.toString()) ?? 0.0;

      if (SalesGstMethodController.text == "Excluding") {
        double sgst0 =
            double.tryParse(gettaxableAmtSGST0(tableData).toString()) ?? 0.0;
        double sgst25 =
            double.tryParse(gettaxableAmtSGST25(tableData).toString()) ?? 0.0;
        double sgst6 =
            double.tryParse(gettaxableAmtSGST6(tableData).toString()) ?? 0.0;
        double sgst9 =
            double.tryParse(gettaxableAmtSGST9(tableData).toString()) ?? 0.0;
        double sgst14 =
            double.tryParse(gettaxableAmtSGST14(tableData).toString()) ?? 0.0;
        // Perform calculations
        // Perform calculations
        double sgst0part1 = sgst0 * disPercentage / 100;
        double sgst25part2 = sgst25 * disPercentage / 100;
        double sgst6part3 = sgst6 * disPercentage / 100;
        double sgst9part4 = sgst9 * disPercentage / 100;
        double sgst14part5 = sgst14 * disPercentage / 100;

        double finalsgst0amt = sgst0 - sgst0part1;
        double finalsgst25amt = sgst25 - sgst25part2;
        double finalsgst6amt = sgst6 - sgst6part3;
        double finalsgst9amt = sgst9 - sgst9part4;
        double finalsgst14amt = sgst14 - sgst14part5;
        double FinameFormulaSGST0 = finalsgst0amt * 0 / 100;
        double FinameFormulaSGST25 = finalsgst25amt * 2.5 / 100;
        double FinameFormulaSGST6 = finalsgst6amt * 6 / 100;
        double FinameFormulaSGST9 = finalsgst9amt * 9 / 100;
        double FinameFormulaSGST14 = finalsgst14amt * 14 / 100;

        SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
        SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
        SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
        SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
        SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

        double FinalSGSTAmounts = FinameFormulaSGST0 +
            FinameFormulaSGST25 +
            FinameFormulaSGST6 +
            FinameFormulaSGST9 +
            FinameFormulaSGST14;

        sgstamtcontroller.text = FinalSGSTAmounts.toStringAsFixed(2);
      } else if (SalesGstMethodController.text == "Including") {
        double sgst0 =
            double.tryParse(getFinalAmtSGST0(tableData).toString()) ?? 0.0;
        double sgst25 =
            double.tryParse(getFinalAmtSGST25(tableData).toString()) ?? 0.0;
        double sgst6 =
            double.tryParse(getFinalAmtSGST6(tableData).toString()) ?? 0.0;
        double sgst9 =
            double.tryParse(getFinalAmtSGST9(tableData).toString()) ?? 0.0;
        double sgst14 =
            double.tryParse(getFinalAmtSGST14(tableData).toString()) ?? 0.0;

        // Perform calculations
        double sgst0part1 = sgst0 * disPercentage / 100;
        double sgst25part2 = sgst25 * disPercentage / 100;
        double sgst6part3 = sgst6 * disPercentage / 100;
        double sgst9part4 = sgst9 * disPercentage / 100;
        double sgst14part5 = sgst14 * disPercentage / 100;

        double finalsgst0amt = sgst0 - sgst0part1;
        double finalsgst25amt = sgst25 - sgst25part2;
        double finalsgst6amt = sgst6 - sgst6part3;
        double finalsgst9amt = sgst9 - sgst9part4;
        double finalsgst14amt = sgst14 - sgst14part5;
        double denominator0 = 100 + 0;
        double denominator25 = 100 + 5;
        double denominator6 = 100 + 12;
        double denominator9 = 100 + 18;
        double denominator14 = 100 + 28;

        double FinameFormulaSGST0 = finalsgst0amt * 0 / denominator0;
        double FinameFormulaSGST25 = finalsgst25amt * 2.5 / denominator25;
        double FinameFormulaSGST6 = finalsgst6amt * 6 / denominator6;
        double FinameFormulaSGST9 = finalsgst9amt * 9 / denominator9;
        double FinameFormulaSGST14 = finalsgst14amt * 14 / denominator14;

        SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
        SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
        SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
        SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
        SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

        double FinalSGSTAmounts = FinameFormulaSGST0 +
            FinameFormulaSGST25 +
            FinameFormulaSGST6 +
            FinameFormulaSGST9 +
            FinameFormulaSGST14;

        sgstamtcontroller.text = FinalSGSTAmounts.toStringAsFixed(2);
      } else {
        SGSTPercent0.text = 0.toStringAsFixed(2);
        SGSTPercent25.text = 0.toStringAsFixed(2);
        SGSTPercent6.text = 0.toStringAsFixed(2);
        SGSTPercent9.text = 0.toStringAsFixed(2);
        SGSTPercent14.text = 0.toStringAsFixed(2);

        double FinalSGSTAmounts = 0;

        sgstamtcontroller.text = FinalSGSTAmounts.toStringAsFixed(2);
      }
    }

    void calculateFinaltotalAmount() {
      if (SalesGstMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double finaltotalTaxable =
            double.tryParse(finaltaxablecontroller.text) ?? 0.0;
        double finalCGSTAmount = double.tryParse(cgstamtcontroller.text) ?? 0.0;
        double finalSGSTAmount = double.tryParse(sgstamtcontroller.text) ?? 0.0;

        // Perform calculation
        double TotalAmount =
            finaltotalTaxable + finalCGSTAmount + finalSGSTAmount;

        finalamtcontroller.text = TotalAmount.toStringAsFixed(2);
        FinallyyyAmounttts.text = TotalAmount.toStringAsFixed(2);
      } else if (SalesGstMethodController.text == "Including") {
        double totalFInalAMount =
            double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;
        double discountamount =
            double.tryParse(SalesDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        finalamtcontroller.text = FinalTotlaAmount.toStringAsFixed(2);

        FinallyyyAmounttts.text = FinalTotlaAmount.toStringAsFixed(2);
      } else {
        double totalFInalAMount =
            double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;
        double discountamount =
            double.tryParse(SalesDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        finalamtcontroller.text = FinalTotlaAmount.toStringAsFixed(2);
        FinallyyyAmounttts.text = FinalTotlaAmount.toStringAsFixed(2);
      }
    }

    void calculateFinalTaxableAmount() {
      // Parse discount percentage

      double discountAmount =
          double.tryParse(SalesDisAMountController.text) ?? 0.0;
      if (SalesGstMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double totalTaxable =
            double.tryParse(getTotalFinalTaxable(tableData).toString()) ?? 0.0;

        double FinalTaxableAMount = totalTaxable - discountAmount;
        finaltaxablecontroller.text = FinalTaxableAMount.toStringAsFixed(2);
      } else if (SalesGstMethodController.text == "Including") {
        double totalFInalAMount =
            double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;
        double discountamount =
            double.tryParse(SalesDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double finalAmount = FinalTotlaAmount;
        double cgsttotalamount =
            double.tryParse(cgstamtcontroller.text.toString()) ?? 0.0;
        double sgsttotalamount =
            double.tryParse(sgstamtcontroller.text.toString()) ?? 0.0;

        double totalgstamount = cgsttotalamount + sgsttotalamount;

        double finaltaxableamount = finalAmount - totalgstamount;
        finaltaxablecontroller.text = finaltaxableamount.toStringAsFixed(2);
      } else {
        double totalTaxable =
            double.tryParse(getTotalTaxable(tableData).toString()) ?? 0.0;
        double discountAmount =
            double.tryParse(SalesDisAMountController.text) ?? 0.0;

        double finaltaxableamount = totalTaxable - discountAmount;
        finaltaxablecontroller.text = finaltaxableamount.toStringAsFixed(2);
      }
    }

    Future<void> postDataWithIncrementedSerialNo() async {
      // Parse the serial number from the text field
      String? incrementedSerialNo;
      try {
        incrementedSerialNo = widget.BillNOreset.text.toString();
      } catch (e) {
        print('Failed to parse serial number: $e');
        return; // Exit the function if parsing fails
      }

      // print("Bill no: $incrementedSerialNo");

      String? cusid = await SharedPrefs.getCusId();
      // Prepare the data to be sent
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "serialno": incrementedSerialNo,
      };

      // Convert the data to JSON format
      String jsonData = jsonEncode(postData);

      try {
        // Send the POST request
        var response = await http.post(
          Uri.parse('$IpAddress/Sales_serialnoalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        // Check the response status
        if (response.statusCode == 201) {
          // print('Data posted successfully');
        } else {
          // print('Response body: ${response.statusCode}');
          // successfullySavedMessage();
        }
      } catch (e) {
        // print('Failed to post data. Error: $e');
      }
    }

    Future<void> Post_SaesRoundtbl() async {
      try {
        CalculateCGSTFinalAmount();
        CalculateSGSTFinalAmount();
        calculateFinalTaxableAmount();
        calculateFinaltotalAmount();

        DateTime currentDate = DateTime.now();
        DateTime currentDatetime = DateTime.now();

        // Format the date in 'yyyy-MM-dd' format
        String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mm:ss a').format(currentDatetime);
        String gstcontorller = SalesGstMethodController.text;
        String gstMethod = '';
        if (gstcontorller == 'Including' || gstcontorller == 'Excluding') {
          gstMethod = 'Gst';
        } else {
          gstMethod = 'NonGst';
        }

        String cgstperc = cgstamtcontroller.text;
        String sgstperc = sgstamtcontroller.text;

        double cgst = double.tryParse(cgstperc) ?? 0.0;
        double sgst = double.tryParse(sgstperc) ?? 0.0;

        double gstamt = cgst + sgst;

        String? cusid = await SharedPrefs.getCusId();
        Map<String, dynamic> postData = {
          "cusid": "$cusid",
          "billno": widget.BillNOreset.text,
          "dt": formattedDate,
          "type": widget.ProductSalesTypeController.text,
          "tableno": widget.tableno.text.isEmpty ? "null" : widget.tableno.text,
          "servent": widget.sname.text.isEmpty ? "null" : widget.sname.text,
          "count": itemCountController.text,
          "amount": getTotalFinalAmt(tableData).toString(),
          "discount": SalesDisAMountController.text,
          "vat": gstamt,
          "finalamount": finalamtcontroller.text,
          "cgst0": CGSTPercent0.text,
          "cgst25": CGSTPercent25.text,
          "cgst6": CGSTPercent6.text,
          "cgst9": CGSTPercent9.text,
          "cgst14": CGSTPercent14.text,
          "sgst0": SGSTPercent0.text,
          "sgst25": SGSTPercent25.text,
          "sgst6": SGSTPercent6.text,
          "sgst9": SGSTPercent9.text,
          "sgst14": SGSTPercent14.text,
          "totcgst": cgstamtcontroller.text,
          "totsgst": sgstamtcontroller.text,
          "paidamount":
              widget.paytype.text == "Credit" ? "0" : finalamtcontroller.text,
          "scode": widget.scode.text.isEmpty ? "null" : widget.scode.text,
          "sname": widget.sname.text.isEmpty ? "null" : widget.sname.text,
          "cusname": widget.customername.text.isEmpty
              ? "null"
              : widget.customername.text,
          "contact": widget.customercontact.text.isEmpty
              ? "null"
              : widget.customercontact.text,
          "paytype": widget.paytype.text,
          "disperc": SalesDisPercentageController.text,
          "famount": finalamtcontroller.text,
          // "vendorname": "0",
          // "vendorcomPerc": "0.0",
          // "CommisionAmt": "0.0",
          // "VendorDisPerc": "0.0",
          // "VendorDisamt": "0.0",
          // "FinalAmt": "1000.0",
          // "TotalAmount": "1000.0",
          "Status": "Normal",
          // "OrderNo": null,
          // "PointDis": null,
          // "login": null,
          "gststatus": gstMethod,
          "time": formattedDateTime,
          // "customeramount": null,
          // "customerchange": null,
          "taxstatus": gstcontorller,
          // "serialno": null,
          "taxable": taxableamountController.text,
          "finaltaxable": finaltaxablecontroller.text
        };

        // Convert the data to JSON format
        String jsonData = jsonEncode(postData);

        // Send the POST request
        var response = await http.post(
          Uri.parse('$IpAddress/SalesRoundDetailsalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        // Check the response status
        if (response.statusCode == 200) {
          // print('Data posted successfully');
        } else {
          // Print the response body if available
          // print('Failed to post data. Error code: ${response.statusCode}');
          if (response.body != null && response.body.isNotEmpty) {
            // print('Response body: ${response.body}');
          }
        }
      } catch (e) {
        // Print any exceptions that occur
        // print('Failed to post data. Error: $e');
      }
    }

    Future<void> Post_salesIncometbl() async {
      try {
        if (widget.paytype != 'Credit') {
          DateTime currentDate = DateTime.now();

          // Format the date in 'yyyy-MM-dd' format
          String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

          String? cusid = await SharedPrefs.getCusId();
          Map<String, dynamic> postData = {
            "cusid": "$cusid",
            "description": "Sales Bill:${widget.BillNOreset.text}",
            "dt": formattedDate,
            "amount": finalamtcontroller.text
          };

          // Convert the data to JSON format
          String jsonData = jsonEncode(postData);

          // Send the POST request
          var response = await http.post(
            Uri.parse('$IpAddress/Sales_IncomeDetails/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonData,
          );

          // Check the response status
          if (response.statusCode == 200) {
            // print('Data posted successfully');
          } else {
            // Print the response body if available
            // print('Failed to post data. Error code: ${response.statusCode}');
            if (response.body != null && response.body.isNotEmpty) {
              // print('Response body: ${response.body}');
            }
          }
        }
      } catch (e) {
        // Print any exceptions that occur
        // print('Failed to post data. Error: $e');Error:
      }
    }

    Future<void> post_stockItems(List<Map<String, dynamic>> tableData) async {
      for (var data in tableData) {
        String productName = data['productName'];
        int quantity = int.tryParse(data['quantity'].toString()) ??
            0; // Retrieve quantity from tableData

        try {
          List<Map<String, dynamic>> productList = await salesProductList();

          Map<String, dynamic>? product = productList.firstWhere(
            (element) => element['name'] == productName,
            orElse: () => {'stock': 'no', 'id': -1},
          );

          String stockStatus = product['stock'];
          int productId = product['id'];
          // print("StockStatus for product '$productName': $stockStatus");
          // print("Id  for product '$productName': $productId");

          if (stockStatus == 'Yes') {
            double stockValue =
                double.tryParse(product['stockvalue'].toString()) ?? 0;

            // Subtract the quantity from the stock value
            double updatedStockValue = stockValue - quantity;

            String? cusid = await SharedPrefs.getCusId();
            // Prepare the data to be sent to the server
            Map<String, dynamic> putData = {
              "cusid": "$cusid",
              "stockvalue": updatedStockValue.toString(),
            };

            // Convert the data to JSON format
            String jsonData = jsonEncode(putData);

            // Send the PUT request to update the stock value
            var response = await http.put(
              Uri.parse(
                  '$IpAddress/SettingsProductDetailsalldatas/$productId/'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonData,
            );

            // Check the response status
            if (response.statusCode == 200) {
              // print(
              //     'Stock value updated successfully for product: $productName');
              // Proceed with further actions if needed
            } else {
              print(
                  'Failed to update stock value for product: $productName. Error code: ${response.statusCode}');
              if (response.body != null && response.body.isNotEmpty) {
                // print('Response body: ${response.body}');
              }
            }
          }
        } catch (error) {
          print('Error retrieving product list: $error');
        }
      }
    }

    Future<void> Post_SalesDetailsRound() async {
      try {
        // CalculateCGSTFinalAmount();
        CalculateSGSTFinalAmount();
        calculateFinalTaxableAmount();
        calculateFinaltotalAmount();
        DateTime currentDate = DateTime.now();
        DateTime currentDatetime = DateTime.now();

        // Format the date in 'yyyy-MM-dd' format
        String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

        String formattedDateTime =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(currentDatetime);
        // String formattedDateTime =
        //     DateFormat('yyyy-MM-dd hh:mm:ss a').format(currentDatetime);
        String gstcontorller = SalesGstMethodController.text;
        String gstMethod = '';
        if (gstcontorller == 'Including' || gstcontorller == 'Excluding') {
          gstMethod = 'Gst';
        } else {
          gstMethod = 'NonGst';
        }

        String cgstperc = sgstamtcontroller.text;
        String sgstperc = sgstamtcontroller.text;

        double cgst = double.tryParse(cgstperc) ?? 0.0;
        double sgst = double.tryParse(sgstperc) ?? 0.0;

        double gstamt = cgst + sgst;
        List<String> productDetails = [];
        for (var data in tableData) {
          // Format each product detail as "{productName},{amount}"
          productDetails.add(
              "{salesbillno:${widget.BillNOreset.text},category:${data['category']},dt:$formattedDate,Itemname:${data['productName']},rate:${data['amount']},qty:${data['quantity']},amount:${data['Amount']},retailrate:${data['retailrate']},retail:${data['retail']},cgst:${data['cgstAmt']},sgst:${data['sgstAmt']},serialno:1,sgstperc:${data['sgstperc']},cgstperc:${data['cgstperc']},makingcost:${data['makingcost']},status:Normal,sno:1.0}");
        }

        // Join all product details into a single string
        String productDetailsString = productDetails.join('');

        String? cusid = await SharedPrefs.getCusId();
        Map<String, dynamic> postData = {
          "cusid": "$cusid",
          "billno": widget.BillNOreset.text,
          "dt": formattedDate,
          "type": widget.ProductSalesTypeController.text,
          "tableno": widget.tableno.text.isEmpty ? "null" : widget.tableno.text,
          "servent": widget.sname.text.isEmpty ? "null" : widget.sname.text,
          "count": itemCountController.text,
          "amount": getTotalFinalAmt(tableData).toString(),
          "discount": SalesDisAMountController.text,
          "vat": gstamt,
          "finalamount": finalamtcontroller.text,
          "cgst0": SGSTPercent0.text,
          "cgst25": SGSTPercent25.text,
          "cgst6": SGSTPercent6.text,
          "cgst9": SGSTPercent9.text,
          "cgst14": SGSTPercent14.text,
          "sgst0": SGSTPercent0.text,
          "sgst25": SGSTPercent25.text,
          "sgst6": SGSTPercent6.text,
          "sgst9": SGSTPercent9.text,
          "sgst14": SGSTPercent14.text,
          "totcgst": cgstamtcontroller.text,
          "totsgst": sgstamtcontroller.text,
          "paidamount":
              widget.paytype.text == "Credit" ? "0" : finalamtcontroller.text,

          "scode": widget.scode.text.isEmpty ? "null" : widget.scode.text,
          "sname": widget.sname.text.isEmpty ? "null" : widget.sname.text,
          "cusname": widget.customername.text.isEmpty
              ? "null"
              : widget.customername.text,
          "contact": widget.customercontact.text.isEmpty
              ? "null"
              : widget.customercontact.text,
          "paytype": widget.paytype.text,
          "disperc": SalesDisPercentageController.text,
          "famount": finalamtcontroller.text,
          // "vendorname": "0",
          // "vendorcomPerc": "0.0",
          // "CommisionAmt": "0.0",
          // "VendorDisPerc": "0.0",
          // "VendorDisamt": "0.0",
          // "FinalAmt": "1000.0",
          // "TotalAmount": "1000.0",
          "Status": "Normal",
          // "OrderNo": null,
          // "PointDis": null,
          // "login": null,
          "gststatus": gstMethod,
          "time": formattedDateTime,
          // "customeramount": null,
          // "customerchange": null,
          "taxstatus": gstcontorller,
          // "serialno": null,
          "taxable": taxableamountController.text,
          "finaltaxable": finaltaxablecontroller.text,
          "SalesDetails": productDetailsString
        };

        // Convert the data to JSON format
        String jsonData = jsonEncode(postData);

        // Send the POST request
        var response = await http.post(
          Uri.parse('$IpAddress/SalesRoundDetailsalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );
        // Check the response status
        if (response.statusCode == 201) {
          print('Data posted successfully');
        } else {
          // Print the response body if available
          print('Failed to post data. Error code: ${response.statusCode}');

          if (response.body != null && response.body.isNotEmpty) {
            print('Response body: ${response.body}');
          }
        }
        logreports('SalesBill: ${widget.BillNOreset.text}_Inserted');
      } catch (e) {
        // Print any exceptions that occur
        print('Failed to post data. Error: $e');
      }
    }

    TextEditingController _pointController = TextEditingController();

    Future<void> calculatePoints(String finalAmountText) async {
      String? cusid = await SharedPrefs.getCusId();
      double finalAmount = double.tryParse(finalAmountText) ?? 0.0;

      final url = Uri.parse('$IpAddress/PointSetting/$cusid/');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            var pointSetting =
                data[0]; // Assuming there's only one item in the list
            double point = double.parse(pointSetting['point']);
            double amount = double.parse(pointSetting['amount']);
            if (finalAmount >= amount) {
              double calculatedPoints = (finalAmount / amount) * point;
              setState(() {
                _pointController.text = calculatedPoints.toString();
              });
              print("point amount : ${_pointController.text}");
              return;
            }
          }
        }
        setState(() {
          _pointController.text =
              '0.0'; // Default to 0 points if no valid point setting found or final amount is less than required
        });
      } catch (e) {
        print('Error fetching point setting: $e');
        setState(() {
          _pointController.text = '0.0'; // Handle error case
        });
      }
    }

    Future<void> updatePointsOnServer(int customerId, double newPoints) async {
      final updateUrl =
          Uri.parse('$IpAddress/SalesCustomeralldatas/$customerId/');
      print("url data : $updateUrl");
      try {
        final response = await http.patch(
          updateUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'Points': newPoints.toString(),
          }),
        );

        if (response.statusCode == 200) {
          print('Points updated successfully on the server.');
        } else {
          print(
              'Failed to update points on the server: ${response.statusCode}   ${response.body}');
        }
      } catch (e) {
        print('Error updating points on the server: $e');
      }
    }

    Future<void> updateCustomerPoints() async {
      // Calculate points based on final amount
      await calculatePoints(finalamtcontroller.text);
      String customerName = widget.customername.text.trim();
      print("Points value: ${_pointController.text}");
      print("Customer name: $customerName");

      if (customerName.isEmpty) {
        // Handle empty customer name input
        return;
      }
      String? cusid = await SharedPrefs.getCusId();

      final url = Uri.parse('$IpAddress/SalesCustomer/$cusid');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          var results = data['results'] as List<dynamic>;

          // Find the customer with the given name
          var customer = results.firstWhere(
            (element) =>
                element['cusname'].toLowerCase() == customerName.toLowerCase(),
            orElse: () => null,
          );

          if (customer != null) {
            // Update points for the found customer
            double existingPoints = double.tryParse(customer['Points']) ?? 0.0;
            double newPoints =
                existingPoints + double.parse(_pointController.text);
            print("New points value: $newPoints");

            // Update points on the server
            await updatePointsOnServer(customer['id'], newPoints);
          } else {
            // Customer not found in the data
            setState(() {
              _pointController.text = 'Customer not found';
            });
          }
        } else {
          // Handle HTTP error
          print(
              'Failed to fetch data: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        // Handle other errors
        print('Error fetching customer data: $e');
      }
    }

    Future<void> _printResult() async {
      try {
        DateTime currentDate = DateTime.now();
        DateTime currentDatetime = DateTime.now();
        String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
        String formattedDateTime =
            DateFormat('hh:mm a').format(currentDatetime);
        String billno = widget.BillNOreset.text;
        String date = formattedDate;
        String paytype = widget.paytype.text;
        String time = formattedDateTime;
        String Customername = widget.customername.text;
        String CustomerContact = widget.customercontact.text;
        String Tableno = widget.tableno.text;
        String tableservent = widget.sname.text;
        String count = itemCountController.text;
        String totalQty = QuantityContController.text;
        String totalamt = getTotalFinalAmt(tableData).toString();
        String discount = SalesDisAMountController.text;
        String FinalAmt = finalamtcontroller.text;

        String sgst25;
        if (SGSTPercent25.text == "0.00") {
          sgst25 = "";
        } else {
          sgst25 = SGSTPercent25.text;
        }
        String sgst6;
        if (SGSTPercent6.text == "0.00") {
          sgst6 = "";
        } else {
          sgst6 = SGSTPercent6.text;
        }
        String sgst9;
        if (SGSTPercent9.text == "0.00") {
          sgst9 = "";
        } else {
          sgst9 = SGSTPercent9.text;
        }
        String sgst14;
        if (SGSTPercent14.text == "0.00") {
          sgst14 = "";
        } else {
          sgst14 = SGSTPercent14.text;
        }

        List<String> productDetails = [];
        for (var data in tableData) {
          // Format each product detail as "{productName},{amount}"
          productDetails.add(
              "${data['productName']}-${data['amount']}-${data['quantity']}");
        }

        String productDetailsString = productDetails.join(',');
        // print("product details : $productDetailsString   ");
        // print(
        //     "billno : $billno   , date : $date ,  paytype : $paytype ,    time :$time    ,customername : $Customername,  customercontact : $CustomerContact  ,    table No : $Tableno,   Tableservent : $tableservent,    total count :  $count,  total qty : $totalQty,    totalamt : $totalamt,    discount amt : $discount,    finalamount:  $FinalAmt");
        print(
            "url : $IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString");

        print(
            "sgst25 : $sgst25  ,  sgst6 :   $sgst6 , sgst 9 :   $sgst9  ,   sgst14:   $sgst14");

        final response = await http.get(Uri.parse(
            '$IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString'));

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

    Future<void> requestStoragePermission() async {
      if (!kIsWeb) {
        // This will only run on mobile platforms
        PermissionStatus status = await Permission.storage.request();

        if (status.isGranted) {
          // Permission is granted, proceed with saving/opening the PDF
        } else {
          // Handle the case where the permission is denied
          // e.g., show an error message to the user
        }
      }
    }

    Future<void> _showPreviewDialog(BuildContext context) async {
      CalculateSGSTFinalAmount();
      DateTime currentDate = DateTime.now();
      DateTime currentDatetime = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
      String formattedDateTime = DateFormat('hh:mm a').format(currentDatetime);

      final pdf = pw.Document();

      final List<pw.Widget> pdfContent = await _buildPdfContent(
        widget.BillNOreset.text,
        widget.paytype.text,
        formattedDate,
        formattedDateTime,
        widget.customername.text,
        widget.customercontact.text,
        widget.tableno.text,
        widget.sname.text,
        itemCountController.text,
        QuantityContController.text,
        getTotalFinalAmt(tableData).toStringAsFixed(2),
        SalesDisAMountController.text,
        finalamtcontroller.text,
        SGSTPercent25.text,
        SGSTPercent6.text,
        SGSTPercent9.text,
        SGSTPercent14.text,
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                  const Text(
                    'Print Previewwwww',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                width: 500, // Width in pixels
                child: ScrollConfiguration(
                  behavior: ScrollBehavior()
                      .copyWith(overscroll: false, scrollbars: false),
                  child: SingleChildScrollView(
                    child: PrintDocument(
                      billno: widget.BillNOreset.text,
                      paytypee: widget.paytype.text,
                      datee: formattedDate,
                      timee: formattedDateTime,
                      cusname: widget.customername.text,
                      cuscontact: widget.customercontact.text,
                      tableno: widget.tableno.text,
                      sname: widget.sname.text,
                      itemcount: itemCountController.text,
                      totalqty: QuantityContController.text,
                      totamt: getTotalFinalAmt(tableData).toString(),
                      discountamt: SalesDisAMountController.text,
                      finalamt: finalamtcontroller.text,
                      sgstt25: SGSTPercent25.text,
                      sgstt6: SGSTPercent6.text,
                      sgstt9: SGSTPercent9.text,
                      sgstt14: SGSTPercent14.text,
                      tableData: tableData,
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final pdf = pw.Document();

                    // Define page size in points (3 inches wide)
                    final double pageWidth = 3 * 86.0; // 3 inches in points
                    final double pageHeight =
                        PdfPageFormat.a4.height; // Using A4 page height

                    // Split items into multiple pages if they exceed page height
                    const itemsPerPage = 5; // Define number of items per page
                    List<Map<String, String>> items = [
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Burger", "rate": "50", "qty": "2", "amount": "100"},
                      // {"name": "Fries", "rate": "150", "qty": "3", "amount": "450"},
                      // {"name": "Coke", "rate": "20", "qty": "2", "amount": "4000"},
                      // {"name": "Briyani", "rate": "50", "qty": "2", "amount": "100"},
                      // Add more items as needed
                    ];

                    final totalPages = (items.length / itemsPerPage).ceil();

                    for (int i = 0; i < totalPages; i++) {
                      final itemsToDisplay = items
                          .skip(i * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();
                      pdf.addPage(
                        pw.Page(
                          pageFormat: PdfPageFormat(pageWidth, pageHeight),
                          build: (pw.Context context) => pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: pdfContent // Passing current page items
                              ),
                        ),
                      );
                    }

                    if (kIsWeb) {
                      final pdfBytes = await pdf.save();
                      final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
                      final url = html.Url.createObjectUrlFromBlob(blob);
                      final anchor = html.AnchorElement(href: url)
                        ..setAttribute('download', 'example.pdf')
                        ..click();
                      html.Url.revokeObjectUrl(url);
                    } else {
                      await requestStoragePermission();
                      final directory = await getExternalStorageDirectory();
                      if (directory != null) {
                        final filePath = '${directory.path}/example.pdf';
                        final file = File(filePath);
                        await file.writeAsBytes(await pdf.save());
                        await OpenFile.open(filePath);
                      }
                    }
                  },
                  child: Text('Generate PDF'),
                ),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(2.0),
                //     ),
                //     backgroundColor: subcolor,
                //     minimumSize: Size(45.0, 31.0), // Set width and height
                //   ),
                //   child: Text('Generate PDF', style: commonWhiteStyle),
                //   onPressed: () async {
                //     final pdf = pw.Document();

                //     // Define page size in points (3 inches wide)
                //     final double pageWidth = 3 * 72.0; // 3 inches in points
                //     final double pageHeight = MediaQuery.of(context)
                //         .size
                //         .height; // 8.5 * 72.0; // Example height in points (8.5 inches)

                //     pdf.addPage(
                //       pw.Page(
                //         pageFormat: PdfPageFormat(pageWidth, pageHeight),
                //         build: (pw.Context context) => pw.Column(
                //           crossAxisAlignment: pw.CrossAxisAlignment.start,
                //           children: pdfContent,
                //         ),
                //       ),
                //     );
                //     if (kIsWeb) {
                //       // For web platform
                //       final pdfBytes = await pdf.save();
                //       final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
                //       final url = html.Url.createObjectUrlFromBlob(blob);
                //       final anchor = html.AnchorElement(href: url)
                //         ..setAttribute('download', 'example.pdf')
                //         ..click();
                //       html.Url.revokeObjectUrl(url);
                //     } else {
                //       // For mobile platforms
                //       await requestStoragePermission();

                //       // Get external storage directory
                //       final directory = await getExternalStorageDirectory();
                //       if (directory != null) {
                //         // Define the PDF file path
                //         final filePath = '${directory.path}/example.pdf';

                //         // Save the PDF to file
                //         final file = File(filePath);
                //         await file.writeAsBytes(await pdf.save());

                //         // Open the saved PDF
                //         await OpenFile.open(filePath);
                //       }
                //     }
                //   },

                //   // if (kIsWeb) {
                //   //   _generateAndDownloadWeb(pdf);
                //   // } else {
                //   //   Printing.layoutPdf(
                //   //     onLayout: (PdfPageFormat format) async => pdf.save(),
                //   //   );
                //   // }
                // )
              ]);
        },
      );
    }

    ;

    Future<void> fetchShopInfo() async {
      String cusid = "BTRM_1"; // Assuming cusid is hardcoded for this example.
      final String url = "$IpAddress/Shopinfo/?cusid=$cusid";

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final shopInfo = data['results'][0];

            restaurantname = shopInfo['shopname'] ?? "";
            address1 = shopInfo['doorno'] ?? "";
            area = shopInfo['area'] ?? "";
            address2 = shopInfo['area2'] ?? "";
            city = shopInfo['city'] ?? "";
            pincode = shopInfo['pincode'] ?? "";
            gstno = shopInfo['gstno'] ?? "";
            fassai = shopInfo['fssai'] ?? "";
            contact = shopInfo['contact'] ?? "";
          }
          print('Restaurant Name: $restaurantname');
          print('Address 1: $address1');
          print('Address 2: $address2');
          print('City and Pincode: $city');
          print('GST Number: $gstno');
          print('FSSAI Number: $fassai');
          print('Contact: $contact');
        } else {
          throw Exception('Failed to load shop info');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    // Function to launch the URL
    void _launchDynamicUrl(BuildContext context) async {
      await fetchShopInfo(); // Fetch the shop info before launching URL
      CalculateSGSTFinalAmount();

      // Ensure the SGST values are updated before proceeding
      await Future.delayed(
          Duration(milliseconds: 100)); // Adjust delay if necessary
      DateTime currentDate = DateTime.now();
      DateTime currentDatetime = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
      String formattedDateTime = DateFormat('hh:mm a').format(currentDatetime);

      String billno =
          widget.BillNOreset.text.isNotEmpty ? widget.BillNOreset.text : "null";
      String date = formattedDate;
      String paytype =
          widget.paytype.text.isNotEmpty ? widget.paytype.text : "null";
      String time = formattedDateTime;
      String customername = widget.customername.text.isNotEmpty
          ? widget.customername.text
          : "null";
      String customercontact = widget.customercontact.text.isNotEmpty
          ? widget.customercontact.text
          : "null";
      String tableno =
          widget.tableno.text.isNotEmpty ? widget.tableno.text : "null";
      String tableservent =
          widget.sname.text.isNotEmpty ? widget.sname.text : "null";
      String count = itemCountController.text;
      String totalQty = QuantityContController.text;
      String totalamt = getTotalFinalAmt(tableData).toString();
      String discount = SalesDisAMountController.text;
      String finalAmt = finalamtcontroller.text;

      String sgst25 =
          SGSTPercent25.text.isNotEmpty ? SGSTPercent25.text : "0.0";
      String sgst6 = SGSTPercent6.text.isNotEmpty ? SGSTPercent6.text : "0.0";
      String sgst9 = SGSTPercent9.text.isNotEmpty ? SGSTPercent9.text : "0.0";
      String sgst14 =
          SGSTPercent14.text.isNotEmpty ? SGSTPercent14.text : "0.0";
      print('SGSTPercent25 value: ${SGSTPercent25.text}');

      // Print SGST values for debugging
      print('SGST25: $sgst25');
      print('SGST6: $sgst6');
      print('SGST9: $sgst9');
      print('SGST14: $sgst14');

      // Concatenate product details as "{productName}-{amount}-{quantity}"
      List<String> productDetails = [];
      for (var data in tableData) {
        productDetails.add(
            "${data['productName']},${data['amount']},${data['quantity']},${data['Amount']}");
      }
      String productDetailsString = productDetails.join('-');

      // Construct the dynamic URL
      String dynamicUrl =
          'http://192.168.10.140:82/print_text/${Uri.encodeComponent(restaurantname)}/${Uri.encodeComponent(area)}/${Uri.encodeComponent(address2)}/${Uri.encodeComponent(city)}/${Uri.encodeComponent(pincode)}/${Uri.encodeComponent(fassai)}/${Uri.encodeComponent(contact)}/000/$billno/$paytype/$date/$time/$customername/$customercontact/$tableno/$tableservent/$productDetailsString/$count/$totalamt/$totalQty/$discount/$sgst25/$sgst6/$sgst9/$sgst14/$finalAmt/';
      print('url : $dynamicUrl');

      // Launch the dynamic URL
      if (await canLaunch(dynamicUrl)) {
        await launch(dynamicUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $dynamicUrl')),
        );
      }
    }

    void _showPrintDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Print Confirmation'),
            content: Text('Do you want to print the receipt?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Pop the dialog if "No" is pressed
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  _launchDynamicUrl(
                      context); // Launch the URL if "Yes" is pressed
                  Navigator.of(context).pop(); // Pop the dialog after launching
                },
              ),
            ],
          );
        },
      );
    }

    // Future<void> _fetchShopDetails() async {
    //   try {
    //     String? cusid = await SharedPrefs.getCusId();
    //     if (cusid == null || cusid.isEmpty) {
    //       print('Customer ID is null or empty');
    //       return;
    //     }

    //     final response = await http.get(Uri.parse('$IpAddress/Shopinfo/'));

    //     if (response.statusCode == 200) {
    //       final data = json.decode(response.body);

    //       if (data['results'] is List && data['results'].isNotEmpty) {
    //         final shop = (data['results'] as List).firstWhere(
    //           (shop) => shop['cusid'] == cusid,
    //           orElse: () => null,
    //         );

    //         if (shop != null) {
    //           setState(() {
    //             _dynamicUrl =
    //                 '$IpAddress/print_text/${shop['shopname']}/${shop['doorno']}/${shop['area']}/${shop['area2']}/${shop['city']}/${shop['pincode']}/${shop['contact']}/${shop['gstno']}/${shop['fssai']}'; // Modify this URL format as needed
    //           });
    //         } else {
    //           print('No shop details found for the given cusid');
    //         }
    //       } else {
    //         print('No shop details available');
    //       }
    //     } else {
    //       throw Exception('Failed to load shop details');
    //     }
    //   } catch (e) {
    //     print('Error fetching shop details: $e');
    //   }
    // }

    // void printView(BuildContext context) async {
    //   bool? shouldPrint = await showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text('Do you want to print?'),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop(true);
    //             },
    //             child: Text('Yes'),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop(false);
    //             },
    //             child: Text('No'),
    //           ),
    //         ],
    //       );
    //     },
    //   );

    //   // if (shouldPrint == true) {
    //   //   DateTime currentDate = DateTime.now();
    //   //   DateTime currentDatetime = DateTime.now();
    //   //   String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
    //   //   String formattedDateTime =
    //   //       DateFormat('hh:mm a').format(currentDatetime);
    //   //   String billno = widget.BillNOreset.text;
    //   //   String date = formattedDate;
    //   //   String paytype = widget.paytype.text;
    //   //   String time = formattedDateTime;
    //   //   String Customername = widget.customername.text;
    //   //   String CustomerContact = widget.customercontact.text;
    //   //   String Tableno = widget.tableno.text;
    //   //   String tableservent = widget.sname.text;
    //   //   String count = itemCountController.text;
    //   //   String totalQty = QuantityContController.text;
    //   //   String totalamt =
    //   //       getTotalFinalAmt(tableData).toString(); // Define this function
    //   //   String discount = SalesDisAMountController.text;
    //   //   String FinalAmt = finalamtcontroller.text;

    //   //   String sgst25 = SGSTPercent25.text == "0.00" ? "" : SGSTPercent25.text;
    //   //   String sgst6 = SGSTPercent6.text == "0.00" ? "" : SGSTPercent6.text;
    //   //   String sgst9 = SGSTPercent9.text == "0.00" ? "" : SGSTPercent9.text;
    //   //   String sgst14 = SGSTPercent14.text == "0.00" ? "" : SGSTPercent14.text;

    //   //   List<String> productDetails = [];
    //   //   for (var data in tableData) {
    //   //     productDetails.add(
    //   //         "${data['productName']}-${data['amount']}-${data['quantity']}");
    //   //   }
    //   //   String productDetailsString = productDetails.join(',');

    //   //   String url =
    //   //       '$IpAddress/print_text/$restaurantname/$address1/$address2/$city/$pincode/$fassai/$contact/000/1234/$paytype/$date/$time/ismail/86767675/12/ismail/briyani,150,2,3-veg,123,4,500/12/4/134500/0.0/12.0/23.0/34.0/0.5/13000/'; // '$IpAddress/SalesPrint3Inch/$doorno-$restaurantname-$city-$pincode/$contact/$billno-$date-$paytype-$time/'
    //   //   // '$Customername-$CustomerContact/$Tableno-$tableservent/'
    //   //   // '$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/'
    //   //   // '$productDetailsString';

    //   //   print("url : $url");

    //   //   if (await canLaunch(url)) {
    //   //     await launch(url);
    //   //   } else {
    //   //     throw 'Could not launch $url';
    //   //   }
    //   if (_dynamicUrl != null && await canLaunch(_dynamicUrl!)) {
    //     await launch(_dynamicUrl!);
    //   } else {
    //     Navigator.of(context).pop();
    //   }
    // }

    return Padding(
      padding: EdgeInsets.only(
        right: Responsive.isDesktop(context) ? 20 : 0,
        left: !Responsive.isDesktop(context) ? 00 : 0,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
            color: Color.fromARGB(255, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.isMobile(context) ||
                                    Responsive.isTablet(context)
                                ? 15
                                : 15,
                            right: 0,
                            bottom: 5),
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("No.Of.Items: ",
                                            // "No.Of.Items: ${getProductCountCallback(tableData)}",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .align_vertical_center_sharp, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: TextFormField(
                                                    controller:
                                                        itemCountController,
                                                    readOnly: true,
                                                    onChanged: (value) {
                                                      print(
                                                          "NO of itemis changed into the new value ");
                                                    },
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("Taxable Amt ₹",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .add_business_outlined, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: TextField(
                                                    readOnly: true,
                                                    controller:
                                                        taxableamountController,
                                                    onChanged: (newvalue) {},
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (Responsive.isDesktop(context))
                                  SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("Discount %",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .discount, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text
                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,
                                                color: Colors.grey[100],
                                                child: Focus(
                                                  onKey: (FocusNode node,
                                                      RawKeyEvent event) {
                                                    if (event
                                                        is RawKeyDownEvent) {
                                                      if (event.logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowDown) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FinalAmtFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowRight) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                discountAmtFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowUp) {
                                                        FocusScope.of(context)
                                                            .requestFocus(widget
                                                                .codeFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .enter) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FinalAmtFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                    }
                                                    return KeyEventResult
                                                        .ignored;
                                                  },
                                                  child: TextFormField(
                                                      controller:
                                                          SalesDisPercentageController,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      focusNode:
                                                          discountpercFocusNode,
                                                      onFieldSubmitted: (_) =>
                                                          _fieldFocusChange(
                                                              context,
                                                              discountpercFocusNode,
                                                              discountAmtFocusNode),
                                                      onChanged: (newValue) {
                                                        calculateDiscountAmount();
                                                        CalculateCGSTFinalAmount();
                                                        CalculateSGSTFinalAmount();
                                                        calculateFinalTaxableAmount();
                                                        calculateFinaltotalAmount();

                                                        double someAmount =
                                                            double.tryParse(
                                                                    finalamtcontroller
                                                                        .text) ??
                                                                0.0;
                                                        // calFinaltotalAmount(
                                                        //     someAmount);
                                                        // //     finalamtcontroller);

                                                        SalesDisPercentageController
                                                                .selection =
                                                            TextSelection.fromPosition(
                                                                TextPosition(
                                                                    offset: SalesDisPercentageController
                                                                        .text
                                                                        .length));
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.0),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
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
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("Discount ₹",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .rate_review, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: Focus(
                                                  onKey: (FocusNode node,
                                                      RawKeyEvent event) {
                                                    if (event
                                                        is RawKeyDownEvent) {
                                                      if (event.logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowDown) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FinalAmtFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowLeft) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                discountpercFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowUp) {
                                                        FocusScope.of(context)
                                                            .requestFocus(widget
                                                                .codeFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .enter) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FinalAmtFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                    }
                                                    return KeyEventResult
                                                        .ignored;
                                                  },
                                                  child: TextFormField(
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      focusNode:
                                                          discountAmtFocusNode,
                                                      onFieldSubmitted: (_) =>
                                                          _fieldFocusChange(
                                                              context,
                                                              discountAmtFocusNode,
                                                              FinalAmtFocusNode),
                                                      controller:
                                                          SalesDisAMountController,
                                                      onChanged: (newvalue) {
                                                        calculateDiscountPercentage();
                                                        CalculateCGSTFinalAmount();
                                                        CalculateSGSTFinalAmount();

                                                        calculateFinaltotalAmount();
                                                        // calculatetotalAmount();
                                                        calculateFinalTaxableAmount();
                                                        // print(
                                                        //     "finalamount :: ${FinallyyyAmounttts.text}");
                                                        SalesDisAMountController
                                                                .selection =
                                                            TextSelection.fromPosition(
                                                                TextPosition(
                                                                    offset: SalesDisAMountController
                                                                        .text
                                                                        .length));
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.0),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
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
                                      ),
                                    ],
                                  ),
                                ),
                                if (Responsive.isDesktop(context))
                                  SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("Final Taxable ₹",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .rotate_90_degrees_cw_outlined, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: TextField(
                                                    readOnly: true,
                                                    controller:
                                                        finaltaxablecontroller,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("CGST ₹",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .attach_money_rounded, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.27,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: TextField(
                                                    readOnly: true,
                                                    controller:
                                                        cgstamtcontroller,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (Responsive.isDesktop(context))
                                  SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("SGST ₹",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .add_moderator_outlined, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: TextField(
                                                    readOnly: true,
                                                    controller:
                                                        sgstamtcontroller,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  // color:subcolor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 5),
                                        child: Text("Final Amount ₹",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 4),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.11
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.37,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .auto_mode_rounded, // Your icon here
                                                size: 17,
                                              ),
                                              SizedBox(
                                                  width:
                                                      5), // Adjust spacing between icon and text

                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28,

                                                color: Colors.grey[100],
                                                // color: Colors.grey[100],
                                                child: Focus(
                                                  onKey: (FocusNode node,
                                                      RawKeyEvent event) {
                                                    if (event
                                                        is RawKeyDownEvent) {
                                                      if (event.logicalKey ==
                                                          LogicalKeyboardKey
                                                              .arrowUp) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                discountpercFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else if (event
                                                              .logicalKey ==
                                                          LogicalKeyboardKey
                                                              .enter) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                SavebuttonFocusNode);
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                    }
                                                    return KeyEventResult
                                                        .ignored;
                                                  },
                                                  child: TextFormField(
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      focusNode:
                                                          FinalAmtFocusNode,
                                                      onFieldSubmitted: (_) {
                                                        // Move focus to the save button
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                SavebuttonFocusNode);
                                                      },
                                                      controller:
                                                          finalamtcontroller,
                                                      onChanged: (newvalue) {},
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.0),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
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
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Container(
                                    // color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 6,
                                              top: 0),
                                          child: Container(
                                            child: ElevatedButton(
                                              focusNode: SavebuttonFocusNode,
                                              onPressed: () async {
                                                if (SalesDisAMountController
                                                        .text.isEmpty ||
                                                    SalesDisPercentageController
                                                        .text.isEmpty ||
                                                    widget
                                                        .paytype.text.isEmpty ||
                                                    tableData.isEmpty) {
                                                  // Show error message
                                                  WarninngMessage(context);
                                                  return;
                                                }

                                                // Post_SaesRoundtbl();
                                                // Post_SaesDetailstbl(tableData);

                                                postDataWithIncrementedSerialNo();
                                                Post_salesIncometbl();
                                                post_stockItems(tableData);
                                                Post_SalesDetailsRound();
                                                updateCustomerPoints();

                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewSalesEntry(
                                                      Fianlamount:
                                                          TextEditingController(),
                                                      cusnameController:
                                                          TextEditingController(
                                                              text: ''),
                                                      TableNoController:
                                                          TextEditingController(
                                                              text: ''),
                                                      cusaddressController:
                                                          TextEditingController(
                                                              text: ''),
                                                      cuscontactController:
                                                          TextEditingController(
                                                              text: ''),
                                                      scodeController:
                                                          TextEditingController(
                                                              text: ''),
                                                      snameController:
                                                          TextEditingController(
                                                              text: ''),
                                                      TypeController:
                                                          TextEditingController(
                                                              text: ''),
                                                      salestableData: [],
                                                      isSaleOn: true,
                                                    ),
                                                  ),
                                                );

                                                _printResult();
                                                successfullySavedMessage(
                                                    context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Save',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Container(
                                    // color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 6,
                                              top: 0),
                                          child: Container(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _showPreviewDialog(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Previewww',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Container(
                                    // color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 6,
                                              top: 0),
                                          child: Container(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _showPrintDialog(
                                                    context); // Show dialog when button is pressed
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('print',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 25),
                                //   child: Container(
                                //     // color: Colors.green,
                                //     child: Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: [
                                //         Padding(
                                //           padding: EdgeInsets.only(
                                //               left:
                                //                   Responsive.isDesktop(context)
                                //                       ? 10
                                //                       : 6,
                                //               top: 0),
                                //           child: Container(
                                //             child: ElevatedButton(
                                //               onPressed: () {
                                //                 // Handle form submission
                                //               },
                                //               style: ElevatedButton.styleFrom(
                                //                 shape: RoundedRectangleBorder(
                                //                   borderRadius:
                                //                       BorderRadius.circular(
                                //                           2.0),
                                //                 ),
                                //                 backgroundColor: subcolor,
                                //                 minimumSize: Size(45.0,
                                //                     31.0), // Set width and height
                                //               ),
                                //               child: Text(
                                //                 'Preview',
                                //                 style: TextStyle(
                                //                   color: Colors.white,
                                //                   fontSize: 12,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Container(
                                    // color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 10
                                                : 6,
                                            top: 0,
                                          ),
                                          child: Container(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero),
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      content: Container(
                                                        width: 1100,
                                                        // height: 700,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                                height: 10),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left: Responsive
                                                                        .isDesktop(
                                                                            context)
                                                                    ? 40
                                                                    : 6,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  IconButton(
                                                                    icon: Icon(Icons
                                                                        .cancel),
                                                                    color: Colors
                                                                        .red,
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            )
// Customize the text style as needed
                                                            ,
                                                            Container(
                                                                width: 1100,
                                                                height: 600,
                                                                child:
                                                                    GstDetailsForm()),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Add Gst',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Container(
                                    // color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 6,
                                              top: 0),
                                          child: Container(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewSalesEntry(
                                                      Fianlamount:
                                                          TextEditingController(),
                                                      cusnameController:
                                                          TextEditingController(),
                                                      TableNoController:
                                                          TextEditingController(),
                                                      cusaddressController:
                                                          TextEditingController(),
                                                      cuscontactController:
                                                          TextEditingController(),
                                                      scodeController:
                                                          TextEditingController(),
                                                      snameController:
                                                          TextEditingController(),
                                                      TypeController:
                                                          TextEditingController(),
                                                      salestableData: [],
                                                      isSaleOn: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Refresh',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
              ],
            )),
      ),
    );
  }

  List<Map<String, dynamic>> productList = [];

  Future<List<Map<String, dynamic>>> salesProductList() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          for (var product in results) {
            // Extracting required fields and creating a map
            Map<String, dynamic> productMap = {
              'id': product['id'],
              'name': product['name'],
              'stock': product['stock'],
              'stockvalue': product['stockvalue']
            };

            // Adding the map to the list
            productList.add(productMap);
          }
          // print("product list : $productList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }

    return productList;
  }

  void processNewSalesEntry(
      BuildContext context, TextEditingController finalamtcontroller) {
    // Find the ancestor widget of type finalamount
    final currentWidget = context.findAncestorWidgetOfExactType<finalamount>();

    if (currentWidget == null) {
      widget.onFinalAmountButtonPressed(finalamtcontroller);
      print("Current widget is not finalamount ${finalamtcontroller.text}");
      return;
    }

    // Update the state of the finalamount widget
    currentWidget.updateFinalAmountforall(finalamtcontroller.text);

    print("Final Amount: ${finalamtcontroller.text}");
  }

  stockcheck(value) {
    print("new auantity entered amount is $value");
    String productName = ProductNameController.text;
    int quantity = int.tryParse(value) ?? 0;

    salesProductList().then((List<Map<String, dynamic>> productList) {
      Map<String, dynamic>? product = productList.firstWhere(
        (element) => element['name'] == productName,
        orElse: () => {'stock': 'no'},
      );

      String stockStatus = product['stock'];

      if (stockStatus == 'No') {
        FocusScope.of(context).requestFocus(addbuttonFocusNode);
      } else if (stockStatus == 'Yes') {
        double stockValue =
            double.tryParse(product['stockvalue'].toString()) ?? 0;

        if (quantity > stockValue) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stock Check'),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              content: Container(
                width: 500,
                child: Text(
                    'The entered quantity exceeds the available stock value (${stockValue}). '
                    'Do you want to proceed by deducting this excess quantity from the stock?'),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        FocusScope.of(context).requestFocus(quantityFocusNode);
                      },
                      child: Text('Yes Add'),
                    ),
                    TextButton(
                      onPressed: () {
                        QuantityController.text = stockValue.toString();
                        Navigator.of(context).pop();
                        FocusScope.of(context).requestFocus(quantityFocusNode);
                      },
                      child: Text('Skip'),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          _fieldFocusChange(context, widget.codeFocusNode, itemFocusNode);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.1;
    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.07;
    return Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 2,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 10, top: 0),
                child: Text("Code", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 20, top: 4),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.numbers, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                          height: 24,
                          width: Responsive.isDesktop(context)
                              ? desktoptextfeildwidth
                              : MediaQuery.of(context).size.width * 0.26,
                          color: Colors.grey[100],
                          child: Focus(
                            onKey: (FocusNode node, RawKeyEvent event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  FocusScope.of(context)
                                      .requestFocus(discountpercFocusNode);
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.enter) {
                                  FocusScope.of(context)
                                      .requestFocus(itemFocusNode);
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: TextFormField(
                              controller: ProductCodeController,
                              textInputAction: TextInputAction.next,
                              focusNode: widget.codeFocusNode,
                              onFieldSubmitted: (_) => _fieldFocusChange(
                                  context, widget.codeFocusNode, itemFocusNode),
                              onChanged: (newValue) {
                                widget.ProductSalesTypeController.text;
                                fetchproductName();
                                updateTotal();
                                updateFinalAmount();
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 180, 180, 180),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 7.0,
                                ),
                              ),
                              style: textStyle,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 20, top: 0),
                child: Text("Item", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 20, top: 0),
                child: Container(
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.13
                        : MediaQuery.of(context).size.width * 0.38,
                    child: _buildProductnameDropdown()),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 10, top: 0),
                child: Text("Amount", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 30 : 15, top: 4),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? desktoptextfeildwidth
                            : MediaQuery.of(context).size.width * 0.285,

                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: TextFormField(
                            readOnly: true,
                            controller: ProductAmountController,
                            onChanged: (newValue) {
                              fetchproductName();
                              updatetaxableamount();
                              updateCGSTAmount();
                              updateSGSTAmount();
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 180, 180, 180),
                                    width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: const Color.fromARGB(0, 0, 0, 0),
                                    width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 20, top: 0),
                child: Text("Quantity", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 25, top: 4),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_alert_sharp, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? desktoptextfeildwidth
                            : MediaQuery.of(context).size.width * 0.285,

                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: Focus(
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowDown) {
                                FocusScope.of(context)
                                    .requestFocus(discountpercFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowLeft) {
                                FocusScope.of(context)
                                    .requestFocus(itemFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                FocusScope.of(context)
                                    .requestFocus(addbuttonFocusNode);
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                              controller: QuantityController,
                              focusNode: quantityFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                _fieldFocusChange(context, quantityFocusNode,
                                    addbuttonFocusNode);
                              },
                              onChanged: (newValue) {
                                stockcheck(newValue);
                                updateTotal();
                                updatetaxableamount();
                                updateCGSTAmount();
                                updateSGSTAmount();
                                updateFinalAmount();
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 180, 180, 180),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
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
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 10, top: 0),
                child: Text("Total", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 15, top: 4),
                child: Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.14
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.paid_outlined, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.1
                            : MediaQuery.of(context).size.width * 0.31,
                        color: Colors.grey[100],
                        child: Focus(
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowDown) {
                                FocusScope.of(context)
                                    .requestFocus(discountpercFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowLeft) {
                                FocusScope.of(context)
                                    .requestFocus(quantityFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                // FocusScope.of(context)
                                //     .requestFocus(addbuttonFocusNode);
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                              readOnly: true,
                              controller: FinalAmtController,
                              focusNode: finaltotalFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                // Move focus to the save button
                                // FocusScope.of(context)
                                //     .requestFocus(addbuttonFocusNode);
                              },
                              onChanged: (newValue) {},
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 180, 180, 180),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 7.0,
                                ),
                              ),
                              style: AmountTextStyle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 20,
                    top: Responsive.isDesktop(context) ? 23 : 4),
                child: Container(
                  width: Responsive.isDesktop(context)
                      ? (updateenable ? 83 : 60)
                      : 60,
                  child: ElevatedButton(
                    focusNode: addbuttonFocusNode,
                    onPressed: () {
                      updateenable ? UpdateData() : saveData();
                      setState(() {
                        FocusScope.of(context)
                            .requestFocus(widget.codeFocusNode);
                      });

                      // print("finalamount :: ${FinallyyyAmounttts.text}");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        backgroundColor: subcolor,
                        minimumSize: Size(45.0, 31.0), // Set width and height
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0)),
                    child: Text(updateenable ? 'Update' : 'Add',
                        style: commonWhiteStyle.copyWith(fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        // finalamtRS(),
        Padding(
          padding: EdgeInsets.only(
              top: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.01
                  : 0,
              bottom: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.01
                  : 0),
          child: tableView(),
        ),
        bottomcontainer()
      ],
    );
  }

  void _deleteRow(int index) {
    setState(() {
      tableData.removeAt(index);
    });
    updatefinaltabletotalAmount();
    processNewSalesEntry(context, FINALAMTCONTROLLWE);
    successfullyDeleteMessage(context);
  }

  Future<bool?> _showDeleteConfirmationDialog(index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this data?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteRow(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}

class tablesalesview extends StatefulWidget {
  final TextEditingController ProductSalesTypeController;
  final TextEditingController SalesPaytype;

  tablesalesview({
    required this.ProductSalesTypeController,
    required this.SalesPaytype,
  });
  @override
  State<tablesalesview> createState() => _tablesalesviewState();
}

class _tablesalesviewState extends State<tablesalesview> {
  String? selectedValue;
  late Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  DateTime? _startTime;
  Map<String, int> _elapsedTimes = {};

  List<dynamic> _tableData = [];
  TextEditingController TableNoController = TextEditingController();

  TextEditingController SCodeController = TextEditingController();
  TextEditingController SNameController = TextEditingController();
  TextEditingController TableCusNameController = TextEditingController();
  TextEditingController TableContactController = TextEditingController();
  TextEditingController TableAddressController = TextEditingController();
  TextEditingController TableCodeController = TextEditingController();
  TextEditingController TableItemController = TextEditingController();
  TextEditingController TableAmountController = TextEditingController();
  TextEditingController TableProdutMakingCostController =
      TextEditingController();
  TextEditingController TableProdutCategoryController = TextEditingController();

  TextEditingController TableQuantityController = TextEditingController();

  TextEditingController TotalAmtController = TextEditingController();
  TextEditingController CGSTperccontroller = TextEditingController();
  TextEditingController SGSTPercController = TextEditingController();
  TextEditingController CGSTAmtController = TextEditingController();
  TextEditingController SGSTAmtController = TextEditingController();
  TextEditingController FinalAmtController = TextEditingController();

  TextEditingController Taxableamountcontroller = TextEditingController();
  TextEditingController SalesGstMethodController = TextEditingController();
  TextEditingController salestypecontroller = TextEditingController();

  String tableKey = ' ';

  double totalAmount = 0.0;
  @override
  void initState() {
    super.initState();
    fetchData();
    fetchProductNameList();
    fetchGSTMethod();
    salestypecontroller = widget.ProductSalesTypeController;
    _loadSavedData();
    _startTimer();
    _loadPreferences();
    _stopTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update state
        });
      }
    });
    updateTotalAmount();
    FinalAmtController.text = calculateTotalAmount().toStringAsFixed(2);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _stopTimer();
    super.dispose();
  }

  FocusNode scodeFocusNode = FocusNode();
  FocusNode snameFocusNode = FocusNode();
  FocusNode CusnameFocusNode = FocusNode();
  FocusNode CusContactFocusNode = FocusNode();

  FocusNode CusAddressFocusNode = FocusNode();

  FocusNode codeFocusNode = FocusNode();
  FocusNode itemFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode quantityFocusNode = FocusNode();
  FocusNode finaltotFocusNode = FocusNode();

  FocusNode addbuttonFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  List<String> ProductNameList = [];

  Future<void> fetchProductNameList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductNameList.addAll(
              results.map<String>((item) => item['name'].toString()));
          // print("payment List : $ProductNameList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $ProductNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? ProductNameSelected;

  int? _selectedProductnameIndex;

  bool _isProductnameOptionsVisible = false;
  int? _ProductnamehoveredIndex;
  Widget _buildProductnameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 15,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    color: Colors.grey[100],
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.08
                        : MediaQuery.of(context).size.width * 0.2,
                    child: ProductnameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        width: 1350,
                        height: 800,
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            AddProductDetailsPage(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchproductName();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(color: subcolor),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ProductnameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(TableItemController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProductnameIndex = currentIndex + 1;
                TableItemController.text = ProductNameList[currentIndex + 1];
                _isProductnameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(TableItemController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductnameIndex = currentIndex - 1;
                TableItemController.text = ProductNameList[currentIndex - 1];
                _isProductnameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: itemFocusNode,
          onSubmitted: (String? suggestion) async {
            await fetchproductcode();
            _fieldFocusChange(context, itemFocusNode, quantityFocusNode);
          },
          controller: TableItemController,
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
          onChanged: (text) async {
            setState(() {
              _isProductnameOptionsVisible = true;
              ProductNameSelected = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProductnameOptionsVisible && pattern.isNotEmpty) {
            return ProductNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProductnamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProductnamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductnameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductnameIndex == null &&
                          ProductNameList.indexOf(TableItemController.text) ==
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
            fetchproductcode();

            TableItemController.text = suggestion!;
            ProductNameSelected = suggestion;
            _isProductnameOptionsVisible = false;

            FocusScope.of(context).requestFocus(quantityFocusNode);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  bool isProductAlreadyExists(String productName) {
    // Assuming table data is stored in a List<Map<String, dynamic>> called tableData
    for (var item in salestableData) {
      if (item['productName'] == productName) {
        return true;
      }
    }
    return false;
  }

  void productalreadyexist() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'This product is already in the table data.',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  List<Map<String, dynamic>> productList = [];
  Future<List<Map<String, dynamic>>> salesProductList() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          for (var product in results) {
            // Extracting required fields and creating a map
            Map<String, dynamic> productMap = {
              'name': product['name'],
              'stock': product['stock'],
              'stockvalue': product['stockvalue']
            };

            // Adding the map to the list
            productList.add(productMap);
          }
          // print("product list : $productList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }

    return productList;
  }

  Future<void> fetchproductName() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
    String ProductCode =
        TableCodeController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductCodeController Name: $ProductCode");

    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each customer entry
          for (var entry in results) {
            if (entry['code'].toString().toLowerCase() == ProductCode) {
              // Convert to lowercase
              // Retrieve the contact number and address for the customer
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }
              String name = entry['name'];
              String agentId = entry['id'].toString();
              String makingcost = entry['makingcost'];
              String category = entry['category'];

              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (ProductCode.isNotEmpty) {
                TableItemController.text = name;
                TableAmountController.text = amount;
                TableAmountController.text = amount;
                TableProdutMakingCostController.text = makingcost;
                TableProdutCategoryController.text = category;

                CGSTperccontroller.text = cgstperc;
                SGSTPercController.text = sgstperc;

                contactFound = true;
                break; // Exit the loop once the contact number is found
              }
            }
          }

          // print("CGst Percentages:${CGSTperccontroller.text}");
          // print("Sgst Percentages:${SGSTPercController.text}");
          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or contact number found
            break;
          }
        } else {
          throw Exception(
              'Failed to load customer contact information: ${response.reasonPhrase}');
        }
      }

      // Print a message if contact number not found
      if (!contactFound) {
        // print("No contact number found for $ProductCode");
      }
    } catch (e) {
      print('Error fetching customer contact information: $e');
    }
  }

  Future<void> fetchproductcode() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
    String productName =
        TableItemController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductNameController Name: $productName");
    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each product entry
          for (var entry in results) {
            if (entry['name'].toString().toLowerCase() == productName) {
              // Convert to lowercase
              // Retrieve the code and id for the product
              String code = entry['code'];
              String agentId = entry['id'].toString();

              // Determine the amount based on the salestype
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }
              String makingcost = entry['makingcost'];
              String category = entry['category'];

              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (productName.isNotEmpty) {
                TableCodeController.text = code;
                TableAmountController.text = amount;
                TableProdutMakingCostController.text = makingcost;
                TableProdutCategoryController.text = category;

                CGSTperccontroller.text = cgstperc;

                SGSTPercController.text = sgstperc;

                contactFound = true;
                break; // Exit the loop once the product information is found
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or product information found
            break;
          }
        } else {
          throw Exception(
              'Failed to load product information: ${response.reasonPhrase}');
        }
      }

      // Print a message if product information not found
      if (!contactFound) {
        // print("No product information found for $productName");
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchSName() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/StaffDetails/$cusid/';
    String productCode = SCodeController.text; // Code entered by the user
    // print("Code : ${SCodeController.text}");

    try {
      String url = '$baseUrl?code=$productCode'; // Append code to URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];

        if (results.isNotEmpty) {
          // Filter the results based on the entered code
          var filteredResults =
              results.where((entry) => entry['code'] == productCode);

          if (filteredResults.isNotEmpty) {
            // Clear previous names
            SNameController.clear();

            // Retrieve the product name for the specific code
            String name = filteredResults.first['serventname'];

            // Update the SNameController with the retrieved name
            SNameController.text = name;
          } else {
            // print('No product found for code: $productCode');
          }
        } else {
          // print('No products found for code: $productCode');
        }
      } else {
        throw Exception(
            'Failed to load product information: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchcode() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/StaffDetails/$cusid/';
    String productName = SNameController.text; // Code entered by the user
    // print("Code : ${SCodeController.text}");

    try {
      String url = '$baseUrl?serventname=$productName'; // Append code to URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];

        if (results.isNotEmpty) {
          // Filter the results based on the entered code
          var filteredResults =
              results.where((entry) => entry['serventname'] == productName);

          if (filteredResults.isNotEmpty) {
            // Clear previous names
            SCodeController.clear();

            // Retrieve the product name for the specific code
            String code = filteredResults.first['code'];

            // Update the SNameController with the retrieved name
            SCodeController.text = code;
          } else {
            // print('No product found for code: $productName');
          }
        } else {
          // print('No products found for code: $productName');
        }
      } else {
        throw Exception(
            'Failed to load product information: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/Sales_tableCount/$cusid/'));
    if (response.statusCode == 200) {
      setState(() {
        _tableData = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchGSTMethod() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/GstDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    String gstMethod = ''; // Initialize GST method to empty string

    // Iterate through each entry in the JSON data
    for (var entry in jsonData) {
      // Check if the name is "Sales"
      if (entry['name'] == "Sales") {
        // Retrieve the GST method for "Sales"
        gstMethod = entry['gst'];
        break; // Exit the loop once the entry is found
      }
    }

    // Update rateController if needed
    if (gstMethod.isNotEmpty) {
      SalesGstMethodController.text = gstMethod;
      // print("GST method for Sales: ${SalesGstMethodController.text}");
      // print("GST method for Sales: $gstMethod");
    } else {
      // print("No GST method found for Sales");
    }
  }

  void updateCGSTAmount() {
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * cgstPercentage);
    // Calculate the CGST amount
    double cgstAmount = numerator / 100;

    // Update the CGST amount controller
    CGSTAmtController.text = cgstAmount.toStringAsFixed(2);
    // print("CGST amont = ${CGSTAmtController.text}");
  }

  void updateSGSTAmount() {
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * sgstPercentage);
    // Calculate the CGST amount
    double sgstAmount = numerator / 100;

    // Update the CGST amount controller
    SGSTAmtController.text = sgstAmount.toStringAsFixed(2);
    // print("SGZGST amont = ${SGSTAmtController.text}");
  }

  void updateTotal() {
    double rate = double.tryParse(TableAmountController.text) ?? 0;
    double quantity = double.tryParse(TableQuantityController.text) ?? 0;
    double total = rate * quantity;
    TotalAmtController.text =
        total.toStringAsFixed(2); // Format total to 2 decimal places
    // Taxableamountcontroller.text = total.toStringAsFixed(2);
  }

  void updatetaxableamount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;
    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(SGSTPercController.text) ?? 0;

    double numeratorPart1 = total;

    if (SalesGstMethodController.text == "Excluding") {
      // Calculate taxable amount excluding GST
      double taxableAmount = numeratorPart1;
      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else if (SalesGstMethodController.text == "Including") {
      double cgstsgst = cgstPercentage + sgstPercentage;
      double cgstnumerator = numeratorPart1 * cgstPercentage;
      double cgstdenominator = 100 + cgstsgst;
      double cgsttaxable = cgstnumerator / cgstdenominator;
      double sgstnumerator = numeratorPart1 * sgstPercentage;
      double sgstdenominator = 100 + cgstsgst;
      double sgsttaxable = sgstnumerator / sgstdenominator;

      double taxableAmount = numeratorPart1 - (cgsttaxable + sgsttaxable);

      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("cgst taxable amount : $cgsttaxable");
      // print("sgst taxable amount : $sgsttaxable");
      // print("Total taxable amount : $taxableAmount");
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else {
      double taxableAmount = numeratorPart1;
      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    }
  }

  void updateFinalAmount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;

    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double denominator = cgstAmount + sgstAmount;

    if (SalesGstMethodController.text == "Excluding") {
      double finalAmount = taxableAmount + denominator;
      // print("FIanl amount = ${taxableAmount} + ${denominator}");

      // Update the final amount controller
      FinalAmtController.text = finalAmount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    } else if (SalesGstMethodController.text == "Including") {
      double totalfinalamount = total;
      FinalAmtController.text = totalfinalamount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    } else {
      double taxableAmount = total;
      FinalAmtController.text = taxableAmount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    }
  }

  void _saveText(
      String tableno,
      String scodeValue,
      String snameValue,
      String customerNameValue,
      String customerContactValue,
      String addressValue,
      List<Map<String, dynamic>> tabledata,
      double totalAmount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tableDataJson = jsonEncode(tabledata);
    totalAmount = calculateTotalAmount();
    String jsonData = jsonEncode({
      'tableno': tableno,
      'scode': scodeValue,
      'sname': snameValue,
      'customerName': customerNameValue,
      'customerContact': customerContactValue,
      'address': addressValue,
      'tableData': tableDataJson,
      'startTime': _startTime?.toIso8601String() ?? '',
      'stopTime': _isRunning ? null : DateTime.now().toIso8601String(),
      'elapsedSeconds': _elapsedSeconds,
      'totalAmount': totalAmount,
    });
    // print('jsonData : $jsonData');
    // Construct unique key based on table number
    String key = 'table_$tableno';

    // Save the serialized data as a string with the unique key
    prefs.setString(key, jsonData);
  }

  void deleteTableData(String tableno) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Construct unique key based on table number
    String key = 'table_$tableno';

    // Remove data associated with the key
    prefs.remove(key);
  }

  late SharedPreferences prefs;
  String selectedCode = '';
  bool showTableNo = false;
  bool isSavedInSharedPreferences = false;

  void _loadSavedData() async {
    prefs = await SharedPreferences.getInstance();

    // Construct the key based on the selected table number
    String key = 'table_$selectedCode';

    // Retrieve the data associated with the selected table number
    String? jsonData = prefs.getString(key);

    // If data exists for the selected table number
    if (jsonData != null) {
      // Decode the JSON data
      Map<String, dynamic> data = jsonDecode(jsonData);

      // Populate the text fields with the retrieved data
      setState(() {
        SCodeController.text = data['scode'] ?? '';
        SNameController.text = data['sname'] ?? '';
        TableCusNameController.text = data['customerName'] ?? '';
        TableContactController.text = data['customerContact'] ?? '';
        TableAddressController.text = data['address'] ?? '';
        isSavedInSharedPreferences = true;
        finalsalestableData =
            List<Map<String, dynamic>>.from(jsonDecode(data['tableData']));
        _startTime = data['startTime'] != null
            ? DateTime.parse(data['startTime'])
            : null;
        _elapsedSeconds = data['elapsedSeconds'] ?? 0;

        _isRunning = data['stopTime'] ==
            null; // If stopTime is null, the timer is still running

        // If timer is running, start the timer
        if (_isRunning) {
          _startTimer();
        }
      });
    }
  }

  void _launchUrl(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime currentDatetime = DateTime.now();

    // Format date and time
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String formattedTime = DateFormat('hh:mm:ss a').format(currentDatetime);

    // Get table number and server name from controllers
    String tableno = TableNoController.text;
    String serventName = SNameController.text;

    // Construct product details
    List<String> productDetails = [];
    for (var data in salestableData) {
      productDetails.add("${data['productName']},${data['quantity']}");
    }

    // Join product details into a single string
    String productDetailsString = productDetails.join(';');

    // Construct the dynamic URL
    String dynamicUrl =
        'http://192.168.10.140:82/print/DINE-IN%20ORDER/$tableno/$formattedDate/$formattedTime/$serventName/$productDetailsString';
    // http://192.168.10.140:82//print/DINE-IN%20ORDER/5/2024-08-21/12:30:00%20AM/John/product1,2;product2,3;product3,1/

    print('url : $dynamicUrl');

    // Launch the dynamic URL
    if (await canLaunch(dynamicUrl)) {
      await launch(
        dynamicUrl,
        enableJavaScript: true,
      ); // Enable JavaScript if necessary,forceSafariVC: false, forceWebView: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $dynamicUrl')),
      );
    }
  }

// Function to show the confirmation dialog
  Future<bool> _showDialogBox(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Print Confirmation'),
          content: Text('Do you want to print the receipt?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if "No" is pressed
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _launchUrl(context); // Launch the URL if "Yes" is pressed
                Navigator.of(context)
                    .pop(true); // Return false if "No" is pressed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.1;
    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.07;
    double screenHeight = MediaQuery.of(context).size.height;
    TableNoController.text = selectedCode;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 6),
                  // Render buttons conditionally based on showTableNo
                  if (!showTableNo)
                    for (var data in _tableData)
                      buildTableButton(
                        data['name'],
                        List.generate(int.parse(data['count']),
                            (index) => '${data['code']}${index + 1}'),
                        data['code'], // Pass the code for comparison
                      ),
                  // Show only the selected button's details when showTableNo is true
                  if (showTableNo)
                    SingleChildScrollView(
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: !Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.65
                            : MediaQuery.of(context).size.width * 0.6,
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(height: 15),
                              if (selectedCode.isNotEmpty)
                                Text("Table No : $selectedCode  ",
                                    style: HeadingStyle),
                              SizedBox(height: 12),
                              if (Responsive.isDesktop(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    tablesalesserventdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                  ],
                                ),
                              if (Responsive.isDesktop(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    tablesalesproductdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                  ],
                                ),
                              if (!Responsive.isDesktop(context))
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    tablesalesserventdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                    tablesalesproductdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                  ],
                                ),
                              if (!Responsive.isDesktop(context))
                                SizedBox(
                                  width: 20,
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    // color:subcolor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 20,
                                              top: Responsive.isDesktop(context)
                                                  ? 23
                                                  : 4),
                                          child: Container(
                                            width: Responsive.isDesktop(context)
                                                ? (updateenable ? 83 : 60)
                                                : 60,
                                            child: ElevatedButton(
                                              focusNode: addbuttonFocusNode,
                                              onPressed: () {
                                                updateenable
                                                    ? UpdateData()
                                                    : saveData();
                                                setState(() {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          codeFocusNode);
                                                });

                                                // print("finalamount :: ${FinallyyyAmounttts.text}");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  backgroundColor: subcolor,
                                                  minimumSize: Size(45.0,
                                                      31.0), // Set width and height
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 15.0)),
                                              child: Text(
                                                  updateenable
                                                      ? 'Update'
                                                      : 'Add',
                                                  style: commonWhiteStyle
                                                      .copyWith(fontSize: 14)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //addbutton
                                  // Container(
                                  //   // color:subcolor,
                                  //   child: Column(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Padding(
                                  //         padding: EdgeInsets.only(
                                  //             left:
                                  //                 Responsive.isDesktop(context)
                                  //                     ? 20
                                  //                     : 0,
                                  //             top: Responsive.isDesktop(context)
                                  //                 ? 17
                                  //                 : 14),
                                  //         child: Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               right: 13),
                                  //           child: StatefulBuilder(builder:
                                  //               (BuildContext context,
                                  //                   StateSetter setState) {
                                  //             return ElevatedButton(
                                  //               focusNode: addbuttonFocusNode,
                                  //               onPressed: () {
                                  //                 updateTotal();
                                  //                 updatetaxableamount();
                                  //                 updateCGSTAmount();
                                  //                 updateSGSTAmount();
                                  //                 updateFinalAmount();
                                  //                 addButtonPressed();

                                  //                 FocusScope.of(context)
                                  //                     .requestFocus(
                                  //                         codeFocusNode);
                                  //               },
                                  //               style: ElevatedButton.styleFrom(
                                  //                 shape: RoundedRectangleBorder(
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                           2.0),
                                  //                 ),
                                  //                 backgroundColor: subcolor,
                                  //                 minimumSize: Size(45.0,
                                  //                     31.0), // Set width and height
                                  //               ),
                                  //               child: Text('Add',
                                  //                   style: commonWhiteStyle),
                                  //             );
                                  //           }),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // SizedBox(width: 5),
                                  Container(
                                    // color:subcolor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 0,
                                              top: Responsive.isDesktop(context)
                                                  ? 17
                                                  : 14),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 13),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                cleardata();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Clear',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width
                                        : MediaQuery.of(context).size.width *
                                            0.8,
                                    // color: const Color.fromARGB(255, 255, 233, 231),
                                    child: Responsive.isDesktop(context)
                                        ? Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.6
                                                            : 480,
                                                        height: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.4
                                                            : 320,
                                                        // color: Colors.pink,
                                                        child:
                                                            tablesalesview()),
                                                    VerticalDivider(
                                                      color: Color.fromARGB(
                                                          255, 122, 122, 122),
                                                      thickness: 0.8,
                                                    ),
                                                    Container(
                                                        width: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.6
                                                            : 480,
                                                        height: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.4
                                                            : 320,
                                                        // color: Colors.yellow,
                                                        child:
                                                            tablesalesviewtableNo())
                                                  ]),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width:
                                                          Responsive.isDesktop(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.6
                                                              : 480,
                                                      height: 40,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                _startTimer(); // Start the timer first

                                                                // Wait for the dialog to close and capture the result
                                                                bool
                                                                    dialogResult =
                                                                    await _showDialogBox(
                                                                        context);

                                                                // If the user pressed "Yes", proceed with other actions
                                                                if (dialogResult ==
                                                                    true) {
                                                                  _printResult(); // Execute print result
                                                                  lastsaveData(); // Execute save data

                                                                  String
                                                                      tableno =
                                                                      TableNoController
                                                                          .text;
                                                                  String
                                                                      scodeValue =
                                                                      SCodeController
                                                                          .text;
                                                                  String
                                                                      snameValue =
                                                                      SNameController
                                                                          .text;
                                                                  String
                                                                      customerNameValue =
                                                                      TableCusNameController
                                                                          .text;
                                                                  String
                                                                      customerContactValue =
                                                                      TableContactController
                                                                          .text;
                                                                  String
                                                                      addressValue =
                                                                      TableAddressController
                                                                          .text;

                                                                  List<Map<String, dynamic>>
                                                                      tabledata =
                                                                      finalsalestableData;

                                                                  if (scodeValue
                                                                      .isNotEmpty) {
                                                                    _saveText(
                                                                      tableno,
                                                                      scodeValue,
                                                                      snameValue,
                                                                      customerNameValue,
                                                                      customerContactValue,
                                                                      addressValue,
                                                                      tabledata,
                                                                      totalAmount,
                                                                    );
                                                                  }
                                                                } else {
                                                                  // Handle the case where the user pressed "No" if needed
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                ),
                                                                backgroundColor:
                                                                    subcolor,
                                                                minimumSize: Size(
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Savebtn',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                          //       ElevatedButton(
                                                          //     onPressed: () {
                                                          //       _startTimer; // Start the timer if it's not already running
                                                          //       _showDialogBox(
                                                          //           context);
                                                          //       _printResult();
                                                          //       lastsaveData();
                                                          //       String tableno =
                                                          //           TableNoController
                                                          //               .text;
                                                          //       String
                                                          //           scodeValue =
                                                          //           SCodeController
                                                          //               .text;
                                                          //       String
                                                          //           snameValue =
                                                          //           SNameController
                                                          //               .text;
                                                          //       String
                                                          //           customerNameValue =
                                                          //           TableCusNameController
                                                          //               .text;
                                                          //       String
                                                          //           customerContactValue =
                                                          //           TableContactController
                                                          //               .text;
                                                          //       String
                                                          //           addressValue =
                                                          //           TableAddressController
                                                          //               .text;

                                                          //       List<
                                                          //               Map<String,
                                                          //                   dynamic>>
                                                          //           tabledata =
                                                          //           finalsalestableData;

                                                          //       if (scodeValue
                                                          //           .isNotEmpty) {
                                                          //         _saveText(
                                                          //             tableno,
                                                          //             scodeValue,
                                                          //             snameValue,
                                                          //             customerNameValue,
                                                          //             customerContactValue,
                                                          //             addressValue,
                                                          //             tabledata,
                                                          //             totalAmount);
                                                          //       }
                                                          //       // Navigator.pop(
                                                          //       //     context);
                                                          //     },
                                                          //     style:
                                                          //         ElevatedButton
                                                          //             .styleFrom(
                                                          //       shape:
                                                          //           RoundedRectangleBorder(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //                     2.0),
                                                          //       ),
                                                          //       backgroundColor:
                                                          //           subcolor,
                                                          //       minimumSize: Size(
                                                          //           45.0,
                                                          //           31.0), // Set width and height
                                                          //     ),
                                                          //     child: Text(
                                                          //         'Savebtn',
                                                          //         style:
                                                          //             commonWhiteStyle),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          Responsive.isDesktop(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.6
                                                              : 480,
                                                      height: 40,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                String tableno =
                                                                    TableNoController
                                                                        .text;
                                                                if (tableno
                                                                    .isEmpty) {
                                                                  print(
                                                                      "Table number is not provided.");
                                                                  return; // Exit early if no table number is provided
                                                                }

                                                                String key =
                                                                    'table_$tableno'; // Initialize `key` early

                                                                // Stop the timer if it's running for the current table
                                                                _stopTimer; // Ensure _stop is called as a function

                                                                // Clear the saved data for the start time and elapsed seconds from SharedPreferences
                                                                // await _clearPreferences(); // Call the method to remove specific keys

                                                                // Clear the saved data for the table from SharedPreferences
                                                                SharedPreferences
                                                                    prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                bool removed =
                                                                    await prefs
                                                                        .remove(
                                                                            key);
                                                                if (removed) {
                                                                  print(
                                                                      "Timer data for $key removed from SharedPreferences");
                                                                } else {
                                                                  print(
                                                                      "Failed to remove data for $key from SharedPreferences");
                                                                }

                                                                // Navigate to the next screen
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            NewSalesEntry(
                                                                      Fianlamount:
                                                                          TextEditingController(),
                                                                      salestableData:
                                                                          finalsalestableData,
                                                                      cusnameController:
                                                                          TableCusNameController,
                                                                      TableNoController:
                                                                          TableNoController, // Corrected to use TableNoController
                                                                      cusaddressController:
                                                                          TableAddressController,
                                                                      cuscontactController:
                                                                          TableContactController,
                                                                      scodeController:
                                                                          SCodeController,
                                                                      snameController:
                                                                          SNameController,
                                                                      TypeController:
                                                                          salestypecontroller,
                                                                      isSaleOn:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                ),
                                                                backgroundColor:
                                                                    subcolor,
                                                                minimumSize: Size(
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Switch',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                // Handle form submission
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                ),
                                                                backgroundColor:
                                                                    subcolor,
                                                                minimumSize: Size(
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Print',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                Closetabledetails();
                                                                if (showTableNo) {
                                                                  setState(() {
                                                                    showTableNo =
                                                                        false; // Close the details view
                                                                  });
                                                                }
                                                                // print(
                                                                //     "c;ose button is pressed");
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                ),
                                                                backgroundColor:
                                                                    subcolor,
                                                                minimumSize: Size(
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Close',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                            ],
                                          )
                                        //mob design
                                        : Column(
                                            children: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 480,
                                                        // color: Colors.pink,
                                                        child: Column(
                                                          children: [
                                                            tablesalesview(),
                                                            Container(
                                                              width: 480,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            13,
                                                                        bottom:
                                                                            15,
                                                                        top:
                                                                            15),
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        _startTimer; // Start the timer if it's not already running

                                                                        _printResult();
                                                                        lastsaveData();
                                                                        String
                                                                            tableno =
                                                                            TableNoController.text;
                                                                        String
                                                                            scodeValue =
                                                                            SCodeController.text;
                                                                        String
                                                                            snameValue =
                                                                            SNameController.text;
                                                                        String
                                                                            customerNameValue =
                                                                            TableCusNameController.text;
                                                                        String
                                                                            customerContactValue =
                                                                            TableContactController.text;
                                                                        String
                                                                            addressValue =
                                                                            TableAddressController.text;

                                                                        List<Map<String, dynamic>>
                                                                            tabledata =
                                                                            finalsalestableData;

                                                                        if (scodeValue
                                                                            .isNotEmpty) {
                                                                          _saveText(
                                                                              tableno,
                                                                              scodeValue,
                                                                              snameValue,
                                                                              customerNameValue,
                                                                              customerContactValue,
                                                                              addressValue,
                                                                              tabledata,
                                                                              totalAmount);
                                                                        }
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2.0),
                                                                        ),
                                                                        backgroundColor:
                                                                            subcolor,
                                                                        minimumSize: Size(
                                                                            45.0,
                                                                            31.0), // Set width and height
                                                                      ),
                                                                      child: Text(
                                                                          'Save',
                                                                          style:
                                                                              commonWhiteStyle),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    Container(
                                                        width: 480,
                                                        // color: Colors.yellow,
                                                        child: Column(
                                                          children: [
                                                            tablesalesviewtableNo(),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(
                                                              width: 480,
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                7,
                                                                            bottom:
                                                                                15,
                                                                            top:
                                                                                5),
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            String
                                                                                tableno =
                                                                                TableNoController.text;
                                                                            if (tableno.isEmpty) {
                                                                              print("Table number is not provided.");
                                                                              return; // Exit early if no table number is provided
                                                                            }

                                                                            String
                                                                                key =
                                                                                'table_$tableno'; // Initialize `key` early

                                                                            // Stop the timer if it's running for the current table
                                                                            _stopTimer; // Stop the timer and save the stop time

                                                                            // Clear the saved data for the table from SharedPreferences
                                                                            SharedPreferences
                                                                                prefs =
                                                                                await SharedPreferences.getInstance();
                                                                            bool
                                                                                removed =
                                                                                await prefs.remove(key);
                                                                            if (removed) {
                                                                              print("Timer data for $key removed from SharedPreferences");
                                                                            } else {
                                                                              print("Failed to remove data for $key from SharedPreferences");
                                                                            }

                                                                            // Navigate to the next screen
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => NewSalesEntry(
                                                                                  Fianlamount: TextEditingController(),
                                                                                  salestableData: finalsalestableData,
                                                                                  cusnameController: TableCusNameController,
                                                                                  TableNoController: TableContactController,
                                                                                  cusaddressController: TableAddressController,
                                                                                  cuscontactController: TableContactController,
                                                                                  scodeController: SCodeController,
                                                                                  snameController: SNameController,
                                                                                  TypeController: salestypecontroller,
                                                                                  isSaleOn: false,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                            ),
                                                                            backgroundColor:
                                                                                subcolor,
                                                                            minimumSize:
                                                                                Size(45.0, 31.0), // Set width and height
                                                                          ),
                                                                          child: Text(
                                                                              'Move',
                                                                              style: commonWhiteStyle),
                                                                        ),
                                                                        //      ElevatedButton(
                                                                        //       onPressed:
                                                                        //           () async {
                                                                        //         // Stop the timer if it's running

                                                                        //         // Clear the saved data for the table from SharedPreferences
                                                                        //         String tableno = TableNoController.text;
                                                                        //         String key = 'table_$tableno';
                                                                        //         if (tableno.isEmpty) {
                                                                        //           print("Table number is not provided.");
                                                                        //           return; // Exit early if no table number is provided
                                                                        //         }

                                                                        //         if (_isRunning) {
                                                                        //           await _stopTimer(key); // Stop the timer and save the stop time
                                                                        //         }

                                                                        //         SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                        //         await prefs.remove(key);

                                                                        //         print("Timer data for $key removed after moving");

                                                                        //         // Navigate to the next screen
                                                                        //         Navigator.push(
                                                                        //           context,
                                                                        //           MaterialPageRoute(
                                                                        //             builder: (context) => NewSalesEntry(
                                                                        //               Fianlamount: TextEditingController(),
                                                                        //               salestableData: finalsalestableData,
                                                                        //               cusnameController: TableCusNameController,
                                                                        //               TableNoController: TableContactController,
                                                                        //               cusaddressController: TableAddressController,
                                                                        //               cuscontactController: TableContactController,
                                                                        //               scodeController: SCodeController,
                                                                        //               snameController: SNameController,
                                                                        //               TypeController: salestypecontroller,
                                                                        //               isSaleOn: false,
                                                                        //             ),
                                                                        //           ),
                                                                        //         );
                                                                        //       },
                                                                        //       style:
                                                                        //           ElevatedButton.styleFrom(
                                                                        //         shape: RoundedRectangleBorder(
                                                                        //           borderRadius: BorderRadius.circular(2.0),
                                                                        //         ),
                                                                        //         backgroundColor: subcolor,
                                                                        //         minimumSize: Size(45.0, 31.0), // Set width and height
                                                                        //       ),
                                                                        //       child:
                                                                        //           Text('Move', style: commonWhiteStyle),
                                                                        //     )),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                7,
                                                                            bottom:
                                                                                15,
                                                                            top:
                                                                                5),
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            // Handle form submission
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                            ),
                                                                            backgroundColor:
                                                                                subcolor,
                                                                            minimumSize:
                                                                                Size(45.0, 31.0), // Set width and height
                                                                          ),
                                                                          child: Text(
                                                                              'Print',
                                                                              style: commonWhiteStyle),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                7,
                                                                            bottom:
                                                                                15,
                                                                            top:
                                                                                5),
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Closetabledetails();
                                                                            if (showTableNo) {
                                                                              setState(() {
                                                                                showTableNo = false; // Close the details view
                                                                              });
                                                                            }
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                            ),
                                                                            backgroundColor:
                                                                                subcolor,
                                                                            minimumSize:
                                                                                Size(45.0, 31.0), // Set width and height
                                                                          ),
                                                                          child: Text(
                                                                              'Close',
                                                                              style: commonWhiteStyle),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ))
                                                  ]),
                                            ],
                                          )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Wrap tablesalesproductdetails(BuildContext context,
      double desktopcontainerdwidth, double desktoptextfeildwidth) {
    return Wrap(alignment: WrapAlignment.start, children: [
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Code", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        onChanged: (newvalue) {
                          fetchproductName();
                        },
                        controller: TableCodeController,
                        focusNode: codeFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, codeFocusNode, itemFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle)),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Item", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 3 : 0, top: 8),
              child: Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.11
                      : MediaQuery.of(context).size.width * 0.3,
                  child: _buildProductnameDropdown()),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Amount", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined, // Your icon here
                      size: 17,
                    ),
                    SizedBox(width: 3), // Adjust spacing between icon and text

                    Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.08
                            : MediaQuery.of(context).size.width * 0.255,
                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: TextField(
                            readOnly: true,
                            controller: TableAmountController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Quantity", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Row(
                  children: [
                    Icon(
                      Icons.add_alert_rounded, // Your icon here
                      size: 17,
                    ),
                    SizedBox(width: 1), // Adjust spacing between icon and text

                    Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.08
                            : MediaQuery.of(context).size.width * 0.255,
                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: TextFormField(
                            controller: TableQuantityController,
                            focusNode: quantityFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              String productName = TableItemController.text;
                              int quantity = int.tryParse(value) ?? 0;

                              // Check if the product's stock is available
                              salesProductList().then(
                                  (List<Map<String, dynamic>> productList) {
                                // Find the product in the list
                                Map<String, dynamic>? product =
                                    productList.firstWhere(
                                  (element) => element['name'] == productName,
                                  orElse: () => {
                                    'stock': 'no'
                                  }, // Default values if product not found
                                );

                                String stockStatus = product['stock'];
                                // print(
                                //     "stock values for the $productName is $stockStatus");

                                if (stockStatus == 'No') {
                                  // Product's stock is not available, proceed with relevant action
                                  // For example, move focus to the next field
                                  // FocusScope.of(context)
                                  //     .requestFocus(
                                  //         finaltotFocusNode);
                                } else if (stockStatus == 'Yes') {
                                  // Product's stock is available, proceed with quantity validation
                                  double stockValue = double.tryParse(
                                          product['stockvalue'].toString()) ??
                                      0;

                                  if (quantity > stockValue) {
                                    // Quantity exceeds stock value, show error message and clear quantity controller
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // Prevent closing when tapping outside or pressing back button

                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Stock Check'),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                // Close the dialog without any action
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                        content: Container(
                                          width: 500,
                                          child: Text(
                                              'The entered quantity exceeds the available stock value (${stockValue}). '
                                              'Do you want to proceed by deducting this excess quantity from the stock?'),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();

                                                  // FocusScope.of(
                                                  //         context)
                                                  //     .requestFocus(
                                                  //         itemFocusNode);
                                                },
                                                child: Text('Yes Add'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  TableQuantityController.text =
                                                      stockValue
                                                          .toString(); // Set quantity to stock value

                                                  Navigator.of(context).pop();
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          finaltotFocusNode);
                                                },
                                                child: Text('Skip'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // Quantity is valid, move focus to the next field
                                    _fieldFocusChange(context,
                                        quantityFocusNode, finaltotFocusNode);
                                  }
                                }
                              });
                            },

                            // onFieldSubmitted: (_) {
                            //   // Move focus to the save button
                            //   FocusScope.of(context)
                            //       .requestFocus(
                            //           addbuttonFocusNode);
                            // },
                            onChanged: (value) {
                              updateTotal();
                              updatetaxableamount();
                              updateCGSTAmount();
                              updateSGSTAmount();
                              updateFinalAmount();
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0, top: 8),
              child: Text("Total", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktoptextfeildwidth
                      : MediaQuery.of(context).size.width * 0.2,
                  color: Colors.grey[200],
                  child: TextFormField(
                      readOnly: true,
                      controller: FinalAmtController,
                      focusNode: finaltotFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        // Move focus to the save button
                        FocusScope.of(context).requestFocus(addbuttonFocusNode);
                      },
                      onChanged: (newValue) {},
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 7.0,
                        ),
                      ),
                      style: AmountTextStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Wrap tablesalesserventdetails(BuildContext context,
      double desktopcontainerdwidth, double desktoptextfeildwidth) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        SizedBox(width: 10),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("S.Code: ", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.28,
                  // color: Colors.red,
                  child: Row(
                    children: [
                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? desktoptextfeildwidth
                            : MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey[100],
                        child: TextFormField(
                            focusNode: scodeFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _fieldFocusChange(
                                context, scodeFocusNode, snameFocusNode),
                            onChanged: (newvalue) {
                              fetchSName();
                            },
                            controller: SCodeController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Container(
                                    width: 1350,
                                    height: 800,
                                    padding: EdgeInsets.all(16),
                                    child: Stack(
                                      children: [
                                        StaffDetailsPage(),
                                        Positioned(
                                          right: 0.0,
                                          top: 0.0,
                                          child: IconButton(
                                            icon: Icon(Icons.cancel,
                                                color: Colors.red, size: 23),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              fetchproductName();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(color: subcolor),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 6, right: 6, top: 2, bottom: 2),
                              child: Text(
                                "+",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
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
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("S Name", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        onChanged: (newvalue) {
                          fetchcode();
                        },
                        controller: SNameController,
                        focusNode: snameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, snameFocusNode, CusnameFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("Customer Name", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[200],
                    child: TextFormField(
                        controller: TableCusNameController,
                        focusNode: CusnameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, CusnameFocusNode, CusContactFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("Contact", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        controller: TableContactController,
                        focusNode: CusContactFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                              10), // Optional: Limit input length to 10
                        ],
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, CusContactFocusNode, CusAddressFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("Address", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        controller: TableAddressController,
                        focusNode: CusAddressFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, CusAddressFocusNode, codeFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, DateTime> _tableStartTimes = {};

//   ///this code made stop time but not running always then double time running
// //orginial ocode
//   void _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? startTimeString = prefs.getString('start_time');
//     int? elapsedSeconds = prefs.getInt('elapsed_seconds');

//     if (startTimeString != null && elapsedSeconds != null) {
//       _startTime = DateTime.parse(startTimeString);
//       _elapsedSeconds = elapsedSeconds;
//       _isRunning = true;
//       _startTimer();
//     }
//   }

//   void _startTimer() {
//     if (_isRunning) {
//       _timer?.cancel(); // Cancel any existing timer before starting a new one
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         setState(() {
//           _elapsedSeconds++;
//           _savePreferences();
//         });
//       });
//     }
//   }

//   Future<void> _stopTimer() async {
//     if (_isRunning) {
//       _timer?.cancel();
//       setState(() {
//         _isRunning = false;
//       });

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String key = 'table_$selectedCode';
//       String? jsonData = prefs.getString(key);

//       if (jsonData != null) {
//         Map<String, dynamic> data = jsonDecode(jsonData);
//         data['stopTime'] = DateTime.now().toIso8601String();
//         data['elapsedSeconds'] = _elapsedSeconds;

//         print("Final timer details before removal: ${jsonEncode(data)}");

//         await prefs.remove(key); // Remove data from SharedPreferences
//         print("Removed timer data for $key from SharedPreferences");
//       } else {
//         print("No timer data found for $key to remove");
//       }
//     }
//   }

//   void _start() async {
//     _startTime = DateTime.now();
//     _isRunning = true;
//     _elapsedSeconds = 0;
//     String tableno = TableNoController.text;
//     String scodeValue = SCodeController.text;
//     String snameValue = SNameController.text;
//     String customerNameValue = TableCusNameController.text;
//     String customerContactValue = TableContactController.text;
//     String addressValue = TableAddressController.text;

//     List<Map<String, dynamic>> tabledata = finalsalestableData;

//     if (scodeValue.isNotEmpty) {
//       _saveText(tableno, scodeValue, snameValue, customerNameValue,
//           customerContactValue, addressValue, tabledata, totalAmount);
//     }
//     _startTimer();
//   }

//   void _stop() async {
//     if (_isRunning) {
//       _timer?.cancel();
//       _isRunning = false;
//       _startTime = null;
//       await _stopTimer(); // Stop the timer and remove data
//       setState(() {});
//     }
//   }

//   Future<void> _savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
//     await prefs.setInt('elapsed_seconds', _elapsedSeconds);
//   }

//   Future<void> _clearPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('start_time');
//     await prefs.remove('elapsed_seconds');
//   }

//   String _formatDuration(int seconds) {
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

// //trial
//   void _startTimer() {
//     if (!_isRunning) {
//       _startTime = DateTime.now();
//       _elapsedSeconds = 0; // Reset elapsed seconds to 0
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         setState(() {
//           _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
//           _savePreferences();
//           print('Timer tick: ${DateTime.now()}');
//           _updateElapsedTimes();
//         });
//       });
//       _isRunning = true;
//       _savePreferences(); // Save the state when the timer starts
//     }
//   }

//   Future<void> _stopTimer() async {
//     if (_isRunning) {
//       _timer?.cancel();
//       setState(() {
//         _isRunning = false;
//       });
//       await _savePreferences(); // Save the final state
//     }
//   }

//   Future<void> _savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
//     await prefs.setInt('elapsed_seconds', _elapsedSeconds);
//     await prefs.setBool('is_running', _isRunning);
//   }

//   Future<void> _clearPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('start_time');
//     await prefs.remove('elapsed_seconds');
//     await prefs.remove('is_running');
//   }

//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? startTimeString = prefs.getString('start_time');
//     int? elapsedSeconds = prefs.getInt('elapsed_seconds');
//     bool? isRunning = prefs.getBool('is_running');

//     if (startTimeString != null && isRunning != null) {
//       _startTime = DateTime.parse(startTimeString);
//       _elapsedSeconds = elapsedSeconds ?? 0;
//       _isRunning = isRunning;

//       if (_isRunning) {
//         // Calculate the elapsed time based on the start time and current time
//         _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//           setState(() {
//             _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
//             _savePreferences();
//           });
//         });
//       }
//     } else {
//       // Initialize with default values if no data found
//       _startTime = null;
//       _elapsedSeconds = 0;
//       _isRunning = false;
//     }
//   }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Map<String, bool> _hoveredTableCodes = {}; // Map to track hover state
  // void _updateElapsedTimes() {
  //   setState(() {
  //     _elapsedTimes.updateAll((key, elapsedTime) {
  //       final newTime = elapsedTime + 1;
  //       print('Updated time for $key: $newTime seconds');
  //       return newTime;
  //     });
  //   });
  // }

  Map<String, DateTime> _startTimes = {}; // Store start time for each table
  // Future<void> _reserveTable(String tableCode) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final currentTime = DateTime.now();

  //   setState(() {
  //     _startTimes[tableCode] = currentTime;
  //   });

  //   // Save the start time as a string in SharedPreferences
  //   await prefs.setString(tableCode, currentTime.toIso8601String());
  // }

  // Future<void> _loadStartTimes() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.getKeys().forEach((tableCode) {
  //     String? storedTime = prefs.getString(tableCode);
  //     if (storedTime != null) {
  //       setState(() {
  //         _startTimes[tableCode] = DateTime.parse(storedTime);
  //       });
  //     }
  //   });
  // }

  // String _getElapsedTime(String tableCode) {
  //   if (!_startTimes.containsKey(tableCode)) {
  //     return "00:00:00"; // Return zero time if not reserved
  //   }

  //   final startTime = _startTimes[tableCode]!;
  //   final elapsed = DateTime.now().difference(startTime);

  //   return _formatDuration(elapsed);
  // }

  // Future<void> _reserveTable(String tableCode) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final currentTime = DateTime.now();

  //   setState(() {
  //     _startTimes[tableCode] = currentTime;
  //   });

  //   // Save the start time as a string in SharedPreferences
  //   await prefs.setString(tableCode, currentTime.toIso8601String());
  // }

  // Future<void> _loadStartTimes() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.getKeys().forEach((tableCode) {
  //     String? storedTime = prefs.getString(tableCode);
  //     if (storedTime != null) {
  //       setState(() {
  //         _startTimes[tableCode] = DateTime.parse(storedTime);
  //       });
  //     }
  //   });
  // }

  // String _getElapsedTime(String tableCode) {
  //   if (!_startTimes.containsKey(tableCode)) {
  //     return "00:00:00"; // Return zero time if the table is not reserved
  //   }

  //   final startTime = _startTimes[tableCode]!;
  //   final elapsed = DateTime.now().difference(startTime);

  //   return _formatDuration(elapsed);
  // }

  // String _formatDuration(Duration duration) {
  //   final hours = duration.inHours.toString().padLeft(2, '0');
  //   final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  //   final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  //   return '$hours:$minutes:$seconds';
  // }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    for (var data in finalsalestableData) {
      if (data['Amount'] != null) {
        double Amount = double.tryParse(data['Amount'].toString()) ?? 0.0;
        // print('Amount: $Amount'); // Debug print
        totalAmount += Amount;
      }
    }
    // print('Total Amount: $totalAmount'); // Debug print
    return totalAmount;
  }

  void updateTotalAmount() {
    setState(() {
      double totalAmount = calculateTotalAmount();
      FinalAmtController.text = totalAmount.toStringAsFixed(2);
      print(
          'Updated FinalAmtController: ${FinalAmtController.text}'); // Debug print
    });
  }

  double _getTotalAmountFromPrefs(String tableCode) {
    String jsonData = prefs.getString('table_$tableCode') ?? '';
    if (jsonData.isNotEmpty) {
      var data = jsonDecode(jsonData);
      return data['totalAmount'] ?? 0.0; // Return totalAmount if available
    }
    return 0.0; // Return 0.0 if no data found
  }

//afternoon try
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  final Map<String, DateTime> _reservationStartTimes = {};
  String _formatElapsedTime(String tableCode) {
    if (_reservationStartTimes.containsKey(tableCode)) {
      Duration elapsed =
          DateTime.now().difference(_reservationStartTimes[tableCode]!);
      return _formatDuration(elapsed);
    }
    return '00:00:00';
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  Future<void> _stopTimer() async {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
      await _savePreferences(); // Save the final state
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
    await prefs.setInt('elapsed_seconds', _elapsedSeconds);
    await prefs.setBool('is_running', _isRunning);
  }

  Future<void> _loadPreferences() async {
    print("Loading preferences...");
    final prefs = await SharedPreferences.getInstance();
    String? startTimeString = prefs.getString('start_time');
    int? elapsedSeconds = prefs.getInt('elapsed_seconds');
    bool? isRunning = prefs.getBool('is_running');

    if (startTimeString != null && isRunning != null) {
      print(
          "Preferences loaded: start_time=$startTimeString, elapsed_seconds=$elapsedSeconds, is_running=$isRunning");
      _startTime = DateTime.parse(startTimeString);
      _elapsedSeconds = elapsedSeconds ?? 0;
      _isRunning = isRunning;

      if (_isRunning) {
        // Calculate the elapsed time based on the start time and current time
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
            _savePreferences(); // Save preferences every second
          });
        });
      }
    } else {
      // Initialize with default values if no data found
      print("No preferences found. Initializing with default values.");
      _startTime = null;
      _elapsedSeconds = 0;
      _isRunning = false;
    }
  }

  Widget buildTableButton(String name, List<String> codes, String tableCode) {
    List<Widget> buttonRows = [];
    List<Widget> currentRow = [];
    int buttonsPerRow = Responsive.isDesktop(context)
        ? 5
        : Responsive.isTablet(context)
            ? 5
            : 2;

    for (int i = 0; i < codes.length; i++) {
      String key = 'table_${codes[i]}';
      bool isReserved = prefs.containsKey(key);

      // Get total amount from SharedPreferences if available
      double totalAmount = 0.0;
      if (isReserved) {
        String? jsonData = prefs.getString(key);
        if (jsonData != null) {
          Map<String, dynamic> data = jsonDecode(jsonData);
          totalAmount = _getTotalAmountFromPrefs(codes[i]);

          // Set reservation start time if not already set
          if (!_reservationStartTimes.containsKey(codes[i])) {
            _reservationStartTimes[codes[i]] = DateTime.now()
                .subtract(Duration(seconds: data['elapsedSeconds'] ?? 0));
          }
        }
      }
      bool isHovered = _hoveredTableCodes[codes[i]] ?? false;
      String elapsedTime = isReserved ? _formatElapsedTime(codes[i]) : '';

      currentRow.add(MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredTableCodes[codes[i]] = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hoveredTableCodes[codes[i]] = false;
          });
        },
        child: Transform.scale(
          scale: isHovered ? 1.1 : 1.0,
          child: Padding(
            padding: EdgeInsets.only(
                top: Responsive.isDesktop(context) ? 10 : 10,
                left: Responsive.isDesktop(context) ? 10 : 3,
                right: Responsive.isDesktop(context) ? 10 : 3,
                bottom: Responsive.isDesktop(context) ? 10 : 2),
            child: Container(
              decoration: BoxDecoration(
                color: isReserved
                    ? Color.fromARGB(255, 62, 67, 85)
                    : Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: isReserved
                          ? MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 62, 67, 85))
                          : MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 255, 255, 255)),
                      elevation: MaterialStateProperty.all<double>(4),
                    ),
                    onPressed: () {
                      _loadSavedData();
                      setState(() {
                        selectedCode = codes[i];
                        showTableNo = true;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(
                          Responsive.isDesktop(context) ? 10 : 2),
                      child: isReserved
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/imgs/reservetable.png',
                                        height: 25,
                                        width: 25,
                                        color: Colors.white),
                                    SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text('Reserved',
                                          style: commonWhiteStyle),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Center(
                                  child: Text(
                                    codes[i],
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Center(
                                    child: Text(
                                      "Time: $elapsedTime",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'TotAmt: ',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text:
                                            '\$${totalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/imgs/table.png',
                                    height: 35,
                                    width: 35,
                                    color: Color.fromARGB(255, 62, 67, 85)),
                                SizedBox(height: 5),
                                Text(
                                  'Available Seat',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color.fromARGB(255, 62, 67, 85)),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  codes[i],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 62, 67, 85)),
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));

      if ((i + 1) % buttonsPerRow == 0 || i == codes.length - 1) {
        buttonRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentRow,
          ),
        );
        currentRow = [];
      }
    }

    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (!showTableNo) ...buttonRows,
        SizedBox(height: 16),
      ],
    );
  }

// //original
//   Widget buildTableButton(String name, List<String> codes, String tableCode) {
//     List<Widget> buttonRows = [];
//     List<Widget> currentRow = [];
//     int buttonsPerRow = Responsive.isDesktop(context)
//         ? 5
//         : Responsive.isTablet(context)
//             ? 5
//             : 2;

//     for (int i = 0; i < codes.length; i++) {
//       String key = 'table_${codes[i]}';
//       bool isReserved = prefs.containsKey(key);

//       // Get elapsed time from SharedPreferences if available
//       String elapsedTime = '';
//       double totalAmount = 0.0;
//       if (isReserved) {
//         elapsedTime = _getElapsedTime(codes[i]);
//         totalAmount = _getTotalAmountFromPrefs(codes[i]); // Get total amount
//         // print('Elapsed time for ${codes[i]}: $elapsedTime');
//       }
//       bool isHovered = _hoveredTableCodes[codes[i]] ?? false;

//       currentRow.add(MouseRegion(
//         onEnter: (_) {
//           setState(() {
//             _hoveredTableCodes[codes[i]] = true;
//           });
//         },
//         onExit: (_) {
//           setState(() {
//             _hoveredTableCodes[codes[i]] = false;
//           });
//         },
//         child: Transform.scale(
//           scale: isHovered ? 1.1 : 1.0,
//           child: Padding(
//             padding: EdgeInsets.only(
//                 top: Responsive.isDesktop(context) ? 10 : 10,
//                 left: Responsive.isDesktop(context) ? 10 : 3,
//                 right: Responsive.isDesktop(context) ? 10 : 3,
//                 bottom: Responsive.isDesktop(context) ? 10 : 2),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: isReserved
//                     ? Color.fromARGB(255, 62, 67, 85)
//                     : Color.fromARGB(255, 255, 255, 255),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3), // changes position of shadow
//                   ),
//                 ],
//                 borderRadius:
//                     BorderRadius.circular(8), // Optional: adds rounded corners
//               ),
//               child: Column(
//                 children: [
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: isReserved
//                           ? MaterialStateProperty.all<Color>(
//                               Color.fromARGB(255, 62, 67, 85))
//                           : MaterialStateProperty.all<Color>(
//                               Color.fromARGB(255, 255, 255, 255)),
//                       elevation: MaterialStateProperty.all<double>(4),
//                     ),
//                     onPressed: () {
//                       _loadSavedData();
//                       setState(() {
//                         selectedCode = codes[i];
//                         showTableNo = true;
//                       });
//                     },
//                     child: Padding(
//                       padding: EdgeInsets.all(
//                           Responsive.isDesktop(context) ? 10 : 2),
//                       child: isReserved
//                           ? Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Image.asset('assets/imgs/reservetable.png',
//                                         height: 25,
//                                         width: 25,
//                                         color: Colors.white),
//                                     SizedBox(width: 4),
//                                     Padding(
//                                       padding: const EdgeInsets.all(5.0),
//                                       child: Text('Reserved',
//                                           style: commonWhiteStyle),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 3),
//                                 Center(
//                                   child: Text(
//                                     codes[i],
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.white),
//                                   ),
//                                 ),
//                                 if (elapsedTime.isNotEmpty)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 4.0),
//                                     child: Center(
//                                         child: RichText(
//                                       text: TextSpan(
//                                         children: [
//                                           TextSpan(
//                                             text: 'Time: ', // Label for time
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors
//                                                     .white, // Style for the label
//                                                 fontWeight: FontWeight.bold
//                                                 // Bold for emphasis
//                                                 ),
//                                           ),
//                                           TextSpan(
//                                             text:
//                                                 elapsedTime, // Actual elapsed time
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors
//                                                     .white, // Different color for the elapsed time
//                                                 fontWeight: FontWeight
//                                                     .bold // Italics for distinction
//                                                 ),
//                                           ),
//                                         ],
//                                       ),
//                                     )),
//                                   ),
//                                 SizedBox(height: 5),
//                                 RichText(
//                                   text: TextSpan(
//                                     children: [
//                                       TextSpan(
//                                         text: 'TotAmt: ', // Label for time
//                                         style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors
//                                                 .white, // Style for the label
//                                             fontWeight: FontWeight.bold
//                                             // Bold for emphasis
//                                             ),
//                                       ),
//                                       TextSpan(
//                                         text:
//                                             '\$${totalAmount.toStringAsFixed(2)}',
//                                         style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors
//                                                 .white, // Different color for the elapsed time
//                                             fontWeight: FontWeight
//                                                 .bold // Italics for distinction
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             )
//                           : Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset('assets/imgs/table.png',
//                                     height: 35,
//                                     width: 35,
//                                     color: Color.fromARGB(255, 62, 67, 85)),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   'Available Seat',
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: Color.fromARGB(255, 62, 67, 85)),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   codes[i],
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color.fromARGB(255, 62, 67, 85)),
//                                 ),
//                                 SizedBox(height: 4),
//                               ],
//                             ),
//                     ),
//                     // child: Padding(
//                     //   padding: EdgeInsets.all(
//                     //       Responsive.isDesktop(context) ? 10 : 2),
//                     //   child: Container(
//                     //     child: Column(
//                     //       children: [
//                     //         Image.asset(
//                     //             isReserved
//                     //                 ? 'assets/imgs/reservetable.png'
//                     //                 : 'assets/imgs/table.png',
//                     //             height: 30,
//                     //             width: 30,
//                     //             color: isReserved
//                     //                 ? Colors.white
//                     //                 : Color.fromARGB(255, 62, 67, 85)),
//                     //         SizedBox(height: 0),
//                     //         Padding(
//                     //           padding: const EdgeInsets.all(4.0),
//                     //           child: Text(
//                     //             isReserved ? 'Reserved' : 'Available Seat',
//                     //             style: TextStyle(
//                     //                 fontSize: 10,
//                     //                 color: isReserved
//                     //                     ? Colors.white
//                     //                     : Color.fromARGB(255, 62, 67, 85)),
//                     //           ),
//                     //         ),
//                     //         Padding(
//                     //           padding: const EdgeInsets.all(4.0),
//                     //           child: Text(
//                     //             codes[i],
//                     //             style: TextStyle(
//                     //                 fontSize: 12,
//                     //                 fontWeight: FontWeight.bold,
//                     //                 color: isReserved
//                     //                     ? Colors.white
//                     //                     : Color.fromARGB(255, 62, 67, 85)),
//                     //           ),
//                     //         ),
//                     //         if (isReserved) // Show elapsed time if the table is reserved
//                     //           Padding(
//                     //             padding: const EdgeInsets.all(4.0),
//                     //             child: Text(
//                     //               'Time: $elapsedTime',
//                     //             ),
//                     //           ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ));

//       if ((i + 1) % buttonsPerRow == 0 || i == codes.length - 1) {
//         buttonRows.add(
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: currentRow,
//           ),
//         );
//         currentRow = [];
//       }
//     }

//     return Column(
//       children: [
//         Text(
//           name,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 16),
//         if (!showTableNo) ...buttonRows,
//         SizedBox(height: 16),
//       ],
//     );
//   }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> salestableData = [];

  List<Map<String, dynamic>> finalsalestableData = [];
  bool updateenable = false;
  void saveData() {
    // Check if any required field is empty
    if (SCodeController.text.isEmpty ||
        SNameController.text.isEmpty ||
        TableItemController.text.isEmpty ||
        TableAmountController.text.isEmpty ||
        TableQuantityController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (widget.SalesPaytype.text.toLowerCase() == 'credit' &&
        TableCusNameController.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details , when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (TableQuantityController.text == '0' ||
        TableQuantityController.text == '') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity Check'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text('Kindly enter the quantity , Quantity must above 0'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productName = TableItemController.text;
      String amount = TableAmountController.text;
      String makingcost = TableProdutMakingCostController.text;
      String category = TableProdutCategoryController.text;

      String quantity = TableQuantityController.text;
      // Extract required details from controllers
      String totalamt = FinalAmtController.text;

      String taxable = Taxableamountcontroller.text;
      // print("final amount :${FinalAmtController.text}");

      String cgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTperccontroller.text;

      String cgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTAmtController.text;
      String sgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTPercController.text;
      String sgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTAmtController.text;
      bool productExists = false;

      for (var item in salestableData) {
        if (item['productName'] == productName) {
          item['quantity'] =
              (int.parse(item['quantity']) + int.parse(quantity)).toString();

          item['Amount'] =
              (double.parse(item['Amount']) + double.parse(totalamt))
                  .toString();
          item['retail'] =
              (double.parse(item['retail']) + double.parse(taxable)).toString();
          item['cgstAmt'] =
              (double.parse(item['cgstAmt']) + double.parse(cgstAmount))
                  .toString();
          item['sgstAmt'] =
              (double.parse(item['sgstAmt']) + double.parse(sgstAmount))
                  .toString();
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        setState(() {
          salestableData.add({
            'productName': productName,
            'amount': amount,
            'quantity': quantity,
            "cgstAmt": cgstAmount,
            "sgstAmt": sgstAmount,
            "Amount": totalamt,
            "retail": taxable,
            "retailrate": amount,
            "cgstperc": cgstPercentage,
            "sgstperc": sgstPercentage,
            "makingcost": makingcost,
            "category": category,
          });
        });
      }

      setState(() {
        productName = '';
        TableCodeController.clear();
        updateenable = false;
      });

      TableCodeController.clear();
      TableItemController.clear();
      ProductNameSelected = '';
      TableAmountController.clear();
      TableQuantityController.clear();
      FinalAmtController.clear();
    }
  }

  void UpdateData() {
    // Check if any required field is empty
    if (TableCodeController.text.isEmpty ||
        TableItemController.text.isEmpty ||
        TableAmountController.text.isEmpty ||
        TableQuantityController.text.isEmpty ||
        FinalAmtController.text.isEmpty ||
        UpdateidController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (widget.SalesPaytype.text.toLowerCase() == 'credit' &&
        TableCusNameController.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details, when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productName = TableItemController.text;
      String amount = TableAmountController.text;
      String makingcost = TableProdutMakingCostController.text;
      String category = TableProdutCategoryController.text;

      String quantity = TableQuantityController.text;
      // Extract required details from controllers
      String totalamt = FinalAmtController.text;

      String taxable = Taxableamountcontroller.text;
      // print("final amount :${FinalAmtController.text}");

      String cgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTperccontroller.text;

      String cgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTAmtController.text;
      String sgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTPercController.text;
      String sgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTAmtController.text;
      bool productExists = false;

      for (var item in salestableData) {
        if (item['productName'] == productName) {
          item['quantity'] =
              (int.parse(item['quantity']) + int.parse(quantity)).toString();

          item['Amount'] =
              (double.parse(item['Amount']) + double.parse(totalamt))
                  .toString();
          item['retail'] =
              (double.parse(item['retail']) + double.parse(taxable)).toString();
          item['cgstAmt'] =
              (double.parse(item['cgstAmt']) + double.parse(cgstAmount))
                  .toString();
          item['sgstAmt'] =
              (double.parse(item['sgstAmt']) + double.parse(sgstAmount))
                  .toString();
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        setState(() {
          salestableData.add({
            'productName': productName,
            'amount': amount,
            'quantity': quantity,
            "cgstAmt": cgstAmount,
            "sgstAmt": sgstAmount,
            "Amount": totalamt,
            "retail": taxable,
            "retailrate": amount,
            "cgstperc": cgstPercentage,
            "sgstperc": sgstPercentage,
            "makingcost": makingcost,
            "category": category,
          });
        });
      }

      setState(() {
        productName = '';
        TableCodeController.clear();
        updateenable = false;
      });

      TableCodeController.clear();
      TableItemController.clear();
      ProductNameSelected = '';
      TableAmountController.clear();
      TableQuantityController.clear();
      FinalAmtController.clear();
    }
  }

  void lastsaveData() {
    // Check if any required field is empty
    if (selectedCode.isEmpty) {
      // Handle empty selectedCode
      return;
    }

    // Extract required details from controllers
    String totalamt = FinalAmtController.text;
    String taxable = Taxableamountcontroller.text;

    // print("final amount lasttable:${FinalAmtController.text}");
    // print("taxable  amount lasttable:${Taxableamountcontroller.text}");

    String cgstPercentage =
        SalesGstMethodController.text.isEmpty ? "0" : CGSTperccontroller.text;

    String cgstAmount =
        SalesGstMethodController.text.isEmpty ? "0" : CGSTAmtController.text;
    String sgstPercentage =
        SalesGstMethodController.text.isEmpty ? "0" : SGSTPercController.text;
    String sgstAmount =
        SalesGstMethodController.text.isEmpty ? "0" : SGSTAmtController.text;

    setState(() {
      // Iterate through salestableData and save only the required fields with the provided table number
      for (var data in salestableData) {
        finalsalestableData.add({
          'TableNo': selectedCode,
          'productName': data[
              'productName'], // Assuming 'productName' is a key in salestableData
          'amount':
              data['amount'], // Assuming 'amount' is a key in salestableData
          'quantity': data[
              'quantity'], // Assuming 'quantity' is a key in salestableData
          "cgstAmt": cgstAmount,
          "sgstAmt": sgstAmount,
          "Amount": data['Amount'],
          "retail": taxable,
          "retailrate": data['amount'],
          'cgstperc': cgstPercentage,
          'sgstperc': sgstPercentage,
          'makingcost': data['makingcost'],
          'category': data['category'],
        });
      }
    });

    // Clear salestableData after saving required data
    salestableData.clear();
  }

  Future<void> _printResult() async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime currentDatetime = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
      String formattedDateTime = DateFormat('hh:mm a').format(currentDatetime);
      String tableno = TableNoController.text;
      String serventName = SNameController.text;
      String date = formattedDate;
      String time = formattedDateTime;

      List<String> productDetails = [];
      for (var data in salestableData) {
        productDetails.add("${data['productName']}-${data['quantity']}");
      }
      getKitchenPrinterProducts();
      String productDetailsString = productDetails.join(",");
      // print("product details : $productDetailsString");
      print(
          "$IpAddress/KitchenSalesPrint3Inch/$tableno-$serventName-$date-$time/$productDetailsString");
      final response = await http.get(Uri.parse(
          '$IpAddress/KitchenSalesPrint3Inch/$tableno-$serventName-$date-$time/$productDetailsString'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, print the response body.
        // print('Response: ${response.body}');
      } else {
        // If the server did not return a 200 OK response, print the status code.
        // print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any potential errors.
      print('Error: $e');
    }
  }

  Future<List<String>> getKitchenPrinterProducts() async {
    String? cusid = await SharedPrefs.getCusId();
    final categoryUrl = '$IpAddress/Settings_ProductCategory/$cusid/';
    List<String> kitchenPrinterProducts = [];
    String? nextUrl = categoryUrl;

    // Fetch categories from all pages
    while (nextUrl != null) {
      try {
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);
          final List<dynamic> categories = decodedData['results'];

          // Collect product names where type is "KitchenPrinter"
          for (var category in categories) {
            if (category['type'] == 'KitchenPrinter') {
              kitchenPrinterProducts.add(category['cat']);
            }
          }

          nextUrl = decodedData['next'];
        } else {
          throw Exception(
              'Failed to load category data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
        throw Exception('Failed to load category data');
      }
    }

    // Print the list of KitchenPrinter products
    // print('Kitchen printer category: $kitchenPrinterProducts');

    return kitchenPrinterProducts;
  }

  void addButtonPressed() {
    saveData(); // Call the saveData function to add data
    if (!_isRunning) {
      _startTimer; // Start the timer if it's not already running
    }
    setState(() {
      // Trigger a rebuild to reflect the changes in tablesalesview
      tablesalesview();
    });
  }

  void _deleteRow(int index) {
    setState(() {
      salestableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

  void _deleteRowinitemtable(int index) {
    setState(() {
      finalsalestableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

  cleardata() {
    SCodeController.clear();
    SNameController.clear();
    TableCusNameController.clear();
    TableContactController.clear();
    TableAddressController.clear();

    TableCodeController.clear();
    TableItemController.clear();
    ProductNameSelected = '';
    TableAmountController.clear();
    TableQuantityController.clear();
    FinalAmtController.clear();
    finalsalestableData = [];
    salestableData = [];
    String tableno = TableNoController.text;

    deleteTableData(tableno);

    setState(() {
      TableCodeController.clear();
    });
  }

  Closetabledetails() {
    SCodeController.clear();
    SNameController.clear();
    TableCusNameController.clear();
    TableContactController.clear();
    TableAddressController.clear();

    TableCodeController.clear();
    TableItemController.clear();
    ProductNameSelected = '';
    TableAmountController.clear();
    TableQuantityController.clear();
    FinalAmtController.clear();
    finalsalestableData = [];
    salestableData = [];

    setState(() {
      TableCodeController.clear();
    });
  }

  Widget tablesalesview() {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalAmount = calculateTotalAmount(); // Calculate total amount

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 0,
          right: 0,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
            // height: Responsive.isDesktop(context) ? 260 : 240,
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
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.7,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fastfood,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 1),
                                  Text("Item",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.currency_exchange_outlined,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Amount",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 300.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_box,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Action",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (salestableData.isNotEmpty)
                    ...salestableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> data = entry.value;
                      var productName = data['productName'].toString();
                      var amount = data['amount'].toString();
                      var quantity = data['quantity'].toString();
                      var cgstAmt = data['cgstAmt'].toString();
                      var sgstAmt = data['sgstAmt'].toString();
                      var Amount = data['Amount'].toString();
                      var retail = data['retail'].toString();
                      var retailrate = data['retailrate'] ?? 0;

                      var cgstperc = data['cgstperc'].toString();
                      var sgstperc = data['sgstperc'] ?? 0;
                      var makingcost = data['makingcost'] ?? 0;
                      var category = data['category'] ?? 0;
                      // print("categoryyyyyyyyyyyyyyy: $category");
                      // print("tablenoooooooooooooo : $TableNo");
                      // print("111productNameaaaaaaaaaaaaaa : $productName");
                      // print("1111111naaaaaaaaaaaaaaaa : $amount");
                      // print("11111111111cgstAmtyyyyyyyyyyyyy : $cgstAmt");
                      // print("111111111111sgstAmtttttttttttttttt : $sgstAmt");
                      // print("111111111Amounttttttttttttttt : $Amount");
                      // print("111111111retailllllllllllllllll : $retail");
                      // print("1111111retailrateaaaaaaaaaaaa : $retailrate");
                      // print("11111111111111cgstperccccccccccccc : $cgstperc");
                      // print("111111111sgstpercscccccccccc : $sgstperc");

                      bool isEvenRow = salestableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(255, 223, 225, 226);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Tooltip(
                                  message: productName,
                                  child: Center(
                                    child: Text(productName,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(amount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(quantity,
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
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Container(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  index);
                                            },
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  // Text(
                  //   "Total Amount: \$${totalAmount.toStringAsFixed(2)}",
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 16,
                  //     color: Colors.black,
                  //   ),
                  // ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController UpdateidController = TextEditingController();
  Widget tablesalesviewtableNo() {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalAmount = 0; // Variable to keep track of the total amount

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
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
              scrollDirection: Axis.horizontal,
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.7,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Containers
                        _buildTableHeader("T.No", Icons.note_alt_rounded),
                        _buildTableHeader("Item", Icons.add_box),
                        _buildTableHeader(
                            "Amt", Icons.currency_exchange_outlined),
                        _buildTableHeader("Qty", Icons.add_box),
                        _buildTableHeader("Action", Icons.delete),
                      ],
                    ),
                  ),
                  if (finalsalestableData.isNotEmpty)
                    ...finalsalestableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> data = entry.value;
                      var Amount =
                          double.tryParse(data['Amount'].toString()) ?? 0;

                      // Accumulate the total amount
                      totalAmount += Amount;

                      bool isEvenRow =
                          finalsalestableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(255, 223, 225, 226);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTableCell(
                                data['TableNo'].toString(), rowColor),
                            _buildTableCell(
                                data['productName'].toString(), rowColor),
                            _buildTableCell(
                                data['amount'].toString(), rowColor),
                            _buildTableCell(
                                data['quantity'].toString(), rowColor),
                            _buildActionButtons(index, data, rowColor),
                          ],
                        ),
                      );
                    }).toList(),
                  SizedBox(height: 10), // Spacer
                  // Text(
                  //   'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, IconData icon) {
    return Flexible(
      child: Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        width: 265.0,
        decoration: TableHeaderColor,
        child: Center(
          child: Row(
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 5),
              Text(text,
                  textAlign: TextAlign.center, style: commonLabelTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, Color? color) {
    return Flexible(
      child: Container(
        height: 30,
        width: 265.0,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child:
              Text(text, textAlign: TextAlign.center, style: TableRowTextStyle),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      int index, Map<String, dynamic> data, Color? color) {
    return Flexible(
      child: Container(
        height: 30,
        width: 255.0,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue, size: 15),
                onPressed: () {
                  TableNoController.text = data['TableNo'].toString();
                  TableItemController.text = data['productName'].toString();
                  TableAmountController.text = data['amount'].toString();
                  TableQuantityController.text = data['quantity'].toString();
                  FinalAmtController.text = data['Amount'].toString();
                  UpdateidController.text = data['id'].toString();
                  setState(() {
                    updateenable = true;
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  });
                },
              ),
              SizedBox(width: 1),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 15),
                onPressed: () {
                  _showFinalsalestableDeleteConfirmationDialog(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
//original
  // Widget tablesalesviewtableNo() {
  //   double screenHeight = MediaQuery.of(context).size.height;
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Padding(
  //       padding: const EdgeInsets.only(
  //         left: 0,
  //         right: 0,
  //       ),
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.vertical,
  //         child: Container(
  //           height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
  //           decoration: BoxDecoration(
  //             color: Colors.grey[50],
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.5),
  //                 spreadRadius: 2,
  //                 blurRadius: 5,
  //                 offset: Offset(0, 3),
  //               ),
  //             ],
  //           ),
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Container(
  //               width: Responsive.isDesktop(context)
  //                   ? MediaQuery.of(context).size.width * 0.3
  //                   : MediaQuery.of(context).size.width * 0.7,
  //               child: Column(children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 0.0, right: 0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: Responsive.isDesktop(context) ? 265 : 300,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.note_alt_rounded,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("T.No",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.add_box,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Item",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.currency_exchange_outlined,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Amt",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.add_box,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Qty",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.delete,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Action",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (finalsalestableData.isNotEmpty)
  //                   ...finalsalestableData.asMap().entries.map((entry) {
  //                     int index = entry.key;
  //                     Map<String, dynamic> data = entry.value;
  //                     var TableNo = data['TableNo'].toString();

  //                     var productName = data['productName'].toString();
  //                     var amount = data['amount'].toString();
  //                     var quantity = data['quantity'].toString();
  //                     var cgstAmt = data['cgstAmt'].toString();
  //                     var sgstAmt = data['sgstAmt'].toString();
  //                     var Amount = data['Amount'].toString();
  //                     var retail = data['retail'].toString();
  //                     var retailrate = data['retailrate'] ?? 0;

  //                     var cgstperc = data['cgstperc'].toString();
  //                     var sgstperc = data['sgstperc'] ?? 0;
  //                     var makingcost = data['makingcost'] ?? 0;
  //                     var category = data['category'] ?? 0;
  //                     // print("categoryyy11111111: $category");
  //                     // print("tablenoooooooooooooo : $TableNo");
  //                     // print("productNameaaaaaaaaaaaaaa : $productName");
  //                     // print("naaaaaaaaaaaaaaaa : $amount");
  //                     // print("cgstAmtyyyyyyyyyyyyy : $cgstAmt");
  //                     // print("sgstAmtttttttttttttttt : $sgstAmt");
  //                     // print("Amounttttttttttttttt : $Amount");
  //                     // print("retailllllllllllllllll : $retail");
  //                     // print("retailrateaaaaaaaaaaaa : $retailrate");
  //                     // print("cgstperccccccccccccc : $cgstperc");
  //                     // print("sgstpercscccccccccc : $sgstperc");
  //                     bool isEvenRow =
  //                         finalsalestableData.indexOf(data) % 2 == 0;
  //                     Color? rowColor = isEvenRow
  //                         ? Color.fromARGB(224, 255, 255, 255)
  //                         : Color.fromARGB(255, 223, 225, 226);

  //                     return Padding(
  //                       padding: const EdgeInsets.only(left: 0.0, right: 0),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(TableNo,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(productName,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(amount,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(quantity,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                               child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.only(bottom: 10.0),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   IconButton(
  //                                     icon: Icon(
  //                                       Icons.edit,
  //                                       color: Colors.blue,
  //                                       size: 15,
  //                                     ),
  //                                     onPressed: () {
  //                                       // _showEditDialog(index);
  //                                       TableNoController.text =
  //                                           data['TableNo'].toString();
  //                                       TableItemController.text =
  //                                           data['productName'].toString();
  //                                       TableAmountController.text =
  //                                           data['amount'].toString();
  //                                       TableQuantityController.text =
  //                                           data['quantity'].toString();
  //                                       FinalAmtController.text =
  //                                           data['Amount'].toString();
  //                                       UpdateidController.text =
  //                                           data['id'].toString();
  //                                       setState(() {
  //                                         updateenable = true;
  //                                         FocusScope.of(context)
  //                                             .requestFocus(quantityFocusNode);
  //                                       });
  //                                     },
  //                                   ),
  //                                   SizedBox(width: 1),
  //                                   IconButton(
  //                                     icon: Icon(
  //                                       Icons.delete,
  //                                       color: Colors.red,
  //                                       size: 15,
  //                                     ),
  //                                     onPressed: () {
  //                                       _showFinalsalestableDeleteConfirmationDialog(
  //                                           index);
  //                                     },
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ))
  //                         ],
  //                       ),
  //                     );
  //                   }).toList()
  //               ]),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<bool?> _showDeleteConfirmationDialog(index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this data?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteRow(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showFinalsalestableDeleteConfirmationDialog(index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this data?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteRowinitemtable(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}

class lastbillview extends StatefulWidget {
  const lastbillview({Key? key}) : super(key: key);

  @override
  State<lastbillview> createState() => _lastbillviewState();
}

class _lastbillviewState extends State<lastbillview> {
  @override
  void initState() {
    super.initState();
    fetchData();

    FinallyyyAmounttts.addListener(updateAmount);
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
            "url : $IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString");

        print(
            "sgst25 : $sgst25  ,  sgst6 :   $sgst6 , sgst 9 :   $sgst9  ,   sgst14:   $sgst14");

        final response = await http.get(Uri.parse(
            '$IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString'));

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
                  Text('Sales Details'),
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
                                style: TextStyle(fontSize: 14),
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                'Customer Name',
                                style: TextStyle(fontSize: 14),
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                style: TextStyle(fontSize: 14),
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                'Table No',
                                style: TextStyle(fontSize: 14),
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                                    style: TextStyle(fontSize: 14),
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
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                    'Customer Name',
                                    style: TextStyle(fontSize: 14),
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
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                                    style: TextStyle(fontSize: 14),
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
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                    'Table No',
                                    style: TextStyle(fontSize: 14),
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
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Item Name",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Rate",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Quantity",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Total Retail",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Total Amount",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Retail Rate",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
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
                                  var Itemname = data['Itemname'].toString();
                                  var rate = data['rate'].toString();

                                  var retailrate = data['retail'].toString();
                                  var qty = data['qty'].toString();
                                  var amount = data['amount'].toString();

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
                                                Itemname,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                rate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                qty,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                retailrate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                rate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                      child: Text(
                        "Print",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      child: Text(
                        "Preview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
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

  // @override
  // void dispose() {
  //   FinallyyyAmounttts.removeListener(updateAmount);
  //   FinallyyyAmounttts.dispose();
  //   super.dispose();
  // }

  void updateAmount() {
    setState(() {}); // Update the UI when FinallyyyAmounttts changes
  }

  Future<void> fetchData() async {
    String startdt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String enddt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    String? cusid = await SharedPrefs.getCusId();
    // Format the dates to string
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        tableData = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
        width: Responsive.isDesktop(context)
            ? screenwidth
            : MediaQuery.of(context).size.width * 0.8,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (Responsive.isDesktop(context))
            //   Padding(
            //     padding: const EdgeInsets.only(left: 0, top: 3),
            //     child: Container(
            //       height: 35,
            //       width: Responsive.isDesktop(context)
            //           ? 260
            //           : MediaQuery.of(context).size.width * 0.75,
            //       color: Color.fromARGB(255, 225, 225, 225),
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           Padding(
            //             padding: EdgeInsets.only(
            //                 left: Responsive.isDesktop(context) ? 0 : 0,
            //                 top: 0),
            //             child: Container(
            //               width: Responsive.isDesktop(context) ? 70 : 70,
            //               height: 35,
            //               child: ElevatedButton(
            //                 onPressed: () {
            //                   // Handle form submission
            //                 },
            //                 style: ElevatedButton.styleFrom(
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(2.0),
            //                   ),
            //                   backgroundColor: subcolor,
            //                   minimumSize:
            //                       Size(45.0, 31.0), // Set width and height
            //                 ),
            //                 child: Text(
            //                   'RS. ',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                     fontSize: 18,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           Padding(
            //             padding: EdgeInsets.only(
            //                 left: Responsive.isDesktop(context) ? 20 : 20,
            //                 top: 11),
            //             child: Container(
            //               width: Responsive.isDesktop(context) ? 85 : 85,
            //               child: Container(
            //                 height: 24,
            //                 width: 100,
            //                 child: Text(
            //                   "${NumberFormat.currency(symbol: '', decimalDigits: 0).format(double.tryParse(FinallyyyAmounttts.text ?? '0') ?? 0)} /-",
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.w700,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    "Last Bill",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            tableView(),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.isDesktop(context) ? 20 : 0,
                            top: 0),
                        child: Container(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              backgroundColor: subcolor,
                              minimumSize:
                                  Size(45.0, 31.0), // Set width and height
                            ),
                            child: Text(
                              'New Sales',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Container(
                  // color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.isDesktop(context) ? 20 : 0,
                            top: 0),
                        child: Container(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle form submission
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              backgroundColor: subcolor,
                              minimumSize:
                                  Size(45.0, 31.0), // Set width and height
                            ),
                            child: Text(
                              'Printer Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.65 : 320,
          // height: Responsive.isDesktop(context) ? 380 : 240,
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.23
              : MediaQuery.of(context).size.width,

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
              width: Responsive.isDesktop(context)
                  ? screenwidth * 0.23
                  : MediaQuery.of(context).size.width * 0.8,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          height: 25,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notes_rounded,
                                    size: 15, color: Colors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Bill No",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 25,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money,
                                    size: 15, color: Colors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Amount",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
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
                    var id = data['id'].toString();

                    var billno = data['billno'].toString();
                    var amount = NumberFormat('###,###,##0.00')
                        .format(double.parse(data['amount'].toString()));
                    bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                    Color? rowColor = isEvenRow
                        ? Color.fromARGB(224, 255, 255, 255)
                        : Color.fromARGB(255, 223, 225, 226);

                    return Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0),
                      child: GestureDetector(
                        onTap: () {
                          // purchasePaymentDetails(data);
                          fetchsalesdetails(data);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
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
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
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
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class finalamount extends StatefulWidget {
  final TextEditingController finalAmount;

  const finalamount({Key? key, required this.finalAmount}) : super(key: key);

  @override
  _finalamountState createState() => _finalamountState();

  static _finalamountState? of(BuildContext context) =>
      context.findAncestorStateOfType<_finalamountState>();

  void updateFinalAmountforall(String text) {}
}

class _finalamountState extends State<finalamount> {
  TextEditingController _finalAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    _finalAmount = widget.finalAmount;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 15),
      child: Container(
        width: screenWidth * 0.18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Container(
                height: 45,
                width: screenWidth * 0.15,
                color: Color.fromARGB(255, 225, 225, 225),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isDesktop(context) ? 0 : 0, top: 0),
                      child: Container(
                        width: screenWidth * 0.045,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button action
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              backgroundColor: subcolor,
                              minimumSize: Size(45.0, 31.0),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0)),
                          child: Text('RS. ',
                              style: commonWhiteStyle.copyWith(fontSize: 16)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isDesktop(context) ? 20 : 20,
                          top: 11),
                      child: Container(
                        width: screenWidth * 0.08,
                        child: Container(
                          height: 24,
                          width: 100,
                          child: Text(
                            "${NumberFormat.currency(symbol: '', decimalDigits: 0).format(double.tryParse(_finalAmount.text) ?? 0)} /-",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
    );
  }
}
