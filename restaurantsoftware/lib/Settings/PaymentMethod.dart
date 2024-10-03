import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'dart:convert';

import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

void main() {
  runApp(PaymentMethodSetting());
}

class PaymentMethodSetting extends StatefulWidget {
  @override
  State<PaymentMethodSetting> createState() => _PaymentMethodSettingState();
}

class _PaymentMethodSettingState extends State<PaymentMethodSetting> {
  final TextEditingController _paymentMethodController =
      TextEditingController();
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String searchText = '';

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['paytype'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PaymentMethod/$cusid/';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> paylist = [];

      for (var item in data) {
        int ID = item['id'];
        String payType = item['paytype'];

        paylist.add({
          'id': ID,
          'paytype': payType,
        });
      }

      paylist.sort((a, b) => a['id'].compareTo(b['id']));

      setState(() {
        tableData = paylist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method',
                style: HeadingStyle,
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.grey[300],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildAddButton(),
                  SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 20.0),
                    child: Container(
                      height: 30,
                      width: 140,
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
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          contentPadding:
                              EdgeInsets.only(left: 10.0, right: 4.0),
                        ),
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey[400],
              ),
              SizedBox(height: 10),
              Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.8 : 440,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              height: Responsive.isDesktop(context) ? 25 : 30,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payment,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Paytype",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: Responsive.isDesktop(context) ? 25 : 30,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Delete",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
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
                        var payType = data['paytype'].toString();

                        bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                        Color? rowColor = isEvenRow
                            ? Color.fromARGB(224, 255, 255, 255)
                            : Color.fromARGB(224, 255, 255, 255);

                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            top: 5.0,
                          ),
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
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      payType,
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
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(data);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 110,
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                _buildTextFieldAndButton(),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFieldAndButton() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Type',
                  style: commonLabelTextStyle,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 135,
                      child: TextFormField(
                        key: Key('paymentTypeField'),
                        autofocus: true,
                        controller: _paymentMethodController,
                        onFieldSubmitted: (_) {
                          _saveDataToAPI();
                        },
                        focusNode: _paymenttypeFocusNode,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveDataToAPI();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: subcolor,
                          minimumSize: Size(45.0, 31.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                      child: Text(
                        'Save',
                        style: commonWhiteStyle,
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

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: () {
          _showFormDialog(context);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          backgroundColor: subcolor,
          minimumSize: Size(45.0, 31.0),
        ),
        child: Text(
          'Add +',
          style: commonWhiteStyle,
        ),
      ),
    );
  }

  FocusNode _paymenttypeFocusNode = FocusNode();

  void _saveDataToAPI() async {
    String? paymentType = _paymentMethodController.text;

    if (paymentType == null || paymentType.isEmpty) {
      WarninngMessage(context);
      _paymentMethodController.text = "";
      _paymenttypeFocusNode.requestFocus();

      return;
    }

    if (isPaymentTypeAlreadyAdded(paymentType)) {
      showDuplicatePaymentTypeWarning();
      _paymentMethodController.text = "";
      _paymenttypeFocusNode.requestFocus();

      return;
    }

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PaymentMethodalldatas/';
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      'paytype': paymentType,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(postData),
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted) {
        if (response.statusCode == 201) {
          print('Data saved successfully');
          await logreports("Payment Method: ${paymentType}_Inserted");
          // Fetch updated data
          await fetchData();
          successfullySavedMessage(context);
          _paymentMethodController.text = "";
          _paymenttypeFocusNode.requestFocus();
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool isPaymentTypeAlreadyAdded(String? paymentType) {
    if (paymentType == null) return false;
    String paymentTypeLower = paymentType.toLowerCase();

    return tableData.any(
        (data) => data['paytype'].toString().toLowerCase() == paymentTypeLower);
  }

  void _deleteData(int id) async {
    String apiUrl = '$IpAddress/PaymentMethodalldatas/$id/';

    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    String? paymentType = _paymentMethodController.text;
    print('Delete Request: $apiUrl');
    print('Delete Response Status Code: ${response.statusCode}');
    print('Delete Response Body: ${response.body}');

    if (response.statusCode == 204) {
      print('Data deleted successfully');
      await logreports("Payment Method: ${paymentType}_Deleted");
      // Fetch updated data
      await fetchData();
      successfullyDeleteMessage(context);
    } else {
      print('Failed to delete data. Status code: ${response.statusCode}');
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(Map<String, dynamic> data) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete', style: commonLabelTextStyle),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this data?',
                style: textStyle,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteData(data['id']);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Delete', style: commonWhiteStyle),
            ),
          ],
        );
      },
    );
  }

  void showDuplicatePaymentTypeWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.yellow, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.yellowAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment method already exists..!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}
