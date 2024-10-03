import 'dart:convert';
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
  runApp(AddStockDetailsReport());
}

class AddStockDetailsReport extends StatefulWidget {
  @override
  State<AddStockDetailsReport> createState() => _AddStockDetailsReportState();
}

class _AddStockDetailsReportState extends State<AddStockDetailsReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Stock_Details_Round/$cusid';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> Stocklist = [];

      for (var item in data) {
        int id = item['id'];
        String serialno = item['serialno'];
        String date = item['date'];
        String agentname = item['agentname'];
        String itemcount = item['itemcount'];
        String StockDetails = item['StockDetails'];

        Stocklist.add({
          'id': id,
          'serialno': serialno,
          'date': date,
          'agentname': agentname,
          'itemcount': itemcount,
          'StockDetails': StockDetails
        });
      }

      // Sort the data by 'id' in ascending order
      Stocklist.sort((a, b) => a['id'].compareTo(b['id']));

      setState(() {
        tableData = Stocklist;
      });
    }
  }

  List<String> getDisplayedColumns() {
    return [
      'id',
      'serialno',
      'date',
      'agentname',
      'itemcount',
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

  Future<void> fetchdatewiseStock() async {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    endDate = endDate.add(Duration(days: 1));

    String formatedlogreportstartdt =
        DateFormat('d MMMM,yyyy').format(startDate);
    String formatedlogreportenddt = DateFormat('d MMMM,yyyy').format(endDate);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    String? cusid = await SharedPrefs.getCusId();
    final response = await http.get(Uri.parse(
        '$IpAddress/DateWiseStockOverAllReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        tableData = List<Map<String, dynamic>>.from(jsonData);
      });
      await logreports(
          "OverallStockReport: ${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");
    } else {
      throw Exception('Failed to load data');
    }
  }

  TextEditingController _StartDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
  TextEditingController _EndDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  @override
  Widget build(BuildContext context) {
    String Total = tableData.length.toString();
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
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
                                'Add Stock Report',
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
                                                controller:
                                                    _StartDateController,
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
                                              height: 30, // Set the height here
                                              child: DateTimePicker(
                                                controller: _EndDateController,
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
                            SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Responsive.isDesktop(context) ? 27.0 : 0,
                                  left: Responsive.isDesktop(context) ? 0 : 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  fetchdatewiseStock();
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
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                      ),
                                      child: Text(
                                        "Total: $Total",
                                        style: textStyle,
                                      ),
                                    ),
                                    Spacer(),
                                    SizedBox(
                                      width: 6,
                                    ),
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
                                          Text("Export",
                                              style: commonWhiteStyle),
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
                                SizedBox(height: 10),
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
                                      Text('$currentPage / $totalPages',
                                          style: commonLabelTextStyle),
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
      ),
    );
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchData();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchData();
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
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 500,
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
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("ID",
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
                                      child: Text("SerialNo",
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
                                      child: Text("AgentName",
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
                                      child: Text("ItemCount",
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
                              var id = data['id'].toString();
                              var serialno = data['serialno'].toString();
                              var date = data['date'].toString();
                              var agentname = data['agentname'].toString();
                              var itemcount = data['itemcount'].toString();

                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
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
                                            child: Text(id,
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
                                            child: Text(serialno,
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
                                            child: Text(date,
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
                                            child: Text(agentname,
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
                                            child: Text(itemcount,
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

  void _showDetailsForm(Map<String, dynamic> rowData) {
    List<dynamic> stockDetails = jsonDecode(rowData['StockDetails']);
    List<Widget> itemRows = [];

    double TotQty = 0.0;

    for (var stock in stockDetails) {
      if (stock['serialno'] == rowData['serialno'].toString()) {
        String productname = stock['productname'];
        double qty = stock['qty'];
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
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text('${rowData['id']}',
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text('${rowData['serialno']}',
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text('${rowData['agentname']}',
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(productname,
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(qty.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        TotQty += qty;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                                    text: 'No.Of.Items : ',
                                    style: textStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: stockDetails.length.toString(),
                                        style: commonLabelTextStyle,
                                      ),
                                    ],
                                  ),
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
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text('ID',
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
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text('Sno',
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
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text('AgentName',
                                        style: commonWhiteStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text('ProdName',
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_box, size: 16, color: Colors.black),
                        Text.rich(
                          TextSpan(
                            text: 'Qty : ',
                            style: textStyle,
                            children: <TextSpan>[
                              TextSpan(
                                text: TotQty.toString(),
                                style: commonLabelTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(
                            left: 7, right: 7, top: 3, bottom: 3),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
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
        ..setAttribute('download', 'OverAllStock_Report ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel OverAllStock_Report ($formattedDate).xlsx'
          : '$path/Excel OverAllStock_Report ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
