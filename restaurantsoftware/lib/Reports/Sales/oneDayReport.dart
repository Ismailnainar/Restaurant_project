import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

import '../../Modules/Responsive.dart';

void main() {
  runApp(oneDayReport());
}

class oneDayReport extends StatefulWidget {
  @override
  State<oneDayReport> createState() => oneDayReportState();
}

class oneDayReportState extends State<oneDayReport> {
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
  String? selectedPayType = '';
  List<String> paymentTypeList = [];
  bool isCatChecked = false;
  bool isPayChecked = false;

  final TextEditingController _dineInAmountController = TextEditingController();
  final TextEditingController _takeawayAmountController =
      TextEditingController();
  final TextEditingController _expensesAmountController =
      TextEditingController();
  final TextEditingController _onlineOrderAmountController =
      TextEditingController();

  String _currentType = 'DineIn';

  List<String> paytypes = [];
  String? selectedPaytype;
  late DateTime selecteddate;

  TextEditingController ProductCategoryController = TextEditingController();
  TextEditingController billCountController = TextEditingController();
  final TextEditingController salesAmountController = TextEditingController();
  final TextEditingController TotalAmtController = TextEditingController();
  String paymentType = 'Cash';
  TextEditingController PaymentTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPaytype();
    fetchBillData(selectedPayType!);
    fetchAndDivideSellingItems();
    fetchSalesData(type: _currentType);
    fetchLastBillNoDatas();
    fetchExpenseDetails();
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

  List<String> PaymentTypeList = [];

  String? PaymentTypeSelectedValue;
  Future<void> fetchPaytype() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/PaymentMethod/$cusid'));

    if (response.statusCode == 200) {
      List<dynamic> paytypeList = json.decode(response.body);
      setState(() {
        paytypes = paytypeList
            .map<String>((item) => item['paytype'] as String)
            .toList();
        if (paytypes.isNotEmpty) {
          selectedPaytype = paytypes[0];
        }
      });
    } else {
      throw Exception('Failed to fetch paytype data');
    }
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  List<List<bool>> isHovered = [
    [false, false, false, false], // First row hover states
    [false, false, false, false], // Second row hover states

    [false, false, false, false], // Second row hover states
    [false, false, false, false], // Second row hover states
  ];

