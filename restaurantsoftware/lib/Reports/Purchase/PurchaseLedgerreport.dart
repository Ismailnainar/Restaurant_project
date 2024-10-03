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
  runApp(PurchaseLedgerReport());
}

class PurchaseLedgerReport extends StatefulWidget {
  @override
  State<PurchaseLedgerReport> createState() => _PurchaseLedgerReportState();
}

class _PurchaseLedgerReportState extends State<PurchaseLedgerReport> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> OpenBaltableData = [];

  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  bool isSupplierNamechecked = true;
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
  TextEditingController SupplierNamecontroller = TextEditingController();

  TextEditingController TotSalesAmtController = TextEditingController();
  TextEditingController OpenBalAmtController = TextEditingController();

  TextEditingController TotPayAmtController = TextEditingController();
  TextEditingController BalanceController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchSupplierName();
  }

  List<String> SupplierNameList = [];

  Future<void> fetchSupplierName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PurchaseSupplierNames/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          SupplierNameList.addAll(
              results.map<String>((item) => item['name'].toString()));

          hasNextPage = data['name'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $SupplierNameList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? SupplierNameselectedValue;
  // Widget SupplierNameDropdown() {
  //   SupplierNamecontroller.text = SupplierNameselectedValue ?? '';

  //   return TypeAheadFormField<String?>(
  //     textFieldConfiguration: TextFieldConfiguration(
  //       // focusNode: SupplierNameFocusNode,
  //       textInputAction: TextInputAction.next,
  //       // onSubmitted: (_) => _fieldFocusChange(
  //       //     context, SupplierNameFocusNode, PaymentTypeFocuNode),
  //       controller: SupplierNamecontroller,

  //       decoration: InputDecoration(
  //           // labelText: ' ${selectedValue ?? ""}',

  //           border: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //           ),
  //           contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //           labelStyle: TextStyle(fontSize: 12),
  //           suffixIcon: Icon(
  //             Icons.keyboard_arrow_down,
  //             size: 18,
  //           )),
  //       style: TextStyle(
  //           fontSize: 12,
  //           color: Colors.black), // Set text style for onSuggestionSelected
  //     ),
  //     suggestionsCallback: (pattern) {
  //       return SupplierNameList.where(
  //               (item) => item.toLowerCase().contains(pattern.toLowerCase()))
  //           .toList();
  //     },
  //     itemBuilder: (context, String? suggestion) {
  //       return Container(
  //         height: 28,
  //         child: ListTile(
  //           dense: true,
  //           title: Text(
  //             suggestion ?? ' ${SupplierNameselectedValue ?? ''}',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.black,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //     onSuggestionSelected: (String? suggestion) async {
  //       setState(() {
  //         SupplierNameselectedValue = suggestion;
  //         SupplierNamecontroller.text =
  //             suggestion ?? ' ${SupplierNameselectedValue ?? ''}';
  //       });
  //       tableData = [];
  //       totalCredit = 0.0;
  //       totalDebit = 0.0;
  //       if (isSupplierNamechecked == true) {
  //         await fetchData();
  //         await getTotSalesAmt(tableData);
  //         getTotPayAmt(tableData);
  //         getBalanceAmount(tableData);
  //       }
  //     },
  //     suggestionsBoxDecoration: SuggestionsBoxDecoration(
  //       constraints: BoxConstraints(maxHeight: 150),
  //     ),
  //   );
  // }

  int? _selectedEmpIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget SupplierNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                SupplierNameList.indexOf(SupplierNamecontroller.text);
            if (currentIndex < SupplierNameList.length - 1) {
              setState(() {
                _selectedEmpIndex = currentIndex + 1;
                SupplierNamecontroller.text =
                    SupplierNameList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                SupplierNameList.indexOf(SupplierNamecontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedEmpIndex = currentIndex - 1;
                SupplierNamecontroller.text =
                    SupplierNameList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: SupplierNamecontroller,
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
              SupplierNameselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return SupplierNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return SupplierNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = SupplierNameList.indexOf(suggestion);
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
                          SupplierNameList.indexOf(
                                  SupplierNamecontroller.text) ==
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
            SupplierNamecontroller.text = suggestion;
            SupplierNameselectedValue = suggestion;
            _filterEnabled = false;
          });
          tableData = [];
          totalCredit = 0.0;
          totalDebit = 0.0;
          if (isSupplierNamechecked == true) {
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

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String SupplierName = SupplierNamecontroller.text;
    final url =
        Uri.parse('$IpAddress/AgentwiseSalesReport/$cusid/$SupplierName');
    final response = await http.get(url);
    print("url datas : $url");

    final paymenturl = Uri.parse(
        '$IpAddress/AgentwiseSalesPaymentReport/$cusid/$SupplierName');
    final Paymentresponse = await http.get(paymenturl);

    if (response.statusCode == 200 && Paymentresponse.statusCode == 200) {
      final List<dynamic> salesResponseData = jsonDecode(response.body);
      final List<dynamic> paymentResponseData =
          jsonDecode(Paymentresponse.body);

      setState(() {
        tableData.clear();

        // Add sales data to tableData
        for (var data in salesResponseData) {
          tableData.add({
            'serialno': data['serialno'],
            'dt': data['date'],
            'Particular': 'Sales',
            'credit': data['total'],
            'debit': '',
          });
        }

        // Add payment data to tableData
        for (var data in paymentResponseData) {
          tableData.add({
            'serialno': data['id'],
            'dt': data['date'],
            'Particular': 'Sales Payment',
            'credit': '',
            'debit': data['amount'],
          });
        }
        getTotSalesAmt(tableData);
        getTotPayAmt(tableData);
        getBalanceAmount(tableData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDatewiseData(
      DateTime selectedStartDate, DateTime selectedEndDate) async {
    String? cusid = await SharedPrefs.getCusId();
    String SupplierName = SupplierNamecontroller.text;
    final url =
        Uri.parse('$IpAddress/AgentwiseSalesReport/$cusid/$SupplierName');
    final response = await http.get(url);

    final paymenturl = Uri.parse(
        '$IpAddress/AgentwiseSalesPaymentReport/$cusid/$SupplierName');
    final Paymentresponse = await http.get(paymenturl);

    if (response.statusCode == 200 && Paymentresponse.statusCode == 200) {
      setState(() {
        final List<dynamic> salesResponseData = jsonDecode(response.body);
        final List<dynamic> paymentResponseData =
            jsonDecode(Paymentresponse.body);

        String formatedlogreportstartdt =
            DateFormat('d MMMM,yyyy').format(selectedStartDate);
        String formatedlogreportenddt =
            DateFormat('d MMMM,yyyy').format(selectedEndDate);
        // Add sales data to tableData
        for (var data in salesResponseData) {
          DateTime dataDate = DateTime.parse(data['date']);
          if ((dataDate.isAfter(selectedStartDate) ||
                  dataDate.isAtSameMomentAs(selectedStartDate)) &&
              (dataDate.isBefore(selectedEndDate) ||
                  dataDate.isAtSameMomentAs(selectedEndDate))) {
            tableData.add({
              'serialno': data['serialno'],
              'dt': data['date'],
              'Particular': 'Sales',
              'credit': data['total'],
              'debit': '',
            });
          }
        }
        // print("purchase table data : $tableData");

        // Add payment data to tableData
        for (var data in paymentResponseData) {
          DateTime dataDate = DateTime.parse(data['date']);
          if ((dataDate.isAfter(selectedStartDate) ||
                  dataDate.isAtSameMomentAs(selectedStartDate)) &&
              (dataDate.isBefore(selectedEndDate) ||
                  dataDate.isAtSameMomentAs(selectedEndDate))) {
            tableData.add({
              'serialno': data['id'],
              'dt': data['date'],
              'Particular': 'Sales Payment',
              'credit': '',
              'debit': data['amount'],
            });
          }
        }
        // print("purchase payment table data : $tableData");

        getTotSalesAmt(tableData);
        getTotPayAmt(tableData);
        getBalanceAmount(tableData);
        logreports(
            "PurchaseLedgerReport: DateWise-${SupplierNamecontroller.text}_${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchOpenBalance(
      DateTime selectedStartDate, DateTime selectedEndDate) async {
    String supplierName = SupplierNamecontroller.text;

    String? cusid = await SharedPrefs.getCusId();
    // Construct URLs for fetching data
    final salesUrl =
        Uri.parse('$IpAddress/AgentwiseSalesReport/$cusid/$supplierName');
    final paymentUrl = Uri.parse(
        '$IpAddress/AgentwiseSalesPaymentReport/$cusid/$supplierName');

    // Fetch data from sales endpoint
    final salesResponse = await http.get(salesUrl);

    // Fetch data from payment endpoint
    final paymentResponse = await http.get(paymentUrl);

    // Check if both responses are successful
    if (salesResponse.statusCode == 200 && paymentResponse.statusCode == 200) {
      // Clear the existing data before adding filtered data
      OpenBaltableData.clear();

      // Decode JSON responses
      final List<dynamic> salesData = jsonDecode(salesResponse.body);
      final List<dynamic> paymentData = jsonDecode(paymentResponse.body);

      // Calculate credit total
      double creditTotal = 0;
      for (var data in salesData) {
        if (data is Map<String, dynamic> &&
            data.containsKey('date') &&
            data.containsKey('total')) {
          DateTime? dataDate = DateTime.tryParse(data['date']);
          if (dataDate != null && dataDate.isBefore(selectedStartDate)) {
            creditTotal += double.tryParse(data['total'].toString()) ?? 0.0;
          }
        }
      }

      // Calculate debit total
      double debitTotal = 0;
      for (var data in paymentData) {
        if (data is Map<String, dynamic> &&
            data.containsKey('date') &&
            data.containsKey('amount')) {
          DateTime? dataDate = DateTime.tryParse(data['date']);
          if (dataDate != null && dataDate.isBefore(selectedStartDate)) {
            debitTotal += double.tryParse(data['amount'].toString()) ?? 0.0;
          }
        }
      }

      // Calculate balance amount
      double balance = creditTotal - debitTotal;
      double totalbalance = (balance < 0 ? 0.0 : balance);
      totalopenbalanceCredit = totalbalance;

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
      String formatedlogreportstartdt =
          DateFormat('d MMMM,yyyy').format(selectedStartDate);
      String formatedlogreportenddt =
          DateFormat('d MMMM,yyyy').format(selectedEndDate);
      String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(selectedStartDate);
      String formattedEndDate =
          DateFormat('yyyy-MM-dd').format(selectedEndDate);

      String? cusid = await SharedPrefs.getCusId();
      final url = Uri.parse(
          '$IpAddress/DatewisePurchaseReport/$cusid/$formattedStartDate/$formattedEndDate/');

      final response = await http.get(url);

      final paymenturl = Uri.parse('$IpAddress/PurchasePayments/$cusid');
      final Paymentresponse = await http.get(paymenturl);
      if (response.statusCode == 200 && Paymentresponse.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        for (var data in responseData) {
          DateTime dataDate = DateTime.parse(data['date']);

          // Check if dataDate is between selectedStartDate and selectedEndDate
          if ((dataDate.isAfter(selectedStartDate) ||
                  dataDate.isAtSameMomentAs(selectedStartDate)) &&
              (dataDate.isBefore(selectedEndDate) ||
                  dataDate.isAtSameMomentAs(selectedEndDate))) {
            tableData.add({
              'serialno': data['serialno'],
              'dt': data['date'],
              'Particular': 'Sales',
              'credit': data['total'],
              'debit': '',
            });
          }
        }

        final List<dynamic> PaymentresponseData =
            jsonDecode(Paymentresponse.body)['results']; // Access 'results' key
        for (var data in PaymentresponseData) {
          DateTime dataDate = DateTime.parse(data['date']);

          // Check if dataDate is between selectedStartDate and selectedEndDate
          if ((dataDate.isAfter(selectedStartDate) ||
                  dataDate.isAtSameMomentAs(selectedStartDate)) &&
              (dataDate.isBefore(selectedEndDate) ||
                  dataDate.isAtSameMomentAs(selectedEndDate))) {
            tableData.add({
              'serialno': data['id'],
              'dt': data['date'],
              'Particular': 'Sales Payment',
              'credit': '',
              'debit': data['amount'],
            });
          }
        }

        setState(() {});
        print("table datass : $tableData");

        getTotSalesAmt(tableData);
        getTotPayAmt(tableData);
        getBalanceAmount(tableData);
        logreports(
            "PurchaseLedgerReport: OverAllSales-${formatedlogreportstartdt} To ${formatedlogreportenddt}_Viewd");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching sales data: $e');
      // Handle the error gracefully, e.g., show an error message to the user
    }
  }

  double overallBalancefinalAmount = 0.0;
  double totaloverallBalancefinalAmount = 0.0;

  Future<void> fetallsalesBalance(
    DateTime selectedStartDate,
  ) async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(selectedStartDate);
      final url =
          Uri.parse('$IpAddress/PurchaseLeadge/$cusid/$formattedStartDate/');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          overallBalancefinalAmount = data['final_amount'];
          totaloverallBalancefinalAmount =
              (overallBalancefinalAmount < 0 ? 0.0 : overallBalancefinalAmount);
          totalopenbalanceCredit = totaloverallBalancefinalAmount;
          OpenBalAmtController.text =
              totaloverallBalancefinalAmount.toStringAsFixed(0);
        });
        OpenBaltableData.add({
          'balance': totaloverallBalancefinalAmount,
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching balance data: $e');
      // Handle the error gracefully, e.g., show an error message to the user
    }
  }

  double getTotSalesAmt(List<Map<String, dynamic>> tableData) {
    double totalSalesAmt = 0.0;
    for (var data in tableData) {
      double SalesAmt = double.tryParse(data['credit']!) ?? 0.0;
      totalSalesAmt += SalesAmt;
    }
    totalSalesAmt = double.parse(totalSalesAmt.toStringAsFixed(2));
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
                              'Purchase  Ledger Reports',
                              style: HeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: [
                          Visibility(
                            visible: isSupplierNamechecked || isDateChecked,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchaser Name',
                                    style: commonLabelTextStyle,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.25,
                                    child: Container(
                                      height: 24,
                                      width: 120,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Container(
                                          child: SupplierNameDropdown(),
                                        ),
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
                                                    _startdateController,
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
                          ),
                          Visibility(
                            visible: isDateChecked || isOverallChecked,
                            child: Padding(
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
                          ),
                          if (isSupplierNamechecked)
                            Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      Responsive.isMobile(context) ? 10 : 25.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isSupplierNamechecked) {
                                    logreports(
                                        "PurchaseLedgerReport: PurchaserWise-${SupplierNamecontroller.text}_Viewd");
                                    tableData.clear();
                                    OpenBaltableData.clear();
                                    totalCredit = 0.0;
                                    totalDebit = 0.0;
                                    fetchData();
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
                          if (isDateChecked)
                            Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      Responsive.isMobile(context) ? 10 : 25.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    tableData.clear();
                                    OpenBaltableData.clear();
                                    totalCredit = 0.0;
                                    totalDebit = 0.0;
                                    fetchOpenBalance(
                                        selectedStartDate, selectedEndDate);
                                    fetchDatewiseData(
                                        selectedStartDate, selectedEndDate);
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
                          if (isOverallChecked)
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Responsive.isMobile(context) ? 0 : 25.0,
                                  left: Responsive.isMobile(context) ? 10 : 0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    tableData.clear();
                                    OpenBaltableData.clear();
                                    totalCredit = 0.0;
                                    totalDebit = 0.0;
                                    fetallsalesDatewise(
                                        selectedStartDate, selectedEndDate);
                                    fetallsalesBalance(selectedStartDate);
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
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: Responsive.isMobile(context)
                                  ? (isOverallChecked ? 0 : 10)
                                  : 25.0,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  tableData.clear();
                                  OpenBaltableData.clear();
                                  totalCredit = 0.0;
                                  totalDebit = 0.0;
                                  SupplierNameselectedValue = '';
                                  SupplierNamecontroller.clear();
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
                                Icons.refresh,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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
                              value: isSupplierNamechecked,
                              onChanged: (value) {
                                setState(() {
                                  tableData = [];
                                  OpenBaltableData = [];
                                  totalCredit = 0.0;
                                  totalDebit = 0.0;
                                  SupplierNameselectedValue = '';
                                  SupplierNamecontroller.clear();
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
                                  isSupplierNamechecked = value!;
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
                              'PurchaserWise',
                              style: commonLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: Responsive.isMobile(context)
                            ? EdgeInsets.only(top: 0, right: 30)
                            : EdgeInsets.only(top: 0.0, right: 87),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: isDateChecked,
                              onChanged: (value) {
                                setState(() {
                                  tableData = [];
                                  OpenBaltableData = [];
                                  totalCredit = 0.0;
                                  totalDebit = 0.0;
                                  SupplierNameselectedValue = '';
                                  SupplierNamecontroller.clear();
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
                                    isSupplierNamechecked = false;
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
                            : EdgeInsets.only(top: 0.0, right: 83),
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
                                  SupplierNameselectedValue = '';
                                  SupplierNamecontroller.clear();
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
                                    isSupplierNamechecked = false;
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
                                                style: textStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                                'Opening Balance: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse((isDateChecked == true ? (totalopenbalanceCredit.toStringAsFixed(0)) : OpenBalAmtController.text)) ?? 0)} /-',
                                                style: textStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                                'Total Payment:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotPayAmtController.text ?? '0') ?? 0)} /-',
                                                style: textStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(
                                                'Total Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(BalanceController.text ?? '0') ?? 0)} /-',
                                                style: textStyle),
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
                                                      style: textStyle),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                      'Opening Balance: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse((isDateChecked == true ? (totalopenbalanceCredit.toStringAsFixed(0)) : OpenBalAmtController.text)) ?? 0)} /-',
                                                      style: textStyle),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                      'Total Payment:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(TotPayAmtController.text ?? '0') ?? 0)} /-',
                                                      style: textStyle),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 10),
                                                  child: Text(
                                                      'Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse(BalanceController.text ?? '0') ?? 0)} /-',
                                                      style: textStyle),
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
                                        child: Text(
                                          "",
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '',
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Opening Balance",
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          balance,
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "",
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
                                        color:
                                            Color.fromARGB(224, 255, 255, 255),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          balance,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle,
                                        ),
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
                                // Padding(
                                //   padding:
                                //       const EdgeInsets.only(left: 0.0, right: 0),
                                //   child: Center(
                                //     child: Text(
                                //       date.toString(), // Display date
                                //       style: TextStyle(
                                //         fontSize: 16,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
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
                                              child: Text(
                                                serialno,
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                dt,
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                Particular,
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                credit.toStringAsFixed(0),
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                debit.toStringAsFixed(0),
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                finalabalamt.toStringAsFixed(0),
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle,
                                              ),
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
