import 'dart:async';
import 'dart:convert';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Purchase/Config/PurchaseCustomer.dart';
import 'package:restaurantsoftware/Purchase/Config/PurchaseProductDetails.dart';

class NewPurchaseEntryPage extends StatefulWidget {
  const NewPurchaseEntryPage({Key? key}) : super(key: key);

  @override
  State<NewPurchaseEntryPage> createState() => _NewPurchaseEntryPageState();
}

class _NewPurchaseEntryPageState extends State<NewPurchaseEntryPage> {
  // String? selectedValue;
  String? selectedproduct;
  List<bool> isSGSTSelected = [true, false, false, false, false];
  List<bool> isCGSTSelected = [true, false, false, false, false];
  Timer? _timer;
  String searchText = '';
  String productName = ' ';
  @override
  void initState() {
    super.initState();
    fetchSupplierNamelist();
    fetchPurchaseRecordNo();
    fetchAllProductNames();
    fetchGSTMethod();
    // fetchAndCheckProduct(productName);
    getProductCount(tableData);
    quantityController.text = "0";
    TotalController.text = "0.0";
    discountPercentageController.text = "0";
    taxableController.text = "0.0";
    discountAmountController.text = "0";
    finalAmountController.text = "0.0";
    cgstAmountController.text = "0.0";
    sgstAmountController.text = "0.0";
    rateController.text = "0.0";
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchPurchaseRecordNo(); // Fetch serial number every 10 sec
    });
    _timer?.cancel(); // Cancel the timer when the widget is disposed
  }

  final TextEditingController productCountController = TextEditingController();

  TextEditingController purchaseRecordNoController = TextEditingController();
  TextEditingController purchaseInvoiceNoController = TextEditingController();
  TextEditingController purchaseContactNoontroller = TextEditingController();
  TextEditingController purchaseSupplierAgentidController =
      TextEditingController();
  TextEditingController purchaseSuppliergstnoController =
      TextEditingController();

  TextEditingController purchaseGstMethodController = TextEditingController();

  TextEditingController productNameController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController stockcheckController = TextEditingController();

  TextEditingController quantityController = TextEditingController();
  TextEditingController TotalController = TextEditingController();

  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController taxableController = TextEditingController();
  TextEditingController cgstPercentageController = TextEditingController();
  TextEditingController cgstAmountController = TextEditingController();
  TextEditingController sgstPercentageController = TextEditingController();
  TextEditingController sgstAmountController = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  TextEditingController ProductCategoryController = TextEditingController();
  String? supplierName;
  // Date value
  DateTime selectedDate = DateTime.now();

  FocusNode productNameFocusNode = FocusNode();
  FocusNode quantityFocusMode = FocusNode();
  FocusNode DisAmtFocusMode = FocusNode();
  FocusNode DisPercFocusMode = FocusNode();
  FocusNode FinalAmtFocusMode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();
  FocusNode InvoiceNooFocustNode = FocusNode();
  FocusNode SupplierNameFocustNode = FocusNode();
  FocusNode DateFocustNode = FocusNode();
  FocusNode finaldiscountPercFocusNode = FocusNode();

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  String PurchaserecordNo = '';
  Future<void> fetchPurchaseRecordNo() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      if (cusid == null) {
        throw Exception('Customer ID is null');
      }

      final response =
          await http.get(Uri.parse('$IpAddress/Purchase_serialNo/$cusid/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Use safe type casting and provide a default value if serialNo is null or not an integer
        int currentPayno = (jsonData['serialNo'] as int?) ??
            0; // Default to 0 if null or not an int
        int nextPayno = currentPayno + 1;

        setState(() {
          purchaseRecordNoController.text = nextPayno.toString();
        });

        // print("Purchase Serial No: ${purchaseRecordNoController.text}");
        // print("Purchase cusid No: ${cusid}");
      } else {
        throw Exception('Failed to load serial number: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching purchase record number: $error');
    }
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    // Increment the serial number
    int incrementedSerialNo = int.parse(purchaseRecordNoController.text);

    String? cusid = await SharedPrefs.getCusId();
    // Prepare the data to be sent
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "serialno": incrementedSerialNo,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);

    print("serialno : $incrementedSerialNo");

    try {
      // Send the POST request
      var response = await http.post(
        Uri.parse('$IpAddress/PurchaseserialNoalldatas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Data posted successfully');
        fetchPurchaseRecordNo();
      } else {
        // print('Response body: ${response.statusCode}');
        fetchPurchaseRecordNo();
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
      fetchPurchaseRecordNo();
    }
    fetchPurchaseRecordNo();
  }

  void ShowBillnoIncreaeMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.question_mark_rounded, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Do you want increase your Purchase RecordNo ?...',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // incrementAndInsert();
                    postDataWithIncrementedSerialNo();

                    Navigator.of(context).pop(true);
                    fetchPurchaseRecordNo();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize: Size(30.0, 20.0), // Set width and height
                  ),
                  child: Text('Yes',
                      style: TextStyle(color: sidebartext, fontSize: 11)),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    fetchPurchaseRecordNo();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize: Size(30.0, 23.0), // Set width and height
                  ),
                  child: Text('No',
                      style: TextStyle(color: sidebartext, fontSize: 11)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.13;

    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.1;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 15 : 0, top: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: Responsive.isDesktop(context) ? 0 : 20),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Purchase Entry", style: HeadingStyle)
                              ],
                            ),
                            if (Responsive.isDesktop(context))
                              Padding(
                                padding: EdgeInsets.only(left: 00, right: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () async {
                                          String? role = await getrole();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => sidebar(
                                                      onItemSelected:
                                                          (content) {},
                                                      settingsproductcategory:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsproductcategory,
                                                      settingsproductdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsproductdetails,
                                                      settingsgstdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingsgstdetails,
                                                      settingsstaffdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingsstaffdetails,
                                                      settingspaymentmethod:
                                                          role == 'admin'
                                                              ? true
                                                              : settingspaymentmethod,
                                                      settingsaddsalespoint:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsaddsalespoint,
                                                      settingsprinterdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsprinterdetails,
                                                      settingslogindetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingslogindetails,
                                                      purchasenewpurchase: role ==
                                                              'admin'
                                                          ? true
                                                          : purchasenewpurchase,
                                                      purchaseeditpurchase: role ==
                                                              'admin'
                                                          ? true
                                                          : purchaseeditpurchase,
                                                      purchasepaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : purchasepaymentdetails,
                                                      purchaseproductcategory:
                                                          role == 'admin'
                                                              ? true
                                                              : purchaseproductcategory,
                                                      purchaseproductdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : purchaseproductdetails,
                                                      purchaseCustomer: role ==
                                                              'admin'
                                                          ? true
                                                          : purchaseCustomer,
                                                      salesnewsales:
                                                          role == 'admin'
                                                              ? true
                                                              : salesnewsale,
                                                      saleseditsales:
                                                          role == 'admin'
                                                              ? true
                                                              : saleseditsales,
                                                      salespaymentdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : salespaymentdetails,
                                                      salescustomer:
                                                          role == 'admin'
                                                              ? true
                                                              : salescustomer,
                                                      salestablecount:
                                                          role == 'admin'
                                                              ? true
                                                              : salestablecount,
                                                      quicksales:
                                                          role == 'admin'
                                                              ? true
                                                              : quicksales,
                                                      ordersalesnew:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalesnew,
                                                      ordersalesedit:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalesedit,
                                                      ordersalespaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalespaymentdetails,
                                                      vendorsalesnew:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorsalesnew,
                                                      vendorsalespaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorsalespaymentdetails,
                                                      vendorcustomer:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorcustomer,
                                                      stocknew: role == 'admin'
                                                          ? true
                                                          : stocknew,
                                                      wastageadd:
                                                          role == 'admin'
                                                              ? true
                                                              : wastageadd,
                                                      kitchenusagesentry: role ==
                                                              'admin'
                                                          ? true
                                                          : kitchenusagesentry,
                                                      report: role == 'admin'
                                                          ? true
                                                          : report,
                                                      daysheetincomeentry: role ==
                                                              'admin'
                                                          ? true
                                                          : daysheetincomeentry,
                                                      daysheetexpenseentry: role ==
                                                              'admin'
                                                          ? true
                                                          : daysheetexpenseentry,
                                                      daysheetexepensescategory:
                                                          role == 'admin'
                                                              ? true
                                                              : daysheetexepensescategory,
                                                      graphsales:
                                                          role == 'admin'
                                                              ? true
                                                              : graphsales,
                                                    )),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   crossAxisAlignment: CrossAxisAlignment.end,
                            //   children: [
                            //     SizedBox(
                            //       width: 60,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 2, // Set the spacing between lines
                      children: [
                        //  Record No
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("RecordNo",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_rounded,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.09
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            controller:
                                                purchaseRecordNoController,
                                            enabled:
                                                false, // make the TextField read-only

                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
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
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0),
                                        child: InkWell(
                                          onTap: () {
                                            ShowBillnoIncreaeMessage();
                                          },
                                          child: Container(
                                            decoration:
                                                BoxDecoration(color: subcolor),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6,
                                                  right: 6,
                                                  top: 2,
                                                  bottom: 2),
                                              child: Text(
                                                "+",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
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
                        ),
                        // Invoice No
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Text("Invoice No",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.numbers_rounded,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode: InvoiceNooFocustNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    InvoiceNooFocustNode,
                                                    SupplierNameFocustNode),
                                            controller:
                                                purchaseInvoiceNoController,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Supplier Name
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 20,
                                    top: 8),
                                child: Text("Supplier Name",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.41,
                                  child: Row(
                                    children: [
                                      Container(
                                          // width: Responsive.isDesktop(context)
                                          //     ? desktoptextfeildwidth
                                          //     : MediaQuery.of(context)
                                          //             .size
                                          //             .width *
                                          //         0.4,
                                          child: _buildSupplierNameDropdown()),
                                      SizedBox(width: 3),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       top: 0),
                                      //   child: InkWell(
                                      //     onTap: () {
                                      //       // showDialog(
                                      //       //   context: context,
                                      //       //   builder: (BuildContext context) {
                                      //       //     return Dialog(
                                      //       //       child: AddProductDetailsPage(),
                                      //       //     );
                                      //       //   },
                                      //       // );
                                      //     },
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //         borderRadius:
                                      //             BorderRadius.circular(
                                      //                 4.0), // Optional: Adjust border radius as needed
                                      //         border: Border.all(
                                      //           color: Colors
                                      //               .blue.shade200,
                                      //           width: 1.0,
                                      //           style:
                                      //               BorderStyle.solid,
                                      //         ),
                                      //       ),
                                      //       child: Padding(
                                      //         padding:
                                      //             const EdgeInsets.only(
                                      //                 left: 6,
                                      //                 right: 6,
                                      //                 top: 2,
                                      //                 bottom: 2),
                                      //         child: Text(
                                      //           "+",
                                      //           style: TextStyle(
                                      //               color: subcolor,
                                      //               fontSize: 13,
                                      //               fontWeight:
                                      //                   FontWeight
                                      //                       .bold),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  Contact No
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 10,
                                    top: 8),
                                child: Text("Contact No",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 15,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.call,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            controller:
                                                purchaseContactNoontroller,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child:
                                    Text("Date", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 6),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height:
                                            30, // Reduced height for a more compact view
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: DateTimePicker(
                                          focusNode: DateFocustNode,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _fieldFocusChange(
                                                  context,
                                                  DateFocustNode,
                                                  productNameFocusNode),
                                          initialValue:
                                              DateTime.now().toString(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          dateLabelText: '',
                                          onChanged: (val) => print(val),
                                          validator: (val) {
                                            print(val);
                                            return null;
                                          },
                                          onSaved: (val) => print(val),
                                          style: TextStyle(
                                              fontSize:
                                                  15), // Font size can be adjusted as needed
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal:
                                                    15.0), // Adjusted padding
                                            border: InputBorder
                                                .none, // Remove the border
                                            filled: true,
                                            fillColor: Colors.grey[
                                                200], // Ensure background color matches container
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

                        //  Gst Method
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Text("GST Method",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.type_specimen_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller:
                                                purchaseGstMethodController,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  Product Name
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("Product Name",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.41,
                                  child: Row(
                                    children: [
                                      Container(
                                          child: _buildProduct5NameDropdown()),
                                      SizedBox(width: 3),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  Rate
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 10,
                                    top: 8),
                                child:
                                    Text("Rate", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 15,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.currency_rupee,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller: rateController,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                            style: AmountTextStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quantity
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("Quantity",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.production_quantity_limits,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.32,
                                        color: Colors.grey[200],
                                        child: Focus(
                                          onKey: (FocusNode node,
                                              RawKeyEvent event) {
                                            if (event is RawKeyDownEvent) {
                                              if (event.logicalKey ==
                                                  LogicalKeyboardKey
                                                      .arrowDown) {
                                                FocusScope.of(context).requestFocus(
                                                    finaldiscountPercFocusNode);
                                                return KeyEventResult.handled;
                                              } else if (event.logicalKey ==
                                                  LogicalKeyboardKey.enter) {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        DisPercFocusMode);
                                                return KeyEventResult.handled;
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: TextFormField(
                                              focusNode: quantityFocusMode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              controller: quantityController,
                                              onFieldSubmitted: (_) {
                                                _fieldFocusChange(
                                                  context,
                                                  quantityFocusMode,
                                                  DisPercFocusMode,
                                                );
                                              },
                                              onChanged: (newValue) {
                                                // quantityController.text = newValue;
                                                updateTotal();
                                                updatediscountamt();
                                                updatediscountpercentage();
                                                updatetaxableamount();
                                                updateCGSTAmount();
                                                updateSGSTAmount();
                                                updateFinalAmount();
                                              },
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          const Color.fromARGB(
                                                              0, 255, 255, 255),
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
                              ),
                            ],
                          ),
                        ),
                        // Total
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child:
                                    Text("Total", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money_rounded,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller: TotalController,
                                            onChanged: (_) => updateTotal(),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                            style: AmountTextStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Discount Percentage
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("Discount %",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.percent,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode: DisPercFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    DisPercFocusMode,
                                                    DisAmtFocusMode),
                                            controller:
                                                discountPercentageController,
                                            onChanged: (newValue) {
                                              // quantityController.text = newValue;
                                              updatediscountamt();
                                              updatetaxableamount();
                                              updateCGSTAmount();
                                              updateSGSTAmount();
                                              updateFinalAmount();
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Discount Amount
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Text("Discount ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.discount_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode: DisAmtFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    DisAmtFocusMode,
                                                    FinalAmtFocusMode),
                                            controller:
                                                discountAmountController,
                                            onChanged: (newValue) {
                                              updatediscountpercentage();
                                              updatetaxableamount();
                                              updateCGSTAmount();
                                              updateSGSTAmount();
                                              updateFinalAmount();
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Taxable Amount
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("Taxable ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.payment_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller: taxableController,
                                            onChanged: (newValue) {
                                              updateCGSTAmount();
                                              updateSGSTAmount();
                                              updateFinalAmount();
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cgst Percentage
                        // Container(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: EdgeInsets.only(
                        //             left:
                        //                 Responsive.isDesktop(context) ? 20 : 10,
                        //             top: 8),
                        //         child: Text(
                        //           "CGST %",
                        //           style: TextStyle(fontSize: 12),
                        //         ),
                        //       ),
                        //       SingleChildScrollView(
                        //         scrollDirection: Axis.horizontal,
                        //         child: Padding(
                        //           padding: EdgeInsets.only(
                        //               left: Responsive.isDesktop(context)
                        //                   ? 20
                        //                   : 15,
                        //               top: 8),
                        //           child: Container(
                        //             width: Responsive.isDesktop(context)
                        //                 ? 250
                        //                 : MediaQuery.of(context).size.width *
                        //                     0.7,
                        //             child: Container(
                        //               height: 24,
                        //               width: Responsive.isDesktop(context)
                        //                   ? 200
                        //                   : MediaQuery.of(context).size.width *
                        //                       0.4,
                        //               // color: Colors.grey[200],
                        //               child: ToggleButtons(
                        //                   borderColor: Colors.grey,
                        //                   fillColor: maincolor,
                        //                   borderWidth: 1,
                        //                   selectedBorderColor: Colors.black,
                        //                   selectedColor: Colors.white,
                        //                   borderRadius:
                        //                       BorderRadius.circular(5),
                        //                   children: <Widget>[
                        //                     Padding(
                        //                       padding:
                        //                           const EdgeInsets.all(2.0),
                        //                       child: Text(
                        //                         '0',
                        //                         style: TextStyle(fontSize: 12),
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding:
                        //                           const EdgeInsets.all(2.0),
                        //                       child: Text(
                        //                         '2.5',
                        //                         style: TextStyle(fontSize: 12),
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding:
                        //                           const EdgeInsets.all(2.0),
                        //                       child: Text(
                        //                         '6',
                        //                         style: TextStyle(fontSize: 12),
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding:
                        //                           const EdgeInsets.all(2.0),
                        //                       child: Text(
                        //                         '9',
                        //                         style: TextStyle(fontSize: 12),
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding:
                        //                           const EdgeInsets.all(2.0),
                        //                       child: Text(
                        //                         '14',
                        //                         style: TextStyle(fontSize: 12),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                   onPressed: (int index) {
                        //                     // setState(() {
                        //                     //   // Update the controller value here
                        //                     //   cgstPercentageController.text = [
                        //                     //     '0',
                        //                     //     '2.5',
                        //                     //     '6',
                        //                     //     '9',
                        //                     //     '14'
                        //                     //   ][index];

                        //                     //   // Set all elements of isCGSTSelected to false
                        //                     //   isCGSTSelected = List.generate(
                        //                     //       isCGSTSelected.length,
                        //                     //       (i) => false);
                        //                     //   // Set the selected index to true
                        //                     //   isCGSTSelected[index] = true;
                        //                     // });
                        //                   },
                        //                   isSelected: isCGSTSelected),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // //  Cgst Amount
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child:
                                    Text("CGST ₹", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.currency_rupee,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller: cgstAmountController,
                                            onChanged: (newValue) {
                                              updateFinalAmount();
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sgst Percentage
                        // Container(
                        //   // color: Subcolor,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: EdgeInsets.only(
                        //             left:
                        //                 Responsive.isDesktop(context) ? 20 : 20,
                        //             top: 8),
                        //         child: Text(
                        //           "SGST %",
                        //           style: TextStyle(fontSize: 12),
                        //         ),
                        //       ),
                        //       SingleChildScrollView(
                        //         scrollDirection: Axis.horizontal,
                        //         child: Padding(
                        //           padding: EdgeInsets.only(
                        //               left: Responsive.isDesktop(context)
                        //                   ? 20
                        //                   : 25,
                        //               top: 8),
                        //           child: Container(
                        //             width: Responsive.isDesktop(context)
                        //                 ? 250
                        //                 : MediaQuery.of(context).size.width *
                        //                     0.7,
                        //             child: Container(
                        //               height: 24,
                        //               width: 100,
                        //               child: ToggleButtons(
                        //                 borderColor: Colors.grey,
                        //                 fillColor: Colors.black,
                        //                 borderWidth: 1,
                        //                 selectedBorderColor: Colors.black,
                        //                 selectedColor: Colors.white,
                        //                 borderRadius: BorderRadius.circular(5),
                        //                 children: <Widget>[
                        //                   Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: Text(
                        //                       '0',
                        //                       style: TextStyle(fontSize: 12),
                        //                     ),
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: Text(
                        //                       '2.5',
                        //                       style: TextStyle(fontSize: 12),
                        //                     ),
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: Text(
                        //                       '6',
                        //                       style: TextStyle(fontSize: 12),
                        //                     ),
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: Text(
                        //                       '9',
                        //                       style: TextStyle(fontSize: 12),
                        //                     ),
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: Text(
                        //                       '14',
                        //                       style: TextStyle(fontSize: 12),
                        //                     ),
                        //                   ),
                        //                 ],

                        //                 onPressed: (int index) {
                        //                   // setState(() {
                        //                   //   // Only update the state if the button is not selected
                        //                   //   if (!isSGSTSelected[index]) {
                        //                   //     // Update the controller value here
                        //                   //     sgstPercentageController.text = [
                        //                   //       '0',
                        //                   //       '2.5',
                        //                   //       '6',
                        //                   //       '9',
                        //                   //       '14'
                        //                   //     ][index];
                        //                   //   }
                        //                   // });
                        //                 },
                        //                 isSelected:
                        //                     isSGSTSelected, // Make sure isSelected has the correct length
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // //  Sgst Amount
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child:
                                    Text("SGST ₹", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.currency_rupee,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            controller: sgstAmountController,
                                            onChanged: (newValue) {
                                              updateFinalAmount();
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Final Amount
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Text("Final ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.paid_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode: FinalAmtFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) {
                                              // Move focus to the save button
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      saveButtonFocusNode);
                                            },
                                            readOnly: true,
                                            controller: finalAmountController,
                                            onChanged: (newValue) {
                                              finalAmountController.text =
                                                  newValue;
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                            style: AmountTextStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //stock
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Text("Add Stock",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 30,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.paid_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            // focusNode: FinalAmtFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) {
                                              // Move focus to the save button
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      saveButtonFocusNode);
                                            },
                                            readOnly: true,
                                            controller: AddStockController,
                                            onChanged: (newValue) {
                                              AddStockController.text =
                                                  newValue;
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 255, 255, 255),
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
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
                                            style: AmountTextStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (Responsive.isDesktop(context))
                          Container(
                            // color: Subcolor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    top: 15,
                                  ),
                                  child: Text(
                                    "",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Responsive.isDesktop(context)
                                          ? 40
                                          : 40,
                                      bottom: 30,
                                      top: 0),
                                  child: Container(
                                    width:
                                        Responsive.isDesktop(context) ? 60 : 60,
                                    child: ElevatedButton(
                                      focusNode: saveButtonFocusNode,
                                      onPressed: () {
                                        saveData();
                                        FocusScope.of(context)
                                            .requestFocus(productNameFocusNode);

                                        getFinalAmtCGST0(tableData);
                                        // getProductCount(tableData);
                                        // getTotalTaxable(tableData);
                                        // gettaxableAmtSGST0(tableData);
                                        // gettaxableAmtSGST25(tableData);
                                        // gettaxableAmtSGST6(tableData);
                                        // gettaxableAmtSGST9(tableData);
                                        // gettaxableAmtSGST14(tableData);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                        backgroundColor: subcolor,
                                        minimumSize: Size(
                                            45.0, 31.0), // Set width and height
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 10.0),
                                      ),
                                      child: Text('Add',
                                          style: commonWhiteStyle.copyWith(
                                              fontSize: 14)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!Responsive.isDesktop(context))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isDesktop(context)
                                              ? 40
                                              : 40,
                                          top: 15),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? 60
                                            : 60,
                                        child: ElevatedButton(
                                          focusNode: saveButtonFocusNode,
                                          onPressed: () {
                                            saveData();
                                            FocusScope.of(context).requestFocus(
                                                productNameFocusNode);

                                            getFinalAmtCGST0(tableData);
                                            // getProductCount(tableData);
                                            // getTotalTaxable(tableData);
                                            // gettaxableAmtSGST0(tableData);
                                            // gettaxableAmtSGST25(tableData);
                                            // gettaxableAmtSGST6(tableData);
                                            // gettaxableAmtSGST9(tableData);
                                            // gettaxableAmtSGST14(tableData);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                            ),
                                            backgroundColor: subcolor,

                                            minimumSize: Size(
                                                Responsive.isDesktop(context)
                                                    ? 45.0
                                                    : 30,
                                                Responsive.isDesktop(context)
                                                    ? 31.0
                                                    : 25), // Set width and height
                                          ),
                                          child: Text('Add',
                                              style: commonWhiteStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // Container(
                        //   // color: Subcolor,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.only(left: 0, top: 8),
                        //         child: Text(
                        //           "",
                        //           style: TextStyle(fontSize: 13),
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: EdgeInsets.only(
                        //             left:
                        //                 Responsive.isDesktop(context) ? 20 : 15,
                        //             top: 0),
                        //         child: Container(
                        //           width:
                        //               Responsive.isDesktop(context) ? 70 : 70,
                        //           child: ElevatedButton(
                        //             onPressed: () {
                        //               // Handle form submission
                        //             },
                        //             style: ElevatedButton.styleFrom(
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(2.0),
                        //               ),
                        //               backgroundColor: subcolor,
                        //               minimumSize: Size(
                        //                   45.0, 31.0), // Set width and height
                        //             ),
                        //             child: Text(
                        //               'Delete',
                        //               style: TextStyle(
                        //                 color: Colors.white,
                        //                 fontSize: 12,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // // if (!Responsive.isDesktop(context))
                        //   SizedBox(width: 150),
                        // if (Responsive.isDesktop(context)) SizedBox(width: 220),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 30.0),
                        //   child: Container(
                        //     height: 30,
                        //     width: 130,
                        //     child: TextField(
                        //       onChanged: (value) {
                        //         setState(() {
                        //           searchText = value;
                        //         });
                        //       },
                        //       decoration: InputDecoration(
                        //         labelText: 'Search',
                        //         suffixIcon: Icon(
                        //           Icons.search,
                        //           color: Colors.grey,
                        //         ),
                        //         floatingLabelBehavior:
                        //             FloatingLabelBehavior.never,
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(1),
                        //         ),
                        //         enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //           borderRadius: BorderRadius.circular(1),
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //           borderRadius: BorderRadius.circular(1),
                        //         ),
                        //         contentPadding:
                        //             EdgeInsets.only(left: 10.0, right: 4.0),
                        //       ),
                        //       style: TextStyle(fontSize: 13),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    if (!Responsive.isDesktop(context)) SizedBox(height: 25),
                    Responsive.isDesktop(context)
                        ? Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Container(child: tableView())),
                              Expanded(
                                flex: 1,
                                child: PurchaseDiscountForm(
                                    finaldiscountPercFocusNode:
                                        finaldiscountPercFocusNode,
                                    clearTableData: clearTableData,
                                    recordonorefresh: recordonorefresh,
                                    tableData: tableData,
                                    getProductCountCallback: getProductCount,
                                    getTotalQuantityCallback: getTotalQuantity,
                                    getTotalTaxableCallback: getTotalTaxable,
                                    getTotalFinalTaxableCallback:
                                        getTotalFinalTaxable,
                                    getTotalCGSTAmtCallback: getTotalCGSTAmt,
                                    getTotalSGSTAMtCallback: getTotalSGSTAmt,
                                    getTotalFinalAmtCallback: getTotalFinalAmt,
                                    getTotalAmtCallback: getTotalAmt,
                                    getProductDiscountCallBack:
                                        getProductZDiscount,
                                    gettaxableAmtCGST0callback:
                                        gettaxableAmtCGST0,
                                    gettaxableAmtCGST25callback:
                                        gettaxableAmtCGST25,
                                    gettaxableAmtCGST6callback:
                                        gettaxableAmtCGST6,
                                    gettaxableAmtCGST9callback:
                                        gettaxableAmtCGST9,
                                    gettaxableAmtCGST14callback:
                                        gettaxableAmtCGST14,
                                    gettaxableAmtSGST0callback:
                                        gettaxableAmtSGST0,
                                    gettaxableAmtSGST25callback:
                                        gettaxableAmtSGST25,
                                    gettaxableAmtSGST6callback:
                                        gettaxableAmtSGST6,
                                    gettaxableAmtSGST9callback:
                                        gettaxableAmtSGST9,
                                    gettaxableAmtSGST14callback:
                                        gettaxableAmtSGST14,
                                    getFinalAmtCGST0callback: getFinalAmtCGST0,
                                    getFinalAmtCGST25callback:
                                        getFinalAmtCGST25,
                                    getFinalAmtCGST6callback: getFinalAmtCGST6,
                                    getFinalAmtCGST9callback: getFinalAmtCGST9,
                                    getFinalAmtCGST14callback:
                                        getFinalAmtCGST14,
                                    getFinalAmtSGST0callback: getFinalAmtSGST0,
                                    getFinalAmtSGST25callback:
                                        getFinalAmtSGST25,
                                    getFinalAmtSGST6callback: getFinalAmtSGST6,
                                    getFinalAmtSGST9callback: getFinalAmtSGST9,
                                    getFinalAmtSGST14callback:
                                        getFinalAmtSGST14,
                                    purchaseRecordNoController:
                                        purchaseRecordNoController,
                                    purchaseInvoiceNoController:
                                        purchaseInvoiceNoController,
                                    purchaseGSTMethodController:
                                        purchaseGstMethodController,
                                    purchaseContactController:
                                        purchaseContactNoontroller,
                                    purchaseSupplierAgentidController:
                                        purchaseSupplierAgentidController,
                                    purchaseSuppliergstnoController:
                                        purchaseSuppliergstnoController,
                                    purchaseSupplierNameController:
                                        SupplierNameController,
                                    ProductCategoryController:
                                        productCountController,
                                    selectedDate: selectedDate),
                              )
                            ],
                          )
                        : Column(
                            children: [
                              Container(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  tableView(),
                                ],
                              )),
                              if (!Responsive.isDesktop(context))
                                SizedBox(height: 30),
                              PurchaseDiscountForm(
                                finaldiscountPercFocusNode:
                                    finaldiscountPercFocusNode,
                                tableData: tableData,
                                recordonorefresh: recordonorefresh,
                                getProductCountCallback: getProductCount,
                                getTotalQuantityCallback: getTotalQuantity,
                                getTotalTaxableCallback: getTotalTaxable,
                                getTotalFinalTaxableCallback:
                                    getTotalFinalTaxable,
                                getTotalCGSTAmtCallback: getTotalCGSTAmt,
                                getTotalSGSTAMtCallback: getTotalSGSTAmt,
                                getTotalFinalAmtCallback: getTotalFinalAmt,
                                getTotalAmtCallback: getTotalAmt,
                                getProductDiscountCallBack: getProductZDiscount,
                                gettaxableAmtCGST0callback: gettaxableAmtCGST0,
                                gettaxableAmtCGST25callback:
                                    gettaxableAmtCGST25,
                                gettaxableAmtCGST6callback: gettaxableAmtCGST6,
                                gettaxableAmtCGST9callback: gettaxableAmtCGST9,
                                gettaxableAmtCGST14callback:
                                    gettaxableAmtCGST14,
                                gettaxableAmtSGST0callback: gettaxableAmtSGST0,
                                gettaxableAmtSGST25callback:
                                    gettaxableAmtSGST25,
                                gettaxableAmtSGST6callback: gettaxableAmtSGST6,
                                gettaxableAmtSGST9callback: gettaxableAmtSGST9,
                                gettaxableAmtSGST14callback:
                                    gettaxableAmtSGST14,
                                getFinalAmtCGST0callback: getFinalAmtCGST0,
                                getFinalAmtCGST25callback: getFinalAmtCGST25,
                                getFinalAmtCGST6callback: getFinalAmtCGST6,
                                getFinalAmtCGST9callback: getFinalAmtCGST9,
                                getFinalAmtCGST14callback: getFinalAmtCGST14,
                                getFinalAmtSGST0callback: getFinalAmtSGST0,
                                getFinalAmtSGST25callback: getFinalAmtSGST25,
                                getFinalAmtSGST6callback: getFinalAmtSGST6,
                                getFinalAmtSGST9callback: getFinalAmtSGST9,
                                getFinalAmtSGST14callback: getFinalAmtSGST14,
                                purchaseRecordNoController:
                                    purchaseRecordNoController,
                                purchaseInvoiceNoController:
                                    purchaseInvoiceNoController,
                                purchaseGSTMethodController:
                                    purchaseGstMethodController,
                                purchaseContactController:
                                    purchaseContactNoontroller,
                                purchaseSupplierAgentidController:
                                    purchaseSupplierAgentidController,
                                purchaseSuppliergstnoController:
                                    purchaseSuppliergstnoController,
                                purchaseSupplierNameController:
                                    SupplierNameController,
                                ProductCategoryController:
                                    productCountController,
                                selectedDate: selectedDate,
                                clearTableData: clearTableData,
                              )
                            ],
                          )
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

  void recordonorefresh() {
    fetchPurchaseRecordNo();
    setState(() {
      SupplierselectedValue = '';
      SupplierNameController.clear();
    });
  }

  void updateTotal() {
    double rate = double.tryParse(rateController.text) ?? 0;
    double quantity = double.tryParse(quantityController.text) ?? 0;
    double total = rate * quantity;
    TotalController.text =
        total.toStringAsFixed(2); // Format total to 2 decimal places
  }

  void updatediscountamt() {
    double total = double.tryParse(TotalController.text) ?? 0;

    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    double discountAmount = (total * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);
  }

  void updatediscountpercentage() {
    double total = double.tryParse(TotalController.text) ?? 0;

    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double discountPercentage = (discountAmount * 100) / total;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);
  }

  void updatetaxableamount() {
    double total = double.tryParse(TotalController.text) ?? 0;
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double cgstAmount = double.tryParse(cgstAmountController.text) ?? 0;
    double sgstAmount = double.tryParse(sgstAmountController.text) ?? 0;
    double cgstPercentage = double.tryParse(cgstPercentageController.text) ?? 0;
    double sgstPercentage = double.tryParse(sgstPercentageController.text) ?? 0;

    double numeratorPart1 = total - discountAmount;

    if (purchaseGstMethodController.text == "Excluding") {
      // Calculate taxable amount excluding GST
      double taxableAmount = numeratorPart1;
      taxableController.text = taxableAmount.toStringAsFixed(2);
    } else if (purchaseGstMethodController.text == "Including") {
      double cgstsgst = cgstPercentage + sgstPercentage;
      double cgstnumerator = numeratorPart1 * cgstPercentage;
      double cgstdenominator = 100 + cgstsgst;
      double cgsttaxable = cgstnumerator / cgstdenominator;
      double sgstnumerator = numeratorPart1 * sgstPercentage;
      double sgstdenominator = 100 + cgstsgst;
      double sgsttaxable = sgstnumerator / sgstdenominator;

      double taxableAmount = numeratorPart1 - (cgsttaxable + sgsttaxable);

      taxableController.text = taxableAmount.toStringAsFixed(2);
      // print("cgst taxable amount : $cgsttaxable");
      // print("sgst taxable amount : $sgsttaxable");
      // print("Total taxable amount : $taxableAmount");
    } else {
      double taxableAmount = numeratorPart1;
      taxableController.text = taxableAmount.toStringAsFixed(2);
    }
  }

  void updateFinalAmount() {
    double total = double.tryParse(TotalController.text) ?? 0;
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;

    double cgstAmount = double.tryParse(cgstAmountController.text) ?? 0;
    double sgstAmount = double.tryParse(sgstAmountController.text) ?? 0;
    double taxableAmount = double.tryParse(taxableController.text) ?? 0;
    double denominator = cgstAmount + sgstAmount;

    if (purchaseGstMethodController.text == "Excluding") {
      double finalAmount = taxableAmount + denominator;

      // Update the final amount controller
      finalAmountController.text = finalAmount.toStringAsFixed(2);
    } else if (purchaseGstMethodController.text == "Including") {
      double totalfinalamount = total - discountAmount;
      finalAmountController.text = totalfinalamount.toStringAsFixed(2);
    } else {
      double taxableAmount = total - discountAmount;
      finalAmountController.text = taxableAmount.toStringAsFixed(2);
    }
  }

  void updateCGSTAmount() {
    double taxableAmount = double.tryParse(taxableController.text) ?? 0;
    double cgstPercentage = double.tryParse(cgstPercentageController.text) ?? 0;
    double numerator = (taxableAmount * cgstPercentage);
    // Calculate the CGST amount
    double cgstAmount = numerator / 100;

    // Update the CGST amount controller
    cgstAmountController.text = cgstAmount.toStringAsFixed(2);
  }

  void updateSGSTAmount() {
    double taxableAmount = double.tryParse(taxableController.text) ?? 0;
    double sgstPercentage = double.tryParse(sgstPercentageController.text) ?? 0;
    double numerator = (taxableAmount * sgstPercentage);
    // Calculate the CGST amount
    double sgstAmount = numerator / 100;

    // Update the CGST amount controller
    sgstAmountController.text = sgstAmount.toStringAsFixed(2);
  }

  Future<void> fetchCGSTPercentages() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalAmount = 0; // Initialize total amount to 0

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Iterate through each entry in the results
      for (var entry in results) {
        // Check if product name matches
        if (entry['name'] == ProductNameController.text) {
          // Parse and accumulate the amount
          double amount = double.parse(entry['cgstperc'] ?? '0');
          totalAmount += amount;
        }
      }

      // Update cgstPercentageController with the fetched value
      cgstPercentageController.text = totalAmount.toString();

      // Enable the corresponding button based on the fetched value
      setState(() {
        isCGSTSelected = ['0', '2.5', '6', '9', '14']
            .map((value) => value == cgstPercentageController.text)
            .toList();
      });

      // Print the total amount after the loop
      // print(
      //     "CGST percentage of the ${ProductNameController.text} is ${cgstPercentageController.text}");
    }
  }

  Future<void> fetchSGSTPercentages() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalAmount = 0; // Initialize total amount to 0

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Iterate through each entry in the results
      for (var entry in results) {
        // Check if product name matches
        if (entry['name'] == ProductNameController.text) {
          // Parse and accumulate the amount
          double amount = double.parse(entry['sgstperc'] ?? '0');
          totalAmount += amount;
        }
      }

      // Update cgstPercentageController with the fetched value
      sgstPercentageController.text = totalAmount.toString();

      // Enable the corresponding button based on the fetched value
      setState(() {
        isSGSTSelected = ['0', '2.5', '6', '9', '14']
            .map((value) => value == sgstPercentageController.text)
            .toList();
      });

      // Print the total amount after the loop
      // print(
      //     "SGST percentage of the ${ProductNameController.text} is ${sgstPercentageController.text}");
    }
  }

  Future<void> fetchGSTMethod() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/GstDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    String gstMethod = ''; // Initialize GST method to empty string

    // Iterate through each entry in the JSON data
    for (var entry in jsonData) {
      // Check if the name is "Sales"
      if (entry['name'] == "Purchase") {
        // Retrieve the GST method for "Sales"
        gstMethod = entry['gst'];
        break; // Exit the loop once the entry is found
      }
    }

    // Update rateController if needed
    if (gstMethod.isNotEmpty) {
      purchaseGstMethodController.text = gstMethod;
      // print("GST method for Sales: $gstMethod");
    } else {
      // print("No GST method found for Sales");
    }
  }

  Future<void> fetchSupplierContact() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/PurchaseSupplierNames/$cusid/';
    String supplierName = SupplierNameController.text;
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
            if (entry['name'] == supplierName) {
              // Retrieve the contact number for the supplier
              String contactno = entry['contact'];
              String agentId = entry['id'].toString();
              String gstNo = entry['gstno'];
              if (contactno.isNotEmpty) {
                purchaseContactNoontroller.text = contactno;
                purchaseSupplierAgentidController.text = agentId;
                purchaseSuppliergstnoController.text = gstNo;
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
        print("No contact number found for $supplierName");
      }
    } catch (e) {
      print('Error fetching supplier contact information: $e');
    }
  }

  Future<void> fetchProductAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    double totalAmount = 0; // Initialize total amount to 0
    String totalAddStock = ''; // Initialize total add stock as an empty string

    // Page number starts from 1
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      // Construct the URL with the current page number
      String url = '$apiUrl?page=$page';

      // Make the HTTP GET request
      http.Response response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      // Check if results exist
      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Iterate through each entry in the results
        for (var entry in results) {
          // Check if product name matches
          if (entry['name'] == ProductNameController.text) {
            // Parse and accumulate the amount
            double amount = double.parse(entry['amount'] ?? '0');
            totalAmount += amount;

            // Extract addstock as a string
            String addstockString = entry['addstock'] ?? '0';

            // Append addstockString to totalAddStock
            totalAddStock += addstockString;
          }
        }

        // Increment page number for next request
        page++;

        // Check if there are more pages
        hasMorePages = jsonData['next'] != null;
      } else {
        // No results found
        hasMorePages = false;
      }
    }

    // Set the rate and stock check controllers' text values
    rateController.text = totalAmount
        .toStringAsFixed(2); // Convert to string with 2 decimal places
    stockcheckController.text = totalAddStock;

    // Print the total amount after fetching all pages
    // print("stock check of ${stockcheckController.text} ");
  }

  Future<void> fetchProductCategory() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    String totalCategory = ''; // Initialize total category to empty string

    // Page number starts from 1
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        // Construct the URL with the current page number
        String url = '$apiUrl?page=$page';

        // Make the HTTP GET request
        http.Response response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

          if (jsonData['results'] != null) {
            List<Map<String, dynamic>> results =
                List<Map<String, dynamic>>.from(jsonData['results']);

            // Iterate through each entry in the results
            for (var entry in results) {
              // Check if product name matches
              if (entry['name'] == ProductNameController.text) {
                // Accumulate the categories
                String category = entry['category'] ?? '';
                totalCategory += category + ', ';
              }
            }

            // Check if there are more pages
            if (jsonData['next'] != null) {
              // Increment page number for next request
              page++;
            } else {
              // No more pages, exit the loop
              hasMorePages = false;
            }
          } else {
            // No results found, exit the loop
            hasMorePages = false;
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching product category: $e');
        // Exit the loop on error
        hasMorePages = false;
      }
    }

    // Remove the trailing comma and space
    if (totalCategory.isNotEmpty) {
      totalCategory = totalCategory.substring(0, totalCategory.length - 2);
    }

    // Update the ProductCategoryController text
    ProductCategoryController.text = totalCategory;

    // print(
    //     "Product Category Controller text is ${ProductCategoryController.text}");
  }

  List<String> SupplierNameList = [];

  Future<void> fetchSupplierNamelist() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PurchaseSupplierNames/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          SupplierNameList.addAll(
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

      // print('All product categories: $SupplierNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController SupplierNameController = TextEditingController();
  String? SupplierselectedValue;

  int? _selectedSuppliernameIndex;

  bool _isSupplierNameOptionsVisible = false;
  int? _SupplierhoveredIndex;

  Widget _buildSupplierNameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          Icon(
            Icons.person_pin_outlined,
            size: 18,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.085
                        : MediaQuery.of(context).size.width * 0.25,
                    child: SupplilerNameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          width: 1150,
                          height: 800,
                          padding: EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              PurchaseCustomerSupplier(),
                              Positioned(
                                right: 0.0,
                                top: 0.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchSupplierNamelist();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(color: subcolor),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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

  Widget SupplilerNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                SupplierNameList.indexOf(SupplierNameController.text);
            if (currentIndex < SupplierNameList.length - 1) {
              setState(() {
                _selectedSuppliernameIndex = currentIndex + 1;
                SupplierNameController.text =
                    SupplierNameList[currentIndex + 1];
                _isSupplierNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                SupplierNameList.indexOf(SupplierNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedSuppliernameIndex = currentIndex - 1;
                SupplierNameController.text =
                    SupplierNameList[currentIndex - 1];
                _isSupplierNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: SupplierNameFocustNode,
          onSubmitted: (String? suggestion) async {
            await fetchSupplierContact();
            _fieldFocusChange(context, SupplierNameFocustNode, DateFocustNode);
          },
          controller: SupplierNameController,
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
          onChanged: (text) async {
            setState(() {
              _isSupplierNameOptionsVisible = true;
              SupplierselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isSupplierNameOptionsVisible && pattern.isNotEmpty) {
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
              _SupplierhoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _SupplierhoveredIndex = null;
            }),
            child: Container(
              color: _selectedSuppliernameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedSuppliernameIndex == null &&
                          SupplierNameList.indexOf(
                                  SupplierNameController.text) ==
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
            SupplierNameController.text = suggestion!;
            SupplierselectedValue = suggestion;
            _isSupplierNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(DateFocustNode);
          });
          await fetchSupplierContact();
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  List<String> ProductNameList = [];
  final TextEditingController AddStockController = TextEditingController();

//fetch stock correct code
  Future<void> fetchAddStock() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    String totalStock = ''; // Initialize total stock to empty string

    // Page number starts from 1
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        // Construct the URL with the current page number
        String url = '$apiUrl?page=$page';

        // Make the HTTP GET request
        http.Response response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

          if (jsonData['results'] != null) {
            List<Map<String, dynamic>> results =
                List<Map<String, dynamic>>.from(jsonData['results']);

            // Iterate through each entry in the results
            for (var entry in results) {
              // Check if product name matches
              if (entry['name'] == ProductNameController.text) {
                // Accumulate the stock details
                String stock = entry['addstock'] ?? '0';
                totalStock = stock;
              }
            }

            // Check if there are more pages
            if (jsonData['next'] != null) {
              // Increment page number for next request
              page++;
            } else {
              // No more pages, exit the loop
              hasMorePages = false;
            }
          } else {
            // No results found, exit the loop
            hasMorePages = false;
          }
        } else {
          throw Exception(
              'Failed to load add stock details: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching add stock: $e');
        // Exit the loop on error
        hasMorePages = false;
      }
    }

    // Update the AddStockController text
    AddStockController.text = totalStock;

    // Optionally print the result for debugging
    // print("AddStockController text is ${AddStockController.text}");
  }

  //stock fetch
  // Future<void> fetchAddStock() async {
  //   try {
  //     String? cusid = await SharedPrefs.getCusId();
  //     String url = '$IpAddress/PurchaseProductDetails/$cusid/';
  //     bool hasNextPage = true;

  //     while (hasNextPage) {
  //       final response = await http.get(Uri.parse(url));

  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> data = jsonDecode(response.body);
  //         final List<dynamic> results = data['results'];

  //         for (var item in results) {
  //           String productName = item['name'].toString();
  //           String addStock =
  //               item['addstock'].toString(); // Fetch the addstock value

  //           // Add product name to the list
  //           ProductNameList.add(productName);

  //           // Print the product name and addstock value
  //           print('Product: $productName, Add Stock: $addStock');
  //         }

  //         hasNextPage = data['next'] != null;
  //         if (hasNextPage) {
  //           url = data['next'];
  //         }
  //       } else {
  //         throw Exception(
  //             'Failed to load categories: ${response.reasonPhrase}');
  //       }
  //     }

  //     // Uncomment this line to print all product names if needed
  //     // print('All product categories: $ProductNameList');
  //   } catch (e) {
  //     print('Error fetching categories: $e');
  //     rethrow; // Rethrow the error to propagate it further
  //   }
  // }

  Future<void> fetchAllProductNames() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String url = '$IpAddress/PurchaseProductDetails/$cusid/';
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

      // print('All product categories: $ProductNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController ProductNameController = TextEditingController();

  String? selectedProductName;
  bool _isProdNameOptionsVisible = false;

  int? _productnamehoveredIndex;
  int? _selectedProductnameIndex;

  Widget _buildProduct5NameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          Icon(
            Icons.family_restroom_rounded,
            size: 18,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.085
                        : MediaQuery.of(context).size.width * 0.25,
                    child: ProductNameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          width: 1300,
                          height: 800,
                          padding: EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              PurchaseProductDetails(),
                              Positioned(
                                right: 0.0,
                                top: 0.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchAllProductNames();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(color: subcolor),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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

  // Future<void> fetchAndCheckProduct(String productName) async {
  //   final url = 'http://192.168.10.117:88/Settings_ProductDetails/BTRM_23/';
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final List<dynamic> products = data[
  //           'results']; // Adjust according to the actual response structure

  //       bool productExists = products.any((product) =>
  //           product['name'].toLowerCase() == productName.toLowerCase());

  //       if (productExists) {
  //         print('The product name "$productName" already exists.');
  //       } else {
  //         print('The product name "$productName" does not exist.');
  //       }
  //     } else {
  //       print('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  Widget ProductNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProductnameIndex = currentIndex + 1;
                ProductNameController.text = ProductNameList[currentIndex + 1];
                _isProdNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductnameIndex = currentIndex - 1;
                ProductNameController.text = ProductNameList[currentIndex - 1];
                _isProdNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: productNameFocusNode,
          onSubmitted: (String? suggestion) async {
            await fetchProductAmount();
            await fetchCGSTPercentages();
            await fetchSGSTPercentages();
            await fetchProductCategory();
            await fetchAddStock();
            _fieldFocusChange(context, productNameFocusNode, quantityFocusMode);
          },
          controller: ProductNameController,
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
          onChanged: (text) async {
            setState(() {
              _isProdNameOptionsVisible = true;
              selectedProductName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProdNameOptionsVisible && pattern.isNotEmpty) {
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
              _productnamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _productnamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductnameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductnameIndex == null &&
                          ProductNameList.indexOf(ProductNameController.text) ==
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
          await fetchProductAmount();
          await fetchCGSTPercentages();
          await fetchSGSTPercentages();
          await fetchProductCategory();
          await fetchAddStock();

          setState(() {
            ProductNameController.text = suggestion!;
            selectedProductName = suggestion;
            _isProdNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(quantityFocusMode);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

// dropdwon with fetch and check
  // Widget ProductNameDropdown() {
  //   return RawKeyboardListener(
  //     focusNode: FocusNode(),
  //     onKey: (RawKeyEvent event) {
  //       if (event is RawKeyDownEvent) {
  //         if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
  //           // Handle arrow down event
  //           int currentIndex =
  //               ProductNameList.indexOf(ProductNameController.text);
  //           if (currentIndex < ProductNameList.length - 1) {
  //             setState(() {
  //               _selectedProductnameIndex = currentIndex + 1;
  //               ProductNameController.text = ProductNameList[currentIndex + 1];
  //               _isProdNameOptionsVisible = false;
  //             });
  //           }
  //         } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
  //           // Handle arrow up event
  //           int currentIndex =
  //               ProductNameList.indexOf(ProductNameController.text);
  //           if (currentIndex > 0) {
  //             setState(() {
  //               _selectedProductnameIndex = currentIndex - 1;
  //               ProductNameController.text = ProductNameList[currentIndex - 1];
  //               _isProdNameOptionsVisible = false;
  //             });
  //           }
  //         }
  //       }
  //     },
  //     child: TypeAheadFormField<String>(
  //       textFieldConfiguration: TextFieldConfiguration(
  //         focusNode: productNameFocusNode,
  //         onSubmitted: (String? suggestion) async {
  //           if (suggestion != null && suggestion.isNotEmpty) {
  //             await fetchAndCheckProduct(suggestion);
  //           }
  //           await fetchProductAmount();
  //           await fetchCGSTPercentages();
  //           await fetchSGSTPercentages();
  //           await fetchProductCategory();
  //           await fetchAddStock();
  //           _fieldFocusChange(context, productNameFocusNode, quantityFocusMode);
  //         },
  //         controller: ProductNameController,
  //         decoration: const InputDecoration(
  //           border: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.black, width: 1.0),
  //           ),
  //           contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //           labelStyle: DropdownTextStyle,
  //           suffixIcon: Icon(
  //             Icons.keyboard_arrow_down,
  //             size: 18,
  //           ),
  //         ),
  //         style: DropdownTextStyle,
  //         onChanged: (text) async {
  //           setState(() {
  //             _isProdNameOptionsVisible = true;
  //             selectedProductName = text.isEmpty ? null : text;
  //           });
  //         },
  //       ),
  //       suggestionsCallback: (pattern) {
  //         if (_isProdNameOptionsVisible && pattern.isNotEmpty) {
  //           return ProductNameList.where(
  //               (item) => item.toLowerCase().contains(pattern.toLowerCase()));
  //         } else {
  //           return ProductNameList;
  //         }
  //       },
  //       itemBuilder: (context, suggestion) {
  //         final index = ProductNameList.indexOf(suggestion);
  //         return MouseRegion(
  //           onEnter: (_) => setState(() {
  //             _productnamehoveredIndex = index;
  //           }),
  //           onExit: (_) => setState(() {
  //             _productnamehoveredIndex = null;
  //           }),
  //           child: Container(
  //             color: _selectedProductnameIndex == index
  //                 ? Colors.grey.withOpacity(0.3)
  //                 : _selectedProductnameIndex == null &&
  //                         ProductNameList.indexOf(ProductNameController.text) ==
  //                             index
  //                     ? Colors.grey.withOpacity(0.1)
  //                     : Colors.transparent,
  //             height: 28,
  //             child: ListTile(
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 10.0,
  //               ),
  //               dense: true,
  //               title: Padding(
  //                 padding: const EdgeInsets.only(bottom: 5.0),
  //                 child: Text(
  //                   suggestion,
  //                   style: DropdownTextStyle,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //       suggestionsBoxDecoration: const SuggestionsBoxDecoration(
  //         constraints: BoxConstraints(maxHeight: 150),
  //       ),
  //       onSuggestionSelected: (String? suggestion) async {
  //         await fetchProductAmount();
  //         await fetchCGSTPercentages();
  //         await fetchSGSTPercentages();
  //         await fetchProductCategory();
  //         await fetchAddStock();
  //         if (suggestion != null && suggestion.isNotEmpty) {
  //           await fetchAndCheckProduct(suggestion);
  //         }
  //         setState(() {
  //           ProductNameController.text = suggestion!;
  //           selectedProductName = suggestion;
  //           _isProdNameOptionsVisible = false;

  //           FocusScope.of(context).requestFocus(quantityFocusMode);
  //         });
  //       },
  //       noItemsFoundBuilder: (context) => Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(
  //           'No Items Found!!!',
  //           style: TextStyle(fontSize: 12, color: Colors.grey),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  void saveData() {
    // Check if any required field is empty
    if (purchaseInvoiceNoController.text.isEmpty ||
        SupplierNameController.text.isEmpty ||
        purchaseContactNoontroller.text.isEmpty ||
        ProductNameController.text.isEmpty ||
        rateController.text.isEmpty ||
        quantityController.text.isEmpty ||
        TotalController.text.isEmpty ||
        discountPercentageController.text.isEmpty ||
        discountAmountController.text.isEmpty ||
        taxableController.text.isEmpty ||
        cgstPercentageController.text.isEmpty ||
        cgstAmountController.text.isEmpty ||
        sgstPercentageController.text.isEmpty ||
        sgstAmountController.text.isEmpty ||
        finalAmountController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    }

    String productName = ProductNameController.text;
    String rate = rateController.text;
    String stockcheck = stockcheckController.text;
    String quantity = quantityController.text;
    String total = TotalController.text;
    String discountPercentage = discountPercentageController.text;
    String discountAmount = discountAmountController.text;
    String taxable = taxableController.text;
    String cgstPercentage = purchaseGstMethodController.text.isEmpty
        ? "0"
        : cgstPercentageController.text;

    String cgstAmount = purchaseGstMethodController.text.isEmpty
        ? "0"
        : cgstAmountController.text;
    String sgstPercentage = purchaseGstMethodController.text.isEmpty
        ? "0"
        : sgstPercentageController.text;
    String sgstAmount = purchaseGstMethodController.text.isEmpty
        ? "0"
        : sgstAmountController.text;
    String finalAmount = finalAmountController.text;
    String stock = AddStockController.text;

    // Check if the product already exists in tableData
    bool found = false;
    for (var item in tableData) {
      if (item['productName'] == productName) {
        // Update quantity
        item['quantity'] =
            (int.parse(item['quantity']) + int.parse(quantity)).toString();
        // Update total, discountpercentage, discountamount, taxableAmount, cgstAmount, sgstAmount, finalAmount
        item['total'] =
            (double.parse(item['total']) + double.parse(total)).toString();
        item['discountpercentage'] = (double.parse(item['discountpercentage']) +
                double.parse(discountPercentage))
            .toString();
        item['discountamount'] = (double.parse(item['discountamount']) +
                double.parse(discountAmount))
            .toString();
        item['taxableAmount'] =
            (double.parse(item['taxableAmount']) + double.parse(taxable))
                .toString();
        item['cgstAmount'] =
            (double.parse(item['cgstAmount']) + double.parse(cgstAmount))
                .toStringAsFixed(2);
        item['sgstAmount'] =
            (double.parse(item['sgstAmount']) + double.parse(sgstAmount))
                .toStringAsFixed(2);
        item['finalAmount'] =
            (double.parse(item['finalAmount']) + double.parse(finalAmount))
                .toString();
        item['addstock'] =
            (double.parse(item['addstock']) + double.parse(stock)).toString();
        found = true;
        break;
      }
    }

    // If the product doesn't exist, add it to tableData
    if (!found) {
      setState(() {
        tableData.add({
          'productName': productName,
          'rate': rate,
          'quantity': quantity,
          "total": total,
          "discountpercentage": discountPercentage,
          "discountamount": discountAmount,
          "taxableAmount": taxable,
          "cgstpercentage": cgstPercentage,
          "cgstAmount": cgstAmount,
          "sgstPercentage": sgstPercentage,
          "sgstAmount": sgstAmount,
          "finalAmount": finalAmount,
          "addstock": stock
        });
      });
    }

    // Clear text controllers
    setState(() {
      // ProductName = null;
      ProductNameController.clear(); // Clear the text field
    });
    rateController.clear();
    quantityController.clear();
    TotalController.clear();
    discountPercentageController.clear();
    discountAmountController.clear();
    taxableController.clear();
    cgstPercentageController.clear();
    cgstAmountController.clear();
    sgstPercentageController.clear();
    sgstAmountController.clear();
    finalAmountController.clear();
    AddStockController.clear();
    isCGSTSelected = [true, false, false, false, false];
    isSGSTSelected = [true, false, false, false, false];
  }

  void _deleteRow(int index) {
    setState(() {
      tableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

  Future<bool?> _showDeleteConfirmationDialog(index) async {
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
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteRow(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void clearTableData() {
    setState(() {
      tableData.clear();
    });
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.68 : 320,
          // height: Responsive.isDesktop(context) ? 350 : 320,
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
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.77
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.fastfood,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 1),
                                  Text("P.Name",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.attach_money,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Rate",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.add_box,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Qty",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.currency_exchange_outlined,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Total",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.pie_chart,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Dis %",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.monetization_on,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Dis ₹",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.currency_exchange_outlined,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Taxable",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Flexible(
                        //   child: Container(
                        //     height: Responsive.isDesktop(context) ? 25 : 30,
                        //     width: 265.0,
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey[200],
                        //     ),
                        //     child: Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           // Icon(
                        //           //   Icons.pie_chart,
                        //           //   size: 15,
                        //           //   color: Colors.blue,
                        //           // ),
                        //           // SizedBox(width: 5),
                        //           Text(
                        //             "Cgst%",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               color: Colors.black,
                        //               fontWeight: FontWeight.w500,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.local_atm,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Cgst %-₹",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Flexible(
                        //   child: Container(
                        //     height: Responsive.isDesktop(context) ? 25 : 30,
                        //     width: 265.0,
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey[200],
                        //     ),
                        //     child: Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           // Icon(
                        //           //   Icons.pie_chart,
                        //           //   size: 15,
                        //           //   color: Colors.blue,
                        //           // ),
                        //           // SizedBox(width: 5),
                        //           Text(
                        //             "Sgst%",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               color: Colors.black,
                        //               fontWeight: FontWeight.w500,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.local_atm,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Sgst %-₹",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.attach_money,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Add Stock",
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
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.attach_money,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("FinAmt",
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
                            width: 100,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                  // SizedBox(width: 5),
                                  // Text(
                                  //   "Delete",
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: Colors.black,
                                  //     fontWeight: FontWeight.w500,
                                  //   ),
                                  // ),
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
                      var productName = data['productName'].toString();
                      var rate = data['rate'].toString();
                      var quantity = data['quantity'].toString();
                      var total = data['total'].toString();
                      var discountpercentage =
                          data['discountpercentage'].toString();
                      var discountamount = data['discountamount'].toString();
                      var taxableAmount = data['taxableAmount'].toString();
                      var cgstpercentage = data['cgstpercentage'] ?? 0;

                      var cgstAmount = data['cgstAmount'].toString();
                      var sgstPercentage = data['sgstPercentage'] ?? 0;
                      var sgstAmount = data['sgstAmount'].toString();
                      var finalAmount = data['finalAmount'].toString();
                      var addstock = data['addstock'].toString();
                      // print("stock checkkkk : $addstock");

                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
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
                                child: Tooltip(
                                  message: productName,
                                  child: Center(
                                    child: Text(productName,
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
                                  color: rowColor,
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
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(quantity,
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
                                  child: Text(total,
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
                                  child: Text(discountpercentage,
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
                                  child: Text(discountamount,
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
                                  child: Text(taxableAmount,
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
                                  child: Text(
                                      "${cgstpercentage.toString()}-$cgstAmount", // Convert to string explicitly
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   child: Container(
                            //     height: 30,
                            //     width: 265.0,
                            //     decoration: BoxDecoration(
                            //       color: rowColor,
                            //       border: Border.all(
                            //         color: Color.fromARGB(255, 226, 225, 225),
                            //       ),
                            //     ),
                            //     child: Center(
                            //       child: Text(
                            //         cgstAmount,
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.w400,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                  child: Text(
                                      "${sgstPercentage.toString()}-${sgstAmount}",
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   child: Container(
                            //     height: 30,
                            //     width: 265.0,
                            //     decoration: BoxDecoration(
                            //       color: rowColor,
                            //       border: Border.all(
                            //         color: Color.fromARGB(255, 226, 225, 225),
                            //       ),
                            //     ),
                            //     child: Center(
                            //       child: Text(
                            //         sgstAmount,
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.w400,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                  child: Text(addstock,
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
                                  child: Text(finalAmount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Padding(
                                      //   padding: const EdgeInsets.only(left: 0),
                                      //   child: Container(
                                      //     child: IconButton(
                                      //       icon: Icon(
                                      //         Icons.add,
                                      //         color: Colors.blue,
                                      //         size: 18,
                                      //       ),
                                      //       onPressed: () {
                                      //         print(
                                      //             "Serial No | Date | Product Name | Quantity | Rate | Discount % | Total | CGST % | CGST Amount | SGST % | SGST Amount | Final Amount | DiscountPercentage | Taxable Amount | igstperc | igstamnt | cessperc | cessamnt");

                                      //         // Print data from each row
                                      //         for (var data in tableData) {
                                      //           print(
                                      //               "${purchaseRecordNoController.text} | ${DateFormat('yyyy-MM-dd').format(selectedDate)} | ${data['productName']} | ${data['quantity']} | ${data['rate']} | ${data['discountpercentage']} | ${data['total']} | ${data['cgstpercentage']} | ${data['cgstAmount']} | ${data['sgstPercentage']} | ${data['sgstAmount']} | ${data['finalAmount']}|  ${data['discountamount']} | | ${data['taxableAmount']} 0 | 0 | 0 | 0");
                                      //         }

                                      //         // Call postDataToAPI method after the loop
                                      //         Post__purchaseDetails(
                                      //             tableData,
                                      //             purchaseRecordNoController
                                      //                 .text,
                                      //             selectedDate);
                                      //       },
                                      //       color: Colors.black,
                                      //     ),
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Container(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  index);
                                            },
                                            color: Colors.black,
                                          ),
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
                    }).toList()
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int getProductCount(List<Map<String, dynamic>> tableData) {
  int count = tableData.length;
  // print('Product count: $count');
  return count;
}

int getTotalQuantity(List<Map<String, dynamic>> tableData) {
  int totalQuantity = 0;
  for (var data in tableData) {
    int quantity = int.tryParse(data['quantity']!) ?? 0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalTaxable(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['taxableAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  // print('Product count: $totalQuantity');

  totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
  return totalQuantity;
}

double getTotalFinalTaxable(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['taxableAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  // print('Product count: $totalQuantity');

  totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
  return totalQuantity;
}

double getTotalCGSTAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['cgstAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalSGSTAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['sgstAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['finalAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['finalAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double gettaxableAmtCGST0(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 0) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST25(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 2.5) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST6(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 6) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST9(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 9) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST14(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 14) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtSGST0(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 0) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 0 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST25(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 2.5) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 2.5 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST6(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 6) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 6 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST9(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 9) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 9 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST14(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 14) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 14 :$taxableAmount ");
  }
  return taxableAmount;
}

double getFinalAmtCGST0(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 0) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  // print("Total amount with CGST 0%: $totalAmountCGST0 ");
  return totalAmountCGST0;
}

double getFinalAmtCGST25(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 2.5) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtCGST6(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 6) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtCGST9(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 9) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtCGST14(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 14) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST0(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 0) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST25(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 2.5) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST6(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 6) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST9(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 9) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST14(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 14) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getProductZDiscount(List<Map<String, dynamic>> tableData) {
  double totalProductDiscount = 0.0;
  for (var data in tableData) {
    // Parse discountpercentage as a double
    double productDiscount = double.tryParse(data['discountamount']!) ?? 0.0;
    totalProductDiscount += productDiscount;
  }
  return totalProductDiscount;
}

class PurchaseDiscountForm extends StatefulWidget {
  final Function clearTableData;
  final Function recordonorefresh;

  final List<Map<String, dynamic>> tableData;
  final Function(List<Map<String, dynamic>>) getProductCountCallback;
  final Function(List<Map<String, dynamic>>) getTotalQuantityCallback;
  final Function(List<Map<String, dynamic>>) getTotalTaxableCallback;
  final Function(List<Map<String, dynamic>>) getTotalFinalTaxableCallback;

  final Function(List<Map<String, dynamic>>) getTotalCGSTAmtCallback;
  final Function(List<Map<String, dynamic>>) getTotalSGSTAMtCallback;
  final Function(List<Map<String, dynamic>>) getTotalFinalAmtCallback;
  final Function(List<Map<String, dynamic>>) getTotalAmtCallback;

  final Function(List<Map<String, dynamic>>) getProductDiscountCallBack;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST0callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST25callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST6callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST9callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST14callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST0callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST25callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST6callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST9callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST14callback;

  final Function(List<Map<String, dynamic>>) getFinalAmtCGST0callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST25callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST6callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST9callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST14callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST0callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST25callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST6callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST9callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST14callback;

  final TextEditingController purchaseRecordNoController;
  final TextEditingController purchaseInvoiceNoController;
  final TextEditingController purchaseGSTMethodController;
  final TextEditingController purchaseContactController;
  final TextEditingController purchaseSupplierAgentidController;
  final TextEditingController purchaseSuppliergstnoController;
  final TextEditingController ProductCategoryController;

  final TextEditingController purchaseSupplierNameController;
  final FocusNode finaldiscountPercFocusNode;

  // final String purchaseSupplierNameController;

  final DateTime selectedDate;

  PurchaseDiscountForm(
      {required this.tableData,
      required this.recordonorefresh,
      required this.getProductCountCallback,
      required this.getTotalQuantityCallback,
      required this.getTotalTaxableCallback,
      required this.getTotalFinalTaxableCallback,
      required this.getTotalCGSTAmtCallback,
      required this.getTotalSGSTAMtCallback,
      required this.getTotalFinalAmtCallback,
      required this.getTotalAmtCallback,
      required this.getProductDiscountCallBack,
      required this.gettaxableAmtCGST0callback,
      required this.gettaxableAmtCGST25callback,
      required this.gettaxableAmtCGST6callback,
      required this.gettaxableAmtCGST9callback,
      required this.gettaxableAmtCGST14callback,
      required this.gettaxableAmtSGST0callback,
      required this.gettaxableAmtSGST25callback,
      required this.gettaxableAmtSGST6callback,
      required this.gettaxableAmtSGST9callback,
      required this.gettaxableAmtSGST14callback,
      required this.getFinalAmtCGST0callback,
      required this.getFinalAmtCGST25callback,
      required this.getFinalAmtCGST6callback,
      required this.getFinalAmtCGST9callback,
      required this.getFinalAmtCGST14callback,
      required this.getFinalAmtSGST0callback,
      required this.getFinalAmtSGST25callback,
      required this.getFinalAmtSGST6callback,
      required this.getFinalAmtSGST9callback,
      required this.getFinalAmtSGST14callback,
      required this.purchaseRecordNoController,
      required this.purchaseSupplierNameController,
      required this.purchaseInvoiceNoController,
      required this.purchaseGSTMethodController,
      required this.purchaseContactController,
      required this.purchaseSupplierAgentidController,
      required this.purchaseSuppliergstnoController,
      required this.ProductCategoryController,
      required this.selectedDate,
      required this.finaldiscountPercFocusNode,
      required this.clearTableData});
  @override
  State<PurchaseDiscountForm> createState() => _PurchaseDiscountFormState();
}

class _PurchaseDiscountFormState extends State<PurchaseDiscountForm> {
  void initState() {
    super.initState();
    purchaseDisAMountController.text = "0.0";
    purchaseDisPercentageController.text = "0";
  }

  TextEditingController purchaseDisAMountController = TextEditingController();
  TextEditingController purchaseDisPercentageController =
      TextEditingController();

  late String finalTaxableAmountinitialValue;

  // FocusNode finaldiscountPercFocusNode = FocusNode();
  FocusNode FinalDiscountAmtFocusNode = FocusNode();
  FocusNode RoundOffFocusNode = FocusNode();
  FocusNode FinalAmountFocusNode = FocusNode();
  FocusNode FinalTotalAmountFocusNode = FocusNode();
  FocusNode saveallButtonFocusNode = FocusNode();

  TextEditingController purchaseRoundOffController =
      TextEditingController(text: '0');
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    TextEditingController CGSTPercent0 = TextEditingController();

    TextEditingController CGSTPercent25 = TextEditingController();

    TextEditingController CGSTPercent6 = TextEditingController();

    TextEditingController CGSTPercent9 = TextEditingController();

    TextEditingController CGSTPercent14 = TextEditingController();
    TextEditingController SGSTPercent0 = TextEditingController();

    TextEditingController SGSTPercent25 = TextEditingController();

    TextEditingController SGSTPercent6 = TextEditingController();

    TextEditingController SGSTPercent9 = TextEditingController();

    TextEditingController SGSTPercent14 = TextEditingController();

    String TaxableAmountinitialValue =
        widget.getTotalTaxableCallback(widget.tableData).toString();
    TextEditingController TaxableController =
        TextEditingController(text: TaxableAmountinitialValue);

    String FinalTaxableAmountinitialValue =
        widget.getTotalFinalTaxableCallback(widget.tableData).toString();
    TextEditingController finalTaxableController =
        TextEditingController(text: FinalTaxableAmountinitialValue);

    String CGSTAmountInitialvalue =
        widget.getTotalCGSTAmtCallback(widget.tableData).toString();
    TextEditingController CGSTAmountController =
        TextEditingController(text: CGSTAmountInitialvalue);

    String SGSTAmountInitialvalue =
        widget.getTotalSGSTAMtCallback(widget.tableData).toString();
    TextEditingController SGSTAmountController =
        TextEditingController(text: SGSTAmountInitialvalue);

    String totalAmountInitialvalue =
        widget.getTotalAmtCallback(widget.tableData).toString();
    TextEditingController TotalAmountController =
        TextEditingController(text: totalAmountInitialvalue);

    String FinalTotalAmtInitialValue =
        widget.getTotalFinalAmtCallback(widget.tableData).toString();
    TextEditingController FinalTotalAmountController =
        TextEditingController(text: FinalTotalAmtInitialValue);

    void _fieldFocusChange(
        BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }

    void calculateDiscountAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        double cgst0 = double.tryParse(widget
                .gettaxableAmtCGST0callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .gettaxableAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(widget
                .gettaxableAmtCGST6callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst9 = double.tryParse(widget
                .gettaxableAmtCGST9callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .gettaxableAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double part1 = cgst0 * disPercentage / 100;
        double part2 = cgst25 * disPercentage / 100;
        double part3 = cgst6 * disPercentage / 100;
        double part4 = cgst9 * disPercentage / 100;
        double part5 = cgst14 * disPercentage / 100;

        // Calculate total discount amount
        double discountAmount = part1 + part2 + part3 + part4 + part5;

        // Update the discount amount in the text controller
        purchaseDisAMountController.text = discountAmount.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double cgst0 = double.tryParse(
                widget.getFinalAmtCGST0callback(widget.tableData).toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .getFinalAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(
                widget.getFinalAmtCGST6callback(widget.tableData).toString()) ??
            0.0;
        double cgst9 = double.tryParse(
                widget.getFinalAmtCGST9callback(widget.tableData).toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .getFinalAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double part1 = cgst0 * disPercentage / 100;
        double part2 = cgst25 * disPercentage / 100;
        double part3 = cgst6 * disPercentage / 100;
        double part4 = cgst9 * disPercentage / 100;
        double part5 = cgst14 * disPercentage / 100;

        // Calculate total discount amount
        double discountAmount = part1 + part2 + part3 + part4 + part5;

        // Update the discount amount in the text controller
        purchaseDisAMountController.text = discountAmount.toStringAsFixed(2);
        // print("DiscountAmount : ${purchaseDisAMountController.text}");
      } else {
        double taxableamount = double.tryParse(widget
                .getTotalFinalTaxableCallback(widget.tableData)
                .toString()) ??
            0.0;

        double discountamount = taxableamount * disPercentage / 100;

        purchaseDisAMountController.text = discountamount.toStringAsFixed(2);
      }
    }

    void calculateDiscountPercentage() {
      // Get the discount amount from the controller
      double discountAmount =
          double.tryParse(purchaseDisAMountController.text) ?? 0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double totalTaxable = double.tryParse(
                widget.getTotalTaxableCallback(widget.tableData).toString()) ??
            0.0;

        // Calculate the discount percentage
        double discountPercentage = (discountAmount * 100) / totalTaxable;

        // Update the discount percentage in the appropriate controller
        purchaseDisPercentageController.text =
            discountPercentage.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalTaxable = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;

        // Calculate the discount percentage
        double discountPercentage = (discountAmount * 100) / totalTaxable;

        // Update the discount percentage in the appropriate controller
        purchaseDisPercentageController.text =
            discountPercentage.toStringAsFixed(2);
      } else {
        double taxableamount = double.tryParse(widget
                .getTotalFinalTaxableCallback(widget.tableData)
                .toString()) ??
            0.0;

        double discountamount = discountAmount * 100 / taxableamount;

        purchaseDisPercentageController.text =
            discountamount.toStringAsFixed(2);
      }
    }

    void CalculateCGSTFinalAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        double cgst0 = double.tryParse(widget
                .gettaxableAmtCGST0callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .gettaxableAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(widget
                .gettaxableAmtCGST6callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst9 = double.tryParse(widget
                .gettaxableAmtCGST9callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .gettaxableAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double cgst0part1 = cgst0 * disPercentage / 100;
        double cgst25part2 = cgst25 * disPercentage / 100;
        double cgst6part3 = cgst6 * disPercentage / 100;
        double cgst9part4 = cgst9 * disPercentage / 100;
        double cgst14part5 = cgst14 * disPercentage / 100;

        double finalcgst0amt = cgst0 - cgst0part1;
        double finalcgst25amt = cgst25 - cgst25part2;
        double finalcgst6amt = cgst6 - cgst6part3;
        double finalcgst9amt = cgst9 - cgst9part4;
        double finalcgst14amt = cgst14 - cgst14part5;

        double FinameFormulaCGST0 = finalcgst0amt * 0 / 100;
        double FinameFormulaCGST25 = finalcgst25amt * 2.5 / 100;
        double FinameFormulaCGST6 = finalcgst6amt * 6 / 100;
        double FinameFormulaCGST9 = finalcgst9amt * 9 / 100;
        double FinameFormulaCGST14 = finalcgst14amt * 14 / 100;

        CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
        CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
        CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
        CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
        CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

        double FinalCGSTAmounts = FinameFormulaCGST0 +
            FinameFormulaCGST25 +
            FinameFormulaCGST6 +
            FinameFormulaCGST9 +
            FinameFormulaCGST14;

        CGSTAmountController.text = FinalCGSTAmounts.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double cgst0 = double.tryParse(
                widget.getFinalAmtCGST0callback(widget.tableData).toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .getFinalAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(
                widget.getFinalAmtCGST6callback(widget.tableData).toString()) ??
            0.0;
        double cgst9 = double.tryParse(
                widget.getFinalAmtCGST9callback(widget.tableData).toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .getFinalAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double cgst0part1 = cgst0 * disPercentage / 100;
        double cgst25part2 = cgst25 * disPercentage / 100;
        double cgst6part3 = cgst6 * disPercentage / 100;
        double cgst9part4 = cgst9 * disPercentage / 100;
        double cgst14part5 = cgst14 * disPercentage / 100;

        double finalcgst0amt = cgst0 - cgst0part1;
        double finalcgst25amt = cgst25 - cgst25part2;
        double finalcgst6amt = cgst6 - cgst6part3;
        double finalcgst9amt = cgst9 - cgst9part4;
        double finalcgst14amt = cgst14 - cgst14part5;

        double denominator0 = 100 + 0;
        double denominator25 = 100 + 5;
        double denominator6 = 100 + 12;
        double denominator9 = 100 + 18;
        double denominator14 = 100 + 28;

        double FinameFormulaCGST0 = finalcgst0amt * 0 / denominator0;
        double FinameFormulaCGST25 = finalcgst25amt * 2.5 / denominator25;
        double FinameFormulaCGST6 = finalcgst6amt * 6 / denominator6;
        double FinameFormulaCGST9 = finalcgst9amt * 9 / denominator9;
        double FinameFormulaCGST14 = finalcgst14amt * 14 / denominator14;

        CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
        CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
        CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
        CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
        CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

        // print("cgsttttttt 00000 : ${CGSTPercent0.text}");
        // print("cgsttttttt 25555 : ${CGSTPercent25.text}");
        // print("cgsttttttt 6666 : ${CGSTPercent6.text}");
        // print("cgsttttttt 999 : ${CGSTPercent9.text}");
        // print("cgsttttttt 14444 : ${CGSTPercent14.text}");

        double FinalCGSTAmounts = FinameFormulaCGST0 +
            FinameFormulaCGST25 +
            FinameFormulaCGST6 +
            FinameFormulaCGST9 +
            FinameFormulaCGST14;

        CGSTAmountController.text = FinalCGSTAmounts.toStringAsFixed(2);
      } else {
        CGSTPercent0.text = 0.toStringAsFixed(2);
        CGSTPercent25.text = 0.toStringAsFixed(2);
        CGSTPercent6.text = 0.toStringAsFixed(2);
        CGSTPercent9.text = 0.toStringAsFixed(2);
        CGSTPercent14.text = 0.toStringAsFixed(2);

        double FinalCGSTAmounts = 0;

        CGSTAmountController.text = FinalCGSTAmounts.toStringAsFixed(2);
      }
    }

    void CalculateSGSTFinalAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Ensure that the values obtained from callbacks are converted to doubles
        double sgst0 = double.tryParse(widget
                .gettaxableAmtSGST0callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst25 = double.tryParse(widget
                .gettaxableAmtSGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst6 = double.tryParse(widget
                .gettaxableAmtSGST6callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst9 = double.tryParse(widget
                .gettaxableAmtSGST9callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst14 = double.tryParse(widget
                .gettaxableAmtSGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double sgst0part1 = sgst0 * disPercentage / 100;
        double sgst25part2 = sgst25 * disPercentage / 100;
        double sgst6part3 = sgst6 * disPercentage / 100;
        double sgst9part4 = sgst9 * disPercentage / 100;
        double sgst14part5 = sgst14 * disPercentage / 100;

        double finalsgst0amt = sgst0 - sgst0part1;
        double finalsgst25amt = sgst25 - sgst25part2;
        double finalsgst6amt = sgst6 - sgst6part3;
        double finalsgst9amt = sgst9 - sgst9part4;
        double finalsgst14amt = sgst14 - sgst14part5;
        double FinameFormulaSGST0 = finalsgst0amt * 0 / 100;
        double FinameFormulaSGST25 = finalsgst25amt * 2.5 / 100;
        double FinameFormulaSGST6 = finalsgst6amt * 6 / 100;
        double FinameFormulaSGST9 = finalsgst9amt * 9 / 100;
        double FinameFormulaSGST14 = finalsgst14amt * 14 / 100;

        SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
        SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
        SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
        SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
        SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

        double FinalSGSTAmounts = FinameFormulaSGST0 +
            FinameFormulaSGST25 +
            FinameFormulaSGST6 +
            FinameFormulaSGST9 +
            FinameFormulaSGST14;

        SGSTAmountController.text = FinalSGSTAmounts.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        // Ensure that the values obtained from callbacks are converted to doubles
        double sgst0 = double.tryParse(
                widget.getFinalAmtSGST0callback(widget.tableData).toString()) ??
            0.0;
        double sgst25 = double.tryParse(widget
                .getFinalAmtSGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst6 = double.tryParse(
                widget.getFinalAmtSGST6callback(widget.tableData).toString()) ??
            0.0;
        double sgst9 = double.tryParse(
                widget.getFinalAmtSGST9callback(widget.tableData).toString()) ??
            0.0;
        double sgst14 = double.tryParse(widget
                .getFinalAmtSGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double sgst0part1 = sgst0 * disPercentage / 100;
        double sgst25part2 = sgst25 * disPercentage / 100;
        double sgst6part3 = sgst6 * disPercentage / 100;
        double sgst9part4 = sgst9 * disPercentage / 100;
        double sgst14part5 = sgst14 * disPercentage / 100;

        double finalsgst0amt = sgst0 - sgst0part1;
        double finalsgst25amt = sgst25 - sgst25part2;
        double finalsgst6amt = sgst6 - sgst6part3;
        double finalsgst9amt = sgst9 - sgst9part4;
        double finalsgst14amt = sgst14 - sgst14part5;
        double denominator0 = 100 + 0;
        double denominator25 = 100 + 5;
        double denominator6 = 100 + 12;
        double denominator9 = 100 + 18;
        double denominator14 = 100 + 28;

        double FinameFormulaSGST0 = finalsgst0amt * 0 / denominator0;
        double FinameFormulaSGST25 = finalsgst25amt * 2.5 / denominator25;
        double FinameFormulaSGST6 = finalsgst6amt * 6 / denominator6;
        double FinameFormulaSGST9 = finalsgst9amt * 9 / denominator9;
        double FinameFormulaSGST14 = finalsgst14amt * 14 / denominator14;

        SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
        SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
        SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
        SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
        SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

        double FinalSGSTAmounts = FinameFormulaSGST0 +
            FinameFormulaSGST25 +
            FinameFormulaSGST6 +
            FinameFormulaSGST9 +
            FinameFormulaSGST14;

        SGSTAmountController.text = FinalSGSTAmounts.toStringAsFixed(2);
      } else {
        SGSTPercent0.text = 0.toStringAsFixed(2);
        SGSTPercent25.text = 0.toStringAsFixed(2);
        SGSTPercent6.text = 0.toStringAsFixed(2);
        SGSTPercent9.text = 0.toStringAsFixed(2);
        SGSTPercent14.text = 0.toStringAsFixed(2);

        double FinalSGSTAmounts = 0;

        SGSTAmountController.text = FinalSGSTAmounts.toStringAsFixed(2);
      }
    }

    void calculatetotalAmount() {
      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double finaltotalTaxable =
            double.tryParse(finalTaxableController.text) ?? 0.0;
        double finalCGSTAmount =
            double.tryParse(CGSTAmountController.text) ?? 0.0;
        double finalSGSTAmount =
            double.tryParse(SGSTAmountController.text) ?? 0.0;

        // Perform calculation
        double TotalAmount =
            finaltotalTaxable + finalCGSTAmount + finalSGSTAmount;

        // // Update TotalAmountController
        // TotalAmountController.text = TotalAmount.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        TotalAmountController.text = FinalTotlaAmount.toStringAsFixed(2);
      } else {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        TotalAmountController.text = FinalTotlaAmount.toStringAsFixed(2);
      }
    }

    void calculateFinaltotalAmount() {
      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double finaltotalTaxable =
            double.tryParse(finalTaxableController.text) ?? 0.0;
        double finalCGSTAmount =
            double.tryParse(CGSTAmountController.text) ?? 0.0;
        double finalSGSTAmount =
            double.tryParse(SGSTAmountController.text) ?? 0.0;

        // Perform calculation
        double TotalAmount =
            finaltotalTaxable + finalCGSTAmount + finalSGSTAmount;

        TotalAmountController.text = TotalAmount.toStringAsFixed(2);

        double Roundoff =
            double.tryParse(purchaseRoundOffController.text) ?? 0.0;
        double roundoffFinalTotAmt = TotalAmount + Roundoff;

        FinalTotalAmountController.text =
            roundoffFinalTotAmt.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double Roundoff =
            double.tryParse(purchaseRoundOffController.text) ?? 0.0;
        double roundoffFinalTotAmt = FinalTotlaAmount + Roundoff;

        FinalTotalAmountController.text =
            roundoffFinalTotAmt.toStringAsFixed(2);
      } else {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double Roundoff =
            double.tryParse(purchaseRoundOffController.text) ?? 0.0;
        double roundoffFinalTotAmt = FinalTotlaAmount + Roundoff;

        FinalTotalAmountController.text =
            roundoffFinalTotAmt.toStringAsFixed(2);
      }
    }

    void calculateFinalTaxableAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;
      double discountAmount =
          double.tryParse(purchaseDisAMountController.text) ?? 0.0;
      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double totalTaxable = double.tryParse(
                widget.getTotalTaxableCallback(widget.tableData).toString()) ??
            0.0;

        double FinalTaxableAMount = totalTaxable - discountAmount;
        finalTaxableController.text = FinalTaxableAMount.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double finalAmount = FinalTotlaAmount;
        double cgsttotalamount =
            double.tryParse(CGSTAmountController.text.toString()) ?? 0.0;
        double sgsttotalamount =
            double.tryParse(CGSTAmountController.text.toString()) ?? 0.0;

        double totalgstamount = cgsttotalamount + sgsttotalamount;

        double finaltaxableamount = finalAmount - totalgstamount;
        finalTaxableController.text = finaltaxableamount.toStringAsFixed(2);
      } else {
        double totalTaxable = double.tryParse(
                widget.getTotalTaxableCallback(widget.tableData).toString()) ??
            0.0;
        double discountAmount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double finaltaxableamount = totalTaxable - discountAmount;
        finalTaxableController.text = finaltaxableamount.toStringAsFixed(2);
      }
    }

    Future<void> postDataToAPI(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      if (!mounted) return; // Check if the widget is mounted before proceeding

      CalculateCGSTFinalAmount();
      CalculateSGSTFinalAmount();
      calculateFinalTaxableAmount();
      calculateFinaltotalAmount();
      List<String> productDetails = [];

      for (var data in tableData) {
        // Format each product detail as "{productName},{amount}"
        String date = DateFormat('yyyy-MM-dd').format(selectedDate);
        productDetails.add(
            "{serialno:$purchaseRecordNo,dt:$date,item:${data['productName']},qty:${data['quantity']},rate:${data['rate']},disc:${data['discountamount']},total:${data['total']},cgstperc:${data['cgstpercentage']},cgstamount:${data['cgstAmount']},sgstperc:${data['sgstPercentage']},sgstamount:${data['sgstAmount']},finaltotal:${data['finalAmount']},disperc:${data['discountpercentage']},taxable:${data['taxableAmount']},igstperc:0.0,igstamnt:0.0,cessperc:0.0,cessamnt:0.0,addstock:${data['addstock']}}");
      }
      // print('tbl : $tableData');

      // Join all product details into a single string
      String productDetailsString = productDetails.join('');
      // print("productdetails:$productDetailsString");
      // Prepare the data to be sent
      if (!mounted) return; // Check if the widget is mounted before proceeding

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "serialno": widget.purchaseRecordNoController.text,
        "date": DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        "purchasername": widget.purchaseSupplierNameController.text,
        "count": widget.getProductCountCallback(widget.tableData).toString(),
        "total": FinalTotalAmountController.text,
        // "name": widget.purchaseSupplierNameController.text,
        "invoiceno": widget.purchaseInvoiceNoController.text,
        "finlaldis": purchaseDisAMountController.text,
        "round": purchaseRoundOffController.text,
        "cgst0": CGSTPercent0.text, // Use the calculated CGST values
        "cgst25": CGSTPercent25.text,
        "cgst6": CGSTPercent6.text,
        "cgst9": CGSTPercent9.text,
        "cgst14": CGSTPercent14.text,
        "sgst0": SGSTPercent0.text,
        "sgst25": SGSTPercent25.text,
        "sgst6": SGSTPercent6.text,
        "sgst9": SGSTPercent9.text,
        "sgst14": SGSTPercent14.text,
        "igst0": "0.0",
        "igst5": "0.0",
        "igst12": "0.0",
        "igst18": "0.0",
        "igst28": "0.0",
        "cess": "0.0",
        "totcgst": CGSTAmountController.text,
        "totsgst": SGSTAmountController.text,
        "totigst": "0.0",
        "totcess": "0.0",
        "proddis":
            widget.getProductDiscountCallBack(widget.tableData).toString(),
        "taxable": TaxableController.text,
        "gstmethod": widget.purchaseGSTMethodController.text.isEmpty
            ? "NonGst"
            : widget.purchaseGSTMethodController.text,
        "disperc": purchaseDisPercentageController.text,
        "agentid": widget.purchaseSupplierAgentidController.text,
        "contact": widget.purchaseContactController.text,
        "gstno": widget.purchaseSuppliergstnoController.text,
        "finaltaxable": finalTaxableController.text,
        "PurchaseDetails": productDetailsString,
      };

      if (widget.purchaseGSTMethodController.text.isEmpty) {
        postData["gstmethod"] = "NonGst";
      } else {
        postData["gstmethod"] = widget.purchaseGSTMethodController.text;
      }

      // Convert the data to JSON format
      String jsonData = jsonEncode(postData);

      try {
        // Send the POST request
        var response = await http.post(
          Uri.parse('$IpAddress/PurchaseRoundDetailsalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );
        if (!mounted)
          return; // Check if the widget is mounted before proceeding

        // Check the response status
        if (response.statusCode == 201) {
          print('Data posted successfully');
          await logreports(
              "Purchase: Invoice-${widget.purchaseInvoiceNoController.text}_Billno-${widget.purchaseRecordNoController.text}_AgentName-${widget.purchaseSupplierNameController.text}_Inserted");
          successfullySavedMessage(context);
          widget.purchaseInvoiceNoController.clear();
          widget.purchaseSupplierNameController.text = '';
          widget.purchaseContactController.clear();
          widget.clearTableData();

          purchaseDisPercentageController.text = '0';
          purchaseDisAMountController.text = '0';
          purchaseRoundOffController.text = '0';
          widget.recordonorefresh();
        } else {
          // print('Failed to post data. Error code: ${response.statusCode}');

          // print('Response body: ${response.statusCode}');
        }
      } catch (e) {
        // print('Failed to post data. Error: $e');
      }
    }

    Clear() {
      widget.purchaseInvoiceNoController.clear();
      widget.purchaseSupplierNameController.text = '';
      widget.purchaseContactController.clear();
      widget.clearTableData();
      purchaseDisPercentageController.text = '0';
      purchaseDisAMountController.text = '0';
      purchaseRoundOffController.text = '0';
      widget.recordonorefresh();
    }

    Future<void> postDataWithIncrementedSerialNo() async {
      // Increment the serial number
      int incrementedSerialNo = int.parse(
        widget.purchaseRecordNoController.text,
      );

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
          Uri.parse('$IpAddress/PurchaseserialNoalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        // Check the response status
        if (response.statusCode == 200) {
          print('Data posted successfully');
        } else {
          // print('Response body: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to post data. Error: $e');
      }
    }

    Future<void> Post__purchaseDetails(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      for (var data in tableData) {
        Map<String, dynamic> postData = {
          // "id": 30,
          "serialno": purchaseRecordNo,
          "dt": DateFormat('yyyy-MM-dd').format(selectedDate),
          "item": data['productName'],
          "qty": data['quantity'],
          "rate": data['rate'],
          "disc": data['discountamount'],
          "total": data['total'],
          "cgstperc": data['cgstpercentage'],
          "cgstamount": data['cgstAmount'],
          "sgstperc": data['sgstPercentage'],
          "sgstamount": data['sgstAmount'],
          "finaltotal": data['finalAmount'],
          "disperc": data['discountpercentage'],
          "taxable": data['taxableAmount'],
          "igstperc": "0.0",
          "igstamnt": "0.0",
          "cessperc": "0.0",
          "cessamnt": "0.0",
          "addstock": data["stockcheck"]
        };

        // Convert the data to JSON format
        String jsonData = jsonEncode(postData);

        try {
          // Send the POST request
          var response = await http.post(
            Uri.parse('http://$IpAddress/Purchase_Details/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonData,
          );

          // Check the response status
          if (response.statusCode == 200) {
            print('Data posted successfully');
          } else {
            // print('Response body: ${response.statusCode}');
          }
        } catch (e) {
          print('Failed to post data. Error: $e');
        }
      }
    }

    TextEditingController ProductCategoryController = TextEditingController();
    Future<bool> checkProductExists(String apiUrl, String productName) async {
      final response = await http.get(Uri.parse(apiUrl));
      final jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        final List<dynamic> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Check if product name exists in the results
        for (var entry in results) {
          if (entry['name'] == productName) {
            return true;
          }
        }
      }
      return false;
    }

    Future<String> fetchProductCategory(String productName) async {
      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
      final response = await http.get(Uri.parse(apiUrl));
      final jsonData = json.decode(response.body);

      String totalCategory = ''; // Initialize total category to empty string

      if (jsonData['results'] != null) {
        final List<dynamic> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Iterate through each entry in the results
        for (var entry in results) {
          // Check if product name matches
          if (entry['name'] == productName) {
            // Accumulate the categories
            String category = entry['category'] ?? '';
            totalCategory += category + ', ';
          }
        }
        // Remove the trailing comma and space
        if (totalCategory.isNotEmpty) {
          totalCategory = totalCategory.substring(0, totalCategory.length - 2);
        }
      }
      return totalCategory;
    }

    Future<void> addNewProduct(String apiUrl, Map<String, dynamic> data) async {
      String category = await fetchProductCategory(data['productName']);

      Map<String, dynamic> postData = {
        "name": data['productName'],
        "stock": data['quantity'],
        "category": category,
        "amount": data['rate'],
        "sgstperc": data['cgstpercentage'],
        "cgstperc": data['sgstPercentage']
      };

      String jsonData = jsonEncode(postData);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data added successfully');
      } else {
        print('Failed to add data: ${response.statusCode}, ${response.body}');
        // Handle failure as needed
      }
    }

    void _addRowMaterial(List<Map<String, dynamic>> tableData) async {
      if (!mounted) return;

      String? cusid = await SharedPrefs.getCusId();
      for (var data in tableData) {
        String productName = data['productName'];
        String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';

        // Check if the product already exists in the URL data
        bool productExists = await checkProductExists(apiUrl, productName);

        if (productExists) {
          try {
            String url = apiUrl;
            Map<String, dynamic> jsonData;
            int productId; // Variable to store the product ID

            while (true) {
              final response = await http.get(Uri.parse(url));

              if (response.statusCode == 200) {
                jsonData = jsonDecode(response.body);
                final List<dynamic> results = jsonData['results'];

                // Find the product and extract its ID
                for (var entry in results) {
                  if (entry['name'] == productName) {
                    productId = entry['id'];
                    double currentStock = double.parse(entry['stock'] ?? '0');
                    double newStockValue =
                        double.parse(data['quantity'].toString());
                    entry['stock'] = (currentStock + newStockValue).toString();

                    // Update the product data using the specific URL with ID
                    String productUrl = '$apiUrl$productId/';
                    String jsonDataString = jsonEncode(entry);
                    await http.put(
                      Uri.parse(productUrl),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonDataString,
                    );

                    print('Stock updated successfully for $productName');
                    break; // Break the loop after updating the stock
                  }
                }

                break; // Break the loop after updating the stock
              } else {
                throw Exception(
                    'Failed to load product data: ${response.reasonPhrase}');
              }
            }
          } catch (e) {
            print('Error updating product stock: $e');
          }
        } else {
          // If product does not exist, add new data
          await addNewProduct(apiUrl, data);
        }
      }
    }

// start with mine
// Function to check if the product exists
    Future<bool> NewcheckProductExists(String productName) async {
      String? cusid = await SharedPrefs.getCusId();
      final url = '$IpAddress/Settings_ProductDetails/$cusid/';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> products = data['results'];
          return products.any((product) =>
              product['name'].toLowerCase() == productName.toLowerCase());
        } else {
          print('Failed to load product data');
          return false;
        }
      } catch (e) {
        print('Error occurred: $e');
        return false;
      }
    }

// Function to fetch the product ID from the URL
    Future<String?> fetchProductId(String productName) async {
      String? cusid = await SharedPrefs.getCusId();

      final url = '$IpAddress/PurchaseProductDetails/$cusid/';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> products = data['results'];
          final product = products.firstWhere(
            (product) =>
                product['name'].toLowerCase() == productName.toLowerCase(),
            orElse: () => null,
          );
          return product?['id']?.toString();
        } else {
          print('Failed to fetch product ID');
          return null;
        }
      } catch (e) {
        print('Error occurred: $e');
        return null;
      }
    }

// Function to fetch current stock and update with new stock using product ID
    Future<void> fetchAndUpdateStockById(String productId, int newStock) async {
      // Fetch the cusid from shared preferences
      String? cusid = await SharedPrefs.getCusId();
      if (cusid == null) {
        print('Error: cusid is null');
        return;
      }

      // Step 1: Fetch the current stock for the given product ID
      final fetchUrl = '$IpAddress/PurchaseProductDetailsalldatas/$productId/';
      try {
        final fetchResponse = await http.get(Uri.parse(fetchUrl));
        if (fetchResponse.statusCode == 200) {
          final data = jsonDecode(fetchResponse.body);

          // Assume the current stock is stored in a field called 'stock'
          // You may need to adjust this depending on the actual structure of the response
          double currentStock = 0.0;

          if (data['stock'] is String) {
            currentStock = double.tryParse(data['stock']) ?? 0.0;
          } else if (data['stock'] is num) {
            currentStock = (data['stock'] as num).toDouble();
          }

          print('Current Stock for product ID $productId: $currentStock');

          // Step 2: Add the new stock (from tableData) to the current stock
          final updatedStock = currentStock + newStock;
          print('Updated Stock for product ID $productId: $updatedStock');

          // Step 3: Send PUT request to update stock
          final updateUrl =
              '$IpAddress/PurchaseProductDetailsalldatas/$productId/';
          final updateResponse = await http.put(
            Uri.parse(updateUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'cusid': cusid, // Include cusid in the request
              'stock': updatedStock // Update with the new stock value
            }),
          );

          if (updateResponse.statusCode == 200) {
            print('Stock updated successfully for product ID: $productId.');
          } else {
            print(
                'Failed to update stock for product ID: $productId. Status Code: ${updateResponse.statusCode}');
            // print('Response Body: ${updateResponse.body}');
          }
        } else {
          print(
              'Failed to fetch current stock for product ID: $productId. Status Code: ${fetchResponse.statusCode}');
        }
      } catch (e) {
        print('Error occurred while fetching or updating stock: $e');
      }
    }

// // Function to fetch and update stock value, and return whether the product was found
    Future<bool> fetchAndUpdateStock(String productName, int newStock) async {
      String? cusid = await SharedPrefs.getCusId();

      final url = '$IpAddress/Settings_ProductDetails/$cusid/';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> products = data['results'];

          // Check if the product exists
          final existingProduct = products.firstWhere(
            (product) =>
                product['name'].toLowerCase() == productName.toLowerCase(),
            orElse: () => null,
          );

          if (existingProduct != null) {
            final productId = existingProduct['id'];

            // Handle the stockvalue which could be of type String or num
            double currentStock;
            if (existingProduct['stockvalue'] is String) {
              currentStock =
                  double.tryParse(existingProduct['stockvalue']) ?? 0.0;
            } else if (existingProduct['stockvalue'] is num) {
              currentStock = (existingProduct['stockvalue'] as num).toDouble();
            } else {
              currentStock =
                  0.0; // Default value if stockvalue is neither a String nor a num
            }

            print('Product "$productName" exists with ID: $productId');
            print('Current Stock Value: $currentStock');

            // Update stock by adding newStock to currentStock
            final double updatedStock = currentStock + newStock;
            print('New Stock Value: $newStock');
            print('Update Stock Value: $updatedStock');

            // Send PUT request to update stock
            final updateUrl =
                '$IpAddress/SettingsProductDetailsalldatas/$productId/';
            final updateResponse = await http.put(
              Uri.parse(updateUrl),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'stockvalue': updatedStock,
                'cusid': cusid, // Ensure cusid is included in the request
              }),
            );

            if (updateResponse.statusCode == 200) {
              print(
                  'Stock updated successfully for product "$productName". New stock: $updatedStock');
              return true; // Product found and stock updated
            } else {
              print(
                  'Failed to update stock for product "$productName". Status Code: ${updateResponse.statusCode}');
              // print('Response Body: ${updateResponse.body}');
              return false; // Failed to update stock
            }
          } else {
            print(
                'The product name "$productName" does not exist in the API data.');
            return false; // Product not found
          }
        } else {
          print('Failed to load product data');
          return false; // Failed to load data
        }
      } catch (e) {
        print('Error occurred: $e');
        return false; // Error occurred
      }
    } // Function to fetch product details and check if they exist, including addstock

    Future<void> fetchProductDetails(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      List<String> productDetails = [];

      if (tableData.isEmpty) {
        print('No data available');
        return;
      }

      for (var data in tableData) {
        // Safely extract values with null checks and type conversions
        String productName = data['productName'] ?? 'Unknown Product';

        // Convert quantity to int if it's not already
        int quantity;
        try {
          quantity = int.tryParse(data['quantity'].toString()) ?? 0;
        } catch (e) {
          print('Error parsing quantity for item $productName: $e');
          quantity = 0;
        }

        // Fetch the addstock value (Yes/No)
        String addStock = data['addstock'] ?? 'No'; // Default to 'No' if null

        // Add product details to the list, including addstock
        productDetails.add(
          "{item: ${productName}, qty: ${quantity}, addstock: ${addStock}}",
        );

        // Check if the product exists and update stock if addstock is Yes
        if (addStock.toLowerCase() == 'yes') {
          // Check if the product exists in the API
          final productExists = await NewcheckProductExists(productName);
          if (productExists) {
            // Fetch and update stock if the product exists
            await fetchAndUpdateStock(productName, quantity);
          } else {
            // If product does not exist, fetch the product ID and update the stock
            final productId = await fetchProductId(productName);
            if (productId != null) {
              await fetchAndUpdateStockById(productId, quantity);
            } else {
              print('Product "$productName" not found and cannot be updated.');
            }
          }
        }
      }

      // Print all collected product details
      print('Product Details: $productDetails');
    }

    TextEditingController _DateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

    Future _saveStockDetailsAndRoundToAPI(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      if (tableData.isEmpty ||
          widget.purchaseSupplierNameController.text.isEmpty) {
        // showEmptyWarning();
        return;
      }

      List<Map<String, dynamic>> StockDetailsData = [];
      String RecordNo = widget.purchaseRecordNoController.text;
      Set<String> uniqueItems = Set<String>();

      for (var i = 0; i < tableData.length; i++) {
        var rowData = tableData[i];

        String productName = rowData['productName'];
        int qty = int.tryParse(rowData['quantity'].toString()) ?? 0;

        // Add the product name to the set of unique items
        uniqueItems.add(productName);

        StockDetailsData.add({
          'serialno': RecordNo,
          'agentname': widget.purchaseSupplierNameController.text,
          'date': _DateController.text,
          'productname': productName,
          'qty': qty,
        });
      }

      // Calculate the number of unique items
      int itemCount = uniqueItems.length;

      String StockDetailsJson = json.encode(StockDetailsData);

      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/Stock_Details_Roundalldata/';
      Map<String, dynamic> postData = {
        "cusid": cusid,
        'serialno': RecordNo,
        'date': _DateController.text,
        'agentname': widget.purchaseSupplierNameController.text,
        'itemcount': itemCount.toString(), // Use the count of unique items
        'status': 'PurchaseStock',
        'StockDetails': StockDetailsJson,
      };

      print('Processed Data: $postData');

      try {
        http.Response response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode(postData),
          headers: {'Content-Type': 'application/json'},
        );

        if (mounted) {
          if (response.statusCode == 201) {
            print('Data saved successfully');

            await logreports(
                'Stock Entry: ${widget.purchaseSupplierNameController.text}_Inserted');
            successfullySavedMessage(context);
            postDataWithIncrementedSerialNo();
            widget.purchaseSupplierNameController.clear();
          } else {
            print('Failed to save data. Status code: ${response.statusCode}');
            print('Response Body: ${response.body}');
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.07;

    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.06;
    return Padding(
      padding: EdgeInsets.only(
        bottom: !Responsive.isDesktop(context) ? 10 : 0,
        right: 20,
        left: !Responsive.isDesktop(context) ? 20 : 0,
      ),
      child: Container(
          height: Responsive.isDesktop(context)
              ? screenHeight * 0.68
              : MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)), // height: 420,

          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isMobile(context) ||
                            Responsive.isTablet(context)
                        ? 20
                        : 15,
                    right: 0),
                child: Column(
                  children: [
                    if (Responsive.isMobile(context) ||
                        Responsive.isTablet(context))
                      SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Text("No.Of.Product:",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    // color: Colors.grey[200],
                                    child: Text(
                                        "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getProductCountCallback(widget.tableData))}",
                                        style: textStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (Responsive.isDesktop(context))
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                        if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Text("Total Qty",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    child: Text(
                                        "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getTotalQuantityCallback(widget.tableData))}",
                                        style: textStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Taxable ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    color: Colors.grey[200],
                                    child: TextField(
                                        controller: TaxableController,
                                        readOnly: true,
                                        onChanged: (newvalue) {},
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
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
                        if (Responsive.isDesktop(context))
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                        if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Discount %",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    color: Colors.grey[200],
                                    child: TextFormField(
                                        focusNode:
                                            widget.finaldiscountPercFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _fieldFocusChange(
                                                context,
                                                widget
                                                    .finaldiscountPercFocusNode,
                                                FinalDiscountAmtFocusNode),
                                        controller:
                                            purchaseDisPercentageController,
                                        onChanged: (newValue) {
                                          // Convert the input value to a double
                                          double newPercentage =
                                              double.tryParse(newValue) ?? 0.0;
                                          purchaseDisPercentageController.text =
                                              newPercentage.toString();
                                          calculateDiscountAmount();
                                          CalculateCGSTFinalAmount();
                                          CalculateSGSTFinalAmount();
                                          calculatetotalAmount();
                                          calculateFinalTaxableAmount();
                                          calculateFinaltotalAmount();

                                          purchaseDisPercentageController
                                                  .selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          purchaseDisPercentageController
                                                              .text.length));
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
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
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Discount ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    color: Colors.grey[200],
                                    child: TextFormField(
                                        focusNode: FinalDiscountAmtFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _fieldFocusChange(
                                                context,
                                                FinalDiscountAmtFocusNode,
                                                RoundOffFocusNode),
                                        controller: purchaseDisAMountController,
                                        onChanged: (newvalue) {
                                          calculateDiscountPercentage();
                                          CalculateCGSTFinalAmount();
                                          CalculateSGSTFinalAmount();

                                          calculateFinaltotalAmount();
                                          calculatetotalAmount();
                                          calculateFinalTaxableAmount();

                                          purchaseDisAMountController
                                                  .selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          purchaseDisAMountController
                                                              .text.length));
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
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
                        if (Responsive.isDesktop(context))
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                        if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Final Taxable ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    color: Colors.grey[200],
                                    child: TextField(
                                        controller: finalTaxableController,
                                        onChanged: (newValue) {
                                          finalTaxableAmountinitialValue =
                                              newValue;
                                          // purchaseDisPercentageController.clear();
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child:
                                    Text("CGST ₹", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    // color: Colors.grey[200],
                                    child: TextField(
                                        controller: CGSTAmountController,
                                        onChanged: (newValue) {
                                          CGSTAmountInitialvalue = newValue;
                                          // purchaseDisPercentageController.clear();
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: AmountTextStyle),
                                    // Text(
                                    //   "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getTotalCGSTAmtCallback(widget.tableData))}",
                                    //   style: TextStyle(
                                    //     color: Colors.black,
                                    //     fontSize: 13,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (Responsive.isDesktop(context))
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                        if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child:
                                    Text("SGST ₹", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    child: TextField(
                                        controller: SGSTAmountController,
                                        onChanged: (newValue) {
                                          SGSTAmountInitialvalue = newValue;
                                          // purchaseDisPercentageController.clear();
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Total ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    child: TextField(
                                        controller: TotalAmountController,
                                        onChanged: (newValue) {
                                          totalAmountInitialvalue = newValue;
                                          // purchaseDisPercentageController.clear();
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                        if (Responsive.isDesktop(context))
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                        if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Round off(+/-)",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    color: Colors.grey[200],
                                    child: TextFormField(
                                        focusNode: RoundOffFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _fieldFocusChange(
                                                context,
                                                RoundOffFocusNode,
                                                FinalTotalAmountFocusNode),
                                        controller: purchaseRoundOffController,
                                        onChanged: (newValue) {
                                          calculateFinaltotalAmount();
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
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
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5),
                                child: Text("Final Amount ₹",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Container(
                                    height: 27,
                                    width: Responsive.isDesktop(context)
                                        ? desktoptextfeildwidth
                                        : 100,
                                    color: Colors.grey[200],
                                    child: TextFormField(
                                        focusNode: FinalTotalAmountFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _fieldFocusChange(
                                                context,
                                                FinalTotalAmountFocusNode,
                                                saveallButtonFocusNode),
                                        controller: FinalTotalAmountController,
                                        onChanged: (newValue) {
                                          FinalTotalAmtInitialValue = newValue;
                                          // purchaseDisPercentageController.clear();
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                        if (!Responsive.isDesktop(context))
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isDesktop(context) ? 0 : 10.0,
                                top: Responsive.isDesktop(context) ? 0 : 25.0),
                            child: Row(
                                mainAxisAlignment: Responsive.isDesktop(context)
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.center,
                                children: [
                                  Container(
                                    // color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 20
                                                      : 0,
                                              top: 0),
                                          child: Container(
                                            width: Responsive.isDesktop(context)
                                                ? 60
                                                : 70,
                                            child: ElevatedButton(
                                              focusNode: saveallButtonFocusNode,
                                              onPressed: () async {
                                                // Check if any mandatory fields are empty
                                                if (widget.purchaseInvoiceNoController.text.isEmpty ||
                                                    widget
                                                        .purchaseSupplierAgentidController
                                                        .text
                                                        .isEmpty ||
                                                    widget.tableData.isEmpty ||
                                                    purchaseDisAMountController
                                                        .text.isEmpty ||
                                                    purchaseRoundOffController
                                                        .text.isEmpty ||
                                                    purchaseDisPercentageController
                                                        .text.isEmpty) {
                                                  // Show error message if validation fails
                                                  WarninngMessage(context);
                                                  return;
                                                }

                                                // Fetch product details
                                                try {
                                                  await fetchProductDetails(
                                                    widget.tableData,
                                                    widget
                                                        .purchaseRecordNoController
                                                        .text,
                                                    widget.selectedDate,
                                                  );
                                                } catch (error) {
                                                  // Handle errors in fetchProductDetails
                                                  print(
                                                      "Error fetching product details: $error");
                                                  return; // Stop further execution if this fails
                                                }
                                                try {
                                                  await _saveStockDetailsAndRoundToAPI(
                                                    widget.tableData,
                                                    widget
                                                        .purchaseRecordNoController
                                                        .text,
                                                    widget.selectedDate,
                                                  );
                                                } catch (error) {
                                                  print(
                                                      "error posting stock details : $error");
                                                }
                                                // Post data to API
                                                try {
                                                  await postDataToAPI(
                                                    widget.tableData,
                                                    widget
                                                        .purchaseRecordNoController
                                                        .text,
                                                    widget.selectedDate,
                                                  );
                                                } catch (error) {
                                                  // Handle errors in posting data
                                                  print(
                                                      "Error posting data to API: $error");
                                                }
                                                try {
                                                  postDataWithIncrementedSerialNo();
                                                } catch (error) {
                                                  // Handle errors in adding row material
                                                  print(
                                                      "Error increament serial no: $error");
                                                }

                                                // Add row material or any other logic
                                                try {
                                                  _addRowMaterial(
                                                      widget.tableData);
                                                } catch (error) {
                                                  // Handle errors in adding row material
                                                  print(
                                                      "Error adding row material: $error");
                                                }

                                                // Log product category for debugging purposes
                                                print(
                                                    "Product Category: ${widget.ProductCategoryController.text}");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Save',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                          //   child: ElevatedButton(
                                          //     focusNode: saveallButtonFocusNode,
                                          //     onPressed: () {
                                          //       // if (widget.purchaseInvoiceNoController.text.isEmpty ||
                                          //       //     widget
                                          //       //         .purchaseSupplierAgentidController
                                          //       //         .text
                                          //       //         .isEmpty ||
                                          //       //     widget.tableData.isEmpty ||
                                          //       //     purchaseDisAMountController
                                          //       //         .text.isEmpty ||
                                          //       //     purchaseRoundOffController
                                          //       //         .text.isEmpty ||
                                          //       //     purchaseDisPercentageController
                                          //       //         .text.isEmpty) {
                                          //       //   // Show error message
                                          //       //   WarninngMessage(context);
                                          //       //   return;
                                          //       // }
                                          //       fetchProductDetails(
                                          //           widget.tableData,
                                          //           widget
                                          //               .purchaseRecordNoController
                                          //               .text,
                                          //           widget.selectedDate);
                                          //       // postDataToAPI(
                                          //       //     widget.tableData,
                                          //       //     widget
                                          //       //         .purchaseRecordNoController
                                          //       //         .text,
                                          //       //     widget.selectedDate);
                                          //       // Post__purchaseDetails(
                                          //       //     widget.tableData,
                                          //       //     widget.purchaseRecordNoController.text,
                                          //       //     widget.selectedDate);
                                          //       // postDataWithIncrementedSerialNo();

                                          //       _addRowMaterial(
                                          //         widget.tableData,
                                          //       );

                                          //       // print(
                                          //       //     "Product Category:${widget.ProductCategoryController.text}");
                                          //     },
                                          //     style: ElevatedButton.styleFrom(
                                          //       shape: RoundedRectangleBorder(
                                          //         borderRadius:
                                          //             BorderRadius.circular(
                                          //                 2.0),
                                          //       ),
                                          //       backgroundColor: subcolor,
                                          //       minimumSize: Size(
                                          //           Responsive.isDesktop(
                                          //                   context)
                                          //               ? 45.0
                                          //               : 30,
                                          //           Responsive.isDesktop(
                                          //                   context)
                                          //               ? 31.0
                                          //               : 25), // Set width and height
                                          //     ),
                                          //     child: Text('Save',
                                          //         style: commonWhiteStyle),
                                          //   ),
                                          // ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!Responsive.isDesktop(context))
                                    SizedBox(width: 5),
                                  Container(
                                    // color: Subcolor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 20
                                                      : 0,
                                              top: 0),
                                          child: Container(
                                            width: Responsive.isDesktop(context)
                                                ? 75
                                                : 85,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Clear();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? 45.0
                                                        : 30,
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? 31.0
                                                        : 25), // Set width and height
                                              ),
                                              child: Text('Refresh',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              if (Responsive.isDesktop(context)) SizedBox(height: 15),
              if (Responsive.isDesktop(context))
                Padding(
                  padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 0 : 48.0,
                  ),
                  child: Row(
                      mainAxisAlignment: Responsive.isDesktop(context)
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          // color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: Responsive.isDesktop(context)
                                          ? 20
                                          : 0,
                                      top: 0),
                                  child: Container(
                                    width: 90,
                                    child: ElevatedButton(
                                      focusNode: saveallButtonFocusNode,
                                      onPressed: () async {
                                        // Check if any mandatory fields are empty
                                        if (widget.purchaseInvoiceNoController
                                                .text.isEmpty ||
                                            widget
                                                .purchaseSupplierAgentidController
                                                .text
                                                .isEmpty ||
                                            widget.tableData.isEmpty ||
                                            purchaseDisAMountController
                                                .text.isEmpty ||
                                            purchaseRoundOffController
                                                .text.isEmpty ||
                                            purchaseDisPercentageController
                                                .text.isEmpty) {
                                          // Show error message if validation fails
                                          WarninngMessage(context);
                                          return;
                                        }

                                        // Fetch product details
                                        try {
                                          await fetchProductDetails(
                                            widget.tableData,
                                            widget.purchaseRecordNoController
                                                .text,
                                            widget.selectedDate,
                                          );
                                        } catch (error) {
                                          // Handle errors in fetchProductDetails
                                          print(
                                              "Error fetching product details: $error");
                                          return; // Stop further execution if this fails
                                        }
                                        try {
                                          await _saveStockDetailsAndRoundToAPI(
                                            widget.tableData,
                                            widget.purchaseRecordNoController
                                                .text,
                                            widget.selectedDate,
                                          );
                                        } catch (error) {
                                          print(
                                              "error posting stock details : $error");
                                        }
                                        // Post data to API
                                        try {
                                          await postDataToAPI(
                                            widget.tableData,
                                            widget.purchaseRecordNoController
                                                .text,
                                            widget.selectedDate,
                                          );
                                        } catch (error) {
                                          // Handle errors in posting data
                                          print(
                                              "Error posting data to API: $error");
                                        }
                                        try {
                                          postDataWithIncrementedSerialNo();
                                        } catch (error) {
                                          // Handle errors in adding row material
                                          print(
                                              "Error increament serial no: $error");
                                        }

                                        // Add row material or any other logic
                                        try {
                                          _addRowMaterial(widget.tableData);
                                        } catch (error) {
                                          // Handle errors in adding row material
                                          print(
                                              "Error adding row material: $error");
                                        }

                                        // Log product category for debugging purposes
                                        print(
                                            "Product Category: ${widget.ProductCategoryController.text}");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                        backgroundColor: subcolor,
                                        minimumSize: Size(
                                            45.0, 31.0), // Set width and height
                                      ),
                                      child:
                                          Text('Save', style: commonWhiteStyle),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        //POST BUTTON
                        // if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        // Container(
                        //   // color: Subcolor,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: EdgeInsets.only(
                        //             left:
                        //                 Responsive.isDesktop(context) ? 20 : 0,
                        //             top: 0),
                        //         child: Container(
                        //           width: 90,
                        //           child: ElevatedButton(
                        //             onPressed: () {
                        //               fetchProductDetails(
                        //                   widget.tableData,
                        //                   widget
                        //                       .purchaseRecordNoController.text,
                        //                   widget.selectedDate);
                        //             },
                        //             style: ElevatedButton.styleFrom(
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(2.0),
                        //               ),
                        //               backgroundColor: subcolor,
                        //               minimumSize: Size(
                        //                   45.0, 31.0), // Set width and height
                        //             ),
                        //             child:
                        //                 Text('post', style: commonWhiteStyle),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        //REFRESH BUTTON
                        if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 0,
                                    top: 0),
                                child: Container(
                                  width: 90,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Clear();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                      backgroundColor: subcolor,
                                      minimumSize: Size(
                                          45.0, 31.0), // Set width and height
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 10.0), // Add padding
                                    ),
                                    child: Text('Refresh',
                                        style: commonWhiteStyle.copyWith(
                                            fontSize: 14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              SizedBox(height: 10),
            ],
          )),
    );
  }
}
