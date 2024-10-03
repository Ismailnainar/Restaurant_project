import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

// MaterialColor maincolor = Colors.purple;

class SalesCoutomer extends StatefulWidget {
  @override
  _SalesCoutomerState createState() => _SalesCoutomerState();
}

class _SalesCoutomerState extends State<SalesCoutomer> {
  List<Map<String, dynamic>> tableData = [];
  bool isUpdateMode = false;

  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;

  String searchText = '';

  Map<String, String> selectedRowData = {};
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _Emailidcontrolller = TextEditingController();
  TextEditingController openingbalancezController = TextEditingController();
  TextEditingController _feedbackController = TextEditingController();

  FocusNode NameFocusNode = FocusNode();
  FocusNode AddressFocusNode = FocusNode();
  FocusNode ContactFocusNode = FocusNode();
  FocusNode EmailidFocusnode = FocusNode();
  FocusNode FeedBackFocusNode = FocusNode();
  FocusNode OpenBalanceFocusNode = FocusNode();
  FocusNode DateOfBirthFocusNode = FocusNode();
  FocusNode MarriageDateFocusNode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchserventname();
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
            (data['cusname'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/SalesCustomer/$cusid/';
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (Responsive.isMobile(context)) {
                    // Mobile layout: Column for both columns
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
                                            Text('Customer Settings',
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
                            color: Color.fromARGB(255, 245, 245, 245),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.0),
                                  Container(child: tableView()),
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.48,
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
                                  padding: const EdgeInsets.all(20),
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
                                          Text('Customer Settings',
                                              style: HeadingStyle),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: staffform())
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Container(
                            color: Color.fromARGB(255, 255, 255, 255),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.0),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children: [
                                          SingleChildScrollView(
                                              child: Container(
                                            child: tableView(),
                                          )),
                                        ],
                                      ),
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
    String apiUrl = '$IpAddress/SalesCustomer/$cusid/';

    while (true) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<dynamic> results = jsonData['results'];
        for (var result in results) {
          if (result['cusname'] is String) {
            String productName = result['cusname'];
            serventname.add(productName);
          } else {
            print("Warning: 'cusname' is not a String, skipping.");
          }
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
        name.toLowerCase() == _CustomerNameController.text.toLowerCase());
    bool contactExists = serventname.any((contact) =>
        contact.toLowerCase() == _contactController.text.toLowerCase());

    if (_CustomerNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _feedbackController.text.isEmpty) {
      WarninngMessage();
      // print('Please fill in all fields');
    } else if (nameExists)
      (contactExists) {
        showDuplicateNameWarning();
        showDuplicateContactWarning();

        // print('Product name already exists');
      };
    else {
      // All fields are filled, proceed with posting the data
      String name = _CustomerNameController.text;
      String address = _addressController.text;
      String contact = _contactController.text;

      String openingbalance = openingbalancezController.text;
      String emailid =
          _Emailidcontrolller.text.isEmpty ? "null" : _Emailidcontrolller.text;
      String feedback = _feedbackController.text;

      String? cusid = await SharedPrefs.getCusId();
      // Prepare data to be posted
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "cusname": name,
        "address": address,
        "contact": contact,
        "mailid": emailid,
        "feedback": feedback,
        // "Points": "0.0",
        "dateofbirth": selectedBirthDate,
        "marriagedt": selectMarriageDate,
        "opnamnt": openingbalance.isEmpty ? 0 : openingbalance
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(postData);

      // Make POST request to the API
      String apiUrl = '$IpAddress/SalesCustomeralldatas/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      if (response.statusCode == 200) {
        // Data posted successfully
        print('Data posted successfully');
      } else {
        // Data posting failed
        print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
      await logreports('Sales Customer: ${name}_Inserted');
      await fetchData();

      successfullySavedMessage();
      _clearFormFields();
    }
  }