  Widget buildContainer(String title, Color color, int rowIndex, int colIndex) {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered[rowIndex][colIndex] = true; // Change the hover state
        });
      },
      onExit: (_) {
        setState(() {
          isHovered[rowIndex][colIndex] = false; // Change the hover state
        });
      },
      child: GestureDetector(
        onTap: () {
          if (title == 'Dine In') {
            _showDineInDialog(); // Show dialog for Dine In
          } else if (title == 'Take Away') {
            _showTakeAwayDialog(); // Show dialog for Take Away
          } else if (title == 'Expenses') {
            _showExpenseDialog(); // Show dialog for Expenses
          } else if (title == 'Online Order') {
            _showOnlineOrderDialog(); // Show dialog for Online Order
          } else {
            // Handle other containers' tap events if necessary
          }
        },
        child: Container(
          width: isDesktop ? 200 : 270,
          margin: EdgeInsets.only(right: isDesktop ? 10 : 5),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHovered[rowIndex][colIndex]
                  ? [color.withOpacity(0.2), color.withOpacity(0.4)]
                  : [color.withOpacity(0.4), color.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: isDesktop ? 18 : 15,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                  // Display the amount based on the type
                  'Total Amount: ₹${_getTotalAmount(title)}',
                  style: TextStyle(
                      fontSize: isDesktop ? 15 : 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  String _getTotalAmount(String title) {
    // Define a helper function to format the amount
    String formatAmount(String amount) {
      if (amount.isEmpty) {
        return '0'; // Return '0' if no amount is available
      }
      return amount;
    }

    if (title == 'Dine In') {
      return formatAmount(_dineInAmountController.text);
    } else if (title == 'Take Away') {
      return formatAmount(_takeawayAmountController.text);
    } else if (title == 'Expenses') {
      return formatAmount(_expensesAmountController.text);
    } else if (title == 'Online Order') {
      return formatAmount(_onlineOrderAmountController.text);
    } else {
      return '0'; // Default value if no type matches
    }
  }

  List<Map<String, dynamic>> topSellingItems = [];
  List<Map<String, dynamic>> lowSellingItems = [];

  Future<void> fetchAndDivideSellingItems() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/DashboardTopSelling/$cusid/';
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        dynamic fetchedItems = data['top_selling_items'];

        if (fetchedItems is List) {
          // Convert fetched items to a list of maps
          List<Map<String, dynamic>> sellingItems =
              List<Map<String, dynamic>>.from(fetchedItems);

          // Sort items by quantity (qty) in descending order
          sellingItems
              .sort((a, b) => (b['qty'] as int).compareTo(a['qty'] as int));

          // Clear previous data
          topSellingItems.clear();
          lowSellingItems.clear();

          // Calculate the mid-point to split the list into two equal parts
          int midPoint = (sellingItems.length / 2).ceil();

          // Assign items to top-selling and low-selling lists based on qty
          topSellingItems = sellingItems.take(midPoint).toList(); // Top half
          lowSellingItems = sellingItems.skip(midPoint).toList(); // Bottom half

          setState(() {}); // Trigger widget rebuild after data update
        } else {
          print('Expected a List, but received: $fetchedItems');
        }
      } else {
        print(
            'Failed to fetch top selling items. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching top selling items: $error');
    }
  }

  bool _isHovered1 = false;
  bool _isHovered2 = false;
  bool _isHovered3 = false;
  Future<double> fetchSalesData({required String type}) async {
    String startdt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String enddt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);
    endDate = endDate.add(Duration(days: 1));

    String? cusid = await SharedPrefs.getCusId();
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> filteredData =
          List<Map<String, dynamic>>.from(jsonData)
              .where((item) => item['type'] == type)
              .toList();

      double totalAmount = filteredData.fold(
        0.0,
        (sum, item) {
          double amount =
              double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
          return sum + amount;
        },
      );

      // Update the appropriate controller
      if (type == 'DineIn') {
        _dineInAmountController.text =
            NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0)
                .format(totalAmount);
      } else if (type == 'TakeAway') {
        _takeawayAmountController.text =
            NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0)
                .format(totalAmount);
      }

      setState(() {
        tableData = filteredData;
      });

      return totalAmount;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<double> fetchExpenseDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/ExpenseEntryDetail/$cusid/?page=$currentPage&size=$pageSize';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalAmount = 0.0;

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      setState(() {
        tableData = results.map((result) {
          double amount = double.tryParse(result['amount'].toString()) ?? 0.0;
          totalAmount += amount; // Accumulate the total amount
          return {
            'cat': result['cat'], // Adjust based on your API response
            'amount': amount, // Adjust based on your API response
          };
        }).toList();
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;

        // Update the controller with the total amount
        _expensesAmountController.text =
            NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0)
                .format(totalAmount);
      });
    }

    return totalAmount;
  }

  List<Map<String, String>> lastbillData = [];

  Future<List<Map<String, String>>> fetchLastBillNoDatas() async {
    lastbillData.clear();
    String? cusid = await SharedPrefs.getCusId();
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String baseUrl = '$IpAddress/SalesRoundAndDetails/$cusid/';
    int page = 1;

    double lastAmount = 0.0;

    while (true) {
      try {
        String url = '$baseUrl?page=$page';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final results = jsonData['results'];

          for (var entry in results) {
            if (entry['dt'] == todayDate && entry['Status'] == 'Vendor') {
              String id = entry['id'].toString();
              String finalamount = entry['finalamount'] ?? '0';
              double amount = double.tryParse(finalamount) ?? 0.0;

              lastbillData.add({
                'id': id,
                'billno': entry['billno'],
                'finalamount': finalamount,
              });

              lastAmount = amount; // Update with the latest amount
            }
          }

          if (jsonData['next'] == null) {
            break;
          } else {
            page++;
          }
        } else {
          print(
              'Failed to load Last Bill datas. Status code: ${response.statusCode}');
          break;
        }
      } catch (e) {
        print('Error: $e');
        break;
      }
    }

    // Update the controller with the latest amount
    _onlineOrderAmountController.text =
        NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0)
            .format(lastAmount);

    return lastbillData;
  }

  void _showDineInDialog() async {
    _currentType = 'DineIn';
    double totalAmount = await fetchSalesData(type: _currentType);
    if (totalAmount == 0.0) {
      // Show No Data Available dialog
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Dine In Details', style: HeadingStyle),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.25
                  : MediaQuery.of(context).size.width * 0.9,
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height * 0.6
                  : 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/thumbNo.gif', // Path to your GIF
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Data Available',
                    style: HeadingStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Dine In Details', style: HeadingStyle),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.25
                  : MediaQuery.of(context).size.width * 0.9,
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height * 0.6
                  : 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: tableView(
                          tableData)), // Call the tableView widget here
                  SizedBox(height: 10),
                  Text(
                      'Total Amount: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(totalAmount)}',
                      style: HeadingStyle),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showTakeAwayDialog() async {
    _currentType = 'TakeAway';
    double totalAmount = await fetchSalesData(type: _currentType);
    if (totalAmount == 0.0) {
      // Show No Data Available dialog
      showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Take Away Details', style: HeadingStyle),
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width *
                      0.2 // Smaller width for desktop
                  : MediaQuery.of(context).size.width *
                      0.8, // Smaller width for mobile
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height *
                      0.25 // Reduced height for desktop
                  : 150, // Reduced height for mobile
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/thumbNo.gif', // Path to your GIF
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Data Available',
                    style: HeadingStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Take Away Details', style: HeadingStyle),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.25
                  : MediaQuery.of(context).size.width * 0.9,
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height * 0.6
                  : 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: tableView(
                          tableData)), // Call the tableView widget here
                  SizedBox(height: 10),
                  Text(
                      'Total Amount: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(totalAmount)}',
                      style: HeadingStyle),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showExpenseDialog() async {
    double totalAmount = await fetchExpenseDetails();
    if (totalAmount == 0.0) {
      // Show No Data Available dialog
      showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Expense Details', style: HeadingStyle),
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width *
                      0.2 // Smaller width for desktop
                  : MediaQuery.of(context).size.width *
                      0.8, // Smaller width for mobile
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height *
                      0.25 // Reduced height for desktop
                  : 150, // Reduced height for mobile
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/thumbNo.gif', // Path to your GIF
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Data Available',
                    style: HeadingStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Expense Details', style: HeadingStyle),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.25
                  : MediaQuery.of(context).size.width * 0.9,
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height * 0.6
                  : 400,
              child: Column(
                children: [
                  Expanded(child: ExpensetableView()), // Display table
                  SizedBox(height: 20),
                  Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                      style: HeadingStyle),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showOnlineOrderDialog() async {
    List<Map<String, String>> fetchedData = await fetchLastBillNoDatas();

    // Calculate total amount
    double totalAmount = fetchedData.fold(
      0.0,
      (sum, item) {
        // Ensure that finalamount is parsed as double
        double amount = double.tryParse(item['finalamount'] ?? '0') ?? 0.0;
        return sum + amount;
      },
    );
    if (totalAmount == 0.0) {
      // Show No Data Available dialog
      showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Online Order', style: HeadingStyle),
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width *
                      0.2 // Smaller width for desktop
                  : MediaQuery.of(context).size.width *
                      0.8, // Smaller width for mobile
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height *
                      0.25 // Reduced height for desktop
                  : 150, // Reduced height for mobile
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/thumbNo.gif', // Path to your GIF
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Data Available',
                    style: HeadingStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Online Order Details', style: HeadingStyle),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
            content: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.25
                  : MediaQuery.of(context).size.width * 0.9,
              height: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.height * 0.6
                  : 400,
              child: Column(
                children: [
                  Expanded(
                      child:
                          OnlineOrderTableView(fetchedData)), // Display table
                  SizedBox(height: 20),
                  Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                      style: HeadingStyle),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget tableView(List<Map<String, dynamic>> tableData) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.65 : 320,
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.23
              : MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: Responsive.isDesktop(context)
                  ? screenWidth * 0.23
                  : MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: 25,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notes_rounded,
                                      size: 15, color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text("Bill No",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: 25,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_money,
                                      size: 15, color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text("Amount",
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
                  if (tableData.isNotEmpty)
                    ...tableData.map((data) {
                      String billno = data['billno'].toString();
                      var amount = NumberFormat('###,###,##0.00')
                          .format(double.parse(data['amount'].toString()));
                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(255, 223, 225, 226);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
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
                                width: 265.0,
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
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// expense table view

  Widget ExpensetableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.65 : 320,
          // height: Responsive.isDesktop(context) ? 380 : 240,
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.23
              : MediaQuery.of(context).size.width,

          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: Responsive.isDesktop(context)
                  ? screenwidth * 0.23
                  : MediaQuery.of(context).size.width * 0.8,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          height: 25,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notes_rounded,
                                    size: 15, color: Colors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Category",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 25,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money,
                                    size: 15, color: Colors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Amount",
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
                if (tableData.isNotEmpty)
                  ...tableData.asMap().entries.map((entry) {
                    int index = entry.key;

                    Map<String, dynamic> data = entry.value;
                    var id = data['id'].toString();

                    var cat = data['cat'].toString();
                    var amount = data['amount'].toString();

                    bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                    Color? rowColor = isEvenRow
                        ? Color.fromARGB(224, 255, 255, 255)
                        : Color.fromARGB(255, 223, 225, 226);

                    return Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0),
                      child: GestureDetector(
                        onTap: () {
                          // purchasePaymentDetails(data);
                          fetchSalesData(type: '');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
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
                                width: 265.0,
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
                      ),
                    );
                  }).toList()
              ]),
            ),
          ),
        ),
      ),
    );
  }

// expense table view

  Widget OnlineOrderTableView(List<Map<String, dynamic>> tableData) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.65 : 320,
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.23
              : MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: Responsive.isDesktop(context)
                  ? screenWidth * 0.23
                  : MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: 25,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notes_rounded,
                                      size: 15, color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text("Bill No",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: 25,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_money,
                                      size: 15, color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text("FinalAmt",
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
                  if (tableData.isNotEmpty)
                    ...tableData.map((data) {
                      String billno = data['billno'].toString();
                      String finalamount = data['finalamount'].toString();

                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(255, 223, 225, 226);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
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
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(finalamount,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> salesData = [];
  Future<List<Map<String, dynamic>>> fetchBillData(
      String selectedPayType) async {
    String startdt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String enddt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);
    endDate = endDate.add(Duration(days: 1));

    String? cusid =
        await SharedPrefs.getCusId(); // Assuming SharedPrefs is defined
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final response = await http.get(Uri.parse(
          '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> filteredResults = data.where((item) {
          return item['paytype'] == selectedPayType;
        }).map((item) {
          // Parse 'amount' as double
          return {
            'billno': item['billno'],
            'amount': double.tryParse(item['amount'].toString()) ?? 0.0,
          };
        }).toList();

        // Calculate the total amount
        double totalAmount =
            filteredResults.fold(0, (sum, item) => sum + item['amount']);

        // Return the filtered results along with the total amount
        return filteredResults;
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _showDialog() async {
    if (selectedPaytype != null) {
      List<Map<String, dynamic>> fetchedData =
          await fetchBillData(selectedPaytype!);

      // Calculate the total amount
      double newTotalAmount = fetchedData.fold(0, (sum, item) {
        final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
        return sum + amount;
      });

      // Update the state with the new total amount
      setState(() {
        totalAmount = newTotalAmount;
      });

      if (fetchedData.isEmpty) {
        // Show small dialog box if no data is available
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Pay Type Details', // Title of the dialog
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for the title
              ),
              content: Column(
                mainAxisSize: MainAxisSize
                    .min, // Makes sure the column takes up minimal space
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/thumbNo.gif', // Path to your GIF
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Data Available', // Text below the image
                    style: TextStyle(fontSize: 16), // Style for the text
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              // actions: [
              //   TextButton(
              //     onPressed: () {
              //       Navigator.of(context)
              //           .pop(); // Close the dialog when OK is pressed
              //     },
              //     child: Text(
              //       'OK',
              //       style:
              //           TextStyle(fontSize: 14), // Style for the OK button text
              //     ),
              //   ),
              // ],
            );
          },
        );
      } else {
        // Show the main dialog box with data
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Paytype Details',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.red,
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Expanded(
                      child: tableView(fetchedData),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a Paytype first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop View

          return Container(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('One Day Report', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.cancel),
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                // Horizontal Line
                Divider(thickness: 1, color: Colors.grey),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 10),
                    // ElevatedButton(
                    //   onPressed: () => _selectDate(context),
                    //   child: Text('Select Date'),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.ads_click, // Adding star icon
                          color: Colors.black,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text("To Click View Details", style: textStyle),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20), // Space between date and rows

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Left Column for Top and Low Selling Products
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTopSellingProductsContainer(),
                            SizedBox(width: 40),
                            _buildLowSellingProductsContainer(),
                          ],
                        ),
                      ),

                      // Right Column for additional containers
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildRowContainers(
                                'Dine In',
                                'Take Away',
                                Colors.blue,
                                Colors.green,
                                'Online Order',
                                'Expenses',
                                Colors.orange,
                                Colors.purple),
                            SizedBox(height: 20),
                            _buildPayTypesContainer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ]));
        } else {
          // Mobile View
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('One Day Report', style: TextStyle(fontSize: 18)),
                        IconButton(
                          icon: Icon(Icons.cancel),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  // Horizontal Line
                  Divider(thickness: 1, color: Colors.grey),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 10),
                      // ElevatedButton(
                      //   onPressed: () => _selectDate(context),
                      //   child: Text('Select Date'),
                      // ),
                    ],
                  ),
                  SizedBox(height: 20), // Space between date and rows
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildTopSellingProductsContainer(),
                        SizedBox(height: 20),
                        _buildLowSellingProductsContainer(),
                        SizedBox(height: 20),
                        _buildRowContainers(
                            'Dine In',
                            'Take Away',
                            Colors.blue,
                            Colors.green,
                            'Online Order',
                            'Expenses',
                            Colors.orange,
                            Colors.purple),
                        SizedBox(height: 20),
                        _buildPayTypesContainer(),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.ads_click, // Adding star icon
                              color: Colors.red,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text("To Click View Details", style: textStyle),
                          ],
                        ),
                      ],
                    ),
                  )
                ])),
          );
        }
      },
    );
  }

  // Separate methods for each section of your layout

  Widget _buildTopSellingProductsContainer() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered1 = true),
      onExit: (_) => setState(() => _isHovered1 = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isHovered1 ? 305 : 300,
        height: _isHovered1 ? 455 : 450,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Top Selling Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                for (var i = 0; i < 7; i++) _buildCardWidget(i),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowSellingProductsContainer() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered2 = true),
      onExit: (_) => setState(() => _isHovered2 = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isHovered2 ? 305 : 300, // Zoom effect on hover
        height: _isHovered2 ? 455 : 450,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Low Selling Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10), // Space between title and list
            Column(
              children: [
                for (var i = 0; i < 7; i++) _buildProductWidget(i),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowContainers(String title1, String title2, Color color1,
      Color color2, String title3, String title4, Color color3, Color color4) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the width is less than a certain breakpoint (e.g., 600 for mobile)
        bool isMobileView = constraints.maxWidth < 600;

        if (isMobileView) {
          // Mobile view layout: single column
          return Column(
            children: [
              buildContainer(title1, color1, 0, 0),
              SizedBox(height: 10),
              buildContainer(title2, color2, 0, 1),
              SizedBox(height: 10),
              buildContainer(title3, color3, 0, 2),
              SizedBox(height: 10),
              buildContainer(title4, color4, 1, 0),
            ],
          );
        } else {
          // Desktop view layout: two rows
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildContainer(title1, color1, 0, 0),
                  SizedBox(width: 10),
                  buildContainer(title2, color2, 0, 1),
                ],
              ),
              SizedBox(height: 20), // Space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildContainer(title3, color3, 0, 2),
                  SizedBox(width: 10),
                  buildContainer(title4, color4, 1, 0),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPayTypesContainer() {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;

    return GestureDetector(
      onTap: () {
        if (selectedPaytype != null) {
          _showDialog();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 420 : 220,
            height: isDesktop ? 220 : 250,
            padding: EdgeInsets.all(isDesktop ? 10 : 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 8.0 : 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay Types', style: HeadingStyle),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 12 : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _buildRadioRows(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 10),
                  if (selectedPaytype != null)
                    Center(
                      child: Container(
                        width: 180,
                        height: isDesktop ? 25 : 35,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                                'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                                style: commonLabelTextStyle),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  // return Container(
  //   padding: EdgeInsets.all(20),
  //   child: Column(
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(top: 5.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text('One Day Report', style: TextStyle(fontSize: 18)),
  //             IconButton(
  //               icon: Icon(Icons.cancel),
  //               color: Colors.red,
  //               onPressed: () {
  //                 Navigator.of(context).pop(); // Close the dialog
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 5),
  //       // Horizontal Line
  //       Divider(thickness: 1, color: Colors.grey),
  //       SizedBox(height: 20),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             "Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
  //             style: TextStyle(fontSize: 18),
  //           ),
  //           SizedBox(width: 10),
  //           // ElevatedButton(
  //           //   onPressed: () => _selectDate(context),
  //           //   child: Text('Select Date'),
  //           // ),
  //         ],
  //       ),
  //       SizedBox(height: 20), // Space between date and rows
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             children: [
  //               // Left Column for Top and Low Selling Products
  //               Expanded(
  //                 flex: 2,
  //                 child: Row(
  //                   mainAxisAlignment:
  //                       MainAxisAlignment.center, // Center the containers
  //                   children: [
  //                     // Top Selling Products Container
  //                     MouseRegion(
  //                       onEnter: (_) => setState(() => _isHovered1 = true),
  //                       onExit: (_) => setState(() => _isHovered1 = false),
  //                       child: AnimatedContainer(
  //                         duration: Duration(milliseconds: 300),
  //                         width:
  //                             _isHovered1 ? 305 : 300, // Zoom effect on hover
  //                         height: _isHovered1 ? 455 : 450,
  //                         padding: EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(8),
  //                           border: Border.all(color: Colors.blue, width: 1),
  //                         ),
  //                         child: Column(
  //                           children: [
  //                             Container(
  //                               padding: EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               child: Text(
  //                                 'Top Selling Products',
  //                                 style: TextStyle(
  //                                     fontSize: 20,
  //                                     fontWeight: FontWeight.bold),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                                 height: 10), // Space between title and list
  //                             Column(
  //                               children: [
  //                                 for (var i = 0; i < 7; i++)
  //                                   _buildCardWidget(i),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 40), // Space between the two containers
  //                     // Low Selling Products Container
  //                     MouseRegion(
  //                       onEnter: (_) => setState(() => _isHovered2 = true),
  //                       onExit: (_) => setState(() => _isHovered2 = false),
  //                       child: AnimatedContainer(
  //                         duration: Duration(milliseconds: 300),
  //                         width:
  //                             _isHovered2 ? 305 : 300, // Zoom effect on hover
  //                         height: _isHovered2 ? 455 : 450,
  //                         padding: EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(8),
  //                           border: Border.all(color: Colors.blue, width: 1),
  //                         ),
  //                         child: Column(
  //                           children: [
  //                             Container(
  //                               padding: EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               child: Text(
  //                                 'Low Selling Products',
  //                                 style: TextStyle(
  //                                     fontSize: 20,
  //                                     fontWeight: FontWeight.bold),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                                 height: 10), // Space between title and list
  //                             Column(
  //                               children: [
  //                                 for (var i = 0; i < 7; i++)
  //                                   _buildProductWidget(i),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               // Right Column for additional containers
  //               Expanded(
  //                 flex: 2,
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         buildContainer('Dine In', Colors.blue, 0, 0),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                         buildContainer('Take Away', Colors.green, 0, 1),
  //                       ],
  //                     ),
  //                     SizedBox(height: 20), // Space between rows
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         buildContainer('Online Order', Colors.orange, 0, 2),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                         buildContainer('Expenses', Colors.purple, 1, 0),
  //                       ],
  //                     ),
  //                     SizedBox(height: 20), // Space between rows
  //                     GestureDetector(
  //                       onTap: () {
  //                         if (selectedPaytype != null) {
  //                           _showDialog();
  //                         }
  //                       },
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             width: 420,
  //                             height: 220,
  //                             padding: EdgeInsets.all(10),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(8),
  //                               border:
  //                                   Border.all(color: Colors.blue, width: 1),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text('Pay Types', style: HeadingStyle),
  //                                   SizedBox(height: 10),
  //                                   Expanded(
  //                                     child: SingleChildScrollView(
  //                                       scrollDirection: Axis.vertical,
  //                                       child: Padding(
  //                                         padding: const EdgeInsets.all(12.0),
  //                                         child: Column(
  //                                           crossAxisAlignment:
  //                                               CrossAxisAlignment.center,
  //                                           children: _buildRadioRows(),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 20),
  //                                   if (selectedPaytype != null)
  //                                     Center(
  //                                       child: Container(
  //                                         width: 180,
  //                                         height: 28,
  //                                         decoration: BoxDecoration(
  //                                           color: Colors.blue[
  //                                               100], // Background color for sub-container
  //                                           borderRadius: BorderRadius.circular(
  //                                               8), // Border radius
  //                                         ),
  //                                         child: Center(
  //                                           child: Padding(
  //                                             padding:
  //                                                 const EdgeInsets.all(3.0),
  //                                             child: Text(
  //                                                 'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
  //                                                 style: commonLabelTextStyle),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  List<Widget> _buildRadioRows() {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;
    int radiosPerRow = isDesktop ? 3 : 2; // 3 for desktop, 2 for mobile

    List<Widget> rows = [];
    for (int i = 0; i < paytypes.length; i += radiosPerRow) {
      rows.add(
        Padding(
          padding: EdgeInsets.all(isDesktop ? 4.0 : 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = i; j < i + radiosPerRow && j < paytypes.length; j++)
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: paytypes[j],
                        groupValue: selectedPaytype,
                        onChanged: (String? value) {
                          setState(() {
                            selectedPaytype = value;
                          });
                        },
                      ),
                      Text(paytypes[j],
                          style: isDesktop
                              ? textStyle
                              : TextStyle(fontSize: 12) // Adjusted font size
                          ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildProductWidget(int index) {
    if (index < lowSellingItems.length) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isHovered3 ? 205 : 200, // Zoom effect on hover
        height: _isHovered3 ? 40 : 38,
        decoration: BoxDecoration(
          color: Colors.blue[100], // Background color for sub-container
          borderRadius: BorderRadius.circular(8), // Border radius
        ),
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Text(
              lowSellingItems[index]['Itemname'], // Fetch item name dynamically
              style:
                  commonLabelTextStyle // Optional: Adjust text style as needed
              ),
        ),
      );
    } else {
      return Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.blue[100], // Background color for sub-container
            borderRadius: BorderRadius.circular(8), // Border radius
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: SmallCard(name: 'Not Available'));
    }
  }

  Widget _buildCardWidget(int index) {
    if (index < topSellingItems.length) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isHovered3 ? 205 : 200, // Zoom effect on hover
        height: _isHovered3 ? 40 : 38,
        decoration: BoxDecoration(
          color: Colors.blue[100], // Background color for sub-container
          borderRadius: BorderRadius.circular(8), // Border radius
        ),
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Text(
              topSellingItems[index]['Itemname'], // Fetch item name dynamically
              style:
                  commonLabelTextStyle // Optional: Adjust text style as needed
              ),
        ),
      );
    } else {
      return Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.blue[100], // Background color for sub-container
            borderRadius: BorderRadius.circular(8), // Border radius
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: SmallCard(name: 'Not Available'));
    }
  }
}

class SmallCard extends StatelessWidget {
  final String name;

  SmallCard({required this.name});

  @override
  Widget build(BuildContext context) {
    Color textColor = name == "Not Available"
        ? const Color.fromARGB(255, 119, 116, 116)
        : maincolor;
    FontWeight fontWeight =
        name == "Not Available" ? FontWeight.normal : FontWeight.bold;

    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        // top: 3,
      ),
      child: Center(
        child: Text(name ?? "Not Available",
            style: TextStyle(
                fontSize: 13.0, color: textColor, fontWeight: fontWeight)),
      ),
    );
  }
}
