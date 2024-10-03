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
  runApp(BillWiseSalesCountReport());
}

class BillWiseSalesCountReport extends StatefulWidget {
  @override
  State<BillWiseSalesCountReport> createState() =>
      _BillWiseSalesCountReportState();
}

class _BillWiseSalesCountReportState extends State<BillWiseSalesCountReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  String selectedValue = 'Ramya';
  bool isChecked = false;
  bool isCatChecked = false;
  String selectedCategory = '';
  @override
  void initState() {
    fetchProductWiseReport().then((_) {
      setState(() {
        filteredTableData = List.from(tableData); // Initialize with all data
      });
    });
    super.initState();
  }

  List<String> getDisplayedColumns() {
    return ['Date', 'Itemname', 'qty', 'amount', 'billNo', 'tableNo'];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData) {
    List<String> displayedColumns = getDisplayedColumns();
    return tableData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
  }

  TextEditingController _enddateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController _startdateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController discountAmtController = TextEditingController();
  TextEditingController totalAmtController = TextEditingController();
  TextEditingController FinalAmtController = TextEditingController();

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  Future<void> fetchDateWiseSales() async {
    String startDt = _startdateController.text;
    String endDt = _enddateController.text;

    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDt);

    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    // Format the dates to string
    String foramtedletterstartdt = DateFormat('d MMMM, yyyy').format(startDate);
    String foramtedletterenddt = DateFormat('d MMMM, yyyy').format(endDate);
    // Format the dates to string
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    // print("start date = $formattedStartDate end date = $formattedEndDate");

    String? cusid = await SharedPrefs.getCusId();
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Map to store aggregated data
      Map<String, Map<String, dynamic>> aggregatedData = {};

      // Iterate through each sales entry
      for (var salesEntry in jsonData) {
        String billNo = salesEntry['billno'];
        String tableNo = salesEntry['tableno'] ?? 'null';
        String salesDate = salesEntry['dt'];

        // Iterate through each sales detail
        for (var salesDetail in salesEntry['SalesDetails']) {
          String itemName = salesDetail['Itemname'];
          double qty = double.parse(salesDetail['qty']);
          double amount = double.parse(salesDetail['amount']);

          // Generate a unique key using date and item name
          String key = '$salesDate-$itemName';

          // If item name already exists for this date, add quantity and amount
          if (aggregatedData.containsKey(key)) {
            aggregatedData[key]!['qty'] += qty;
            aggregatedData[key]!['amount'] += amount;
            aggregatedData[key]!['billNos'].add(billNo);
            aggregatedData[key]!['tableNos'].add(tableNo);
          } else {
            // Otherwise, create new entry
            aggregatedData[key] = {
              'date': salesDate,
              'itemName': itemName,
              'qty': qty,
              'amount': amount,
              'billNos': [billNo],
              'tableNos': [tableNo],
            };
          }
        }
      }
      // Convert aggregated data to list format for display
      List<Map<String, dynamic>> aggregatedList = [];
      aggregatedData.forEach((key, data) {
        aggregatedList.add({
          'Date': data['date'],
          'Itemname': data['itemName'],
          'qty': data['qty'],
          'amount': data['amount'],
          'billNo': data['billNos'].join(','),
          'tableNo': data['tableNos'].join(','),
        });
      });
      await logreports(
          "SalesCountReport: ${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");

      // Update state with aggregated data
      setState(() {
        tableData = aggregatedList;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchtotamt() async {
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

    // print("start date = $formattedStartDate end date = $formattedEndDate");

    String? cusid = await SharedPrefs.getCusId();
    final url =
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        double totalDiscountAmt = 0;
        double totalAmount = 0;
        double totalFinalAmount = 0;

        for (var item in data) {
          totalDiscountAmt += double.parse(item['discount']);
          totalAmount += double.parse(item['amount']);
          totalFinalAmount += double.parse(item['finalamount']);
        }

        setState(() {
          discountAmtController.text = totalDiscountAmt.toString();
          totalAmtController.text = totalAmount.toString();
          FinalAmtController.text = totalFinalAmount.toString();
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  String? ProductcategoyselectedValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
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
                              'Sales Count Report',
                              style: HeadingStyle,
                            ),
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
                                fetchtotamt();
                                if (!isCatChecked) {
                                  // If checkbox is not checked, reset the filtered data
                                  setState(() {
                                    filteredTableData = List.from(tableData);
                                    isFilterActive =
                                        false; // Reset filter state
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: subcolor,
                                minimumSize: Size(10, 30),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                              ),
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
                                'ProductWise',
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
                          top: 20,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                          left: 7, right: 7, top: 3, bottom: 3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)

                                    ),
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
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: subcolor,
                                      padding: EdgeInsets.only(
                                          left: 7, right: 7, top: 3, bottom: 3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)

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
                              Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: Responsive.isDesktop(context)
                                          ? 20
                                          : 20,
                                    ),
                                    child: Text(
                                      "Discount Amount: ₹ ${discountAmtController.text}",
                                      style: textStyle,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: Responsive.isDesktop(context)
                                          ? 0
                                          : 10,
                                      left: Responsive.isDesktop(context)
                                          ? 20
                                          : 20,
                                    ),
                                    child: Text(
                                        "Total Amount: ₹ ${totalAmtController.text}",
                                        style: textStyle),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: Responsive.isDesktop(context)
                                          ? 0
                                          : 10,
                                      left: Responsive.isDesktop(context)
                                          ? 20
                                          : 20,
                                    ),
                                    child: Text(
                                        "Final Amount: ₹ ${FinalAmtController.text}",
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
            )
          ],
        ),
      ),
    );
  }

  List<String> ProductCategoryList = [];
  TextEditingController ProductCategoryController = TextEditingController();
  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  Future<void> fetchProductWiseReport() async {
    try {
      String startDt = _startdateController.text;
      String endDt = _enddateController.text;

      // Parse start and end dates
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDt);
      DateTime endDate =
          DateFormat('yyyy-MM-dd').parse(endDt).add(Duration(days: 1));

      String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      String? cusid = await SharedPrefs.getCusId();

      // Print the URL for debugging
      // print(
      //     'Fetching data from: $IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/');

      final response = await http.get(Uri.parse(
          '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Print the JSON response for debugging
        // print('Response data: $jsonData');

        // Clear the ProductCategoryList before adding new items
        ProductCategoryList.clear();

        // Iterate through each sales entry
        for (var salesEntry in jsonData) {
          for (var salesDetail in salesEntry['SalesDetails']) {
            String itemName = salesDetail['Itemname'];

            // Add item names to the ProductCategoryList if they don't already exist
            if (!ProductCategoryList.contains(itemName)) {
              ProductCategoryList.add(itemName);
            }
          }
        }

        // Print the updated ProductCategoryList
        // print('Updated ProductCategoryList: $ProductCategoryList');

        // Update the state to reflect the new items in the ProductCategoryList
        setState(() {
          // Ensuring the dropdown gets updated
        });
      } else {
        // Print the error message
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print any exceptions that occur
      print('Error fetching data: $e');
    }
  }

  List<Map<String, dynamic>> filteredTableData = [];
  void filterTableData(String selectedItem) {
    setState(() {
      filteredTableData = tableData.where((data) {
        return data['Itemname']
            .toString()
            .toLowerCase()
            .contains(selectedItem.toLowerCase());
      }).toList();
      isFilterActive = true; // Set filter active when filtering
    });
  }

  Widget ProductCategoryDropdown() {
    String startDt = _startdateController.text;
    String endDt = _enddateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDt);

    String formattedStartDt = DateFormat('d MMMM, yyyy').format(startDate);
    String formattedEndDt = DateFormat('d MMMM, yyyy').format(endDate);

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          int currentIndex =
              ProductCategoryList.indexOf(ProductCategoryController.text);
          if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
              currentIndex < ProductCategoryList.length - 1) {
            setState(() {
              _selectedIndex = currentIndex + 1;
              ProductCategoryController.text =
                  ProductCategoryList[currentIndex + 1];
              _filterEnabled = false;
            });
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
              currentIndex > 0) {
            setState(() {
              _selectedIndex = currentIndex - 1;
              ProductCategoryController.text =
                  ProductCategoryList[currentIndex - 1];
              _filterEnabled = false;
            });
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: ProductCategoryController,
          decoration: InputDecoration(
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
          onSubmitted: (String? suggestion) {
            if (suggestion != null) {
              setState(() {
                ProductcategoyselectedValue = suggestion;
                ProductCategoryController.text = suggestion;
                _filterEnabled = false;
                filterTableData(suggestion); // Directly filter table data
              });
            }
          },
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
                  : _hoveredIndex == index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
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
        onSuggestionSelected: (suggestion) async {
          setState(() {
            ProductCategoryController.text = suggestion;
            ProductcategoyselectedValue = suggestion;
            _filterEnabled = false;
            filterTableData(suggestion); // Call the filter function here
            isFilterActive = true; // Set filter active when an item is selected
          });

          await logreports(
              "SalesProductCountReport: Category-${ProductCategoryController.text}_${formattedStartDt} To ${formattedEndDt}_Viewed");
          await fetchProductWiseReport();
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

  bool isFilterActive = false;

  Widget tableView() {
    var currentData = isFilterActive ? filteredTableData : tableData;
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
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 300,
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 450,
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Date",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
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
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
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
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Amt",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Billno",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Table",
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
                          if (currentData.isNotEmpty)
                            ...currentData.asMap().entries.map((entry) {
                              int index = entry.key;

                              Map<String, dynamic> data = entry.value;
                              var Date = data['Date'].toString();
                              var Itemname = data['Itemname'].toString();
                              var qty = data['qty'].toString();
                              var amount = data['amount'].toString();
                              var billNo = data['billNo'].toString();
                              var tableNo = data['tableNo'].toString();
                              bool isEvenRow = index % 2 == 0;
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
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(Date,
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
                                          child: Text(amount,
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
                                          child: Text(billNo,
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
                                          child: Text(tableNo,
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
        ..setAttribute(
            'download', 'SalesCountReport_BillWise ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel SalesCountReport_BillWise ($formattedDate).xlsx'
          : '$path/Excel SalesCountReport_BillWise ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
