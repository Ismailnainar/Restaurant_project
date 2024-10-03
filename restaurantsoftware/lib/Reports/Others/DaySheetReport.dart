import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

void main() {
  runApp(DaysheetReport());
}

class DaysheetReport extends StatefulWidget {
  @override
  State<DaysheetReport> createState() => _DaysheetReportState();
}

class _DaysheetReportState extends State<DaysheetReport> {
  List<Map<String, dynamic>> IncometableData = [];
  List<Map<String, dynamic>> ExpensetableData = [];

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
  }

  Future<void> fetchdatewiseIncome() async {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    endDate = endDate.add(Duration(days: 1));

    String? cusid = await SharedPrefs.getCusId();
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DateWiseIncomeReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        IncometableData = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchdatewiseExpense() async {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    endDate = endDate.add(Duration(days: 1));

    String? cusid = await SharedPrefs.getCusId();
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DateWiseExpenseReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        ExpensetableData = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  double getIncomeAmount() {
    double Income = 0.0;
    for (var data in IncometableData) {
      double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
      Income += amount;
    }
    return Income;
  }

  double getExpenseAmount() {
    double Expense = 0.0;
    for (var data in ExpensetableData) {
      double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
      Expense += amount;
    }
    return Expense;
  }

  late DateTime selectedEndDate;
  late DateTime selectedStartDate;

  TextEditingController _StartDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController _EndDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    double IncomeAmount = getIncomeAmount();
    double ExpenseAmount = getExpenseAmount();
    double BalanceAmt = IncomeAmount - ExpenseAmount;
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
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              'Daysheet Summary',
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
                                top: Responsive.isDesktop(context) ? 30.0 : 0,
                                left: Responsive.isDesktop(context) ? 0 : 10),
                            child: ElevatedButton(
                              onPressed: () {
                                fetchdatewiseIncome();
                                fetchdatewiseExpense();
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
                                size: 20,
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
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.start,
                                      runSpacing: 5,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            "Total Income: ₹ $IncomeAmount",
                                            style: textStyle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            "Total Expense: ₹ $ExpenseAmount",
                                            style: textStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Column(
                                children: [
                                  if (Responsive.isDesktop(context))
                                    tableViewDeskTop(),
                                  if (Responsive.isMobile(context))
                                    tableViewMobile()
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    child: Text(
                                      "Balance: ₹ $BalanceAmt",
                                      style: textStyle,
                                    ),
                                  ),
                                ],
                              ),
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
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
              width: Responsive.isDesktop(context) ? 550 : 430,
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
                                width: 400.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Description",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 400.0,
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
                          ],
                        ),
                      ),
                      if (IncometableData.isNotEmpty)
                        ...IncometableData.map((data) {
                          var description = data['description'].toString();
                          var amount = data['amount'].toString();
                          bool isEvenRow =
                              IncometableData.indexOf(data) % 2 == 0;
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
                                    width: 400.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(description,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 400.0,
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
                                    width: 100, // Adjust width as needed
                                    height: 100, // Adjust height as needed
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
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
              width: Responsive.isDesktop(context) ? 600 : 500,
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
                                width: 400.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cat",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 400.0,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Description",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: 400.0,
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
                          ],
                        ),
                      ),
                      if (ExpensetableData.isNotEmpty)
                        ...ExpensetableData.map((data) {
                          var cat = data['cat'].toString();
                          var description = data['description'].toString();
                          var amount = data['amount'].toString();

                          bool isEvenRow =
                              IncometableData.indexOf(data) % 2 == 0;
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
                                    width: 400.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        cat,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 400.0,
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 226, 225, 225),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        description,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    width: 400.0,
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
                                    width: 100, // Adjust width as needed
                                    height: 100, // Adjust height as needed
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
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? 345 : 350,
              width: 430,
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Income Details..',
                          style: textStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                                    "Description",
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
                          ],
                        ),
                      ),
                      if (IncometableData.isNotEmpty)
                        ...IncometableData.map((data) {
                          var description = data['description'].toString();
                          var amount = data['amount'].toString();
                          bool isEvenRow =
                              IncometableData.indexOf(data) % 2 == 0;
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
                                      child: Text(
                                        description,
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
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
          child: SingleChildScrollView(
            child: Container(
              height: Responsive.isDesktop(context) ? 345 : 350,
              width: 500,
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Expense Details..',
                          style: textStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                                    "Cat",
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
                                    "Description",
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
                          ],
                        ),
                      ),
                      if (ExpensetableData.isNotEmpty)
                        ...ExpensetableData.map((data) {
                          var cat = data['cat'].toString();
                          var description = data['description'].toString();
                          var amount = data['amount'].toString();

                          bool isEvenRow =
                              IncometableData.indexOf(data) % 2 == 0;
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
                                      child: Text(cat,
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
                                      child: Text(description,
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
  }
}
