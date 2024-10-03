import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';

void main() {
  runApp(RawMaterialStockReport());
}

class RawMaterialStockReport extends StatefulWidget {
  @override
  State<RawMaterialStockReport> createState() => _RawMaterialStockReportState();
}

class _RawMaterialStockReportState extends State<RawMaterialStockReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  String? selectedproduct;
// Initialize with a valid value from the list
  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchAllPurchaseProductName();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (selectedProductName == null || selectedProductName!.isEmpty) {
      return tableData;
    }

    return tableData
        .where((data) => (data['name'] ?? '')
            .toLowerCase()
            .contains(selectedProductName!.toLowerCase()))
        .toList();
  }

  Future<void> fetchProductDetails() async {
    String apiUrl =
        'http://$IpAddress/Purchase_ProductDetails/?page=$currentPage&size=$pageSize';
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
        // results.sort((a, b) => a['code'].compareTo(b['code']));
      });
    }
  }

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // color: Subcolor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arrow back icon and text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              'Raw Material Stock Report',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Name',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 27,
                                            width: 150,
                                            child: ProductNamedropdown(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              tableView(),
                              SizedBox(height: 10),
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
                                      icon: Icon(Icons.keyboard_arrow_right),
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
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<String> ProductNameList = [];

  Future<void> fetchAllPurchaseProductName() async {
    try {
      String url = 'http://$IpAddress/Purchase_ProductDetails/';
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

      //  print('All product categories: $ProductCategoryList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController ProductCategoryController = TextEditingController();
  TextEditingController stockValueController = TextEditingController();
  String? selectedProductName;
  bool _isProdNameOptionsVisible = false;
  Widget ProductNamedropdown() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue fruitTextEditingValue) {
        final filteredOptions = ProductNameList.where((String option) {
          return option
              .toLowerCase()
              .contains(fruitTextEditingValue.text.toLowerCase());
        }).toList();

        if (filteredOptions.isEmpty && fruitTextEditingValue.text.isNotEmpty) {
          return ['No items found!!!'];
        }

        return filteredOptions;
      },
      onSelected: (String value) async {
        // debugPrint('You just selected $value');
        setState(() {
          selectedProductName = value;
          ProductCategoryController.text = value;
          _isProdNameOptionsVisible = true;
        });
      },
      displayStringForOption: (String option) => option,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        ProductCategoryController = textEditingController;
        return Container(
          height: 23,
          width: 150,
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.black,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 10, left: 5),
              labelStyle: TextStyle(fontSize: 12),
            ),
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
            onTap: () {
              setState(() {
                if (!_isProdNameOptionsVisible) {
                  _isProdNameOptionsVisible = true;
                }
              });
            },
            onChanged: (value) {
              setState(() {
                _isProdNameOptionsVisible =
                    ProductCategoryController.text.isNotEmpty;
              });
            },
            onSubmitted: (value) {
              onFieldSubmitted();
            },
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        if (_isProdNameOptionsVisible) {
          // Change the condition to check if _isOptionsVisible is true
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 150.0,
                width: 150,
                child: ListView(
                  children: options.map((String option) {
                    return Container(
                      height: 25,
                      child: ListTile(
                        title: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  option,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          onSelected(option);
                          setState(() {
                            _isProdNameOptionsVisible = true;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchProductDetails();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchProductDetails();
  }

  Widget tableView() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? 430 : 350,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 2,
            //     blurRadius: 5,
            //     offset: Offset(0, 3),
            //   ),
            // ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "ProdName",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Stock",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
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
                        var name = data['name'].toString();
                        var stock = data['stock'].toString();
                        bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                        Color? rowColor = isEvenRow
                            ? Color.fromARGB(224, 255, 255, 255)
                            : Color.fromARGB(224, 255, 255, 255);

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0, top: 5.0, bottom: 5.0),
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
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
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
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      stock,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    else ...{
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 60.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/imgs/document.png',
                                  width: 100, // Adjust width as needed
                                  height: 100, // Adjust height as needed
                                ),
                                Center(
                                  child: Text(
                                    'No transactions available to generate report',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    }
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
