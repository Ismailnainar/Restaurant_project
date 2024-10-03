import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/constaints.dart';

// MaterialColor maincolor = Colors.purple;

class Sales_TableCount extends StatefulWidget {
  @override
  _Sales_TableCountState createState() => _Sales_TableCountState();
}

class _Sales_TableCountState extends State<Sales_TableCount> {
  List<Map<String, dynamic>> tableData = [];
  bool isUpdateMode = false;

  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;

  String searchText = '';

  Map<String, String> selectedRowData = {};
  TextEditingController _NameController = TextEditingController();
  // TextEditingController _nameController = TextEditingController();
  TextEditingController _TableCountController = TextEditingController();
  TextEditingController _TableCodeController = TextEditingController();

  FocusNode NameFocusNode = FocusNode();
  FocusNode TableCountFocusNode = FocusNode();
  FocusNode TableCodeFocusNode = FocusNode();
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
            (data['name'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Sales_tableCount/$cusid/';
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Icon(
                                                Icons.add_box_outlined,
                                                size: 25,
                                                color:
                                                    maincolor, // Change to your color
                                              ),
                                            ),
                                            Text('Table Count Settings',
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
                            color: Colors.grey[70],
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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.keyboard_arrow_left),
                                          onPressed: hasPreviousPage
                                              ? () => loadPreviousPage()
                                              : null,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '$currentPage / $totalPages',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        IconButton(
                                          icon:
                                              Icon(Icons.keyboard_arrow_right),
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.add_box_outlined,
                                            size: 25,
                                            color:
                                                maincolor, // Change to your color
                                          ),
                                        ),
                                        Text(
                                          'Table Count Settings',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
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
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              color: Colors.grey[70],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20.0),
                                    Column(
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Container(
                                              height:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.36
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.05,
                                              child: SingleChildScrollView(
                                                  child: tableView())),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                    Icons.keyboard_arrow_left),
                                                onPressed: hasPreviousPage
                                                    ? () => loadPreviousPage()
                                                    : null,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '$currentPage / $totalPages',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
  Future<void> fetchserventname() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Sales_tableCount/$cusid/';

