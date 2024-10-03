import 'dart:convert';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

class AddSalesPointSetting extends StatefulWidget {
  const AddSalesPointSetting({Key? key}) : super(key: key);

  @override
  State<AddSalesPointSetting> createState() => _AddSalesPointSettingState();
}

class _AddSalesPointSettingState extends State<AddSalesPointSetting> {
  List<Map<String, dynamic>> tableData = [];

  final TextEditingController _pointController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  FocusNode pointFocus = FocusNode();
  FocusNode AmountFocus = FocusNode();

  String id = '';

  void initState() {
    super.initState();
    fetchData();
    fetchsidebarmenulist();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PointSetting/$cusid/';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> paylist = [];

      for (var item in data) {
        String? point = item['point'];
        String? amount = item['amount'];
        id = item['id'].toString();

        paylist.add({
          'point': point,
          'amount': amount,
        });
      }

      setState(() {
        tableData = paylist;
        if (tableData.isNotEmpty) {
          double? amount = double.tryParse(tableData.first['amount'] ?? '');
          _amountController.text =
              amount?.toStringAsFixed(amount % 1 == 0 ? 0 : 2) ?? '';

          double? point = double.tryParse(tableData.first['point'] ?? '');
          _pointController.text =
              point?.toStringAsFixed(point % 1 == 0 ? 0 : 2) ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: Row(
          children: [
            Expanded(
              flex: 10,
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'Point Setting',
                          style: HeadingStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          adminupdate(),
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
    );
  }

  Widget adminupdate() {
    return Center(
      child: Row(
        children: [
          if (Responsive.isDesktop(context))
            Center(
                child: Row(
              children: [
                SizedBox(
                  width: 50,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/imgs/point.png',
                        height: 400,
                        width: 400,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 50,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 500,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Color.fromARGB(255, 160, 158, 158)
                        //         .withOpacity(0.5),
                        //     spreadRadius: 5,
                        //     blurRadius: 7,
                        //     offset: Offset(0, 3),
                        //   ),
                        // ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Point',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 230,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: (_) => _fieldFocusChange(
                                        context, pointFocus, AmountFocus),
                                    focusNode: pointFocus,
                                    controller: _pointController,
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 230,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    focusNode: AmountFocus,
                                    controller: _amountController,
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: ElevatedButton(
                                  onPressed: updateData,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: subcolor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  child: Text(
                                    'Update',
                                    style: commonWhiteStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
          if (Responsive.isMobile(context))
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/point.png',
                      height: 350,
                      width: 350,
                    ),
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Point',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 230,
                                  child: TextFormField(
                                    focusNode: pointFocus,
                                    controller: _pointController,
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 230,
                                  child: TextFormField(
                                    focusNode: AmountFocus,
                                    controller: _amountController,
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: ElevatedButton(
                                  onPressed: updateData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: subcolor,
                                  ),
                                  child: Text(
                                    'Update',
                                    style: commonWhiteStyle,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }

  void WarninngMessage() {
    showDialog(
      barrierDismissible: false,
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
                    'Failed to update..!!',
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

  Future<void> updateData() async {
    try {
      final String point = _pointController.text;
      final String amount = _amountController.text;

      if (point.isNotEmpty && amount.isNotEmpty) {
        final Uri apiUrl = Uri.parse('$IpAddress/PointSettingalldatas/$id/');

        String? cusid = await SharedPrefs.getCusId();
        final Map<String, dynamic> data = {
          "cusid": "$cusid",
          "point": point,
          "amount": amount,
        };

        final response = await http.patch(
          apiUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic>? pointDetails = json.decode(response.body);

          if (pointDetails != null) {
            setState(() {
              _pointController.text = pointDetails['point'] ?? '';
              _amountController.text = pointDetails['amount'] ?? '';
            });
            await logreports(
                "Sales Point Setting: Point-${point}_Amount-${amount}_Updated");
            successfullyUpdateMessage(context);
          } else {
            WarninngMessage();
          }
        } else {
          WarninngMessage();
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.yellow,
              content: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.error, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Text(
                    'Kindly fill in both Point and Amount',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
      WarninngMessage();
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
