import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

import '../../Modules/Responsive.dart';

void main() {
  runApp(DailySalesDetailsReport());
}

class DailySalesDetailsReport extends StatefulWidget {
  @override
  State<DailySalesDetailsReport> createState() =>
      _DailySalesDetailsReportState();
}

class _DailySalesDetailsReportState extends State<DailySalesDetailsReport> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> categorytableData = [];
  List<Map<String, dynamic>> PaymentTypeData = [];

  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  String selectedValue = 'Ramya';

  bool isCatChecked = false;
  bool isPayChecked = false;

  TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selecteddate;

  TextEditingController ProductCategoryController = TextEditingController();
  TextEditingController billCountController = TextEditingController();
  final TextEditingController salesAmountController = TextEditingController();
  final TextEditingController TotalAmtController = TextEditingController();

  TextEditingController PaymentTypeController = TextEditingController();
  @override
  void initState() {
    super.initState();

    fetchAllProductCategories();
    fetchPaymenttype();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Convert search text to lowercase
    String searchTextLower = searchText.toLowerCase();

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) =>
            (data['Itemname'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String date = _dateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(date);
    String formatedlogreportstartdt =
        DateFormat('dMMMM,yyyy').format(startDate);
    String apiUrl = '$IpAddress/DaySelectedSales/$cusid/$date/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      Map<String, List<Map<String, dynamic>>> salesByBill = {};
      double totalSalesAmount = 0;

      for (var item in jsonData) {
        String paytype = item['paytype'];

        List<Map<String, dynamic>> salesDetails = [];
        for (var detail in item['SalesDetails']) {
          salesDetails.add({
            'prodname': detail['Itemname'],
            'amount': detail['amount'],
            'qty': detail['qty'],
          });
          totalSalesAmount += double.parse(detail['amount']);
        }
        String billno = item['SalesDetails'][0]['salesbillno'];

        if (salesByBill.containsKey(billno)) {
          salesByBill[billno]!.addAll(salesDetails);
        } else {
          salesByBill[billno] = salesDetails;
        }

        List<Map<String, dynamic>> aggregatedSales = [];
        int billCount = 0;
        salesByBill.forEach((billno, details) {
          double totalAmount = details.fold(
              0,
              (previousValue, element) =>
                  previousValue + double.parse(element['amount']));
          double totalaQty = details.fold(
              0,
              (previousValue, element) =>
                  previousValue + double.parse(element['qty']));
          billCount++;
          aggregatedSales.add({
            'billno': billno,
            // 'count': details.length,
            // 'paytype': paytype,
            'totalAmount': totalAmount,
            // 'totalaQty': totalaQty,
            // 'details': details,
          });
        });

        setState(() {
          logreports("DailySalesReport: ${formatedlogreportstartdt}_Viewd");

          tableData = aggregatedSales;
          billCountController.text = billCount.toString();
          salesAmountController.text = totalSalesAmount.toStringAsFixed(2);
          TotalAmtController.text = totalSalesAmount.toStringAsFixed(2);
        });
      }
    }
  }

  Future<void> fetchProductPaymenttype(String selectedPaytype) async {
    String? cusid = await SharedPrefs.getCusId();
    String date = _dateController.text;
    String apiUrl = '$IpAddress/DaySelectedSales/$cusid/$date/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      Map<String, List<Map<String, dynamic>>> salesByBill = {};
      Map<String, String> billPaymentTypeMap = {};
      double totalSalesAmount = 0;

      for (var item in jsonData) {
        List<Map<String, dynamic>> salesDetails = [];
        for (var detail in item['SalesDetails']) {
          salesDetails.add({
            'prodname': detail['Itemname'],
            'amount': detail['amount'],
            'qty': detail['qty'],
          });
          totalSalesAmount += double.parse(detail['amount']);
        }
        String billno = item['SalesDetails'][0]['salesbillno'];
        String paytype = item['paytype'];

        if (salesByBill.containsKey(billno)) {
          salesByBill[billno]!.addAll(salesDetails);
        } else {
          salesByBill[billno] = salesDetails;
          billPaymentTypeMap[billno] = paytype;
        }
      }

      List<Map<String, dynamic>> aggregatedSales = [];
      int billCount = 0;
      salesByBill.forEach((billno, details) {
        double totalAmount = details.fold(
            0,
            (previousValue, element) =>
                previousValue + double.parse(element['amount']));
        double totalQty = details.fold(
            0,
            (previousValue, element) =>
                previousValue + double.parse(element['qty']));
        billCount++;
        String paytype = billPaymentTypeMap[billno] ?? "";

        if (selectedPaytype.isEmpty || paytype == selectedPaytype) {
          aggregatedSales.add({
            'billno': billno,
            'count': details.length,
            'paytype': paytype,
            'totalAmount': totalAmount,
            'totalQty': totalQty,
            'details': details,
          });
        }
      });

      setState(() {
        PaymentTypeData = aggregatedSales;
        billCountController.text = billCount.toString();
        salesAmountController.text = totalSalesAmount.toStringAsFixed(2);
      });
    }
  }

  Future<void> fetchproductnamecategory(String selectedCategory) async {
    String? cusid = await SharedPrefs.getCusId();
    String date = _dateController.text;
    String apiUrl = '$IpAddress/DaySelectedSales/$cusid/$date/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      Map<String, Map<String, dynamic>> aggregatedData = {};

      for (var item in jsonData) {
        for (var detail in item['SalesDetails']) {
          String productName = detail['Itemname'];
          String category = detail['category'];

          // If selectedCategory is empty, include all categories
          if (selectedCategory.isEmpty || category == selectedCategory) {
            double amount = double.parse(detail['amount']);
            double qty = double.parse(detail['qty']);

            if (aggregatedData.containsKey(productName)) {
              // If product already exists, update quantity and amount
              qty += aggregatedData[productName]!['productqty'];
              amount += aggregatedData[productName]!['productamount']!;
            }

            // Update or add product to aggregated data
            aggregatedData[productName] = {
              'productname': productName,
              'productqty': qty,
              'productamount': amount,
            };
          }
        }
      }

      setState(() {
        categorytableData = aggregatedData.values.toList();
      });
    }
  }

  double getCategoryTotalAmount(List<Map<String, dynamic>> categorytableData) {
    double totalAmount = 0.0;
    for (var data in categorytableData) {
      double quantity =
          double.tryParse(data['productamount'].toString()) ?? 0.0;
      totalAmount += quantity;
    }
    totalAmount = double.parse(totalAmount.toStringAsFixed(2));

    return totalAmount;
  }

  double GetPaymentMethodTotalAmt(List<Map<String, dynamic>> PaymentTypeData) {
    double totalAmount = 0.0;
    for (var data in PaymentTypeData) {
      double quantity = double.tryParse(data['totalAmount'].toString()) ?? 0.0;
      totalAmount += quantity;
    }
    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    print("total amtttt : $totalAmount");
    return totalAmount;
  }

  List<String> ProductCategoryList = [];

  Future<void> fetchAllProductCategories() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductCategory/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductCategoryList.addAll(
              results.map<String>((item) => item['cat'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $ProductCategoryList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? ProductcategoyselectedValue;

  int? _selectedProdIndex;

  bool _ProdNamefilterEnabled = true;
  int? _ProdNamehoveredIndex;

  Widget ProductCategoryDropdown() {
    String date = _dateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(date);
    String formatedlogreportstartdt =
        DateFormat('dMMMM,yyyy').format(startDate);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex < ProductCategoryList.length - 1) {
              setState(() {
                _selectedProdIndex = currentIndex + 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex + 1];
                _ProdNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProdIndex = currentIndex - 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex - 1];
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
              ProductcategoyselectedValue = suggestion;
              ProductCategoryController.text = suggestion!;
              _ProdNamefilterEnabled = false;
            });

            logreports(
                "DailySalesReport: Category-${ProductCategoryController.text}_${formatedlogreportstartdt}_Viewd");
            await fetchproductnamecategory(ProductCategoryController.text);
            double totalAmount = getCategoryTotalAmount(categorytableData);
            TotalAmtController.text = totalAmount.toString();
          },
          controller: ProductCategoryController,
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
              ProductcategoyselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_ProdNamefilterEnabled && pattern.isNotEmpty) {
            return ProductCategoryList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductCategoryList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductCategoryList.indexOf(suggestion);
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
                          ProductCategoryList.indexOf(
                                  ProductCategoryController.text) ==
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
            ProductcategoyselectedValue = suggestion;
            ProductCategoryController.text = suggestion!;
            _ProdNamefilterEnabled = false;
          });
          logreports(
              "DailySalesReport: Category-${ProductCategoryController.text}_${formatedlogreportstartdt}_Viewd");

          await fetchproductnamecategory(ProductCategoryController.text);
          double totalAmount = getCategoryTotalAmount(categorytableData);
          TotalAmtController.text = totalAmount.toString();
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

  List<String> PaymentTypeList = [];

  Future<void> fetchPaymenttype() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PaymentMethod/$cusid';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<String> fetchedPaytypes = [];

        for (var item in data) {
          String PaymentTypeList = item['paytype'];
          fetchedPaytypes.add(PaymentTypeList);
        }

        setState(() {
          PaymentTypeList = fetchedPaytypes;
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  String? PaymentTypeSelectedValue;

  int? _selectedPayTypeIndex;
  bool _PayTypefilterEnabled = true;
  int? _PayTypehoveredIndex;

  Widget PaymentTypeDropdown() {
    String date = _dateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(date);
    String formatedlogreportstartdt =
        DateFormat('dMMMM,yyyy').format(startDate);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeController.text);
            if (currentIndex < PaymentTypeList.length - 1) {
              setState(() {
                _selectedPayTypeIndex = currentIndex + 1;
                PaymentTypeController.text = PaymentTypeList[currentIndex + 1];
                _PayTypefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                PaymentTypeController.text = PaymentTypeList[currentIndex - 1];
                _PayTypefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: PaymentTypeController,
          onSubmitted: (_) async {
            logreports(
                "DailySalesReport: Category-${ProductCategoryController.text}_${formatedlogreportstartdt}_Viewd");
            await fetchProductPaymenttype(PaymentTypeController.text);
            double totalAmount = GetPaymentMethodTotalAmt(PaymentTypeData);
            TotalAmtController.text = totalAmount.toString();
          },
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
              _PayTypefilterEnabled = true;
              PaymentTypeSelectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_PayTypefilterEnabled && pattern.isNotEmpty) {
            return PaymentTypeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return PaymentTypeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = PaymentTypeList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _PayTypehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _PayTypehoveredIndex = null;
            }),
            child: Container(
              color: _selectedPayTypeIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedPayTypeIndex == null &&
                          PaymentTypeList.indexOf(PaymentTypeController.text) ==
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
            PaymentTypeController.text = suggestion!;
            PaymentTypeSelectedValue = suggestion;
            _PayTypefilterEnabled = false;
          });

          logreports(
              "DailySalesReport: Category-${ProductCategoryController.text}_${formatedlogreportstartdt}_Viewd");
          await fetchProductPaymenttype(PaymentTypeController.text);
          double totalAmount = GetPaymentMethodTotalAmt(PaymentTypeData);
          TotalAmtController.text = totalAmount.toString();
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

  Future<List<String>> fetchPaytype() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/PaymentMethod/$cusid'));

    if (response.statusCode == 200) {
      List<dynamic> paytypeList = json.decode(response.body);
      List<String> paytypes = [];
      for (var paytype in paytypeList) {
        paytypes.add(paytype['paytype']);
      }
      // print("Paytype : $paytypes");

      return paytypes;
    } else {
      throw Exception('Failed to fetch paytype data');
    }
  }

  Future<String> getPrintCount(
      List<Map<String, dynamic>> paymentTypeData) async {
    try {
      List<String> paytypes = await fetchPaytype();

      if (paytypes.isNotEmpty) {
        print('Paytypes: $paytypes');

        List<String> productDetails = [];

        for (var paytype in paytypes) {
          int count = 0;
          int totalAmount = 0;

          for (var data in PaymentTypeData) {
            if (data.containsKey('paytype') && data['paytype'] == paytype) {
              totalAmount += data.containsKey('totalAmount')
                  ? int.parse(data['totalAmount'].toString())
                  : 0;
              count++;
            }
          }

          productDetails.add("$paytype-$totalAmount-$count");
        }

        String productDetailsString = productDetails.join(",");

        print('Productdetails : $productDetailsString');

        return productDetailsString;
      } else {
        print('Paytype data is empty');
        return '';
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

  Future<void> _printResult() async {
    try {
      String productDetailsString = await getPrintCount(PaymentTypeData);

      print("product details : $productDetailsString");
      print(
          "http://127.0.0.1:8000/DailySalesReport3Inch/$productDetailsString");
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/DailySalesReport3Inch/$productDetailsString'));

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String salesType = 'Billwise'; // Default sales type

  @override
  Widget build(BuildContext context) {
    if (isCatChecked) {
      salesType = 'Productwise';
    } else if (isPayChecked) {
      salesType = 'Paywise';
    } else {
      salesType = 'Billwise'; // Default sales type when no box is checked
    }
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
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              'Daily Sales Summary',
                              style: HeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: Responsive.isMobile(context) ? 10 : 0,
                            bottom: Responsive.isMobile(context) ? 10 : 0,
                            right: Responsive.isMobile(context) ? 10 : 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Sales : ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(salesAmountController.text ?? '0') ?? 0)} /-',
                              style: AmountTextStyle,
                            ),
                            SizedBox(width: 40),
                            Text(
                              'Count : ${billCountController.text}',
                              style: AmountTextStyle,
                            )
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Date',
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
                                      border: Border.all(
                                          color: Colors.grey.shade300),
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
                                                controller: _dateController,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                                dateLabelText: '',
                                                onChanged: (val) {
                                                  setState(() {
                                                    selecteddate =
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
                            SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  fetchData();
                                  fetchproductnamecategory(
                                      ProductCategoryController.text);
                                  fetchProductPaymenttype(
                                      PaymentTypeController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: subcolor,
                                    minimumSize: Size(10, 30),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.only(left: 5, top: 22.0),
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       _printResult();
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: subcolor,
                            //       minimumSize: Size(60, 30),
                            //       padding: EdgeInsets.symmetric(
                            //           horizontal: 10, vertical: 5),
                            //       elevation: 2,
                            //     ),
                            //     child: Row(
                            //       children: [
                            //         Icon(
                            //           Icons.print,
                            //           size: 18,
                            //           color: Colors.white,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Responsive.isMobile(context)
                            ? Axis.horizontal
                            : Axis.vertical,
                        child: Padding(
                          padding: Responsive.isMobile(context)
                              ? EdgeInsets.only(top: 0, right: 30)
                              : EdgeInsets.only(top: 0.0, right: 80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: isCatChecked,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  height: 29,
                                  width: 160,
                                  child: Container(
                                      child: ProductCategoryDropdown()),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Checkbox(
                                value: isCatChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isCatChecked = value!;
                                    if (value == true) {
                                      isPayChecked = false;
                                      PaymentTypeSelectedValue = '';
                                      salesType = 'Productwise';
                                    }
                                  });
                                },
                                activeColor: subcolor,
                              ),
                              Text(
                                'Category',
                                style: commonLabelTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Responsive.isMobile(context)
                            ? Axis.horizontal
                            : Axis.vertical,
                        child: Padding(
                          padding: Responsive.isMobile(context)
                              ? EdgeInsets.only(top: 0, right: 30)
                              : EdgeInsets.only(top: 0.0, right: 80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: isPayChecked,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  height: 29,
                                  width: 160,
                                  child:
                                      Container(child: PaymentTypeDropdown()),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Checkbox(
                                value: isPayChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isPayChecked = value!;
                                    if (value == true) {
                                      isCatChecked = false;
                                      ProductcategoyselectedValue = '';
                                      salesType = 'PayTypewise';
                                    }
                                  });
                                },
                                activeColor: subcolor,
                              ),
                              Text(
                                'PayType',
                                style: commonLabelTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 20,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // This will space elements between
                                children: [
                                  // First two texts in a Row
                                  Row(
                                    children: [
                                      Text(
                                        'Sales Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(double.tryParse(salesAmountController.text ?? '0') ?? 0)} /-',
                                        style: textStyle,
                                      ),
                                      SizedBox(
                                          width:
                                              10), // Space between the two texts
                                      Text(
                                        "Count:  ${billCountController.text}",
                                        style: textStyle,
                                      ),
                                    ],
                                  ),
                                  // Button at the end of the Row
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: subcolor,
                                        minimumSize: Size(60, 30),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero)),
                                    child: Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                right: 0.0),
                                            child: Icon(
                                              Icons.print,
                                              size: 18,
                                              color: Colors.grey.shade200,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Padding(
                              //       padding: const EdgeInsets.only(
                              //         left: 10,
                              //       ),
                              //       child: Row(
                              //         children: [
                              //           Icon(
                              //             Icons.currency_rupee,
                              //             size: 18,
                              //           ),
                              //           SizedBox(
                              //             width: 5,
                              //           ),
                              // Text(
                              //   'Sales Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(double.tryParse(salesAmountController.text ?? '0') ?? 0)} /-',
                              //   style: textStyle,
                              // ),
                              //         ],
                              //       ),
                              //     ),
                              //     SingleChildScrollView(
                              //       scrollDirection: Axis.horizontal,
                              //       child: Padding(
                              //         padding: EdgeInsets.only(
                              //             left: 5,
                              //             top: Responsive.isMobile(context)
                              //                 ? 0
                              //                 : 0),
                              //         child: Row(
                              //           children: [
                              //             Icon(
                              //               Icons.control_point_outlined,
                              //               size: 18,
                              //             ),
                              //             SizedBox(
                              //               width: 5,
                              //             ),
                              // Text(
                              //   "Count:  ${billCountController.text}",
                              //   style: textStyle,
                              // ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     Spacer(),
                              //     if (!Responsive.isMobile(context))
                              // ElevatedButton(
                              //   onPressed: () {},
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: subcolor,
                              //     minimumSize: Size(60, 30),
                              //     padding: EdgeInsets.symmetric(
                              //         horizontal: 10, vertical: 5),
                              //     elevation: 2,
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Padding(
                              //           padding: const EdgeInsets.only(
                              //               right: 0.0),
                              //           child: Icon(
                              //             Icons.print,
                              //             size: 18,
                              //             color: Colors.grey.shade200,
                              //           )),
                              //     ],
                              //   ),
                              // ),
                              //     if (!Responsive.isMobile(context))
                              //       SizedBox(width: 6),
                              //     if (!Responsive.isMobile(context))
                              //       Padding(
                              //         padding: const EdgeInsets.only(
                              //           right: 20.0,
                              //         ),
                              //         // child: Container( row
                              //         //   height: 30,
                              //         //   width: 130,
                              //         //   child: TextField(
                              //         //     onChanged: (value) {
                              //         //       setState(() {
                              //         //         searchText = value;
                              //         //       });
                              //         //     },
                              //         //     decoration: InputDecoration(
                              //         //       labelText: 'Search',
                              //         //       suffixIcon: Icon(
                              //         //         Icons.search,
                              //         //         color: Colors.grey,
                              //         //       ),
                              //         //       floatingLabelBehavior:
                              //         //           FloatingLabelBehavior.never,
                              //         //       border: OutlineInputBorder(
                              //         //         borderRadius:
                              //         //             BorderRadius.circular(1),
                              //         //       ),
                              //         //       enabledBorder: OutlineInputBorder(
                              //         //         borderSide: BorderSide(
                              //         //             color: Colors.grey,
                              //         //             width: 1.0),
                              //         //         borderRadius:
                              //         //             BorderRadius.circular(1),
                              //         //       ),
                              //         //       focusedBorder: OutlineInputBorder(
                              //         //         borderSide: BorderSide(
                              //         //             color: Colors.grey,
                              //         //             width: 1.0),
                              //         //         borderRadius:
                              //         //             BorderRadius.circular(1),
                              //         //       ),
                              //         //       contentPadding: EdgeInsets.only(
                              //         //           left: 10.0, right: 4.0),
                              //         //     ),
                              //         //     style: textStyle,
                              //         //   ),
                              //         // ),
                              //       ),
                              //   ],
                              // ),
                              if (Responsive.isMobile(context))
                                Row(
                                  children: [
                                    if (!Responsive.isMobile(context))
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: subcolor,
                                          padding: EdgeInsets.only(
                                              left: 7,
                                              right: 7,
                                              top: 3,
                                              bottom: 3),
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 0.0),
                                                child: Icon(
                                                  Icons.print,
                                                  color: Colors.grey.shade200,
                                                )),
                                          ],
                                        ),
                                      ),
                                    if (!Responsive.isMobile(context))
                                      SizedBox(width: 6),
                                    if (!Responsive.isMobile(context))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 20.0,
                                        ),
                                        child: Container(
                                          height: 30,
                                          width: 130,
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                searchText = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Search',
                                              suffixIcon: Icon(
                                                Icons.search,
                                                color: Colors.grey,
                                              ),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                  left: 10.0, right: 4.0),
                                            ),
                                            style: textStyle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              Column(
                                children: [
                                  if (Responsive.isDesktop(context))
                                    tableViewDeskTop(),
                                  if (Responsive.isMobile(context))
                                    tableViewMobile()
                                ],
                              ),
                              SizedBox(height: 15),
                              // Define a variable for sales type

// Widget to display sales type and total amount
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total Amount : ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotalAmtController.text ?? '0') ?? 0)} /-',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight
                                            .bold), // Display the total amount first
                                  ),

                                  SizedBox(
                                      width: 5), // Adding space between texts
                                  Text(
                                    '($salesType)', // Dynamically show the sales type after the total amount
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
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

  Widget tableViewDeskTop() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
              width: Responsive.isDesktop(context) ? 300 : 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
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
                                width: 300.0,
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
                                width: 300.0,
                                height: 30,
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
                          var billno = data['billno'].toString();
                          var amount = data['totalAmount'].toString();
                          bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 0.0, right: 0, top: 5.0, bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 5),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
              width: Responsive.isDesktop(context) ? 500 : 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
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
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text("Item",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
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
                      if (categorytableData.isNotEmpty)
                        ...categorytableData.asMap().entries.map((entry) {
                          int index = entry.key;

                          Map<String, dynamic> data = entry.value;
                          var productname = data['productname'].toString();
                          var productqty = data['productqty'].toString();
                          var productamount = data['productamount'].toString();

                          bool isEvenRow =
                              categorytableData.indexOf(data) % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 0.0, right: 0, top: 5.0, bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(productname,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(productqty,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(productamount,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                              ],
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
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 5),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
              width: Responsive.isDesktop(context) ? 400 : 430,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
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
                                width: 300.0,
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
                                width: 300.0,
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
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
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
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text("Paytype",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (PaymentTypeData.isNotEmpty)
                        ...PaymentTypeData.asMap().entries.map((entry) {
                          int index = entry.key;

                          Map<String, dynamic> data = entry.value;

                          var billno = data['billno'].toString();
                          var totalAmount = data['totalAmount'].toString();

                          var totalaQty = data['totalQty'].toString();

                          var count = data['count'].toString();

                          var paytype = data['paytype'].toString();

                          bool isEvenRow =
                              PaymentTypeData.indexOf(data) % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 0.0, right: 0, top: 5.0, bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(totalaQty,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(totalAmount,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(paytype,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }

  Widget tableViewMobile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? 300 : 350,
              width: 430,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'BillWise Report',
                          style: textStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, right: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                width: 300.0,
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
                                width: 300.0,
                                height: 30,
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
                          var billno = data['billno'].toString();
                          var amount = data['totalAmount'].toString();
                          bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 2.0, right: 2, top: 5.0, bottom: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? 300 : 350,
              width: 430,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ProductWise Report',
                          style: textStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, right: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text("Item",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
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
                      if (categorytableData.isNotEmpty)
                        ...categorytableData.asMap().entries.map((entry) {
                          int index = entry.key;

                          Map<String, dynamic> data = entry.value;
                          var productname = data['productname'].toString();
                          var productqty = data['productqty'].toString();
                          var productamount = data['productamount'].toString();

                          bool isEvenRow =
                              categorytableData.indexOf(data) % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 2.0, right: 2, top: 5.0, bottom: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        productname,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        productqty,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        productamount,
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
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? 300 : 350,
              width: 430,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'PayTypeWise Report',
                          style: textStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, right: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "BillNo",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Count",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Disc",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
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
                            Flexible(
                              child: Container(
                                width: 300.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Paytype",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (PaymentTypeData.isNotEmpty)
                        ...PaymentTypeData.asMap().entries.map((entry) {
                          int index = entry.key;

                          Map<String, dynamic> data = entry.value;

                          var billno = data['billno'].toString();
                          var totalAmount = data['totalAmount'].toString();

                          var totalaQty = data['totalQty'].toString();

                          var count = data['count'].toString();

                          var paytype = data['paytype'].toString();

                          bool isEvenRow =
                              PaymentTypeData.indexOf(data) % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 2.0, right: 2, top: 5.0, bottom: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
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
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(totalaQty,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(totalAmount,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(paytype,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
