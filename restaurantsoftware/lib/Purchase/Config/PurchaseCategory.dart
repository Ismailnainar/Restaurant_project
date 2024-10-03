import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'dart:convert';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';

void main() {
  runApp(PurchaseProductCategory());
}

class PurchaseProductCategory extends StatefulWidget {
  @override
  State<PurchaseProductCategory> createState() =>
      _PurchaseProductCategoryState();
}

class _PurchaseProductCategoryState extends State<PurchaseProductCategory> {
  final TextEditingController _paymentMethodController =
      TextEditingController();
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int number = 0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchAllProductNames();
  }

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

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['name'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/PurchaseProductCategory/$cusid/?page=$currentPage&size=$pageSize';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);
    // print(response.body);

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
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purchase Product Category', style: HeadingStyle),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildAddButton(),
                        SizedBox(width: 5),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 10.0, top: 20.0),
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
                    Divider(
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: Responsive.isDesktop(context)
                          ? screenHeight * 0.75
                          : 440,
                      // width: Responsive.isDesktop(context)?:,

                      // height: Responsive.isDesktop(context) ? 465 : 440,
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
                      padding: EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Flexible(
                                //   child: Container(
                                //     height:
                                //         Responsive.isDesktop(context) ? 25 : 30,
                                //     decoration: TableHeaderColor,
                                //     child: Center(
                                //       child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           Icon(
                                //             Icons.numbers,
                                //             size: 15,
                                //             color: Colors.blue,
                                //           ),
                                //           SizedBox(width: 5),
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
                                    width: 800.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    width: 800.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete,
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
                          if (getFilteredData().isNotEmpty)
                            ...getFilteredData().map((data) {
                              var Productid = data['id'].toString();
                              var name = data['name'].toString();
                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10, top: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Flexible(
                                    //   child: Container(
                                    //     height: 30,
                                    //     width: 500.0,
                                    //     decoration: BoxDecoration(
                                    //       color: rowColor,
                                    //       border: Border.all(
                                    //         color: Color.fromARGB(
                                    //             255, 226, 225, 225),
                                    //       ),
                                    //     ),
                                    //     child: Center(
                                    //       child: Text(Productid,
                                    //           textAlign: TextAlign.center,
                                    //           style: TableRowTextStyle),
                                    //     ),
                                    //   ),
                                    // ),
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: 800.0,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
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
                                        height: 30,
                                        width: 800.0,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  context, Productid, name);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          SizedBox(height: 0),
                        ]),
                      ),
                    ),
                    SizedBox(height: 5),
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed:
                                hasNextPage ? () => loadNextPage() : null,
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
      ),
    );
  }

  String Productid = '';

  void _showFormDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 150,
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                _buildTextField(),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> productNames = [];
  Future<void> fetchAllProductNames() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductCategory/$cusid/';

    while (true) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);
        for (var result in results) {
          String productName = result['name'];
          productNames.add(productName);
        }
      }

      if (jsonData['next'] != null) {
        apiUrl = jsonData['next'];
      } else {
        break;
      }
    }

    print(productNames);
  }

  void _addCategory() async {
    if (PurchaseProductCategoryController.text.isEmpty) {
      WarninngMessage(context);
    } else if (productNames.any((name) =>
        name.toLowerCase() ==
        PurchaseProductCategoryController.text.toLowerCase())) {
      AlreadyExistWarninngMessage();

      print('Product name already exists');
    } else {
      String Category = PurchaseProductCategoryController.text;

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "name": Category,
      };

      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/PurchaseProductCategoryalldatas/';
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
        await logreports("Purchase ProductCategory: ${Category}_Inserted");
        successfullySavedMessage(context);
        PurchaseProductCategoryController.clear();
        fetchData();
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
    }
  }

  TextEditingController PurchaseProductCategoryController =
      TextEditingController();
  FocusNode _paymenttypeFocusNode = FocusNode();

  Widget _buildTextField() {
    return Container(
      width: 220,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Name', style: commonLabelTextStyle),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 24,
                width: 135,
                child: TextField(
                    onSubmitted: (value) {
                      _addCategory();
                      Navigator.pop(context);
                    },
                    autofocus: true,
                    focusNode: _paymenttypeFocusNode,
                    controller: PurchaseProductCategoryController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 7.0,
                      ),
                    ),
                    style: textStyle),
              ),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                onPressed: () {
                  _addCategory();
                  // PurchaseProductCategoryController.clear();
                  // Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: subcolor,
                    minimumSize: Size(45.0, 31.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                child: Text('Save', style: commonWhiteStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: () {
          _showFormDialog(context);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          backgroundColor: subcolor,
          minimumSize: Size(45.0, 31.0), // Set width and height
        ),
        child: Text('Add +', style: commonWhiteStyle),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext context, String Productid, String name) async {
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
              onPressed: () async {
                await logreports("Purchase ProductCategory: ${name}_Deleted");

                deletedata(Productid!);
                Navigator.pop(context);
                // successfullyDeleteMessage(context);
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

  void deletedata(String Productid) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/PurchaseProductCategoryalldatas/$Productid';
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
      successfullyDeleteMessage(context);
    } else {
      // Data updating failed
      // print('Failed to update data: ${response.statusCode}, ${response.body}');
      fetchData();
    }
  }

  void AlreadyExistWarninngMessage() {
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
                'This Product name is already exists',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
  }
}
