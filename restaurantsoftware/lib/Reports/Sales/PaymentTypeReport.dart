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
  runApp(PaymentTypeReport());
}

class PaymentTypeReport extends StatefulWidget {
  @override
  State<PaymentTypeReport> createState() => _PaymentTypeReportState();
}

class _PaymentTypeReportState extends State<PaymentTypeReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  String? selectedproduct;

  @override
  void initState() {
    super.initState();
    fetchPaymenttype();
  }

  TextEditingController PaymentTypeController = TextEditingController();
  TextEditingController TableCountController = TextEditingController();
  TextEditingController TableTotalAmtController = TextEditingController();

  TextEditingController _enddateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController _startdateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  List<String> getDisplayedColumns() {
    return ['billno', 'dt', 'count', 'discount', 'finalamount', 'paytype'];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData, String searchText) {
    // Get the columns that should be displayed
    List<String> displayedColumns = getDisplayedColumns();

    // First filter the data based on the search text for 'paytype'
    List<Map<String, dynamic>> filteredData = tableData.where((data) {
      String paytype = (data['paytype'] ?? '').toLowerCase();
      return paytype.contains(searchText.toLowerCase());
    }).toList();

    // Then filter the columns to only include those that should be displayed
    return filteredData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
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

      // print('All PaymentTypeList: $PaymentTypeList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? PaymentTypeSelectedValue;

  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget PaymentTypeDropdown() {
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
                _selectedIndex = currentIndex + 1;
                PaymentTypeController.text = PaymentTypeList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                PaymentTypeController.text = PaymentTypeList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: PaymentTypeController,
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
              PaymentTypeSelectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
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
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
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
            _filterEnabled = false;
          });
          await fetchdatewisesales();
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

  Future<void> fetchdatewisesales() async {
    String startdt = _startdateController.text;
    String enddt = _enddateController.text;
    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    // Format the dates to string
    String foramtedletterstartdt = DateFormat('d MMMM,yyyy').format(startDate);
    String foramtedletterenddt = DateFormat('d MMMM,yyyy').format(endDate);
    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    // Format the dates to string
    String? cusid = await SharedPrefs.getCusId();
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    // print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // Filter the jsonData based on payment type
      final filteredData = jsonData
          .where((data) => data['paytype'] == PaymentTypeController.text)
          .toList();
      await logreports(
          "SalesPaytypeReport: ${PaymentTypeController.text}_${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");

      setState(() {
        tableData = List<Map<String, dynamic>>.from(filteredData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  int getTableRowCount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
  }

  double gettableamount(List<Map<String, dynamic>> tableData) {
    double totalAmount = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['finalamount'].toString()) ?? 0.0;
      totalAmount += quantity;
    }
    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    // print("total amtttt : $totalAmount");
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    int totalcount = getTableRowCount(tableData);
    TableCountController.text = totalcount.toString();
    double totalAmount = gettableamount(tableData);
    TableTotalAmtController.text = totalAmount.toString();
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
                          Text('Payment Type', style: HeadingStyle),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
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
                          _comboAndButtondesktop(),
                        ],
                      ),
                      _comboAndButtonMobile(),
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.payment,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            "Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TableTotalAmtController.text ?? '0') ?? 0)} /-",
                                            style: textStyle),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      List<Map<String, dynamic>> filteredData =
                                          getFilteredData(
                                              tableData, searchText);
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
                                  if (Responsive.isDesktop(context))
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
                              SizedBox(
                                height: 10.0,
                              ),
                              tableView(),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    child: Text(
                                        "Count: ${TableCountController.text}",
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
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 320,
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
                                      child: Text("Discount",
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
                                      child: Text("PayType",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tableData.isNotEmpty)
                            ...tableData.map((data) {
                              var billno = data['billno'].toString();
                              var dt = data['dt'].toString();
                              var count = data['count'].toString();
                              var discount = data['discount'].toString();
                              var finalamount = data['finalamount'].toString();
                              var paytype = data['paytype'].toString();
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
                                          child: Text(discount,
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
                                          child: Text(finalamount,
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
          ),
        ],
      ),
    );
  }

  Widget _comboAndButtondesktop() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay Type',
                      style: commonLabelTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 27,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Container(child: PaymentTypeDropdown()),
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
                    fetchdatewisesales();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subcolor,
                    minimumSize: Size(10, 30),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ],
    );
  }

  Widget _comboAndButtonMobile() {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Column(
        children: [
          if (Responsive.isMobile(context))
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay Type',
                        style: commonLabelTextStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 27,
                          width: 150,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(0, 255, 255, 255),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(child: PaymentTypeDropdown()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: ElevatedButton(
                    onPressed: () {
                      fetchdatewisesales();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subcolor,
                      minimumSize: Size(10, 30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
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
        ..setAttribute('download', 'PaymentType_Report ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel PaymentType_Report ($formattedDate).xlsx'
          : '$path/Excel PaymentType_Report ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
