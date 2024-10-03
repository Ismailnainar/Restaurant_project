import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

// MaterialColor maincolor = Colors.purple;

class VendorCustomer extends StatefulWidget {
  @override
  _VendorCustomerState createState() => _VendorCustomerState();
}

class _VendorCustomerState extends State<VendorCustomer> {
  List<Map<String, dynamic>> tableData = [];
  bool isUpdateMode = false;

  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;

  String searchText = '';

  Map<String, String> selectedRowData = {};
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _CommisionController = TextEditingController(text: '0');

  late FocusNode _focusNode1;
  late FocusNode _focusNode2;
  late FocusNode _focusNode3;
  late FocusNode _focusNode4;
  late FocusNode _focusNode5;

  @override
  void initState() {
    super.initState();
    fetchData();
    _focusNode1 = FocusNode();
    _focusNode2 = FocusNode();
    _focusNode3 = FocusNode();
    _focusNode4 = FocusNode();
    _focusNode5 = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _CommisionController.dispose();
    _addressController.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    super.dispose();
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
            (data['Name'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/VendorsName/$cusid/';
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
                                              Text(
                                                'Vendor Setting',
                                                style: HeadingStyle,
                                              ),
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
                                    Container(
                                        height: 400,
                                        child: SingleChildScrollView(
                                            child: tableView())),
                                    SizedBox(height: 0),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon:
                                                Icon(Icons.keyboard_arrow_left),
                                            onPressed: hasPreviousPage
                                                ? () => loadPreviousPage()
                                                : null,
                                          ),
                                          SizedBox(width: 5),
                                          Text('$currentPage / $totalPages',
                                              style: commonLabelTextStyle),
                                          SizedBox(width: 5),
                                          IconButton(
                                            icon: Icon(
                                                Icons.keyboard_arrow_right),
                                            onPressed: hasNextPage
                                                ? () => loadNextPage()
                                                : null,
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
                                          Text(
                                            'Vendor Setting',
                                            style: HeadingStyle,
                                          ),
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
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: tableView(),
                                            ),
                                          ),
                                          SizedBox(height: 0),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_left),
                                                  onPressed: hasPreviousPage
                                                      ? () => loadPreviousPage()
                                                      : null,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    '$currentPage / $totalPages',
                                                    style:
                                                        commonLabelTextStyle),
                                                SizedBox(width: 5),
                                                IconButton(
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_right),
                                                  onPressed: hasNextPage
                                                      ? () => loadNextPage()
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
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
      ),
    );
  }

  void _addVendorName() async {
    String name = _nameController.text;
    String address = _addressController.text;
    String contact = _contactController.text;
    String email =
        _emailController.text.isEmpty ? "Null" : _emailController.text;
    String commision = _CommisionController.text;

    if (isNameAlreadyAdded(name)) {
      showDuplicateNameWarning();
      return;
    }
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty) {
      WarninngMessage(context);
      print('Kindly Check your customer details');
    } else {
      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": cusid,
        "Name": name,
        "Address": address,
        "Contact": contact,
        "MailId": email,
        "Commision": commision,
      };

      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/VendorsNamealldata/';
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
      }
      await logreports("Vendor Customer: ${name}_Inserted");
      fetchData();
      successfullySavedMessage(context);
      _clearFormFields();
    }
  }

  bool isNameAlreadyAdded(String? name) {
    return tableData.any((data) => data['Name'] == name);
  }

  void _updateVendorName(String vendorId) async {
    String name = _nameController.text;
    String address = _addressController.text;
    String contact = _contactController.text;
    String email = _emailController.text;
    String commision = _CommisionController.text;

    String? cusid = await SharedPrefs.getCusId();
    // Prepare data to be updated
    Map<String, dynamic> putdata = {
      "cusid": cusid,
      "Name": name,
      "Address": address,
      "Contact": contact,
      "MailId": email,
      "Commision": commision,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putdata);

    // Make PUT request to the API
    String apiUrl = '$IpAddress/VendorsNamealldata/$vendorId/';
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
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }

    await logreports("Vendor Customer: ${name}_Updated");
    fetchData();
    successfullyUpdateMessage(context);
  }

  FocusNode SaveFocus = FocusNode();
  Widget SaveButton() {
    return ElevatedButton(
      focusNode: SaveFocus,
      onPressed: () {
        _addVendorName();
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        backgroundColor: subcolor,
        minimumSize: Size(45.0, 31.0),
      ),
      child: Text('Save', style: commonWhiteStyle),
    );
  }

  String vendorId = '';
  FocusNode UpdateFocus = FocusNode();

  Widget UpdateButton() {
    return ElevatedButton(
      focusNode: UpdateFocus,
      onPressed: () {
        // print("Staff ID for the Selected row in the table : $vendorId");
        _updateVendorName(vendorId);
        _clearFormFields();
        setState(() {
          isUpdateMode = false;
        });
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        backgroundColor: subcolor,
        minimumSize: Size(45.0, 31.0),
      ),
      child: Text('Update', style: commonWhiteStyle),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget staffform() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Name", _nameController, 200, Icons.person,
              _focusNode1, _focusNode2),
          SizedBox(height: 12.0),
          _buildTextField("Address", _addressController, 200,
              Icons.location_city, _focusNode2, _focusNode3),
          SizedBox(height: 12.0),
          _buildTextField("Contact", _contactController, 200, Icons.phone,
              _focusNode3, _focusNode4,
              isNumeric: true),
          SizedBox(height: 12.0),
          _buildTextField("Email", _emailController, 200, Icons.mail,
              _focusNode4, _focusNode5),
          SizedBox(height: 12.0),
          _buildTextField(
              "Commision",
              _CommisionController,
              200,
              Icons.attach_money,
              _focusNode5,
              isUpdateMode ? UpdateFocus : SaveFocus,
              isNumeric: true),
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
    double width,
    IconData icon,
    FocusNode currentFocusNode,
    FocusNode? nextFocusNode, {
    bool isNumeric = false,
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
                Text(
                  label,
                  style: commonLabelTextStyle,
                ),
              ],
            ),
          ),
          Container(
            height: 27,
            width: 170,
            color: Colors.white,
            child: TextFormField(
                onFieldSubmitted: (value) {
                  if (nextFocusNode != null) {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  }
                },
                controller: controller,
                focusNode: currentFocusNode,
                inputFormatters: [
                  if (isNumeric) ...[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade500, width: 1.0),
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
    _emailController.clear();
    _nameController.clear();
    _addressController.clear();
    _contactController.clear();
    // _CommisionController.clear();
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: Responsive.isDesktop(context) ? screenHeight * 0.9 : 400,
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
                padding:
                    const EdgeInsets.only(top: 20.0, right: 15.0, bottom: 20.0),
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
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      contentPadding: EdgeInsets.only(left: 10.0, right: 4.0),
                    ),
                    style: textStyle,
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 50.0,
                          decoration: TableHeaderColor,
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
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
                                  Text(
                                    "Name",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
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
                                  Text(
                                    "Address",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
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
                                  Text(
                                    "Contact",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mail,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "MailId",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    "Comm",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          width: 265.0,
                          decoration: TableHeaderColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
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
                                  Text(
                                    "Actions",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          if (getFilteredData().isNotEmpty)
            ...getFilteredData().map((data) {
              var Name = data['Name'].toString();
              var Address = data['Address'].toString();
              var Contact = data['Contact'].toString();
              var MailId = data['MailId'].toString();
              var Commision = data['Commision'].toString();

              bool isEvenRow = tableData.indexOf(data) % 2 == 0;

              Color? rowColor = isEvenRow
                  ? Color.fromARGB(224, 255, 255, 255)
                  : Color.fromARGB(224, 255, 255, 255);

              return Padding(
                padding: const EdgeInsets.only(
                    top: 2.0, bottom: 2.0, left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        height: Responsive.isDesktop(context) ? 25 : 30,
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
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 500.0,
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        child: Center(
                          child: Text(Name,
                              textAlign: TextAlign.center,
                              style: TableRowTextStyle),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 500.0,
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        child: Center(
                          child: Text(Address,
                              textAlign: TextAlign.center,
                              style: TableRowTextStyle),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 500.0,
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        child: Center(
                          child: Text(Contact,
                              textAlign: TextAlign.center,
                              style: TableRowTextStyle),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 500.0,
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        child: Center(
                          child: Text(MailId,
                              textAlign: TextAlign.center,
                              style: TableRowTextStyle),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 500.0,
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        child: Center(
                          child: Text(Commision,
                              textAlign: TextAlign.center,
                              style: TableRowTextStyle),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 255.0,
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                      vendorId = data['id'].toString();

                                      _nameController.text =
                                          data['Name'].toString();
                                      _addressController.text =
                                          data['Address'].toString();
                                      _contactController.text =
                                          data['Contact'].toString();
                                      _emailController.text =
                                          data['MailId'].toString();
                                      _CommisionController.text =
                                          data['Commision'].toString();
                                      // print(
                                      //     "Staff Selected id from the table displayed corretly or nOt : $vendorId");

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
                                      vendorId = data['id'].toString();
                                    });
                                    _showDeleteConfirmationDialog(
                                        vendorId, Name);
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
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
      String vendorId, String Name) async {
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
                'Are you sure you want to delete ?',
                style: textStyle,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                deletedata(vendorId);

                await logreports("Vendor Customer: ${Name}_Deleted");
                Navigator.pop(context);
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

  void deletedata(String vendorId) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/VendorsNamealldata/$vendorId/';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check response status
    if (response.statusCode == response.statusCode) {
      // Data updated successfully
      print('Data deleted successfully');
      fetchData();
      successfullyDeleteMessage(context);
    } else {
      // Data updating failed
      // print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
  }

  void showDuplicateNameWarning() {
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
                    'Name already exists...!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
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
