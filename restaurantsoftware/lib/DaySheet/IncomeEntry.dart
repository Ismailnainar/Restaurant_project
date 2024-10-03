import 'package:restaurantsoftware/Reports/Purchase/PurchaseReport.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(IncomeEntry());
}

class IncomeEntry extends StatefulWidget {
  @override
  State<IncomeEntry> createState() => _IncomeEntryState();
}

class _IncomeEntryState extends State<IncomeEntry> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String searchText = '';
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  @override
  void initState() {
    super.initState();
    fetchIncomeDetails();
    _AmountController.text = "0.0";
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchIncomeDetails();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchIncomeDetails();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['description'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  String? selectedAmount;
  String? selectedproduct;
  Future<void> fetchIncomeDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/IncomeEntryDetail/$cusid/?page=$currentPage&size=$pageSize';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      setState(() {
        tableData = results;
        // You might need to adjust the key names based on your actual API response
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;
      });
    }
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (var data in tableData) {
      total += double.parse(data['amount'].toString());
    }
    return total;
  }

  void setState(VoidCallback fn) {
    super.setState(fn);
    totalAmount = calculateTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> filteredData;
    return WillPopScope(
      onWillPop: () async {
        String? role = await getrole();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => sidebar(
                    onItemSelected: (content) {},
                    settingsproductcategory:
                        role == 'admin' ? true : settingsproductcategory,
                    settingsproductdetails:
                        role == 'admin' ? true : settingsproductdetails,
                    settingsgstdetails:
                        role == 'admin' ? true : settingsgstdetails,
                    settingsstaffdetails:
                        role == 'admin' ? true : settingsstaffdetails,
                    settingspaymentmethod:
                        role == 'admin' ? true : settingspaymentmethod,
                    settingsaddsalespoint:
                        role == 'admin' ? true : settingsaddsalespoint,
                    settingsprinterdetails:
                        role == 'admin' ? true : settingsprinterdetails,
                    settingslogindetails:
                        role == 'admin' ? true : settingslogindetails,
                    purchasenewpurchase:
                        role == 'admin' ? true : purchasenewpurchase,
                    purchaseeditpurchase:
                        role == 'admin' ? true : purchaseeditpurchase,
                    purchasepaymentdetails:
                        role == 'admin' ? true : purchasepaymentdetails,
                    purchaseproductcategory:
                        role == 'admin' ? true : purchaseproductcategory,
                    purchaseproductdetails:
                        role == 'admin' ? true : purchaseproductdetails,
                    purchaseCustomer: role == 'admin' ? true : purchaseCustomer,
                    salesnewsales: role == 'admin' ? true : salesnewsale,
                    saleseditsales: role == 'admin' ? true : saleseditsales,
                    salespaymentdetails:
                        role == 'admin' ? true : salespaymentdetails,
                    salescustomer: role == 'admin' ? true : salescustomer,
                    salestablecount: role == 'admin' ? true : salestablecount,
                    quicksales: role == 'admin' ? true : quicksales,
                    ordersalesnew: role == 'admin' ? true : ordersalesnew,
                    ordersalesedit: role == 'admin' ? true : ordersalesedit,
                    ordersalespaymentdetails:
                        role == 'admin' ? true : ordersalespaymentdetails,
                    vendorsalesnew: role == 'admin' ? true : vendorsalesnew,
                    vendorsalespaymentdetails:
                        role == 'admin' ? true : vendorsalespaymentdetails,
                    vendorcustomer: role == 'admin' ? true : vendorcustomer,
                    stocknew: role == 'admin' ? true : stocknew,
                    wastageadd: role == 'admin' ? true : wastageadd,
                    kitchenusagesentry:
                        role == 'admin' ? true : kitchenusagesentry,
                    report: role == 'admin' ? true : report,
                    daysheetincomeentry:
                        role == 'admin' ? true : daysheetincomeentry,
                    daysheetexpenseentry:
                        role == 'admin' ? true : daysheetexpenseentry,
                    daysheetexepensescategory:
                        role == 'admin' ? true : daysheetexepensescategory,
                    graphsales: role == 'admin' ? true : graphsales,
                  )),
        );
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income Entry',
                        style: HeadingStyle,
                      ),
                      SizedBox(height: 15),
                      _buildContainer(),
                      SizedBox(height: 15),
                      Container(
                        height: Responsive.isDesktop(context)
                            ? screenHeight * 0.8
                            : 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 20, top: 10),
                                  child: Text(
                                    'Total Income :',
                                    style: textStyle,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, top: 10),
                                  child: Container(
                                    width:
                                        Responsive.isDesktop(context) ? 70 : 70,
                                    child: Container(
                                      height: 27,
                                      width: 100,
                                      // color: Colors.grey[200],
                                      child: Text(
                                        totalAmount.toStringAsFixed(2),
                                        style: commonLabelTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: Responsive.isDesktop(context)
                                        ? EdgeInsets.only(
                                            right: 30.0,
                                            bottom: 10.0,
                                          )
                                        : EdgeInsets.only(
                                            right: 0.0,
                                            bottom: 10.0,
                                          ),
                                    child: Container(
                                      height: 30,
                                      width: 100,
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
                                                color: Colors.grey, width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black,
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
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.date_range,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.description,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text("Descri",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
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
                            if (getFilteredData().isNotEmpty)
                              ...getFilteredData().map((data) {
                                var id = data['id'].toString();
                                var dt = data['dt'].toString();
                                var description =
                                    data['description'].toString();
                                var amount = data['amount'].toString();

                                bool isEvenRow =
                                    tableData.indexOf(data) % 2 == 0;
                                Color? rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 255, 255, 255);

                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 1.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            width: 500.0,
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
                                            width: 500.0,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
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
                                            width: 500.0,
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
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                          ]),
                        ),
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
                            Text('$currentPage / $totalPages',
                                style: commonLabelTextStyle),
                            SizedBox(width: 5),
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_right),
                              onPressed:
                                  hasNextPage ? () => loadNextPage() : null,
                            ),
                          ],
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
    );
  }

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _AmountController = TextEditingController();
  TextEditingController _DateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  void _saveDataToAPI() async {
    String? description = _descriptionController.text;
    String? amount = _AmountController.text;

    if (description == null || description.isEmpty) {
      WarninngMessage(context);
      _descriptionController.text = "";

      _descriptionFocusNode.requestFocus();

      return;
    }
    if (amount == "0.0" || amount.isEmpty) {
      WarninngMessage(context);
      _AmountController.text = "0.0";

      _amountFocusNode.requestFocus();

      return;
    }

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/IncomeEntryDetailalldatas/';
    Map<String, dynamic> postData = {
      "cusid": cusid,
      'dt': _DateController.text,
      'description': description,
      'amount': amount,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(postData),
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted) {
        // Check if the widget is still mounted before updating the state
        if (response.statusCode == 201) {
          print('Data saved successfully');
          await logreports("Income Entry: Description-${description}_Inserted");
          fetchIncomeDetails();
          successfullySavedMessage(context);
          _descriptionController.text = "";
          _AmountController.text = "0.0";

          _descriptionFocusNode.requestFocus();
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
          // print('Response content: ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error as needed
    }
  }

  void showIncomeEmptyWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Kindly check your income details.!!!',
                style: TextStyle(fontSize: 13, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  FocusNode buttonFocusNode = FocusNode();
  Widget _buildContainer() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // First Textbox
                _buildDescTextField("Description"),

                // Spacer or SizedBox to add some space between text fields
                SizedBox(width: 10),

                // Second Textbox
                _buildAmountTextField("Amount"),
                SizedBox(width: 10),
                _buildDateTimePickerField("Date"),
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 27.0),
                  child: ElevatedButton(
                    focusNode: buttonFocusNode,
                    onPressed: () {
                      _saveDataToAPI();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      backgroundColor: subcolor,
                      minimumSize: Size(75.0, 28.0), // Set width and height
                    ),
                    child: Text('Add', style: commonWhiteStyle),
                  ),
                ),
              ],
            ),
          ),
        if (Responsive.isMobile(context))
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDescTextField("Description"),
                  ],
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildAmountTextField("Amount"),
                      SizedBox(width: 5),
                      _buildDateTimePickerField("Date"),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(top: 23.0),
                        child: ElevatedButton(
                          focusNode: buttonFocusNode,
                          onPressed: () {
                            _saveDataToAPI();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            backgroundColor: subcolor,
                            minimumSize:
                                Size(25.0, 23.0), // Set width and height
                          ),
                          child: Text('Add', style: commonWhiteStyle),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  FocusNode _amountFocusNode = FocusNode();

  Widget _buildAmountTextField(String label) {
    return Container(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: commonLabelTextStyle),
          SizedBox(height: 5),
          Container(
            width: Responsive.isDesktop(context)
                ? 180
                : MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 23,
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _AmountController,
                focusNode: _amountFocusNode,
                onSubmitted: (_) =>
                    _fieldFocusChange(context, _amountFocusNode, DateFocusNode),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 7.0,
                  ),
                ),
                style: AmountTextStyle,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  FocusNode _descriptionFocusNode = FocusNode();

  Widget _buildDescTextField(String label) {
    return Container(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: commonLabelTextStyle),
          SizedBox(height: 5),
          Container(
            width: Responsive.isDesktop(context)
                ? 150
                : MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 23,
              width: 100,
              color: Colors.white,
              child: TextField(
                  focusNode: _descriptionFocusNode,
                  onSubmitted: (_) => _fieldFocusChange(
                      context, _descriptionFocusNode, _amountFocusNode),
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade400, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 7.0,
                    ),
                  ),
                  style: textStyle),
            ),
          ),
        ],
      ),
    );
  }

  late DateTime selectedDate;
  FocusNode DateFocusNode = FocusNode();

  Widget _buildDateTimePickerField(String label) {
    return Container(
      // color: Subcolor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: commonLabelTextStyle),
          SizedBox(height: 5),
          Container(
            width: Responsive.isDesktop(context)
                ? 140
                : MediaQuery.of(context).size.width * 0.4,
            child: Container(
              height: 23,
              decoration: BoxDecoration(
                  color: Colors.white, border: Border.all(color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DateTimePicker(
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, DateFocusNode, buttonFocusNode),
                        focusNode: DateFocusNode,
                        controller: _DateController,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        dateLabelText: '',
                        onChanged: (val) {
                          setState(() {
                            selectedDate = DateTime.parse(val);
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
