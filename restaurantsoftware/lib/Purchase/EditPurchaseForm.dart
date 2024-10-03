import 'dart:convert';
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

class EditPurchaseEntryPage extends StatefulWidget {
  const EditPurchaseEntryPage({Key? key}) : super(key: key);

  @override
  State<EditPurchaseEntryPage> createState() => _EditPurchaseEntryPageState();
}

class _EditPurchaseEntryPageState extends State<EditPurchaseEntryPage> {
  final GlobalKey<_PurchaseDiscountFormState> _tableSalesKey =
      GlobalKey<_PurchaseDiscountFormState>();

  void _onShowButtonPressed() {
    _tableSalesKey.currentState?.printShowButtonPressed();
  }

  // String? selectedValue;
  String? selectedproduct;
  List<bool> isSGSTSelected = [true, false, false, false, false];
  List<bool> isCGSTSelected = [true, false, false, false, false];

  String searchText = '';

  @override
  void initState() {
    super.initState();

    fetchSupplierNamelist();
    fetchAllProductNames();
    fetchGSTMethod();
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
  }

  final TextEditingController productCountController = TextEditingController();
  TextEditingController GetIdController = TextEditingController();
  TextEditingController purchaseRecordNoController = TextEditingController();
  TextEditingController purchaseInvoiceNoController = TextEditingController();
  TextEditingController purchaseContactNoontroller = TextEditingController();
  TextEditingController purchaseSupplierAgentidController =
      TextEditingController();
  TextEditingController purchaseSuppliergstnoController =
      TextEditingController();

  TextEditingController purchaseGstMethodController = TextEditingController();

  List<String> SupplierNameList = [];
  TextEditingController SupplierNameController = TextEditingController();
  String? SupplierselectedValue;
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
  String? ProductName;
  String? supplierName;
  // Date value
  DateTime selectedDate = DateTime.now();

  FocusNode productNameFocusNode = FocusNode();
  FocusNode quantityFocusMode = FocusNode();
  FocusNode DisAmtFocusMode = FocusNode();
  FocusNode DisPercFocusMode = FocusNode();
  FocusNode FinalAmtFocusMode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();
  FocusNode showbuttonfocusnode = FocusNode();
  FocusNode RecordNooFocustNode = FocusNode();
  FocusNode InvoiceNooFocustNode = FocusNode();
  FocusNode SupplierNameFocustNode = FocusNode();
  FocusNode DateFocustNode = FocusNode();

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

