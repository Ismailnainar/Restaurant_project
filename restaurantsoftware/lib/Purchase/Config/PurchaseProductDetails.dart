import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Purchase/Config/PurchaseCategory.dart';

void main() {
  runApp(PurchaseProductDetails());
}

class PurchaseProductDetails extends StatefulWidget {
  @override
  State<PurchaseProductDetails> createState() => _PurchaseProductDetailsState();
}

class _PurchaseProductDetailsState extends State<PurchaseProductDetails> {
  List<Map<String, dynamic>> tableData = [];
  bool isSwitched = false;

  bool isUpdateMode = false;
  int selectedOption = 1; // Default selected option
  List<bool> isSelected = [];
  TextEditingController _gstCombocontroller = TextEditingController();
  TextEditingController _ProductNameController = TextEditingController();
  TextEditingController _ProductAmountController = TextEditingController();

  FocusNode productnameFocusNode = FocusNode();
  FocusNode productcategoryFocusNode = FocusNode();
  FocusNode AmountFocusNode = FocusNode();
  FocusNode cgstFocusNode = FocusNode();
  FocusNode stockvalueFocusNode = FocusNode();
  FocusNode saveFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  String? selectedValue;
  double totalAmount = 0.0;
  int number = 0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  List<double> sgstPercentages = [0, 2.5, 6, 9, 14]; // List of SGST percentages
  List<bool> isSelectedsgst = []; // Initial state

  List<double> cgstPercentages = [0, 2.5, 6, 9, 14]; // List of SGST percentages
  List<bool> isSelectedcgst = []; // Initial state

