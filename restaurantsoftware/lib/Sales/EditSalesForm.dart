import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sales/Config/SalesCustomer.dart';
import 'package:restaurantsoftware/Sales/NewSales.dart';
import 'dart:async';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:restaurantsoftware/Settings/AddProductsDetails.dart';
import 'package:restaurantsoftware/Settings/GstDetails.dart';
import 'package:restaurantsoftware/Settings/PaymentMethod.dart';

TextEditingController FinallyyyAmounttts = TextEditingController();
void finalamountcontainer(TextEditingController finalamtcontroller) {
  String finalamt = finalamtcontroller.text;
  FinallyyyAmounttts.text = finalamt;
  print("finalamountyyyyyyyyyyyyyyy is ${FinallyyyAmounttts.text}");
}

class EditNewSalesEntry extends StatefulWidget {
  final TextEditingController cusnameController;
  final TextEditingController cuscontactController;
  final TextEditingController cusaddressController;
  final TextEditingController TableNoController;
  final TextEditingController scodeController;

  final TextEditingController snameController;
  final TextEditingController TypeController;

  final List<Map<String, dynamic>> salestableData;

  EditNewSalesEntry({
    required Key key,
    required this.salestableData,
    required this.cusnameController,
    required this.cuscontactController,
    required this.cusaddressController,
    required this.scodeController,
    required this.snameController,
    required this.TableNoController,
    required this.TypeController,
  });
  @override
  State<EditNewSalesEntry> createState() => _EditNewSalesEntryState();
}

class _EditNewSalesEntryState extends State<EditNewSalesEntry> {
  final GlobalKey<_EditSalesableviewState> _tableSalesKey =
      GlobalKey<_EditSalesableviewState>();

  void _onShowButtonPressed() {
    _tableSalesKey.currentState?.printShowButtonPressed();
  }

  void _changegstmethod() {
    _tableSalesKey.currentState?.refreshData();
  }

  TextEditingController finalAMTcontroller = TextEditingController();

  void Finalamtvalues(TextEditingController finalamtcontroller) {
    setState(() {
      finalAMTcontroller.text = finalamtcontroller.text;
      print(
          'Final amount button pressed with value: ${finalAMTcontroller.text}');
    });
  }

  String? selectedValue;
  String? selectedproduct;
  bool isFirstContainerSelected = true;
  List<Map<String, dynamic>> tableData = [];
  TextEditingController CustomerNameController = TextEditingController();
  TextEditingController ContactController = TextEditingController();
  TextEditingController AddressController = TextEditingController();
  TextEditingController NoOfVisitController = TextEditingController();
  TextEditingController NoOfPointsController = TextEditingController();
  TextEditingController BillNoController = TextEditingController(text: "S");

  TextEditingController timecontroller = TextEditingController();

  TextEditingController SalesTypeController = TextEditingController();
  TextEditingController PaytypeController = TextEditingController();
  TextEditingController SNameController = TextEditingController();
  TextEditingController SCodeController = TextEditingController();
  TextEditingController tableNocontroller = TextEditingController();
  TextEditingController SalesGstMethodController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  bool showCustomerList = false;

  FocusNode CustomerNameFocusMode = FocusNode();
  FocusNode DateFocustNode = FocusNode();
  FocusNode CustomerContactFocusMode = FocusNode();
  FocusNode CustomerAddressFocusMode = FocusNode();
  FocusNode BillNoFocusMode = FocusNode();
  FocusNode SalesTypeFocusMode = FocusNode();
  FocusNode PayTypeFocusMode = FocusNode();
  FocusNode TablesalesFocusMode = FocusNode();
  FocusNode showbuttonfocusnode = FocusNode();

  FocusNode TablenoFocusNode = FocusNode();
  FocusNode SCodeFocusMode = FocusNode();
  FocusNode SNameFocusMode = FocusNode();
  FocusNode codeFocusNode = FocusNode();
  FocusNode GSTFocusMode = FocusNode();

  List<String> CustomerNameList = [];
  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> fetchSupplierContact() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/SalesCustomer/$cusid';
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
                // print("pointsssss:${NoOfPointsController.text}");
                contactFound = true;
                break; // Exit the loop once the contact number is found
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

