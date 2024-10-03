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
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io' as io;
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(VendorSalesReport());
}

class VendorSalesReport extends StatefulWidget {
  @override
  State<VendorSalesReport> createState() => _VendorSalesReportState();
}

class _VendorSalesReportState extends State<VendorSalesReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    fetchSalesCustomer();
    filteredData = List.from(tableData);
  }

  void filterData() {
    filteredData = tableData.where((item) {
      bool nameFilter = true;
      if (selectedCusName != null && selectedCusName!.isNotEmpty) {
        nameFilter = item['vendorname'].toString().contains(selectedCusName!);
      }
      return nameFilter;
    }).toList();

    setState(() {});
  }

  List<String> getDisplayedColumns() {
    return [
      'billno',
      'dt',
      'cusname',
      'paidamount',
      'discount',
      'disperc',
      'amount',
      'vendorcomPerc',
      'CommisionAmt',
      'TotalAmount'
    ];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData) {
    List<String> displayedColumns = getDisplayedColumns();
    return tableData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
  }

  List<String> CustomerList = [];

  Future<void> fetchSalesCustomer() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/VendorsName/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          CustomerList.addAll(
              results.map<String>((item) => item['Name'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> fetchdatewiseVendorsales() async {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    endDate = endDate.add(Duration(days: 1));

    String foramtedletterstartdt = DateFormat('yyyy-MM-dd').format(startDate);
    String foramtedletterenddt = DateFormat('yyyy-MM-dd').format(endDate);
    String? cusid = await SharedPrefs.getCusId();
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseVendorSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        tableData = List<Map<String, dynamic>>.from(jsonData);
      });
      logreports(
          "VendorSales: ${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");
    } else {
      throw Exception('Failed to load data');
    }
  }

  double getAmount() {
    double total = 0.0;
    for (var data in tableData) {
      double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
      total += amount;
    }
    return total;
  }

  double getVendorCommisionAmount() {
    double total = 0.0;
    for (var data in tableData) {
      double CommisionAmt =
          double.tryParse(data['CommisionAmt'].toString()) ?? 0.0;
      total += CommisionAmt;
    }
    return total;
  }

  double getVendorCommisionPerc() {
    double total = 0.0;
    for (var data in tableData) {
      double CommisionPerc =
          double.tryParse(data['vendorcomPerc'].toString()) ?? 0.0;
      total += CommisionPerc;
    }
    return total;
  }

  double getTotalAmount() {
    double total = 0.0;
    for (var data in tableData) {
      double TotalAmount =
          double.tryParse(data['TotalAmount'].toString()) ?? 0.0;
      total += TotalAmount;
    }
    return total;
  }

  double getDiscountAmount() {
    double total = 0.0;
    for (var data in tableData) {
      double discount = double.tryParse(data['discount'].toString()) ?? 0.0;
      total += discount;
    }
    return total;
  }

  bool isChecked = false;
  late DateTime selectedStartDate;
  TextEditingController _StartDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  TextEditingController _EndDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selectedEndDate;

  @override
  Widget build(BuildContext context) {
    double Amount = getAmount();
    double CommisionAmt = getVendorCommisionAmount();
    double TotalAmount = getTotalAmount();
    double VendorComPerc = getVendorCommisionPerc();
    double discountAmt = getDiscountAmount();

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
                              'Vendor Sales Summary',
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
                                            height: 30, // Set the height here
                                            child: DateTimePicker(
                                              controller: _StartDateController,
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
                                              controller: _EndDateController,
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
                            width: 8,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: Responsive.isDesktop(context) ? 27.0 : 0,
                                left: Responsive.isDesktop(context) ? 0 : 10),
                            child: ElevatedButton(
                              onPressed: () {
                                isFilterActive = false;
                                fetchdatewiseVendorsales();
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
                        scrollDirection: Responsive.isDesktop(context)
                            ? Axis.vertical
                            : Axis.horizontal,
                        child: Padding(
                          padding: Responsive.isMobile(context)
                              ? EdgeInsets.only(top: 15.0)
                              : EdgeInsets.only(top: 0.0, right: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: isChecked,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  height: 29,
                                  width: 160,
                                  child: CustomerNamedropdown(),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                                activeColor: subcolor,
                              ),
                              Text(
                                'Name Wise',
                                style: textStyle,
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
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                    ),
                                    child: Text(
                                      "Amount: ₹ $Amount",
                                      style: textStyle,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                    ),
                                    child: Text(
                                      "Dis Amount: ₹ $discountAmt",
                                      style: textStyle,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Excel

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

                                      // // PDF
                                      // List<String> columnNames =
                                      //     tableData.isNotEmpty
                                      //         ? tableData.first.keys.toList()
                                      //         : [];
                                      // createPDF(columnNames, tableData);
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
                                ],
                              ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              tableView(),
                              SizedBox(height: 20),
                              Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 5,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        top: Responsive.isMobile(context)
                                            ? 10
                                            : 0),
                                    child: Text(
                                      "Commission: $VendorComPerc %",
                                      style: textStyle,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        top: Responsive.isMobile(context)
                                            ? 10
                                            : 0),
                                    child: Text(
                                      "Commision Amt: ₹ $CommisionAmt",
                                      style: textStyle,
                                    ),
                                  ),
                                  if (Responsive.isMobile(context))
                                    SizedBox(
                                      width: 50,
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        top: Responsive.isMobile(context)
                                            ? 10
                                            : 0),
                                    child: Text(
                                      "Total: ₹ $TotalAmount",
                                      style: textStyle,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: [],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.keyboard_arrow_left),
                                      onPressed: hasPreviousPage
                                          ? () => loadPreviousPage()
                                          : null,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '$currentPage / $totalPages',
                                      style: commonLabelTextStyle,
                                    ),
                                    SizedBox(width: 5),
                                    IconButton(
                                      icon: Icon(Icons.keyboard_arrow_right),
                                      onPressed: hasNextPage
                                          ? () => loadNextPage()
                                          : null,
                                    ),
                                  ],
                                ),
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

  //Prodname
  TextEditingController _CusnameController = TextEditingController();
  late FocusNode _CusNamefocusNode;
  bool _isCusNameOptionsVisible = false;
  String? selectedCusName;

  int? _selectedVendorIndex;
  bool _VendNamefilterEnabled = true;
  int? _VendNamehoveredIndex;

  Widget CustomerNamedropdown() {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    endDate = endDate.add(Duration(days: 1));

    String foramtedletterstartdt = DateFormat('d MMMM,yyyy').format(startDate);
    String foramtedletterenddt = DateFormat('d MMMM,yyyy').format(endDate);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = CustomerList.indexOf(_CusnameController.text);
            if (currentIndex < CustomerList.length - 1) {
              setState(() {
                _selectedVendorIndex = currentIndex + 1;
                _CusnameController.text = CustomerList[currentIndex + 1];
                _VendNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = CustomerList.indexOf(_CusnameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedVendorIndex = currentIndex - 1;
                _CusnameController.text = CustomerList[currentIndex - 1];
                _VendNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          textInputAction: TextInputAction.next,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedCusName = suggestion;
              _CusnameController.text = suggestion!;
              _VendNamefilterEnabled = false;
            });
          },
          controller: _CusnameController,
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
              _VendNamefilterEnabled = true;
              selectedCusName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_VendNamefilterEnabled && pattern.isNotEmpty) {
            return CustomerList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return CustomerList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = CustomerList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _VendNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _VendNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedVendorIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedVendorIndex == null &&
                          CustomerList.indexOf(_CusnameController.text) == index
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
          // debugPrint('You just selected $value');
          setState(() {
            selectedCusName = suggestion;
            _CusnameController.text = suggestion!;
            _VendNamefilterEnabled = false;
            isFilterActive = true;
          });

          try {
            filterData();
            logreports(
                "VendorSales: VendorName-${_CusnameController.text}_${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");
          } catch (e) {
            print('Error in onSuggestionSelected: $e');
          }
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

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchdatewiseVendorsales();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchdatewiseVendorsales();
  }

  bool isFilterActive = false;

  Widget tableView() {
    var currentData = isFilterActive ? filteredData : tableData;
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
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 750,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.5),
                  //     spreadRadius: 2,
                  //     blurRadius: 5,
                  //     offset: Offset(0, 3),
                  //   ),
                  // ],
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
                                        "Date",
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
                                        "Name",
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
                                        "PaidAmt",
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
                                        "DisAmt",
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
                                        "DisPerc",
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
                                        "Perc",
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
                                        "Commision",
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
                                        "Total",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle,
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
                              var BillNo = data['billno'].toString();
                              var Date = data['dt'].toString();
                              var Customers = data['vendorname'].toString();
                              var paidamount = data['paidamount'].toString();
                              var disAmt = data['discount'].toString();
                              var disperc = data['disperc'].toString();
                              var amount = data['amount'].toString();
                              var vendorcomPerc =
                                  data['vendorcomPerc'].toString();
                              var CommisionAmt =
                                  data['CommisionAmt'].toString();
                              var TotalAmount = data['TotalAmount'].toString();

                              bool isEvenRow = index % 2 == 0;
                              Color rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onDoubleTap: () {
                                  _showDetailsForm(data);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0,
                                      right: 0,
                                      top: 5.0,
                                      bottom: 5.0),
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
                                            child: Text(BillNo,
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
                                            child: Text(Customers,
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
                                            child: Text(disAmt,
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
                                            child: Text(disperc,
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
                                            child: Text(vendorcomPerc,
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
                                            child: Text(CommisionAmt,
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
                                            child: Text(TotalAmount,
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
          ..setAttribute('download', 'VendorSalesReport ($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel VendorSalesReport ($formattedDate).xlsx'
            : '$path/Excel VendorSalesReport ($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }

  Future<void> createPDF(
      List<String> columnNames, List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: columnNames
                  .map((columnName) => pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text(columnName,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: pw.EdgeInsets.all(5),
                      ))
                  .toList(),
            ),
            // Data rows
            ...data.map((row) => pw.TableRow(
                  children: columnNames
                      .map((columnName) => pw.Container(
                            alignment: pw.Alignment.center,
                            child: pw.Text(row[columnName].toString()),
                            padding: pw.EdgeInsets.all(5),
                          ))
                      .toList(),
                ))
          ],
        );
      },
    ));

    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "TableData.pdf")
        ..click();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/TableData.pdf';
      final io.File file = io.File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (io.Platform.isWindows) {
        io.Process.run('explorer.exe', [filePath]);
      }
    }
  }

  void _showDetailsForm(Map<String, dynamic> rowData) {
    List<dynamic> SalesDetails = jsonDecode(rowData['SalesDetails']);
    double discount =
        double.tryParse(rowData['discount']?.toString() ?? '0') ?? 0.0;
    double cgst = double.tryParse(rowData['totcgst']?.toString() ?? '0') ?? 0.0;
    double sgst = double.tryParse(rowData['totsgst']?.toString() ?? '0') ?? 0.0;

    double totalAmount = 0.0;
    double TaxableAmount = 0.0;

    List<Widget> itemRows = [];

    for (var order in SalesDetails) {
      if (order['billno'] == rowData['billno'].toString()) {
        String itemName = order['Itemname'];
        double rate = (order['rate'] as num).toDouble();
        double qty = (order['qty'] as num).toDouble();
        double totalAmt = (order['amount'] as num).toDouble();
        double taxable = (order['retail'] as num).toDouble();

        itemRows.add(
          Padding(
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
                      color: Colors.white,
                      border:
                          Border.all(color: Color.fromARGB(255, 226, 225, 225)),
                    ),
                    child: Center(
                      child: Text(itemName,
                          textAlign: TextAlign.center,
                          style: commonLabelTextStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Color.fromARGB(255, 226, 225, 225)),
                    ),
                    child: Center(
                      child: Text(rate.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Color.fromARGB(255, 226, 225, 225)),
                    ),
                    child: Center(
                      child: Text(qty.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Color.fromARGB(255, 226, 225, 225)),
                    ),
                    child: Center(
                      child: Text(totalAmt.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        totalAmount += totalAmt;
        TaxableAmount += taxable;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Details', style: HeadingStyle),
              Spacer(),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.numbers,
                                    size: 16, color: Colors.black),
                                Text.rich(
                                  TextSpan(
                                    text: 'Count : ',
                                    style: textStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: SalesDetails.length.toString(),
                                          style: commonLabelTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.receipt,
                                        size: 16, color: Colors.black),
                                    Text.rich(
                                      TextSpan(
                                        text: 'BillNo : ',
                                        style: textStyle,
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '${rowData['billno']}',
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(color: subcolor),
                                  child: Center(
                                    child: Text('ItemName',
                                        textAlign: TextAlign.center,
                                        style: commonWhiteStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(color: subcolor),
                                  child: Center(
                                    child: Text("Rate",
                                        textAlign: TextAlign.center,
                                        style: commonWhiteStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(color: subcolor),
                                  child: Center(
                                    child: Text("Qty",
                                        textAlign: TextAlign.center,
                                        style: commonWhiteStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(color: subcolor),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: itemRows,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 16, color: Colors.black),
                          Text.rich(
                            TextSpan(
                              text: ' TaxableAmt: ',
                              style: textStyle,
                              children: <TextSpan>[
                                TextSpan(
                                    text: TaxableAmount.toString(),
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.money_off, size: 16, color: Colors.black),
                          Text.rich(
                            TextSpan(
                              text: 'Dis ₹ :',
                              style: textStyle,
                              children: <TextSpan>[
                                TextSpan(
                                    text: discount.toString(),
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on,
                              size: 16, color: Colors.black),
                          Text.rich(
                            TextSpan(
                              text: 'Total: ',
                              style: textStyle,
                              children: <TextSpan>[
                                TextSpan(
                                    text: totalAmount.toString(),
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.money, size: 16, color: Colors.black),
                        Text.rich(
                          TextSpan(
                            text: ' CGST: ',
                            style: textStyle,
                            children: <TextSpan>[
                              TextSpan(
                                  text: cgst.toString(),
                                  style: commonLabelTextStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Row(
                      children: [
                        Icon(Icons.money, size: 16, color: Colors.black),
                        Text.rich(
                          TextSpan(
                            text: ' SGST: ',
                            style: textStyle,
                            children: <TextSpan>[
                              TextSpan(
                                  text: sgst.toString(),
                                  style: commonLabelTextStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
