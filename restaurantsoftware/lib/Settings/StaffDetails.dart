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

class StaffDetailsPage extends StatefulWidget {
  @override
  _StaffDetailsPageState createState() => _StaffDetailsPageState();
}

class _StaffDetailsPageState extends State<StaffDetailsPage> {
  bool isUpdateMode = false;
  int currentPage = 1; // Start from page 1
  int pageSize = 10; // Number of items per page
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 0;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> AlltableData = [];

  String searchText = '';

  Map<String, String> selectedRowData = {};
  TextEditingController _staffCodeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchHoleData();

    fetchserventname();
  }

  double totalAmount = 0.0;
  void loadNextPage() {
    if (hasNextPage) {
      setState(() {
        currentPage++;
      });
      fetchData();
    } else {
      print('No next page available'); // Debug print
    }
  }

  void loadPreviousPage() {
    if (hasPreviousPage && currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchData();
    } else {
      print('No previous page available or at the first page'); // Debug print
    }
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      return tableData;
    }

    String searchTextLower = searchText.toLowerCase();

    List<Map<String, dynamic>> filteredData = tableData
        .where((data) =>
            (data['serventname'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String apiUrl =
          '$IpAddress/StaffDetails/$cusid/?page=$currentPage&page_size=$pageSize';
      print('Fetching data from: $apiUrl'); // Debug print

      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
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
        } else {
          print('No results found'); // Debug print
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchHoleData() async {
    String apiUrl = '$IpAddress/StaffDetailsalldatas/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      setState(() {
        AlltableData = results;
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;
      });
    }
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
                                                color:
                                                    maincolor, // Change to your color
                                              ),
                                              Text(
                                                'Staff Details',
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
                                          Text(
                                            '$currentPage / $totalPages',
                                            style: commonLabelTextStyle,
                                          ),
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
                                            color:
                                                maincolor, // Change to your color
                                          ),
                                          Text(
                                            'Staff Details',
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
                                                  style: commonLabelTextStyle,
                                                ),
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

  List<String> serventname = [];
  List<String> serventcode = [];

  Future<void> fetchserventname() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/StaffDetails/$cusid/';

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

  bool _isProcessing = false; // Add this flag at the class level

  void _addStaffDetails() async {
    if (_isProcessing) return; // Prevents re-entry if already processing
    _isProcessing = true; // Set the flag to indicate processing is ongoing

    // Ensure the lists are up-to-date
    await fetchData();

    // Check for existing names and codes
    bool codeExists = serventcode.any(
      (code) => code.toLowerCase() == _staffCodeController.text.toLowerCase(),
    );

    if (_staffCodeController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty) {
      WarninngMessage(context);
      print('Please fill in all fields');
    } else if (codeExists) {
      showDuplicateNameWarning();
      print('Staff name or code already exists');
    } else {
      String staffcode = _staffCodeController.text;
      String staffname = _nameController.text;
      String staffaddress = _addressController.text;
      String staffcontact = _contactController.text;

      String? cusid = await SharedPrefs.getCusId();

      // Prepare data to be posted
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "code": staffcode,
        "serventname": staffname,
        "address": staffaddress,
        "contact": staffcontact,
        "username": "null",
        "pwd": "null",
        "status": "Active",
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(postData);

      // Make POST request to the API
      String apiUrl = '$IpAddress/StaffDetailsalldatas/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      if (response.statusCode == 201) {
        print('Data posted successfully');
        await logreports("Staff Details: ${staffname}_Inserted");

        await fetchData();
        await fetchHoleData();
        successfullySavedMessage(context);
        _clearFormFields();
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
    }

    _isProcessing = false; // Reset the flag once processing is complete
  }

  void _updateStaffDetails(String staffid) async {
    String staffcode = _staffCodeController.text;
    String staffname = _nameController.text;
    String staffaddress = _addressController.text;
    String staffcontact = _contactController.text;
    String? cusid = await SharedPrefs.getCusId();
    // Prepare data to be updated
    Map<String, dynamic> putdata = {
      "cusid": "$cusid",
      "code": staffcode,
      "serventname": staffname,
      "address": staffaddress,
      "contact": staffcontact,
      // "username": "null",
      // "pwd": "null",
      "status": "Active"
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putdata);

    // Make PUT request to the API
    String apiUrl = '$IpAddress/StaffDetailsalldatas/$staffid/';
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
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
    await logreports("Staff Details: ${staffname}_Updated");

    await fetchData();
    await fetchHoleData();
    successfullyUpdateMessage(context);
  }

  void checkCodeExists() async {
    await fetchData();

    bool codeExists = serventcode.any((code) =>
        code.toLowerCase() == _staffCodeController.text.toLowerCase());

    if (codeExists) {
      showDuplicateNameWarning();
      _staffCodeController.text = "";
      FocusScope.of(context).requestFocus(_staffCodeFocusNode);

      print('Staff code already exists');
    } else {
      print('Staff code is unique');
    }
  }

  FocusNode SavebuttonFocus = FocusNode();

  Widget SaveButton() {
    return ElevatedButton(
      focusNode: SavebuttonFocus,
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

  String staffid = '';
  FocusNode UpdatebuttonFocus = FocusNode();
  Widget UpdateButton() {
    return ElevatedButton(
      focusNode: UpdatebuttonFocus,
      onPressed: () {
        _updateStaffDetails(staffid);
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
        minimumSize: Size(45.0, 31.0), // Set width and height
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
          _buildTextField(
            "Staff Code",
            _staffCodeController,
            200,
            Icons.numbers,
            _staffCodeFocusNode,
            _nameFocusNode,
          ),
          SizedBox(height: 12.0),
          _buildTextField(
            "Staff Name",
            _nameController,
            200,
            Icons.person,
            _nameFocusNode,
            _addressFocusNode,
          ),
          SizedBox(height: 12.0),
          _buildTextField(
            "Address",
            _addressController,
            200,
            Icons.location_city,
            _addressFocusNode,
            _contactFocusNode,
          ),
          SizedBox(height: 12.0),
          _buildTextField(
              "Contact",
              _contactController,
              200,
              Icons.phone,
              _contactFocusNode,
              isUpdateMode ? UpdatebuttonFocus : SavebuttonFocus,
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

  FocusNode _staffCodeFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();
  FocusNode _contactFocusNode = FocusNode();

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
              controller: controller,
              focusNode: currentFocusNode,
              inputFormatters: [
                if (isNumeric) ...[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ],
              textInputAction: nextFocusNode != null
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (value) {
                if (label == "Staff Code") {
                  checkCodeExists();
                }
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                }
              },
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
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _clearFormFields() {
    _staffCodeController.clear();
    _nameController.clear();
    _addressController.clear();
    _contactController.clear();
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: Responsive.isDesktop(context) ? screenHeight * 0.9 : 490,
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
              padding: const EdgeInsets.only(left: 0.0, right: 0),
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
                                    Icons.numbers,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 2),
                                  Text("Code",
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
                                  SizedBox(width: 2),
                                  Text("Name",
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
                                  SizedBox(width: 2),
                                  Text("Address",
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
                                  SizedBox(width: 2),
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
                                    Icons.star_rate,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 2),
                                  Text("Status",
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
                                  SizedBox(width: 2),
                                  Text("Actions",
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
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          if (getFilteredData().isNotEmpty)
            ...getFilteredData().map((data) {
              var code = data['code'].toString();
              var serventname = data['serventname'].toString();
              var address = data['address'].toString();
              var contact = data['contact'].toString();
              var status = data['status'].toString();

              bool isEvenRow = tableData.indexOf(data) % 2 == 0;

              Color? rowColor = isEvenRow
                  ? Color.fromARGB(224, 255, 255, 255)
                  : Color.fromARGB(224, 255, 255, 255);

              return Padding(
                padding: const EdgeInsets.only(top: 2),
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
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border.all(
                            color: Color.fromARGB(255, 226, 225, 225),
                          ),
                        ),
                        height: Responsive.isDesktop(context) ? 25 : 30,
                        width: 255.0,
                        child: Center(
                          child: Text(
                            code,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                          ),
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
                          child: Text(
                            serventname,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                          ),
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
                          child: Text(
                            address,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                          ),
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
                          child: Text(
                            contact,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                          ),
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
                          child: Text(
                            status,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                          ),
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
                                      staffid = data['id'].toString();
                                      _staffCodeController.text =
                                          data['code'].toString();
                                      _nameController.text =
                                          data['serventname'].toString();
                                      _addressController.text =
                                          data['address'].toString();
                                      _contactController.text =
                                          data['contact'].toString();
                                      // print(
                                      // "Staff Selected id from the table displayed corretly or nOt : $staffid");

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
                                      staffid = data['id'].toString();
                                    });
                                    _showDeleteConfirmationDialog(staffid);
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

  Future<bool?> _showDeleteConfirmationDialog(String staffid) async {
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
                deletedata(staffid);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete', style: commonWhiteStyle),
            ),
          ],
        );
      },
    );
  }

  void deletedata(String staffid) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/StaffDetailsalldatas/$staffid/';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    String staffname = _nameController.text;

    // Check response status
    if (response.statusCode == response.statusCode) {
      // Data updated successfully
      print('Data Delete successfully');
    } else {
      // Data updating failed
      print('Failed to Delete data: ${response.statusCode}, ${response.body}');

      // successfullyDeletedMessage();
    }
    await logreports("Staff Details: ${staffname}_Deleted");

    await fetchData();
    await fetchHoleData();

    successfullyDeleteMessage(context);
  }

  void showDuplicateNameWarning() {
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
                    ' Your scode already exists..!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

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
