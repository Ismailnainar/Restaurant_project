import 'dart:async';
import 'dart:convert';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sales/Config/SalesCustomer.dart';
import 'package:restaurantsoftware/Sales/SubFormNewSales.dart';
import 'package:restaurantsoftware/Settings/PaymentMethod.dart';

class NewSalesEntry extends StatefulWidget {
  final TextEditingController cusnameController;
  final TextEditingController cuscontactController;
  final TextEditingController cusaddressController;
  final TextEditingController TableNoController;
  final TextEditingController scodeController;

  final TextEditingController snameController;
  final TextEditingController TypeController;
  final TextEditingController Fianlamount;

  final List<Map<String, dynamic>> salestableData;
  final bool isSaleOn;

  NewSalesEntry(
      {required this.salestableData,
      required this.cusnameController,
      required this.cuscontactController,
      required this.cusaddressController,
      required this.scodeController,
      required this.snameController,
      required this.TableNoController,
      required this.TypeController,
      required this.Fianlamount,
      this.isSaleOn = true});
  @override
  State<NewSalesEntry> createState() => _NewSalesEntryState();
}

class _NewSalesEntryState extends State<NewSalesEntry> {
  String? selectedValue;
  String? selectedproduct;
  bool isFirstContainerSelected = true;
  List<Map<String, dynamic>> tableData = [];
  TextEditingController CustomerNameController = TextEditingController();
  TextEditingController ContactController = TextEditingController();
  TextEditingController AddressController = TextEditingController();
  TextEditingController NoOfVisitController = TextEditingController();
  TextEditingController NoOfPointsController = TextEditingController();
  TextEditingController BillNoController = TextEditingController();
  TextEditingController SalesTypeController = TextEditingController();
  TextEditingController PaytypeController = TextEditingController();
  TextEditingController SNameController = TextEditingController();
  TextEditingController SCodeController = TextEditingController();
  TextEditingController tableNocontroller = TextEditingController();
  TextEditingController finalAMTcontroller = TextEditingController();

  DateTime? selectedDate;
  bool showCustomerList = false;

