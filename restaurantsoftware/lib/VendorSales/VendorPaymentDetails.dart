import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(VendorPaymentDetails());
}

class VendorPaymentDetails extends StatefulWidget {
  @override
  State<VendorPaymentDetails> createState() => _VendorPaymentDetailsState();
}

class _VendorPaymentDetailsState extends State<VendorPaymentDetails> {
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  late FocusNode _focusNode;
  bool _isOptionsVisible = false;

  TextEditingController billnocontroller = TextEditingController();
  TextEditingController customernameController = TextEditingController();
  TextEditingController customercontactController = TextEditingController();

  TextEditingController Selecttypecontroller = TextEditingController();
  TextEditingController PaymentTypeController = TextEditingController();
  TextEditingController BalanceAmtController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController TotalAmtController = TextEditingController();

  TextEditingController RemainController = TextEditingController();
  TextEditingController CurrentAmtController = TextEditingController();
  TextEditingController DateController = TextEditingController();
  TextEditingController idcontroller = TextEditingController();

  TextEditingController TimeController = TextEditingController();

  FocusNode paidamountFocusNode = FocusNode();

  FocusNode CurrentAmountFocusNode = FocusNode();
  FocusNode remainingamtFocusnode = FocusNode();
  FocusNode PaytypeFocusnode = FocusNode();
  FocusNode RemainFocusnode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    fetchData();
    fetchVendorsName();
    fetchPaymenttype();
    controller = TextEditingController();
    _focusNode = FocusNode();
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

