import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Settings/AddProductsDetails.dart';
import 'package:restaurantsoftware/Settings/PaymentMethod.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';
import 'package:restaurantsoftware/VendorSales/Config/VendorCustomer.dart';

class NewVendorSalesEntry extends StatefulWidget {
  const NewVendorSalesEntry({Key? key}) : super(key: key);

  @override
  State<NewVendorSalesEntry> createState() => _NewVendorSalesEntryPageState();
}

class _NewVendorSalesEntryPageState extends State<NewVendorSalesEntry> {
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  @override
  void initState() {
    fetchPaytype();
    fetchVendorsName();
    fetchAllProductName();
    fetchGstData();
    fetchSalesFinalSerialNo();
    fetchLastBillNoDatas().then((data) {
      setState(() {
        lastbillData = data;
      });
    });
    _typeController.text = selectedType ?? '';
    super.initState();
    // _billNoController.text = "50";
    _RateController.text = "0";
    _QtyController.text = "0";
    _TotalAmtController.text = "0.0";
    _DisPercController.text = "0";
    _DisAmtController.text = "0";
    _CgstController.text = "0";
    _SgstController.text = "0";
  }

  String gstName = "";
  String? gstStatus;

  Future<void> fetchGstData() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      http.Response response =
          await http.get(Uri.parse('$IpAddress/GstDetails/$cusid'));
      var GstData = json.decode(response.body);

      var vendorSales = GstData.firstWhere(
          (entry) => entry['name'] == 'VendorSales',
          orElse: () => null);

      if (vendorSales != null) {
        setState(() {
          gstName = vendorSales['gst'];
          gstStatus = vendorSales['status'];
        });
      } else {
        print('VendorSales entry not found.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  TextEditingController BillnoController = TextEditingController();
  Future<String> fetchSalesSerialNo() async {
    String newSerialNo = '';
    String? cusid = await SharedPrefs.getCusId();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Vendor_Sno/$cusid/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if the orderserialno is directly in jsonData and not a list
        if (jsonData.containsKey('serialno')) {
          String serialNo = jsonData['serialno'].toString();

          // If orderserialno is "0", set newSerialNo to "OS1"
          if (serialNo == "0") {
            // Directly accessing the integer value for orderserialno
            int maxSerialNumber = jsonData['serialno'] ?? 0;

            // Increment the serial number by 1 and prepend "OS"
            newSerialNo = 'VS' + (maxSerialNumber + 1).toString();
          } else if (serialNo.startsWith('VS')) {
            // If orderserialno starts with 'OS', increment the number part
            int parsedSerialNo = int.tryParse(serialNo.substring(2)) ?? 0;
            newSerialNo = 'VS' + (parsedSerialNo + 1).toString();
          } else {
            // Handle any other unexpected formats if necessary
            print('Unexpected serial number format');
          }
        } else {
          print('Failed to find orderserialno in response');
        }
      } else {
        print('Failed to load sales serial numbers');
      }
    } catch (e) {
      print('Error: $e');
    }

    return newSerialNo;
  }

  List<Map<String, String>> lastbillData = [];

