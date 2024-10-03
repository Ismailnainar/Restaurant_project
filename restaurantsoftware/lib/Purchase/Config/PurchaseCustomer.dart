import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

class PurchaseCustomerSupplier extends StatefulWidget {
  const PurchaseCustomerSupplier({Key? key}) : super(key: key);

  @override
  State<PurchaseCustomerSupplier> createState() =>
      _PurchaseCustomerSupplierState();
}

class _PurchaseCustomerSupplierState extends State<PurchaseCustomerSupplier> {
  List<Map<String, dynamic>> tableData = [];
  bool isUpdateMode = false;

  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;

  String searchText = '';

  Map<String, String> selectedRowData = {};
  TextEditingController _supplierNameController = TextEditingController();
  TextEditingController _supplierContactController = TextEditingController();
  TextEditingController _supplierAddressController = TextEditingController();
  TextEditingController _suppliergstNoController = TextEditingController();
  TextEditingController _supplieropenBalanceController =
      TextEditingController();

  FocusNode SupplierNameFocusNode = FocusNode();
  FocusNode SupplierContactFocusNode = FocusNode();
  FocusNode SupplierAddressFocusNode = FocusNode();
  FocusNode SupplierGSTFocusNode = FocusNode();
  FocusNode SupplieropenbalanceFocusNode = FocusNode();
  FocusNode suppliersavebuttonfocustode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchserventname();
    _suppliergstNoController.text = '0';
    _supplieropenBalanceController.text = '0';
  }

  double totalAmount = 0.0;

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
            (data['name'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseSupplierNames/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      setState(() {
        tableData = results;
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;
      });
    }
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile layout: Column for both columns
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                    ), // Set border color
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(26),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.account_circle,
                                              size: 40,
                                              color: maincolor,
                                            ),
                                            Text('Supplier Settings',
                                                style: HeadingStyle),
                                          ],
                                        ),
                                        SizedBox(height: 20.0),
                                        staffform()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.0),
                                  Container(child: tableView()),
                                  // SizedBox(height: 0),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(right: 20),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.end,
                                  //     children: [
                                  //       IconButton(
                                  //         icon: Icon(Icons.keyboard_arrow_left),
                                  //         onPressed: hasPreviousPage
                                  //             ? () => loadPreviousPage()
                                  //             : null,
                                  //       ),
                                  //       SizedBox(width: 5),
                                  //       Text(
                                  //         '$currentPage / $totalPages',
                                  //         style: TextStyle(
                                  //           fontSize: 12,
                                  //           fontWeight: FontWeight.bold,
                                  //         ),
                                  //       ),
                                  //       SizedBox(width: 5),
                                  //       IconButton(
                                  //         icon:
                                  //             Icon(Icons.keyboard_arrow_right),
                                  //         onPressed: hasNextPage
                                  //             ? () => loadNextPage()
                                  //             : null,
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Desktop layout: Row for side-by-side columns
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white,
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(26),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_circle,
                                          size: 40,
                                          color:
                                              maincolor, // Change to your color
                                        ),
                                        Text('Supplier Settings',
                                            style: HeadingStyle),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    staffform()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.0),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(child: tableView()),
                                        // SizedBox(height: 0),
                                        // Padding(
                                        //   padding:
                                        //       const EdgeInsets.only(right: 20),
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.end,
                                        //     children: [
                                        //       IconButton(
                                        //         icon: Icon(
                                        //             Icons.keyboard_arrow_left),
                                        //         onPressed: hasPreviousPage
                                        //             ? () => loadPreviousPage()
                                        //             : null,
                                        //       ),
                                        //       SizedBox(width: 5),
                                        //       Text(
                                        //         '$currentPage / $totalPages',
                                        //         style: TextStyle(
                                        //           fontSize: 12,
                                        //           fontWeight: FontWeight.bold,
                                        //         ),
                                        //       ),
                                        //       SizedBox(width: 5),
                                        //       IconButton(
                                        //         icon: Icon(
                                        //             Icons.keyboard_arrow_right),
                                        //         onPressed: hasNextPage
                                        //             ? () => loadNextPage()
                                        //             : null,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> serventname = [];
  List<String> serventcode = [];

  Future<void> fetchserventname() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseSupplierNames/$cusid/';

    while (true) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);
        for (var result in results) {
          String productName = result['serventname'];
          serventname.add(productName);
          String productCode = result['code'];
          serventcode.add(productCode);
        }
      }

      if (jsonData['next'] != null) {
        apiUrl = jsonData['next'];
      } else {
        break;
      }
    }

    // Print the entire list of product names outside the loop
    print(serventname);
  }

  void _addStaffDetails() async {
    bool nameExists = serventname.any((name) =>
        name.toLowerCase() == _supplierContactController.text.toLowerCase());
    bool codeExists = serventcode.any((code) =>
        code.toLowerCase() == _supplierNameController.text.toLowerCase());

    if (_supplierNameController.text.isEmpty ||
        _supplierContactController.text.isEmpty ||
        _supplierAddressController.text.isEmpty ||
        _suppliergstNoController.text.isEmpty ||
        _supplieropenBalanceController.text.isEmpty) {
      WarninngMessage(context);
      // print('Please fill in all fields');
    } else if (nameExists || codeExists) {
      showDuplicateNameWarning();
      // print('Product name already exists');
    } else {
      // All fields are filled, proceed with posting the data
      String name = _supplierNameController.text;
      String contact = _supplierContactController.text;
      String address = _supplierAddressController.text;
      String gstno = _suppliergstNoController.text;
      String balance = _supplieropenBalanceController.text;

      String? cusid = await SharedPrefs.getCusId();
      // Prepare data to be posted
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "name": name,
        "address": address,
        "contact": contact,
        "balance": balance,
        "gstno": gstno
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(postData);

      // Make POST request to the API
      String apiUrl = '$IpAddress/PurchaseSupplierNamesalldatas/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      if (response.statusCode == 201) {
        // Data posted successfully
        print('Data posted successfully');
        successfullySavedMessage(context);
        _clearFormFields();
      } else {
        // Data posting failed
        // print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
    }
    await logreports(
        "Purchase Customer: ${_supplierNameController.text}_Inserted");
    fetchData();
    // successfullySavedMessage(context);
    // _clearFormFields();
  }

  void _updateStaffDetails(String supplierid) async {
    String name = _supplierNameController.text;
    String contact = _supplierContactController.text;
    String address = _supplierAddressController.text;
    String gstno = _suppliergstNoController.text;
    String balance = _supplieropenBalanceController.text;

    // Prepare data to be updated
    String? cusid = await SharedPrefs.getCusId();
    Map<String, dynamic> putdata = {
      "cusid": "$cusid",
      "name": name,
      "address": address,
      "contact": contact,
      "balance": balance,
      "gstno": gstno
    };
    // Convert data to JSON format
    String jsonData = jsonEncode(putdata);

    // Make PUT request to the API
    String apiUrl = '$IpAddress/PurchaseSupplierNamesalldatas/$supplierid/';
    print("update url :$IpAddress/PurchaseSupplierNamesalldatas/$supplierid/ ");
    http.Response response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    // Check response status
    if (response.statusCode == 200) {
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
    await logreports("Purchase Customer: ${name}_Updated");
    successfullyUpdateMessage(context);
    _clearFormFields();
    fetchData();
  }

  Widget SaveButton() {
    return ElevatedButton(
      focusNode: suppliersavebuttonfocustode,
      onPressed: () {
        _addStaffDetails();
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        backgroundColor: subcolor,
        minimumSize: Size(45.0, 31.0), // Set width and height
      ),
      child: Text('Save', style: commonWhiteStyle),
    );
  }

  String supplierid = '';
  Widget UpdateButton() {
    return ElevatedButton(
      onPressed: () {
        // print("Staff ID for the Selected row in the table : $supplierid");
        _updateStaffDetails(supplierid);

        setState(() {
          isUpdateMode = false; // Switch back to save mode after update
        });
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        backgroundColor: subcolor,
        minimumSize: Size(45.0, 31.0), // Set width and height
      ),
      child: Text('Update', style: commonWhiteStyle),
    );
  }

  final _formKey = GlobalKey<FormState>();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget staffform() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
              "Name",
              _supplierNameController,
              SupplierNameFocusNode,
              SupplierContactFocusNode,
              200,
              Icons.person),
          SizedBox(height: 12.0),
          _buildTextField(
              "Contact",
              _supplierContactController,
              SupplierContactFocusNode,
              SupplierAddressFocusNode,
              200,
              Icons.phone,
              isNumeric: true),
          SizedBox(height: 12.0),
          _buildTextField(
              "Address",
              _supplierAddressController,
              SupplierAddressFocusNode,
              SupplierGSTFocusNode,
              200,
              Icons.location_city),
          SizedBox(height: 12.0),
          _buildTextField(
              "GSTNo",
              _suppliergstNoController,
              SupplierGSTFocusNode,
              SupplieropenbalanceFocusNode,
              200,
              Icons.payment),
          SizedBox(height: 20.0),
          _buildTextField(
              "Opening Balance",
              _supplieropenBalanceController,
              SupplieropenbalanceFocusNode,
              suppliersavebuttonfocustode,
              200,
              Icons.attach_money),
          SizedBox(height: 20.0),
          Row(
            children: [
              isUpdateMode ? UpdateButton() : SaveButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    FocusNode nextFocus,
    double width,
    IconData icon, {
    isNumeric = false,
  }) {
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Colors.black,
                ),
                SizedBox(width: 5),
                Text(label, style: commonLabelTextStyle),
              ],
            ),
          ),
          Container(
            height: 24,
            width: 170,
            child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                inputFormatters: [
                  if (isNumeric) ...[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    _fieldFocusChange(context, focusNode, nextFocus),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
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
        ],
      ),
    );
  }

  void _clearFormFields() {
    _supplierNameController.clear();
    _supplierContactController.clear();
    _supplierAddressController.clear();
    _suppliergstNoController.clear();
    _supplieropenBalanceController.clear();
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          decoration: BoxDecoration(),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.63
                    : MediaQuery.of(context).size.width * 1.8,
                height: Responsive.isDesktop(context)
                    ? screenHeight * 0.9
                    : MediaQuery.of(context).size.height,
                // height: Responsive.isDesktop(context)
                //     ? 550
                //     : MediaQuery.of(context).size.height,
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, right: 15.0, bottom: 20.0),
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 10.0, right: 4.0),
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              height: 25,
                              width: 50.0,
                              color: Colors.grey[200],
                              child: Center(
                                  child: Icon(
                                Icons.arrow_downward,
                                color: maincolor,
                                size: 18,
                              )),
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
                              width: 265.0,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_city,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Address",
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
                                    Icon(
                                      Icons.phone,
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
                                      Icons.payment,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("GstNo",
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
                                    Icon(
                                      Icons.attach_money,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("OpenBal",
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
                                    Icon(
                                      Icons.call_to_action,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Actions",
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
                    SizedBox(height: 5),
                    if (getFilteredData().isNotEmpty)
                      ...getFilteredData().map((data) {
                        var name = data['name'].toString();
                        var address = data['address'].toString();
                        var contact = data['contact'].toString();
                        var balance = data['balance'].toString();
                        var gstno = data['gstno'].toString();

                        bool isEvenRow = tableData.indexOf(data) % 2 == 0;

                        Color? rowColor = isEvenRow
                            ? Color.fromARGB(224, 255, 255, 255)
                            : Color.fromARGB(224, 255, 255, 255);

                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                      child: Icon(
                                    Icons.person,
                                    color: subcolor,
                                  )),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(name,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(address,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(contact,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(gstno,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(balance,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.edit_square,
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                supplierid =
                                                    data['id'].toString();
                                                _supplierNameController.text =
                                                    data['name'].toString();
                                                _supplierAddressController
                                                        .text =
                                                    data['address'].toString();
                                                _supplierContactController
                                                        .text =
                                                    data['contact'].toString();
                                                _suppliergstNoController.text =
                                                    data['gstno'].toString();
                                                _supplieropenBalanceController
                                                        .text =
                                                    data['balance'].toString();
                                                // print(
                                                //     "Supplier Selected id from the table displayed corretly or nOt : $supplierid");

                                                isUpdateMode = true;
                                              });
                                            },
                                          ),
                                        ),
                                        Flexible(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                supplierid =
                                                    data['id'].toString();
                                              });
                                              _showDeleteConfirmationDialog(
                                                  supplierid, name);
                                            },
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
                      }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
      String supplierid, String name) async {
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
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              onPressed: () async {
                await logreports("Purchase Customer: ${name}_Deleted");
                deletedata(supplierid);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: sidebartext, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  void deletedata(String supplierid) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/PurchaseSupplierNamesalldatas/$supplierid';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check response status
    if (response.statusCode == 200) {
      // Data updated successfully
      // print('Data updated successfully');
      fetchData();
      successfullyDeleteMessage(context);
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
      fetchData();
      successfullyDeleteMessage(context);
    }
  }

  void showDuplicateNameWarning() {
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
                'This Staff Details is already exist',
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

  void clearSelectedRowData() {
    setState(() {
      selectedRowData.clear();
    });
  }
}
