import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(ProductStockReport());
}

class ProductStockReport extends StatefulWidget {
  @override
  State<ProductStockReport> createState() => _ProductStockReportState();
}

class _ProductStockReportState extends State<ProductStockReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';
  String? selectedproduct;
  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchAllProductName();
  }

  List<String> getDisplayedColumns() {
    return ['id', 'name', 'stock', 'stockvalue'];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData) {
    List<String> displayedColumns = getDisplayedColumns();
    return tableData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
  }

  Future<void> fetchProductDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/Settings_ProductDetails/$cusid/?page=$currentPage&size=$pageSize';
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
                  child: SingleChildScrollView(
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
                                'Product Stock',
                                style: HeadingStyle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              // color: Subcolor,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProductNameDropdown('ProductName : ')
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: _buildQtyText('Qty'),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                            bottom: 20,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        List<Map<String, dynamic>>
                                            filteredData =
                                            getFilteredData(tableData);
                                        List<List<dynamic>> convertedData =
                                            filteredData
                                                .map((map) =>
                                                    map.values.toList())
                                                .toList();
                                        List<String> columnNames =
                                            getDisplayedColumns();
                                        await createExcel(
                                            columnNames, convertedData);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: subcolor,
                                          padding: EdgeInsets.only(
                                              left: 7,
                                              right: 7,
                                              top: 3,
                                              bottom: 3),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero)),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: SvgPicture.asset(
                                              'assets/imgs/excel.svg',
                                              width: 20,
                                              height: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "Export",
                                            style: commonWhiteStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductNameDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.fastfood_sharp,
                size: 15,
              ),
              SizedBox(width: 5),
              Text(
                label,
                style: commonLabelTextStyle,
              ),
            ],
          ),
          Container(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Container(height: 23, width: 150, child: ProductNamedropdown()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAllProductName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
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
      rethrow;
    }
  }

  List<String> ProductNameList = [];

  TextEditingController ProductCategoryController = TextEditingController();
  TextEditingController stockValueController = TextEditingController();
  String? selectedProductName;
  int? _selectedProdIndex;

  bool _ProdNamefilterEnabled = true;
  int? _ProdNamehoveredIndex;
  FocusNode ProdNameFocus = FocusNode();

  Widget ProductNamedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(ProductCategoryController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProdIndex = currentIndex + 1;
                ProductCategoryController.text =
                    ProductNameList[currentIndex + 1];
                _ProdNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(ProductCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProdIndex = currentIndex - 1;
                ProductCategoryController.text =
                    ProductNameList[currentIndex - 1];
                _ProdNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: ProdNameFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedProductName = suggestion;
              ProductCategoryController.text = suggestion!;
              _ProdNamefilterEnabled = false;
              _fieldFocusChange(context, ProdNameFocus, _Qtyfocus);
            });
            try {
              String? stock = await fetchStockValueByName(suggestion!);

              if (stock != null) {
                setState(() {
                  selectedProductName = suggestion;
                  ProductCategoryController.text =
                      suggestion ?? ' ${selectedProductName ?? ''}';
                  stockValueController.text = stock;
                });
              } else {
                print('Failed to fetch stock for product: $suggestion');
              }
            } catch (e) {
              print('Error in onSuggestionSelected: $e');
            }
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
          onChanged: (text) {
            setState(() {
              _ProdNamefilterEnabled = true;
              selectedProductName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_ProdNamefilterEnabled && pattern.isNotEmpty) {
            return ProductNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProdNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProdNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProdIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProdIndex == null &&
                          ProductNameList.indexOf(
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
            selectedProductName = suggestion;
            ProductCategoryController.text = suggestion!;
            _ProdNamefilterEnabled = false;
          });
          try {
            String? stock = await fetchStockValueByName(suggestion!);
            await logreports(
                "ProductStockReport: ${ProductCategoryController.text}_Viewd");
            if (stock != null) {
              setState(() {
                selectedProductName = suggestion;
                ProductCategoryController.text =
                    suggestion ?? ' ${selectedProductName ?? ''}';
                stockValueController.text = stock;
              });
            } else {
              print('Failed to fetch stock for product: $suggestion');
            }
          } catch (e) {
            print('Error in onSuggestionSelected: $e');
          }
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  Future<String?> fetchStockValueByName(String selectedProductName) async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
      int page = 1;
      List<dynamic> allResults = [];

      while (true) {
        String url = '$apiUrl?page=$page';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          allResults.addAll(results);

          if (data['next'] != null) {
            page++;
          } else {
            break;
          }
        } else {
          throw Exception('Failed to fetch stock: ${response.reasonPhrase}');
        }
      }

      final Map<String, dynamic>? productData = allResults.firstWhere(
        (item) => item['name'].toString() == selectedProductName,
        orElse: () => null,
      );

      if (productData != null) {
        return productData['stockvalue'].toString();
      }
    } catch (e) {
      print('Error fetching stock: $e');
    }
    return null;
  }

  FocusNode _Qtyfocus = FocusNode();

  Widget _buildQtyText(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 2.0),
              child: Icon(
                Icons.production_quantity_limits,
                size: 15,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                0.0,
              ),
              child: Text(
                label,
                style: commonLabelTextStyle,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10, top: 5),
              child: Row(
                children: [
                  Container(
                    width: Responsive.isDesktop(context) ? 80 : 80,
                    child: Container(
                      height: 23,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      child: TextField(
                        focusNode: _Qtyfocus,
                        keyboardType: TextInputType.number,
                        controller: stockValueController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade100, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade100, width: 1.0),
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
            ),
          ],
        ),
      ],
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.60 : 380,
          decoration: BoxDecoration(
            color: Colors.grey[100],
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
                                  "ID",
                                  textAlign: TextAlign.center,
                                  style: commonLabelTextStyle,
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
                                  "Name",
                                  textAlign: TextAlign.center,
                                  style: commonLabelTextStyle,
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
                                  style: commonLabelTextStyle,
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
                                  "StockValue",
                                  textAlign: TextAlign.center,
                                  style: commonLabelTextStyle,
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
                        var name = data['name'].toString();
                        var stock = data['stock'].toString();
                        var stockvalue = data['stockvalue'].toString();

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
                                    child: Text(id,
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
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                    child: Text(stock,
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
                                    child: Text(stockvalue,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
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
                                  width: 100,
                                  height: 100,
                                ),
                                Center(
                                  child: Text(
                                    'No transactions available to generate report',
                                    style: textStyle,
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}

Future<void> createExcel(
    List<String> columnNames, List<List<dynamic>> data) async {
  try {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
      final Range range = sheet.getRangeByIndex(1, colIndex + 1);
      range.setText(columnNames[colIndex]);
      range.cellStyle.backColor = '#550A35';
      range.cellStyle.fontColor = '#F5F5F5';
    }

    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final List<dynamic> rowData = data[rowIndex];
      for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
        range.setText(rowData[colIndex].toString());
      }
    }

    final List<int> bytes = workbook.saveAsStream();

    try {
      workbook.dispose();
    } catch (e) {
      print('Error during workbook disposal: $e');
    }

    final now = DateTime.now();
    final formattedDate =
        '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'ProductStock_Report ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel ProductStock_Report ($formattedDate).xlsx'
          : '$path/Excel ProductStock_Report ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