  Future<List<Map<String, String>>> fetchLastBillNoDatas() async {
    lastbillData.clear();
    String? cusid = await SharedPrefs.getCusId();
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String baseUrl = '$IpAddress/SalesRoundAndDetails/$cusid/';
    int page = 1;

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

              lastbillData.add({
                'id': id,
                'billno': entry['billno'],
                'finalamount': entry['finalamount'],
              });
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
          // print('Response body: ${response.body}');
          break;
        }
      } catch (e) {
        print('Error: $e');
        break;
      }
    }

    return lastbillData;
  }

  Future<void> fetchSalesFinalSerialNo() async {
    // String amcSerialNo = await fetchAmcSerialNo();
    String addedSerialNo = await fetchSalesSerialNo();
    String billNoText = '$addedSerialNo';

    BillnoController.text = billNoText;
    // print("bill no : $billNoText = $amcSerialNo-$addedSerialNo ");
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    // Parse the serial number from the text field
    String? incrementedSerialNo;
    try {
      incrementedSerialNo = BillnoController.text.toString();
    } catch (e) {
      print('Failed to parse serial number: $e');
      return; // Exit the function if parsing fails
    }

    // print("Bill no: $incrementedSerialNo");

    String? cusid = await SharedPrefs.getCusId();
    // Prepare the data to be sent
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "serialno": incrementedSerialNo,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);

    try {
      // Send the POST request
      var response = await http.post(
        Uri.parse('$IpAddress/Vendor_Snoalldata/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 201) {
        print('Data posted successfully');

        fetchSalesFinalSerialNo();
        successfullySavedMessage(context);
        fetchSalesFinalSerialNo();
      } else {
        fetchSalesFinalSerialNo();
        print('Response body: ${response.statusCode}');
      }
    } catch (e) {
      // print('Failed to post data. Error: $e');
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Vendor Bill", style: HeadingStyle),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Row(
                        children: [
                          Text('Gst Status : ', style: commonLabelTextStyle),
                          Text(
                            gstName,
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 29, 148, 33)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                _buildTopWidget(),
                if (Responsive.isDesktop(context))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [tableView(), LastBillTable()],
                      ),
                      Row(
                        children: [
                          _buildBottomWidget(),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                if (Responsive.isMobile(context))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      _buildNoOfItemText('No.Of.Items : '),
                      SizedBox(height: 10),
                      tableView(),
                      SizedBox(height: 10),
                      _buildBottomWidget(),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: LastBillTable(),
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

  Widget _buildTopWidget() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildBillNoText(),
                    SizedBox(
                      width: 10,
                    ),
                    _buildtypeComboBoxMain('Type'),
                    SizedBox(
                      width: 10,
                    ),
                    _buildPayTypeDropdown('PayType'),
                    SizedBox(
                      width: 10,
                    ),
                    _buildVendorNameDropdown('Vendors Name'),
                    SizedBox(
                      width: 10,
                    ),
                    _buildVendorPercText('Vendors %'),
                    SizedBox(
                      width: 10,
                    ),
                    _buildOrderNoText('Order No'),
                  ],
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    _buildCodeText('Code'),
                    SizedBox(
                      width: 10,
                    ),
                    _buildProductNameDropdown('Item : '),
                    SizedBox(
                      width: 20,
                    ),
                    _buildRateText('Rate : '),
                    SizedBox(
                      width: 10,
                    ),
                    _buildQtyText('Qty : '),
                    SizedBox(
                      width: 15,
                    ),
                    _buildTotalAmtText('Total : '),
                    SizedBox(
                      width: 10,
                    ),
                    AddAndDeleteButton(),
                  ],
                )
              ],
            ),
          ),
        if (Responsive.isMobile(context))
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBillNoText(),
                      _buildtypeComboBoxMain('Type'),
                      _buildPayTypeDropdown('PayType')
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildVendorNameDropdown('Vendors Name'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildVendorPercText('Vendors %'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildOrderNoText('Order No'),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildProductNameDropdown('Item : '),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCodeText('Code'),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildRateText('Rate : '),
                    SizedBox(
                      width: 15,
                    ),
                    _buildQtyText('Qty : '),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTotalAmtText('Total : '),
                    SizedBox(
                      width: 15,
                    ),
                    AddAndDeleteButton(),
                  ],
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomWidget() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    _buildNoOfItemText('No.Of.Items : '),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    _buildTaxableAmtText('Taxable Amount'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildDisPercText('Dis '),
                    SizedBox(
                      width: 20,
                    ),
                    _buildDisAmtText('Dis Amount'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildFinTaxText('Final Taxable ₹'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildCgstText('CGST Value'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildSgstText('SGST Value'),
                    SizedBox(
                      width: 20,
                    ),
                    _buildAmountText('Amount'),
                    SizedBox(
                      width: 20,
                    ),
                    SaveAndRefreshButton(),
                  ],
                ),
              ],
            ),
          ),
        if (Responsive.isMobile(context))
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTaxableAmtText('Taxable Amount'),
                      SizedBox(
                        width: 40,
                      ),
                      _buildDisPercText('Dis '),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildDisAmtText('Dis Amount'),
                      SizedBox(
                        width: 50,
                      ),
                      _buildFinTaxText('Final Taxable ₹')
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCgstText('CGST Value'),
                      SizedBox(
                        width: 50,
                      ),
                      _buildSgstText('SGST Value'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildAmountText('Amount'),
                      SizedBox(
                        width: 50,
                      ),
                      SaveAndRefreshButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget LastBillTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Last Bill',
                  style: HeadingStyle,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context)
                          ? screenHeight * 0.60
                          : 320,
                      decoration: BoxDecoration(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          width: Responsive.isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.18
                              : MediaQuery.of(context).size.width * 0.8,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: Responsive.isDesktop(context)
                                              ? 25
                                              : 30,
                                          width: 265.0,
                                          decoration: TableHeaderColor,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.money,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("BillNo",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
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
                                          width: 265.0,
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
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (lastbillData.isNotEmpty)
                                  ...lastbillData.map((data) {
                                    var id = data['id'].toString();
                                    var billno = data['billno'].toString();
                                    var amount = data['finalamount'].toString();
                                    bool isEvenRow =
                                        lastbillData.indexOf(data) % 2 == 0;

                                    Color? rowColor = isEvenRow
                                        ? Color.fromARGB(224, 255, 255, 255)
                                        : Color.fromARGB(224, 255, 255, 255);

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 0.0,
                                        right: 0,
                                      ),
                                      child: GestureDetector(
                                        onDoubleTap: () {
                                          _showDetailsForm(data);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  child: Text(billno,
                                                      textAlign:
                                                          TextAlign.center,
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
                                                  child: Text(amount,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TableRowTextStyle),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList()
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
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'If double click on the billno you can view the\n bill details',
                  style: textStyle,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  int? selectedRow;
  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
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
          child: SingleChildScrollView(
            child: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.61
                  : MediaQuery.of(context).size.width * 1.8,
              height: Responsive.isDesktop(context) ? screenHeight * 0.7 : 320,
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
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fastfood_sharp,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Item",
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
                          width: 265.0,
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
                                Text(
                                  "Rate",
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
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_box,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Qty",
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
                          width: 265.0,
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
                                Text(
                                  "Cgst",
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
                          width: 265.0,
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
                                Text(
                                  "Sgst",
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
                          width: 265.0,
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
                                Text(
                                  "Amt",
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
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 2),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    width: 45,
                                    child: Text(
                                      "Taxable",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 265.0,
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
                                Text(
                                  "Cgst %",
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
                          width: 265.0,
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
                                Text(
                                  "Sgst%",
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
                          width: 265.0,
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
                    var prodname = data['prodname'].toString();
                    var rate = data['rate'].toString();
                    var qty = data['qty'].toString();
                    var cgst = data['cgst'].toString();
                    var sgst = data['sgst'].toString();
                    var amount = data['amount'].toString();
                    var taxable = data['taxable'].toString();
                    var cgstper = data['cgstPerc'].toString();
                    var sgstper = data['sgstPerc'].toString();

                    bool isEvenRow = index % 2 == 0;
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
                              selectedRow =
                                  null; // Deselect the row if it's already selected
                            } else {
                              selectedRow = index;
                            }
                          });
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
                                  width: 265.0,
                                  decoration: BoxDecoration(
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Tooltip(
                                    message: prodname,
                                    child: Center(
                                      child: Text(prodname,
                                          textAlign: TextAlign.center,
                                          style: TableRowTextStyle),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  width: 265.0,
                                  decoration: BoxDecoration(
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(rate,
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
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(qty,
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
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(cgst,
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
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(sgst,
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
                                    // color: rowColor,
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
                              Flexible(
                                child: Container(
                                  height: 30,
                                  width: 265.0,
                                  decoration: BoxDecoration(
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(taxable,
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
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cgstper,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  width: 265.0,
                                  decoration: BoxDecoration(
                                    // color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      sgstper,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            _deleteTableData(index);
                                          },
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
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

  void _deleteTableData(int index) {
    setState(() {
      if (index >= 0 && index < tableData.length) {
        tableData.removeAt(index);
      }
    });
  }

// Type

  Widget _buildtypeComboBoxMain(String label) {
    return Container(
      // color: Subcolor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: Responsive.isDesktop(context) ? 5 : 5, top: 10),
            child: Text(
              label,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 5.0, bottom: 8.0, top: 6.0, right: 6.0),
            child: Row(
              children: [
                Container(height: 23, width: 120, child: TypeDropdown()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController _typeController = TextEditingController();
  List<String> TypeList = ['DineIn', 'TakeAway'];
  String? selectedType = 'TakeAway';
  Widget TypeDropdown() {
    _typeController.text = selectedType ?? '';

    return TypeAheadFormField<String?>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _typeController,
        decoration: InputDecoration(
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: maincolor,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 10, left: 5),
          labelStyle: DropdownTextStyle,
        ),
        style: DropdownTextStyle,
        onSubmitted: (value) {
          setState(() {
            selectedType = null;
            _typeController.clear();
          });
        },
      ),
      suggestionsCallback: (pattern) {
        // Replace with your actual suggestion logic
        return TypeList.where(
          (item) => item.toLowerCase().contains(pattern.toLowerCase()),
        ).toList();
      },
      itemBuilder: (context, String? suggestion) {
        return Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                suggestion ?? '',
                style: DropdownTextStyle,
              ),
            ],
          ),
        );
      },
      noItemsFoundBuilder: (context) {
        return Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'No items found!!!',
                style: DropdownTextStyle,
              ),
            ],
          ),
        );
      },
      onSuggestionSelected: (String? suggestion) {
        setState(() {
          selectedType = suggestion;
          _typeController.text = suggestion ?? ' ${selectedType ?? ''}';
        });
      },
    );
  }

// BillNo

  Widget _buildBillNoText() {
    return Row(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BillNo : ",
                  style: commonLabelTextStyle,
                ),
                Text(
                  BillnoController.text,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            ShowBillnoIncreaeMessage();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: subcolor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 6,
                  right: 6,
                ),
                child: Text(
                  "+",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void ShowBillnoIncreaeMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.question_mark_rounded,
                color: maincolor,
              ),
              SizedBox(width: 10), // Spacing between icon and text
              Expanded(
                child: Text(
                  'Do you want to increase your addstock bill number?',
                  style: textStyle.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    postDataWithIncrementedSerialNo();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize:
                        Size(50.0, 30.0), // Adjust size for better look
                  ),
                  child: Text('Yes',
                      style: TextStyle(color: sidebartext, fontSize: 12)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize:
                        Size(50.0, 30.0), // Adjust size for better look
                  ),
                  child: Text('No',
                      style: TextStyle(color: sidebartext, fontSize: 12)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
// PayType

  Widget _buildPayTypeDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Container(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: commonLabelTextStyle),
                SizedBox(height: 5),
                Container(height: 23, width: 120, child: Paymenttypedropdown()),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    child: Container(
                      width: 1000,
                      height: 800,
                      padding: EdgeInsets.all(10),
                      child: Stack(
                        children: [
                          PaymentMethodSetting(),
                          Positioned(
                            right: 0.0,
                            top: 0.0,
                            child: IconButton(
                              icon: Icon(Icons.cancel,
                                  color: Colors.red, size: 23),
                              onPressed: () {
                                Navigator.of(context).pop();
                                fetchPaytype();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: subcolor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  TextEditingController _PaytypeController = TextEditingController();
  String? selectedPaytype;
  List<String> PaytypeList = [];
  FocusNode PaymentTypeFocus = FocusNode();

  int? _selectedPayTypeIndex;
  bool _PayTypefilterEnabled = true;
  int? _PayTypehoveredIndex;

  Widget Paymenttypedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = PaytypeList.indexOf(_PaytypeController.text);
            if (currentIndex < PaytypeList.length - 1) {
              setState(() {
                _selectedPayTypeIndex = currentIndex + 1;
                _PaytypeController.text = PaytypeList[currentIndex + 1];
                _PayTypefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = PaytypeList.indexOf(_PaytypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                _PaytypeController.text = PaytypeList[currentIndex - 1];
                _PayTypefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: PaymentTypeFocus,
          onSubmitted: (_) =>
              _fieldFocusChange(context, PaymentTypeFocus, VendorNameFocus),
          controller: _PaytypeController,
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
              selectedPaytype = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_PayTypefilterEnabled && pattern.isNotEmpty) {
            return PaytypeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return PaytypeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = PaytypeList.indexOf(suggestion);
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
                          PaytypeList.indexOf(_PaytypeController.text) == index
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
            _PaytypeController.text = suggestion!;
            selectedPaytype = suggestion;
            _PayTypefilterEnabled = false;
            FocusScope.of(context).requestFocus(VendorNameFocus);
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

// VendorName
  FocusNode VendorNameFocus = FocusNode();
  TextEditingController _VendorNameController = TextEditingController();
  List<String> VendorNameList = [];
  String? selectedVendorName;

  int? _selectedVendorIndex;
  bool _VendNamefilterEnabled = true;
  int? _VendNamehoveredIndex;

  Widget VendorsNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                VendorNameList.indexOf(_VendorNameController.text);
            if (currentIndex < VendorNameList.length - 1) {
              setState(() {
                _selectedVendorIndex = currentIndex + 1;
                _VendorNameController.text = VendorNameList[currentIndex + 1];
                _VendNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                VendorNameList.indexOf(_VendorNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedVendorIndex = currentIndex - 1;
                _VendorNameController.text = VendorNameList[currentIndex - 1];
                _VendNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: VendorNameFocus,
          textInputAction: TextInputAction.next,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedVendorName = suggestion;
              _VendorNameController.text = suggestion!;
              _VendNamefilterEnabled = false;
              _fieldFocusChange(context, VendorNameFocus, _OrderNofocus);
            });

            try {
              await fetchVendorPercByProdName();
            } catch (e) {
              print('Error in onSuggestionSelected: $e');
            }
          },
          controller: _VendorNameController,
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
              _VendNamefilterEnabled = true;
              selectedVendorName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_VendNamefilterEnabled && pattern.isNotEmpty) {
            return VendorNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return VendorNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = VendorNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _VendNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _VendNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedVendorIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedVendorIndex == null &&
                          VendorNameList.indexOf(_VendorNameController.text) ==
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
          // debugPrint('You just selected $value');
          setState(() {
            selectedVendorName = suggestion;
            _VendorNameController.text = suggestion!;
            _VendNamefilterEnabled = false;
          });

          try {
            await fetchVendorPercByProdName();
            FocusScope.of(context).requestFocus(_OrderNofocus);
          } catch (e) {
            print('Error in onSuggestionSelected: $e');
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

  Widget _buildVendorNameDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Container(
            width: 130, // Adjust the width as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: commonLabelTextStyle,
                ),
                SizedBox(height: 5),
                Container(height: 23, width: 150, child: VendorsNameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),

                      child: SingleChildScrollView(
                        scrollDirection: Axis
                            .horizontal, // Set scrolling direction to horizontal
                        child: Container(
                          width: Responsive.isDesktop(context)
                              ? 1300
                              : 300, // Set a fixed width for horizontal scrolling
                          padding: EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              Container(
                                width:
                                    1500, // Ensure width matches the container's width
                                height:
                                    800, // Ensure height is appropriate for your content
                                child: VendorCustomer(), // Your custom content
                              ),
                              Positioned(
                                right: 10.0,
                                top: 5.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchVendorsName(); // Call the function after closing dialog
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // child: Container(
                      //   width: 1500,
                      //   height: 800,
                      //   padding: EdgeInsets.all(10),
                      //   child: Stack(
                      //     children: [
                      //       VendorCustomer(),
                      //       Positioned(
                      //         right: 15.0,
                      //         top: 5.0,
                      //         child: IconButton(
                      //           icon: Icon(Icons.cancel,
                      //               color: Colors.red, size: 23),
                      //           onPressed: () {
                      //             Navigator.of(context).pop();
                      //             fetchVendorsName();
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: subcolor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

// VendorPerc

  TextEditingController _VendorPercController = TextEditingController();
  Widget _buildVendorPercText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 80 : 80,
                      child: Container(
                        height: 23,
                        width: 50,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _VendorPercController,
                          // focusNode: _qtyfocus,
                          readOnly: true,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade100, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade100, width: 1.0),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// OrderNo
  FocusNode _OrderNofocus = FocusNode();
  TextEditingController _OrderNoController = TextEditingController();
  Widget _buildOrderNoText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 80 : 80,
                      child: Container(
                        height: 23,
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _OrderNoController,
                          onSubmitted: (_) => _fieldFocusChange(
                              context, _OrderNofocus, ProdNameFocus),
                          focusNode: _OrderNofocus,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade100, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade100, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: textStyle,
                        ),
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

// Code
  String? code = "";
  Widget _buildCodeText(String label) {
    return Row(
      children: [
        Container(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Code : ",
                  style: textStyle,
                ),
                Text(
                  "$code",
                  style: commonLabelTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

//Prodname
  TextEditingController _ProductNameController = TextEditingController();
  List<String> ProductNameList = [];

  String? selectedProductName;
  FocusNode ProdNameFocus = FocusNode();
  int? _selectedProdIndex;

  bool _ProdNamefilterEnabled = true;
  int? _ProdNamehoveredIndex;

  Widget ProductNamedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(_ProductNameController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProdIndex = currentIndex + 1;
                _ProductNameController.text = ProductNameList[currentIndex + 1];
                _ProdNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(_ProductNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProdIndex = currentIndex - 1;
                _ProductNameController.text = ProductNameList[currentIndex - 1];
                _ProdNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: ProdNameFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedProductName = suggestion;
              _ProductNameController.text = suggestion!;
              _ProdNamefilterEnabled = false;
              _fieldFocusChange(context, ProdNameFocus, _Qtyfocus);
            });

            try {
              await fetchCodeByProdName();
              await fetchRateByProdName();

              FocusScope.of(context).requestFocus(_Qtyfocus);
            } catch (e) {
              print('Error in onSuggestionSelected: $e');
            }
          },
          controller: _ProductNameController,
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
              _ProdNamefilterEnabled = true;
              selectedProductName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_ProdNamefilterEnabled && pattern.isNotEmpty) {
            return ProductNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProdNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProdNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProdIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProdIndex == null &&
                          ProductNameList.indexOf(
                                  _ProductNameController.text) ==
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
            selectedProductName = suggestion;
            _ProductNameController.text = suggestion!;
            _ProdNamefilterEnabled = false;
          });

          try {
            await fetchCodeByProdName();
            await fetchRateByProdName();

            FocusScope.of(context).requestFocus(_Qtyfocus);
          } catch (e) {
            print('Error in onSuggestionSelected: $e');
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

  Widget _buildProductNameDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Row(
        children: [
          Icon(Icons.fastfood_sharp, size: 18),
          SizedBox(width: 3),
          Text(
            label,
            style: commonLabelTextStyle,
          ),
          Container(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Container(height: 23, width: 150, child: ProductNamedropdown()),
              ],
            ),
          ),
          SizedBox(width: 3),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        width: 1200,
                        height: 800,
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            AddProductDetailsPage(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchAllProductName();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                color: subcolor,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Rate
  TextEditingController _RateController = TextEditingController();
  Widget _buildRateText(String label) {
    return Row(
      children: [
        Icon(Icons.currency_rupee_outlined, size: 18),
        Padding(
          padding: EdgeInsets.all(
            0.0,
          ),
          child: Text(
            label,
            style: commonLabelTextStyle,
          ),
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 50 : 80,
                      child: Container(
                        height: 23,
                        width: 50,
                        child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _RateController,
                            // focusNode: _qtyfocus,
                            readOnly: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: AmountTextStyle),
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

  List<Map<String, dynamic>> productList = [];
  Future<List<Map<String, dynamic>>> salesProductList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          for (var product in results) {
            // Extracting required fields and creating a map
            Map<String, dynamic> productMap = {
              'id': product['id'],
              'name': product['name'],
              'stock': product['stock'],
              'stockvalue': product['stockvalue']
            };

            // Adding the map to the list
            productList.add(productMap);
          }
          // print("product list : $productList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }

    return productList;
  }

// Qty
  TextEditingController _QtyController = TextEditingController();
  FocusNode _Qtyfocus = FocusNode();
  Widget _buildQtyText(String label) {
    return Row(
      children: [
        Icon(Icons.production_quantity_limits, size: 18),
        Padding(
          padding: EdgeInsets.all(
            0.0,
          ),
          child: Text(
            label,
            style: commonLabelTextStyle,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10, top: 0),
              child: Row(
                children: [
                  Container(
                    width: Responsive.isDesktop(context) ? 50 : 80,
                    child: Container(
                      height: 23,
                      width: 50,
                      child: TextField(
                        onSubmitted: (String value) {
                          String productName = _ProductNameController.text;
                          int quantity = int.tryParse(value) ?? 0;

                          salesProductList()
                              .then((List<Map<String, dynamic>> productList) {
                            Map<String, dynamic>? product =
                                productList.firstWhere(
                              (element) => element['name'] == productName,
                              orElse: () => {'stock': 'no'},
                            );

                            String stockStatus = product['stock'];

                            if (stockStatus == 'No') {
                              FocusScope.of(context).requestFocus(_TotAmtFocus);
                            } else if (stockStatus == 'Yes') {
                              double stockValue = double.tryParse(
                                      product['stockvalue'].toString()) ??
                                  0;

                              if (quantity > stockValue) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Stock Check'),
                                        IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    content: Container(
                                      width: 500,
                                      child: Text(
                                          'The entered quantity exceeds the available stock value (${stockValue}). '
                                          'Do you want to proceed by deducting this excess quantity from the stock?'),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Yes Add'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _QtyController.text =
                                                  stockValue.toString();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Skip'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {}
                            }
                          });
                        },
                        onChanged: (value) {
                          // Parse rate and quantity
                          double rate =
                              double.tryParse(_RateController.text) ?? 0;
                          double qty = double.tryParse(value) ?? 0;

                          // Calculate total amount
                          double totalAmount = rate * qty;

                          // Update total amount controller
                          _TotalAmtController.text =
                              totalAmount.toStringAsFixed(2);
                        },
                        keyboardType: TextInputType.number,
                        controller: _QtyController,
                        focusNode: _Qtyfocus,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade100, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade100, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AmountTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

// TotalAmt
  FocusNode _TotAmtFocus = FocusNode();
  TextEditingController _TotalAmtController = TextEditingController();
  Widget _buildTotalAmtText(String label) {
    return Row(
      children: [
        Icon(Icons.attach_money, size: 18),
        Padding(
          padding: EdgeInsets.all(
            0.0,
          ),
          child: Text(
            label,
            style: commonLabelTextStyle,
          ),
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 100 : 120,
                      child: Container(
                        height: 23,
                        width: 80,
                        child: TextField(
                            onSubmitted: (String value) {
                              _AddTabledata();
                            },
                            keyboardType: TextInputType.number,
                            controller: _TotalAmtController,
                            focusNode: _TotAmtFocus,
                            readOnly: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: AmountTextStyle),
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

// ButtonAdd and Delete
  Widget AddAndDeleteButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              _AddTabledata();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              backgroundColor: subcolor,
              minimumSize: Size(45.0, 31.0),
            ),
            child: Text('Add', style: commonWhiteStyle),
          ),
        ],
      ),
    );
  }

// NoOfItems
  Widget _buildNoOfItemText(String label) {
    return Row(
      children: [
        Text(
          label,
          style: textStyle,
        ),
        SizedBox(width: 5),
        Text(
          tableData.length.toString(),
          style: commonLabelTextStyle,
        ),
      ],
    );
  }

// RetailsAmt
  TextEditingController _TaxableAmtController = TextEditingController();
  Widget _buildTaxableAmtText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 120 : 120,
                      child: Container(
                        height: 23,
                        width: 100,
                        color: Colors.white,
                        child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _TaxableAmtController,
                            readOnly: true,
                            // focusNode: _qtyfocus,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade500, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade500, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: AmountTextStyle),
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

// DisPerc
  FocusNode Disperc = FocusNode();
  TextEditingController _DisPercController = TextEditingController();

  Widget _buildDisPercText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: commonLabelTextStyle,
                  ),
                  Icon(
                    Icons.percent,
                    color: Colors.black,
                    size: 18,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Row(children: [
                  Container(
                    width: Responsive.isDesktop(context) ? 100 : 120,
                    child: Container(
                      height: 23,
                      width: 100,
                      child: TextField(
                          onSubmitted: (value) {
                            _fieldFocusChange(context, Disperc, DisAmt);
                          },
                          onChanged: (value) {
                            DisAmtFind_IncludeGst(value);
                            DisAmtFind_ExcludingGst(value);
                            DisAmtFind_NonGst(value);
                          },
                          keyboardType: TextInputType.number,
                          controller: _DisPercController,
                          focusNode: Disperc,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade100, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade100, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: AmountTextStyle),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ],
    );
  }

// DisAMount
  TextEditingController _DisAmtController = TextEditingController();
  FocusNode DisAmt = FocusNode();
  Widget _buildDisAmtText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 100 : 120,
                      child: Container(
                        height: 23,
                        width: 100,
                        child: TextField(
                            onChanged: (value) {
                              DisPercFind_IncludingGst(value);
                              DisPercFind_ExcludingGst(value);
                              DisPercFind_NonGst(value);
                            },
                            keyboardType: TextInputType.number,
                            controller: _DisAmtController,
                            focusNode: DisAmt,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AmountTextStyle),
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

// FinAmount
  TextEditingController _FinTaxController = TextEditingController();
  Widget _buildFinTaxText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 120 : 120,
                      child: Container(
                        height: 23,
                        width: 100,
                        color: Colors.white,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _FinTaxController,
                          readOnly: true,
                          // focusNode: _qtyfocus,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          style: AmountTextStyle,
                        ),
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

// Button-Save and refresh
  Widget SaveAndRefreshButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              SavetoSalesRoundAndDetails_tbl();

              fetchSalesFinalSerialNo();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              backgroundColor: subcolor,
              minimumSize: Size(45.0, 31.0),
            ),
            child: Text('Save', style: commonWhiteStyle),
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
            onPressed: () {
              ClearFields();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              backgroundColor: subcolor,
              minimumSize: Size(45.0, 31.0),
            ),
            child: Text(
              'Refresh',
              style: commonWhiteStyle,
            ),
          ),
        ],
      ),
    );
  }

// Sgst
  TextEditingController _SgstController = TextEditingController();
  Widget _buildSgstText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 100 : 120,
                      child: Container(
                        height: 23,
                        width: 100,
                        child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _SgstController,
                            readOnly: true,
                            // focusNode: _qtyfocus,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: AmountTextStyle),
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

// Cgst
  TextEditingController _CgstController = TextEditingController();
  Widget _buildCgstText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 100 : 120,
                      child: Container(
                        height: 23,
                        width: 100,
                        child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _CgstController,
                            // focusNode: _qtyfocus,
                            readOnly: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: AmountTextStyle),
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

// Amount
  TextEditingController _AmountController = TextEditingController();
  Widget _buildAmountText(String label) {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  0.0,
                ),
                child: Text(
                  label,
                  style: AmountTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context) ? 120 : 120,
                      child: Container(
                        height: 23,
                        width: 100,
                        color: Colors.white,
                        child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _AmountController,
                            readOnly: true,

                            // focusNode: _qtyfocus,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade500, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade500, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: AmountTextStyle),
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

// All fetch Functions
  List<String> nameComboList = [];

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

          VendorNameList.addAll(
              results.map<String>((item) => item['Name'].toString()));
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

  Future<void> fetchAllProductName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductNameList.addAll(
              results.map<String>((item) => item['name'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      //  print('All product categories: $ProductCategoryList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String searchText = '';

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['prodname'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  void ClearFields() {
    setState(() {
      _ProductNameController.text = "";
      _VendorNameController.text = "";
      _VendorPercController.text = "";
      _OrderNoController.text = "";
      code = "";
      _PaytypeController.text = "";
      _RateController.text = "0";
      _QtyController.text = "0";
      _TotalAmtController.text = "0.00";
      tableData.clear();
      _DisPercController.text = "0";
      _DisAmtController.text = "0";
      _CgstController.text = "0";
      _SgstController.text = "0";
      _AmountController.text = "0.00";
      _TaxableAmtController.text = "0.00";
      _FinTaxController.text = "0.00";
    });
  }

  Future<void> fetchPaytype() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PaymentMethod/$cusid';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<String> fetchedPaytypes =
          []; // Use a separate list to store paytypes

      for (var item in data) {
        String PaytypeList = item['paytype'];
        fetchedPaytypes.add(PaytypeList); // Add paytype to the list
      }

      setState(() {
        PaytypeList =
            fetchedPaytypes; // Update the state with the fetched paytypes
      });
    }
  }

  Future<String?> fetchVendorPercByProdName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String apiUrl = '$IpAddress/VendorsName/$cusid';

      int page = 1;
      double venPerc = 0;
      ;
      bool hasMorePages = true;

      while (hasMorePages) {
        String url = '$apiUrl?page=$page';

        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['Name'] == _VendorNameController.text) {
              double CommisionDouble =
                  double.parse(entry['Commision'].toString());
              venPerc += CommisionDouble;
            }
          }

          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }

      _VendorPercController.text = venPerc.toString();

      // print("Total VendorPerc of ${_VendorNameController.text} products: $venPerc");
    } catch (e) {
      print('Error fetching VendorPerc: $e');
      return null;
    }
    return null;
  }

  Future<void> fetchRateByProdName() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid';

    int page = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        String url = '$apiUrl?page=$page';

        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['name'] == _ProductNameController.text) {
              double RateDouble = double.parse(entry['OnlineAmt'].toString());
              _RateController.text = RateDouble.toString();
            }
          }

          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }

      // print("Total amount of ${_ProductNameController.text} products: $totalAmount");
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<String?> fetchCategoryByProdName(String productName) async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid';
    int page = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        String url = '$apiUrl?page=$page';
        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['name'] == productName) {
              String Category = entry['category'];
              return Category;
            }
          }
          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }
    } catch (e) {
      print('Error fetching category: $e');
    }
    return null;
  }

  Future<double?> fetchMakingCostByProdName(String productName) async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid';
    int page = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        String url = '$apiUrl?page=$page';
        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['name'] == productName) {
              double makingCost = double.parse(entry['makingcost'].toString());
              return makingCost;
            }
          }
          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }
    } catch (e) {
      print('Error fetching making cost: $e');
    }
    return null;
  }

  Future<String?> fetchCodeByProdName() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid';

    int page = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        String url = '$apiUrl?page=$page';

        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['name'] == _ProductNameController.text) {
              double Code = double.parse(entry['code'].toString());
              code = Code.toString();
            }
          }
          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }
      // print("Code of ${_ProductNameController.text} products: $totalAmount");
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  double cgstPercentage = 0;
  double sgstPercentage = 0;
  double cgstAmt = 0.0;
  double sgstAmt = 0.0;
  double taxableAmt = 0.00;

// Add Button Excluding Gst

  void _ExcludecalculateGstAmounts(
      double cgstPercentage, double sgstPercentage, String? totalAmount) {
    cgstAmt = _ExcludecalculateGst(cgstPercentage, totalAmount);
    sgstAmt = _ExcludecalculateGst(sgstPercentage, totalAmount);
  }

  double _ExcludecalculateGst(double percentage, String? amount) {
    double taxableAmount = double.tryParse(amount ?? '0') ?? 0;
    return (taxableAmount * percentage) / 100;
  }

  // Add button Including Gst

  double calculateIncludingPerc() {
    String? TotalAmt = _TotalAmtController.text;
    double totAmt = double.tryParse(TotalAmt ?? "") ?? 0.0;

    double gstPerc = cgstPercentage + sgstPercentage;
    cgstAmt = (totAmt * cgstPercentage) / (100 + gstPerc);
    sgstAmt = (totAmt * sgstPercentage) / (100 + gstPerc);

    cgstAmt = double.parse(cgstAmt.toStringAsFixed(2));
    sgstAmt = double.parse(sgstAmt.toStringAsFixed(2));

    double taxableAmt = totAmt - (cgstAmt + sgstAmt);
    taxableAmt = double.parse(taxableAmt.toStringAsFixed(2));

    if (taxableAmt < 0.01) {
      taxableAmt = 0.00;
    }

    return taxableAmt;
  }

  void _AddTabledata() async {
    String? cusid = await SharedPrefs.getCusId();
    String? productName = _ProductNameController.text;
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid';
    double TotAmt = 0.0;

    try {
      int page = 1;
      bool hasMorePages = true;

      while (hasMorePages) {
        String url = '$apiUrl?page=$page';

        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['name'] == productName) {
              cgstPercentage = double.parse(entry['cgstper'].toString());
              sgstPercentage = double.parse(entry['sgstper'].toString());
              break;
            }
          }
          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }

      // Gst Calculation
      if (gstName == 'Including') {
        taxableAmt = calculateIncludingPerc();
        TotAmt = double.tryParse(_TotalAmtController.text ?? '0') ?? 0.0;
      } else if (gstName == 'Excluding') {
        taxableAmt = double.tryParse(_TotalAmtController.text ?? '0') ?? 0.0;

        _ExcludecalculateGstAmounts(
            cgstPercentage, sgstPercentage, _TotalAmtController.text);

        TotAmt = cgstAmt + sgstAmt + taxableAmt;
      } else {
        taxableAmt = double.tryParse(_TotalAmtController.text ?? '0') ?? 0.0;
        TotAmt = double.tryParse(_TotalAmtController.text ?? '0') ?? 0.0;
        cgstAmt = 0.00;
        sgstAmt = 0.00;
        cgstPercentage = 0;
        sgstPercentage = 0;
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    setState(() {
      String? billNo = BillnoController.text;
      String? type = _typeController.text;
      String? payType = _PaytypeController.text;
      String? VendorName = _VendorNameController.text;
      String? VendorPerc = _VendorPercController.text;
      String? OrderNo = _OrderNoController.text;
      String? Rate = _RateController.text;
      String? qty = _QtyController.text;
      String? Amount = _AmountController.text;
      if (type == "" ||
          payType == "" ||
          VendorName == "" ||
          VendorPerc == "" ||
          OrderNo == "" ||
          productName == "" ||
          Rate == "" ||
          qty == "0" ||
          qty == "" ||
          Amount == 0.0) {
        WarninngMessage(context);
        return;
      }

      tableData.add({
        'prodname': productName,
        'rate': Rate,
        'qty': qty,
        'cgst': cgstAmt,
        'sgst': sgstAmt,
        'amount': TotAmt,
        'taxable': taxableAmt.toStringAsFixed(2),
        'cgstPerc': cgstPercentage,
        'sgstPerc': sgstPercentage,
      });

      _ProductNameController.text = "";
      _RateController.text = "0";
      _TotalAmtController.text = "0.00";
      _QtyController.text = "0";
      code = "";

      // Calculate sums for display
      double sumTaxable = 0.0;
      double sumAmount = 0.0;
      double sumCGSTAmount = 0.0;
      double sumSGSTAmount = 0.0;

      for (var entry in tableData) {
        sumTaxable += double.parse((entry['taxable'] ?? '0').toString());
        sumAmount += double.parse((entry['amount'] ?? '0').toString());
        sumCGSTAmount += double.parse((entry['cgst'] ?? '0').toString());
        sumSGSTAmount += double.parse((entry['sgst'] ?? '0').toString());
      }

      _TaxableAmtController.text = sumTaxable.toStringAsFixed(2);
      _FinTaxController.text = sumTaxable.toStringAsFixed(2);
      _AmountController.text = sumAmount.toStringAsFixed(2);
      _CgstController.text = sumCGSTAmount.toStringAsFixed(2);
      _SgstController.text = sumSGSTAmount.toStringAsFixed(2);

      FocusScope.of(context).requestFocus(ProdNameFocus);
    });
  }

// Find Total Gst Under the Table

  double FinCGST0Incl = 0;
  double FinCGST5Incl = 0;
  double FinCGST12Incl = 0;
  double FinCGST18Incl = 0;
  double FinCGST28Incl = 0;

  double sumFinCGSTAmtIncl = 0;

  double FinCGST0Exc = 0;
  double FinCGST5Exc = 0;
  double FinCGST12Exc = 0;
  double FinCGST18Exc = 0;
  double FinCGST28Exc = 0;

  double sumFinCGSTAmtExc = 0;

  void CgstAndSgstAmountInTable() {
    if (gstName == "Including") {
      tableData.forEach((entry) {
        var CgstPerc = entry['cgstPerc'].toString();

        double cgstamount = double.parse((entry['cgst'] ?? '0').toString());

        switch (CgstPerc) {
          case '0':
            FinCGST0Incl += cgstamount;

            break;
          case '2.5':
            FinCGST5Incl += cgstamount;

            break;
          case '6':
            FinCGST12Incl += cgstamount;
            break;
          case '9':
            FinCGST18Incl += cgstamount;
            break;
          case '14':
            FinCGST28Incl += cgstamount;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });
    }

    if (gstName == "Excluding") {
      tableData.forEach((entry) {
        var CgstPerc = entry['cgstPerc'].toString();

        double cgstamount = double.parse((entry['cgst'] ?? '0').toString());

        switch (CgstPerc) {
          case '0':
            FinCGST0Exc += cgstamount;

            break;
          case '2.5':
            FinCGST5Exc += cgstamount;

            break;
          case '6':
            FinCGST12Exc += cgstamount;
            break;
          case '9':
            FinCGST18Exc += cgstamount;

            break;
          case '14':
            FinCGST28Exc += cgstamount;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });
    }
  }

// Including Gst

  void DisAmtFind_IncludeGst(value) {
    if (gstName == "Including") {
      // Find Discount Amount

      double DisPerc = 0;
      if (value != null && value.isNotEmpty) {
        try {
          DisPerc = double.parse(value);
        } catch (e) {
          print('Error parsing value to double: $e');
          return;
        }
      }

      double gettotvat0 = 0;
      double gettotvat5 = 0;
      double gettotvat12 = 0;
      double gettotvat18 = 0;
      double gettotvat28 = 0;

      double FinDisAmt0 = 0;
      double FinDisAmt5 = 0;
      double FinDisAmt12 = 0;
      double FinDisAmt18 = 0;
      double FinDisAmt28 = 0;

      double TaxFind0 = 0;
      double TaxFind5 = 0;
      double TaxFind12 = 0;
      double TaxFind18 = 0;
      double TaxFind28 = 0;

      double FinTaxFind0 = 0;
      double FinTaxFind5 = 0;
      double FinTaxFind12 = 0;
      double FinTaxFind18 = 0;
      double FinTaxFind28 = 0;

      double FinOverAllTax0 = 0;
      double FinOverAllTax5 = 0;
      double FinOverAllTax12 = 0;
      double FinOverAllTax18 = 0;
      double FinOverAllTax28 = 0;

      tableData.forEach((entry) {
        var getvat = entry['cgstPerc'].toString();
        double amount = double.parse((entry['amount'] ?? '0').toString());

        switch (getvat) {
          case '0':
            gettotvat0 += amount;
            FinDisAmt0 = gettotvat0 * DisPerc / 100;
            TaxFind0 = gettotvat0 - FinDisAmt0;
            FinTaxFind0 = TaxFind0 * 0 / 100;
            FinOverAllTax0 = TaxFind0 - FinTaxFind0;
            break;
          case '2.5':
            gettotvat5 += amount;
            FinDisAmt5 = gettotvat5 * DisPerc / 100;
            TaxFind5 = gettotvat5 - FinDisAmt5;
            FinTaxFind5 = TaxFind5 * 10 / 110;
            FinOverAllTax5 = TaxFind5 - FinTaxFind5;

            break;
          case '6':
            gettotvat12 += amount;
            FinDisAmt12 = gettotvat12 * DisPerc / 100;
            TaxFind12 = gettotvat12 - FinDisAmt12;
            FinTaxFind12 = TaxFind12 * 12 / 112;
            FinOverAllTax12 = TaxFind12 - FinTaxFind12;

            break;
          case '9':
            gettotvat18 += amount;
            FinDisAmt18 = gettotvat18 * DisPerc / 100;
            TaxFind18 = gettotvat18 - FinDisAmt18;
            FinTaxFind18 = TaxFind18 * 18 / 118;
            FinOverAllTax18 = TaxFind18 - FinTaxFind18;

            break;
          case '14':
            gettotvat28 += amount;
            FinDisAmt28 = gettotvat28 * DisPerc / 100;
            TaxFind28 = gettotvat28 - FinDisAmt28;
            FinTaxFind28 = TaxFind28 * 28 / 128;
            FinOverAllTax28 = TaxFind28 - FinTaxFind28;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });

      double sumFinDisAmt =
          FinDisAmt0 + FinDisAmt5 + FinDisAmt12 + FinDisAmt18 + FinDisAmt28;

      _DisAmtController.text = sumFinDisAmt.toStringAsFixed(2);

      // Find  Amount
      double sumTableTotalAmount = 0.0;

      for (var entry in tableData) {
        sumTableTotalAmount +=
            double.parse((entry['amount'] ?? '0').toString());
      }

      double Amount = sumTableTotalAmount - sumFinDisAmt;

      _AmountController.text = Amount.toStringAsFixed(2);

      // Find CGST Amount

      double SumAmt0 = 0;
      double SumAmt5 = 0;
      double SumAmt12 = 0;
      double SumAmt18 = 0;
      double SumAmt28 = 0;

      double CGSTAmt0 = 0;
      double CGSTAmt5 = 0;
      double CGSTAmt12 = 0;
      double CGSTAmt18 = 0;
      double CGSTAmt28 = 0;

      tableData.forEach((entry) {
        var CgstPerc = entry['cgstPerc'].toString();
        double amount = double.parse((entry['amount'] ?? '0').toString());

        switch (CgstPerc) {
          case '0':
            SumAmt0 += amount;
            CGSTAmt0 = SumAmt0 - FinDisAmt0;
            double Numeric = CGSTAmt0 * 0;
            double denominator = 100 + 0;
            FinCGST0Incl = Numeric / denominator;
            break;
          case '2.5':
            SumAmt5 += amount;
            CGSTAmt5 = SumAmt5 - FinDisAmt5;
            double Numeric = CGSTAmt5 * 2.5;
            double denominator = 100 + 5;
            FinCGST5Incl = Numeric / denominator;
            break;
          case '6':
            SumAmt12 += amount;
            CGSTAmt12 = SumAmt12 - FinDisAmt12;
            double Numeric = CGSTAmt12 * 6;
            double denominator = 100 + 12;
            FinCGST12Incl = Numeric / denominator;
            break;
          case '9':
            SumAmt18 += amount;
            CGSTAmt18 = SumAmt18 - FinDisAmt18;
            double Numeric = CGSTAmt18 * 9;
            double denominator = 100 + 18;
            FinCGST18Incl = Numeric / denominator;
            break;
          case '14':
            SumAmt28 += amount;
            CGSTAmt28 = SumAmt28 - FinDisAmt28;
            double Numeric = CGSTAmt28 * 14;
            double denominator = 100 + 28;
            FinCGST28Incl = Numeric / denominator;
            break;
          default:
            print('Invalid CGST Percentage..');
        }
      });

      sumFinCGSTAmtIncl = FinCGST0Incl +
          FinCGST5Incl +
          FinCGST12Incl +
          FinCGST18Incl +
          FinCGST28Incl;
      _CgstController.text = sumFinCGSTAmtIncl.toStringAsFixed(2);
      _SgstController.text = sumFinCGSTAmtIncl.toStringAsFixed(2);

      // Find Final Taxable Amount

      double FinTaxAmount = 0;
      FinTaxAmount = FinOverAllTax0 +
          FinOverAllTax5 +
          FinOverAllTax12 +
          FinOverAllTax18 +
          FinOverAllTax28;

      _FinTaxController.text = FinTaxAmount.toStringAsFixed(2);
    }
  }

  void DisPercFind_IncludingGst(value) {
    if (gstName == "Including") {
      // Find Discount Perc
      double DisAmt = double.tryParse(value) ?? 0;
      double sumTableTotalAmount = 0.0;

      for (var entry in tableData) {
        sumTableTotalAmount +=
            double.parse((entry['amount'] ?? '0').toString());
      }

      double DisPerc = DisAmt * 100 / sumTableTotalAmount;

      _DisPercController.text = DisPerc.toStringAsFixed(2);

      // Find  Amount
      double Amount = sumTableTotalAmount - DisAmt;

      _AmountController.text = Amount.toStringAsFixed(2);

      // Find Discount Amount - > for CGST Amount because its only find Disperc

      double gettotvat0 = 0;
      double gettotvat5 = 0;
      double gettotvat12 = 0;
      double gettotvat18 = 0;
      double gettotvat28 = 0;

      double FinDisAmt0 = 0;
      double FinDisAmt5 = 0;
      double FinDisAmt12 = 0;
      double FinDisAmt18 = 0;
      double FinDisAmt28 = 0;

      double TaxFind0 = 0;
      double TaxFind5 = 0;
      double TaxFind12 = 0;
      double TaxFind18 = 0;
      double TaxFind28 = 0;

      double FinTaxFind0 = 0;
      double FinTaxFind5 = 0;
      double FinTaxFind12 = 0;
      double FinTaxFind18 = 0;
      double FinTaxFind28 = 0;

      double FinOverAllTax0 = 0;
      double FinOverAllTax5 = 0;
      double FinOverAllTax12 = 0;
      double FinOverAllTax18 = 0;
      double FinOverAllTax28 = 0;

      tableData.forEach((entry) {
        var getvat = entry['cgstPerc'].toString();
        double amount = double.parse((entry['amount'] ?? '0').toString());

        switch (getvat) {
          case '0':
            gettotvat0 += amount;
            FinDisAmt0 = gettotvat0 * DisPerc / 100;
            TaxFind0 = gettotvat0 - FinDisAmt0;
            FinTaxFind0 = TaxFind0 * 0 / 100;
            FinOverAllTax0 = TaxFind0 - FinTaxFind0;
            break;
          case '2.5':
            gettotvat5 += amount;
            FinDisAmt5 = gettotvat5 * DisPerc / 100;
            TaxFind5 = gettotvat5 - FinDisAmt5;
            FinTaxFind5 = TaxFind5 * 10 / 110;
            FinOverAllTax5 = TaxFind5 - FinTaxFind5;

            break;
          case '6':
            gettotvat12 += amount;
            FinDisAmt12 = gettotvat12 * DisPerc / 100;
            TaxFind12 = gettotvat12 - FinDisAmt12;
            FinTaxFind12 = TaxFind12 * 12 / 112;
            FinOverAllTax12 = TaxFind12 - FinTaxFind12;

            break;
          case '9':
            gettotvat18 += amount;
            FinDisAmt18 = gettotvat18 * DisPerc / 100;
            TaxFind18 = gettotvat18 - FinDisAmt18;
            FinTaxFind18 = TaxFind18 * 18 / 118;
            FinOverAllTax18 = TaxFind18 - FinTaxFind18;

            break;
          case '14':
            gettotvat28 += amount;
            FinDisAmt28 = gettotvat28 * DisPerc / 100;
            TaxFind28 = gettotvat28 - FinDisAmt28;
            FinTaxFind28 = TaxFind28 * 28 / 128;
            FinOverAllTax28 = TaxFind28 - FinTaxFind28;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });

      // Find CGST Amount

      double SumAmt0 = 0;
      double SumAmt5 = 0;
      double SumAmt12 = 0;
      double SumAmt18 = 0;
      double SumAmt28 = 0;

      double CGSTAmt0 = 0;
      double CGSTAmt5 = 0;
      double CGSTAmt12 = 0;
      double CGSTAmt18 = 0;
      double CGSTAmt28 = 0;

      tableData.forEach((entry) {
        var CgstPerc = entry['cgstPerc'].toString();
        double amount = double.parse((entry['amount'] ?? '0').toString());

        switch (CgstPerc) {
          case '0':
            SumAmt0 += amount;
            CGSTAmt0 = SumAmt0 - FinDisAmt0;
            double Numeric = CGSTAmt0 * 0;
            double denominator = 100 + 0;
            FinCGST0Incl = Numeric / denominator;
            break;
          case '2.5':
            SumAmt5 += amount;
            CGSTAmt5 = SumAmt5 - FinDisAmt5;
            double Numeric = CGSTAmt5 * 2.5;
            double denominator = 100 + 5;
            FinCGST5Incl = Numeric / denominator;
            break;
          case '6':
            SumAmt12 += amount;
            CGSTAmt12 = SumAmt12 - FinDisAmt12;
            double Numeric = CGSTAmt12 * 6;
            double denominator = 100 + 12;
            FinCGST12Incl = Numeric / denominator;
            break;
          case '9':
            SumAmt18 += amount;
            CGSTAmt18 = SumAmt18 - FinDisAmt18;
            double Numeric = CGSTAmt18 * 9;
            double denominator = 100 + 18;
            FinCGST18Incl = Numeric / denominator;
            break;
          case '14':
            SumAmt28 += amount;
            CGSTAmt28 = SumAmt28 - FinDisAmt28;
            double Numeric = CGSTAmt28 * 14;
            double denominator = 100 + 28;
            FinCGST28Incl = Numeric / denominator;
            break;
          default:
            print('Invalid CGST Percentage..');
        }
      });

      sumFinCGSTAmtIncl = FinCGST0Incl +
          FinCGST5Incl +
          FinCGST12Incl +
          FinCGST18Incl +
          FinCGST28Incl;
      _CgstController.text = sumFinCGSTAmtIncl.toStringAsFixed(2);
      _SgstController.text = sumFinCGSTAmtIncl.toStringAsFixed(2);

      // Find Final Taxable Amount

      double FinTaxAmount = 0;
      FinTaxAmount = FinOverAllTax0 +
          FinOverAllTax5 +
          FinOverAllTax12 +
          FinOverAllTax18 +
          FinOverAllTax28;

      _FinTaxController.text = FinTaxAmount.toStringAsFixed(2);
    }
  }

// Excluding Gst

  void DisAmtFind_ExcludingGst(value) {
    if (gstName == "Excluding") {
// Find Discount Amount

      double DisPerc = 0;
      if (value != null && value.isNotEmpty) {
        try {
          DisPerc = double.parse(value);
        } catch (e) {
          print('Error parsing value to double: $e');
          return;
        }
      }

      double gettotvat0 = 0;
      double gettotvat5 = 0;
      double gettotvat12 = 0;
      double gettotvat18 = 0;
      double gettotvat28 = 0;

      double FinDisAmt0 = 0;
      double FinDisAmt5 = 0;
      double FinDisAmt12 = 0;
      double FinDisAmt18 = 0;
      double FinDisAmt28 = 0;

      tableData.forEach((entry) {
        var getvat = entry['cgstPerc'].toString();
        double taxable = double.parse((entry['taxable'] ?? '0').toString());

        switch (getvat) {
          case '0':
            gettotvat0 += taxable;
            FinDisAmt0 = gettotvat0 * DisPerc / 100;

            break;
          case '2.5':
            gettotvat5 += taxable;
            FinDisAmt5 = gettotvat5 * DisPerc / 100;

            break;
          case '6':
            gettotvat12 += taxable;
            FinDisAmt12 = gettotvat12 * DisPerc / 100;
            break;
          case '9':
            gettotvat18 += taxable;
            FinDisAmt18 = gettotvat18 * DisPerc / 100;

            break;
          case '14':
            gettotvat28 += taxable;
            FinDisAmt28 = gettotvat28 * DisPerc / 100;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });

      double sumFinDisAmt =
          FinDisAmt0 + FinDisAmt5 + FinDisAmt12 + FinDisAmt18 + FinDisAmt28;

      _DisAmtController.text = sumFinDisAmt.toStringAsFixed(2);

// Find CGST Amount

      double SumAmt0 = 0;
      double SumAmt5 = 0;
      double SumAmt12 = 0;
      double SumAmt18 = 0;
      double SumAmt28 = 0;

      double CGSTAmt0 = 0;
      double CGSTAmt5 = 0;
      double CGSTAmt12 = 0;
      double CGSTAmt18 = 0;
      double CGSTAmt28 = 0;

      tableData.forEach((entry) {
        var CgstPerc = entry['cgstPerc'].toString();
        double taxable = double.parse((entry['taxable'] ?? '0').toString());

        switch (CgstPerc) {
          case '0':
            SumAmt0 += taxable;
            CGSTAmt0 = SumAmt0 - FinDisAmt0;
            double Numeric = CGSTAmt0 * 0;
            double denominator = 100;
            FinCGST0Exc = Numeric / denominator;
            break;
          case '2.5':
            SumAmt5 += taxable;
            CGSTAmt5 = SumAmt5 - FinDisAmt5;
            double Numeric = CGSTAmt5 * 2.5;
            double denominator = 100;
            FinCGST5Exc = Numeric / denominator;
            break;
          case '6':
            SumAmt12 += taxable;
            CGSTAmt12 = SumAmt12 - FinDisAmt12;
            double Numeric = CGSTAmt12 * 6;
            double denominator = 100;
            FinCGST12Exc = Numeric / denominator;
            break;
          case '9':
            SumAmt18 += taxable;
            CGSTAmt18 = SumAmt18 - FinDisAmt18;
            double Numeric = CGSTAmt18 * 9;
            double denominator = 100;
            FinCGST18Exc = Numeric / denominator;
            break;
          case '14':
            SumAmt28 += taxable;
            CGSTAmt28 = SumAmt28 - FinDisAmt28;
            double Numeric = CGSTAmt28 * 14;
            double denominator = 100;
            FinCGST28Exc = Numeric / denominator;
            break;
          default:
            print('Invalid CGST Percentage..');
        }
      });

      sumFinCGSTAmtExc = FinCGST0Exc +
          FinCGST5Exc +
          FinCGST12Exc +
          FinCGST18Exc +
          FinCGST28Exc;

      _CgstController.text = sumFinCGSTAmtExc.toStringAsFixed(2);
      _SgstController.text = sumFinCGSTAmtExc.toStringAsFixed(2);

      // Find Final Taxable Amount
      double sumTableTaxableAmount = 0.0;

      for (var entry in tableData) {
        sumTableTaxableAmount +=
            double.parse((entry['taxable'] ?? '0').toString());
      }
      double TaxableAmount = sumTableTaxableAmount - sumFinDisAmt;

      _FinTaxController.text = TaxableAmount.toStringAsFixed(2);

      // Find Amount

      double Amount = TaxableAmount + sumFinCGSTAmtExc + sumFinCGSTAmtExc;

      _AmountController.text = Amount.toStringAsFixed(2);
    }
  }

  void DisPercFind_ExcludingGst(value) {
    if (gstName == "Excluding") {
      // Find Discount Perc
      double DisAmt = double.tryParse(value) ?? 0;
      double sumTableTaxableAmount = 0.0;

      for (var entry in tableData) {
        sumTableTaxableAmount +=
            double.parse((entry['taxable'] ?? '0').toString());
      }

      double DisPerc = DisAmt * 100 / sumTableTaxableAmount;

      _DisPercController.text = DisPerc.toStringAsFixed(2);

      // Find Discount Amount - > for CGST Amount because its only find Disperc

      double gettotvat0 = 0;
      double gettotvat5 = 0;
      double gettotvat12 = 0;
      double gettotvat18 = 0;
      double gettotvat28 = 0;

      double FinDisAmt0 = 0;
      double FinDisAmt5 = 0;
      double FinDisAmt12 = 0;
      double FinDisAmt18 = 0;
      double FinDisAmt28 = 0;

      tableData.forEach((entry) {
        var getvat = entry['cgstPerc'].toString();
        double taxable = double.parse((entry['taxable'] ?? '0').toString());

        switch (getvat) {
          case '0':
            gettotvat0 += taxable;
            FinDisAmt0 = gettotvat0 * DisPerc / 100;

            break;
          case '2.5':
            gettotvat5 += taxable;
            FinDisAmt5 = gettotvat5 * DisPerc / 100;

            break;
          case '6':
            gettotvat12 += taxable;
            FinDisAmt12 = gettotvat12 * DisPerc / 100;
            break;
          case '9':
            gettotvat18 += taxable;
            FinDisAmt18 = gettotvat18 * DisPerc / 100;

            break;
          case '14':
            gettotvat28 += taxable;
            FinDisAmt28 = gettotvat28 * DisPerc / 100;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });

      // Find CGST Amount

      double SumAmt0 = 0;
      double SumAmt5 = 0;
      double SumAmt12 = 0;
      double SumAmt18 = 0;
      double SumAmt28 = 0;

      double CGSTAmt0 = 0;
      double CGSTAmt5 = 0;
      double CGSTAmt12 = 0;
      double CGSTAmt18 = 0;
      double CGSTAmt28 = 0;

      tableData.forEach((entry) {
        var CgstPerc = entry['cgstPerc'].toString();
        double taxable = double.parse((entry['taxable'] ?? '0').toString());

        switch (CgstPerc) {
          case '0':
            SumAmt0 += taxable;
            CGSTAmt0 = SumAmt0 - FinDisAmt0;
            double Numeric = CGSTAmt0 * 0;
            double denominator = 100;
            FinCGST0Exc = Numeric / denominator;
            break;
          case '2.5':
            SumAmt5 += taxable;
            CGSTAmt5 = SumAmt5 - FinDisAmt5;
            double Numeric = CGSTAmt5 * 2.5;
            double denominator = 100;
            FinCGST5Exc = Numeric / denominator;
            break;
          case '6':
            SumAmt12 += taxable;
            CGSTAmt12 = SumAmt12 - FinDisAmt12;
            double Numeric = CGSTAmt12 * 6;
            double denominator = 100;
            FinCGST12Exc = Numeric / denominator;
            break;
          case '9':
            SumAmt18 += taxable;
            CGSTAmt18 = SumAmt18 - FinDisAmt18;
            double Numeric = CGSTAmt18 * 9;
            double denominator = 100;
            FinCGST18Exc = Numeric / denominator;
            break;
          case '14':
            SumAmt28 += taxable;
            CGSTAmt28 = SumAmt28 - FinDisAmt28;
            double Numeric = CGSTAmt28 * 14;
            double denominator = 100;
            FinCGST28Exc = Numeric / denominator;
            break;
          default:
            print('Invalid CGST Percentage..');
        }
      });

      sumFinCGSTAmtExc = FinCGST0Exc +
          FinCGST5Exc +
          FinCGST12Exc +
          FinCGST18Exc +
          FinCGST28Exc;

      _CgstController.text = sumFinCGSTAmtExc.toStringAsFixed(2);
      _SgstController.text = sumFinCGSTAmtExc.toStringAsFixed(2);

      // Find Final Taxable Amount

      double TaxableAmount = sumTableTaxableAmount - DisAmt;

      _FinTaxController.text = TaxableAmount.toStringAsFixed(2);

      // Find Amount

      double Amount = TaxableAmount + sumFinCGSTAmtExc + sumFinCGSTAmtExc;

      _AmountController.text = Amount.toStringAsFixed(2);
    }
  }

// Non Gst

  void DisPercFind_NonGst(String value) {
    if (gstName == "NonGst") {
      double DisAmt = double.tryParse(value) ?? 0.0;

      double sumTableTaxableAmount = 0.0;
      for (var entry in tableData) {
        sumTableTaxableAmount +=
            double.tryParse((entry['taxable'] ?? '0').toString()) ?? 0.0;
      }

      double DisPerc = (sumTableTaxableAmount != 0)
          ? DisAmt * 100 / sumTableTaxableAmount
          : 0.0;

      _DisPercController.text = DisPerc.toStringAsFixed(2);

      double Amount = sumTableTaxableAmount - DisAmt;
      _FinTaxController.text = Amount.toStringAsFixed(2);

      _AmountController.text = Amount.toStringAsFixed(2);
    }
  }

  void DisAmtFind_NonGst(String value) {
    if (gstName == "NonGst") {
      double sumTableTaxableAmount = 0.0;
      for (var entry in tableData) {
        sumTableTaxableAmount +=
            double.tryParse((entry['taxable'] ?? '0').toString()) ?? 0.0;
      }

      double DisPerc = 0;
      if (value != null && value.isNotEmpty) {
        try {
          DisPerc = double.parse(value);
        } catch (e) {
          print('Error parsing value to double: $e');
          return;
        }
      }

      double gettotvat0 = 0;
      double gettotvat5 = 0;
      double gettotvat12 = 0;
      double gettotvat18 = 0;
      double gettotvat28 = 0;

      double FinDisAmt0 = 0;
      double FinDisAmt5 = 0;
      double FinDisAmt12 = 0;
      double FinDisAmt18 = 0;
      double FinDisAmt28 = 0;

      tableData.forEach((entry) {
        var getvat = entry['cgstPerc'].toString();
        double taxable = double.parse((entry['taxable'] ?? '0').toString());

        switch (getvat) {
          case '0':
            gettotvat0 += taxable;
            FinDisAmt0 = gettotvat0 * DisPerc / 100;

            break;
          case '2.5':
            gettotvat5 += taxable;
            FinDisAmt5 = gettotvat5 * DisPerc / 100;

            break;
          case '6':
            gettotvat12 += taxable;
            FinDisAmt12 = gettotvat12 * DisPerc / 100;
            break;
          case '9':
            gettotvat18 += taxable;
            FinDisAmt18 = gettotvat18 * DisPerc / 100;

            break;
          case '14':
            gettotvat28 += taxable;
            FinDisAmt28 = gettotvat28 * DisPerc / 100;

            break;
          default:
            print('Invalid Vat Percentage..');
        }
      });

      double sumFinDisAmt =
          FinDisAmt0 + FinDisAmt5 + FinDisAmt12 + FinDisAmt18 + FinDisAmt28;

      _DisAmtController.text = sumFinDisAmt.toStringAsFixed(2);

      double Amount = sumTableTaxableAmount - sumFinDisAmt;
      _FinTaxController.text = Amount.toStringAsFixed(2);

      _AmountController.text = Amount.toStringAsFixed(2);
    }
  }

  void SavetoSalesRoundAndDetails_tbl() async {
    CgstAndSgstAmountInTable();

    String? Type = _typeController.text;
    String? Amount = _AmountController.text;
    String? taxable = _TaxableAmtController.text;
    String? FinTaxable = _FinTaxController.text;
    String? disAmt = _DisAmtController.text;
    String? disPerc = _DisPercController.text;
    String? PayType = _PaytypeController.text;
    String? vendorName = _VendorNameController.text;
    String? VendorPerc = _VendorPercController.text;
    String? OrderNo = _OrderNoController.text;
    String? CgstAmt = _CgstController.text;
    String? SgstAmt = _SgstController.text;

    double FinalCGSTAmount0 = 0;
    double FinalCGSTAmount5 = 0;
    double FinalCGSTAmount12 = 0;
    double FinalCGSTAmount18 = 0;
    double FinalCGSTAmount28 = 0;

    double cgstAmount = double.tryParse(CgstAmt) ?? 0.0;
    double sgstAmount = double.tryParse(SgstAmt) ?? 0.0;

    double finalGSTAmount = cgstAmount + sgstAmount;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    if (gstName == "Excluding") {
      FinalCGSTAmount0 = FinCGST0Exc;
      FinalCGSTAmount5 = FinCGST5Exc;
      FinalCGSTAmount12 = FinCGST12Exc;
      FinalCGSTAmount18 = FinCGST18Exc;
      FinalCGSTAmount28 = FinCGST28Exc;
    } else if (gstName == "Including") {
      FinalCGSTAmount0 = FinCGST0Incl;
      FinalCGSTAmount5 = FinCGST5Incl;
      FinalCGSTAmount12 = FinCGST12Incl;
      FinalCGSTAmount18 = FinCGST18Incl;
      FinalCGSTAmount28 = FinCGST28Incl;
    }

    if (Type == "" ||
        PayType == "" ||
        vendorName == "" ||
        VendorPerc == "" ||
        OrderNo == "" ||
        tableData.isEmpty ||
        disAmt == "" ||
        disPerc == "") {
      WarninngMessage(context);
      return;
    }
    List<Map<String, dynamic>> SalesDetailsData = [];
    double totalAmt = 0.0;

    for (var i = 0; i < tableData.length; i++) {
      var rowData = tableData[i];

      String productName = rowData['prodname'];
      int qty = int.parse(rowData['qty'].toString());
      double Rate = double.parse(rowData['rate'].toString());
      double Amount = double.parse(rowData['amount'].toString());
      double cgst = double.parse(rowData['cgst'].toString());
      double sgst = double.parse(rowData['sgst'].toString());
      double retail = double.parse(rowData['taxable'].toString());
      double cgstPerc = double.parse(rowData['cgstPerc'].toString());
      double sgstPerc = double.parse(rowData['sgstPerc'].toString());
      double? makingCost = await fetchMakingCostByProdName(productName);
      String? Category = await fetchCategoryByProdName(productName);
      totalAmt += Amount;
      String billno = BillnoController.text;

      SalesDetailsData.add({
        "billno": "$billno",
        "dt": "$formattedDate",
        "category": "$Category",
        "Itemname": productName,
        "rate": Rate,
        "qty": qty,
        "amount": Amount,
        "retailrate": "$Rate",
        "retail": retail,
        "cgst": cgst,
        "sgst": sgst,
        "serialno": "1",
        "sgstperc": sgstPerc,
        "cgstperc": cgstPerc,
        "makingcost": "$makingCost",
        "status": "Vendor",
        "sno": "5"
      });
    }

    String salesDetailsJson = json.encode(SalesDetailsData);
    double? amount = double.tryParse(Amount ?? "0");
    double? vendorPerc = double.tryParse(VendorPerc ?? "0");
    double commissionAmount = (amount ?? 0) * (vendorPerc ?? 0) / 100;

    String billno = BillnoController.text;
    String? cusid = await SharedPrefs.getCusId();
    DateTime dateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dateTime);
    String apiUrl = '$IpAddress/SalesRoundDetailsalldatas/';

    double PaidAmount = 0;

    if (selectedPaytype == 'Credit') {
      PaidAmount = 0.0;
    } else {
      PaidAmount = double.tryParse(Amount ?? '0') ?? 0.0;
    }

    Map<String, dynamic> postData = {
      "cusid": cusid,
      'billno': billno,
      'dt': formattedDate,
      'type': selectedType,
      // 'tableno': "",
      // 'servent': '',
      'count': tableData.length.toString(),
      'amount': totalAmt,
      'discount': disAmt,
      'vat': finalGSTAmount,
      'finalamount': Amount,
      'cgst0': FinalCGSTAmount0,
      'cgst25': FinalCGSTAmount5,
      'cgst6': FinalCGSTAmount12,
      'cgst9': FinalCGSTAmount18,
      'cgst14': FinalCGSTAmount28,
      'sgst0': FinalCGSTAmount0,
      'sgst25': FinalCGSTAmount5,
      'sgst6': FinalCGSTAmount12,
      'sgst9': FinalCGSTAmount18,
      'sgst14': FinalCGSTAmount28,
      'totcgst': CgstAmt,
      'totsgst': SgstAmt,
      'paidamount': PaidAmount,
      // 'scode': '',
      // 'sname': '',
      // 'cusname': '',
      // 'contact': '',
      'paytype': PayType,
      'disperc': disPerc,
      'famount': Amount,
      'vendorname': vendorName,
      'vendorcomPerc': VendorPerc,
      'CommisionAmt': commissionAmount,
      'VendorDisPerc': '0',
      'VendorDisamt': '0',
      'FinalAmt': Amount,
      'TotalAmount': Amount,
      'Status': 'Vendor',
      'OrderNo': OrderNo,
      'PointDis': '0',
      // 'login': '',
      'gststatus': gstStatus,
      'time': formattedDateTime,
      'customeramount': '0',
      'customerchange': '0',
      'taxstatus': gstName,
      'serialno': '1',
      'taxable': taxable,
      'finaltaxable': FinTaxable,
      'SalesDetails': salesDetailsJson,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(postData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Data posted successfully');
        await logreports("VendorSalesBill: ${billno}_Inserted");
        successfullySavedMessage(context);
        SaveToIncome_tbl();
        print('tabledataaaaa: $tableData');
        UpdateStockValue(tableData);
        postDataWithIncrementedSerialNo();
        ClearFields();
        fetchLastBillNoDatas();
      } else {
        print('Failed to save data. Status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        FailedSavedMessage();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void FailedSavedMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Failed to Save Details!!',
                style: TextStyle(fontSize: 13, color: Colors.white),
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

  void SaveToIncome_tbl() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String? Amount = _AmountController.text;
    String billno = BillnoController.text;
    String? cusid = await SharedPrefs.getCusId();

    String apiUrl = '$IpAddress/IncomeEntryDetailalldatas/';
    Map<String, dynamic> postData = {
      "cusid": cusid,
      'dt': formattedDate,
      'description': 'Vendor Sales Bill:$billno',
      'amount': Amount,
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
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> UpdateStockValue(List<Map<String, dynamic>> tableData) async {
    print("update stock ");
    for (var data in tableData) {
      String productName = data['prodname'];
      int quantity = int.tryParse(data['qty'].toString()) ?? 0;

      try {
        List<Map<String, dynamic>> productList = await salesProductList();
        print("Product name $productName stock : $quantity ");

        Map<String, dynamic>? product = productList.firstWhere(
          (element) => element['name'] == productName,
          orElse: () => {'stock': 'no', 'id': -1},
        );

        String stockStatus = product['stock'];
        int productId = product['id'];

        if (stockStatus == 'Yes') {
          double stockValue =
              double.tryParse(product['stockvalue'].toString()) ?? 0;

          double updatedStockValue = stockValue - quantity;

          String? cusid = await SharedPrefs.getCusId();
          Map<String, dynamic> putData = {
            "cusid": cusid,
            "stockvalue": updatedStockValue.toString(),
          };

          String jsonData = jsonEncode(putData);

          var response = await http.put(
            Uri.parse('$IpAddress/SettingsProductDetailsalldatas/$productId/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonData,
          );

          if (response.statusCode == 200) {
            print('Stock value updated successfully for product: $productName');
          } else {
            print(
                'Failed to update stock value for product: $productName. Error code: ${response.statusCode}');
            if (response.body != null && response.body.isNotEmpty) {
              // print('Response body: ${response.body}');
            }
          }
        }
      } catch (error) {
        print('Error retrieving product list: $error');
      }
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _showDetailsForm(Map<String, dynamic> data) async {
    String id = data["id"].toString();
    print('Id: $id');

    final String apiUrl = '$IpAddress/SalesRoundDetailsalldatas/$id';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> rowData = jsonDecode(response.body);
        List<dynamic> SalesDetails = jsonDecode(rowData['SalesDetails']);
        double discount =
            double.tryParse(rowData['discount']?.toString() ?? '0') ?? 0.0;
        double cgst =
            double.tryParse(rowData['totcgst']?.toString() ?? '0') ?? 0.0;
        double sgst =
            double.tryParse(rowData['totsgst']?.toString() ?? '0') ?? 0.0;
        double totalAmount = 0.0;
        double TaxableAmount = 0.0;
        List<Widget> itemRows = [];

        for (var order in SalesDetails) {
          if (order['billno'] == rowData['billno'].toString()) {
            String itemName = order['Itemname'];
            double rate = (order['rate'] as num).toDouble();
            double qty = (order['qty'] as num).toDouble();
            double totalAmt = (order['amount'] as num).toDouble();
            double taxable = (order['retail'] as num).toDouble();

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
                              color: Color.fromARGB(255, 226, 225, 225)),
                        ),
                        child: Center(
                          child: Text(
                            itemName,
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
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromARGB(255, 226, 225, 225)),
                        ),
                        child: Center(
                          child: Text(
                            rate.toString(),
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
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromARGB(255, 226, 225, 225)),
                        ),
                        child: Center(
                          child: Text(
                            qty.toString(),
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
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromARGB(255, 226, 225, 225)),
                        ),
                        child: Center(
                          child: Text(
                            totalAmt.toString(),
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            totalAmount += totalAmt;
            TaxableAmount += taxable;
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                                        text: 'Count : ',
                                        style: textStyle,
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: SalesDetails.length
                                                  .toString(),
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.receipt,
                                            size: 16, color: Colors.black),
                                        Text.rich(
                                          TextSpan(
                                            text: 'BillNo : ',
                                            style: textStyle,
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: '${rowData['billno']}',
                                                style: commonLabelTextStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration:
                                          BoxDecoration(color: subcolor),
                                      child: Center(
                                        child: Text('ItemName',
                                            textAlign: TextAlign.center,
                                            style: commonWhiteStyle),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      width: 150.0,
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration:
                                          BoxDecoration(color: subcolor),
                                      child: Center(
                                        child: Text("Rate",
                                            textAlign: TextAlign.center,
                                            style: commonWhiteStyle),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      width: 150.0,
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration:
                                          BoxDecoration(color: subcolor),
                                      child: Center(
                                        child: Text("Qty",
                                            textAlign: TextAlign.center,
                                            style: commonWhiteStyle),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      width: 150.0,
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration:
                                          BoxDecoration(color: subcolor),
                                      child: Center(
                                        child: Text("Amount",
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 16, color: Colors.black),
                                Text.rich(
                                  TextSpan(
                                    text: ' TaxableAmt: ',
                                    style: textStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: TaxableAmount.toString(),
                                          style: commonLabelTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Icon(Icons.money_off,
                                    size: 16, color: Colors.black),
                                Text.rich(
                                  TextSpan(
                                    text: 'Dis ₹ :',
                                    style: textStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: discount.toString(),
                                          style: commonLabelTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Icon(Icons.monetization_on,
                                    size: 16, color: Colors.black),
                                Text.rich(
                                  TextSpan(
                                    text: 'Total: ',
                                    style: textStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: totalAmount.toString(),
                                          style: commonLabelTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.money, size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' CGST: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: cgst.toString(),
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                        Row(
                          children: [
                            Icon(Icons.money, size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' SGST: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: sgst.toString(),
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        print('Failed to load bill details');
      }
    } catch (e) {
      print('Failed to load bill details. Exception: $e');
    }
  }
}