  double selectedSgstPercentage = 0;
  double selectedCgstPercentage = 0;
  @override
  void initState() {
    isSelectedcgst = [true, false, false, false, false];
    isSelectedsgst = [true, false, false, false, false];
    super.initState();

    fetchData();
    fetchProductNameList();

    fetchAllProductCategories();
    fetchAllProductNames();
    _ProductAmountController.text = "0.0";
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
        '$IpAddress/PurchaseProductDetails/$cusid/?page=$currentPage&size=$pageSize';
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

  final TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(children: [
        Expanded(
          flex: 10,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text('Purchase Product Details', style: HeadingStyle),
                  SizedBox(
                    height: 0,
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1, //thickness of divider line
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  if (!Responsive.isDesktop(context)) _topMobileDesign(),
                  if (Responsive.isDesktop(context)) _topWebDesign(),
                  SizedBox(
                    height: 7,
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1, //thickness of divider line
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 30.0, top: 5.0, bottom: 5.0),
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
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
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
                  SizedBox(height: 10),
                  tableView(),
                  SizedBox(height: 0),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.keyboard_arrow_left),
                          onPressed:
                              hasPreviousPage ? () => loadPreviousPage() : null,
                        ),
                        SizedBox(width: 5),
                        Text('$currentPage / $totalPages',
                            style: commonLabelTextStyle),
                        SizedBox(width: 5),
                        IconButton(
                          icon: Icon(Icons.keyboard_arrow_right),
                          onPressed: hasNextPage ? () => loadNextPage() : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  bool _isCheckboxChecked = false;
  String? _selectedProduct;
  List<String> productList = []; // List to hold product names

  Future<void> fetchProductNameList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          productList
              .addAll(results.map<String>((item) => item['name'].toString()));
          // print("payment List : $ProductNameList");

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

  FocusNode productCategoryFocus = FocusNode();
  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget ProductDropdownWidget() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = productList.indexOf(_ProductNameController.text);
            if (currentIndex < productList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                _ProductNameController.text = productList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = productList.indexOf(_ProductNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                _ProductNameController.text = productList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: productCategoryFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedValue = suggestion;
              ProductCategoryController.text = suggestion!;
              _filterEnabled = false;
              // _fieldFocusChange(
              //     context, productCategoryFocus, _ProductNameFocus);
            });
          },
          controller: _ProductNameController,
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
          onChanged: (text) {
            setState(() {
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          return productList;
        },
        itemBuilder: (context, suggestion) {
          final index = productList.indexOf(suggestion);
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
                          productList.indexOf(_ProductNameController.text) ==
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
        onSuggestionSelected: (suggestion) {
          setState(() {
            _ProductNameController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
            // FocusScope.of(context).requestFocus(_ProductNameFocus);
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

  Widget _topWebDesign() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isCheckboxChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isCheckboxChecked = value!;
                    });
                  },
                ),
                Text('Product Name', style: commonLabelTextStyle),
              ],
            ),
            SizedBox(height: 5),
            Container(
              width: Responsive.isDesktop(context)
                  ? 150
                  : MediaQuery.of(context).size.width * 0.3,
              child: _isCheckboxChecked
                  ? Container(
                      height: 24,
                      width: 100,
                      child:
                          ProductDropdownWidget()) // Call the dropdown widget here

                  : Container(
                      height: 24,
                      width: 100,
                      child: TextFormField(
                        controller: _ProductNameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle,
                      ),
                    ),
            ),
          ],
        ),
        SizedBox(
          width: 25,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Category', style: commonLabelTextStyle),
            SizedBox(height: 5),
            Row(
              children: [
                Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.1
                      : MediaQuery.of(context).size.width * 0.25,
                  child: Container(
                    height: 24,
                    width: 100,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Container(child: _buildSupplierNameDropdown()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: commonLabelTextStyle),
            SizedBox(height: 5),
            Container(
              width: Responsive.isDesktop(context)
                  ? 110
                  : MediaQuery.of(context).size.width * 0.3,
              child: Container(
                height: 27,
                width: 100,
                child: TextFormField(
                    controller: _ProductAmountController,
                    focusNode: AmountFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _fieldFocusChange(
                        context, AmountFocusNode, saveFocusNode),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
                    style: AmountTextStyle),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        _buildCGst(),
        SizedBox(
          width: 10,
        ),
        _buildSGst(),
        SizedBox(
          width: 10,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: RichText(
                text: TextSpan(
                  style: commonLabelTextStyle,
                  children: [
                    TextSpan(
                        text: 'Stock Check: ', style: commonLabelTextStyle),
                    TextSpan(
                      text: isSwitched ? 'YES' : 'NO',
                      style: TextStyle(
                        color: isSwitched ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: isUpdateMode ? UpdateButton() : SaveButton(),
        ),
      ],
    );
  }

  Widget _topMobileDesign() {
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Name',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 5),
                Container(
                  width: Responsive.isDesktop(context)
                      ? 150
                      : MediaQuery.of(context).size.width * 0.4,
                  child: Container(
                    height: 24,
                    width: 100,
                    child: TextFormField(
                        controller: _ProductNameController,
                        focusNode: productnameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(context,
                            productnameFocusNode, productcategoryFocusNode),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Category',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: Responsive.isDesktop(context)
                          ? MediaQuery.of(context).size.width * 0.36
                          : MediaQuery.of(context).size.width * 0.38,
                      child: Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.36
                            : MediaQuery.of(context).size.width * 0.38,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Container(child: _buildSupplierNameDropdown()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: Responsive.isDesktop(context)
                        ? 150
                        : MediaQuery.of(context).size.width * 0.3,
                    child: Container(
                      height: 27,
                      width: 100,
                      color: Colors.grey[200],
                      child: TextFormField(
                          controller: _ProductAmountController,
                          focusNode: AmountFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _fieldFocusChange(
                              context, AmountFocusNode, saveFocusNode),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          style: AmountTextStyle),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 30,
              ),
              _buildCGst(),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSGst(),
              SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Stock Check: ',
                          ),
                          TextSpan(
                            text: isSwitched ? 'YES' : 'NO',
                            style: TextStyle(
                              color: isSwitched ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: isUpdateMode ? UpdateButton() : SaveButton(),
            ),
          ],
        )
      ],
    );
  }

  List<String> ProductCategoryList = [];

  Future<void> fetchAllProductCategories() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PurchaseProductCategory/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductCategoryList.addAll(
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

      // print('All product categories: $ProductCategoryList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController ProductCategoryController = TextEditingController();
  String? selectedProductName;
  bool _isProdNameOptionsVisible = false;

  int? _productcategoryhoveredIndex;
  int? _selectedProductcategoryIndex;

  Widget _buildSupplierNameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          Icon(Icons.person),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.06
                        : MediaQuery.of(context).size.width * 0.25,
                    child: ProductCategoryDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      content: Container(
                        width: 1100,
                        // height: 700,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(
                                left: Responsive.isDesktop(context) ? 40 : 6,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.cancel),
                                    color: Colors.red,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      fetchAllProductCategories();
                                    },
                                  ),
                                ],
                              ),
                            )
// Customize the text style as needed
                            ,
                            Container(
                                width: 1100,
                                height: 550,
                                child: PurchaseProductCategory()),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: subcolor,
                ),
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

  Widget ProductCategoryDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex < ProductCategoryList.length - 1) {
              setState(() {
                _selectedProductcategoryIndex = currentIndex + 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex + 1];
                _isProdNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductcategoryIndex = currentIndex - 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex - 1];
                _isProdNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: productcategoryFocusNode,
          onSubmitted: (String? suggestion) async {
            _fieldFocusChange(
                context, productcategoryFocusNode, AmountFocusNode);
          },
          controller: ProductCategoryController,
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
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProdNameOptionsVisible && pattern.isNotEmpty) {
            return ProductCategoryList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductCategoryList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductCategoryList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _productcategoryhoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _productcategoryhoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductcategoryIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductcategoryIndex == null &&
                          ProductCategoryList.indexOf(
                                  ProductCategoryController.text) ==
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
            ProductCategoryController.text = suggestion!;
            selectedValue = suggestion;
            _isProdNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(AmountFocusNode);
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

  Widget _buildCGst() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("CGST %", style: commonLabelTextStyle),
          SizedBox(height: 10),
          Container(
            height: 28,
            child: ToggleButtons(
              borderColor: Colors.grey,
              fillColor: maincolor,
              borderWidth: 1,
              selectedColor: Colors.white,
              // Adjust the border radius
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '2.5',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '6',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '9',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '14',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelectedcgst.length; i++) {
                    isSelectedcgst[i] = i == index;
                  }
                  if (isSelectedcgst[index]) {
                    selectedCgstPercentage = cgstPercentages[index];
                  }
                });
              },
              isSelected: isSelectedcgst,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSGst() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SGST %", style: commonLabelTextStyle),
          SizedBox(height: 10),
          Container(
            height: 28,
            child: ToggleButtons(
              borderColor: Colors.grey,
              fillColor: maincolor,
              borderWidth: 1,
              selectedColor: Colors.white,
              // Adjust the border radius
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '2.5',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '6',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '9',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '14',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelectedsgst.length; i++) {
                    isSelectedsgst[i] = i == index;
                  }
                  if (isSelectedsgst[index]) {
                    selectedSgstPercentage = sgstPercentages[index];
                  }
                });
              },
              isSelected: isSelectedcgst,
            ),
          ),
        ],
      ),
    );
  }

  List<String> ProdcutNameLists = [];
  Future<void> fetchAllProductNames() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';

    while (true) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);
        for (var result in results) {
          String productName = result['name'];
          ProdcutNameLists.add(productName);
          // Removed print statement inside the loop
        }
      }

      if (jsonData['next'] != null) {
        apiUrl = jsonData['next'];
      } else {
        break;
      }
    }

    // Print the entire list of product names outside the loop
    // print("ProductName list : $ProdcutNameLists");
  }

  void _addItem() async {
    // Check if all fields are filled
    if (_ProductAmountController.text.isEmpty ||
        ProductCategoryController.text.isEmpty ||
        _ProductNameController.text.isEmpty) {
      WarninngMessage(context);
      print('Please fill in all fields');
      return;
    }

    if (ProdcutNameLists.any((name) =>
        name.toLowerCase() == _ProductNameController.text.toLowerCase())) {
      AlreadyExistWarninngMessage();
      print('Product name already exists');
      return;
    }

    String productName = _ProductNameController.text;
    String Amount = _ProductAmountController.text;
    String category = ProductCategoryController.text;

    String stockValueAsString = isSwitched ? 'Yes' : 'No';

    // Provide default values for selectedSgstPercentage and selectedCgstPercentage
    // double sgstPercentage = selectedSgstPercentage ?? 0.0;
    // double cgstPercentage = selectedSgstPercentage ?? 0.0;

    String sgstperc = selectedCgstPercentage.toString();
    String cgstperc = selectedCgstPercentage.toString();
    String? cusid = await SharedPrefs.getCusId();
    // Prepare data to be posted
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "name": productName,
      "stock": "0",
      "category": category,
      "amount": Amount,
      "sgstperc": sgstperc,
      "cgstperc": cgstperc,
      "addstock": stockValueAsString,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(postData);

    // Make POST request to the API
    String apiUrl = '$IpAddress/PurchaseProductDetailsalldatas/';
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
    await logreports(
        "Purchase ProductDetails: ${category}_${productName}_${Amount}_Inserted");
    successfullySavedMessage(context);
    fetchData();
    clearAllFeild();
    fetchData();
  }

  void UpdateItems(String Productid) async {
    String productName = _ProductNameController.text;
    String Amount = _ProductAmountController.text;
    String categories = ProductCategoryController.text;
    String stockValueAsString = isSwitched ? 'Yes' : 'No';

    String sgstperc = selectedCgstPercentage.toString();
    String cgstperc = selectedCgstPercentage.toString();

    String? cusid = await SharedPrefs.getCusId();
    // Prepare data to be posted
    Map<String, dynamic> putdata = {
      "cusid": "$cusid",
      "name": productName,
      "stock": "0",
      "category": categories,
      "amount": Amount,
      "sgstperc": cgstperc,
      "cgstperc": sgstperc,
      "addstock": stockValueAsString,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putdata);

    // Make PUT request to the API
    String apiUrl = '$IpAddress/PurchaseProductDetailsalldatas/$Productid/';
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
      await logreports(
          "Purchase ProductDetails: ${categories}_${productName}_${Amount}_Updated");
      successfullyUpdateMessage(context);
      fetchData();
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
  }

  Widget SaveButton() {
    return ElevatedButton(
      focusNode: saveFocusNode,
      onPressed: () {
        _addItem();
        clearAllFeild();
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

  String? Productid;
  Widget UpdateButton() {
    return ElevatedButton(
      focusNode: saveFocusNode,
      onPressed: () {
        print("Product Code : $Productid");
        UpdateItems(Productid!);
        clearAllFeild();
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

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.7 : 320,
          // height: Responsive.isDesktop(context) ? 400 : 320,
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
                    ? MediaQuery.of(context).size.width * 0.77
                    : MediaQuery.of(context).size.width * 3,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        //           Icon(
                        //             Icons.numbers,
                        //             size: 15,
                        //             color: Colors.blue,
                        //           ),
                        //           SizedBox(width: 5),
                        //           Text(
                        //             "ID",
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
                                  Icon(
                                    Icons.fastfood,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("MaterialName",
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
                                    Icons.add_box,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("MaterialStock",
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
                                    Icons.category,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Category",
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
                                  Text("Amount",
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
                                  Text(
                                    "Cgst %",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
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
                                  Text("Sgst %",
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
                                    Icons.point_of_sale_sharp,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Stock",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle,
                                  ),
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
                  if (getFilteredData().isNotEmpty)
                    ...getFilteredData().map((data) {
                      var id = data["id"].toString();
                      var name = data['name'].toString();
                      var stock = data['stock'].toString();
                      var category = data['category'].toString();

                      var amount = data['amount'].toString();
                      var sgstperc = data['sgstperc'].toString();
                      var cgstperc = data['cgstperc'].toString();
                      var addstock = data['addstock'].toString();
                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10,
                            top: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                              //       child: Text(id,
                              //           textAlign: TextAlign.center,
                              //           style: TableRowTextStyle),
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
                                    child: Text(name,
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
                                    child: Text(stock,
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
                                    child: Text(category,
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
                                    child: Text(amount,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 35,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      color: subcolor,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 3,
                                            bottom: 3),
                                        child: Text(
                                          sgstperc,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 35,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      color: subcolor,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 3,
                                            bottom: 3),
                                        child: Text(
                                          cgstperc,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                      ),
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
                                    child: Text(addstock,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 35,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              Productid = data['id'].toString();

                                              ProductCategoryController.text =
                                                  data['category'].toString();
                                              _ProductNameController.text =
                                                  data['name'].toString();
                                              _ProductAmountController.text =
                                                  data['amount'].toString();

                                              cgstperc =
                                                  data['cgstperc'].toString();
                                              int cgstIndex =
                                                  cgstPercentages.indexOf(
                                                      double.parse(cgstperc));
                                              isSelectedcgst = List.generate(
                                                  cgstPercentages.length,
                                                  (index) =>
                                                      index == cgstIndex);

                                              // Update sgst percentage and initialize isSelectedsgst list
                                              sgstperc =
                                                  data['sgstperc'].toString();
                                              int sgstIndex =
                                                  sgstPercentages.indexOf(
                                                      double.parse(sgstperc));
                                              isSelectedsgst = List.generate(
                                                  sgstPercentages.length,
                                                  (index) =>
                                                      index == sgstIndex);
                                              isUpdateMode = true;

                                              isSwitched =
                                                  data['addstock'].toString() ==
                                                      'Yes';
                                            });
                                          },
                                          color: Colors.black,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                                context,
                                                id,
                                                category,
                                                name,
                                                amount);
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
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String id,
      String category, String name, String amount) async {
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
                logreports(
                    "Purchase ProductDetails: ${category}_${name}_${amount}_Deleted");

                deletedata(id!);
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

  void deletedata(String id) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/PurchaseProductDetailsalldatas/$id';
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
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
      fetchData();
    }
    Navigator.pop(context);
    successfullyDeleteMessage(context);
  }

  void clearAllFeild() {
    _ProductNameController.clear();
    _ProductAmountController.text = "0.0";
    ProductCategoryController.clear();

    setState(() {
      isSwitched = false;
      selectedValue = '';
      isSelectedcgst = [true, false, false, false, false];
      isSelectedsgst = [true, false, false, false, false];
    });
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