    while (true) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<dynamic> results = jsonData['results'];
        for (var result in results) {
          if (result['name'] is String) {
            String productName = result['name'];
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
    bool nameExists = serventname.any(
        (name) => name.toLowerCase() == _NameController.text.toLowerCase());

    if (_NameController.text.isEmpty ||
        _TableCountController.text.isEmpty ||
        _TableCodeController.text.isEmpty) {
      WarninngMessage();
      print('Please fill in all fields');
    } else if (nameExists) {
      showDuplicateNameWarning();
      _NameController.clear();

      print('Product name already exists');
    } else {
      // All fields are filled, proceed with posting the data
      String name = _NameController.text;
      String count = _TableCountController.text;
      String code = _TableCodeController.text;

      // Prepare data to be posted
      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "name": name,
        "count": count,
        "code": code,
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(postData);

      // Make POST request to the API
      String apiUrl = '$IpAddress/Sales_tableCountalldatas/';
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

        fetchData();

        successfullySavedMessage();
        _clearFormFields();
      } else {
        // Data posting failed
        print('Failed to post data: ${response.statusCode}, ${response.body}');

        fetchData();
        successfullySavedMessage();
        _clearFormFields();
      }
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
      String name = _NameController.text;
      String count = _TableCountController.text;
      String code = _TableCodeController.text;

      String? cusid = await SharedPrefs.getCusId();
      // Prepare data to be updated
      Map<String, dynamic> putdata = {
        "cusid": "$cusid",
        "name": name,
        "count": count,
        "code": code
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(putdata);

      // Make PUT request to the API
      String apiUrl = '$IpAddress/Sales_tableCountalldatas/$customerid/';
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
        fetchData();
        successfullyUpdateMessage();
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

  final _formKey = GlobalKey<FormState>();

  Widget staffform() {
    if (Responsive.isMobile(context))
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Name", _NameController, NameFocusNode,
                TableCountFocusNode, 200),
            SizedBox(height: 10),
            _buildTextField("Count", _TableCountController, TableCountFocusNode,
                TableCodeFocusNode, 200),
            SizedBox(height: 10),
            _buildTextField("Code", _TableCodeController, TableCodeFocusNode,
                saveButtonFocusNode, 200),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: isUpdateMode ? UpdateButton() : SaveButton(),
            ),
          ],
        ),
      );
    return Form(
      key: _formKey,
      child: Wrap(
        // crossAxisAlignment: CrossAxisAlignment.start,
        alignment: WrapAlignment.start,
        children: [
          _buildTextField(
              "Name", _NameController, NameFocusNode, TableCountFocusNode, 200),
          SizedBox(width: 10),
          _buildTextField("Count", _TableCountController, TableCountFocusNode,
              TableCodeFocusNode, 200),
          SizedBox(width: 10),
          _buildTextField("Code", _TableCodeController, TableCodeFocusNode,
              saveButtonFocusNode, 200),
          SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: isUpdateMode ? UpdateButton() : SaveButton(),
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

  Widget _buildTextField(String label, TextEditingController controller,
      FocusNode focusNode, FocusNode nextFocusNode, double width) {
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(label, style: commonLabelTextStyle),
          ),
          Container(
            height: 24,
            width: 170,
            color: Colors.grey[100],
            child: TextFormField(
                controller: controller,
                focusNode: focusNode,
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
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
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
    _NameController.clear();
    _TableCountController.clear();
    _TableCodeController.clear();
  }

  Widget tableView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Container(
          height: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.33
              : MediaQuery.of(context).size.height * 0.4,
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        height: 25,
                        width: 50.0,
                        decoration: TableHeaderColor,
                        child: Center(
                            child: Icon(
                          Icons.arrow_downward,
                          color: Colors.blue,
                          size: 15,
                        )),
                      ),
                    ),
                    // Flexible(
                    //   child: Container(
                    //     height: 25,
                    //     width: 255.0,
                    //     decoration: TableHeaderColor,
                    //     child: Center(
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Icon(
                    //             Icons.notes_rounded,
                    //             color: Colors.blue,
                    //             size: 15,
                    //           ),
                    //           SizedBox(
                    //             width: 5,
                    //           ),
                    //           Text("ID",
                    //               textAlign: TextAlign.center,
                    //               style: commonLabelTextStyle),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Flexible(
                      child: Container(
                        height: 25,
                        width: 255.0,
                        decoration: TableHeaderColor,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_2_outlined,
                                color: Colors.blue,
                                size: 15,
                              ),
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
                        width: 255.0,
                        decoration: TableHeaderColor,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.control_point_outlined,
                                color: Colors.blue,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Count",
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
                        width: 255.0,
                        decoration: TableHeaderColor,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.numbers_outlined,
                                color: Colors.blue,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Code",
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
                        width: 255.0,
                        decoration: TableHeaderColor,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.blue,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Action",
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

                  var name = data['name'].toString();
                  var count = data['count'].toString();
                  var code = data['code'].toString();

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
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 50.0,
                            decoration: BoxDecoration(
                              color: rowColor,
                            ),
                            child: Center(
                                child: Icon(
                              Icons.person,
                              color: subcolor,
                            )),
                          ),
                        ),
                        // Flexible(
                        //   child: Container(
                        //     height: Responsive.isDesktop(context) ? 25 : 30,
                        //     width: 255.0,
                        //     color: rowColor,
                        //     child: Center(
                        //       child: Text(id,
                        //           textAlign: TextAlign.center,
                        //           style: TableRowTextStyle),
                        //     ),
                        //   ),
                        // ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 255.0,
                            color: rowColor,
                            child: Center(
                              child: Text(name,
                                  textAlign: TextAlign.center,
                                  style: TableRowTextStyle),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 255.0,
                            color: rowColor,
                            child: Center(
                              child: Text(count,
                                  textAlign: TextAlign.center,
                                  style: TableRowTextStyle),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 255.0,
                            color: rowColor,
                            child: Center(
                              child: Text(code,
                                  textAlign: TextAlign.center,
                                  style: TableRowTextStyle),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 255.0,
                            color: rowColor,
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
                                          customerid = data['id'].toString();
                                          _NameController.text =
                                              data['name'].toString();
                                          _TableCountController.text =
                                              data['count'].toString();
                                          _TableCodeController.text =
                                              data['code'].toString();

                                          // print(
                                          //     "selected birth date : $selectedBirthDate");
                                          // print(
                                          //     "selected Marriage date : $selectMarriageDate");
                                          // print(
                                          //     "Staff Selected id from the table displayed corretly or nOt : $customerid");

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
                                          customerid = data['id'].toString();
                                        });
                                        _showDeleteConfirmationDialog(
                                            customerid);
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
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(String customerid) async {
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
    String apiUrl = '$IpAddress/Sales_tableCountalldatas/$customerid/';
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
