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
  runApp(WastageReport());
}

class WastageReport extends StatefulWidget {
  @override
  State<WastageReport> createState() => _WastageReportState();
}

class _WastageReportState extends State<WastageReport> {
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
    fetchEmployeeName();
    filteredData = List.from(tableData);
  }

  void filterData() {
    String selectedEmployeeName = _EmployeeController.text.trim();

    // Filter the data based on date and employee name
    filteredData = tableData.where((item) {
      bool nameFilter = true;
      if (selectedEmployeeName != null && selectedEmployeeName!.isNotEmpty) {
        nameFilter =
            item['agentname'].toString().contains(selectedEmployeeName!);
      }

      return nameFilter;
    }).toList();

    setState(() {});
  }

  Future<List<Map<String, dynamic>>> getFilteredDataAsync(
      List<Map<String, dynamic>> tableData) async {
    List<Map<String, dynamic>> filteredData = [];
    for (var row in tableData) {
      List<dynamic> wastageDetails = row['WastageDetails'] != null
          ? jsonDecode(row['WastageDetails'])
          : [];

      String productname = '';
      double qty = 0;
      double amount = 0;

      if (wastageDetails.isNotEmpty) {
        productname = wastageDetails[0]['productname'] ?? '';
        qty = wastageDetails[0]['qty'] ?? 0;

        // Fetch the amount for each product
        String? fetchedAmount = await fetchamountByName(productname);
        amount = double.tryParse(fetchedAmount ?? '0') ?? 0;
      }

      double finalamount = qty * amount;

      filteredData.add({
        'id': row['id'],
        'agentname': row['agentname'],
        'date': row['date'],
        'productname': productname,
        'qty': qty,
        'amount': amount,
        'finalamount': finalamount
      });
    }
    return filteredData;
  }

  List<String> getDisplayedColumns() {
    return [
      'id',
      'agentname',
      'date',
      'productname',
      'qty',
      'amount',
      'finalamount'
    ];
  }

  List<String> EmployeeNameList = [];

  Future<void> fetchEmployeeName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/StaffDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          EmployeeNameList.addAll(
              results.map<String>((item) => item['serventname'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $EmployeeNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> fetchdatewiseWastage() async {
    try {
      String startdt = _StartDateController.text;
      String enddt = _EndDateController.text;

      if (startdt.isEmpty || enddt.isEmpty) {
        throw Exception('Start date and end date cannot be empty');
      }

      DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
      DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

      endDate = endDate.add(Duration(days: 1));

      String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      print("Start date = $formattedStartDate, End date = $formattedEndDate");

      String? cusid = await SharedPrefs.getCusId();

      String formatedlogreportstartdt =
          DateFormat('d MMMM,yyyy').format(startDate);
      String formatedlogreportenddt = DateFormat('d MMMM,yyyy').format(endDate);
      if (cusid == null) {
        throw Exception('Customer ID is null');
      }

      final response = await http.get(Uri.parse(
        '$IpAddress/DateWiseWastageReport/$cusid/$formattedStartDate/$formattedEndDate/',
      ));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        await logreports(
            "WastageReports: ${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");
        setState(() {
          tableData = List<Map<String, dynamic>>.from(jsonData);
        });
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch data: $e'),
      ));
    }
  }

  bool isChecked = false;
  late DateTime selectedStartDate;

  TextEditingController _StartDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
  TextEditingController _EndDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

  late DateTime selectedEndDate;

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
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              'Wastage Report',
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
                                              controller: _StartDateController,
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
                                fetchdatewiseWastage();
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
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      List<Map<String, dynamic>> filteredData =
                                          await getFilteredDataAsync(tableData);
                                      List<List<dynamic>> convertedData =
                                          filteredData.map((map) {
                                        return [
                                          map['id'],
                                          map['agentname'],
                                          map['date'],
                                          map['productname'],
                                          map['qty'],
                                          map['amount'],
                                          map['finalamount']
                                        ];
                                      }).toList();

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
                                        Text(
                                          "Export",
                                          style: commonWhiteStyle,
                                        ),
                                      ],
                                    ),
                                  )
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

  // Employee Name

  TextEditingController _EmployeeController = TextEditingController();
  bool _isEmployeeNameOptionsVisible = false;
  String? selectedEmployeeName;

  int? _selectedEmpIndex;

  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget CustomerNamedropdown() {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    String formatedlogreportstartdt =
        DateFormat('d MMMM,yyyy').format(startDate);
    String formatedlogreportenddt = DateFormat('d MMMM,yyyy').format(endDate);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                EmployeeNameList.indexOf(_EmployeeController.text);
            if (currentIndex < EmployeeNameList.length - 1) {
              setState(() {
                _selectedEmpIndex = currentIndex + 1;
                _EmployeeController.text = EmployeeNameList[currentIndex + 1];
                _filterEnabled = false;
                isFilterActive = true;
              });
              try {
                logreports(
                    "WastageReports: CustomerNameWise-${_EmployeeController.text}_${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");

                filterData();
              } catch (e) {
                print('Error in onSuggestionSelected: $e');
              }
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                EmployeeNameList.indexOf(_EmployeeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedEmpIndex = currentIndex - 1;
                _EmployeeController.text = EmployeeNameList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _EmployeeController,
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
              selectedEmployeeName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return EmployeeNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return EmployeeNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = EmployeeNameList.indexOf(suggestion);
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
                          EmployeeNameList.indexOf(_EmployeeController.text) ==
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
        onSuggestionSelected: (suggestion) {
          setState(() {
            _EmployeeController.text = suggestion;
            selectedEmployeeName = suggestion;
            _filterEnabled = false;
            isFilterActive = true;
          });
          try {
            logreports(
                "WastageReports: CustomerNameWise-${_EmployeeController.text}_${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");
            filterData();
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
    fetchdatewiseWastage();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchdatewiseWastage();
  }

  bool isFilterActive = false;

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    var currentData = isFilterActive ? filteredData : tableData;

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
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 320,
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 600,
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
                                    width: 300.0,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Id",
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
                                      child: Text("Worker",
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
                                      child: Text("ProductName",
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
                                      child: Text("Date",
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
                                      child: Text("Total",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
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
                              var id = data['id'].toString();
                              var agentname =
                                  data['agentname']?.toString() ?? 'N/A';
                              var date = data['date']?.toString() ?? 'N/A';
                              var wastageDetails =
                                  data['WastageDetails'] != null
                                      ? jsonDecode(data['WastageDetails'])
                                      : [];

                              bool isEvenRow = index % 2 == 0;
                              Color rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 0.0, right: 0, top: 2.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (var detail in wastageDetails)
                                      Row(
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
                                                  id,
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
                                                  agentname,
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
                                                  detail['productname'],
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
                                                  date,
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
                                                  detail['qty'].toString(),
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
                                              child: FutureBuilder<String?>(
                                                future: fetchamountByName(
                                                    detail['productname']),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Center(
                                                      child: Text(
                                                        snapshot.data ??
                                                            'No Data',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle,
                                                      ),
                                                    );
                                                  }
                                                },
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
                                              child: FutureBuilder<String?>(
                                                future: fetchamountByName(
                                                    detail['productname']),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    double amount =
                                                        double.tryParse(snapshot
                                                                .data!) ??
                                                            0.0;
                                                    int qty =
                                                        detail['qty'] ?? 0;

                                                    // Calculate the total amount
                                                    double totalAmount =
                                                        amount * qty;

                                                    return Center(
                                                      child: Text(
                                                        totalAmount.toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TableRowTextStyle,
                                                      ),
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                      child: Text(
                                                        'Error: ${snapshot.error}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: textStyle,
                                                      ),
                                                    );
                                                  } else {
                                                    return Center();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
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

  String? amount;

  Future<String?> fetchamountByName(String productName) async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid';
      int page = 1;
      bool hasMorePages = true;

      while (hasMorePages) {
        String url = '$apiUrl?page=$page';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          final Map<String, dynamic>? productData = results.firstWhere(
            (item) => item['name'].toString() == productName,
            orElse: () => null,
          );

          if (productData != null) {
            return productData['amount'].toString();
          }

          page++;
          hasMorePages = data['next'] != null;
        } else {
          throw Exception('Failed to fetch stock: ${response.reasonPhrase}');
        }
      }

      return null;
    } catch (e) {
      print('Error fetching stock: $e');
      return null;
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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
          ..setAttribute('download', 'Wastage_Report ($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Wastage_Report ($formattedDate).xlsx'
            : '$path/Excel Wastage_Report ($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }
}