  Future<void> fetchPurchaseDetails(
      DateTime selectedDate, TextEditingController recordno) async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);

    String recordno = purchaseRecordNoController.text;
    print("dateeeeeee: $date");
    print("recordnooo: $recordno");
    String? cusid = await SharedPrefs.getCusId();
    final url = '$IpAddress/EditPurchasereportsView/$cusid/$date/$recordno/';
    print("urllll : $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> data = responseData.first;
          if (data.containsKey('PurchaseDetails')) {
            final List<dynamic> purchaseDetailsList = data['PurchaseDetails'];
            tableData.clear();
            for (var purchaseDetail in purchaseDetailsList) {
              Map<String, dynamic> purchaseDetailMap =
                  Map<String, dynamic>.from(purchaseDetail);
              tableData.add({
                'productName': purchaseDetailMap['item'],
                'rate': purchaseDetailMap['rate'],
                'quantity': purchaseDetailMap['qty'],
                'total': purchaseDetailMap['total'],
                'discountpercentage': purchaseDetailMap['disperc'],
                'discountamount': purchaseDetailMap['disc'],
                'taxableAmount': purchaseDetailMap['taxable'],
                'cgstpercentage': purchaseDetailMap['cgstperc'],
                'cgstAmount': purchaseDetailMap['cgstamount'],
                'sgstPercentage': purchaseDetailMap['sgstperc'],
                'sgstAmount': purchaseDetailMap['sgstamount'],
                'finalAmount': purchaseDetailMap['finaltotal'],
              });
            }
            GetIdController.text = data['id'].toString();
            purchaseRecordNoController.text = data['serialno'];
            purchaseInvoiceNoController.text = data['invoiceno'];

            purchaseSupplierAgentidController.text = data['agentid'];
            SupplierselectedValue = data['purchasername'];
            SupplierNameController.text = SupplierselectedValue ?? '';
            purchaseContactNoontroller.text = data['contact'];
            purchaseGstMethodController.text = data['gstmethod'];
            discountPercentageController.text = data['disperc'];
          } else {
            throw Exception(
                'Invalid response format: PurchaseDetails not found');
          }
        } else {
          throw Exception('Invalid response: Empty data');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
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
                    Container(
                      child: Row(
                        children: [
                          if (!Responsive.isDesktop(context))
                            SizedBox(
                              height: 70,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text("Edit Purchase Entry", style: HeadingStyle)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 60,
                              ),
                            ],
                          ),
                        ],
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
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode: RecordNooFocustNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    RecordNooFocustNode,
                                                    DateFocustNode),
                                            controller:
                                                purchaseRecordNoController,
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
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("Supplier Name",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 35 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.41,
                                  child: Row(
                                    children: [
                                      Container(
                                          child: _buildSupplierNameDropdown()),
                                      SizedBox(width: 3),
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
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: DateTimePicker(
                                            focusNode: DateFocustNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) {
                                              fetchPurchaseDetails(selectedDate,
                                                  purchaseRecordNoController);
                                              fetchCGSTPercentages();

                                              fetchSupplierContact();
                                              _fieldFocusChange(
                                                context,
                                                DateFocustNode,
                                                showbuttonfocusnode,
                                              );
                                            },
                                            initialValue:
                                                DateTime.now().toString(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            dateLabelText: '',
                                            onChanged: (val) {
                                              setState(() {
                                                selectedDate =
                                                    DateTime.parse(val);
                                              });
                                              print(val);
                                            },
                                            validator: (val) {
                                              print(val);
                                              return null;
                                            },
                                            onSaved: (val) {
                                              setState(() {
                                                selectedDate =
                                                    DateTime.parse(val!);
                                              });
                                              print(val);
                                            },
                                            style: textStyle),
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
                                        Responsive.isDesktop(context) ? 35 : 25,
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
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        height: 24,
                                        color: Colors.grey[200],
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
                                        Responsive.isDesktop(context) ? 40 : 30,
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
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        height: 24,
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
                                            style: textStyle),
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
                                        Responsive.isDesktop(context) ? 35 : 25,
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
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        height: 24,
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
                                        Responsive.isDesktop(context) ? 15 : 25,
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
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        height: 24,
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
                                  height: 24,
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

                        if (Responsive.isDesktop(context))
                          Container(
                            // color: Subcolor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, top: 15),
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
                                        Responsive.isDesktop(context) ? 90 : 60,
                                    child: ElevatedButton(
                                      focusNode: saveButtonFocusNode,
                                      onPressed: () {
                                        saveData();
                                        FocusScope.of(context)
                                            .requestFocus(productNameFocusNode);

                                        getFinalAmtCGST0(tableData);
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
                                          Text('Add', style: commonWhiteStyle),
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
                                  padding:
                                      const EdgeInsets.only(left: 0, top: 15),
                                  child: Text(
                                    "",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Responsive.isDesktop(context)
                                          ? 20
                                          : 40,
                                      bottom: 30,
                                      top: 0),
                                  child: Container(
                                    width:
                                        Responsive.isDesktop(context) ? 95 : 60,
                                    child: ElevatedButton(
                                      focusNode: showbuttonfocusnode,
                                      onPressed: () {
                                        if (purchaseRecordNoController
                                            .text.isEmpty) {
                                          WarninngMessage(context);
                                        } else {
                                          fetchSupplierContact();
                                          fetchPurchaseDetails(selectedDate,
                                              purchaseRecordNoController);
                                          fetchCGSTPercentages();
                                          _onShowButtonPressed();
                                        }
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
                                      child: Tooltip(
                                        message: "Double click the Show button",
                                        child: Text('Show',
                                            style: commonWhiteStyle),
                                      ),
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
                                            ? 64
                                            : 64,
                                        child: ElevatedButton(
                                          focusNode: saveButtonFocusNode,
                                          onPressed: () {
                                            if (purchaseRecordNoController
                                                .text.isEmpty) {
                                              WarninngMessage(context);
                                            } else {
                                              fetchSupplierContact();
                                              fetchPurchaseDetails(selectedDate,
                                                  purchaseRecordNoController);
                                              fetchCGSTPercentages();
                                            }
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
                                          child: Text('Show',
                                              style: commonWhiteStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (!Responsive.isDesktop(context)) SizedBox(height: 25),
                    Responsive.isDesktop(context)
                        ? Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(child: tableView())),
                              Expanded(
                                flex: 1,
                                child: PurchaseDiscountForm(
                                    key: _tableSalesKey,
                                    clearTableData: clearTableData,
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
                                    discountAmountController:
                                        discountAmountController,
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
                                key: _tableSalesKey,
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
                                discountAmountController:
                                    discountAmountController,
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
    print("supplier name : ${SupplierNameController.text}");
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
                        ? MediaQuery.of(context).size.width * 0.075
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

  Future<void> fetchAllProductNames() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
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

  // Widget ProductNameDropdown() {
  //   ProductNameController.text = ProductName ?? '';

  //   return TypeAheadFormField<String?>(
  //     textFieldConfiguration: TextFieldConfiguration(
  //       focusNode: productNameFocusNode,
  //       textInputAction: TextInputAction.next,
  //       onSubmitted: (_) =>
  //           _fieldFocusChange(context, productNameFocusNode, quantityFocusMode),

  //       controller: ProductNameController,

  //       decoration: InputDecoration(
  //         // labelText: ' ${selectedValue ?? ""}',

  //         border: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //         ),
  //         contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //         labelStyle: TextStyle(fontSize: 12),
  //         suffixIcon: Icon(
  //           Icons.keyboard_arrow_down,
  //           size: 18,
  //         ),
  //       ),
  //       style: TextStyle(
  //           fontSize: 12,
  //           color: Colors.black), // Set text style for onSuggestionSelected
  //     ),
  //     suggestionsCallback: (pattern) {
  //       return ProductNameList.where(
  //               (item) => item.toLowerCase().contains(pattern.toLowerCase()))
  //           .toList();
  //     },
  //     itemBuilder: (context, String? suggestion) {
  //       return ListTile(
  //         title: Text(
  //           suggestion ?? ' ${ProductName ?? ''}',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.black,
  //           ),
  //         ),
  //       );
  //     },
  //     onSuggestionSelected: (String? suggestion) async {
  //       setState(() {
  //         ProductName = suggestion;
  //         ProductNameController.text = suggestion ?? ' ${ProductName ?? ''}';
  //       });
  //       if (isProductAlreadyExists(ProductName!)) {
  //         ProductName = '';
  //         _fieldFocusChange(
  //             context, productNameFocusNode, productNameFocusNode);
  //         productalreadyexist();
  //       } else {
  //         await fetchProductAmount();
  //         await fetchCGSTPercentages();
  //         await fetchSGSTPercentages();
  //         await fetchProductCategory();
  //         FocusScope.of(context).requestFocus(quantityFocusMode);
  //       }
  //     },
  //     suggestionsBoxDecoration: SuggestionsBoxDecoration(
  //       constraints: BoxConstraints(maxHeight: 150),
  //     ),
  //   );
  // }

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

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  // void saveData() {
  //   // Check if any required field is empty
  //   if (purchaseInvoiceNoController.text.isEmpty ||
  //       SupplierNameController.text.isEmpty ||
  //       purchaseContactNoontroller.text.isEmpty ||
  //       ProductName!.isEmpty ||
  //       rateController.text.isEmpty ||
  //       quantityController.text.isEmpty ||
  //       TotalController.text.isEmpty ||
  //       discountPercentageController.text.isEmpty ||
  //       discountAmountController.text.isEmpty ||
  //       taxableController.text.isEmpty ||
  //       cgstPercentageController.text.isEmpty ||
  //       cgstAmountController.text.isEmpty ||
  //       sgstPercentageController.text.isEmpty ||
  //       sgstAmountController.text.isEmpty ||
  //       finalAmountController.text.isEmpty) {
  //     // Show error message
  //     WarninngMessage();
  //     return;
  //   }

  //   String productName = ProductName!;
  //   String rate = rateController.text;
  //   String stockcheck = stockcheckController.text;
  //   String quantity = quantityController.text;
  //   String total = TotalController.text;
  //   String discountPercentage = discountPercentageController.text;
  //   String discountAmount = discountAmountController.text;
  //   String taxable = taxableController.text;
  //   String cgstPercentage = purchaseGstMethodController.text.isEmpty
  //       ? "0"
  //       : cgstPercentageController.text;

  //   String cgstAmount = purchaseGstMethodController.text.isEmpty
  //       ? "0"
  //       : cgstAmountController.text;
  //   String sgstPercentage = purchaseGstMethodController.text.isEmpty
  //       ? "0"
  //       : sgstPercentageController.text;
  //   String sgstAmount = purchaseGstMethodController.text.isEmpty
  //       ? "0"
  //       : sgstAmountController.text;
  //   String finalAmount = finalAmountController.text;

  //   // Check if the product already exists in tableData
  //   bool found = false;
  //   for (var item in tableData) {
  //     if (item['productName'] == productName) {
  //       // Update quantity
  //       item['quantity'] =
  //           (int.parse(item['quantity']) + int.parse(quantity)).toString();
  //       // Update total, discountpercentage, discountamount, taxableAmount, cgstAmount, sgstAmount, finalAmount
  //       item['total'] =
  //           (double.parse(item['total']) + double.parse(total)).toString();
  //       item['discountpercentage'] = (double.parse(item['discountpercentage']) +
  //               double.parse(discountPercentage))
  //           .toString();
  //       item['discountamount'] = (double.parse(item['discountamount']) +
  //               double.parse(discountAmount))
  //           .toString();
  //       item['taxableAmount'] =
  //           (double.parse(item['taxableAmount']) + double.parse(taxable))
  //               .toString();
  //       item['cgstAmount'] =
  //           (double.parse(item['cgstAmount']) + double.parse(cgstAmount))
  //               .toStringAsFixed(2);
  //       item['sgstAmount'] =
  //           (double.parse(item['sgstAmount']) + double.parse(sgstAmount))
  //               .toStringAsFixed(2);
  //       item['finalAmount'] =
  //           (double.parse(item['finalAmount']) + double.parse(finalAmount))
  //               .toString();
  //       found = true;
  //       break;
  //     }
  //   }

  //   // If the product doesn't exist, add it to tableData
  //   if (!found) {
  //     setState(() {
  //       tableData.add({
  //         'productName': productName,
  //         'rate': rate,
  //         'quantity': quantity,
  //         "total": total,
  //         "discountpercentage": discountPercentage,
  //         "discountamount": discountAmount,
  //         "taxableAmount": taxable,
  //         "cgstpercentage": cgstPercentage,
  //         "cgstAmount": cgstAmount,
  //         "sgstPercentage": sgstPercentage,
  //         "sgstAmount": sgstAmount,
  //         "finalAmount": finalAmount,
  //         "stockcheck": stockcheck
  //       });
  //     });
  //   }

  //   // Clear text controllers
  //   setState(() {
  //     ProductName = null;
  //     ProductNameController.clear(); // Clear the text field
  //   });
  //   rateController.clear();
  //   quantityController.clear();
  //   TotalController.clear();
  //   discountPercentageController.clear();
  //   discountAmountController.clear();
  //   taxableController.clear();
  //   cgstPercentageController.clear();
  //   cgstAmountController.clear();
  //   sgstPercentageController.clear();
  //   sgstAmountController.clear();
  //   finalAmountController.clear();
  //   isCGSTSelected = [true, false, false, false, false];
  //   isSGSTSelected = [true, false, false, false, false];
  // }

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
      // Print the contents of all fields
      print('purchaseInvoiceNo: ${purchaseInvoiceNoController.text}');
      print('SupplierName: ${SupplierNameController.text}');
      print('purchaseContactNo: ${purchaseContactNoontroller.text}');
      print('productName: ${ProductNameController.text}');
      print('rate: ${rateController.text}');
      print('quantity: ${quantityController.text}');
      print('Total: ${TotalController.text}');
      print('discountPercentage: ${discountPercentageController.text}');
      print('discountAmount: ${discountAmountController.text}');
      print('taxable: ${taxableController.text}');
      print('cgstPercentage: ${cgstPercentageController.text}');
      print('cgstAmount: ${cgstAmountController.text}');
      print('sgstPercentage: ${sgstPercentageController.text}');
      print('sgstAmount: ${sgstAmountController.text}');
      print('finalAmount: ${finalAmountController.text}');

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
          "stockcheck": stockcheck
        });
      });
    }

    // Clear text controllers
    setState(() {
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
    isCGSTSelected = [true, false, false, false, false];
    isSGSTSelected = [true, false, false, false, false];
  }

  void _deleteRow(int index) {
    setState(() {
      tableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

  bool isProductAlreadyExists(String productName) {
    // Assuming table data is stored in a List<Map<String, dynamic>> called tableData
    for (var item in tableData) {
      if (item['productName'] == productName) {
        return true;
      }
    }
    return false;
  }

  void productalreadyexist() {
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
                'This product is already in the table data.',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  void updateMangoStock(double qty, String productName) async {
    String? cusid = await SharedPrefs.getCusId();
    // Fetching product details from the API
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    http.Response productResponse = await http.get(Uri.parse(apiUrl));
    if (productResponse.statusCode != 200) {
      print('Failed to fetch product details: ${productResponse.statusCode}');
      return;
    }

    // Parsing product details JSON
    List<dynamic> products = jsonDecode(productResponse.body)['results'];

    // Finding the product by name
    var product = products.firstWhere(
        (product) => product['name'].toLowerCase() == productName.toLowerCase(),
        orElse: () => null);

    if (product == null) {
      print('Product $productName not found');
      return;
    }

    // Extracting product ID and existing stock
    int productId = product['id'];
    double existingStock = double.parse(product['stock']);

    // Calculating new stock after subtracting the quantity
    double newStock = existingStock - qty;

    // Prepare data to be updated
    Map<String, dynamic> putData = {"cusid": "BTRM_2", 'stock': newStock};

    // Convert data to JSON format
    String jsonData = jsonEncode(putData);

    // Make PUT request to update the product stock
    String updateUrl = '$IpAddress/PurchaseProductDetailsalldatas/$productId/';
    http.Response response = await http.put(
      Uri.parse(updateUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    // Check response status
    if (response.statusCode == 200) {
      // Data updated successfully
      print('Stock updated successfully for product: $productName');
    } else {
      // Data updating failed
      print(
          'Failed to update stock for product $productName: ${response.statusCode}, ${response.body}');
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    int index,
    String productName,
    double quantity,
  ) async {
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
                _deleteRow(index);
                // postDataToAPI(tableData);
                double qty = quantity;
                String prodName = productName;
                // print("productname : $prodName,    quantity : $qty");

                updateMangoStock(qty, prodName);

                purchaseGstMethodController.clear();
                // print(
                //     "productname wwwww: ${productNameController.text},    quantity : ${rateController.text}");

                ProductNameController.clear();
                rateController.clear();
                quantityController.clear();
                TotalController.clear();
                discountAmountController.clear();
                discountPercentageController.clear();

                taxableController.clear();
                cgstAmountController.clear();
                sgstAmountController.clear();
                finalAmountController.clear();
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

  Future<void> postDataToAPI(
    List<Map<String, dynamic>> tableData,
  ) async {
    if (!mounted) return;

    // CalculateCGSTFinalAmount();
    // CalculateSGSTFinalAmount();
    // calculateFinalTaxableAmount();
    // calculateFinaltotalAmount();
    List<String> productDetails = [];

    String purchaseRecordNo = purchaseRecordNoController.text;
    for (var data in tableData) {
      // Format each product detail as "{productName},{amount}"
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);
      productDetails.add(
          "{serialno:$purchaseRecordNo,dt:$date,item:${data['productName']},qty:${data['quantity']},rate:${data['rate']},disc:${data['discountamount']},total:${data['total']},cgstperc:${data['cgstpercentage']},cgstamount:${data['cgstAmount']},sgstperc:${data['sgstPercentage']},sgstamount:${data['sgstAmount']},finaltotal:${data['finalAmount']},disperc:${data['discountpercentage']},taxable:${data['taxableAmount']},igstperc:0.0,igstamnt:0.0,cessperc:0.0,cessamnt:0.0,addstock:${data['stockcheck']}}");
    }
    print("tableeeeeeee dataaaaaaaas  : $tableData");

    // Join all product details into a single string
    String productDetailsString = productDetails.join('');
    // print("productdetails:$productDetailsString");
    // Prepare the data to be sent
    if (!mounted) return; // Check if the widget is mounted before proceeding

    String? cusid = await SharedPrefs.getCusId();
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "date": DateFormat('yyyy-MM-dd').format(selectedDate),
      // "purchasername": widget.purchaseSupplierNameController.text,
      // "count": widget.getProductCountCallback(widget.tableData).toString(),
      // "total": FinalTotalAmountController.text,
      // // "name": widget.purchaseSupplierNameController.text,
      // "invoiceno": widget.purchaseInvoiceNoController.text,
      // "finlaldis": purchaseDisAMountController.text,
      // "round": purchaseRoundOffController.text,
      // "cgst0": CGSTPercent0.text, // Use the calculated CGST values
      // "cgst25": CGSTPercent25.text,
      // "cgst6": CGSTPercent6.text,
      // "cgst9": CGSTPercent9.text,
      // "cgst14": CGSTPercent14.text,
      // "sgst0": SGSTPercent0.text,
      // "sgst25": SGSTPercent25.text,
      // "sgst6": SGSTPercent6.text,
      // "sgst9": SGSTPercent9.text,
      // "sgst14": SGSTPercent14.text,
      // "igst0": "0.0",
      // "igst5": "0.0",
      // "igst12": "0.0",
      // "igst18": "0.0",
      // "igst28": "0.0",
      // "cess": "0.0",
      // "totcgst": CGSTAmountController.text,
      // "totsgst": SGSTAmountController.text,
      // "totigst": "0.0",
      // "totcess": "0.0",
      // "proddis":
      //     widget.getProductDiscountCallBack(widget.tableData).toString(),
      // "taxable": TaxableController.text,
      // "gstmethod": widget.purchaseGSTMethodController.text.isEmpty
      //     ? "NonGst"
      //     : widget.purchaseGSTMethodController.text,
      // "disperc": purchaseDisPercentageController.text,
      // "agentid": widget.purchaseSupplierAgentidController.text,
      // "contact": widget.purchaseContactController.text,
      // "gstno": widget.purchaseSuppliergstnoController.text,
      // "finaltaxable": finalTaxableController.text,
      "PurchaseDetails": productDetailsString,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);
    int id = int.parse(GetIdController.text);

    print("iddddddddddddd:$id");
    try {
      // Send the PUT request
      var response = await http.put(
        Uri.parse('$IpAddress/PurchaseRoundDetailsalldatas/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      if (!mounted) return; // Check if the widget is mounted before proceeding

      // Check the response status
      if (response.statusCode == response.statusCode) {
        print('Data updated successfully');
        // successfullySavedMessage();
        // widget.purchaseRecordNoController.text = '0';
        // widget.purchaseInvoiceNoController.clear();
        // widget.purchaseSupplierNameController.clear();
        // widget.purchaseContactController.clear();
        // widget.clearTableData();

        // purchaseDisPercentageController.text = '0.0';
        // purchaseDisAMountController.text = '0.0';
        // GetfinalTaxableController.text = '0.0';
        // GetFinalTotalAmountController.text = '0.0';
        // GetCGSTAmountController.text = '0.0';
        // GetSGSTAmountController.text = '0.0';

        // FinalTotalAmountController.text = '0.0';
        // finalTaxableController.text = '0.0';
        // CGSTAmountController.text = '0.0';
        // SGSTAmountController.text = '0.0';
        // purchaseRoundOffController.text = '0.0';
      } else {
        print('Failed to post data. Error code: ${response.statusCode}');
        // print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
    }
  }

  void clearTableData() {
    setState(() {
      tableData.clear();
      SupplierNameController.clear();
      SupplierselectedValue = '';
    });
  }

  // Widget tableView() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 20, right: 20),
  //     child: SingleChildScrollView(
  //       child: Container(
  //         height: Responsive.isDesktop(context) ? 350 : 320,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey.withOpacity(0.5),
  //               spreadRadius: 2,
  //               blurRadius: 5,
  //               offset: Offset(0, 3),
  //             ),
  //           ],
  //         ),
  //         child: SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: SingleChildScrollView(
  //             child: Container(
  //               width: Responsive.isDesktop(context)
  //                   ? MediaQuery.of(context).size.width * 0.6
  //                   : MediaQuery.of(context).size.width * 1.8,
  //               child: Column(children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 0.0, right: 0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.fastfood,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 1),
  //                                 Text(
  //                                   "P.Name",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.attach_money,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Rate",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.add_box,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Qty",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.currency_exchange_outlined,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Total",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.pie_chart,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Dis %",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.monetization_on,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Dis ₹",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.currency_exchange_outlined,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Taxable",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       // Flexible(
  //                       //   child: Container(
  //                       //     height: Responsive.isDesktop(context) ? 25 : 30,
  //                       //     width: 265.0,
  //                       //     decoration: BoxDecoration(
  //                       //       color: Colors.grey[200],
  //                       //     ),
  //                       //     child: Center(
  //                       //       child: Row(
  //                       //         mainAxisAlignment: MainAxisAlignment.center,
  //                       //         children: [
  //                       //           // Icon(
  //                       //           //   Icons.pie_chart,
  //                       //           //   size: 15,
  //                       //           //   color: Colors.blue,
  //                       //           // ),
  //                       //           // SizedBox(width: 5),
  //                       //           Text(
  //                       //             "Cgst%",
  //                       //             textAlign: TextAlign.center,
  //                       //             style: TextStyle(
  //                       //               fontSize: 12,
  //                       //               color: Colors.black,
  //                       //               fontWeight: FontWeight.w500,
  //                       //             ),
  //                       //           ),
  //                       //         ],
  //                       //       ),
  //                       //     ),
  //                       //   ),
  //                       // ),

  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.local_atm,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Cgst %-₹",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),

  //                       // Flexible(
  //                       //   child: Container(
  //                       //     height: Responsive.isDesktop(context) ? 25 : 30,
  //                       //     width: 265.0,
  //                       //     decoration: BoxDecoration(
  //                       //       color: Colors.grey[200],
  //                       //     ),
  //                       //     child: Center(
  //                       //       child: Row(
  //                       //         mainAxisAlignment: MainAxisAlignment.center,
  //                       //         children: [
  //                       //           // Icon(
  //                       //           //   Icons.pie_chart,
  //                       //           //   size: 15,
  //                       //           //   color: Colors.blue,
  //                       //           // ),
  //                       //           // SizedBox(width: 5),
  //                       //           Text(
  //                       //             "Sgst%",
  //                       //             textAlign: TextAlign.center,
  //                       //             style: TextStyle(
  //                       //               fontSize: 12,
  //                       //               color: Colors.black,
  //                       //               fontWeight: FontWeight.w500,
  //                       //             ),
  //                       //           ),
  //                       //         ],
  //                       //       ),
  //                       //     ),
  //                       //   ),
  //                       // ),

  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.local_atm,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "Sgst %-₹",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 // Icon(
  //                                 //   Icons.attach_money,
  //                                 //   size: 15,
  //                                 //   color: Colors.blue,
  //                                 // ),
  //                                 // SizedBox(width: 5),
  //                                 Text(
  //                                   "FinAmt",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 100,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                           ),
  //                           child: Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(
  //                                   Icons.delete,
  //                                   size: 15,
  //                                   color: Colors.black,
  //                                 ),
  //                                 // SizedBox(width: 5),
  //                                 // Text(
  //                                 //   "Delete",
  //                                 //   textAlign: TextAlign.center,
  //                                 //   style: TextStyle(
  //                                 //     fontSize: 12,
  //                                 //     color: Colors.black,
  //                                 //     fontWeight: FontWeight.w500,
  //                                 //   ),
  //                                 // ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (tableData.isNotEmpty)
  //                   ...tableData.asMap().entries.map((entry) {
  //                     int index = entry.key;
  //                     Map<String, dynamic> data = entry.value;
  //                     var productName = data['productName'].toString();
  //                     var rate = data['rate'].toString();
  //                     var quantity = data['quantity'].toString();
  //                     var total = data['total'].toString();
  //                     var discountpercentage =
  //                         data['discountpercentage'].toString();
  //                     var discountamount = data['discountamount'].toString();
  //                     var taxableAmount = data['taxableAmount'].toString();
  //                     var cgstpercentage = data['cgstpercentage'] ?? 0;

  //                     var cgstAmount = data['cgstAmount'].toString();
  //                     var sgstPercentage = data['sgstPercentage'] ?? 0;
  //                     var sgstAmount = data['sgstAmount'].toString();
  //                     var finalAmount = data['finalAmount'].toString();
  //                     // print(
  //                     //     "tableDataeeeeeeeeeeeeeeeeeeeeeeeeeeee checkkkk : $tableData");

  //                     bool isEvenRow = tableData.indexOf(data) % 2 == 0;
  //                     Color? rowColor = isEvenRow
  //                         ? Color.fromARGB(224, 255, 255, 255)
  //                         : Color.fromARGB(255, 223, 225, 226);

  //                     return Padding(
  //                       padding: const EdgeInsets.only(left: 0.0, right: 0),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   productName,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   rate,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   quantity,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   total,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   discountpercentage,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   discountamount,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   taxableAmount,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   "${cgstpercentage.toString()}-$cgstAmount", // Convert to string explicitly
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           // Flexible(
  //                           //   child: Container(
  //                           //     height: 30,
  //                           //     width: 265.0,
  //                           //     decoration: BoxDecoration(
  //                           //       color: rowColor,
  //                           //       border: Border.all(
  //                           //         color: Color.fromARGB(255, 226, 225, 225),
  //                           //       ),
  //                           //     ),
  //                           //     child: Center(
  //                           //       child: Text(
  //                           //         cgstAmount,
  //                           //         textAlign: TextAlign.center,
  //                           //         style: TextStyle(
  //                           //           color: Colors.black,
  //                           //           fontSize: 12,
  //                           //           fontWeight: FontWeight.w400,
  //                           //         ),
  //                           //       ),
  //                           //     ),
  //                           //   ),
  //                           // ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   "${sgstPercentage.toString()}-${sgstAmount}",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           // Flexible(
  //                           //   child: Container(
  //                           //     height: 30,
  //                           //     width: 265.0,
  //                           //     decoration: BoxDecoration(
  //                           //       color: rowColor,
  //                           //       border: Border.all(
  //                           //         color: Color.fromARGB(255, 226, 225, 225),
  //                           //       ),
  //                           //     ),
  //                           //     child: Center(
  //                           //       child: Text(
  //                           //         sgstAmount,
  //                           //         textAlign: TextAlign.center,
  //                           //         style: TextStyle(
  //                           //           color: Colors.black,
  //                           //           fontSize: 12,
  //                           //           fontWeight: FontWeight.w400,
  //                           //         ),
  //                           //       ),
  //                           //     ),
  //                           //   ),
  //                           // ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   finalAmount,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 100,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Padding(
  //                                 padding: const EdgeInsets.only(bottom: 10.0),
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     // Padding(
  //                                     //   padding: const EdgeInsets.only(left: 0),
  //                                     //   child: Container(
  //                                     //     child: IconButton(
  //                                     //       icon: Icon(
  //                                     //         Icons.add,
  //                                     //         color: Colors.blue,
  //                                     //         size: 18,
  //                                     //       ),
  //                                     //       onPressed: () {
  //                                     //         print(
  //                                     //             "Serial No | Date | Product Name | Quantity | Rate | Discount % | Total | CGST % | CGST Amount | SGST % | SGST Amount | Final Amount | DiscountPercentage | Taxable Amount | igstperc | igstamnt | cessperc | cessamnt");

  //                                     //         // Print data from each row
  //                                     //         for (var data in tableData) {
  //                                     //           print(
  //                                     //               "${purchaseRecordNoController.text} | ${DateFormat('yyyy-MM-dd').format(selectedDate)} | ${data['productName']} | ${data['quantity']} | ${data['rate']} | ${data['discountpercentage']} | ${data['total']} | ${data['cgstpercentage']} | ${data['cgstAmount']} | ${data['sgstPercentage']} | ${data['sgstAmount']} | ${data['finalAmount']}|  ${data['discountamount']} | | ${data['taxableAmount']} 0 | 0 | 0 | 0");
  //                                     //         }

  //                                     //         // Call postDataToAPI method after the loop
  //                                     //         Post__purchaseDetails(
  //                                     //             tableData,
  //                                     //             purchaseRecordNoController
  //                                     //                 .text,
  //                                     //             selectedDate);
  //                                     //       },
  //                                     //       color: Colors.black,
  //                                     //     ),
  //                                     //   ),
  //                                     // ),
  //                                     Padding(
  //                                       padding: const EdgeInsets.only(left: 0),
  //                                       child: Container(
  //                                         child: IconButton(
  //                                           icon: Icon(
  //                                             Icons.delete,
  //                                             color: Colors.red,
  //                                             size: 18,
  //                                           ),
  //                                           onPressed: () {
  //                                             _showDeleteConfirmationDialog(
  //                                                 context,
  //                                                 index,
  //                                                 productName,
  //                                                 double.parse(
  //                                                     quantity.toString()));
  //                                           },
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }).toList()
  //               ]),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                    ? MediaQuery.of(context).size.width * 0.6
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
                      var stockcheck = data['stockcheck'].toString();
                      // print("stock checkkkk : $stockcheck");

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
                                                  context,
                                                  index,
                                                  productName,
                                                  double.parse(
                                                      quantity.toString()));
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

  final TextEditingController discountAmountController;

  final TextEditingController purchaseRecordNoController;
  final TextEditingController purchaseInvoiceNoController;
  final TextEditingController purchaseGSTMethodController;
  final TextEditingController purchaseContactController;
  final TextEditingController purchaseSupplierAgentidController;
  final TextEditingController purchaseSuppliergstnoController;
  final TextEditingController ProductCategoryController;

  final TextEditingController purchaseSupplierNameController;

  // final String purchaseSupplierNameController;

  final DateTime selectedDate;

  PurchaseDiscountForm(
      {required this.tableData,
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
      required this.discountAmountController,
      required this.selectedDate,
      required this.clearTableData,
      required GlobalKey<_PurchaseDiscountFormState> key})
      : super(key: key);
  @override
  State<PurchaseDiscountForm> createState() => _PurchaseDiscountFormState();
}

class _PurchaseDiscountFormState extends State<PurchaseDiscountForm> {
  void printShowButtonPressed() {
    fetchPurchaseDetails(
        widget.selectedDate, widget.purchaseRecordNoController);
    ;
  }

  TextEditingController GetIdController = TextEditingController();
  TextEditingController purchaseDisAMountController = TextEditingController();
  TextEditingController purchaseDisPercentageController =
      TextEditingController();

  TextEditingController GetfinalTaxableController = TextEditingController();
  TextEditingController GetCGSTAmountController = TextEditingController();

  TextEditingController GetSGSTAmountController = TextEditingController();
  TextEditingController GetFinalTotalAmountController = TextEditingController();
  late String finalTaxableAmountinitialValue;

  FocusNode finaldiscountPercFocusNode = FocusNode();
  FocusNode FinalDiscountAmtFocusNode = FocusNode();
  FocusNode RoundOffFocusNode = FocusNode();
  FocusNode FinalAmountFocusNode = FocusNode();
  FocusNode FinalTotalAmountFocusNode = FocusNode();
  FocusNode saveallButtonFocusNode = FocusNode();

  TextEditingController purchaseRoundOffController =
      TextEditingController(text: '0');
  int productCount = 0;
  void initState() {
    super.initState();
    // purchaseDisAMountController.text = "0.0";
    // purchaseDisPercentageController.text = "0";

    productCount = widget.getProductCountCallback(widget.tableData);
  }

  Future<void> fetchPurchaseDetails(
      DateTime selectedDate, TextEditingController recordno) async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    String recordno = widget.purchaseRecordNoController.text;
    print("widgettttt dateeeeeee: $date");
    print("widgettttt  recored no : $recordno");

    String? cusid = await SharedPrefs.getCusId();
    final url = '$IpAddress/EditPurchasereportsView/$cusid/$date/$recordno/';
    print("url : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List<dynamic> && responseData.isNotEmpty) {
          var firstRecord = responseData[0];
          GetIdController.text = firstRecord['id'].toString();
          purchaseDisAMountController.text = firstRecord['finlaldis'] ?? '';
          purchaseDisPercentageController.text = firstRecord['disperc'] ?? '';

          purchaseRoundOffController.text = firstRecord['round'] ?? '';

          // Get the values for FinalTaxableAmountinitialValue, CGSTAmountInitialvalue, SGSTAmountInitialvalue, FinalTotalAmtInitialValue
          widget.getTotalFinalTaxableCallback(widget.tableData).text =
              firstRecord['finaltaxable'] ?? '';
          widget.getTotalCGSTAmtCallback(widget.tableData).text =
              firstRecord['totcgst'] ?? '';
          widget.getTotalSGSTAMtCallback(widget.tableData).text =
              firstRecord['totsgst'] ?? '';
          widget.getTotalFinalAmtCallback(widget.tableData).text =
              firstRecord['total'] ?? '';
          print(
              "final taxable : ${GetfinalTaxableController.text}   ${GetCGSTAmountController.text}    ${GetSGSTAmountController.text}    ${GetFinalTotalAmountController.text}");
        }

        print("url id get using controller: ${GetIdController.text}");
        // print("Discount Amount: ${purchaseDisAMountController.text}");
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void didUpdateWidget(PurchaseDiscountForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.getProductCountCallback(widget.tableData) != productCount) {
      setState(() {
        productCount = widget.getProductCountCallback(widget.tableData);
      });
      fetchPurchaseDetails(
          widget.selectedDate, widget.purchaseRecordNoController);

      // print(
      //     "selected dataaaaaaaaaaaaa  : ${widget.selectedDate}      selected recored no : ${widget.purchaseRecordNoController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
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
    // print("finalllllllll taxable : ${GetfinalTaxableController.text}");
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
      if (!mounted) return;

      CalculateCGSTFinalAmount();
      CalculateSGSTFinalAmount();
      calculateFinalTaxableAmount();
      calculateFinaltotalAmount();
      List<String> productDetails = [];

      for (var data in tableData) {
        // Format each product detail as "{productName},{amount}"
        String date = DateFormat('yyyy-MM-dd').format(selectedDate);
        productDetails.add(
            "{serialno:$purchaseRecordNo,dt:$date,item:${data['productName']},qty:${data['quantity']},rate:${data['rate']},disc:${data['discountamount']},total:${data['total']},cgstperc:${data['cgstpercentage']},cgstamount:${data['cgstAmount']},sgstperc:${data['sgstPercentage']},sgstamount:${data['sgstAmount']},finaltotal:${data['finalAmount']},disperc:${data['discountpercentage']},taxable:${data['taxableAmount']},igstperc:0.0,igstamnt:0.0,cessperc:0.0,cessamnt:0.0,addstock:${data['stockcheck']}}");
      }
      print("tableeeeeeee dataaaaaaaas  : $tableData");

      // Join all product details into a single string
      String productDetailsString = productDetails.join('');
      print("productdetails:$productDetailsString");
      // Prepare the data to be sent
      if (!mounted) return; // Check if the widget is mounted before proceeding

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "date": DateFormat('yyyy-MM-dd').format(selectedDate),
        "purchasername": widget.purchaseSupplierNameController.text,
        "count": widget.getProductCountCallback(widget.tableData).toString(),
        "total": FinalTotalAmountController.text,
        // "name": widget.purchaseSupplierNameController.text,
        "invoiceno": widget.purchaseInvoiceNoController.text,
        "finlaldis": purchaseDisAMountController.text,
        "round": purchaseRoundOffController.text,
        "cgst0": CGSTPercent0.text,
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

      // Convert the data to JSON format
      String jsonData = jsonEncode(postData);
      int id = int.parse(GetIdController.text);
      print("iddddddddddddd:$id");
      print("tabledata : $tableData");
      try {
        // Send the PUT request
        var response = await http.put(
          Uri.parse('$IpAddress/PurchaseRoundDetailsalldatas/$id/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );
        print(
            "round table url :: $IpAddress/PurchaseRoundDetailsalldatas/$id/");
        if (!mounted)
          return; // Check if the widget is mounted before proceeding

        // Check the response status
        if (response.statusCode == 200) {
          print('Data updated successfully');
          await logreports(
              "Purchase: Invoice-${widget.purchaseInvoiceNoController.text}_Billno-${widget.purchaseRecordNoController.text}_AgentName-${widget.purchaseSupplierNameController.text}_Updated");

          successfullySavedMessage(context);
          widget.purchaseRecordNoController.text = '0';
          widget.purchaseInvoiceNoController.clear();
          widget.purchaseSupplierNameController.clear();
          widget.purchaseContactController.clear();
          widget.clearTableData();

          purchaseDisPercentageController.text = '0.0';
          purchaseDisAMountController.text = '0.0';
          GetfinalTaxableController.text = '0.0';
          GetFinalTotalAmountController.text = '0.0';
          GetCGSTAmountController.text = '0.0';
          GetSGSTAmountController.text = '0.0';

          FinalTotalAmountController.text = '0.0';
          finalTaxableController.text = '0.0';
          CGSTAmountController.text = '0.0';
          SGSTAmountController.text = '0.0';
          purchaseRoundOffController.text = '0.0';
        } else {
          print('Failed to post data. Error code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Failed to post data. Error: $e');
      }
    }

    Clear() {
      widget.purchaseRecordNoController.text = '0';
      widget.purchaseInvoiceNoController.clear();
      widget.purchaseSupplierNameController.clear();
      widget.purchaseContactController.clear();
      widget.clearTableData();

      purchaseDisPercentageController.text = '0.0';
      purchaseDisAMountController.text = '0.0';
      GetfinalTaxableController.text = '0.0';
      GetFinalTotalAmountController.text = '0.0';
      GetCGSTAmountController.text = '0.0';
      GetSGSTAmountController.text = '0.0';

      FinalTotalAmountController.text = '0.0';
      finalTaxableController.text = '0.0';
      CGSTAmountController.text = '0.0';
      SGSTAmountController.text = '0.0';
      purchaseRoundOffController.text = '0.0';
    }

    double screenHeight = MediaQuery.of(context).size.height;
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

    @override
    void didUpdateWidget(PurchaseDiscountForm oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.getProductCountCallback(widget.tableData) != productCount) {
        setState(() {
          productCount = widget.getProductCountCallback(widget.tableData);
        });

        calculateDiscountAmount();
        CalculateCGSTFinalAmount();
        CalculateSGSTFinalAmount();
        calculatetotalAmount();
        calculateFinalTaxableAmount();
        calculateFinaltotalAmount();
        // print(
        //     "selected dataaaaaaaaaaaaa  : ${widget.selectedDate}      selected recored no : ${widget.purchaseRecordNoController.text}");
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
                                    color: Colors.grey[200],
                                    child: TextField(
                                        controller: TextEditingController(
                                            text:
                                                "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getProductCountCallback(widget.tableData))}"),
                                        readOnly: true,
                                        onChanged: (newvalue) {
                                          double newPercentage =
                                              double.tryParse(newvalue) ?? 0.0;
                                          TaxableController.text =
                                              newPercentage.toString();
                                          purchaseDisPercentageController.text =
                                              widget.discountAmountController
                                                  .text;
                                          calculateDiscountAmount();
                                          CalculateCGSTFinalAmount();
                                          CalculateSGSTFinalAmount();
                                          calculatetotalAmount();
                                          calculateFinalTaxableAmount();
                                          calculateFinaltotalAmount();
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    0, 150, 44, 44),
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    0, 255, 255, 255),
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
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 5, top: 8),
                              //   child: Container(
                              //     width: Responsive.isDesktop(context)
                              //         ? 110
                              //         : MediaQuery.of(context).size.width *
                              //             0.38,
                              //     child: Container(
                              //       height: 27,
                              //       width: 100,
                              //       // color: Colors.grey[200],
                              //       child: Text(
                              //         "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getProductCountCallback(widget.tableData))}",
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        if (Responsive.isDesktop(context))
                          Expanded(
                            child: SizedBox(width: 0),
                          ),
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
                                    // width: 100,
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
                    // SizedBox(height: 2),
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
                                    child: TextField(
                                        controller: TaxableController,
                                        readOnly: true,
                                        onChanged: (newvalue) {
                                          double newPercentage =
                                              double.tryParse(newvalue) ?? 0.0;
                                          TaxableController.text =
                                              newPercentage.toString();
                                          purchaseDisPercentageController.text =
                                              widget.discountAmountController
                                                  .text;
                                          calculateDiscountAmount();
                                          CalculateCGSTFinalAmount();
                                          CalculateSGSTFinalAmount();
                                          calculatetotalAmount();
                                          calculateFinalTaxableAmount();
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
                        if (Responsive.isDesktop(context))
                          Expanded(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0),
                          ),
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
                                        focusNode: finaldiscountPercFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _fieldFocusChange(
                                                context,
                                                finaldiscountPercFocusNode,
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
                    SizedBox(height: 2),
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
                          Expanded(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0),
                          ),
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
                                        style: textStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
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
                                        style: textStyle),
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
                          Expanded(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0),
                          ),
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
                                    // width: 100,
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
                                        style: textStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
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
                                    // color: Colors.grey[200],
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
                                        style: textStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (Responsive.isDesktop(context))
                          Expanded(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0),
                          ),
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
                                        style: textStyle),
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
                                                : 60,
                                            child: ElevatedButton(
                                              focusNode: saveallButtonFocusNode,
                                              onPressed: () {
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
                                                  // Show error message
                                                  print(
                                                      "datasssss: ${widget.purchaseInvoiceNoController.text}   ${widget.purchaseSupplierAgentidController.text}    ${widget.tableData}    ${purchaseDisAMountController.text}   ${purchaseRoundOffController.text}    ${purchaseDisPercentageController.text}");
                                                  WarninngMessage(context);
                                                  return;
                                                }
                                                postDataToAPI(
                                                    widget.tableData,
                                                    widget
                                                        .purchaseRecordNoController
                                                        .text,
                                                    widget.selectedDate);
                                                // Post__purchaseDetails(
                                                //     widget.tableData,
                                                //     widget.purchaseRecordNoController.text,
                                                //     widget.selectedDate);

                                                _addRowMaterial(
                                                  widget.tableData,
                                                );

                                                // print(
                                                //     "Product Category:${widget.ProductCategoryController.text}");
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical:
                                                        10.0), // Add padding
                                              ),
                                              child: Text('Save',
                                                  style: commonWhiteStyle
                                                      .copyWith(fontSize: 14)),
                                            ),
                                          ),
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
                                                : 75,
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical:
                                                        10.0), // Add padding
                                              ),
                                              child: Text(
                                                'Refresh',
                                                style: commonWhiteStyle
                                                    .copyWith(fontSize: 14),
                                              ),
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
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 0,
                                    top: 0),
                                child: Container(
                                  width:
                                      Responsive.isDesktop(context) ? 60 : 60,
                                  child: ElevatedButton(
                                    focusNode: saveallButtonFocusNode,
                                    onPressed: () {
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
                                        // Show error message
                                        print(
                                            "datasssss: ${widget.purchaseInvoiceNoController.text}   ${widget.purchaseSupplierAgentidController.text}    ${widget.tableData}    ${purchaseDisAMountController.text}   ${purchaseRoundOffController.text}    ${purchaseDisPercentageController.text}");

                                        WarninngMessage(context);
                                        return;
                                      }
                                      postDataToAPI(
                                          widget.tableData,
                                          widget
                                              .purchaseRecordNoController.text,
                                          widget.selectedDate);

                                      // _addRowMaterial(
                                      //   widget.tableData,
                                      // );

                                      // print(
                                      //     "Product Category:${widget.ProductCategoryController.text}");
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
                                            vertical: 10, horizontal: 10)),
                                    child: Text('Save',
                                        style: commonWhiteStyle.copyWith(
                                            fontSize: 14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                  width:
                                      Responsive.isDesktop(context) ? 75 : 75,
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
                                            vertical: 10, horizontal: 10)),
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
