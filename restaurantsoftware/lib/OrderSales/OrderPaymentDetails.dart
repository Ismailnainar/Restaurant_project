import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(OrderPaymentDetails());
}

class OrderPaymentDetails extends StatefulWidget {
  @override
  State<OrderPaymentDetails> createState() => _OrderPaymentDetailsState();
}

class _OrderPaymentDetailsState extends State<OrderPaymentDetails> {
  final TextEditingController CustomerNamecontroller = TextEditingController();
  final TextEditingController CustomerContactcontroller =
      TextEditingController();
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
    fetchCustomerName();
    fetchCustomerContact();
    fetchPaymenttype();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/OrderSalesRoundDetails/$cusid/?page=$currentPage&size=$pageSize';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);
    // print(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      // Filter the results where balanceamount != 0.0
      List<Map<String, dynamic>> filteredResults = results.where((data) {
        return data['balanceamount'] != "0.0";
      }).toList();

      setState(() {
        tableData = filteredResults;
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;
        // results.sort((a, b) => a['code'].compareTo(b['code']));
        // print("table datas : $tableData");
      });
    }
  }

  Future<void> fetchcustomernameordersales() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      if (cusid == null) {
        throw Exception("Customer ID is null");
      }

      String customerName = CustomerNamecontroller.text;
      String apiUrl =
          '$IpAddress/OrderSalesRoundDetails/$cusid/?page=$currentPage&size=$pageSize';
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        throw Exception("Failed to load data: ${response.statusCode}");
      }

      var jsonData = json.decode(response.body);
      // print("url data : ${response.body}");

      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Filter the results based on the customerName
        List<Map<String, dynamic>> filteredResults =
            results.where((order) => order['cusname'] == customerName).toList();

        List<Map<String, dynamic>> filteredBalance =
            filteredResults.where((data) {
          return data['balanceamount'] != "0.0";
        }).toList();

        // print("table data : ${filteredBalance}");

        setState(() {
          tableData = filteredBalance;
          hasNextPage = jsonData['next'] != null;
          hasPreviousPage = jsonData['previous'] != null;
          int totalCount = jsonData['count'];
          totalPages = (totalCount + pageSize - 1) ~/ pageSize;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchcustomerContactordersales() async {
    String? cusid = await SharedPrefs.getCusId();
    String CustomerContact = CustomerContactcontroller.text;
    String apiUrl =
        '$IpAddress/OrderSalesRoundDetails/$cusid/?page=$currentPage&size=$pageSize';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Filter the results based on the customerName
      List<Map<String, dynamic>> filteredResults = results
          .where((order) => order['contact'] == CustomerContact)
          .toList();

      List<Map<String, dynamic>> filteredBalance =
          filteredResults.where((data) {
        return data['balanceamount'] != "0.0";
      }).toList();

      setState(() {
        tableData = filteredBalance;
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;
      });
    }
  }

  List<String> ComboList = ['Name', 'Contact'];
  String? selectedValue;

  TextEditingController billnocontroller = TextEditingController();
  TextEditingController customernameController = TextEditingController();
  TextEditingController Selecttypecontroller = TextEditingController();
  TextEditingController PaymentTypeController = TextEditingController();
  TextEditingController BalanceAmtController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController RemainController = TextEditingController();

  FocusNode paidamountFocusNode = FocusNode();
  FocusNode PaytypeFocusnode = FocusNode();
  FocusNode RemainFocusnode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget Dropdown() {
    Selecttypecontroller.text = selectedValue ?? '';

    return TypeAheadFormField<String?>(
      textFieldConfiguration: TextFieldConfiguration(
        // focusNode: SupplierNameFocusNode,
        textInputAction: TextInputAction.next,
        // onSubmitted: (_) => _fieldFocusChange(
        //     context, SupplierNameFocusNode, PaymentTypeFocuNode),
        controller: Selecttypecontroller,

        decoration: InputDecoration(
            // labelText: ' ${selectedValue ?? ""}',

            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            )),
        style: DropdownTextStyle,
      ),
      suggestionsCallback: (pattern) {
        return ComboList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, String? suggestion) {
        return ListTile(
          dense: true,
          title: Text(
            suggestion ?? ' ${selectedValue ?? ''}',
            style: DropdownTextStyle,
          ),
        );
      },
      onSuggestionSelected: (String? suggestion) async {
        setState(() {
          selectedValue = suggestion;
          Selecttypecontroller.text = suggestion ?? ' ${selectedValue ?? ''}';
        });
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(maxHeight: 150),
      ),
    );
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

  String? CustomernamewselectedValue;
  Widget CustomerNameDropdown() {
    CustomerNamecontroller.text = CustomernamewselectedValue ?? '';

    return TypeAheadFormField<String?>(
      textFieldConfiguration: TextFieldConfiguration(
        // focusNode: SupplierNameFocusNode,
        textInputAction: TextInputAction.next,
        // onSubmitted: (_) => _fieldFocusChange(
        //     context, SupplierNameFocusNode, PaymentTypeFocuNode),
        controller: CustomerNamecontroller,

        decoration: InputDecoration(
            // labelText: ' ${selectedValue ?? ""}',

            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            )),
        style: DropdownTextStyle,
      ),
      suggestionsCallback: (pattern) {
        return CustomerNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, String? suggestion) {
        return ListTile(
          dense: true,
          title: Text(
            suggestion ?? ' ${CustomernamewselectedValue ?? ''}',
            style: DropdownTextStyle,
          ),
        );
      },
      onSuggestionSelected: (String? suggestion) async {
        setState(() {
          CustomernamewselectedValue = suggestion;
          CustomerNamecontroller.text =
              suggestion ?? ' ${CustomernamewselectedValue ?? ''}';
        });
        await fetchcustomernameordersales();
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(maxHeight: 150),
      ),
    );
  }

  List<String> CustomerContactList = [];

  Future<void> fetchCustomerContact() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/SalesCustomer/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          CustomerContactList.addAll(
              results.map<String>((item) => item['contact'].toString()));

          hasNextPage = data['contact'] != null;
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

  String? CustomerContactselectedValue;
  Widget CustomerContactDropdown() {
    CustomerContactcontroller.text = CustomerContactselectedValue ?? '';

    return TypeAheadFormField<String?>(
      textFieldConfiguration: TextFieldConfiguration(
        // focusNode: SupplierNameFocusNode,
        textInputAction: TextInputAction.next,
        // onSubmitted: (_) => _fieldFocusChange(
        //     context, SupplierNameFocusNode, PaymentTypeFocuNode),
        controller: CustomerContactcontroller,

        decoration: InputDecoration(
            // labelText: ' ${selectedValue ?? ""}',

            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            )),
        style: DropdownTextStyle,
      ),
      suggestionsCallback: (pattern) {
        return CustomerContactList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, String? suggestion) {
        return ListTile(
          dense: true,
          title: Text(
            suggestion ?? ' ${CustomerContactselectedValue ?? ''}',
            style: DropdownTextStyle,
          ),
        );
      },
      onSuggestionSelected: (String? suggestion) async {
        setState(() {
          CustomerContactselectedValue = suggestion;
          CustomerContactcontroller.text =
              suggestion ?? ' ${CustomerContactselectedValue ?? ''}';
        });
        await fetchcustomerContactordersales();
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(maxHeight: 150),
      ),
    );
  }

  Widget dropdown() {
    if (Selecttypecontroller.text == 'Name') {
      return CustomerNameDropdown();
    } else if (Selecttypecontroller.text == 'Contact') {
      return CustomerContactDropdown();
    } else {
      return CustomerNameDropdown(); // Or any default widget you want to display
    }
  }

  Future<void> fetchSalesDetails(Map<String, dynamic> data) async {
    String id = data["id"].toString(); // Convert Id to String
    final url = '$IpAddress/OrderSalesRoundDetailsalldetails/?id=$id';
    // print("url : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('results')) {
          try {
            List<dynamic> results = responseData['results'];
            showPurchaseDetailsDialog(data, results);
          } catch (e) {
            throw FormatException('Invalid purchasepaymentdetails format');
          }
        } else {
          throw Exception(
              'Invalid response format: purchasepaymentdetails not found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
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

  void checkBalance() {
    double enteredAmount = double.tryParse(paidController.text) ?? 0;
    double balanceAmount = double.tryParse(BalanceAmtController.text) ?? 0;

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
                paidController.text = balanceAmount.toString();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    BalanceAmtController.dispose();
    billnocontroller.dispose();
    CustomerContactcontroller.dispose();

    super.dispose();
  }

  void _addStaffDetails() async {
    try {
      String billno = billnocontroller.text;
      String customername = customernameController.text;
      String paidamount = paidController.text;
      String paytype = PaymentTypeController.text;
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String? cusid = await SharedPrefs.getCusId();
      // Prepare data to be posted
      Map<String, dynamic> postData = {
        "cusid": cusid,
        "billno": billno,
        "dt": currentDate,
        "cusname": customername,
        "amount": paidamount,
        "paytype": paytype,
        "des": "OrderPayment"
      };
      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/OrderPaymentalldatas/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        // Display appropriate error message to the user

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

  void _updateStaffDetails(String customerid, String Alreadypaidamount) async {
    try {
      String billno = billnocontroller.text;
      String customername = customernameController.text;
      // Parse already paid amount and balance to double
      double alreadyPaid = double.parse(Alreadypaidamount);
      double paidAmount = double.parse(paidController.text.toString());
      double balanceAmount = double.parse(RemainController.text.toString());

      // Calculate new paid amount
      double newPaidAmount = alreadyPaid + paidAmount;

      String? cusid = await SharedPrefs.getCusId();
      // Prepare data to be updated
      Map<String, dynamic> putdata = {
        "cusid": cusid,
        "paidamount": newPaidAmount.toString(),
        "balanceamount": balanceAmount.toString(),
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(putdata);

      // Make PUT request to the API
      String apiUrl =
          '$IpAddress/OrderSalesRoundDetailsalldetails/$customerid/';
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      if (response.statusCode == 200) {
        // Data updated successfully
        print('Data updated successfully');

        await logreports(
            'OrderSales Payment: ${billno}_${customername}_${paidAmount}_Paid');
        _clearFormFields();
        fetchData();
        Navigator.of(context).pop();
        successfullyUpdateMessage(context);
      } else {
        // Data updating failed
        print(
            'Failed to update data: ${response.statusCode}, ${response.body}');
        // You might want to show an error message to the user here.
      }
    } catch (e) {
      // Handle any exceptions
      print('Error updating data: $e');
      // You might want to show an error message to the user here.
    }
  }

  void _clearFormFields() {
    paidController.clear();
    RemainController.clear();
    PaymentTypeSelectedValue = '';
  }

  void showPurchaseDetailsDialog(
      Map<String, dynamic> rowData, List<dynamic> results) {
    BalanceAmtController =
        TextEditingController(text: rowData['balanceamount'] ?? '');
    billnocontroller = TextEditingController(text: rowData['billno'] ?? '');
    customernameController =
        TextEditingController(text: rowData['cusname'] ?? '');

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
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
                                          color:
                                              const Color.fromARGB(0, 0, 0, 0),
                                          width: 1.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 7.0,
                                    ),
                                  ),
                                  style: textStyle,
                                ),
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
                                  padding:
                                      const EdgeInsets.only(left: 5.0, top: 5),
                                  child: Text(rowData['amount'] ?? '',
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
                                    controller:
                                        BalanceAmtController, // Provide the controller
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
                                    style: textStyle,
                                  ),
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
                                      keyboardType: TextInputType.number,
                                      controller: paidController,
                                      focusNode: paidamountFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _fieldFocusChange(
                                              context,
                                              paidamountFocusNode,
                                              PaytypeFocusnode),
                                      onChanged: (value) {
                                        checkBalance();
                                        double balanceAmount = double.tryParse(
                                                BalanceAmtController.text) ??
                                            0.0;
                                        double paidAmount =
                                            double.tryParse(value) ?? 0.0;
                                        double remainingAmount =
                                            balanceAmount - paidAmount;
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
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
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
                                      style: AmountTextStyle),
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
                            _addStaffDetails();
                            _updateStaffDetails(
                              rowData['id'].toString(),
                              rowData['paidamount'].toString(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: subcolor,
                              padding: EdgeInsets.only(left: 7, right: 7),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildCombo('Search type'),
                    SizedBox(
                      width: 10,
                    ),
                    _buildTextField(),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        height:
                            28, // Increase the height to allow for proper centering
                        width:
                            28, // Adjust the width to be the same as the height for centering
                        child: ElevatedButton(
                          onPressed: () {
                            fetchData();
                            selectedValue = '';
                            CustomernamewselectedValue = '';
                            CustomerContactselectedValue = '';
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: subcolor,
                              padding: EdgeInsets
                                  .zero, // Remove any padding from the button
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                          child: Center(
                            // Center the icon within the button
                            child: Icon(
                              Icons.refresh,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey[400],
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 20),
                SingleChildScrollView(
                  child: Container(
                    height: Responsive.isDesktop(context)
                        ? screenHeight * 0.8
                        : 350,
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(children: [
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.notes_outlined,
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
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.calendar_month_outlined,
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
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_2_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("CusName",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.call_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("Contact",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.attach_money_outlined,
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
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.discount_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("Dis",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.payment,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("PayableAmt",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.paid,
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
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 35,
                                      width: 500.0,
                                      decoration: TableHeaderColor,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.balance,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("BalAmt",
                                                  textAlign: TextAlign.center,
                                                  style: commonLabelTextStyle),
                                            ],
                                          ),
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
                                var billno = data['billno'].toString();
                                var dt = data['dt'].toString();
                                var cusname = data['cusname'].toString();
                                var contact = data['contact'].toString();
                                var amount = data['amount'].toString();
                                var discount = data['discount'].toString();
                                var payableamount =
                                    data['payableamount'].toString();
                                var paidamount = data['paidamount'].toString();
                                var balanceamount =
                                    data['balanceamount'].toString();

                                bool isEvenRow =
                                    tableData.indexOf(data) % 2 == 0;
                                Color? rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 255, 255, 255);
                                // print("Table viewwwww : $tableData");

                                return GestureDetector(
                                  onTap: () {
                                    fetchSalesDetails(data);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0,
                                        right: 5.0,
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
                                            width: 500.0,
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
                                                  style: textStyle),
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
                                              child: Text(dt,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                                              child: Text(cusname,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                                              child: Text(contact,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                                                  style: textStyle),
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
                                              child: Text(discount,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                                              child: Text(payableamount,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                                              child: Text(paidamount,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                                              child: Text(balanceamount,
                                                  textAlign: TextAlign.center,
                                                  style: textStyle),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCombo(String label,
      {String? initialValue, Function(String?)? onSelect}) {
    return Container(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: commonLabelTextStyle,
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 120,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Dropdown();
                      },
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          width: 135,
          height: 51,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Value',
                style: commonLabelTextStyle,
              ),
              SizedBox(height: 5),
              Container(
                height: 24,
                width: 120,
                child: dropdown(),
              ),
            ],
          ),
        );
      },
    );
  }
}
