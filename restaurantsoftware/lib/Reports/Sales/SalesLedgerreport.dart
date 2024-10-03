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
  runApp(SalesLedgerReport());
}

class SalesLedgerReport extends StatefulWidget {
  @override
  State<SalesLedgerReport> createState() => _SalesLedgerReportState();
}

class _SalesLedgerReportState extends State<SalesLedgerReport> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> OpenBaltableData = [];

  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  bool isCustomernamechecked = true;
  bool isDateChecked = false;
  bool isOverallChecked = false;

  double totalCredit = 0.0;
  double totalopenbalanceCredit = 0.0;
  double totalDebit = 0.0;
  // TextEditingController _enddateController = TextEditingController(
  //     text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  // TextEditingController _startdateController = TextEditingController(
  //     text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  // late DateTime selectedStartDate;
  // late DateTime selectedEndDate;

  TextEditingController _enddateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd')
          .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0)));

  TextEditingController _startdateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd')
          .format(DateTime(DateTime.now().year, DateTime.now().month, 1)));

  late DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime selectedEndDate =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  TextEditingController CustomerNamecontroller = TextEditingController();
  TextEditingController CustomerContactController = TextEditingController();

  TextEditingController TotSalesAmtController = TextEditingController();
  TextEditingController OpenBalAmtController = TextEditingController();

  TextEditingController TotPayAmtController = TextEditingController();
  TextEditingController BalanceController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCustomerName();
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

  String? customernameselectedValue;

  int? _selectedIndex;
  bool filterEnabled = true;
  int? _hoveredIndex;

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
                _selectedIndex = currentIndex + 1;
                CustomerNamecontroller.text =
                    CustomerNameList[currentIndex + 1];
                filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNamecontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                CustomerNamecontroller.text =
                    CustomerNameList[currentIndex - 1];
                filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          onSubmitted: (String? suggestion) async {
            setState(() {
              customernameselectedValue = suggestion;
              CustomerNamecontroller.text = suggestion!;
              filterEnabled = false;
            });

            await fetchCustomerContact();
            tableData = [];
            totalCredit = 0.0;
            totalDebit = 0.0;
            if (isCustomernamechecked == true) {
              await fetchData();
              await getTotSalesAmt(tableData);
              getTotPayAmt(tableData);
              getBalanceAmount(tableData);
            }
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
              filterEnabled = true;
              customernameselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (filterEnabled && pattern.isNotEmpty) {
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
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
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
            customernameselectedValue = suggestion;
            CustomerNamecontroller.text = suggestion!;
            filterEnabled = false;
          });

          await fetchCustomerContact();
          tableData = [];
          totalCredit = 0.0;
          totalDebit = 0.0;
          if (isCustomernamechecked == true) {
            await fetchData();
            await getTotSalesAmt(tableData);
            getTotPayAmt(tableData);
            getBalanceAmount(tableData);
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

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String customerName = CustomerNamecontroller.text;
    final url =
        Uri.parse('$IpAddress/CusnamewiseSalesReport/$cusid/$customerName');
    final response = await http.get(url);

    final paymenturl = Uri.parse(
        '$IpAddress/CusnamewiseSalesPaymentReport/$cusid/$customerName');
    final Paymentresponse = await http.get(paymenturl);
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      for (var data in responseData) {
        if (data['paidamount'] == data['finalamount']) {
          // Adding two rows for each billno where paidamount is 0
          tableData.add({
            'serialno': data['billno'],
            'dt': data['dt'],
            'Particular': 'Sales',
            'credit': data['finalamount'],
            'debit': '',
          });
          tableData.add({
            'serialno': data['billno'],
            'dt': data['dt'],
            'Particular': 'Sales Payment',
            'credit': '',
            'debit': data['finalamount'],
          });

          setState(() {});
        } else {
          tableData.add({
            'serialno': data['billno'],
            'dt': data['dt'],
            'Particular': 'Sales',
            'credit': data['finalamount'],
            'debit': '',
          });
        }
      }

      final List<dynamic> PaymentresponseData =
          jsonDecode(Paymentresponse.body);
      for (var data in PaymentresponseData) {
        tableData.add({
          'serialno': data['billno'],
          'dt': data['dt'],
          'Particular': 'Sales Payment',
          'credit': '',
          'debit': data['amount'],
        });

        setState(() {});
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDatewiseData(
      DateTime selectedStartDate, DateTime selectedEndDate) async {
    String? cusid = await SharedPrefs.getCusId();
    String customerName = CustomerNamecontroller.text;
    final url =
        Uri.parse('$IpAddress/CusnamewiseSalesReport/$cusid/$customerName');
    final response = await http.get(url);

    final paymenturl = Uri.parse(
        '$IpAddress/CusnamewiseSalesPaymentReport/$cusid/$customerName');
    final Paymentresponse = await http.get(paymenturl);

    if (response.statusCode == 200) {
      // Clear the existing data before adding filtered data

      final List<dynamic> responseData = jsonDecode(response.body);
      for (var data in responseData) {
        DateTime dataDate = DateTime.parse(data['dt']);

        // Check if dataDate is between selectedStartDate and selectedEndDate
        if ((dataDate.isAfter(selectedStartDate) ||
                dataDate.isAtSameMomentAs(selectedStartDate)) &&
            (dataDate.isBefore(selectedEndDate) ||
                dataDate.isAtSameMomentAs(selectedEndDate))) {
          if (data['paidamount'] == data['finalamount']) {
            // Adding two rows for each billno where paidamount is 0
            tableData.add({
              'serialno': data['billno'],
              'dt': data['dt'],
              'Particular': 'Sales',
              'credit': data['finalamount'],
              'debit': '',
            });
            tableData.add({
              'serialno': data['billno'],
              'dt': data['dt'],
              'Particular': 'Sales Payment',
              'credit': '',
              'debit': data['finalamount'],
            });
          } else {
            tableData.add({
              'serialno': data['billno'],
              'dt': data['dt'],
              'Particular': 'Sales',
              'credit': data['finalamount'],
              'debit': '',
            });
          }
        }
      }

      final List<dynamic> PaymentresponseData =
          jsonDecode(Paymentresponse.body);
      for (var data in PaymentresponseData) {
        DateTime dataDate = DateTime.parse(data['dt']);

        // Check if dataDate is between selectedStartDate and selectedEndDate
        if ((dataDate.isAfter(selectedStartDate) ||
                dataDate.isAtSameMomentAs(selectedStartDate)) &&
            (dataDate.isBefore(selectedEndDate) ||
                dataDate.isAtSameMomentAs(selectedEndDate))) {
          tableData.add({
            'serialno': data['billno'],
            'dt': data['dt'],
            'Particular': 'Sales Payment',
            'credit': '',
            'debit': data['amount'],
          });
        }
      }
      setState(() {});
      getTotSalesAmt(tableData);
      getTotPayAmt(tableData);
      getBalanceAmount(tableData);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchopenbalance(
      DateTime selectedStartDate, DateTime selectedEndDate) async {
    String? cusid = await SharedPrefs.getCusId();
    String customerName = CustomerNamecontroller.text;
    final url =
        Uri.parse('$IpAddress/CusnamewiseSalesReport/$cusid/$customerName');
    final response = await http.get(url);

    final paymenturl = Uri.parse(
        '$IpAddress/CusnamewiseSalesPaymentReport/$cusid/$customerName');
    final Paymentresponse = await http.get(paymenturl);

    if (response.statusCode == 200 && Paymentresponse.statusCode == 200) {
      // Clear the existing data before adding filtered data

      final List<dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> PaymentresponseData =
          jsonDecode(Paymentresponse.body);

      // Calculate credit total
      double creditTotal = 0;
      for (var data in responseData) {
        if (data is Map<String, dynamic> &&
            data.containsKey('dt') &&
            data.containsKey('finalamount') &&
            data['paytype'] == "Credit") {
          DateTime? dataDate = DateTime.tryParse(data['dt']);
          if (dataDate != null && dataDate.isBefore(selectedStartDate)) {
            creditTotal +=
                double.tryParse(data['finalamount'].toString()) ?? 0.0;
          }
        }
      }

      // Calculate debit total
      double debitTotal = 0;
      for (var data in PaymentresponseData) {
        if (data is Map<String, dynamic> &&
            data.containsKey('dt') &&
            data.containsKey('amount')) {
          DateTime? dataDate = DateTime.tryParse(data['dt']);
          if (dataDate != null && dataDate.isBefore(selectedStartDate)) {
            debitTotal += double.tryParse(data['amount'].toString()) ?? 0.0;
          }
        }
      }

      // Calculate balance amount
      double balance = creditTotal - debitTotal;
      totalopenbalanceCredit = balance;
      // print("$balance = $creditTotal - $debitTotal;");

      // Add the balance row to the OpenBaltableData
      OpenBaltableData.add({
        'Creditdsalesamount': creditTotal,
        'debitedsalesamount': debitTotal,
        'balance': balance,
      });

      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetallsalesDatewise(
      DateTime selectedStartDate, DateTime selectedEndDate) async {
    try {
      String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(selectedStartDate);
      String formattedEndDate =
          DateFormat('yyyy-MM-dd').format(selectedEndDate);

      String? cusid = await SharedPrefs.getCusId();
      final url = Uri.parse(
          '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/');

      final response = await http.get(url);

      final paymenturl =
          Uri.parse('$IpAddress/SalesPaymentRoundDetails/$cusid');
      final Paymentresponse = await http.get(paymenturl);

      if (response.statusCode == 200) {
        // Clear the existing data before adding filtered data

        final List<dynamic> responseData = jsonDecode(response.body);
        for (var data in responseData) {
          DateTime dataDate = DateTime.parse(data['dt']);

          // Check if dataDate is between selectedStartDate and selectedEndDate
          if ((dataDate.isAfter(selectedStartDate) ||
                  dataDate.isAtSameMomentAs(selectedStartDate)) &&
              (dataDate.isBefore(selectedEndDate) ||
                  dataDate.isAtSameMomentAs(selectedEndDate))) {
            if (data['Status'] == 'Normal') {
              if (data['paidamount'] == data['finalamount']) {
                // Adding two rows for each billno where paidamount is 0
                tableData.add({
                  'serialno': data['billno'],
                  'dt': data['dt'],
                  'Particular': 'Sales',
                  'credit': data['finalamount'],
                  'debit': '',
                });
                tableData.add({
                  'serialno': data['billno'],
                  'dt': data['dt'],
                  'Particular': 'Sales Payment',
                  'credit': '',
                  'debit': data['finalamount'],
                });
              } else {
                tableData.add({
                  'serialno': data['billno'],
                  'dt': data['dt'],
                  'Particular': 'Sales',
                  'credit': data['finalamount'],
                  'debit': '',
                });
              }
            }
          }
        }

        final List<dynamic> PaymentresponseData =
            jsonDecode(Paymentresponse.body);
        for (var data in PaymentresponseData) {
          DateTime dataDate = DateTime.parse(data['dt']);

          // Check if dataDate is between selectedStartDate and selectedEndDate
          if ((dataDate.isAfter(selectedStartDate) ||
                  dataDate.isAtSameMomentAs(selectedStartDate)) &&
              (dataDate.isBefore(selectedEndDate) ||
                  dataDate.isAtSameMomentAs(selectedEndDate))) {
            tableData.add({
              'serialno': data['billno'],
              'dt': data['dt'],
              'Particular': 'Sales Payment',
              'credit': '',
              'debit': data['amount'],
            });
          }
        }

        setState(() {});
        getTotSalesAmt(tableData);
        getTotPayAmt(tableData);
        getBalanceAmount(tableData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching sales data: $e');
      // Handle the error gracefully, e.g., show an error message to the user
    }
  }

  double overallBalancefinalAmount = 0.0;

  Future<void> fetallsalesBalance(
    DateTime selectedStartDate,
  ) async {
    String formattedStartDate =
        DateFormat('yyyy-MM-dd').format(selectedStartDate);
    String? cusid = await SharedPrefs.getCusId();
    final url = Uri.parse('$IpAddress/SalesLeadge/$cusid/$formattedStartDate/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        overallBalancefinalAmount = data['final_amount'];
        totalopenbalanceCredit = overallBalancefinalAmount;
        OpenBalAmtController.text =
            overallBalancefinalAmount.toStringAsFixed(0);
      });
      OpenBaltableData.add({
        'balance': overallBalancefinalAmount,
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  double getTotSalesAmt(List<Map<String, dynamic>> tableData) {
    double totalSalesAmt = 0.0;
    // print("table datas : $tableData");
    for (var data in tableData) {
      double SalesAmt = double.tryParse(data['credit']!) ?? 0.0;
      totalSalesAmt += SalesAmt;
    }
    totalSalesAmt = double.parse(totalSalesAmt.toStringAsFixed(2));
    print("total sales amount : ${TotSalesAmtController.text}");
    TotSalesAmtController.text = totalSalesAmt.toStringAsFixed(2);
    return totalSalesAmt;
  }

  double getTotPayAmt(List<Map<String, dynamic>> tableData) {
    double totalPayAmt = 0.0;
    // print("table datas : $tableData");
    for (var data in tableData) {
      double payment = double.tryParse(data['debit']!) ?? 0.0;
      totalPayAmt += payment;
    }
    totalPayAmt = double.parse(totalPayAmt.toStringAsFixed(2));

    TotPayAmtController.text = totalPayAmt.toStringAsFixed(2);
    return totalPayAmt;
  }

  double getBalanceAmount(List<Map<String, dynamic>> tableData) {
    double totalCredit = 0.0;
    double totalDebit = 0.0;

    for (var data in tableData) {
      var credit = double.tryParse(data['credit']?.toString() ?? '0.0') ?? 0;
      var debit = double.tryParse(data['debit']?.toString() ?? '0.0') ?? 0;

      totalCredit += credit;
      totalDebit += debit;
    }

    var balanceValue = totalCredit - totalDebit;
    // print("open balance : $totalopenbalanceCredit");
    var openbalance = balanceValue + totalopenbalanceCredit;
    var balance = (openbalance < 0 ? 0.0 : openbalance).toStringAsFixed(0);

    BalanceController.text = balance;
    return double.parse(balance);
  }

  Map<String, List<Map<String, dynamic>>> groupTransactionsByDate(
      List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      var date = transaction['dt'].toString();
      groupedTransactions.putIfAbsent(date, () => []);
      groupedTransactions[date]!.add(transaction);
    }
    return groupedTransactions;
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
                              'Sales Ledger Reports',
                              style: HeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 5,
                              children: [
                                Visibility(
                                  visible:
                                      isCustomernamechecked || isDateChecked,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Customer Name',
                                        style: commonLabelTextStyle,
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: Responsive.isDesktop(context)
                                            ? 150
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                        child: Container(
                                          height: 24,
                                          width: 100,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Container(
                                              child: CustomerNameDropdown(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      isCustomernamechecked || isDateChecked,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contact',
                                        style: commonLabelTextStyle,
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: Responsive.isDesktop(context)
                                            ? 150
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.32,
                                        child: Container(
                                          height: 24,
                                          width: 100,
                                          child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              controller:
                                                  CustomerContactController,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
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
                                Visibility(
                                  visible: isDateChecked || isOverallChecked,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From',
                                          style: commonLabelTextStyle,
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: Responsive.isDesktop(context)
                                              ? 150
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.32,
                                          height: Responsive.isDesktop(context)
                                              ? 25
                                              : 30,
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
                                                          _startdateController,
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                      dateLabelText: '',
                                                      onChanged: (val) {
                                                        setState(() {
                                                          selectedStartDate =
                                                              DateTime.parse(
                                                                  val);
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
                                ),
                                Visibility(
                                  visible: isDateChecked || isOverallChecked,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'To',
                                          style: commonLabelTextStyle,
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: Responsive.isDesktop(context)
                                              ? 150
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.32,
                                          height: Responsive.isDesktop(context)
                                              ? 25
                                              : 30,
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
                                                          _enddateController,
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                      dateLabelText: '',
                                                      onChanged: (val) {
                                                        setState(() {
                                                          selectedEndDate =
                                                              DateTime.parse(
                                                                  val);
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
                                ),
                                if (isCustomernamechecked == true)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: Responsive.isMobile(context)
                                            ? 0
                                            : 25,
                                        left: Responsive.isMobile(context)
                                            ? 10
                                            : 0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (isCustomernamechecked == true) {
                                          tableData = [];
                                          totalCredit = 0.0;
                                          totalDebit = 0.0;
                                          fetchData();
                                          getTotSalesAmt(tableData);
                                          getTotPayAmt(tableData);
                                          getBalanceAmount(tableData);
                                          logreports(
                                              "SalesLedgerReport: CutomerWise-${CustomerContactController.text}_Viewd");
                                        }
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
                                if (isDateChecked == true)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: Responsive.isMobile(context)
                                            ? 0
                                            : 25,
                                        left: Responsive.isMobile(context)
                                            ? 10
                                            : 0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          tableData.clear();
                                          OpenBaltableData.clear();
                                          totalCredit = 0.0;
                                          totalDebit = 0.0;
                                          fetchopenbalance(selectedStartDate,
                                              selectedEndDate);
                                          fetchDatewiseData(selectedStartDate,
                                              selectedEndDate);
                                          String startdt =
                                              _startdateController.text;
                                          String enddt =
                                              _enddateController.text;
                                          // Parse start and end dates
                                          DateTime startDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .parse(startdt);
                                          DateTime endDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .parse(enddt);

                                          String foramtedletterstartdt =
                                              DateFormat('d MMMM,yyyy')
                                                  .format(startDate);
                                          String foramtedletterenddt =
                                              DateFormat('d MMMM,yyyy')
                                                  .format(endDate);
                                          logreports(
                                              "SalesLedgerReport: CutomerWise-${CustomerContactController.text}_${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");
                                        });
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
                                if (isOverallChecked == true)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: Responsive.isMobile(context)
                                            ? 0
                                            : 25,
                                        left: Responsive.isMobile(context)
                                            ? 10
                                            : 0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        tableData.clear();
                                        OpenBaltableData.clear();
                                        totalCredit = 0.0;
                                        totalDebit = 0.0;
                                        setState(() {
                                          fetallsalesDatewise(selectedStartDate,
                                              selectedEndDate);
                                          fetallsalesBalance(selectedStartDate);
                                        });
                                        String startdt =
                                            _startdateController.text;
                                        String enddt = _enddateController.text;
                                        // Parse start and end dates
                                        DateTime startDate =
                                            DateFormat('yyyy-MM-dd')
                                                .parse(startdt);
                                        DateTime endDate =
                                            DateFormat('yyyy-MM-dd')
                                                .parse(enddt);

                                        String foramtedletterstartdt =
                                            DateFormat('d MMMM,yyyy')
                                                .format(startDate);
                                        String foramtedletterenddt =
                                            DateFormat('d MMMM,yyyy')
                                                .format(endDate);
                                        logreports(
                                            "SalesLedgerReport: ${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: subcolor,
                                        minimumSize: Size(10, 30),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        elevation: 2,
                                                shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero)
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: Responsive.isMobile(context)
                                          ? 0
                                          : 25),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        tableData = [];
                                        OpenBaltableData = [];

                                        totalCredit = 0.0;
                                        totalDebit = 0.0;
                                        customernameselectedValue = '';
                                        CustomerNamecontroller.clear();
                                        CustomerContactController.clear();
                                        TotSalesAmtController.clear();
                                        OpenBalAmtController.clear();
                                        totalopenbalanceCredit = 0;

                                        TotPayAmtController.clear();
                                        BalanceController.clear();
                                        // Set _startdateController to the current month's start date
                                        _startdateController.text =
                                            DateFormat('yyyy-MM-dd').format(
                                                DateTime(DateTime.now().year,
                                                    DateTime.now().month, 1));

                                        // Set _enddateController to the current month's end date
                                        _enddateController.text =
                                            DateFormat('yyyy-MM-dd').format(
                                                DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month + 1,
                                                    0));
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: subcolor,
                                      minimumSize: Size(10, 30),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      elevation: 2,
                                              shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero)
                                    ),
                                    child: Icon(
                                      Icons.refresh,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: Responsive.isMobile(context)
                            ? EdgeInsets.only(top: 0, right: 30)
                            : EdgeInsets.only(top: 0.0, right: 80),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Checkbox(
                              value: isCustomernamechecked,
                              onChanged: (value) {
                                setState(() {
                                  tableData = [];
                                  OpenBaltableData = [];
                                  totalCredit = 0.0;
                                  totalDebit = 0.0;
                                  customernameselectedValue = '';
                                  CustomerNamecontroller.clear();
                                  CustomerContactController.clear();
                                  TotSalesAmtController.clear();
                                  OpenBalAmtController.clear();
                                  totalopenbalanceCredit = 0;

                                  TotPayAmtController.clear();
                                  BalanceController.clear();
                                  _startdateController.text =
                                      DateFormat('yyyy-MM-dd').format(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          1));

                                  _enddateController.text =
                                      DateFormat('yyyy-MM-dd').format(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month + 1,
                                          0));
                                });
                                setState(() {
                                  isCustomernamechecked = value!;
                                  if (value == true) {
                                    isDateChecked = false;
                                    isOverallChecked = false;
                                    // PaymentTypeSelectedValue = '';0
                                  }
                                });
                              },
                              activeColor: subcolor,
                            ),
                            Text(
                              'CustomerWise',
                              style: commonLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: Responsive.isMobile(context)
                            ? EdgeInsets.only(top: 0, right: 30)
                            : EdgeInsets.only(top: 0.0, right: 88),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Checkbox(
                              value: isDateChecked,
                              onChanged: (value) {
                                setState(() {
                                  tableData = [];
                                  OpenBaltableData = [];
                                  totalCredit = 0.0;
                                  totalDebit = 0.0;
                                  customernameselectedValue = '';
                                  CustomerNamecontroller.clear();
                                  CustomerContactController.clear();
                                  TotSalesAmtController.clear();
                                  OpenBalAmtController.clear();
                                  totalopenbalanceCredit = 0;

                                  TotPayAmtController.clear();
                                  BalanceController.clear();
                                  // Set _startdateController to the current month's start date
                                  _startdateController.text =
                                      DateFormat('yyyy-MM-dd').format(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          1));

                                  // Set _enddateController to the current month's end date
                                  _enddateController.text =
                                      DateFormat('yyyy-MM-dd').format(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month + 1,
                                          0));
                                });
                                setState(() {
                                  isDateChecked = value!;
                                  if (value == true) {
                                    isCustomernamechecked = false;
                                    isOverallChecked = false;
                                    // ProductcategoyselectedValue = '';
                                  }
                                });
                              },
                              activeColor: subcolor,
                            ),
                            Text(
                              'DateWise        ',
                              style: commonLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: Responsive.isMobile(context)
                            ? EdgeInsets.only(top: 0, right: 30)
                            : EdgeInsets.only(top: 0.0, right: 84),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Checkbox(
                              value: isOverallChecked,
                              onChanged: (value) {
                                setState(() {
                                  tableData = [];
                                  OpenBaltableData = [];
                                  totalCredit = 0.0;
                                  totalDebit = 0.0;
                                  customernameselectedValue = '';
                                  CustomerNamecontroller.clear();
                                  CustomerContactController.clear();
                                  TotSalesAmtController.clear();
                                  OpenBalAmtController.clear();
                                  totalopenbalanceCredit = 0;
                                  TotPayAmtController.clear();
                                  BalanceController.clear();
                                  // Set _startdateController to the current month's start date
                                  _startdateController.text =
                                      DateFormat('yyyy-MM-dd').format(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          1));

                                  // Set _enddateController to the current month's end date
                                  _enddateController.text =
                                      DateFormat('yyyy-MM-dd').format(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month + 1,
                                          0));
                                });
                                setState(() {
                                  isOverallChecked = value!;
                                  if (value == true) {
                                    isCustomernamechecked = false;
                                    isDateChecked = false;

                                    // ProductcategoyselectedValue = '';
                                  }
                                });
                              },
                              activeColor: subcolor,
                            ),
                            Text(
                              'Over All Sales',
                              style: commonLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 0,
                          bottom: 0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  tableview(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Responsive.isDesktop(context)
                                  ? Padding(
                                      padding:
                                          EdgeInsets.only(top: 18, bottom: 18),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                              'Total Sales:   ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotSalesAmtController.text ?? '0') ?? 0)} /-',
                                              style: textStyle,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                              'Opening Balance: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse((isDateChecked == true ? (totalopenbalanceCredit.toStringAsFixed(0)) : OpenBalAmtController.text)) ?? 0)} /-',
                                              style: textStyle,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                              'Total Payment:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotPayAmtController.text ?? '0') ?? 0)} /-',
                                              style: textStyle,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                              'Total Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(BalanceController.text ?? '0') ?? 0)} /-',
                                              style: textStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                    'Total Sales:   ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotSalesAmtController.text ?? '0') ?? 0)} /-',
                                                    style: textStyle,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                    'Opening Balance: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse((isDateChecked == true ? (totalopenbalanceCredit.toStringAsFixed(0)) : OpenBalAmtController.text)) ?? 0)} /-',
                                                    style: textStyle,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                    'Total Payment:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotPayAmtController.text ?? '0') ?? 0)} /-',
                                                    style: textStyle,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                    'Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(BalanceController.text ?? '0') ?? 0)} /-',
                                                    style: textStyle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
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

  Widget tableview() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection:
          Responsive.isMobile(context) ? Axis.horizontal : Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: SingleChildScrollView(
              child: Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 350,
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 450,
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
                                    child: Text(
                                      "SerialNo",
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
                                      "Paticulars",
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
                                      "Credit",
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
                                      "Debit",
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
                                      "Balance",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (OpenBaltableData.isNotEmpty)
                          ...OpenBaltableData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> data = entry.value;

                            var balance = data['balance'].toString();
                            var overallbalance = data['balance'].toString();
                            bool isEvenRow =
                                OpenBaltableData.indexOf(data) % 2 == 0;
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text("",
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('',
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text("Opening Balance",
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(balance,
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text("",
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(balance,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        if (tableData.isNotEmpty) ...{
                          // Grouping transactions by date
                          ...groupTransactionsByDate(tableData)
                              .entries
                              .map((entry) {
                            var date = entry.key;
                            var transactions = entry.value;

                            // Filtering and sorting transactions for the current date
                            var filteredTransactions = transactions
                                .where((data) =>
                                    data['Particular'] == 'Sales' ||
                                    data['Particular'] == 'Sales Payment')
                                .toList()
                              ..sort((a, b) =>
                                  a['Particular'].compareTo(b['Particular']));

                            return Column(
                              children: [
                                ...filteredTransactions.map((data) {
                                  var serialno = data['serialno'].toString();
                                  var dt = data['dt'].toString();
                                  var Particular =
                                      data['Particular'].toString();
                                  var credit = double.tryParse(
                                          data['credit']?.toString() ??
                                              '0.0') ??
                                      0;
                                  var debit = double.tryParse(
                                          data['debit']?.toString() ?? '0.0') ??
                                      0;
                                  totalCredit += credit;

                                  totalDebit += debit;
                                  var balanceValue = totalCredit - totalDebit;

                                  var balance =
                                      (balanceValue < 0 ? 0.0 : balanceValue)
                                          .toStringAsFixed(0);

                                  var totalopenbal = totalopenbalanceCredit;

                                  var finalabalamt =
                                      double.parse(balance) + totalopenbal;

                                  bool isEvenRow =
                                      tableData.indexOf(data) % 2 == 0;
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0.0,
                                        right: 0,
                                        top: 5.0,
                                        bottom: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            width: 300.0,
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
                                            width: 300.0,
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
                                            width: 300.0,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(Particular,
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  credit.toStringAsFixed(0),
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  debit.toStringAsFixed(0),
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  finalabalamt
                                                      .toStringAsFixed(0),
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList()
                        } else ...{
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
  }
}