  Widget SaveButton() {
    return ElevatedButton(
      focusNode: saveButtonFocusNode,
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
      child: Text(
        'Save',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  String customerid = '';
  Widget UpdateButton() {
    return ElevatedButton(
      onPressed: () {
        print("Staff ID for the Selected row in the table : $customerid");
        _updateStaffDetails(customerid);

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
      child: Text(
        'Update',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  void _updateStaffDetails(String customerid) async {
    try {
      String name = _CustomerNameController.text;
      String address = _addressController.text;
      String contact = _contactController.text;

      String openingbalance = openingbalancezController.text;
      String emailid =
          _Emailidcontrolller.text.isEmpty ? "null" : _Emailidcontrolller.text;
      String feedback = _feedbackController.text;

      String? cusid = await SharedPrefs.getCusId();

      print(
          "posted updated datas : $cusid   ,   $name   , $address ,,  $contact  ,   $emailid  ,   $feedback   ,  $selectedBirthDate,    $selectMarriageDate   ,   $openingbalance   ");
      // Prepare data to be updated
      Map<String, dynamic> putdata = {
        "cusid": "$cusid",
        "cusname": name,
        "address": address,
        "contact": contact,
        "mailid": emailid,
        "feedback": feedback,
        "Points": "0.0",
        "dateofbirth": selectedBirthDate,
        "marriagedt": selectMarriageDate,
        "opnamnt": openingbalance
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(putdata);

      // Make PUT request to the API
      String apiUrl = '$IpAddress/SalesCustomeralldatas/$customerid/';
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
        print(
            'Failed to update data: ${response.statusCode}, ${response.body}');
        // You might want to show an error message to the user here.
      }
      await logreports('Sales Customer: ${name}_Updated');
      await fetchData();

      successfullyUpdateMessage();
      _clearFormFields();
    } catch (e) {
      // Handle any exceptions
      print('Error updating data: $e');
      // You might want to show an error message to the user here.
    }
  }

  final _formKey = GlobalKey<FormState>();

  String selectedBirthDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now()); // Initialize selectedDate with correct date format
  String selectMarriageDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now()); // Initialize selectedDate with correct date format

  Widget staffform() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Name", _CustomerNameController, NameFocusNode,
                AddressFocusNode, 200, Icons.person_add_alt),
            SizedBox(height: 20.0),
            _buildTextField("Address", _addressController, AddressFocusNode,
                ContactFocusNode, 200, Icons.note_alt_rounded),
            SizedBox(height: 20.0),
            _buildTextField("Contact", _contactController, ContactFocusNode,
                EmailidFocusnode, 200, Icons.contact_emergency_outlined,
                isNumeric: true),
            SizedBox(height: 20.0),
            _buildTextField("Email ID", _Emailidcontrolller, EmailidFocusnode,
                DateOfBirthFocusNode, 200, Icons.email_outlined),
            SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date-Of-Birth',
                  style: commonLabelTextStyle,
                ),
                SizedBox(height: 5),
                Container(
                  width: Responsive.isDesktop(context)
                      ? 170
                      : MediaQuery.of(context).size.width * 0.50,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 24,
                        width: 140,
                        child: DateTimePicker(
                            key: UniqueKey(),
                            focusNode: DateOfBirthFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _fieldFocusChange(context,
                                DateOfBirthFocusNode, MarriageDateFocusNode),
                            initialValue:
                                selectedBirthDate, // Set initial value to selectedDate as a string
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            dateLabelText: '',
                            onChanged: (val) {
                              setState(() {
                                selectedBirthDate =
                                    val; // Update selectedDate with the new value
                              });
                            },
                            validator: (val) {
                              print(val);
                              return null;
                            },
                            onSaved: (val) {
                              print(val);
                            },
                            style: textStyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Marriage Date', style: commonLabelTextStyle),
                SizedBox(height: 5),
                Container(
                  width: Responsive.isDesktop(context)
                      ? 170
                      : MediaQuery.of(context).size.width * 0.50,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_sharp,
                        size: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 24,
                        width: 140,
                        child: DateTimePicker(
                            key: UniqueKey(),
                            focusNode: MarriageDateFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _fieldFocusChange(context,
                                MarriageDateFocusNode, FeedBackFocusNode),
                            initialValue:
                                selectMarriageDate, // Set initial value to selectedDate as a string
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            dateLabelText: '',
                            onChanged: (val) {
                              setState(() {
                                selectMarriageDate =
                                    val; // Update selectedDate with the new value
                              });
                            },
                            validator: (val) {
                              print(val);
                              return null;
                            },
                            onSaved: (val) {
                              print(val);
                            },
                            style: textStyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            _buildTextField("Feedback", _feedbackController, FeedBackFocusNode,
                OpenBalanceFocusNode, 200, Icons.feed_outlined),
            SizedBox(height: 20.0),
            _buildTextField("Opening Balance", openingbalancezController,
                OpenBalanceFocusNode, saveButtonFocusNode, 200, Icons.balance),
            SizedBox(height: 20.0),
            Row(
              children: [
                isUpdateMode ? UpdateButton() : SaveButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    FocusNode nextFocusNode,
    double width,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label, style: commonLabelTextStyle),
          ),
          Row(
            children: [
              Icon(
                icon, // Use 'icon' variable instead of 'Icons.icon'
                size: 15,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                height: 24,
                width: 150,
                child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    inputFormatters: [
                      if (isNumeric) ...[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ],
                    textInputAction: nextFocusNode != null
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onFieldSubmitted: (_) {
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
                    style: textStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearFormFields() {
    _CustomerNameController.clear();
    _addressController.clear();
    _contactController.clear();
    _Emailidcontrolller.clear();
    _feedbackController.clear();
    openingbalancezController.clear();
    selectedBirthDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    selectMarriageDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
            decoration: BoxDecoration(),
            child: SingleChildScrollView(
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.63
                    : MediaQuery.of(context).size.width * 2.3,
                height: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.45
                    : MediaQuery.of(context).size.height,
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
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              height: 25,
                              color: Colors.grey[200],
                              child: Center(
                                  child: Icon(
                                Icons.arrow_downward,
                                color: Colors.blue,
                                size: 12,
                              )),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(Icons.notes_sharp,
                                        color: Colors.blue, size: 12),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("ID",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(Icons.person_2_outlined,
                                        color: Colors.blue, size: 12),
                                    SizedBox(
                                      width: 5,
                                    ),
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
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_city,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 1,
                                    ),
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
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.contact_emergency,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
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
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.mark_email_read,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Email",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                height: 25,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.feed_outlined,
                                        color: Colors.blue,
                                        size: 12,
                                      ),
                                      SizedBox(
                                        width: 1,
                                      ),
                                      Text("Feedback",
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
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.control_point_duplicate_sharp,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Points",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("DOB",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("MrgDt",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
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
                              height: 25,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
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
                        var id = data['id'].toString();

                        var name = data['cusname'].toString();
                        var address = data['address'].toString();
                        var contact = data['contact'].toString();
                        var mailid = data['mailid'].toString();
                        var feedback = data['feedback'].toString();
                        var points = data['Points'].toString();
                        var birthdate = data['dateofbirth'].toString();
                        var marriagedate = data['marriagedt'].toString();
                        var openingbalance = data['opnamnt'].toString();

                        bool isEvenRow = tableData.indexOf(data) % 2 == 0;

                        Color? rowColor = isEvenRow
                            ? Color.fromARGB(224, 255, 255, 255)
                            : Color.fromARGB(224, 255, 255, 255);

                        return Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
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
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(id,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
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
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(mailid,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(feedback,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(points,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(birthdate,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(marriagedate,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(openingbalance,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
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
                                                customerid =
                                                    data['id'].toString();
                                                _CustomerNameController.text =
                                                    data['cusname'].toString();
                                                _addressController.text =
                                                    data['address'].toString();
                                                _contactController.text =
                                                    data['contact'].toString();
                                                _Emailidcontrolller.text =
                                                    data['mailid'].toString();
                                                _feedbackController.text =
                                                    data['feedback'].toString();
                                                openingbalancezController.text =
                                                    data['opnamnt'].toString();

                                                selectedBirthDate =
                                                    data['dateofbirth']
                                                        .toString();
                                                selectMarriageDate =
                                                    data['marriagedt']
                                                        .toString();
                                                print(
                                                    "selected birth date : $selectedBirthDate");
                                                print(
                                                    "selected Marriage date : $selectMarriageDate");
                                                print(
                                                    "Staff Selected id from the table displayed corretly or nOt : $customerid");

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
                                                customerid =
                                                    data['id'].toString();
                                              });
                                              _showDeleteConfirmationDialog(
                                                  customerid, name);
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
            )),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
      String customerid, String name) async {
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
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                deletedata(customerid);
                logreports('Sales Customer: ${name}_Deleted');
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

  void deletedata(String customerid) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/SalesCustomeralldatas/$customerid';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check response status
    if (response.statusCode == 200) {
      // Data updated successfully
      print('Data updated successfully');
      fetchData();
      successfullyDeletedMessage();
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
      fetchData();
      successfullyDeletedMessage();
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
            side: BorderSide(color: Colors.green, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This Customer Details is already exist',
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void showDuplicateContactWarning() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This Contact Number is already exist',
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void successfullySavedMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Successfully Saved..!!',
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void successfullyDeletedMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Successfully deleted..!!',
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void clearSelectedRowData() {
    setState(() {
      selectedRowData.clear();
    });
  }

  void successfullyUpdateMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Successfully Updated..!!',
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
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
            side: BorderSide(color: Colors.orange, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.orangeAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to Update, Fill all the Feilds',
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

    // Close the dialog automatically after 2 seconds
  }
}