  @override
  void initState() {
    super.initState();
    fetchCustomerName();

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

    // fetchSalesFinalSerialNo();
    tableData = widget.salestableData;
    CustomerNameController.text = widget.cusnameController.text;
    ContactController.text = widget.cuscontactController.text;
    AddressController.text = widget.cusaddressController.text;
    tableNocontroller.text = widget.TableNoController.text;
    SNameController.text = widget.snameController.text;
    SCodeController.text = widget.scodeController.text;
    SalesTypeController.text = widget.TypeController.text;

    // Print tableData
    // print("tabledatas :: ${SalesTypeController.text}");
    SalesTypeController = TextEditingController(text: "DineIn");
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

  Future<String> fetchAmcSerialNo() async {
    String AMCserialNo = '';
    try {
      final response = await http.get(Uri.parse('$IpAddress/Amc/'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty) {
          AMCserialNo = jsonData[0]['serialno'];
        }
        // print("Amc SerialNo : $AMCserialNo");
      } else {
        print('Failed to load serial number');
      }
    } catch (e) {
      print('Error: $e');
    }
    return AMCserialNo;
  }

  Future<String> fetchSalesSerialNo() async {
    String addedSerialNo = '';

    // Fetch AMC serial number
    String amcSerialNo = await fetchAmcSerialNo();

    try {
      final response = await http.get(Uri.parse('$IpAddress/Sales_serialno'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> serialNumbers = jsonData;

        // Finding the highest ID
        int maxId = -1;
        for (var item in serialNumbers) {
          if (item['id'] > maxId) {
            maxId = item['id'];
            String serialNo = item['serialno'];

            // Check if the serial number contains a hyphen
            int hyphenIndex = serialNo.indexOf('-');
            if (hyphenIndex != -1) {
              // Extract the part of serial number before the hyphen
              String beforeHyphen = serialNo.substring(0, hyphenIndex);

              // Check if the part before hyphen matches AMC serial number
              if (beforeHyphen == amcSerialNo) {
                // Extract the number after the hyphen
                String afterHyphen = serialNo.substring(hyphenIndex + 1);

                // Parse the number after the hyphen
                int parsedSerialNo = int.tryParse(afterHyphen) ?? 0;

                // Increment the parsed serial number by 1
                addedSerialNo = (parsedSerialNo + 1).toString();
              }
            }
          }
        }
        // If no matching serial number found, start from 1
        if (addedSerialNo.isEmpty) {
          addedSerialNo = '1';
        }
      } else {
        print('Failed to load sales serial numbers');
      }
    } catch (e) {
      print('Error: $e');
    }
    return addedSerialNo;
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
      String url = '$IpAddress/PaymentMethod/$cusid';

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

  List<String> GstmethodList = ["Including", "Excluding", "Nongst"];
  String? GstmethodselectedValue;
  String? previousGstmethodselectedValue;

  Widget GstmethodDropdown() {
    SalesGstMethodController.text = GstmethodselectedValue ?? '';

    return TypeAheadFormField<String?>(
      textFieldConfiguration: TextFieldConfiguration(
        focusNode: GSTFocusMode,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) =>
            _fieldFocusChange(context, GSTFocusMode, codeFocusNode),
        controller: SalesGstMethodController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 10, left: 5),
          labelStyle: TextStyle(fontSize: 12),
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
          ),
        ),
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
      suggestionsCallback: (pattern) {
        return GstmethodList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, String? suggestion) {
        return ListTile(
          dense: true,
          title: Text(
            suggestion ?? ' ${GstmethodselectedValue ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        );
      },
      onSuggestionSelected: (String? suggestion) async {
        previousGstmethodselectedValue = GstmethodselectedValue;
        GstmethodselectedValue = suggestion;
        SalesGstMethodController.text = suggestion ?? '';

        bool? confirmChange = await _showDeleteConfimationchangegststatus();

        if (confirmChange != true) {
          setState(() {
            GstmethodselectedValue = previousGstmethodselectedValue;
            SalesGstMethodController.text =
                previousGstmethodselectedValue ?? '';
          });
        } else {
          setState(() {
            GstmethodselectedValue = suggestion;
          });
        }
        FocusScope.of(context).requestFocus(codeFocusNode);
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(maxHeight: 150),
      ),
    );
  }

  Future<bool?> _showDeleteConfimationchangegststatus() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.question_answer, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Questions ??',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure..?? Do you want to change the gst status.. If you click the Yes then all your product details will be clear.. Then you can add new products..',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _changegstmethod();

                    Navigator.pop(context, true);
                    FocusScope.of(context).requestFocus(codeFocusNode);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: subcolor,
                    minimumSize: Size(30.0, 28.0), // Set width and height
                  ),
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    FocusScope.of(context).requestFocus(codeFocusNode);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: subcolor,
                    minimumSize: Size(30.0, 28.0), // Set width and height
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchCustomerName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/SalesCustomer/$cusid';
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
            setState(() {
              CustomerselectedValue = suggestion;
              CustomerNameController.text =
                  suggestion ?? ' ${CustomerselectedValue ?? ''}';
            });

            await fetchSupplierContact();
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
            CustomerselectedValue = suggestion;
            CustomerNameController.text =
                suggestion ?? ' ${CustomerselectedValue ?? ''}';

            fetchSupplierContact();
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

  Future<void> fetchSalesDetails(
      DateTime selectedDate, TextEditingController recordno) async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    // print("dateeeeeee: $date");
    String recordno = BillNoController.text;

    String? cusid = await SharedPrefs.getCusId();
    // final url = '$IpAddress/EditSalesreports/$date/$recordno/';
    final url = '$IpAddress/EditSalesreports/$cusid/$date/$recordno/';

    print("url : $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> data = responseData.first;
          if (data.containsKey('SalesDetails')) {
            final List<dynamic> purchaseDetailsList = data['SalesDetails'];
            tableData.clear();

            BillNoController.text = data['billno'];
            timecontroller.text = data['time'];

            CustomerselectedValue = data['cusname'];
            CustomerNameController.text = CustomerselectedValue ?? '';
            ContactController.text = data['contact'];
            TypeselectedValue = data['type'];
            SalesTypeController.text = TypeselectedValue ?? '';

            PaymentTypeselectedValue = data['paytype'];
            PaytypeController.text = PaymentTypeselectedValue ?? '';

            GstmethodselectedValue = data['taxstatus'];
            SalesGstMethodController.text = GstmethodselectedValue ?? '';
          } else {
            throw Exception(
                'Invalid response format: PurchaseDetails not found');
          }
        } else {
          throw Exception('Invalid response: Empty data');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void fetchDataAndUpdate() {
    fetchSalesDetails(selectedDate, BillNoController);
  }

  void cleartabledata() {
    setState(() {
      tableData.clear();

      CustomerNameController.clear();
      CustomerselectedValue = '';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                Text("Edit Sales Entry", style: HeadingStyle)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 60,
                                ),
                              ],
                            ),
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
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text(
                                  "Bill No",
                                  style: commonLabelTextStyle,
                                ),
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
                                                focusNode: BillNoFocusMode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    _fieldFocusChange(
                                                        context,
                                                        BillNoFocusMode,
                                                        DateFocustNode),
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
                        // Date
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                child:
                                    Text("Date", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 6),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.38,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
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
                                        child: DateTimePicker(
                                            focusNode: DateFocustNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) {
                                              EditSalesableview(
                                                codeFocusNode: codeFocusNode,
                                                onFinalAmountButtonPressed:
                                                    (finalamtcontroller) {
                                                  Finalamtvalues(
                                                      finalamtcontroller);
                                                },
                                                key: _tableSalesKey,
                                                getdata: fetchDataAndUpdate,
                                                cleartabledata: cleartabledata,
                                                selectedsalesdate: selectedDate,
                                                SalesGstMethodController:
                                                    SalesGstMethodController,
                                                ProductSalesTypeController:
                                                    SalesTypeController,
                                                BillNOreset: BillNoController,
                                                time: timecontroller,
                                                SALEStabledata: tableData,
                                                customercontact:
                                                    ContactController,
                                                customername:
                                                    CustomerNameController,
                                                paytype: PaytypeController,
                                                scode: SCodeController,
                                                sname: SNameController,
                                                tableno: tableNocontroller,
                                              );
                                              // print(
                                              //     "sales tabledata : $tableData");
                                              _fieldFocusChange(
                                                context,
                                                DateFocustNode,
                                                showbuttonfocusnode,
                                              );
                                            },
                                            initialValue:
                                                DateTime.now().toString(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            dateLabelText: '',
                                            onChanged: (val) {
                                              setState(() {
                                                selectedDate =
                                                    DateTime.parse(val);
                                              });
                                              print(val);
                                            },
                                            validator: (val) {
                                              print(val);
                                              return null;
                                            },
                                            onSaved: (val) {
                                              setState(() {
                                                selectedDate =
                                                    DateTime.parse(val!);
                                              });
                                              print(val);
                                            },
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
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
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
                                                0.3,
                                        child: TextFormField(
                                            controller: ContactController,
                                            focusNode: CustomerContactFocusMode,
                                            textInputAction:
                                                TextInputAction.next,
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
                                                0.3,
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
                        // if (Responsive.isDesktop(context))
                        //   finalAmtRs(finalAMTcontroller: finalAMTcontroller),

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
                                        Responsive.isDesktop(context) ? 20 : 20,
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
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                                child: Text("GST Method",
                                    style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 25,
                                    top: 8),
                                child: Container(
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
                                        Icons.merge_type_sharp,
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
                                                  0.3,
                                          color: Colors.grey[200],
                                          child: Container(
                                            child: GstmethodDropdown(),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 40,
                                    top: 35),
                                child: Container(
                                  width:
                                      Responsive.isDesktop(context) ? 80 : 64,
                                  child: ElevatedButton(
                                    focusNode: showbuttonfocusnode,
                                    onPressed: () {
                                      fetchDataAndUpdate();
                                      _onShowButtonPressed();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                        backgroundColor: subcolor,
                                        minimumSize: Size(
                                            Responsive.isDesktop(context)
                                                ? 45.0
                                                : 30,
                                            Responsive.isDesktop(context)
                                                ? 31.0
                                                : 25), // Set width and height
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 16.0)),
                                    child: Tooltip(
                                      message: "Double click the Show button",
                                      child: Text('Show',
                                          style: commonWhiteStyle.copyWith(
                                              fontSize: 14)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: Responsive.isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.9
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
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                top: Responsive.isDesktop(
                                                        context)
                                                    ? 15
                                                    : 8),
                                            child: Container(
                                                color: Color.fromRGBO(
                                                    251, 234, 255, 0.973),
                                                // height: 350,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.8
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
                                                      child: EditSalesableview(
                                                        codeFocusNode:
                                                            codeFocusNode,
                                                        key: _tableSalesKey,
                                                        getdata:
                                                            fetchDataAndUpdate,
                                                        cleartabledata:
                                                            cleartabledata,
                                                        selectedsalesdate:
                                                            selectedDate,
                                                        SalesGstMethodController:
                                                            SalesGstMethodController,
                                                        ProductSalesTypeController:
                                                            SalesTypeController,
                                                        BillNOreset:
                                                            BillNoController,
                                                        time: timecontroller,
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
                                                        onFinalAmountButtonPressed:
                                                            (finalamtcontroller) {
                                                          Finalamtvalues(
                                                              finalamtcontroller);
                                                        },
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
                                                        0.8
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
                                                      child: EditSalesableview(
                                                        codeFocusNode:
                                                            codeFocusNode,
                                                        onFinalAmountButtonPressed:
                                                            (finalamtcontroller) {
                                                          Finalamtvalues(
                                                              finalamtcontroller);
                                                        },
                                                        key: _tableSalesKey,
                                                        getdata:
                                                            fetchDataAndUpdate,
                                                        cleartabledata:
                                                            cleartabledata,
                                                        selectedsalesdate:
                                                            selectedDate,
                                                        SalesGstMethodController:
                                                            SalesGstMethodController,
                                                        ProductSalesTypeController:
                                                            SalesTypeController,
                                                        BillNOreset:
                                                            BillNoController,
                                                        time: timecontroller,
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

class finalAmtRs extends StatelessWidget {
  const finalAmtRs({
    Key? key,
    required this.finalAMTcontroller,
  }) : super(key: key);

  final TextEditingController finalAMTcontroller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 10),
      child: Container(
        width: Responsive.isDesktop(context)
            ? 300
            : MediaQuery.of(context).size.width * 0.75,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Container(
                height: 45,
                width: Responsive.isDesktop(context)
                    ? 260
                    : MediaQuery.of(context).size.width * 0.75,
                color: Color.fromARGB(255, 225, 225, 225),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isDesktop(context) ? 0 : 0, top: 0),
                      child: Container(
                        width: Responsive.isDesktop(context) ? 70 : 70,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle form submission
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            backgroundColor: subcolor,
                            minimumSize:
                                Size(45.0, 31.0), // Set width and height
                          ),
                          child: Text(
                            'RS. ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isDesktop(context) ? 20 : 20,
                          top: 11),
                      child: Container(
                        width: Responsive.isDesktop(context) ? 85 : 85,
                        child: Container(
                          height: 24,
                          width: 100,
                          child: Text(
                            "${NumberFormat.currency(symbol: '', decimalDigits: 0).format(double.tryParse(finalAMTcontroller.text) ?? 0)} /-",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
    );
  }
}

class EditSalesableview extends StatefulWidget {
  final Function getdata;
  final Function cleartabledata;
  final DateTime selectedsalesdate;
  final TextEditingController SalesGstMethodController;

  final TextEditingController ProductSalesTypeController;
  final List<Map<String, dynamic>> SALEStabledata;
  final TextEditingController BillNOreset;
  final TextEditingController tableno;
  final TextEditingController time;

  final TextEditingController customername;
  final TextEditingController customercontact;
  final TextEditingController scode;
  final TextEditingController sname;
  final TextEditingController paytype;
  final Function(TextEditingController) onFinalAmountButtonPressed;

  final FocusNode codeFocusNode;

  EditSalesableview({
    required Key key,
    required this.getdata,
    required this.cleartabledata,
    required this.selectedsalesdate,
    required this.ProductSalesTypeController,
    required this.BillNOreset,
    required this.tableno,
    required this.customername,
    required this.customercontact,
    required this.scode,
    required this.sname,
    required this.paytype,
    required this.SALEStabledata,
    required this.onFinalAmountButtonPressed,
    required this.time,
    required this.SalesGstMethodController,
    required this.codeFocusNode,
  }) : super(key: key);

  @override
  State<EditSalesableview> createState() => _EditSalesableviewState();
}

class _EditSalesableviewState extends State<EditSalesableview> {
  String? selectItem;

  void printShowButtonPressed() {
    fetchDataAndUpdate();
    // print('Show button is pressed');
    widget.onFinalAmountButtonPressed(finalamtcontroller);
  }

  refreshData() {
    tableData.clear();
    itemCountController.text = '0';
    taxableamountController.text = '0';
    finaltaxablecontroller.text = '0';
    cgstamtcontroller.text = '0';
    sgstamtcontroller.text = '0';
    finalamtcontroller.text = '0';
    SalesDisPercentageController.text = '0';
    SalesDisAMountController.text = '0';

    print("sales table view table data refresh button is pressed ");
  }

  // void gstchangetabledata() {
  //   tableData.clear();

  //   itemCountController.text = '0';
  //   taxableamountController.text = '0';
  //   finaltaxablecontroller.text = '0';
  //   cgstamtcontroller.text = '0';
  //   sgstamtcontroller.text = '0';
  //   finalamtcontroller.text = '0';
  //   SalesDisPercentageController.text = '0';
  //   SalesDisAMountController.text = '0';

  //   print("sales table view table data refresh button is pressed ");
  // }

  TextEditingController EditsalesIdController = TextEditingController();

  Future<void> fetchSalesDetails(
      DateTime selectedDate, TextEditingController recordno) async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    String recordNumber = recordno.text;

    String? cusid = await SharedPrefs.getCusId();

    final url = '$IpAddress/EditSalesreports/$cusid/$date/$recordNumber';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> data = responseData.first;
          if (data.containsKey('SalesDetails')) {
            final List<dynamic> purchaseDetailsList = data['SalesDetails'];
            tableData.clear();
            for (var purchaseDetail in purchaseDetailsList) {
              Map<String, dynamic> purchaseDetailMap =
                  Map<String, dynamic>.from(purchaseDetail);
              tableData.add({
                'productName': purchaseDetailMap['Itemname'],
                'amount': purchaseDetailMap['rate'],
                'quantity': purchaseDetailMap['qty'],
                'cgstAmt': purchaseDetailMap['cgst'],
                'sgstAmt': purchaseDetailMap['sgst'],
                'Amount': purchaseDetailMap['amount'],
                'retail': purchaseDetailMap['retail'],
                'retailrate': purchaseDetailMap['retailrate'] ?? 0,
                'cgstperc': purchaseDetailMap['cgstperc'],
                'sgstperc': purchaseDetailMap['sgstperc'] ?? 0,
                'makingcost': purchaseDetailMap['makingcost'] ?? 0,
                'category': purchaseDetailMap['category'],
              });
            }
            // print("tableData: $tableData");

            // Update UI if necessary
            setState(() {
              EditsalesIdController.text = data['id'].toString();

              itemCountController.text = data['count'];
              taxableamountController.text = data['taxable'];

              finaltaxablecontroller.text = data['finaltaxable'];
              cgstamtcontroller.text = data['totcgst'];

              sgstamtcontroller.text = data['totcgst'];
              SalesDisAMountController.text = data['discount'];

              SalesDisPercentageController.text = data['disperc'];
              finalamtcontroller.text = data['finalamount'];
              DatetimeCOntroller.text = data['time'];
            });
          } else {
            throw Exception('Invalid response format: SalesDetails not found');
          }
        } else {
          throw Exception('Invalid response: Empty data');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void fetchDataAndUpdate() {
    fetchSalesDetails(widget.selectedsalesdate, widget.BillNOreset);
    // print('Show button is pressed');
  }

  TextEditingController ProductCodeController = TextEditingController();
  TextEditingController ProductNameController = TextEditingController();
  TextEditingController ProductAmountController = TextEditingController();
  TextEditingController QuantityController = TextEditingController();
  TextEditingController TotalAmtController = TextEditingController();
  TextEditingController ProductMakingCostController = TextEditingController();

  TextEditingController CGSTperccontroller = TextEditingController();
  TextEditingController SGSTPercController = TextEditingController();
  TextEditingController CGSTAmtController = TextEditingController();
  TextEditingController SGSTAmtController = TextEditingController();
  TextEditingController FinalAmtController = TextEditingController();

  TextEditingController tableTaxableamountcontroller = TextEditingController();
  TextEditingController SalesGstMethodController = TextEditingController();
  TextEditingController ProductCategoryController = TextEditingController();

  late List<Map<String, dynamic>> tableData;
  double totalAmount = 0.0;

  // FocusNode codeFocusNode = FocusNode();
  FocusNode itemFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode quantityFocusNode = FocusNode();
  FocusNode finaltotalFocusNode = FocusNode();
  FocusNode addbuttonFocusNode = FocusNode();

  FocusNode discountpercFocusNode = FocusNode();
  FocusNode discountAmtFocusNode = FocusNode();
  FocusNode FinalAmtFocusNode = FocusNode();
  FocusNode SavebuttonFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void initState() {
    super.initState();
    fetchProductNameList();
    // fetchGSTMethod();
    tableData = widget.SALEStabledata;
    TotalAmtController.text = "0";
    QuantityController.text = "0";
    ProductAmountController.text = "0";
    SalesDisPercentageController.text = "0";
    FinalAmtController.text = "0";
    SalesDisAMountController.text = "0";

    widget.getdata();
  }

  @override
  void dispose() {
    // codeFocusNode.dispose();
    itemFocusNode.dispose();
    amountFocusNode.dispose();
    quantityFocusNode.dispose();
    finaltotalFocusNode.dispose();
    addbuttonFocusNode.dispose();
    discountpercFocusNode.dispose();
    discountAmtFocusNode.dispose();
    FinalAmtFocusNode.dispose();
    SavebuttonFocusNode.dispose();

    super.dispose();
  }

  List<String> ProductNameList = [];

  Future<void> fetchProductNameList() async {
    String? cusid = await SharedPrefs.getCusId();

    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductNameList.addAll(
              results.map<String>((item) => item['name'].toString()));
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

  String? ProductNameSelected;

  int? _selectedProductnameIndex;

  bool _isProductnameOptionsVisible = false;
  int? _ProductnamehoveredIndex;
  Widget _buildProductnameDropdown() {
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
                    color: Colors.grey[100],
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.095
                        : MediaQuery.of(context).size.width * 0.25,
                    child: ProductnameDropdown()),
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
                      child: Container(
                        width: 1350,
                        height: 800,
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            AddProductDetailsPage(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchproductName();
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

  Widget ProductnameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProductnameIndex = currentIndex + 1;
                ProductNameController.text = ProductNameList[currentIndex + 1];
                _isProductnameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductnameIndex = currentIndex - 1;
                ProductNameController.text = ProductNameList[currentIndex - 1];
                _isProductnameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            FocusScope.of(context).requestFocus(widget.codeFocusNode);
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: itemFocusNode,
          onSubmitted: (String? suggestion) async {
            setState(() {
              ProductNameSelected = suggestion;
              ProductNameController.text =
                  suggestion ?? ' ${ProductNameSelected ?? ''}';
            });

            widget.ProductSalesTypeController.text;
            await fetchproductcode();
            updateTotal();
            updatetaxableamount();
            updateCGSTAmount();
            updateSGSTAmount();
            updateFinalAmount();

            FocusScope.of(context).requestFocus(quantityFocusNode);

            _fieldFocusChange(context, itemFocusNode, quantityFocusNode);
          },
          controller: ProductNameController,
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
              _isProductnameOptionsVisible = true;
              ProductNameSelected = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProductnameOptionsVisible && pattern.isNotEmpty) {
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
              _ProductnamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProductnamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductnameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductnameIndex == null &&
                          ProductNameList.indexOf(ProductNameController.text) ==
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
            ProductNameSelected = suggestion;
            ProductNameController.text =
                suggestion ?? ' ${ProductNameSelected ?? ''}';

            widget.ProductSalesTypeController.text;
            fetchproductcode();
            updateTotal();
            updatetaxableamount();
            updateCGSTAmount();
            updateSGSTAmount();
            updateFinalAmount();

            FocusScope.of(context).requestFocus(quantityFocusNode);
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

  bool isProductAlreadyExists(String productName) {
    // Assuming table data is stored in a List<Map<String, dynamic>> called tableData
    for (var item in tableData) {
      if (item['productName'] == productName) {
        return true;
      }
    }
    return false;
  }

  void productalreadyexist() {
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
                'This product is already in the table data.',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  Future<void> fetchproductName() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid';
    String ProductCode =
        ProductCodeController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductCodeController Name: $ProductCode");

    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each customer entry
          for (var entry in results) {
            if (entry['code'].toString().toLowerCase() == ProductCode) {
              // Convert to lowercase
              // Retrieve the contact number and address for the customer
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }
              String name = entry['name'];
              String agentId = entry['id'].toString();
              String makingcost = entry['makingcost'];
              String category = entry['category'];

              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (ProductCode.isNotEmpty) {
                ProductNameController.text = name;
                ProductAmountController.text = amount;
                ProductMakingCostController.text = makingcost;
                ProductCategoryController.text = category;
                CGSTperccontroller.text = cgstperc;
                SGSTPercController.text = sgstperc;

                contactFound = true;
                break; // Exit the loop once the contact number is found
              }
            }
          }

          // print("CGst Percentages:${CGSTperccontroller.text}");
          // print("Sgst Percentages:${SGSTPercController.text}");
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

  Future<void> fetchproductcode() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid';
    String productName =
        ProductNameController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    print("ProductNameController Name: $productName");
    String salestype = widget.ProductSalesTypeController.text;
    print("ProductSalesTypeController Name: $salestype");

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each product entry
          for (var entry in results) {
            if (entry['name'].toString().toLowerCase() == productName) {
              // Convert to lowercase
              // Retrieve the code and id for the product
              String code = entry['code'];
              String agentId = entry['id'].toString();

              // Determine the amount based on the salestype
              String amount = '';
              if (salestype.toLowerCase() == 'dinein') {
                amount = entry['amount'];
              } else if (salestype.toLowerCase() == 'takeaway') {
                amount = entry['wholeamount'];
              }

              String makingcost = entry['makingcost'];
              String category = entry['category'];
              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (productName.isNotEmpty) {
                ProductCodeController.text = code;
                CGSTperccontroller.text = cgstperc;
                ProductMakingCostController.text = makingcost;
                ProductCategoryController.text = category;

                SGSTPercController.text = sgstperc;
                ProductAmountController.text = amount;

                contactFound = true;
                break; // Exit the loop once the product information is found
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or product information found
            break;
          }
        } else {
          throw Exception(
              'Failed to load product information: ${response.reasonPhrase}');
        }
      }

      // Print a message if product information not found
      if (!contactFound) {
        // print("No product information found for $productName");
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  void updateCGSTAmount() {
    double taxableAmount =
        double.tryParse(tableTaxableamountcontroller.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * cgstPercentage);
    // Calculate the CGST amount
    double cgstAmount = numerator / 100;

    // Update the CGST amount controller
    CGSTAmtController.text = cgstAmount.toStringAsFixed(2);
    // print("CGST amont = ${CGSTAmtController.text}");
  }

  void updateSGSTAmount() {
    double taxableAmount =
        double.tryParse(tableTaxableamountcontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * sgstPercentage);
    // Calculate the CGST amount
    double sgstAmount = numerator / 100;

    // Update the CGST amount controller
    SGSTAmtController.text = sgstAmount.toStringAsFixed(2);
    // print("SGZGST amont = ${SGSTAmtController.text}");
  }

  void updateTotal() {
    double rate = double.tryParse(ProductAmountController.text) ?? 0;
    double quantity = double.tryParse(QuantityController.text) ?? 0;
    double total = rate * quantity;
    TotalAmtController.text =
        total.toStringAsFixed(2); // Format total to 2 decimal places
    // Taxableamountcontroller.text = total.toStringAsFixed(2);
  }

  void updatetaxableamount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;
    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(SGSTPercController.text) ?? 0;

    double numeratorPart1 = total;

    print(
        "updatetaxableamount sales gst method : ${widget.SalesGstMethodController.text}");

    if (widget.SalesGstMethodController.text == "Excluding") {
      // Calculate taxable amount excluding GST
      double taxableAmount = numeratorPart1;
      tableTaxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      print("total taxable amount = ${tableTaxableamountcontroller.text}");
    } else if (widget.SalesGstMethodController.text == "Including") {
      double cgstsgst = cgstPercentage + sgstPercentage;
      double cgstnumerator = numeratorPart1 * cgstPercentage;
      double cgstdenominator = 100 + cgstsgst;
      double cgsttaxable = cgstnumerator / cgstdenominator;
      double sgstnumerator = numeratorPart1 * sgstPercentage;
      double sgstdenominator = 100 + cgstsgst;
      double sgsttaxable = sgstnumerator / sgstdenominator;

      double taxableAmount = numeratorPart1 - (cgsttaxable + sgsttaxable);

      tableTaxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("cgst taxable amount : $cgsttaxable");
      // print("sgst taxable amount : $sgsttaxable");
      // print("Total taxable amount : $taxableAmount");
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else {
      double taxableAmount = numeratorPart1;
      tableTaxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    }
  }

  void updateFinalAmount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;

    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double taxableAmount =
        double.tryParse(tableTaxableamountcontroller.text) ?? 0;
    double denominator = cgstAmount + sgstAmount;
    print(
        "updateFinalAmount sales gst method : ${widget.SalesGstMethodController.text}");

    if (widget.SalesGstMethodController.text == "Excluding") {
      double finalAmount = taxableAmount + denominator;
      // print("FIanl amount = ${taxableAmount} + ${denominator}");

      // Update the final amount controller
      FinalAmtController.text = finalAmount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    } else if (widget.SalesGstMethodController.text == "Including") {
      double totalfinalamount = total;
      FinalAmtController.text = totalfinalamount.toStringAsFixed(2);
    } else {
      double taxableAmount = total;
      FinalAmtController.text = taxableAmount.toStringAsFixed(2);
    }
  }

  int nextId = 1;
  bool updateenable = false;
  void saveData() {
    // Check if any required field is empty
    if (ProductCodeController.text.isEmpty ||
        ProductNameController.text.isEmpty ||
        ProductAmountController.text.isEmpty ||
        QuantityController.text.isEmpty ||
        FinalAmtController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (QuantityController.text == '0' ||
        QuantityController.text == '') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity Check'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text('Kindly enter the quantity , Quantity must above 0'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productName = ProductNameController.text;
      String amount = ProductAmountController.text;
      String quantity = QuantityController.text;
      String makingcost = ProductMakingCostController.text;
      String category = ProductCategoryController.text;
      String totalamt = FinalAmtController.text;
      String taxable = tableTaxableamountcontroller.text;
      String cgstPercentage = widget.SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTperccontroller.text;
      String sgstPercentage = widget.SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTPercController.text;
      String cgstAmount = widget.SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTAmtController.text;
      String sgstAmount = widget.SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTAmtController.text;

      bool productExists = false;

      for (var item in tableData) {
        if (item['productName'] == productName) {
          item['quantity'] =
              (int.parse(item['quantity']) + int.parse(quantity)).toString();

          item['Amount'] =
              (double.parse(item['Amount']) + double.parse(totalamt))
                  .toString();
          item['retail'] =
              (double.parse(item['retail']) + double.parse(taxable)).toString();
          item['cgstAmt'] =
              (double.parse(item['cgstAmt']) + double.parse(cgstAmount))
                  .toString();
          item['sgstAmt'] =
              (double.parse(item['sgstAmt']) + double.parse(sgstAmount))
                  .toString();
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        setState(() {
          tableData.add({
            'id': nextId++,
            'productName': productName,
            'amount': amount,
            'quantity': quantity,
            "cgstAmt": cgstAmount,
            "sgstAmt": sgstAmount,
            "Amount": totalamt,
            "retail": taxable,
            "retailrate": amount,
            "cgstperc": cgstPercentage,
            "sgstperc": sgstPercentage,
            "makingcost": makingcost,
            "category": category,
          });
        });
      }

      setState(() {
        ProductCodeController.clear();
        ProductNameController.clear();
        ProductAmountController.clear();
        QuantityController.clear();
        FinalAmtController.clear();
        ProductNameSelected = '';
      });

      updateItemCount();
      updateTaxableAmount();
      updatefinalTaxableAmount();
      updateCGSTtabletotal();
      updateSGSTtabletotal();
      updatefinaltabletotalAmount();
      widget.onFinalAmountButtonPressed(finalamtcontroller);
    }
  }

  Future<void> post_stockItemsproductadd() async {
    try {
      String productName = ProductNameController.text;
      int quantity = int.tryParse(QuantityController.text) ?? 0;

      List<Map<String, dynamic>> productList = await salesProductList();

      Map<String, dynamic>? product = productList.firstWhere(
        (element) => element['name'] == productName,
        orElse: () => {'stock': 'no', 'id': -1},
      );

      String stockStatus = product['stock'];
      int productId = product['id'];

      if (stockStatus == 'Yes') {
        double stockValue =
            double.tryParse(product['stockvalue'].toString()) ?? 0;

        // Subtract the quantity from the stock value
        double updatedStockValue = stockValue - quantity;

        String? cusid = await SharedPrefs.getCusId();
        // Prepare the data to be sent to the server
        Map<String, dynamic> putData = {
          "cusid": cusid,
          "stockvalue": updatedStockValue.toString(),
        };

        // Convert the data to JSON format
        String jsonData = jsonEncode(putData);

        // Send the PUT request to update the stock value
        var response = await http.put(
          Uri.parse('$IpAddress/SettingsProductDetailsalldatas/$productId/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );
        print(
            "urll stock : $IpAddress/SettingsProductDetailsalldatas/$productId/");
        // Check the response status
        if (response.statusCode == 200) {
          print(
              'Added Product Stock value updated successfully for product: $productName');
          // Proceed with further actions if needed
        } else {
          print(
              'Failed to update stock value for product: $productName. Error code: ${response.statusCode}');
          if (response.body != null && response.body.isNotEmpty) {
            print('Response body: ${response.body}');
          }
        }
      }
    } catch (error) {
      print('Error retrieving product list: $error');
    }
  }

  Future<void> post_stockItemsproductdelete(
      String productName, int quantity) async {
    try {
      // print('Fetching product list...');
      List<Map<String, dynamic>> productList = await salesProductList();

      // print('Searching for product: $productName');
      Map<String, dynamic>? product = productList.firstWhere(
        (element) => element['name'] == productName,
        orElse: () => {'stock': 'no', 'id': -1},
      );

      String stockStatus = product['stock'];
      int productId = product['id'];

      // print('Stock status for product $productName: $stockStatus');
      // print('Product ID for product $productName: $productId');

      if (stockStatus == 'Yes' && productId != -1) {
        // Fetch the product details from the specified URL
        var response = await http.get(
          Uri.parse('$IpAddress/SettingsProductDetailsalldatas/$productId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          var productDetails = jsonDecode(response.body);
          double stockValue =
              double.tryParse(productDetails['stockvalue'].toString()) ?? 0;

          // print('Stock value for product $productName: $stockValue');

          // Additional logic if necessary
          // For example, you can update the stock value by subtracting the quantity
          double updatedStockValue = stockValue + quantity;

          String? cusid = await SharedPrefs.getCusId();

          Map<String, dynamic> putData = {
            "cusid": cusid,
            "stockvalue": updatedStockValue.toString(),
          };

          String jsonData = jsonEncode(putData);

          // Send the PUT request to update the stock value if necessary
          var updateResponse = await http.put(
            Uri.parse('$IpAddress/SettingsProductDetailsalldatas/$productId/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonData,
          );

          if (updateResponse.statusCode == 200) {
            print(
                'Deleted product stock value updated successfully for product: $productName');
          } else {
            print(
                'Failed to update stock value for product: $productName. Error code: ${updateResponse.statusCode}');
            if (updateResponse.body != null && updateResponse.body.isNotEmpty) {
              print('Response body: ${updateResponse.body}');
            }
          }
        } else {
          print(
              'Failed to fetch product details for product: $productName. Error code: ${response.statusCode}');
          if (response.body != null && response.body.isNotEmpty) {
            print('Response body: ${response.body}');
          }
        }
      } else {
        print(
            'Stock status for product $productName is not "Yes" or invalid product ID.');
      }
    } catch (error) {
      print('Error retrieving product list: $error');
    }
  }

  TextEditingController UpdateidController = TextEditingController();

  void UpdateData() {
    // Check if any required field is empty
    if (ProductCodeController.text.isEmpty ||
        ProductNameController.text.isEmpty ||
        ProductAmountController.text.isEmpty ||
        QuantityController.text.isEmpty ||
        FinalAmtController.text.isEmpty ||
        UpdateidController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (QuantityController.text == '0' ||
        QuantityController.text == '') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity Check'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text('Kindly enter the quantity, Quantity must be above 0'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (widget.paytype.text.toLowerCase() == 'credit' &&
        widget.customername.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details, when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(widget.codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productCode = ProductCodeController.text;
      String productName = ProductNameController.text;
      String amount = ProductAmountController.text;
      String quantity = QuantityController.text;
      String makingcost = ProductMakingCostController.text;
      String category = ProductCategoryController.text;
      String totalamt = FinalAmtController.text;
      String taxable = tableTaxableamountcontroller.text;

      String cgstPercentage = SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTperccontroller.text;
      String sgstPercentage = SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTPercController.text;
      String cgstAmount = SalesGstMethodController.text == "NonGst"
          ? '0'
          : CGSTAmtController.text;
      String sgstAmount = SalesGstMethodController.text == "NonGst"
          ? '0'
          : SGSTAmtController.text;

      // Convert UpdateidController.text to integer
      int idToUpdate = int.tryParse(UpdateidController.text) ?? -1;

      if (idToUpdate == -1) {
        WarninngMessage(context); // Invalid ID
        return;
      }

      bool entryExists = false;
      setState(() {
        for (var entry in tableData) {
          if (entry['id'] == idToUpdate) {
            // Update the existing entry
            entry['productCode'] = productCode;
            entry['productName'] = productName;
            entry['amount'] = amount;
            entry['quantity'] = quantity;
            entry['cgstAmt'] = cgstAmount;
            entry['sgstAmt'] = sgstAmount;
            entry['Amount'] = totalamt;
            entry['retail'] = taxable;
            entry['retailrate'] = amount;
            entry['cgstperc'] = cgstPercentage;
            entry['sgstperc'] = sgstPercentage;
            entry['makingcost'] = makingcost;
            entry['category'] = category;
            entryExists = true;
            break;
          }
        }

        if (!entryExists) {
          WarninngMessage(context); // ID not found
        }
      });

      // Clear text fields
      setState(() {
        updateenable = false;
        ProductCodeController.clear();
        ProductNameController.clear();
        ProductAmountController.clear();
        QuantityController.clear();
        FinalAmtController.clear();
        ProductNameSelected = '';
      });

      updatefinaltabletotalAmount();
      // processNewSalesEntry(context, FINALAMTCONTROLLWE);
    }
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: SingleChildScrollView(
          child: Container(
            height: Responsive.isDesktop(context) ? screenHeight * 0.55 : 320,
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
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.78
                    : MediaQuery.of(context).size.width * 1.8,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  SizedBox(width: 1),
                                  Text("Item",
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
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Rate",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle)
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
                                children: [
                                  Icon(
                                    Icons.add_box,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle)
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
                                children: [
                                  Icon(
                                    Icons.local_atm,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Cgst ₹",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle)
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
                                children: [
                                  Icon(
                                    Icons.local_atm,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Sgst ₹",
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
                                children: [
                                  Icon(
                                    Icons.currency_exchange_outlined,
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
                                children: [
                                  Icon(
                                    Icons.currency_exchange_outlined,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Retail",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   height: Responsive.isDesktop(context) ? 25 : 30,
                        //   width: 80,
                        //   decoration: TableHeaderColor,
                        //   child: Center(
                        //     child: Row(
                        //       children: [
                        //         Icon(
                        //           Icons.currency_exchange_sharp,
                        //           size: 15,
                        //           color: Colors.blue,
                        //         ),
                        //         SizedBox(width: 5),
                        //         Text("RetailRate",
                        //             textAlign: TextAlign.center,
                        //             style: commonLabelTextStyle),
                        //       ],
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
                                children: [
                                  Icon(
                                    Icons.pie_chart,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("CGST %",
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
                                children: [
                                  Icon(
                                    Icons.pie_chart,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("SGST %",
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
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
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
                  // if (tableData.isNotEmpty)
                  //   ...tableData.map((data) {
                  if (tableData.isNotEmpty)
                    ...tableData.asMap().entries.map((entry) {
                      int index = entry.key;

                      Map<String, dynamic> data = entry.value;

                      var id = data['id'].toString();
                      var productName = data['productName'].toString();
                      var amount = data['amount'].toString();
                      var quantity = data['quantity'].toString();
                      var cgstAmt = data['cgstAmt'].toString();
                      var sgstAmt = data['sgstAmt'].toString();
                      var Amount = data['Amount'].toString();
                      var retail = data['retail'].toString();
                      var retailrate = data['retailrate'] ?? 0;

                      var cgstperc = data['cgstperc'].toString();
                      var sgstperc = data['sgstperc'] ?? 0;
                      var makingcost = data['makingcost'] ?? 0;
                      var category = data['category'].toString();
                      // print("categoryyy: $category");
                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, top: 3, bottom: 3, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                  child: Text(productName,
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
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(quantity,
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
                                  child: Text(cgstAmt,
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
                                  child: Text(sgstAmt,
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
                                  child: Text(Amount,
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
                                  child: Text(retail,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
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
                            //       child: Text(retailrate,
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
                                  child: Text(cgstperc,
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
                                  child: Text(sgstperc,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 255.0,
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
                                      // Padding(
                                      //   padding: const EdgeInsets.only(left: 0),
                                      //   child: Container(
                                      //     child: IconButton(
                                      //       icon: Icon(
                                      //         Icons.edit_square,
                                      //         color: Colors.blue,
                                      //         size: 18,
                                      //       ),
                                      //       onPressed: () {
                                      //         print(
                                      //             "print the ungiueeeee : $id");
                                      //         ProductCodeController.text =
                                      //             data['productCode']
                                      //                 .toString();
                                      //         ProductNameController.text =
                                      //             data['productName']
                                      //                 .toString();
                                      //         ProductAmountController.text =
                                      //             data['amount'].toString();
                                      //         QuantityController.text =
                                      //             data['quantity'].toString();
                                      //         FinalAmtController.text =
                                      //             data['Amount'].toString();
                                      //         UpdateidController.text =
                                      //             data['id'].toString();
                                      //         setState(() {
                                      //           updateenable = true;
                                      //           FocusScope.of(context)
                                      //               .requestFocus(
                                      //                   quantityFocusNode);
                                      //         });
                                      //       },
                                      //       color: Colors.black,
                                      //     ),
                                      //   ),
                                      // ),

                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Container(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  index,
                                                  productName,
                                                  int.parse(quantity));
                                            },
                                            color: Colors.black,
                                          ),
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
                    }).toList()
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int getProductCount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
  }

  double getTotalTaxable(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['retail']!) ?? 0.0;
      totalQuantity += quantity;
    }
    totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
    return totalQuantity;
  }

  double gettabletotalqty(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['quantity']!) ?? 0.0;
      totalQuantity += quantity;
    }
    totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
    return totalQuantity;
  }

  double getTotalFinalTaxable(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['retail']!) ?? 0.0;
      totalQuantity += quantity;
    }
    totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
    return totalQuantity;
  }

  double getTotalCGSTAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['cgstAmt']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  double getTotalSGSTAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['sgstAmt']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['Amount']!) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  double gettaxableAmtCGST0(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 0) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST25(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 2.5) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST6(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 6) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST9(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 9) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtCGST14(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      if (cgstPercentage != null && cgstPercentage == 14) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST0(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 0) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 0 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST25(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 2.5) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 2.5 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST6(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 6) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 6 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST9(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 9) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 9 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double gettaxableAmtSGST14(List<Map<String, dynamic>> tableData) {
    double taxableAmount = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      if (sgstPercentage != null && sgstPercentage == 14) {
        // Parse 'taxableAmount' to double before adding it to taxableAmount
        double? parsedTaxableAmount = double.tryParse(data['retail']);
        if (parsedTaxableAmount != null) {
          taxableAmount += parsedTaxableAmount;
        }
      }

      // print("SGSt 14 :$taxableAmount ");
    }
    return taxableAmount;
  }

  double getFinalAmtCGST0(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 0) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    // print("Total amount with CGST 0%: $totalAmountCGST0 ");
    return totalAmountCGST0;
  }

  double getFinalAmtCGST25(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 2.5) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtCGST6(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 6) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtCGST9(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 9) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtCGST14(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? cgstPercentage = double.tryParse(data['cgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (cgstPercentage != null && cgstPercentage == 14) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST0(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 0) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST25(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 2.5) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST6(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 6) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST9(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 9) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  double getFinalAmtSGST14(List<Map<String, dynamic>> tableData) {
    double totalAmountCGST0 = 0.0;
    for (var data in tableData) {
      double? sgstPercentage = double.tryParse(data['sgstperc'] ?? '0');
      double? parsedFinalAmount = double.tryParse(data['Amount'] ?? '0');

      if (sgstPercentage != null && sgstPercentage == 14) {
        if (parsedFinalAmount != null) {
          totalAmountCGST0 += parsedFinalAmount;
        }
      }
    }
    return totalAmountCGST0;
  }

  TextEditingController SalesDisAMountController = TextEditingController();
  TextEditingController SalesDisPercentageController = TextEditingController();
  TextEditingController CGSTPercent0 = TextEditingController();

  TextEditingController CGSTPercent25 = TextEditingController();

  TextEditingController CGSTPercent6 = TextEditingController();

  TextEditingController CGSTPercent9 = TextEditingController();

  TextEditingController CGSTPercent14 = TextEditingController();
  TextEditingController SGSTPercent0 = TextEditingController();

  TextEditingController SGSTPercent25 = TextEditingController();

  TextEditingController SGSTPercent6 = TextEditingController();

  TextEditingController SGSTPercent9 = TextEditingController();

  TextEditingController SGSTPercent14 = TextEditingController();

  List<Map<String, dynamic>> productList = [];
  Future<List<Map<String, dynamic>>> salesProductList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          for (var product in results) {
            // Extracting required fields and creating a map
            Map<String, dynamic> productMap = {
              'id': product['id'],
              'name': product['name'],
              'stock': product['stock'],
              'stockvalue': product['stockvalue']
            };

            // Adding the map to the list
            productList.add(productMap);
          }
          // print("product list : $productList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }

    return productList;
  }

  TextEditingController QuantityContController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  TextEditingController taxableamountController = TextEditingController();
  TextEditingController finaltaxablecontroller = TextEditingController();
  TextEditingController cgstamtcontroller = TextEditingController();
  TextEditingController sgstamtcontroller = TextEditingController();
  TextEditingController finalamtcontroller = TextEditingController();

  TextEditingController DatetimeCOntroller = TextEditingController();
  void updateItemCount() {
    itemCountController.text = tableData.length.toString();
    // print("itemcount of the table data : ${itemCountController.text}");
  }

  void updateTaxableAmount() {
    double totalTaxable = getTotalTaxable(tableData);
    taxableamountController.text = totalTaxable.toStringAsFixed(2);
  }

  void updatefinalTaxableAmount() {
    double finaltotalTaxable = getTotalTaxable(tableData);
    finaltaxablecontroller.text = finaltotalTaxable.toStringAsFixed(2);
  }

  void updateCGSTtabletotal() {
    double totalcgst = getTotalCGSTAmt(tableData);
    cgstamtcontroller.text = totalcgst.toStringAsFixed(2);
  }

  void updateSGSTtabletotal() {
    double totalsgst = getTotalSGSTAmt(tableData);
    cgstamtcontroller.text = totalsgst.toStringAsFixed(2);
  }

  void updatefinaltabletotalAmount() {
    double finaltotalamount = getTotalFinalAmt(tableData);
    finalamtcontroller.text = finaltotalamount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.1;
    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.07;
    return Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 2,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 10, top: 0),
                child: Text("Code", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 15, top: 4),
                child: Container(
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.numbers, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                          height: 24,
                          width: Responsive.isDesktop(context)
                              ? desktoptextfeildwidth
                              : MediaQuery.of(context).size.width * 0.26,
                          color: Colors.grey[100],
                          child: Focus(
                            onKey: (FocusNode node, RawKeyEvent event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  FocusScope.of(context)
                                      .requestFocus(discountpercFocusNode);
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.enter) {
                                  FocusScope.of(context)
                                      .requestFocus(itemFocusNode);
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: TextFormField(
                              controller: ProductCodeController,
                              textInputAction: TextInputAction.next,
                              focusNode: widget.codeFocusNode,
                              onFieldSubmitted: (_) => _fieldFocusChange(
                                  context, widget.codeFocusNode, itemFocusNode),
                              onChanged: (newValue) {
                                widget.ProductSalesTypeController.text;
                                fetchproductName();
                                updateTotal();
                                updateFinalAmount();
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 180, 180, 180),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 7.0,
                                ),
                              ),
                              style: textStyle,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 10 : 20, top: 0),
                child: Text("Item", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 20, top: 0),
                child: Container(
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.12
                        : MediaQuery.of(context).size.width * 0.38,
                    child: _buildProductnameDropdown()),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 10, top: 0),
                child: Text("Amount", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 30 : 15, top: 4),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? desktoptextfeildwidth
                            : MediaQuery.of(context).size.width * 0.285,

                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: TextFormField(
                            readOnly: true,
                            controller: ProductAmountController,
                            onChanged: (newValue) {
                              fetchproductName();
                              updatetaxableamount();
                              updateCGSTAmount();
                              updateSGSTAmount();
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 180, 180, 180),
                                    width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: const Color.fromARGB(0, 0, 0, 0),
                                    width: 1.0),
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
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 20, top: 0),
                child: Text("Quantity", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 25, top: 4),
                child: Container(
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_alert_sharp, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? desktoptextfeildwidth
                            : MediaQuery.of(context).size.width * 0.285,

                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: Focus(
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowDown) {
                                FocusScope.of(context)
                                    .requestFocus(discountpercFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowLeft) {
                                FocusScope.of(context)
                                    .requestFocus(itemFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                FocusScope.of(context)
                                    .requestFocus(addbuttonFocusNode);
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                              controller: QuantityController,
                              focusNode: quantityFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                String productName = ProductNameController.text;
                                int quantity = int.tryParse(value) ?? 0;

                                salesProductList().then(
                                    (List<Map<String, dynamic>> productList) {
                                  Map<String, dynamic>? product =
                                      productList.firstWhere(
                                    (element) => element['name'] == productName,
                                    orElse: () => {'stock': 'no'},
                                  );

                                  String stockStatus = product['stock'];

                                  if (stockStatus == 'No') {
                                    FocusScope.of(context)
                                        .requestFocus(finaltotalFocusNode);
                                  } else if (stockStatus == 'Yes') {
                                    double stockValue = double.tryParse(
                                            product['stockvalue'].toString()) ??
                                        0;

                                    if (quantity > stockValue) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Stock Check'),
                                              IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                          content: Container(
                                            width: 500,
                                            child: Text(
                                                'The entered quantity exceeds the available stock value (${stockValue}). '
                                                'Do you want to proceed by deducting this excess quantity from the stock?'),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();

                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            itemFocusNode);
                                                  },
                                                  child: Text('Yes Add'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    QuantityController.text =
                                                        stockValue.toString();
                                                    Navigator.of(context).pop();
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            finaltotalFocusNode);
                                                  },
                                                  child: Text('Skip'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      _fieldFocusChange(
                                          context,
                                          quantityFocusNode,
                                          finaltotalFocusNode);
                                    }
                                  }
                                });
                              },
                              onChanged: (newValue) {
                                updateTotal();
                                updatetaxableamount();
                                updateCGSTAmount();
                                updateSGSTAmount();
                                updateFinalAmount();
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 180, 180, 180),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
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
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 10, top: 0),
                child: Text("Total", style: commonLabelTextStyle),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 15, top: 4),
                child: Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.14
                      : MediaQuery.of(context).size.width * 0.38,
                  child: Row(
                    children: [
                      Icon(
                        Icons.paid_outlined, // Your icon here
                        size: 17,
                      ),
                      SizedBox(
                          width: 5), // Adjust spacing between icon and text

                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.1
                            : MediaQuery.of(context).size.width * 0.31,
                        color: Colors.grey[100],
                        child: Focus(
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowDown) {
                                FocusScope.of(context)
                                    .requestFocus(discountpercFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.arrowLeft) {
                                FocusScope.of(context)
                                    .requestFocus(quantityFocusNode);
                                return KeyEventResult.handled;
                              } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                // FocusScope.of(context)
                                //     .requestFocus(addbuttonFocusNode);
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                              readOnly: true,
                              controller: FinalAmtController,
                              focusNode: finaltotalFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                // Move focus to the save button
                                FocusScope.of(context)
                                    .requestFocus(addbuttonFocusNode);
                              },
                              onChanged: (newValue) {},
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 180, 180, 180),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
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
                ),
              ),
            ],
          ),
        ),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 20 : 20,
                    top: Responsive.isDesktop(context) ? 25 : 4),
                child: Container(
                  width: Responsive.isDesktop(context) ? 60 : 60,
                  child: ElevatedButton(
                    focusNode: addbuttonFocusNode,
                    onPressed: () {
                      post_stockItemsproductadd();
                      saveData();
                      FocusScope.of(context).requestFocus(widget.codeFocusNode);
                      // print("finalamount :: ${FinallyyyAmounttts.text}");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        backgroundColor: subcolor,
                        minimumSize: Size(45.0, 31.0), // Set width and height
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0)),
                    child: Text('Add',
                        style: commonWhiteStyle.copyWith(fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.01
                  : 0,
              bottom: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.01
                  : 0),
          child: tableView(),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: Responsive.isDesktop(context) ? 20 : 0,
            left: !Responsive.isDesktop(context) ? 00 : 0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
                color: Color.fromARGB(255, 255, 255, 255),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 12,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isMobile(context) ||
                                        Responsive.isTablet(context)
                                    ? 15
                                    : 15,
                                right: 0,
                                bottom: 5),
                            child: Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("No.Of.Items: ",
                                                // "No.Of.Items: ${getProductCountCallback(tableData)}",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .align_vertical_center_sharp, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: TextField(
                                                        controller:
                                                            itemCountController,
                                                        readOnly: true,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
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
                                    SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("Taxable Amt ₹",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .add_business_outlined, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: TextField(
                                                        readOnly: true,
                                                        controller:
                                                            taxableamountController,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
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
                                    if (Responsive.isDesktop(context))
                                      SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("Discount %",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .discount, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text
                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: Focus(
                                                      onKey: (FocusNode node,
                                                          RawKeyEvent event) {
                                                        if (event
                                                            is RawKeyDownEvent) {
                                                          if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowDown) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    FinalAmtFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowRight) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    discountAmtFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowUp) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(widget
                                                                    .codeFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .enter) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    FinalAmtFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          }
                                                        }
                                                        return KeyEventResult
                                                            .ignored;
                                                      },
                                                      child: TextFormField(
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          focusNode:
                                                              discountpercFocusNode,
                                                          onFieldSubmitted: (_) =>
                                                              _fieldFocusChange(
                                                                  context,
                                                                  discountpercFocusNode,
                                                                  discountAmtFocusNode),
                                                          controller:
                                                              SalesDisPercentageController,
                                                          onChanged:
                                                              (newValue) {
                                                            calculateDiscountAmount();
                                                            CalculateCGSTFinalAmount();
                                                            CalculateSGSTFinalAmount();
                                                            // calculatetotalAmount();
                                                            calculateFinalTaxableAmount();
                                                            calculateFinaltotalAmount();
                                                            finalamountcontainer(
                                                                finalamtcontroller);
                                                            SalesDisPercentageController
                                                                    .selection =
                                                                TextSelection.fromPosition(
                                                                    TextPosition(
                                                                        offset: SalesDisPercentageController
                                                                            .text
                                                                            .length));
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  width: 1.0),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.0),
                                                            ),
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 7.0,
                                                            ),
                                                          ),
                                                          style: textStyle),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("Discount ₹",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .rate_review, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: Focus(
                                                      onKey: (FocusNode node,
                                                          RawKeyEvent event) {
                                                        if (event
                                                            is RawKeyDownEvent) {
                                                          if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowDown) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    FinalAmtFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowLeft) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    discountpercFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowUp) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(widget
                                                                    .codeFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .enter) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    FinalAmtFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          }
                                                        }
                                                        return KeyEventResult
                                                            .ignored;
                                                      },
                                                      child: TextFormField(
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          focusNode:
                                                              discountAmtFocusNode,
                                                          onFieldSubmitted: (_) =>
                                                              _fieldFocusChange(
                                                                  context,
                                                                  discountAmtFocusNode,
                                                                  FinalAmtFocusNode),
                                                          controller:
                                                              SalesDisAMountController,
                                                          onChanged:
                                                              (newvalue) {
                                                            calculateDiscountPercentage();
                                                            CalculateCGSTFinalAmount();
                                                            CalculateSGSTFinalAmount();

                                                            calculateFinaltotalAmount();
                                                            // calculatetotalAmount();
                                                            calculateFinalTaxableAmount();
                                                            // widget.onFinalAmountButtonPressed(
                                                            //     finalamtcontroller);
                                                            // print(
                                                            //     "finalamount :: ${FinallyyyAmounttts.text}");
                                                            SalesDisAMountController
                                                                    .selection =
                                                                TextSelection.fromPosition(
                                                                    TextPosition(
                                                                        offset: SalesDisAMountController
                                                                            .text
                                                                            .length));
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  width: 1.0),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.0),
                                                            ),
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 7.0,
                                                            ),
                                                          ),
                                                          style: textStyle),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (Responsive.isDesktop(context))
                                      SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("Final Taxable ₹",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .attach_money_rounded, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.27,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: TextField(
                                                        readOnly: true,
                                                        controller:
                                                            finaltaxablecontroller,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
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
                                    SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("CGST ₹",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .add_moderator_outlined, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: TextField(
                                                        readOnly: true,
                                                        controller:
                                                            cgstamtcontroller,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
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
                                    if (Responsive.isDesktop(context))
                                      SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("SGST ₹",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .add_moderator_outlined, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: TextField(
                                                        readOnly: true,
                                                        controller:
                                                            sgstamtcontroller,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1.0),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
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
                                    SizedBox(width: 10),
                                    Container(
                                      // color:subcolor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text("Final Amount ₹",
                                                style: commonLabelTextStyle),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 4),
                                            child: Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.11
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.37,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .auto_mode_rounded, // Your icon here
                                                    size: 17,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          5), // Adjust spacing between icon and text

                                                  Container(
                                                    height: 24,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.28,

                                                    color: Colors.grey[100],
                                                    // color: Colors.grey[100],
                                                    child: Focus(
                                                      onKey: (FocusNode node,
                                                          RawKeyEvent event) {
                                                        if (event
                                                            is RawKeyDownEvent) {
                                                          if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .arrowUp) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    discountpercFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .enter) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    SavebuttonFocusNode);
                                                            return KeyEventResult
                                                                .handled;
                                                          }
                                                        }
                                                        return KeyEventResult
                                                            .ignored;
                                                      },
                                                      child: TextFormField(
                                                          readOnly: true,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          focusNode:
                                                              FinalAmtFocusNode,
                                                          onFieldSubmitted:
                                                              (_) {
                                                            // Move focus to the save button
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    SavebuttonFocusNode);
                                                          },
                                                          controller:
                                                              finalamtcontroller,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  width: 1.0),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.0),
                                                            ),
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 7.0,
                                                            ),
                                                          ),
                                                          style: textStyle),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: Container(
                                        // color: Colors.green,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 6,
                                                  bottom: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 0,
                                                  top: 0),
                                              child: Container(
                                                child: ElevatedButton(
                                                  focusNode:
                                                      SavebuttonFocusNode,
                                                  onPressed: () async {
                                                    if (SalesDisAMountController.text.isEmpty ||
                                                        SalesDisPercentageController
                                                            .text.isEmpty ||
                                                        widget.paytype.text
                                                            .isEmpty ||
                                                        tableData.isEmpty) {
                                                      // Show error message
                                                      WarninngMessage(context);
                                                      return;
                                                    }

                                                    Post_salesIncometbl();
                                                    update_SalesDetailsRound();
                                                    _printResult();
                                                    FocusScope.of(context)
                                                        .requestFocus(widget
                                                            .codeFocusNode);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0),
                                                    ),
                                                    backgroundColor: subcolor,
                                                    minimumSize:
                                                        Responsive.isMobile(
                                                                context)
                                                            ? Size(25.0, 31.0)
                                                            : Size(45.0, 31.0),
                                                  ),
                                                  child: Text(
                                                    'Update',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: Responsive
                                                              .isDesktop(
                                                                  context)
                                                          ? 12
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 25),
                                    //   child: Container(
                                    //     // color: Colors.green,
                                    //     child: Column(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         Padding(
                                    //           padding: EdgeInsets.only(
                                    //               left: Responsive.isDesktop(
                                    //                       context)
                                    //                   ? 10
                                    //                   : 6,
                                    //               top: 0),
                                    //           child: Container(
                                    //             child: ElevatedButton(
                                    //               onPressed: () {
                                    //                 // Handle form submission
                                    //               },
                                    //               style:
                                    //                   ElevatedButton.styleFrom(
                                    //                 shape:
                                    //                     RoundedRectangleBorder(
                                    //                   borderRadius:
                                    //                       BorderRadius.circular(
                                    //                           2.0),
                                    //                 ),
                                    //                 backgroundColor: subcolor,
                                    //                 minimumSize: Size(45.0,
                                    //                     31.0), // Set width and height
                                    //               ),
                                    //               child: Text(
                                    //                 'Preview',
                                    //                 style: TextStyle(
                                    //                   color: Colors.white,
                                    //                   fontSize: 12,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: Container(
                                        // color: Colors.green,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 6,
                                                  bottom: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 0,
                                                  top: 0),
                                              child: Container(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          content: Container(
                                                            width: 1100,
                                                            // height: 700,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                    height: 10),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                    left: Responsive.isDesktop(
                                                                            context)
                                                                        ? 40
                                                                        : 6,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      IconButton(
                                                                        icon: Icon(
                                                                            Icons.cancel),
                                                                        color: Colors
                                                                            .red,
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
// Customize the text style as needed
                                                                ,
                                                                Container(
                                                                    width: 1100,
                                                                    height: 600,
                                                                    child:
                                                                        GstDetailsForm()),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0),
                                                    ),
                                                    backgroundColor: subcolor,
                                                    minimumSize: Size(45.0,
                                                        31.0), // Set width and height
                                                  ),
                                                  child: Text(
                                                    'Add Gst',
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
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: Container(
                                        // color: Colors.green,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 6,
                                                  bottom: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 0,
                                                  top: 0),
                                              child: Container(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    refreshData();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0),
                                                    ),
                                                    backgroundColor: subcolor,
                                                    minimumSize: Size(45.0,
                                                        31.0), // Set width and height
                                                  ),
                                                  child: Text(
                                                    'Refresh',
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                )),
          ),
        )
      ],
    );
  }

  void calculateDiscountAmount() {
    // Parse discount percentage
    double disPercentage =
        double.tryParse(SalesDisPercentageController.text.toString()) ?? 0.0;

    print(
        "calculateDiscountAmount sales gst method : ${widget.SalesGstMethodController.text}");

    if (widget.SalesGstMethodController.text == "Excluding") {
      double cgst0 =
          double.tryParse(gettaxableAmtCGST0(tableData).toString()) ?? 0.0;
      double cgst25 =
          double.tryParse(gettaxableAmtCGST25(tableData).toString()) ?? 0.0;
      double cgst6 =
          double.tryParse(gettaxableAmtCGST6(tableData).toString()) ?? 0.0;
      double cgst9 =
          double.tryParse(gettaxableAmtCGST9(tableData).toString()) ?? 0.0;
      double cgst14 =
          double.tryParse(gettaxableAmtCGST14(tableData).toString()) ?? 0.0;
      // print("Cgst 000:$cgst0");
      // print("Cgst 255:$cgst25");

      // print("Cgst 6666:$cgst6");
      // print("Cgst 9999:$cgst9");
      // print("Cgst 1444:$cgst14");

      // Perform calculations
      double part1 = cgst0 * disPercentage / 100;
      double part2 = cgst25 * disPercentage / 100;
      double part3 = cgst6 * disPercentage / 100;
      double part4 = cgst9 * disPercentage / 100;
      double part5 = cgst14 * disPercentage / 100;

      // Calculate total discount amount
      double discountAmount = part1 + part2 + part3 + part4 + part5;

      // Update the discount amount in the text controller
      SalesDisAMountController.text = discountAmount.toStringAsFixed(2);
      print(
          "total SalesDisAMountController amount = ${SalesDisAMountController.text}");
    } else if (widget.SalesGstMethodController.text == "Including") {
      double cgst0 =
          double.tryParse(getFinalAmtCGST0(tableData).toString()) ?? 0.0;
      double cgst25 =
          double.tryParse(getFinalAmtCGST25(tableData).toString()) ?? 0.0;
      double cgst6 =
          double.tryParse(getFinalAmtCGST6(tableData).toString()) ?? 0.0;
      double cgst9 =
          double.tryParse(getFinalAmtCGST9(tableData).toString()) ?? 0.0;
      double cgst14 =
          double.tryParse(getFinalAmtCGST14(tableData).toString()) ?? 0.0;

      // print("Cgst 000:$cgst0");
      // print("Cgst 255:$cgst25");

      // print("Cgst 6666:$cgst6");
      // print("Cgst 9999:$cgst9");
      // print("Cgst 1444:$cgst14");
      // Perform calculations
      double part1 = cgst0 * disPercentage / 100;
      double part2 = cgst25 * disPercentage / 100;
      double part3 = cgst6 * disPercentage / 100;
      double part4 = cgst9 * disPercentage / 100;
      double part5 = cgst14 * disPercentage / 100;

      // Calculate total discount amount
      double discountAmount = part1 + part2 + part3 + part4 + part5;

      // Update the discount amount in the text controller
      SalesDisAMountController.text = discountAmount.toStringAsFixed(2);
      // print("DiscountAmount : ${SalesDisAMountController.text}");
    } else {
      double taxableamount =
          double.tryParse(getTotalFinalTaxable(tableData).toString()) ?? 0.0;

      double discountamount = taxableamount * disPercentage / 100;

      SalesDisAMountController.text = discountamount.toStringAsFixed(2);
    }
  }

  void calculateDiscountPercentage() {
    // Get the discount amount from the controller
    double discountAmount =
        double.tryParse(SalesDisAMountController.text) ?? 0.0;

    print(
        "calculateDiscountPercentage sales gst method : ${widget.SalesGstMethodController.text}");

    if (widget.SalesGstMethodController.text == "Excluding") {
      // Get the total taxable amount from the widget
      double totalTaxable =
          double.tryParse(getTotalTaxable(tableData).toString()) ?? 0.0;

      // Calculate the discount percentage
      double discountPercentage = (discountAmount * 100) / totalTaxable;

      // Update the discount percentage in the appropriate controller
      SalesDisPercentageController.text = discountPercentage.toStringAsFixed(2);

      print(
          "SalesDisPercentageController sales gst method : ${SalesDisPercentageController.text}");
    } else if (widget.SalesGstMethodController.text == "Including") {
      double totalTaxable =
          double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;

      // Calculate the discount percentage
      double discountPercentage = (discountAmount * 100) / totalTaxable;

      // Update the discount percentage in the appropriate controller
      SalesDisPercentageController.text = discountPercentage.toStringAsFixed(2);
    } else {
      double taxableamount =
          double.tryParse(getTotalFinalTaxable(tableData).toString()) ?? 0.0;

      double discountamount = discountAmount * 100 / taxableamount;

      SalesDisPercentageController.text = discountamount.toStringAsFixed(2);
    }
  }

  void CalculateCGSTFinalAmount() {
    // Parse discount percentage
    double disPercentage =
        double.tryParse(SalesDisPercentageController.text.toString()) ?? 0.0;

    print(
        "CalculateCGSTFinalAmount sales gst method : ${widget.SalesGstMethodController.text}");
    double cgst0 =
        double.tryParse(gettaxableAmtCGST0(tableData).toString()) ?? 0.0;
    double cgst25 =
        double.tryParse(gettaxableAmtCGST25(tableData).toString()) ?? 0.0;
    double cgst6 =
        double.tryParse(gettaxableAmtCGST6(tableData).toString()) ?? 0.0;
    double cgst9 =
        double.tryParse(gettaxableAmtCGST9(tableData).toString()) ?? 0.0;
    double cgst14 =
        double.tryParse(gettaxableAmtCGST14(tableData).toString()) ?? 0.0;

    print("cgst0 00000 : ${cgst0}");
    print("cgst23 25555 : ${cgst25}");
    print("cgs666 6666 : ${cgst6}");
    print("cgst99 999 : ${cgst9}");
    print("cgst14 14444 : ${cgst14}");

    print(
        "CalculateCGSTFinalAmount sales gst method : ${widget.SalesGstMethodController.text}");
    if (widget.SalesGstMethodController.text == "Including") {
      double cgst0 =
          double.tryParse(getFinalAmtCGST0(tableData).toString()) ?? 0.0;
      double cgst25 =
          double.tryParse(getFinalAmtCGST25(tableData).toString()) ?? 0.0;
      double cgst6 =
          double.tryParse(getFinalAmtCGST6(tableData).toString()) ?? 0.0;
      double cgst9 =
          double.tryParse(getFinalAmtCGST9(tableData).toString()) ?? 0.0;
      double cgst14 =
          double.tryParse(getFinalAmtCGST14(tableData).toString()) ?? 0.0;

      // Perform calculations
      double cgst0part1 = cgst0 * disPercentage / 100;
      double cgst25part2 = cgst25 * disPercentage / 100;
      double cgst6part3 = cgst6 * disPercentage / 100;
      double cgst9part4 = cgst9 * disPercentage / 100;
      double cgst14part5 = cgst14 * disPercentage / 100;

      double finalcgst0amt = cgst0 - cgst0part1;
      double finalcgst25amt = cgst25 - cgst25part2;
      double finalcgst6amt = cgst6 - cgst6part3;
      double finalcgst9amt = cgst9 - cgst9part4;
      double finalcgst14amt = cgst14 - cgst14part5;

      double denominator0 = 100 + 0;
      double denominator25 = 100 + 5;
      double denominator6 = 100 + 12;
      double denominator9 = 100 + 18;
      double denominator14 = 100 + 28;

      double FinameFormulaCGST0 = finalcgst0amt * 0 / denominator0;
      double FinameFormulaCGST25 = finalcgst25amt * 2.5 / denominator25;
      double FinameFormulaCGST6 = finalcgst6amt * 6 / denominator6;
      double FinameFormulaCGST9 = finalcgst9amt * 9 / denominator9;
      double FinameFormulaCGST14 = finalcgst14amt * 14 / denominator14;

      CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
      CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
      CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
      CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
      CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

      // print("cgsttttttt 00000 : ${CGSTPercent0.text}");
      // print("cgsttttttt 25555 : ${CGSTPercent25.text}");
      // print("cgsttttttt 6666 : ${CGSTPercent6.text}");
      // print("cgsttttttt 999 : ${CGSTPercent9.text}");
      // print("cgsttttttt 14444 : ${CGSTPercent14.text}");

      double FinalCGSTAmounts = FinameFormulaCGST0 +
          FinameFormulaCGST25 +
          FinameFormulaCGST6 +
          FinameFormulaCGST9 +
          FinameFormulaCGST14;

      cgstamtcontroller.text = FinalCGSTAmounts.toStringAsFixed(2);
    } else if (widget.SalesGstMethodController.text == "Excluding") {
      double cgst0 =
          double.tryParse(gettaxableAmtCGST0(tableData).toString()) ?? 0.0;
      double cgst25 =
          double.tryParse(gettaxableAmtCGST25(tableData).toString()) ?? 0.0;
      double cgst6 =
          double.tryParse(gettaxableAmtCGST6(tableData).toString()) ?? 0.0;
      double cgst9 =
          double.tryParse(gettaxableAmtCGST9(tableData).toString()) ?? 0.0;
      double cgst14 =
          double.tryParse(gettaxableAmtCGST14(tableData).toString()) ?? 0.0;

      print("cgst0 00000 : ${cgst0}");
      print("cgst23 25555 : ${cgst25}");
      print("cgs666 6666 : ${cgst6}");
      print("cgst99 999 : ${cgst9}");
      print("cgst14 14444 : ${cgst14}");

      // Perform calculations
      double cgst0part1 = cgst0 * disPercentage / 100;
      double cgst25part2 = cgst25 * disPercentage / 100;
      double cgst6part3 = cgst6 * disPercentage / 100;
      double cgst9part4 = cgst9 * disPercentage / 100;
      double cgst14part5 = cgst14 * disPercentage / 100;

      double finalcgst0amt = cgst0 - cgst0part1;
      double finalcgst25amt = cgst25 - cgst25part2;
      double finalcgst6amt = cgst6 - cgst6part3;
      double finalcgst9amt = cgst9 - cgst9part4;
      double finalcgst14amt = cgst14 - cgst14part5;

      print("finalcgst0amt 00000 : ${finalcgst0amt}");
      print("finalcgst0amt 25555 : ${finalcgst25amt}");
      print("finalcgst0amt 6666 : ${finalcgst6amt}");
      print("finalcgst0amt 999 : ${finalcgst9amt}");
      print("finalcgst0amt 14444 : ${finalcgst14amt}");

      double FinameFormulaCGST0 = finalcgst0amt * 0 / 100;
      double FinameFormulaCGST25 = finalcgst25amt * 2.5 / 100;
      double FinameFormulaCGST6 = finalcgst6amt * 6 / 100;
      double FinameFormulaCGST9 = finalcgst9amt * 9 / 100;
      double FinameFormulaCGST14 = finalcgst14amt * 14 / 100;

      CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
      CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
      CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
      CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
      CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

      print("CGSTPercent0 00000 : ${CGSTPercent0.text}");
      print("CGSTPercent0 25555 : ${CGSTPercent25.text}");
      print("CGSTPercent0 6666 : ${CGSTPercent6.text}");
      print("CGSTPercent0 999 : ${CGSTPercent9.text}");
      print("CGSTPercent0 14444 : ${CGSTPercent14.text}");

      double FinalCGSTAmounts = FinameFormulaCGST0 +
          FinameFormulaCGST25 +
          FinameFormulaCGST6 +
          FinameFormulaCGST9 +
          FinameFormulaCGST14;

      cgstamtcontroller.text = FinalCGSTAmounts.toStringAsFixed(2);

      print("cgstamtcontroller sales gst method : ${cgstamtcontroller.text}");
    } else {
      CGSTPercent0.text = 0.toStringAsFixed(2);
      CGSTPercent25.text = 0.toStringAsFixed(2);
      CGSTPercent6.text = 0.toStringAsFixed(2);
      CGSTPercent9.text = 0.toStringAsFixed(2);
      CGSTPercent14.text = 0.toStringAsFixed(2);

      double FinalCGSTAmounts = 0;

      cgstamtcontroller.text = FinalCGSTAmounts.toStringAsFixed(2);
    }
  }

  void CalculateSGSTFinalAmount() {
    // Parse discount percentage
    double disPercentage =
        double.tryParse(SalesDisPercentageController.text.toString()) ?? 0.0;

    print(
        "CalculatesGSTFinalAmount sales gst method : ${widget.SalesGstMethodController.text}");
    if (widget.SalesGstMethodController.text == "Excluding") {
      double sgst0 =
          double.tryParse(gettaxableAmtSGST0(tableData).toString()) ?? 0.0;
      double sgst25 =
          double.tryParse(gettaxableAmtSGST25(tableData).toString()) ?? 0.0;
      double sgst6 =
          double.tryParse(gettaxableAmtSGST6(tableData).toString()) ?? 0.0;
      double sgst9 =
          double.tryParse(gettaxableAmtSGST9(tableData).toString()) ?? 0.0;
      double sgst14 =
          double.tryParse(gettaxableAmtSGST14(tableData).toString()) ?? 0.0;
      // Perform calculations
      // Perform calculations
      double sgst0part1 = sgst0 * disPercentage / 100;
      double sgst25part2 = sgst25 * disPercentage / 100;
      double sgst6part3 = sgst6 * disPercentage / 100;
      double sgst9part4 = sgst9 * disPercentage / 100;
      double sgst14part5 = sgst14 * disPercentage / 100;

      double finalsgst0amt = sgst0 - sgst0part1;
      double finalsgst25amt = sgst25 - sgst25part2;
      double finalsgst6amt = sgst6 - sgst6part3;
      double finalsgst9amt = sgst9 - sgst9part4;
      double finalsgst14amt = sgst14 - sgst14part5;
      double FinameFormulaSGST0 = finalsgst0amt * 0 / 100;
      double FinameFormulaSGST25 = finalsgst25amt * 2.5 / 100;
      double FinameFormulaSGST6 = finalsgst6amt * 6 / 100;
      double FinameFormulaSGST9 = finalsgst9amt * 9 / 100;
      double FinameFormulaSGST14 = finalsgst14amt * 14 / 100;

      SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
      SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
      SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
      SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
      SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

      double FinalSGSTAmounts = FinameFormulaSGST0 +
          FinameFormulaSGST25 +
          FinameFormulaSGST6 +
          FinameFormulaSGST9 +
          FinameFormulaSGST14;

      sgstamtcontroller.text = FinalSGSTAmounts.toStringAsFixed(2);
    } else if (widget.SalesGstMethodController.text == "Including") {
      double sgst0 =
          double.tryParse(getFinalAmtSGST0(tableData).toString()) ?? 0.0;
      double sgst25 =
          double.tryParse(getFinalAmtSGST25(tableData).toString()) ?? 0.0;
      double sgst6 =
          double.tryParse(getFinalAmtSGST6(tableData).toString()) ?? 0.0;
      double sgst9 =
          double.tryParse(getFinalAmtSGST9(tableData).toString()) ?? 0.0;
      double sgst14 =
          double.tryParse(getFinalAmtSGST14(tableData).toString()) ?? 0.0;

      // Perform calculations
      double sgst0part1 = sgst0 * disPercentage / 100;
      double sgst25part2 = sgst25 * disPercentage / 100;
      double sgst6part3 = sgst6 * disPercentage / 100;
      double sgst9part4 = sgst9 * disPercentage / 100;
      double sgst14part5 = sgst14 * disPercentage / 100;

      double finalsgst0amt = sgst0 - sgst0part1;
      double finalsgst25amt = sgst25 - sgst25part2;
      double finalsgst6amt = sgst6 - sgst6part3;
      double finalsgst9amt = sgst9 - sgst9part4;
      double finalsgst14amt = sgst14 - sgst14part5;
      double denominator0 = 100 + 0;
      double denominator25 = 100 + 5;
      double denominator6 = 100 + 12;
      double denominator9 = 100 + 18;
      double denominator14 = 100 + 28;

      double FinameFormulaSGST0 = finalsgst0amt * 0 / denominator0;
      double FinameFormulaSGST25 = finalsgst25amt * 2.5 / denominator25;
      double FinameFormulaSGST6 = finalsgst6amt * 6 / denominator6;
      double FinameFormulaSGST9 = finalsgst9amt * 9 / denominator9;
      double FinameFormulaSGST14 = finalsgst14amt * 14 / denominator14;

      SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
      SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
      SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
      SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
      SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

      double FinalSGSTAmounts = FinameFormulaSGST0 +
          FinameFormulaSGST25 +
          FinameFormulaSGST6 +
          FinameFormulaSGST9 +
          FinameFormulaSGST14;

      sgstamtcontroller.text = FinalSGSTAmounts.toStringAsFixed(2);
    } else {
      SGSTPercent0.text = 0.toStringAsFixed(2);
      SGSTPercent25.text = 0.toStringAsFixed(2);
      SGSTPercent6.text = 0.toStringAsFixed(2);
      SGSTPercent9.text = 0.toStringAsFixed(2);
      SGSTPercent14.text = 0.toStringAsFixed(2);

      double FinalSGSTAmounts = 0;

      sgstamtcontroller.text = FinalSGSTAmounts.toStringAsFixed(2);
    }
  }

  void calculateFinaltotalAmount() {
    print(
        "calculateFinaltotalAmount sales gst method : ${widget.SalesGstMethodController.text}");
    if (widget.SalesGstMethodController.text == "Excluding") {
      // Get the total taxable amount from the widget
      double finaltotalTaxable =
          double.tryParse(finaltaxablecontroller.text) ?? 0.0;
      double finalCGSTAmount = double.tryParse(cgstamtcontroller.text) ?? 0.0;
      double finalSGSTAmount = double.tryParse(sgstamtcontroller.text) ?? 0.0;

      // Perform calculation
      double TotalAmount =
          finaltotalTaxable + finalCGSTAmount + finalSGSTAmount;

      finalamtcontroller.text = TotalAmount.toStringAsFixed(2);
    } else if (widget.SalesGstMethodController.text == "Including") {
      double totalFInalAMount =
          double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;
      double discountamount =
          double.tryParse(SalesDisAMountController.text) ?? 0.0;

      double FinalTotlaAmount = totalFInalAMount - discountamount;

      finalamtcontroller.text = FinalTotlaAmount.toStringAsFixed(2);
    } else {
      double totalFInalAMount =
          double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;
      double discountamount =
          double.tryParse(SalesDisAMountController.text) ?? 0.0;

      double FinalTotlaAmount = totalFInalAMount - discountamount;

      finalamtcontroller.text = FinalTotlaAmount.toStringAsFixed(2);
    }
  }

  void calculateFinalTaxableAmount() {
    // Parse discount percentage

    double discountAmount =
        double.tryParse(SalesDisAMountController.text) ?? 0.0;
    print(
        "calculateFinalTaxableAmount sales gst method : ${widget.SalesGstMethodController.text}");
    if (widget.SalesGstMethodController.text == "Excluding") {
      // Get the total taxable amount from the widget
      double totalTaxable =
          double.tryParse(getTotalFinalTaxable(tableData).toString()) ?? 0.0;

      double FinalTaxableAMount = totalTaxable - discountAmount;
      finaltaxablecontroller.text = FinalTaxableAMount.toStringAsFixed(2);
    } else if (widget.SalesGstMethodController.text == "Including") {
      double totalFInalAMount =
          double.tryParse(getTotalFinalAmt(tableData).toString()) ?? 0.0;
      double discountamount =
          double.tryParse(SalesDisAMountController.text) ?? 0.0;

      double FinalTotlaAmount = totalFInalAMount - discountamount;

      double finalAmount = FinalTotlaAmount;
      double cgsttotalamount =
          double.tryParse(cgstamtcontroller.text.toString()) ?? 0.0;
      double sgsttotalamount =
          double.tryParse(sgstamtcontroller.text.toString()) ?? 0.0;

      double totalgstamount = cgsttotalamount + sgsttotalamount;

      double finaltaxableamount = finalAmount - totalgstamount;
      finaltaxablecontroller.text = finaltaxableamount.toStringAsFixed(2);
    } else {
      double totalTaxable =
          double.tryParse(getTotalTaxable(tableData).toString()) ?? 0.0;
      double discountAmount =
          double.tryParse(SalesDisAMountController.text) ?? 0.0;

      double finaltaxableamount = totalTaxable - discountAmount;
      finaltaxablecontroller.text = finaltaxableamount.toStringAsFixed(2);
    }
  }

  Future<void> Post_salesIncometbl() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      // Format the date in 'yyyy-MM-dd' format
      String formattedDate =
          DateFormat('yyyy-MM-dd').format(widget.selectedsalesdate);

      Map<String, dynamic> postData = {
        "cusid": cusid,
        "amount": finalamtcontroller.text
      };

      // Convert the data to JSON format
      String jsonData = jsonEncode(postData);

      // Construct the URL to fetch data
      String fetchUrl =
          '$IpAddress/Sales_IncomeDetailsdatewise/$cusid/$formattedDate/';

      print("urllllllllllll post incometable : $fetchUrl");

      // Send the GET request to fetch data
      var fetchResponse = await http.get(
        Uri.parse(fetchUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print("status code of the income table : ${fetchResponse.statusCode}");

      if (fetchResponse.statusCode == 200) {
        var responseBody = jsonDecode(fetchResponse.body);

        // Check if response contains 'results' key
        if (responseBody.containsKey('results')) {
          List<dynamic> results = responseBody['results'];

          String billno = widget.BillNOreset.text;
          // Find the entry with description == 'Sales Bill:$billno'
          Map<String, dynamic>? targetEntry = results.firstWhere(
            (entry) => entry['description'] == 'Sales Bill:$billno',
            orElse: () => {},
          );

          print("targetentry of the income table : ${targetEntry}");

          if (targetEntry != null && targetEntry.isNotEmpty) {
            int id = targetEntry['id'];
            print('Found ID: $id');

            // Construct the URL to post data
            String postUrl = '$IpAddress/Sales_IncomeDetails/$id/';

            // Send the PUT request to update data
            var postResponse = await http.put(
              Uri.parse(postUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonData,
            );

            // Check the response status
            if (postResponse.statusCode == 200) {
              print('Data posted successfully');
            } else {
              print(
                  'Failed to post data. Error code: ${postResponse.statusCode}');
              if (postResponse.body.isNotEmpty) {
                print('Response body: ${postResponse.body}');
              }
            }
          } else {
            print('No entry found with description "Sales Bill:$billno"');
          }
        } else {
          print('Invalid response format. Missing "results" key.');
        }
      } else {
        print('Failed to fetch data. Error code: ${fetchResponse.statusCode}');
        if (fetchResponse.body.isNotEmpty) {
          print('Response body: ${fetchResponse.body}');
        }
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
    }
  }

  Future<void> update_SalesDetailsRound() async {
    try {
      CalculateCGSTFinalAmount();
      CalculateSGSTFinalAmount();
      calculateFinalTaxableAmount();
      calculateFinaltotalAmount();

      DateTime parsedDateTime = DateTime.parse(DatetimeCOntroller.text);

      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDateTime);

      print("formatted selected date is ${formattedDate}");

      // Format the current date and time in the required format
      String formattedDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
          .format(widget.selectedsalesdate);
      String gstcontorller = widget.SalesGstMethodController.text;
      String gstMethod = '';
      if (gstcontorller == 'Including' || gstcontorller == 'Excluding') {
        gstMethod = 'Gst';
      } else {
        gstMethod = 'NonGst';
      }

      String cgstperc = cgstamtcontroller.text;
      String sgstperc = sgstamtcontroller.text;

      double cgst = double.tryParse(cgstperc) ?? 0.0;
      double sgst = double.tryParse(sgstperc) ?? 0.0;

      double gstamt = cgst + sgst;
      List<String> productDetails = [];
      for (var data in tableData) {
        // Format each product detail as "{productName},{amount}"
        productDetails.add(
            "{salesbillno:${widget.BillNOreset.text},category:${data['category']},dt:$formattedDate,Itemname:${data['productName']},rate:${data['amount']},qty:${data['quantity']},amount:${data['Amount']},retailrate:${data['retailrate']},retail:${data['retail']},cgst:${data['cgstAmt']},sgst:${data['sgstAmt']},serialno:1,sgstperc:${data['sgstperc']},cgstperc:${data['cgstperc']},makingcost:${data['makingcost']},status:Normal,sno:1.0}");
      }

      // Join all product details into a single string
      String productDetailsString = productDetails.join('');

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> putData = {
        "cusid": cusid,
        "billno": widget.BillNOreset.text,
        "dt": formattedDate,
        "type": widget.ProductSalesTypeController.text,
        "tableno": widget.tableno.text.isEmpty ? "null" : widget.tableno.text,
        "servent": widget.sname.text.isEmpty ? "null" : widget.sname.text,
        "count": itemCountController.text,
        "amount": getTotalFinalAmt(tableData).toString(),
        "discount": SalesDisAMountController.text,
        "vat": gstamt,
        "finalamount": finalamtcontroller.text,
        "cgst0": CGSTPercent0.text,
        "cgst25": CGSTPercent25.text,
        "cgst6": CGSTPercent6.text,
        "cgst9": CGSTPercent9.text,
        "cgst14": CGSTPercent14.text,
        "sgst0": SGSTPercent0.text,
        "sgst25": SGSTPercent25.text,
        "sgst6": SGSTPercent6.text,
        "sgst9": SGSTPercent9.text,
        "sgst14": SGSTPercent14.text,
        "totcgst": cgstamtcontroller.text,
        "totsgst": sgstamtcontroller.text,
        "paidamount":
            widget.paytype.text == "Credit" ? "0" : finalamtcontroller.text,
        "scode": widget.scode.text.isEmpty ? "null" : widget.scode.text,
        "sname": widget.sname.text.isEmpty ? "null" : widget.sname.text,
        "cusname": widget.customername.text.isEmpty
            ? "null"
            : widget.customername.text,
        "contact": widget.customercontact.text.isEmpty
            ? "null"
            : widget.customercontact.text,
        "paytype": widget.paytype.text,
        "disperc": SalesDisPercentageController.text,
        "famount": finalamtcontroller.text,
        "Status": "Normal",
        "gststatus": gstMethod,
        "time": formattedDateTime,
        "taxstatus": gstcontorller,
        "taxable": taxableamountController.text,
        "finaltaxable": finaltaxablecontroller.text,
        "SalesDetails": productDetailsString
      };

      // Convert the data to JSON format
      String jsonData = jsonEncode(putData);

      // Send the PUT request to update the data at the specific ID
      String id = EditsalesIdController.text;
      // print("iddddddddddddddd: $id");

      var response = await http.put(
        Uri.parse('$IpAddress/SalesRoundDetailsalldatas/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Data updated successfully');

        await logreports('SalesBill: ${widget.BillNOreset.text}_Updated');
        widget.BillNOreset.clear();
        widget.customername.clear();
        widget.customercontact.clear();
        widget.cleartabledata();
        itemCountController.text = '0';
        taxableamountController.text = '0';
        finaltaxablecontroller.text = '0';
        SalesDisAMountController.text = '0';
        SalesDisPercentageController.text = '0';
        cgstamtcontroller.text = '0';
        sgstamtcontroller.text = '0';
        finalamtcontroller.text = '0';
        successfullySavedMessage(context);
        // widget.selectedsalesdate = DateTime.now();
      } else {
        // Print the response body if available
        print('Failed to update data. Error code: ${response.statusCode}');
        if (response.body != null && response.body.isNotEmpty) {
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      // Print any exceptions that occur
      print('Failed to update data. Error: $e');
    }
  }

  Future<void> _printResult() async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime currentDatetime = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
      String formattedDateTime = DateFormat('hh:mm a').format(currentDatetime);
      String billno = widget.BillNOreset.text;

      String date = formattedDate;
      String paytype = widget.paytype.text;
      String time = formattedDateTime;
      String Customername = widget.customername.text;
      String CustomerContact = widget.customercontact.text;
      String Tableno = widget.tableno.text;
      String tableservent = widget.sname.text;
      String count = itemCountController.text;
      String totalQty = QuantityContController.text;
      String totalamt = getTotalFinalAmt(tableData).toString();
      String discount = SalesDisAMountController.text;
      String FinalAmt = finalamtcontroller.text;

      String sgst25;
      if (SGSTPercent25.text == "0.00") {
        sgst25 = "";
      } else {
        sgst25 = SGSTPercent25.text;
      }
      String sgst6;
      if (SGSTPercent6.text == "0.00") {
        sgst6 = "";
      } else {
        sgst6 = SGSTPercent6.text;
      }
      String sgst9;
      if (SGSTPercent9.text == "0.00") {
        sgst9 = "";
      } else {
        sgst9 = SGSTPercent9.text;
      }
      String sgst14;
      if (SGSTPercent14.text == "0.00") {
        sgst14 = "";
      } else {
        sgst14 = SGSTPercent14.text;
      }

      List<String> productDetails = [];
      for (var data in tableData) {
        // Format each product detail as "{productName},{amount}"
        productDetails.add(
            "${data['productName']}-${data['amount']}-${data['quantity']}");
      }

      String productDetailsString = productDetails.join(',');
      // print("product details : $productDetailsString   ");
      // print(
      //     "billno : $billno   , date : $date ,  paytype : $paytype ,    time :$time    ,customername : $Customername,  customercontact : $CustomerContact  ,    table No : $Tableno,   Tableservent : $tableservent,    total count :  $count,  total qty : $totalQty,    totalamt : $totalamt,    discount amt : $discount,    finalamount:  $FinalAmt");
      // print(
      //     "url : $IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString");

      // print(
      //     "sgst25 : $sgst25  ,  sgst6 :   $sgst6 , sgst 9 :   $sgst9  ,   sgst14:   $sgst14");

      final response = await http.get(Uri.parse(
          '$IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, print the response body.
        print('Response: ${response.body}');
      } else {
        // If the server did not return a 200 OK response, print the status code.
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any potential errors.
      print('Error: $e');
    }
  }

  void _deleteRow(int index) {
    setState(() {
      tableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
    updateItemCount();
    updateTaxableAmount();
    updatefinalTaxableAmount();
    updateCGSTtabletotal();
    updateSGSTtabletotal();
    updatefinaltabletotalAmount();
    widget.onFinalAmountButtonPressed(finalamtcontroller);
  }

  Future<bool?> _showDeleteConfirmationDialog(
      index, String productName, int quantity) async {
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
                post_stockItemsproductdelete(productName, quantity);
                _deleteRow(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
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
}
