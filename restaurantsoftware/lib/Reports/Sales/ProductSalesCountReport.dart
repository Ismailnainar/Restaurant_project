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
  runApp(ProductSalesCountReport());
}

class ProductSalesCountReport extends StatefulWidget {
  @override
  State<ProductSalesCountReport> createState() =>
      _ProductSalesCountReportState();
}

class _ProductSalesCountReportState extends State<ProductSalesCountReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  bool isCatChecked = false;

  @override
  void initState() {
    super.initState();
    fetchAllProductCategories();
  }

  TextEditingController ProductCategoryController = TextEditingController();
  TextEditingController TotalAmountController = TextEditingController();

  TextEditingController _enddateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController _startdateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  List<String> getDisplayedColumns() {
    return ['Itemname', 'qty', 'amount'];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData) {
    List<String> displayedColumns = getDisplayedColumns();
    return tableData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
  }

  Future<void> fetchDateWiseSales() async {
    String startDt = _startdateController.text;
    String endDt = _enddateController.text;

    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDt);

    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    // Format the dates to string

    String foramtedletterstartdt = DateFormat('d MMMM,yyyy').format(startDate);
    String foramtedletterenddt = DateFormat('d MMMM,yyyy').format(endDate);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    print("start date = $formattedStartDate end date = $formattedEndDate");

    String? cusid = await SharedPrefs.getCusId();
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Map to store aggregated data
      Map<String, Map<String, dynamic>> aggregatedData = {};

      // Iterate through each sales entry
      for (var salesEntry in jsonData) {
        // Iterate through each sales detail
        for (var salesDetail in salesEntry['SalesDetails']) {
          String itemName = salesDetail['Itemname'];
          double qty = double.parse(salesDetail['qty']);
          double amount = double.parse(salesDetail['amount']);

          // If item name already exists, add quantity and amount
          if (aggregatedData.containsKey(itemName)) {
            aggregatedData[itemName]!['qty'] += qty;
            aggregatedData[itemName]?['amount'] += amount;
          } else {
            // Otherwise, create new entry
            aggregatedData[itemName] = {
              'qty': qty,
              'amount': amount,
            };
          }
        }
      }

      // Convert aggregated data to list format for display
      List<Map<String, dynamic>> aggregatedList = [];
      aggregatedData.forEach((itemName, data) {
        aggregatedList.add({
          'Itemname': itemName,
          'qty': data['qty'],
          'amount': data['amount'],
        });
      });

      // Update state with aggregated data
      setState(() {
        logreports(
            "SalesProductCountReport: ${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");

        tableData = aggregatedList;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchproductnamecategory(String selectedCategory) async {
    String startDt = _startdateController.text;
    String endDt = _enddateController.text;

    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDt);

    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    // Format the dates to string
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    print("start date = $formattedStartDate end date = $formattedEndDate");

    String? cusid = await SharedPrefs.getCusId();
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Map to store aggregated data
      Map<String, Map<String, dynamic>> aggregatedData = {};

      // Iterate through each sales entry
      for (var salesEntry in jsonData) {
        // Iterate through each sales detail
        for (var salesDetail in salesEntry['SalesDetails']) {
          String itemName = salesDetail['Itemname'];
          String category = salesDetail['category']; // Added category

          // Check if the category matches the selected category
          if (category == ProductCategoryController.text) {
            double qty = double.parse(salesDetail['qty']);
            double amount = double.parse(salesDetail['amount']);

            // If item name already exists, add quantity and amount
            if (aggregatedData.containsKey(itemName)) {
              aggregatedData[itemName]!['qty'] += qty;
              aggregatedData[itemName]?['amount'] += amount;
            } else {
              // Otherwise, create new entry
              aggregatedData[itemName] = {
                'qty': qty,
                'amount': amount,
              };
            }
          }
        }
      }

      // Convert aggregated data to list format for display
      List<Map<String, dynamic>> aggregatedList = [];
      aggregatedData.forEach((itemName, data) {
        aggregatedList.add({
          'Itemname': itemName,
          'qty': data['qty'],
          'amount': data['amount'],
        });
      });

      // Update state with aggregated data
      setState(() {
        tableData = aggregatedList;
      });
    } else {
      throw Exception('Failed to load data');
    }
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

  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget ProductCategoryDropdown() {
    String startDt = _startdateController.text;
    String endDt = _enddateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDt);

    String foramtedletterstartdt = DateFormat('d MMMM,yyyy').format(startDate);
    String foramtedletterenddt = DateFormat('d MMMM,yyyy').format(endDate);
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
                _selectedIndex = currentIndex + 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex - 1];
                _filterEnabled = false;
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
              _filterEnabled = false;
            });
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
              _filterEnabled = true;
              ProductcategoyselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
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
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
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
        onSuggestionSelected: (suggestion) async {
          setState(() {
            ProductCategoryController.text = suggestion;
            ProductcategoyselectedValue = suggestion;
            _filterEnabled = false;
          });
          await logreports(
              "SalesProductCountReport: Category-${ProductCategoryController.text}_${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");

          await fetchproductnamecategory(ProductCategoryController.text);
          double totalAmount = getCategoryTotalAmount(tableData);
          TotalAmountController.text = totalAmount.toString();
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

  double getCategoryTotalAmount(List<Map<String, dynamic>> tableData) {
    double totalAmount = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['amount'].toString()) ?? 0.0;
      totalAmount += quantity;
    }
    totalAmount = double.parse(totalAmount.toStringAsFixed(2));

    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = getCategoryTotalAmount(tableData);
    TotalAmountController.text = totalAmount.toString();
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
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
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Product Count Report',
                            style: HeadingStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.start,
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
                          SizedBox(
                            width: 5,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: Responsive.isMobile(context) ? 0 : 27.0,
                                left: Responsive.isMobile(context) ? 10 : 0),
                            child: ElevatedButton(
                              onPressed: () {
                                fetchDateWiseSales();
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
                      SingleChildScrollView(
                        scrollDirection: Responsive.isMobile(context)
                            ? Axis.horizontal
                            : Axis.vertical,
                        child: Padding(
                          padding: Responsive.isMobile(context)
                              ? EdgeInsets.only(top: 15.0, right: 30)
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
                                    if (value == false) {
                                      ProductcategoyselectedValue = '';
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
                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      List<Map<String, dynamic>> filteredData =
                                          getFilteredData(tableData);
                                      List<List<dynamic>> convertedData =
                                          filteredData
                                              .map((map) => map.values.toList())
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
                              tableView(),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    child: Text(
                                        "Total Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(double.tryParse(TotalAmountController.text ?? '0') ?? 0)} /-",
                                        style: textStyle),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
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

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 320,
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
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
                                child: Text("Item",
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
                                child: Text("Qty",
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
                        var Itemname = data['Itemname'].toString();
                        var qty = data['qty'].toString();
                        var amount = data['amount'].toString();

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
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(Itemname,
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
                                      color: Color.fromARGB(255, 226, 225, 225),
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
        ..setAttribute(
            'download', 'ProductSalesCountReport ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel ProductSalesCountReport ($formattedDate).xlsx'
          : '$path/Excel ProductSalesCountReport ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
