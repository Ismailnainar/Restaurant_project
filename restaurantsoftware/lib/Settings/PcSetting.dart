import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(PcSetting());
}

class PcSetting extends StatefulWidget {
  @override
  State<PcSetting> createState() => _PcSettingState();
}

class _PcSettingState extends State<PcSetting> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    FetchPcSetting();
  }

  Future<void> createTable() async {
    final String csrfToken = await fetchCsrfToken(); // Fetch CSRF token
    final String url = 'http://$IpAddress/api/create-table/';

    // Prepare headers with CSRF token
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRFToken': csrfToken,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error creating table: $e');
    }
  }

  Future<String> fetchCsrfToken() async {
    final String tokenUrl = 'http://$IpAddress/api/get-csrf-token/';
    try {
      final response = await http.get(Uri.parse(tokenUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['csrf_token'];
      } else {
        throw Exception('Failed to fetch CSRF token');
      }
    } catch (e) {
      print('Error fetching CSRF token: $e');
      return ''; // Return empty string or handle the error accordingly
    }
  }

  Future<void> FetchPcSetting() async {
    String apiUrl = 'http://$IpAddress/PcSetting/';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> Pclist = [];

      for (var item in data) {
        int ID = item['id'];
        String pcname = item['pcname'];
        String code = item['code'];
        String machine = item['machine'];

        Pclist.add({
          'id': ID,
          'pcname': pcname,
          'code': code,
          'machine': machine,
        });
      }

      Pclist.sort((a, b) => a['id'].compareTo(b['id']));

      setState(() {
        tableData = Pclist;
      });
    }
  }

  String? selectedAmount;
  String? selectedproduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PC Setting',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildContainer(),
                    SizedBox(height: 15),
                    Container(
                      height: Responsive.isDesktop(context) ? 480 : 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      padding: EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 500.0,
                                    decoration: BoxDecoration(
                                      color: maincolor,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "ID",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 500.0,
                                    decoration: BoxDecoration(
                                      color: maincolor,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Name",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 500.0,
                                    decoration: BoxDecoration(
                                      color: maincolor,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Code",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 500.0,
                                    decoration: BoxDecoration(
                                      color: maincolor,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Machine",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tableData.isNotEmpty)
                            ...tableData.map((data) {
                              var id = data['id'].toString();
                              var pcname = data['pcname'].toString();
                              var code = data['code'].toString();
                              var machine = data['machine'].toString();

                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 3.0,
                                      bottom: 3.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 500.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              id,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: maincolor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 500.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              pcname,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: maincolor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 500.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              code,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: maincolor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 500.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              machine,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: maincolor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()
                        ]),
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

  TextEditingController _CustomerPcNameController = TextEditingController();
  TextEditingController _CodeController = TextEditingController();
  TextEditingController _defaultPcNameController = TextEditingController();

  void _saveDataToAPI() async {
    String? CustomerPcName = _CustomerPcNameController.text;
    String? code = _CodeController.text;
    String? defaultPcName = _defaultPcNameController.text;

    if (CustomerPcName == null ||
        CustomerPcName.isEmpty ||
        code == null ||
        code.isEmpty ||
        defaultPcName == null ||
        defaultPcName.isEmpty) {
      showIncomeEmptyWarning();
      _CustomerPcNameController.text = "";
      _CodeController.text = "";
      _defaultPcNameController.text = "";
      _CustomPCNameFocusNode.requestFocus();

      return;
    }
    if (isCustomNameAlreadyAdded(CustomerPcName)) {
      // Display a warning message
      showDuplicatePaymentTypeWarning();
      _CustomerPcNameController.text = "";
      _CustomPCNameFocusNode.requestFocus();

      return; // Stop further execution
    }
    String apiUrl = 'http://$IpAddress/PcSetting/';
    Map<String, dynamic> postData = {
      'pcname': CustomerPcName,
      'code': code,
      'machine': defaultPcName,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(postData),
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted) {
        // Check if the widget is still mounted before updating the state
        if (response.statusCode == 201) {
          print('Data saved successfully');
          FetchPcSetting();

          createTable();
          successfullySavedMessage();
          _CustomerPcNameController.text = "";
          _CodeController.text = "";
          _defaultPcNameController.text = "";

          _CustomPCNameFocusNode.requestFocus();
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
          // print('Response content: ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error as needed
    }
  }

  bool isCustomNameAlreadyAdded(String? pcname) {
    // Implement the logic to check if the name is already added
    return tableData.any((data) => data['pcname'] == pcname);
  }

  void showDuplicatePaymentTypeWarning() {
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
                'PcName is already exist',
                style: TextStyle(fontSize: 12, color: maincolor),
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

  void showIncomeEmptyWarning() {
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
                'Kindly check your system details.!!!',
                style: TextStyle(fontSize: 12, color: maincolor),
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

  void successfullySavedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'System Details successfully Added..!!',
                style: TextStyle(fontSize: 12, color: Colors.white),
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

  Widget _buildContainer() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // First Textbox
                _buildPcNameTextField("Custom PC Name"),

                // Spacer or SizedBox to add some space between text fields
                SizedBox(width: 5),

                // Second Textbox
                _buildCodeTextField("Code"),
                SizedBox(width: 5),
                _buildDefaultPcNameTextField("Default PC Name"),
                SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _saveDataToAPI();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      backgroundColor: subcolor,
                      minimumSize: Size(35.0, 28.0), // Set width and height
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (Responsive.isMobile(context))
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // Row for Dropdown and First Textbox
                Row(
                  children: [
                    _buildPcNameTextField("Custom PC Name"),
                  ],
                ),

                // Spacer or SizedBox to add some space between rows
                SizedBox(height: 10),

                // Row for Second Textbox
                Row(
                  children: [
                    _buildCodeTextField("Code"),
                    SizedBox(width: 5),
                    _buildDefaultPcNameTextField("Default PC Name"),
                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(top: 22.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _saveDataToAPI();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          backgroundColor: subcolor,
                          minimumSize: Size(35.0, 28.0), // Set width and height
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  FocusNode _CodeFocusNode = FocusNode();

  Widget _buildCodeTextField(String label) {
    return Container(
      width: 150, // Adjust the width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: Responsive.isDesktop(context)
                ? 180
                : MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 23,
              width: 100,
              color: Colors.white,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _CodeController,
                focusNode: _CodeFocusNode,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 7.0,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FocusNode _DefaultPcNameFocus = FocusNode();

  Widget _buildDefaultPcNameTextField(String label) {
    return Container(
      width: 150, // Adjust the width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: Responsive.isDesktop(context)
                ? 180
                : MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 23,
              width: 100,
              color: Colors.white,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _defaultPcNameController,
                focusNode: _DefaultPcNameFocus,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 7.0,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FocusNode _CustomPCNameFocusNode = FocusNode();

  Widget _buildPcNameTextField(String label) {
    return Container(
      width: 180, // Adjust the width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: Responsive.isDesktop(context)
                ? 180
                : MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 23,
              width: 100,
              color: Colors.white,
              child: TextField(
                autofocus: true,
                focusNode: _CustomPCNameFocusNode, // Set autofocus to true
                controller: _CustomerPcNameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 7.0,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