  List<Map<String, dynamic>> tableData = [];
  List<String> nameComboList = [];
  String? selectedValue;
  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> getFilteredData() {
    if (selectedValue == null || selectedValue!.isEmpty) {
      return tableData;
    }

    return tableData
        .where((data) => (data['vendorname'] ?? '')
            .toLowerCase()
            .contains(selectedValue!.toLowerCase()))
        .toList();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();

    String apiUrl = '$IpAddress/SalesFetchVendorPaymentcusid/$cusid';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      // List<Map<String, dynamic>> results =
      //     List<Map<String, dynamic>>.from(jsonData['results']);

      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Filter the results where "paidamount" is not equal to "TotalAmount"
      List<Map<String, dynamic>> filteredResults = results.where((item) {
        return item['paidamount'] != item['TotalAmount'];
      }).toList();

      setState(() {
        tableData = filteredResults;
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
    getFilteredData().forEach((data) {
      total += double.parse(data['FinalAmt'].toString());
    });
    return total;
  }

  void clearFilter() {
    setState(() {
      controller.text = "";
      selectedValue = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    totalAmount = calculateTotalAmount();
    int totalCount = getFilteredData().length;
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: HeadingStyle,
                ),
                SizedBox(height: 10),
                Divider(
                  color: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCombo('Vendors Name'),
                        SizedBox(width: 5),
                        _buildButton()
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 15,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Tap to explore more details',
                      style: textStyle,
                    )
                  ],
                ),
                SizedBox(height: 30),
                tableView(),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_left),
                        onPressed:
                            hasPreviousPage ? () => loadPreviousPage() : null,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '$currentPage / $totalPages',
                        style: commonLabelTextStyle,
                      ),
                      SizedBox(width: 5),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_right),
                        onPressed: hasNextPage ? () => loadNextPage() : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            "Count:",
                            style: textStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            totalCount.toString(),
                            style: commonLabelTextStyle,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 40,
                      ),
                      child: Text(
                        "Amount : ₹ $totalAmount",
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> PaymentTypeList = [];
  String? PaymentTypeSelectedValue;

  Future<void> fetchPaymenttype() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PaymentMethod/$cusid';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<String> fetchedPaytypes = [];

        for (var item in data) {
          String paymentType = item['paytype'];
          fetchedPaytypes.add(paymentType);
        }

        setState(() {
          PaymentTypeList = fetchedPaytypes;
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  int? _selectedPayTypeIndex;
  bool _PayTypefilterEnabled = true;
  int? _PayTypehoveredIndex;

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
                _selectedPayTypeIndex = currentIndex + 1;
                PaymentTypeController.text = PaymentTypeList[currentIndex + 1];
                _PayTypefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                PaymentTypeController.text = PaymentTypeList[currentIndex - 1];
                _PayTypefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: PaytypeFocusnode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(RemainFocusnode),
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
              _PayTypefilterEnabled = true;
              PaymentTypeSelectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_PayTypefilterEnabled && pattern.isNotEmpty) {
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
              _PayTypehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _PayTypehoveredIndex = null;
            }),
            child: Container(
              color: _selectedPayTypeIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedPayTypeIndex == null &&
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
            _PayTypefilterEnabled = false;
            FocusScope.of(context).requestFocus(RemainFocusnode);
          });
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void checkBalance() {
    double enteredAmount = double.tryParse(CurrentAmtController.text) ?? 0;
    double balanceAmount = double.tryParse(BalanceAmtController.text) ?? 0;
    print(
        "entered amount :: $enteredAmount    balanceamountt : $balanceAmount");
    if (enteredAmount <= balanceAmount) {
    } else {
      // Display error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Warning'),
          content: Text(
              'The entered amount {$enteredAmount} is greater than the balance amount {$balanceAmount}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                CurrentAmtController.clear();
                CurrentAmtController.text = balanceAmount.toString();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> updatePaidAmount(
      TextEditingController idController,
      TextEditingController dateController,
      TextEditingController timeController,
      TextEditingController paidController,
      TextEditingController currentAmtController,
      TextEditingController customernameController) async {
    String? cusid = await SharedPrefs.getCusId();
    String id = idController.text;
    String date = dateController.text;
    String time = timeController.text;

    try {
      // Ensure date is in the correct format
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      // Ensure time is in the correct format
      DateTime parsedTime;
      if (time.isNotEmpty) {
        parsedTime = DateFormat('HH:mm').parse(time);
      } else {
        // Set to default time if not provided
        parsedTime =
            DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 0, 0);
      }

      String formattedTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day,
              parsedTime.hour, parsedTime.minute));

      double paid = double.tryParse(paidController.text) ?? 0.0;
      double currentPaid = double.tryParse(currentAmtController.text) ?? 0.0;

      double newPaidAmt = paid + currentPaid;

      print(
          "date: $formattedDate, time: $formattedTime, paid amount: $paid, current entered amount: $currentPaid, new paid amount: $newPaidAmt");

      String updateUrl = '$IpAddress/SalesRoundDetailsalldatas/$id/';
      print("url: $updateUrl");

      // Prepare the data to be sent in the request body
      Map<String, dynamic> requestBody = {
        "cusid": cusid,
        "dt": formattedDate,
        "paidamount": newPaidAmt,
        "time": formattedTime
      };

      // Convert the requestBody to a JSON string
      String jsonData = jsonEncode(requestBody);

      // Send the PUT request
      http.Response response = await http.put(
        Uri.parse(updateUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Handle response here (e.g., check status codes, parse JSON response)
      if (response.statusCode == 200) {
        // Successful update
        print('Payment details updated successfully');
        AddSalesPaymentItems(customernameController);
      } else {
        // Handle errors or other status codes
        print(
            'Failed to update payment details: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during update: $e');
    }
  }

  void AddSalesPaymentItems(
      TextEditingController customernameController) async {
    if (CurrentAmtController.text.isEmpty ||
        RemainController.text.isEmpty ||
        PaymentTypeController.text.isEmpty) {
      WarninngMessage(context);
      return; // Ensure we exit early if the form is not filled out
    }

    try {
      String billno = billnocontroller.text;
      String name = customernameController.text;
      String contact = customercontactController.text;
      // print("contact: $contact");
      String paymenttype = PaymentTypeController.text;

      String amount = CurrentAmtController.text;

      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": cusid,
        "billno": billno,
        "cusname": name,
        "dt": currentDate,
        "amount": amount,
        "paytype": paymenttype
      };

      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/Vendorpayment/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      double amt = double.parse(CurrentAmtController.text);
      Post_salespaymentIncometbl(billno, amt, customernameController);

      if (response.statusCode == response.statusCode) {
        print('Data posted successfully');

        await logreports(
            "VendorSales Payment: ${billno}_${name}_${amount}_Inserted");
        Navigator.of(context).pop();
        billnocontroller.clear();
        customernameController.clear();
        paidController.clear();
        selectedValue = '';
        PaymentTypeController.text = '';
        RemainController.clear();
        TotalAmtController.clear();
        CurrentAmtController.clear();
        BalanceAmtController.clear();
        fetchData();
        successfullyUpdateMessage(context);
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        // Display appropriate error message to the user
        // For example, if status code is 500, display a generic error message
        billnocontroller.clear();
        customernameController.clear();
        paidController.clear();
        selectedValue = '';
        PaymentTypeController.text = '';
        RemainController.clear();
        TotalAmtController.clear();
        CurrentAmtController.clear();
        BalanceAmtController.clear();
        fetchData();
        Navigator.of(context).pop();
        if (response.statusCode == 500) {
        } else {
          // Handle other status codes as needed
          // displayErrorMessage("Custom error message");
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> Post_salespaymentIncometbl(String billno, double amount,
      TextEditingController customernameController) async {
    try {
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      String cusname = customernameController.text;
      print("customer name : $BalanceAmtController");
      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "description":
            "VendorSales Payment: $amount, VendorSales Bill: $billno, VendorName: ${cusname}",
        "dt": formattedDate,
        "amount": amount.toString()
      };
      print("posted datassssssss : $postData");

      String jsonData = jsonEncode(postData);

      var response = await http.post(
        Uri.parse('$IpAddress/Sales_IncomeDetails/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print(
            'Data posted successfully for bill no $billno with amount $amount');
      } else {
        print('Failed to post data. Error code: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
    }
  }

  void showPurchaseDetailsDialog(Map<String, dynamic> rowData) {
    TotalAmtController = TextEditingController(
        text:
            rowData['FinalAmt'] != null ? rowData['FinalAmt'].toString() : '');
    paidController = TextEditingController(
        text: rowData['paidamount'] != null
            ? rowData['paidamount'].toString()
            : '');
    double totalAmount = double.tryParse(TotalAmtController.text) ?? 0.0;
    double paidAmount = double.tryParse(paidController.text) ?? 0.0;
    double balanceAmount = totalAmount - paidAmount;
    BalanceAmtController =
        TextEditingController(text: balanceAmount.toStringAsFixed(2));

    billnocontroller = TextEditingController(
        text: rowData['billno'] != null ? rowData['billno'].toString() : '');
    customernameController = TextEditingController(
        text: rowData['vendorname'] != null
            ? rowData['vendorname'].toString()
            : '');
    idcontroller = TextEditingController(
        text: rowData['id'] != null ? rowData['id'].toString() : '');
    paidController = TextEditingController(
        text: rowData['paidamount'] != null
            ? rowData['paidamount'].toString()
            : '');

    DateController = TextEditingController(
        text: rowData['dt'] != null ? rowData['dt'].toString() : '');
    TimeController = TextEditingController(
        text: rowData['time'] != null ? rowData['time'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        billnocontroller.clear();
                        customernameController.clear();
                        paidController.clear();
                        selectedValue = '';
                        PaymentTypeController.text = '';
                        RemainController.clear();
                        TotalAmtController.clear();
                        CurrentAmtController.clear();
                        BalanceAmtController.clear();

                        fetchData();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 300,
              child: Column(
                children: [
                  Wrap(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BillNo',
                            style: commonLabelTextStyle,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              height: 24,
                              width: 100,
                              color: Colors.grey[200],
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: TextFormField(
                                    readOnly: true,
                                    controller:
                                        billnocontroller, // Provide the controller
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: const Color.fromARGB(
                                                0, 0, 0, 0),
                                            width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: textStyle),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Name',
                            style: commonLabelTextStyle,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              height: 24,
                              width: 100,
                              color: Colors.grey[200],
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: TextFormField(
                                    readOnly: true,
                                    controller:
                                        customernameController, // Provide the controller
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: const Color.fromARGB(
                                                0, 0, 0, 0),
                                            width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: textStyle),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: commonLabelTextStyle,
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 24,
                                width: 100,
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: TextFormField(
                                      controller: TotalAmtController,
                                      readOnly: true,
                                      // focusNode: paidamountFocusNode,
                                      textInputAction: TextInputAction.next,
                                      // onFieldSubmitted: (_) => _fieldFocusChange(
                                      //     context,
                                      //     paidamountFocusNode,
                                      //     PaytypeFocusnode),
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: textStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paid Amount',
                              style: commonLabelTextStyle,
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 24,
                                width: 100,
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: TextFormField(
                                      controller: paidController,
                                      readOnly: true,
                                      // focusNode: paidamountFocusNode,
                                      textInputAction: TextInputAction.next,
                                      // onFieldSubmitted: (_) => _fieldFocusChange(
                                      //     context,
                                      //     paidamountFocusNode,
                                      //     PaytypeFocusnode),
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: textStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance Amount',
                              style: commonLabelTextStyle,
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 24,
                                width: 100,
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: TextFormField(
                                      readOnly: true,
                                      controller: BalanceAmtController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  0, 0, 0, 0),
                                              width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: textStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Amount',
                              style: commonLabelTextStyle,
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 24,
                                width: 100,
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: CurrentAmtController,
                                      focusNode: CurrentAmountFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _fieldFocusChange(
                                              context,
                                              CurrentAmountFocusNode,
                                              PaytypeFocusnode),
                                      onChanged: (value) {
                                        checkBalance();
                                        double balanceAmount = double.tryParse(
                                                BalanceAmtController.text) ??
                                            0.0;

                                        double currentamt =
                                            double.tryParse(value) ?? 0.0;
                                        double remainingAmount =
                                            balanceAmount - currentamt;
                                        RemainController.text =
                                            remainingAmount.toString();
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: textStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pay Type',
                              style: commonLabelTextStyle,
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 24,
                                width: 100,
                                color: Colors.grey[200],
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: PaymentTypeDropdown()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remaining Amount',
                              style: commonLabelTextStyle,
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 24,
                                width: 100,
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: RemainController,
                                      focusNode: RemainFocusnode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _fieldFocusChange(
                                              context,
                                              RemainFocusnode,
                                              saveButtonFocusNode),
                                      onChanged: (value) {
                                        checkBalance();
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: textStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 20),
                        child: ElevatedButton(
                          focusNode: saveButtonFocusNode,
                          onPressed: () {
                            // _addStaffDetails();
                            // updatePaymentDetails();
                            updatePaidAmount(
                                idcontroller,
                                DateController,
                                TimeController,
                                paidController,
                                CurrentAmtController,
                                customernameController);
                            // AddSalesPaymentItems();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: subcolor,
                            padding: EdgeInsets.only(left: 7, right: 7),
                          ),
                          child: Text("Save", style: commonWhiteStyle),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchVendorPaymentDetails() async {
    final response = await http
        .get(Uri.parse('http://192.168.10.141:82/Vendorpayment/BTRM_23/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Assuming the response contains a list of data
      List<dynamic> data =
          jsonData['results']; // Adjust based on actual response structure

      // Process the data
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load vendor payment details');
    }
  }

  int? selectedRow;
  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.7 : 350,
          decoration: BoxDecoration(),
          child: SingleChildScrollView(
            child: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.80
                  : MediaQuery.of(context).size.width * 1.8,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.money,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text("BillNo",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text("Name",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text("PaidAmt",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pie_chart,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text("DisPerc",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_exchange_outlined,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
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
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_atm,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text("Perc",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Commision",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 500.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.money_off_csred_sharp,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text("Total",
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
                  ...getFilteredData().asMap().entries.map((entry) {
                    var index = entry.key;
                    var data = entry.value;
                    var billno = data['billno'].toString();
                    var dt = data['dt'].toString();
                    var vendorname = data['vendorname'].toString();
                    var paidamount = data['paidamount'].toString();
                    var disperc = data['disperc'].toString();
                    var FinalAmt = data['FinalAmt'].toString();
                    var vendorcomPerc = data['vendorcomPerc'].toString();
                    var CommisionAmt = data['CommisionAmt'].toString();
                    var TotalAmount = data['TotalAmount'].toString();
                    bool isEvenRow = tableData.indexOf(data) % 2 == 0;

                    Color? rowColor = isEvenRow
                        ? Color.fromARGB(224, 255, 255, 255)
                        : Color.fromARGB(224, 255, 255, 255);

                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 0.0, right: 0, top: 1.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedRow == index) {
                              selectedRow = null;
                            } else {
                              selectedRow = index;
                            }
                          });
                          showPurchaseDetailsDialog(data);
                        },
                        child: Container(
                          color: selectedRow == index
                              ? Color.fromARGB(255, 237, 230, 238)
                              : rowColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 30,
                                  width: 500.0,
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
                                  width: 500.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
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
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(vendorname,
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
                                      color: Color.fromARGB(255, 226, 225, 225),
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
                                  width: 500.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
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
                                  width: 500.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(FinalAmt,
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
                                      color: Color.fromARGB(255, 226, 225, 225),
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
                                  width: 500.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
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
                                  width: 500.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
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

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            clearFilter();
          });
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          backgroundColor: subcolor,
          minimumSize: Size(35.0, 28.0),
        ),
        child: Text(
          'Clear',
          style: commonWhiteStyle,
        ),
      ),
    );
  }

  Widget _buildCombo(String label) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person, size: 18),
          SizedBox(width: 3),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              label,
              style: commonLabelTextStyle,
            ),
          ),
          SizedBox(width: 5),
          Column(
            children: [
              Container(
                height: 24,
                width: 130,
                child: VendorsNameDropdown(
                    // initialValue: selectedValue,
                    // onChanged: (String? value) {
                    //   setState(() {
                    //     selectedValue = value;
                    //   });
                    // },
                    ),
              ),
            ],
          )
        ],
      ),
    );
  }

  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  Widget VendorsNameDropdown() {
    controller.text = selectedValue ?? '';

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = nameComboList.indexOf(controller.text);
            if (currentIndex < nameComboList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                controller.text = nameComboList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = nameComboList.indexOf(controller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                controller.text = nameComboList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
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
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return nameComboList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return nameComboList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = nameComboList.indexOf(suggestion);
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
                          nameComboList.indexOf(controller.text) == index
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
            controller.text = suggestion!;
            selectedValue = suggestion;
            _filterEnabled = false;
          });
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

  Future<void> fetchVendorsName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/VendorsName/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          nameComboList
              .addAll(results.map<String>((item) => item['Name'].toString()));
          //  print(nameComboList);
          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      //   print('All product categories: $EmployeeNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }
}
