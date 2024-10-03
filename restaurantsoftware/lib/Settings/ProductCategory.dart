import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Settings/PrinterDetails.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(ProductCategory());
}

class ProductCategory extends StatefulWidget {
  @override
  _ProductCategoryState createState() => _ProductCategoryState();
}

class _ProductCategoryState extends State<ProductCategory> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchProductCategory();
    fetchCategories();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      return tableData;
    }

    String searchTextLower = searchText.toLowerCase();

    List<Map<String, dynamic>> filteredData = tableData
        .where((data) =>
            (data['cat'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  Future<void> fetchProductCategory() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/Settings_ProductCategory/$cusid/?page=$currentPage&size=$pageSize';
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

  TextEditingController _idController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  final TextEditingController _productCategoryController =
      TextEditingController();
  String Productid = '';
  String productcategory = '';
  String PrinterName = "";

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
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Category',
                          style: HeadingStyle,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Manage and view product categories with ease.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _showFormDialog(context, Productid,
                                    productcategory, PrinterName, false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: subcolor,
                                minimumSize: Size(20.0, 31.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.zero, // Set radius to zero
                                ),
                              ),
                              child: Text(
                                'New +',
                                style: commonWhiteStyle,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Container(
                                height: 30,
                                width: 130,
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
                                      contentPadding: EdgeInsets.only(
                                          left: 10.0, right: 4.0),
                                    ),
                                    style: DropdownTextStyle),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _buildTable(),
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
                              Text('$currentPage / $totalPages',
                                  style: commonLabelTextStyle),
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
            ),
          ],
        ),
      ),
    );
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchProductCategory();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchProductCategory();
  }

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      height: Responsive.isDesktop(context) ? screenHeight * 0.7 : 400,
      child: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10, top: 13, bottom: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    height: Responsive.isDesktop(context) ? 25 : 30,
                    decoration: TableHeaderColor,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category,
                              size: 15,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 5),
                            Text("ProductCat",
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
                    decoration: TableHeaderColor,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.print,
                              size: 15,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 5),
                            Text("Print Name",
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
                    decoration: TableHeaderColor,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                ),
              ],
            ),
          ),
          if (getFilteredData().isNotEmpty)
            ...getFilteredData().map((data) {
              var Productid = data['id'].toString();
              var productcategory = data['cat'].toString();
              var PrinterName = data['type'].toString();
              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
              Color? rowColor = isEvenRow
                  ? Color.fromARGB(224, 255, 255, 255)
                  : Color.fromARGB(224, 255, 255, 255);

              return GestureDetector(
                onTap: () {
                  // Open dialog with selected data
                  _showFormDialog(
                      context, Productid, productcategory, PrinterName, true);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: rowColor,
                            border: Border.all(
                              color: Color.fromARGB(255, 226, 225, 225),
                            ),
                          ),
                          child: Center(
                            child: Text(productcategory,
                                textAlign: TextAlign.center,
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
                              color: Color.fromARGB(255, 226, 225, 225),
                            ),
                          ),
                          child: Center(
                            child: Text(PrinterName,
                                textAlign: TextAlign.center,
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
                              color: Color.fromARGB(255, 226, 225, 225),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_square,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    // Open dialog with selected data
                                    _showFormDialog(context, Productid,
                                        productcategory, PrinterName, true);
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
              );
            }).toList()
        ]),
      ),
    );
  }

  FocusNode ButtonFocus = FocusNode();

  void _showFormDialog(BuildContext context, String Productid,
      String productCategory, String PrinterName, bool isUpdate) {
    _productCategoryController.text = productCategory;
    _printNameController.text =
        PrinterName; // Initialize _printNameController with PrinterName
    _selectedPrinterName = PrinterName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 100,
            padding: EdgeInsets.only(left: 50.0, bottom: 10),
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
                SizedBox(height: 20),
                _buildDropdownMenu(
                    'Printer Name', _selectedPrinterName, _printerNameList,
                    (String? value) {
                  setState(() {
                    _selectedPrinterName = value ?? '';
                  });
                }),
                _buildTextField('Product Category', _productCategoryController,
                    readOnly: isUpdate),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      focusNode: ButtonFocus,
                      onPressed: () {
                        if (isUpdate) {
                          _updateItem(
                              Productid, productCategory, _selectedPrinterName);
                          fetchProductCategory();
                          Navigator.pop(context);
                        } else {
                          _addItem();
                          fetchProductCategory();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        minimumSize: Size(45.0, 31.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Set radius to zero
                        ),
                      ),
                      child: Text(
                        isUpdate ? 'Update' : 'Add',
                        style: commonWhiteStyle,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _selectedPrinterName = '';
  List<String> _printerNameList = [];

  Future<void> fetchCategories() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/Settings_PrinterDetails/$cusid/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _printerNameList = data
          .where((item) => item['name'] != 'SalesPrinter')
          .map<String>((item) => item['name'])
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void _addItem() async {
    if (_productCategoryController.text.isEmpty) {
      WarninngMessage(context);
      return;
    }

    String? cusid = await SharedPrefs.getCusId();
    String category = _productCategoryController.text.trim().toLowerCase();

    String fetchApiUrl = '$IpAddress/SettingsProductCategory/';
    http.Response fetchResponse = await http.get(Uri.parse(fetchApiUrl));

    if (fetchResponse.statusCode == 200) {
      print('API Response: ${fetchResponse.body}');

      List<dynamic> categories;
      try {
        Map<String, dynamic> responseJson = jsonDecode(fetchResponse.body);
        if (responseJson.containsKey('results')) {
          categories = responseJson['results'];
          if (categories is! List) {
            throw Exception('Results key does not contain a list');
          }
        } else {
          throw Exception('Response does not contain results key');
        }
      } catch (e) {
        print('Failed to parse categories: $e');
        return;
      }

      // Check if the category already exists (case-insensitive)
      bool categoryExists = categories.any((cat) {
        if (cat is Map<String, dynamic> && cat.containsKey('cat')) {
          return cat['cat'].toString().toLowerCase() == category;
        }
        return false;
      });

      if (categoryExists) {
        WarninngAlreadyExistMessage(context);
        return;
      } else {
        // Proceed to add the category
        Map<String, dynamic> postData = {
          "cusid": cusid,
          'cat': _productCategoryController.text.trim(),
          'type':
              _selectedPrinterName.isNotEmpty ? _selectedPrinterName : 'Null',
        };

        String jsonData = jsonEncode(postData);
        http.Response postResponse = await http.post(
          Uri.parse(fetchApiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        if (postResponse.statusCode == 201) {
          Navigator.pop(context);
          print('Data posted successfully');
          await logreports(
              "Product Category: ${_productCategoryController.text.trim()}_${_selectedPrinterName.isNotEmpty ? _selectedPrinterName : 'Null'}_Inserted");
          successfullySavedMessage(context);
          fetchProductCategory();
        } else {
          print(
              'Failed to post data: ${postResponse.statusCode}, ${postResponse.body}');
        }
      }
    } else {
      print(
          'Failed to fetch categories: ${fetchResponse.statusCode}, ${fetchResponse.body}');
    }
  }

  void WarninngAlreadyExistMessage(context) {
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
                    'Category already exists..!!',
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
  }

  void _updateItem(
    String Productid,
    String productcategory,
    String _selectedPrinterName,
  ) async {
    // Prepare data to be updated
    String? cusid = await SharedPrefs.getCusId();
    Map<String, dynamic> putData = {
      "cusid": "$cusid",
      'cat': _productCategoryController.text,
      'type': _selectedPrinterName.isNotEmpty ? _selectedPrinterName : 'Null',
    };
    // print("Product Category: ${_productCategoryController.text}");
    // print("Printer Name: ${_selectedPrinterName}");

    // Convert data to JSON format
    String jsonData = jsonEncode(putData);

    // Make PUT request to the API with the Productid
    String apiUrl = '$IpAddress/SettingsProductCategory/$Productid/';
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
      successfullyUpdateMessage(context);
      fetchProductCategory();
    } else {
      // Data updating failed
      print('Failed to update data ${response.statusCode}, ${response.body}');
      successfullyUpdateMessage(context);
      fetchProductCategory();
    }
    await logreports(
        "Product Category: ${_productCategoryController.text}_${_selectedPrinterName.isNotEmpty ? _selectedPrinterName : 'Null'}_Updated");
    fetchProductCategory();
  }

  void _deleteItem(String Productid) async {
    try {
      // print("product Id : $Productid");
      int id = int.parse(Productid);
      //   print(id);
      String apiUrl = '$IpAddress/SettingsProductCategory/$id';
      http.Response response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // Check response status
      if (response.statusCode == 200) {
        // Data deleted successfully
        print('Data deleted successfully');
        fetchProductCategory();
      } else if (response.statusCode == 405) {
        // Method not allowed (DELETE request is not supported)
        print(
            'Method not allowed: DELETE request is not supported for this endpoint');
      } else {
        // Data deletion failed for other reasons
        print('Failed to delete data ${response.statusCode}, ${response.body}');
        fetchProductCategory();
      }
    } catch (e) {
      // Handle any exceptions or errors
      print('Failed to delete data: $e');
    }
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String productCategory,
    String Productid,
    Function() onDeleteConfirmed,
  ) {
    showDialog(
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
          content: Text(
            "Are you sure you want to delete the $productCategory?",
            style: commonLabelTextStyle,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 5),
              child: ElevatedButton(
                onPressed: () {
                  _deleteItem(Productid);
                  Navigator.of(context).pop();
                  onDeleteConfirmed(); // Call the callback function after deletion confirmation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: subcolor,
                  minimumSize: Size(30.0, 28.0), // Set width and height
                ),
                child: Text(
                  'Delete',
                  style: commonWhiteStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownMenu(String labelText, String selectedValue,
      List<String> items, void Function(String?)? onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: commonLabelTextStyle,
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 24,
                  width: 150,
                  child: Dropdown(),
                );
              }),
              InkWell(
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Container(
                          width: 1150,
                          height: 800,
                          padding: EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              printerdetails(),
                              Positioned(
                                right: 0.0,
                                top: 0.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchCategories();
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
            ],
          ),
        ],
      ),
    );
  }

  final TextEditingController _printNameController = TextEditingController();
  FocusNode _PrintFocusMode = FocusNode();

  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  Widget Dropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                _printerNameList.indexOf(_printNameController.text);
            if (currentIndex < _printerNameList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                _printNameController.text = _printerNameList[currentIndex + 1];
                _filterEnabled = false;
                _selectedPrinterName = _printNameController.text;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                _printerNameList.indexOf(_printNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                _printNameController.text = _printerNameList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: _PrintFocusMode,
          controller: _printNameController,
          onSubmitted: (_) =>
              _fieldFocusChange(context, _PrintFocusMode, productCategoryFocus),
          decoration: InputDecoration(
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
              _filterEnabled = true;
              _selectedPrinterName = text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          // Always return the full list of items
          return _printerNameList;
        },
        itemBuilder: (context, suggestion) {
          final index = _printerNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
                          _printerNameList.indexOf(_printNameController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(suggestion, style: DropdownTextStyle),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            _printNameController.text = suggestion;
            _selectedPrinterName = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(productCategoryFocus);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: commonLabelTextStyle,
          ),
        ),
      ),
    );
  }

  FocusNode productCategoryFocus = FocusNode();

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: commonLabelTextStyle,
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Container(
                height: 24,
                width: 150,
                child: TextField(
                  focusNode: productCategoryFocus,
                  controller: controller,
                  onSubmitted: (_) {
                    _fieldFocusChange(
                        context, productCategoryFocus, ButtonFocus);
                  },
                  keyboardType: TextInputType.text,
                  readOnly: readOnly,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 7.0,
                    ),
                  ),
                  style: readOnly
                      ? DropdownTextStyle.copyWith(color: Colors.grey)
                      : DropdownTextStyle,
                ),
              ),
            ],
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

  // void _addItem() {
  //   // Implement your logic to add an item
  //   setState(() {
  //     int id = tableData.length + 1;
  //     String name = _nameController.text;
  //     double price = double.parse(_priceController.text);
  //     tableData.add({'id': id, 'name': name, 'price': price});
  //     _clearForm();
  //   });
  // }

  // void _updateItem() {
  //   // Implement your logic to update an item
  //   setState(() {
  //     int id = int.parse(_idController.text);
  //     String name = _nameController.text;
  //     double price = double.parse(_priceController.text);
  //     int index = data.indexWhere((item) => item['id'] == id);
  //     if (index != -1) {
  //       data[index] = {'id': id, 'name': name, 'price': price};
  //       _clearForm();
  //     }
  //   });
  // }

  // void _deleteItem() {
  //   // Implement your logic to delete an item
  //   setState(() {
  //     int id = int.parse(_idController.text);
  //     int index = data.indexWhere((item) => item['id'] == id);
  //     if (index != -1) {
  //       data.removeAt(index);
  //       _clearForm();
  //     }
  //   });
  // }

  void _clearForm() {
    _idController.clear();
    _nameController.clear();
    _productCategoryController.clear();
  }
}