  FocusNode CustomerNameFocusMode = FocusNode();
  FocusNode CustomerContactFocusMode = FocusNode();
  FocusNode CustomerAddressFocusMode = FocusNode();
  FocusNode BillNoFocusMode = FocusNode();
  FocusNode SalesTypeFocusMode = FocusNode();
  FocusNode PayTypeFocusMode = FocusNode();
  FocusNode TablesalesFocusMode = FocusNode();
  FocusNode codeFocusNode = FocusNode();
  FocusNode TablenoFocusNode = FocusNode();
  FocusNode SCodeFocusMode = FocusNode();
  FocusNode SNameFocusMode = FocusNode();
  Timer? _timer;
  @override
  late salestableview saleTableView;
  void initState() {
    super.initState();
    isSaleOn = widget.isSaleOn;
    fetchCustomerName();
    // fetchNoOfVisits();
    fetchPaymentTypeList().then((_) {
      if (PaymentTypeList.isNotEmpty) {
        setState(() {
          PaymentTypeselectedValue = PaymentTypeList.first;
          PaytypeController.text = PaymentTypeselectedValue!;
        });
      }
    }).catchError((error) {
      print('Error in initState: $error');
    });
    fetchSalesFinalSerialNo();
    tableData = widget.salestableData;
    CustomerNameController.text = widget.cusnameController.text;
    ContactController.text = widget.cuscontactController.text;
    AddressController.text = widget.cusaddressController.text;
    tableNocontroller.text = widget.TableNoController.text;
    SNameController.text = widget.snameController.text;
    SCodeController.text = widget.scodeController.text;
    SalesTypeController.text = widget.TypeController.text;
    FinallyyyAmounttts.text = widget.Fianlamount.text;
    SalesTypeController = TextEditingController(text: "DineIn");
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchSalesFinalSerialNo(); // Fetch serial number every 10 sec
    });
    _timer?.cancel();
    saleTableView = salestableview(
      ProductSalesTypeController: widget.TypeController,
      BillNOreset: widget.cusnameController, // Example mapping
      tableno: widget.TableNoController,
      customername: widget.cusnameController,
      customercontact: widget.cuscontactController,
      scode: widget.scodeController,
      sname: widget.snameController,
      paytype: widget.TypeController,
      SALEStabledata: widget.salestableData,
      onFinalAmountButtonPressed: (controller) {
        // Handle button press
      },
      codeFocusNode: FocusNode(),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> fetchSupplierContact() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/SalesCustomer/$cusid/';
    String customerName =
        CustomerNameController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("Customer Name: $customerName");

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each customer entry
          for (var entry in results) {
            if (entry['cusname'].toString().toLowerCase() == customerName) {
              // Convert to lowercase
              // Retrieve the contact number and address for the customer
              String contactNo = entry['contact'];
              String agentId = entry['id'].toString();
              String address = entry['address'];
              String Points = entry['Points'];

              if (contactNo.isNotEmpty) {
                ContactController.text = contactNo;
                AddressController.text = address;
                NoOfPointsController.text = Points;
                contactFound = true;
                break;
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or contact number found
            break;
          }
        } else {
          throw Exception(
              'Failed to load customer contact information: ${response.reasonPhrase}');
        }
      }

      // Print a message if contact number not found
      if (!contactFound) {}
    } catch (e) {
      print('Error fetching customer contact information: $e');
    }
  }

  Future<void> fetchNoOfVisits() async {
    String? cusid = await SharedPrefs.getCusId();
    int totalCount = 0;
    String? nextUrl = '$IpAddress/SalesRoundAndDetails/$cusid/';

    try {
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // print("response body datas : ${response.body}");
          if (responseData.containsKey('results') &&
              responseData['results'] is List) {
            final List<dynamic> data = responseData['results'];
            final String customername = CustomerNameController.text;

            // Filter data where cusname is 'thilo' and Status is 'Normal'
            final filteredData = data
                .where((item) =>
                    item['cusname'] == customername &&
                    item['Status'] == 'Normal')
                .toList();

            totalCount += filteredData.length;

            // Check for pagination
            nextUrl = responseData['next'];
          } else {
            throw Exception('Invalid data format');
          }
        } else {
          throw Exception(
              'Failed to load data with status code: ${response.statusCode}');
        }
      }

      // Update UI after fetching all pages
      setState(() {
        NoOfVisitController.text = totalCount.toString();
      });
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  void dispose() {
    CustomerNameFocusMode.dispose();
    CustomerContactFocusMode.dispose();
    CustomerAddressFocusMode.dispose();
    BillNoFocusMode.dispose();
    SalesTypeFocusMode.dispose();
    PayTypeFocusMode.dispose();
    TablesalesFocusMode.dispose();
    TablenoFocusNode.dispose();
    SCodeFocusMode.dispose();
    SNameFocusMode.dispose();

    super.dispose();
  }

  Future<String> fetchSalesSerialNo() async {
    String newSerialNo = '';
    String? cusid = await SharedPrefs.getCusId();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Sales_serialno/$cusid/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if the serialno key exists in the JSON response
        if (jsonData.containsKey('serialno')) {
          String serialNo = jsonData['serialno'].toString();
          print("serialno : $serialNo");

          // Extract the alphabet part and the numeric part
          String alphabetPart = serialNo.replaceAll(RegExp(r'[0-9]'), '');
          String numberPart = serialNo.replaceAll(RegExp(r'[^0-9]'), '');

          if (numberPart.isEmpty) {
            print('Invalid serial number format');
            return '';
          }

          int parsedSerialNo = int.tryParse(numberPart) ?? 0;

          if (parsedSerialNo == 0) {
            // Directly accessing the integer value for orderserialno
            int maxSerialNumber = jsonData['serialno'] ?? 0;

            // Increment the serial number by 1 and prepend "OS"
            newSerialNo = 'S' + (maxSerialNumber + 1).toString();
          } else if (alphabetPart == 'S') {
            // If orderserialno starts with 'S', increment the number part
            newSerialNo = 'S' + (parsedSerialNo + 1).toString();
            ;
          } else {
            // Handle any other unexpected formats if necessary
            print('Unexpected serial number format');
          }
        } else {
          print('Failed to find serialno in response');
        }
      } else {
        print('Failed to load sales serial numbers');
      }
    } catch (e) {
      print('Error: $e');
    }

    return newSerialNo;
  }

  Future<void> fetchSalesFinalSerialNo() async {
    String addedSerialNo = await fetchSalesSerialNo();
    String billNoText = '$addedSerialNo';

    BillNoController.text = billNoText;
  }

  List<String> filteredCustomerList = [];
  void filterCustomerList(String query) {
    setState(() {
      filteredCustomerList = CustomerNameList.where(
          (name) => name.toLowerCase().contains(query.toLowerCase())).toList();
      showCustomerList = filteredCustomerList.isNotEmpty;
    });
  }

  List<String> typelist = ["DineIn", "TakeAway"];

  String? TypeselectedValue;
  int? _TypehoveredIndex;

  int? _selectedSalesTypeIndex;

  bool _isSalesTypeOptionsVisible = false;
  int? _SalesTypehoveredIndex;
  Widget _buildSalesTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 15,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.1
                        : MediaQuery.of(context).size.width * 0.25,
                    child: SalesTypeDropdown()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget SalesTypeDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = typelist.indexOf(SalesTypeController.text);
            if (currentIndex < typelist.length - 1) {
              setState(() {
                _selectedSalesTypeIndex = currentIndex + 1;
                SalesTypeController.text = typelist[currentIndex + 1];
                _isSalesTypeOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = typelist.indexOf(SalesTypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedSalesTypeIndex = currentIndex - 1;
                SalesTypeController.text = typelist[currentIndex - 1];
                _isSalesTypeOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: SalesTypeFocusMode,
          onSubmitted: (String? suggestion) async {
            _fieldFocusChange(context, SalesTypeFocusMode, PayTypeFocusMode);
          },
          controller: SalesTypeController,
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
              _isSalesTypeOptionsVisible = true;
              TypeselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isSalesTypeOptionsVisible && pattern.isNotEmpty) {
            return typelist.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return typelist;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = typelist.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _SalesTypehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _SalesTypehoveredIndex = null;
            }),
            child: Container(
              color: _selectedSalesTypeIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedSalesTypeIndex == null &&
                          typelist.indexOf(SalesTypeController.text) == index
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
            SalesTypeController.text = suggestion!;
            TypeselectedValue = suggestion;
            _isSalesTypeOptionsVisible = false;

            FocusScope.of(context).requestFocus(PayTypeFocusMode);
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

  List<String> PaymentTypeList = [];

  Future<void> fetchPaymentTypeList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PaymentMethod/$cusid/';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<String> fetchedPaytypes = [];

        for (var item in data) {
          String PaymentTypeList = item['paytype'];
          fetchedPaytypes.add(PaymentTypeList);
        }

        setState(() {
          PaymentTypeList = fetchedPaytypes;
        });
      }

      // print('All PaymentTypeList: $PaymentTypeList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? PaymentTypeselectedValue;

  Widget _buildPayTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            size: 15,
          ),
          SizedBox(width: 3),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.085
                        : MediaQuery.of(context).size.width * 0.25,
                    child: Paymenttypedropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
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
                            PaymentMethodSetting(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchPaymentTypeList();
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
                decoration: BoxDecoration(color: subcolor),
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

  bool _isPayTypeOptionsVisible = false;

  int? _selectedPayTypeIndex;
  int? _PayTypehoveredIndex;

  Widget Paymenttypedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = PaymentTypeList.indexOf(PaytypeController.text);
            if (currentIndex < PaymentTypeList.length - 1) {
              setState(() {
                _selectedPayTypeIndex = currentIndex + 1;
                PaytypeController.text = PaymentTypeList[currentIndex + 1];
                _isPayTypeOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = PaymentTypeList.indexOf(PaytypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                PaytypeController.text = PaymentTypeList[currentIndex - 1];
                _isPayTypeOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: PayTypeFocusMode,
          onSubmitted: (_) =>
              _fieldFocusChange(context, PayTypeFocusMode, codeFocusNode),
          controller: PaytypeController,
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
              _isPayTypeOptionsVisible = true;
              PaymentTypeselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isPayTypeOptionsVisible && pattern.isNotEmpty) {
            return PaymentTypeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return PaymentTypeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = PaymentTypeList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _PayTypehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _PayTypehoveredIndex = null;
            }),
            child: Container(
              color: _selectedPayTypeIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedPayTypeIndex == null &&
                          PaymentTypeList.indexOf(PaytypeController.text) ==
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

        // onSuggestionSelected: (String? suggestion) async {
        //   if (suggestion != null && (suggestion.toLowerCase() == 'credit')) {
        //     if (CustomerNameController.text.isEmpty) {
        //       showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return AlertDialog(
        //             title: Text('Warning'),
        //             content: Text(
        //                 'When you select "Credit", set the customer name.'),
        //             actions: <Widget>[
        //               ElevatedButton(
        //                 onPressed: () {
        //                   Navigator.of(context).pop();
        //                   _fieldFocusChange(
        //                       context, PayTypeFocusMode, CustomerNameFocusMode);
        //                 },
        //                 style: ElevatedButton.styleFrom(
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(2.0),
        //                   ),
        //                   backgroundColor: subcolor,
        //                   minimumSize: Size(45.0, 31.0), // Set width and height
        //                 ),
        //                 child: Text('Ok', style: commonWhiteStyle),
        //               ),
        //             ],
        //           );
        //         },
        //       );
        //     } else {
        //       setState(() {
        //         PaytypeController.text = suggestion;
        //         PaymentTypeselectedValue = suggestion;
        //         _isPayTypeOptionsVisible = false;
        //         FocusScope.of(context).requestFocus(codeFocusNode);
        //       });
        //     }
        //   } else {
        //     setState(() {
        //       PaytypeController.text = suggestion!;
        //       PaymentTypeselectedValue = suggestion;
        //       _isPayTypeOptionsVisible = false;
        //       FocusScope.of(context).requestFocus(codeFocusNode);
        //     });
        //   }
        // },
        onSuggestionSelected: (String? suggestion) async {
          setState(() {
            PaytypeController.text = suggestion!;
            PaymentTypeselectedValue = suggestion;
            _isPayTypeOptionsVisible = false;
            FocusScope.of(context).requestFocus(codeFocusNode);
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

  List<String> CustomerNameList = [];

  Future<void> fetchCustomerName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/SalesCustomer/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          CustomerNameList.addAll(
              results.map<String>((item) => item['cusname'].toString()));

          hasNextPage = data['cusname'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $CustomerNameList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? CustomerselectedValue;

  bool _isCustomernameOptionsVisible = false;

  int? _CustomerNamehoveredIndex;

  int? _selectedCustomerNameIndex;

  Widget _buildCustomerNameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 15,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.085
                        : MediaQuery.of(context).size.width * 0.25,
                    child: CustomerNameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
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
                            SalesCoutomer(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchCustomerName();
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
                decoration: BoxDecoration(color: subcolor),
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

  Widget CustomerNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNameController.text);
            if (currentIndex < CustomerNameList.length - 1) {
              setState(() {
                _selectedCustomerNameIndex = currentIndex + 1;
                CustomerNameController.text =
                    CustomerNameList[currentIndex + 1];
                _isCustomernameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedCustomerNameIndex = currentIndex - 1;
                CustomerNameController.text =
                    CustomerNameList[currentIndex - 1];
                _isCustomernameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: CustomerNameFocusMode,
          onSubmitted: (String? suggestion) async {
            await fetchSupplierContact();
            await fetchNoOfVisits();
            _fieldFocusChange(
                context, CustomerNameFocusMode, CustomerContactFocusMode);
          },
          controller: CustomerNameController,
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
              _isCustomernameOptionsVisible = true;
              CustomerselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isCustomernameOptionsVisible && pattern.isNotEmpty) {
            return CustomerNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return CustomerNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = CustomerNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _CustomerNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _CustomerNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedCustomerNameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedCustomerNameIndex == null &&
                          CustomerNameList.indexOf(
                                  CustomerNameController.text) ==
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
            CustomerNameController.text = suggestion!;
            CustomerselectedValue = suggestion;
            _isCustomernameOptionsVisible = false;
            fetchSupplierContact();
            fetchNoOfVisits();
            FocusScope.of(context).requestFocus(CustomerContactFocusMode);
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

  void Finalamtvalues(TextEditingController finalamtcontroller) {
    setState(() {
      finalAMTcontroller.text = finalamtcontroller.text;
      print(
          'Final amount button pressed with value: ${finalAMTcontroller.text}');
    });
  }

  late bool isSaleOn;

  void toggleSale(bool isSale) {
    setState(() {
      isSaleOn = isSale;
      if (!isSaleOn) {
        // _fetchTableSalesData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    {
      bool isNumeric = false;
    }
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.13;
    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.1;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 15 : 0, top: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: Responsive.isDesktop(context) ? 0 : 20),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Sales Entry", style: HeadingStyle)
                              ],
                            ),
                            if (Responsive.isDesktop(context))
                              Padding(
                                padding: EdgeInsets.only(left: 00, right: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () async {
                                          String? role = await getrole();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => sidebar(
                                                      onItemSelected:
                                                          (content) {},
                                                      settingsproductcategory:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsproductcategory,
                                                      settingsproductdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsproductdetails,
                                                      settingsgstdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingsgstdetails,
                                                      settingsstaffdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingsstaffdetails,
                                                      settingspaymentmethod:
                                                          role == 'admin'
                                                              ? true
                                                              : settingspaymentmethod,
                                                      settingsaddsalespoint:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsaddsalespoint,
                                                      settingsprinterdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsprinterdetails,
                                                      settingslogindetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingslogindetails,
                                                      purchasenewpurchase: role ==
                                                              'admin'
                                                          ? true
                                                          : purchasenewpurchase,
                                                      purchaseeditpurchase: role ==
                                                              'admin'
                                                          ? true
                                                          : purchaseeditpurchase,
                                                      purchasepaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : purchasepaymentdetails,
                                                      purchaseproductcategory:
                                                          role == 'admin'
                                                              ? true
                                                              : purchaseproductcategory,
                                                      purchaseproductdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : purchaseproductdetails,
                                                      purchaseCustomer: role ==
                                                              'admin'
                                                          ? true
                                                          : purchaseCustomer,
                                                      salesnewsales:
                                                          role == 'admin'
                                                              ? true
                                                              : salesnewsale,
                                                      saleseditsales:
                                                          role == 'admin'
                                                              ? true
                                                              : saleseditsales,
                                                      salespaymentdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : salespaymentdetails,
                                                      salescustomer:
                                                          role == 'admin'
                                                              ? true
                                                              : salescustomer,
                                                      salestablecount:
                                                          role == 'admin'
                                                              ? true
                                                              : salestablecount,
                                                      quicksales:
                                                          role == 'admin'
                                                              ? true
                                                              : quicksales,
                                                      ordersalesnew:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalesnew,
                                                      ordersalesedit:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalesedit,
                                                      ordersalespaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalespaymentdetails,
                                                      vendorsalesnew:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorsalesnew,
                                                      vendorsalespaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorsalespaymentdetails,
                                                      vendorcustomer:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorcustomer,
                                                      stocknew: role == 'admin'
                                                          ? true
                                                          : stocknew,
                                                      wastageadd:
                                                          role == 'admin'
                                                              ? true
                                                              : wastageadd,
                                                      kitchenusagesentry: role ==
                                                              'admin'
                                                          ? true
                                                          : kitchenusagesentry,
                                                      report: role == 'admin'
                                                          ? true
                                                          : report,
                                                      daysheetincomeentry: role ==
                                                              'admin'
                                                          ? true
                                                          : daysheetincomeentry,
                                                      daysheetexpenseentry: role ==
                                                              'admin'
                                                          ? true
                                                          : daysheetexpenseentry,
                                                      daysheetexepensescategory:
                                                          role == 'admin'
                                                              ? true
                                                              : daysheetexepensescategory,
                                                      graphsales:
                                                          role == 'admin'
                                                              ? true
                                                              : graphsales,
                                                    )),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   crossAxisAlignment: CrossAxisAlignment.end,
                            //   children: [
                            //     SizedBox(
                            //       width: 60,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 0),
                                child: Text(
                                  "Customer Name",
                                  style: commonLabelTextStyle,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Container(
                                    width: Responsive.isDesktop(context)
                                        ? desktopcontainerdwidth
                                        : MediaQuery.of(context).size.width *
                                            0.38,
                                    child: _buildCustomerNameDropdown()),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text("Contact No",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 25,
                                    top: 8),
                                child: Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.call_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        color: Colors.grey[200],
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        child: TextFormField(
                                            controller: ContactController,
                                            focusNode: CustomerContactFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  10), // Optional: Limit input length to 10
                                            ],
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    CustomerContactFocusMode,
                                                    CustomerAddressFocusMode),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text("Address",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 25,
                                    top: 8),
                                child: Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.note_alt_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            controller: AddressController,
                                            focusNode: CustomerAddressFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    CustomerAddressFocusMode,
                                                    SalesTypeFocusMode),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          //  color: subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("No.of Visits",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.note_alt_outlined,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller: NoOfVisitController,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          //  color: subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Text("No.of Points",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.control_point_sharp,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            readOnly: true,
                                            controller: NoOfPointsController,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text("Bill No",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 25,
                                    top: 8),
                                child: Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.inventory_rounded,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        color: Colors.grey[200],
                                        height: 24,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Container(
                                            child: TextFormField(
                                                controller: BillNoController,
                                                readOnly: true,
                                                focusNode: BillNoFocusMode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    _fieldFocusChange(
                                                        context,
                                                        BillNoFocusMode,
                                                        SalesTypeFocusMode),
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300,
                                                        width: 1.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black,
                                                        width: 1.0),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 7.0,
                                                  ),
                                                ),
                                                style: textStyle),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child:
                                    Text("Type", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Container(
                                    width: Responsive.isDesktop(context)
                                        ? desktopcontainerdwidth
                                        : MediaQuery.of(context).size.width *
                                            0.38,
                                    child: _buildSalesTypeDropdown()),
                              )
                            ],
                          ),
                        ),
                        Container(
                          //  color: subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text("Pay Type",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child: Container(
                                    width: Responsive.isDesktop(context)
                                        ? desktopcontainerdwidth
                                        : MediaQuery.of(context).size.width *
                                            0.38,
                                    child: _buildPayTypeDropdown()),
                              ),
                            ],
                          ),
                        ),
                        //Table Sales

                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text("Table Sales",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 8,
                                  left: Responsive.isDesktop(context) ? 10 : 25,
                                ),
                                child: Container(
                                  // color: Colors.purple,
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.45,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        isSaleOn
                                            ? Icons.stacked_bar_chart_sharp
                                            : Icons.table_bar,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                        height: 24,
                                        // margin: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 99, 4, 116),
                                            )),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                toggleSale(true);
                                                tableNocontroller.clear();
                                                SCodeController.clear();
                                                SNameController.clear();
                                                tableData = [];
                                              },
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.048
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.19,
                                                decoration: BoxDecoration(
                                                  color: isSaleOn
                                                      ? const Color.fromARGB(
                                                          255, 99, 4, 116)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                    left: Radius.circular(5),
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Sales',
                                                  style: TextStyle(
                                                    color: isSaleOn
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return WillPopScope(
                                                      onWillPop: () async =>
                                                          false, // Prevent closing by tapping outside the dialog
                                                      child: AlertDialog(
                                                        content: Container(
                                                          color: Color.fromARGB(
                                                              255,
                                                              250,
                                                              221,
                                                              255),
                                                          height: 700,
                                                          width: Responsive
                                                                  .isDesktop(
                                                                      context)
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Container(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      IconButton(
                                                                        icon: Icon(
                                                                            Icons.cancel),
                                                                        color: Colors
                                                                            .red,
                                                                        onPressed:
                                                                            () {
                                                                          // This only closes the dialog, does not affect the timer
                                                                          Navigator.of(context)
                                                                              .pop();

                                                                          // Use setState only if you need to modify any specific state here
                                                                          setState(
                                                                              () {
                                                                            // Ensure this flag change doesn't affect the timer

                                                                            isSaleOn =
                                                                                true; // Update any UI state you want without resetting the timer
                                                                          });
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  tablesalesview(
                                                                    SalesPaytype:
                                                                        PaytypeController,
                                                                    ProductSalesTypeController:
                                                                        SalesTypeController,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                                toggleSale(false);
                                              },
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.05
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.19,
                                                decoration: BoxDecoration(
                                                  color: isSaleOn
                                                      ? Colors.white
                                                      : const Color.fromARGB(
                                                          255, 99, 4, 116),
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                    right: Radius.circular(5),
                                                  ),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'TableSales',
                                                  style: TextStyle(
                                                    color: isSaleOn
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isSaleOn)
                          Container(
                            width: Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.37
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 10
                                                : 20,
                                            top: 8),
                                        child: Text("Table No",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 10
                                                : 25,
                                            top: 8),
                                        child: Container(
                                          height: 24,
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.38,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.table_bar,
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.07
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.25,
                                                color: Colors.grey[200],
                                                child: TextFormField(
                                                    readOnly: true,
                                                    controller:
                                                        tableNocontroller,
                                                    focusNode: TablenoFocusNode,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    onFieldSubmitted: (_) =>
                                                        _fieldFocusChange(
                                                            context,
                                                            TablenoFocusNode,
                                                            SCodeFocusMode),
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 7.0,
                                                      ),
                                                    ),
                                                    style: textStyle),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 20
                                                : 20,
                                            top: 8),
                                        child: Text("SCode",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 20
                                                : 25,
                                            top: 8),
                                        child: Container(
                                          height: 24,
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.38,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons
                                                    .cleaning_services_outlined,
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.07
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.25,
                                                color: Colors.grey[200],
                                                child: TextFormField(
                                                    readOnly: true,
                                                    controller: SCodeController,
                                                    focusNode: SCodeFocusMode,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    onFieldSubmitted: (_) =>
                                                        _fieldFocusChange(
                                                            context,
                                                            SCodeFocusMode,
                                                            SNameFocusMode),
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 7.0,
                                                      ),
                                                    ),
                                                    style: textStyle),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 20
                                                : 20,
                                            top: 8),
                                        child: Text("SName",
                                            style: commonLabelTextStyle),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 20
                                                : 25,
                                            top: 8),
                                        child: Container(
                                          height: 24,
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.38,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons
                                                    .supervised_user_circle_outlined,
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: 24,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.07
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.25,
                                                color: Colors.grey[200],
                                                child: TextFormField(
                                                    readOnly: true,
                                                    controller: SNameController,
                                                    focusNode: SNameFocusMode,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    onFieldSubmitted: (_) =>
                                                        _fieldFocusChange(
                                                            context,
                                                            SNameFocusMode,
                                                            TablesalesFocusMode),
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 7.0,
                                                      ),
                                                    ),
                                                    style: textStyle),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isSaleOn)
                          Container(
                            width: Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.37
                                : MediaQuery.of(context).size.width * 0.38,
                          ),
                        if (Responsive.isDesktop(context))
                          Container(
                              child:
                                  finalamount(finalAmount: finalAMTcontroller)),
                        Container(
                          width: Responsive.isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.75
                              : MediaQuery.of(context).size.width * 1,
                          child: Column(
                            children: [
                              isFirstContainerSelected
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, top: 8),
                                            child: Container(
                                                color: Color.fromRGBO(
                                                    251, 234, 255, 0.973),
                                                // height: 350,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.73
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.9,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 10),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: salestableview(
                                                        codeFocusNode:
                                                            codeFocusNode,
                                                        onFinalAmountButtonPressed:
                                                            (finalamtcontroller) {
                                                          Finalamtvalues(
                                                              finalamtcontroller);
                                                        },
                                                        ProductSalesTypeController:
                                                            SalesTypeController,
                                                        BillNOreset:
                                                            BillNoController,
                                                        SALEStabledata:
                                                            tableData,
                                                        customercontact:
                                                            ContactController,
                                                        customername:
                                                            CustomerNameController,
                                                        paytype:
                                                            PaytypeController,
                                                        scode: SCodeController,
                                                        sname: SNameController,
                                                        tableno:
                                                            tableNocontroller,
                                                      ),
                                                    ),
                                                    SizedBox(height: 13),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      // child:
                                                      //     STablle(),
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ])
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, top: 8),
                                            child: Container(
                                                color: Color.fromRGBO(
                                                    251, 234, 255, 0.973),
                                                // height: 350,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.7
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.9,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 10),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: salestableview(
                                                        codeFocusNode:
                                                            codeFocusNode,
                                                        onFinalAmountButtonPressed:
                                                            (finalamtcontroller) {
                                                          Finalamtvalues(
                                                              finalamtcontroller);
                                                        },
                                                        ProductSalesTypeController:
                                                            SalesTypeController,
                                                        BillNOreset:
                                                            BillNoController,
                                                        SALEStabledata:
                                                            tableData,
                                                        customercontact:
                                                            ContactController,
                                                        customername:
                                                            CustomerNameController,
                                                        paytype:
                                                            PaytypeController,
                                                        scode: SCodeController,
                                                        sname: SNameController,
                                                        tableno:
                                                            tableNocontroller,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      // child:
                                                      //     STablle(),
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ]),
                            ],
                          ),
                        ),

                        Container(
                            // height: 460,
                            width: Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.23
                                : MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, left: 0),
                              child: (Responsive.isDesktop(context))
                                  ? Column(
                                      children: [
                                        lastbillview(),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        lastbillview(),
                                      ],
                                    ),
                            )),

                        // saleTableView.finalamtRS(),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
