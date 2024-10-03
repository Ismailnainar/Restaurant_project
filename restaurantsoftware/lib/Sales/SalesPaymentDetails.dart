import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sales/Config/SalesCustomer.dart';
import 'package:restaurantsoftware/Settings/PaymentMethod.dart';

import '../Modules/Style.dart';

class SalesPaymetdetails extends StatefulWidget {
  @override
  _SalesPaymetdetailsState createState() => _SalesPaymetdetailsState();
}

class _SalesPaymetdetailsState extends State<SalesPaymetdetails> {
  bool isFormVisible = false;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> PaymenttableData = [];

  bool isUpdateMode = false;

  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  TextEditingController BillnoController = TextEditingController();
  TextEditingController BalanceAmtController = TextEditingController();
  TextEditingController DateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  TextEditingController finalAmountController = TextEditingController();
  TextEditingController CustomerNameController = TextEditingController();
  TextEditingController CustomerContactController = TextEditingController();
  TextEditingController PaymentTypeListController = TextEditingController();
  TextEditingController paymentdatecontroller = TextEditingController();
  TextEditingController ChequeNoController = TextEditingController();
  TextEditingController ChequeCashDtController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController ReferenceController = TextEditingController();
  late DateTime selectedchequeCashdt;
  late DateTime selecteddt;

  FocusNode CustomerNameFocusNode = FocusNode();

  FocusNode ContactFocuNode = FocusNode();
  FocusNode BalanceFocuNode = FocusNode();
  FocusNode DateFocuNode = FocusNode();
  FocusNode PaymentTypeFocuNode = FocusNode();
  FocusNode AmountFocusNode = FocusNode();

  FocusNode ChequenoFocuNode = FocusNode();
  FocusNode ChequedtFocusNode = FocusNode();
  FocusNode ReferenceFocusNode = FocusNode();

  FocusNode saveButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchCUstomerName();
    FetchPaymentType();
    fetchBillno();
  }

  double totalAmount = 0.0;
  String searchText = '';

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  List<String> CUstomerNameList = [];

  Future<void> fetchCUstomerName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/SalesCustomer/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          CUstomerNameList.addAll(
              results.map<String>((item) => item['cusname'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchCustomerContact() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/SalesCustomer/$cusid/';
    String customerName = CustomerNameController.text.toLowerCase();
    try {
      String url = baseUrl;
      while (true) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each customer entry
          for (var entry in results) {
            if (entry['cusname'].toString().toLowerCase() == customerName) {
              // Retrieve the contact number for the customer
              String contactNo = entry['contact'];

              // Update CustomerContactController with fetched data
              CustomerContactController.text = contactNo;
              // print("Customer contact : $contactNo");
              return;
            }
          }

          // Check if there are more pages
          if (data['next'] != null) {
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
      print('Contact information not found for customer: $customerName');
    } catch (e) {
      print('Error fetching customer contact information: $e');
    }
  }

  Future<void> fetchBalanceAmt() async {
    String? cusid = await SharedPrefs.getCusId();
    String selectedCustomer = CustomerNameController.text;
    String apiUrl =
        '$IpAddress/CusnamewiseSalesReport/$cusid/$selectedCustomer';

    double finalAmount = 0;
    double paidAmount = 0;

    String? nextUrl = apiUrl; // Initial URL

    try {
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl));
        var jsonData = json.decode(response.body);

        if (jsonData.isNotEmpty) {
          // Iterate through each entry in the JSON array
          for (var entry in jsonData) {
            // Extract relevant fields from each entry
            String? customerName = entry['cusname'];
            double finalAmt = double.tryParse(entry['finalamount'] ?? '0') ?? 0;
            double paidAmt = double.tryParse(entry['paidamount'] ?? '0') ?? 0;

            // Check if the customer name matches the selected customer
            if (customerName == selectedCustomer) {
              finalAmount += finalAmt;
              paidAmount += paidAmt;
            }
          }

          // Check if there are more pages
          nextUrl = null; // Assuming no pagination in the provided JSON
        } else {
          // Exit the loop if no results
          break;
        }
      }

      // print("Final amount: $finalAmount");
      // print("Paid amount: $paidAmount");

      // Calculate and update the balance amount
      double balanceAmount = finalAmount - paidAmount;
      BalanceAmtController.text = balanceAmount.toStringAsFixed(2);
    } catch (e) {
      print('Error fetching balance amount: $e');
    }
  }

  Future<void> fetchcustomerSalesdetails() async {
    String selectedCustomer = CustomerNameController.text;

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/CusnamewiseSalesReport/$cusid/$selectedCustomer/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData);

      List<Map<String, dynamic>> filteredResults = [];
      for (var item in results) {
        double finalAmount = double.parse(item['finalamount']);
        double paidAmount = double.parse(item['paidamount']);
        if (finalAmount - paidAmount != 0) {
          filteredResults.add(item);
        }
      }

      setState(() {
        tableData = filteredResults;
      });
    }
  }

  Future<void> fetchcustomerPaymentdetails() async {
    String? cusid = await SharedPrefs.getCusId();
    // Construct the URL with a query parameter for filtering
    String apiUrl = '$IpAddress/SalesPaymentRoundDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData);
      String customername = CustomerNameController.text;

      // Filter the results where 'name' is 'indhu'
      List<Map<String, dynamic>> filteredResults =
          results.where((payment) => payment['name'] == customername).toList();

      // print("Filtered table data of payments: $filteredResults");

      setState(() {
        PaymenttableData = filteredResults;
      });
    }
  }

  Future<void> updatePaymentDetails(String customerName, double amount) async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/CusnamewiseSalesReport/$cusid/$customerName/';
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);
      // print("datas in customerdata : $jsonData");

      if (jsonData != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData);

        // Sort the results by bill number to ensure payment order
        results.sort((a, b) => a['dt'].compareTo(b['dt']));

        double remainingAmount = amount;

        // Initialize the list to store all payment details
        List<Map<String, dynamic>> paymentdatas = [];
        for (Map<String, dynamic> bill in results) {
          double paid = double.parse(bill['paidamount']);
          double finalAmount = double.parse(bill['finalamount']);
          double balance = finalAmount - paid;

          if (balance > 0 && remainingAmount > 0) {
            double paymentAmount =
                remainingAmount < balance ? remainingAmount : balance;
            double updatedPaid = paid + paymentAmount;

            int billId = bill['id'];
            String billdt = bill['dt'];
            String billtime = bill['time'];

            String updateUrl = '$IpAddress/SalesRoundDetailsalldatas/$billId/';

            String? cusid = await SharedPrefs.getCusId();
            // Prepare the data to be sent in the request body
            Map<String, dynamic> requestBody = {
              "cusid": "$cusid",
              'paidamount': updatedPaid.toString(),
              "dt": billdt,
              "time": billtime,

              // Add any other fields if required
            };

            // Check if the bill has a "dt" field, if not, provide a default value
            if (!bill.containsKey('dt')) {
              requestBody['dt'] = DateTime.now().toString();
            }

            await Post_salespaymentIncometbl(bill['billno'], paymentAmount);
            http.Response updateResponse = await http.put(
              Uri.parse(updateUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestBody),
            );

            if (updateResponse.statusCode == 200) {
              print(
                  'Payment of $paymentAmount successfully applied to bill ${bill['billno']}');
              remainingAmount -= paymentAmount;
              String billno = bill['billno'];
              String billamount = bill['finalamount'];
              // print("billno : $billno");

              String totamount = finalAmountController.text;
              String Serialno = BillnoController.text;
              String paytype = PaymentTypeListController.text;
              String CustomerName = CustomerNameController.text;
              String CustomerContact = CustomerContactController.text;
              String Date = DateController.text;
              print("paymenttypee:$paytype");

              // Collect each payment detail and add it to the list
              Map<String, dynamic> paymentDetail = {
                "Billno": Serialno,
                "type": "Normal",
                "Paytype": paytype,
                "Amount": paymentAmount,
                "dt": Date,
                "billdt": billdt,
                "billamount": billamount,
                "salesbill": billno,
                "name": CustomerName,
                "contact": CustomerContact,
                "totpaid": totamount
              };

              paymentdatas.add(paymentDetail);
            } else {
              print(
                  'Failed to update payment details for bill ${bill['billno']}. Error: ${updateResponse.body}');
              break; // Exit the loop on error
            }
          }
        }

        if (remainingAmount > 0) {
          print(
              'Remaining amount $remainingAmount could not be fully applied to bills.');
        } else {
          // print('Payment details updated successfully for all bills.');
          print('Payment details $paymentdatas');

          AddSalesPaymentItems(paymentdatas);
          // successfullySavedMessage();
        }
      } else {
        print('No pending bills found for $customerName');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void AddSalesPaymentItems(List<Map<String, dynamic>> paymentdatas) async {
    if (CustomerNameController.text.isEmpty ||
        PaymentTypeListController.text.isEmpty ||
        finalAmountController.text.isEmpty) {
      WarninngMessage();
      return; // Ensure we exit early if the form is not filled out
    }

    try {
      String billno = BillnoController.text;
      String name = CustomerNameController.text;
      String contact = CustomerContactController.text;
      // print("contact: $contact");
      String dt = DateController.text;
      String paymenttype = PaymentTypeListController.text;
      String chequeno =
          ChequeNoController.text.isEmpty ? 'null' : ChequeNoController.text;
      String chequedt = ChequeCashDtController.text;
      String reference =
          ReferenceController.text.isEmpty ? "null" : ReferenceController.text;
      String amount = finalAmountController.text;

      // Convert each payment detail map to a JSON string
      List<Map<String, dynamic>> paymentDataList = paymentdatas;

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "billno": billno,
        "name": name,
        "contact": contact,
        "dt": dt,
        "paymenttype": paymenttype,
        "chequeno": chequeno,
        "chequedt": chequedt,
        "reference": reference,
        "amount": amount,
        "salespaymentdetails": "$paymentDataList"
      };

      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/SalesPaymentRoundDetailsalldata/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        // Display appropriate error message to the user
        // For example, if status code is 500, display a generic error message

        if (response.statusCode == 500) {
        } else {
          // Handle other status codes as needed
          // displayErrorMessage("Custom error message");
        }
      }
      await logreports('Sales Payment: ${billno}_${name}_${amount}_Inserted');
      successfullySavedMessage();
      BalanceAmtController.clear();
      finalAmountController.clear();
      CustomerNameController.clear();
      selectedValue = '';
      PaymentTypeselectedValue = '';
      CustomerContactController.clear();
      PaymentTypeListController.clear();
      paymentdatecontroller.clear();
      ChequeNoController.clear();
      ReferenceController.clear();
      fetchcustomerPaymentdetails();
      fetchcustomerSalesdetails();
      tableData = [];
      postDataWithIncrementedSerialNo();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> Post_salespaymentIncometbl(String billno, double amount) async {
    try {
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "description":
            "Sales Payment: $amount , Sales Bill: $billno ,CusName:  ${CustomerNameController.text}",
        "dt": formattedDate,
        "amount": amount.toString()
      };
      print("posted datassssssss : $postData");

      String jsonData = jsonEncode(postData);

      var response = await http.post(
        Uri.parse('$IpAddress/Sales_IncomeDetails/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print(
            'Data posted successfully for bill no $billno with amount $amount');
      } else {
        print('Failed to post data. Error code: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
    }
  }

  String? selectedValue;
  // Widget CustomerNameDropdown() {
  //   CustomerNameController.text = selectedValue ?? '';

  //   return TypeAheadFormField<String?>(
  //     textFieldConfiguration: TextFieldConfiguration(
  //       focusNode: CustomerNameFocusNode,
  //       textInputAction: TextInputAction.next,
  //       onSubmitted: (_) => _fieldFocusChange(
  //           context, CustomerNameFocusNode, PaymentTypeFocuNode),
  //       controller: CustomerNameController,

  //       decoration: InputDecoration(
  //           // labelText: ' ${selectedValue ?? ""}',

  //           border: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //           ),
  //           contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //           labelStyle: TextStyle(fontSize: 12),
  //           suffixIcon: Icon(
  //             Icons.keyboard_arrow_down,
  //             size: 18,
  //           )),
  //       style: TextStyle(
  //           fontSize: 12,
  //           color: Colors.black), // Set text style for onSuggestionSelected
  //     ),
  //     suggestionsCallback: (pattern) {
  //       return CUstomerNameList.where(
  //               (item) => item.toLowerCase().contains(pattern.toLowerCase()))
  //           .toList();
  //     },
  //     itemBuilder: (context, String? suggestion) {
  //       return ListTile(
  //         dense: true,
  //         title: Text(
  //           suggestion ?? ' ${selectedValue ?? ''}',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.black,
  //           ),
  //         ),
  //       );
  //     },
  //     onSuggestionSelected: (String? suggestion) async {
  //       setState(() {
  //         selectedValue = suggestion;
  //         CustomerNameController.text = suggestion ?? ' ${selectedValue ?? ''}';
  //       });
  //       // await fetchpaymentData();
  //       await fetchCustomerContact();
  //       await fetchBalanceAmt();
  //       await fetchcustomerPaymentdetails();
  //       fetchcustomerSalesdetails();
  //       FocusScope.of(context).requestFocus(PaymentTypeFocuNode);
  //     },
  //     suggestionsBoxDecoration: SuggestionsBoxDecoration(
  //       constraints: BoxConstraints(maxHeight: 150),
  //     ),
  //   );
  // }

  int? _selectedCustomerNameIndex;

  bool _isCustomerNameOptionsVisible = false;
  int? _CustomerhoveredIndex;
  Widget _buildCUstomerNameDropdown() {
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
                                  fetchCUstomerName();
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
                CUstomerNameList.indexOf(CustomerNameController.text);
            if (currentIndex < CUstomerNameList.length - 1) {
              setState(() {
                _selectedCustomerNameIndex = currentIndex + 1;
                CustomerNameController.text =
                    CUstomerNameList[currentIndex + 1];
                _isCustomerNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                CUstomerNameList.indexOf(CustomerNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedCustomerNameIndex = currentIndex - 1;
                CustomerNameController.text =
                    CUstomerNameList[currentIndex - 1];
                _isCustomerNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: CustomerNameFocusNode,
          onSubmitted: (String? suggestion) async {
            await fetchCustomerContact();
            await fetchBalanceAmt();
            await fetchcustomerPaymentdetails();
            fetchcustomerSalesdetails();
            _fieldFocusChange(
                context, CustomerNameFocusNode, PaymentTypeFocuNode);
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
              _isCustomerNameOptionsVisible = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isCustomerNameOptionsVisible && pattern.isNotEmpty) {
            return CUstomerNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return CUstomerNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = CUstomerNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _CustomerhoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _CustomerhoveredIndex = null;
            }),
            child: Container(
              color: _selectedCustomerNameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedCustomerNameIndex == null &&
                          CUstomerNameList.indexOf(
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
            selectedValue = suggestion;
            _isCustomerNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(PaymentTypeFocuNode);
          });

          await fetchCustomerContact();
          await fetchBalanceAmt();
          await fetchcustomerPaymentdetails();
          fetchcustomerSalesdetails();
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

  Future<void> FetchPaymentType() async {
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
  // Widget PaymentTypeDropdown() {
  //   PaymentTypeListController.text = PaymentTypeselectedValue ?? '';

  //   return TypeAheadFormField<String?>(
  //     textFieldConfiguration: TextFieldConfiguration(
  //       focusNode: PaymentTypeFocuNode,
  //       textInputAction: TextInputAction.next,
  //       onSubmitted: (_) =>
  //           _fieldFocusChange(context, PaymentTypeFocuNode, ChequenoFocuNode),
  //       controller: PaymentTypeListController,

  //       decoration: InputDecoration(
  //         // labelText: ' ${selectedValue ?? ""}',

  //         border: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //         ),
  //         contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //         labelStyle: TextStyle(fontSize: 12),
  //         suffixIcon: Icon(
  //           Icons.keyboard_arrow_down,
  //           size: 18,
  //         ),
  //       ),
  //       style: TextStyle(
  //           fontSize: 12,
  //           color: Colors.black), // Set text style for onSuggestionSelected
  //     ),
  //     suggestionsCallback: (pattern) {
  //       return PaymentTypeList.where(
  //               (item) => item.toLowerCase().contains(pattern.toLowerCase()))
  //           .toList();
  //     },
  //     itemBuilder: (context, String? suggestion) {
  //       return ListTile(
  //         dense: true,
  //         title: Text(
  //           suggestion ?? ' ${PaymentTypeselectedValue ?? ''}',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.black,
  //           ),
  //         ),
  //       );
  //     },
  //     onSuggestionSelected: (String? suggestion) async {
  //       setState(() {
  //         PaymentTypeselectedValue = suggestion;
  //         PaymentTypeListController.text =
  //             suggestion ?? ' ${PaymentTypeselectedValue ?? ''}';
  //       });

  //       FocusScope.of(context).requestFocus(ChequenoFocuNode);
  //     },
  //     suggestionsBoxDecoration: SuggestionsBoxDecoration(
  //       constraints: BoxConstraints(maxHeight: 150),
  //     ),
  //   );
  // }

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
                                  FetchPaymentType();
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
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeListController.text);
            if (currentIndex < PaymentTypeList.length - 1) {
              setState(() {
                _selectedPayTypeIndex = currentIndex + 1;
                PaymentTypeListController.text =
                    PaymentTypeList[currentIndex + 1];
                _isPayTypeOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeListController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                PaymentTypeListController.text =
                    PaymentTypeList[currentIndex - 1];
                _isPayTypeOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: PaymentTypeFocuNode,
          onSubmitted: (_) =>
              _fieldFocusChange(context, PaymentTypeFocuNode, ChequenoFocuNode),
          controller: PaymentTypeListController,
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
                          PaymentTypeList.indexOf(
                                  PaymentTypeListController.text) ==
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
            PaymentTypeListController.text = suggestion!;
            PaymentTypeselectedValue = suggestion;
            _isPayTypeOptionsVisible = false;
            FocusScope.of(context).requestFocus(ChequenoFocuNode);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('Sales Payment', style: HeadingStyle),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    _cardview(),
                    SizedBox(height: 20),
                    _tableview(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchBillno() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/SalesPaymentSno/$cusid/'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      int currentPayno = jsonData['sno'];
      // Add 1 to the current payno
      int nextPayno = currentPayno + 1;
      setState(() {
        BillnoController.text = nextPayno.toString();
      });
      print("Payment RecordNo : ${BillnoController.text}");
    } else {
      throw Exception('Failed to load serial number');
    }
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    // Increment the serial number
    int incrementedSerialNo = int.parse(
      BillnoController.text,
    );
    String? cusid = await SharedPrefs.getCusId();

    // Prepare the data to be sent
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "sno": incrementedSerialNo,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);

    try {
      // Send the POST request
      var response = await http.post(
        Uri.parse('$IpAddress/SalesPaymentSnoalldatas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 201) {
        print('Serial no of payment is posted successfully');
        fetchBillno();
      } else {
        print(
            'Failed to post Serial no of payment. Error code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
    }
  }

  Widget _cardview() {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.13;

    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.1;
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Wrap(
                alignment: WrapAlignment.start,
                runSpacing: 15,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BillNo',
                          style: commonLabelTextStyle,
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            height: 24,
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
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
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(top: 3, left: 5),
                                    child: TextField(
                                        readOnly: true,
                                        controller: BillnoController,
                                        onChanged: (newValue) {
                                          BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: const Color.fromARGB(
                                                    0, 158, 158, 158),
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                width: 1.0),
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
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Name', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                              width: Responsive.isDesktop(context)
                                  ? desktopcontainerdwidth
                                  : MediaQuery.of(context).size.width * 0.38,
                              child: _buildCUstomerNameDropdown()),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.call_sharp, size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                      focusNode: ContactFocuNode,
                                      textInputAction: TextInputAction.next,
                                      // onFieldSubmitted: (_) => _fieldFocusChange(
                                      //     context, ContactFocuNode, DateFocuNode),
                                      readOnly: true,
                                      controller: CustomerContactController,
                                      onChanged: (newValue) {
                                        CustomerContactController.text =
                                            newValue;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!Responsive.isDesktop(context)) SizedBox(width: 10),
                  Padding(
                    padding: EdgeInsets.only(
                        top: Responsive.isMobile(context) ? 0 : 0,
                        left: Responsive.isDesktop(context) ? 5 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[200],
                                  child: DateTimePicker(
                                    controller: DateController,
                                    focusNode:
                                        DateFocuNode, // Add the focus node here
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    dateLabelText: '',
                                    onChanged: (val) {
                                      // Update selectedDate when the date is changed
                                      setState(() {
                                        selecteddt = DateTime.parse(val);
                                      });
                                      print(val);
                                    },
                                    validator: (val) {
                                      print(val);
                                      return null;
                                    },
                                    onSaved: (val) {
                                      print(val);
                                    },
                                    style: textStyle,
                                    textInputAction: TextInputAction.next,
                                    // onFieldSubmitted: (_) => _fieldFocusChange(
                                    //     context,
                                    //     DateFocuNode,
                                    //     BalanceFocuNode), // Switch focus to the next field
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
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 18 : 10,
                        top: Responsive.isMobile(context) ? 0 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.call_sharp, size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                      focusNode: BalanceFocuNode,
                                      textInputAction: TextInputAction.next,
                                      // onFieldSubmitted: (_) => _fieldFocusChange(
                                      //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                      readOnly: true,
                                      controller: BalanceAmtController,
                                      onChanged: (newValue) {
                                        BalanceAmtController.text = newValue;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Type', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                              width: Responsive.isDesktop(context)
                                  ? desktopcontainerdwidth
                                  : MediaQuery.of(context).size.width * 0.38,
                              child: _buildPayTypeDropdown()),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(width: Responsive.isDesktop(context) ? 60 : 10),
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10,
                        top: Responsive.isMobile(context) ? 0 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cheque/Neft No', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.content_paste_search_rounded,
                                    size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                      focusNode: ChequenoFocuNode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _fieldFocusChange(
                                              context,
                                              ChequenoFocuNode,
                                              ChequedtFocusNode),
                                      controller: ChequeNoController,
                                      // onChanged: (newValue) {
                                      //   ChequeNoController.text = newValue;
                                      // },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cheque / Cash Dt', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: DateTimePicker(
                                    controller: ChequeCashDtController,
                                    focusNode:
                                        ChequedtFocusNode, // Add the focus node here
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    dateLabelText: '',
                                    onChanged: (val) {
                                      // Update selectedDate when the date is changed
                                      setState(() {
                                        selectedchequeCashdt =
                                            DateTime.parse(val);
                                      });
                                      // print(val);
                                    },
                                    validator: (val) {
                                      // print(val);
                                      return null;
                                    },
                                    onSaved: (val) {
                                      // print(val);
                                    },
                                    style: textStyle,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => _fieldFocusChange(
                                        context,
                                        ChequedtFocusNode,
                                        ReferenceFocusNode), // Switch focus to the next field
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
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10, top: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reference', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.rule_folder_outlined, size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                      focusNode: ReferenceFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _fieldFocusChange(
                                              context,
                                              ReferenceFocusNode,
                                              AmountFocusNode),
                                      controller: ReferenceController,
                                      // onChanged: (newValue) {
                                      //   ReferenceController.text = newValue;
                                      // },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 0, left: Responsive.isDesktop(context) ? 5 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount', style: commonLabelTextStyle),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 7 : 0),
                          child: Container(
                            width: Responsive.isDesktop(context)
                                ? desktopcontainerdwidth
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Row(
                              children: [
                                Icon(Icons.attach_money_rounded, size: 15),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 24,
                                  width: Responsive.isDesktop(context)
                                      ? desktoptextfeildwidth
                                      : MediaQuery.of(context).size.width *
                                          0.31,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                      focusNode: AmountFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _fieldFocusChange(
                                              context,
                                              AmountFocusNode,
                                              saveButtonFocusNode),
                                      onChanged: (value) {
                                        checkBalance();
                                      },
                                      controller: finalAmountController,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 5 : 10,
                        top: Responsive.isDesktop(context) ? 13 : 10),
                    child: ElevatedButton(
                      focusNode: saveButtonFocusNode,
                      onPressed: () {
                        if (CustomerNameController.text.isEmpty ||
                            PaymentTypeListController.text.isEmpty ||
                            finalAmountController.text.isEmpty) {
                          WarninngMessage();
                        } else {
                          // AddSalesPaymentItems();
                          updatePaymentDetails(CustomerNameController.text,
                              double.parse(finalAmountController.text));

                          // print("add button is pressed");
                          // Navigator.of(context)
                          //     .pushReplacement(MaterialPageRoute(
                          //   builder: (context) => SalesPaymetdetails(),
                          // ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: subcolor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                      child: Text('Save', style: commonWhiteStyle),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void checkBalance() {
    double enteredAmount = double.tryParse(finalAmountController.text) ?? 0;
    double balanceAmount = double.tryParse(BalanceAmtController.text) ?? 0;

    if (enteredAmount <= balanceAmount) {
    } else {
      // Display error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Warning'),
          content: Text(
              'The entered amount {$enteredAmount} is greater than the balance amount {$balanceAmount}.'),
          actions: [
            TextButton(
              onPressed: () {
                finalAmountController.text = balanceAmount.toString();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  List<Map<String, dynamic>> Paymentdetailsamounts = [];

  Future<void> FetchPaymentdetailsamounts(Map<String, dynamic> data) async {
    String Id = data["id"].toString(); // Convert Id to String
    final url = 'h$IpAddress/SalesPaymentDetailedalldatas/$Id';
    // print("url : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('salespaymentdetails')) {
          try {
            final List<dynamic> salesPaymentDetails =
                responseData['salespaymentdetails'];
            for (var detail in salesPaymentDetails) {
              Paymentdetailsamounts.add({
                'billno': detail['salesbill'],
                'amount': detail['Amount'],
              });
            }
            // Print Paymentdetailsamounts after setting state
            // print('Sales Payment Details: $Paymentdetailsamounts');
            SalesPaymentDetails(data);
          } catch (e) {
            throw FormatException('Invalid salespaymentdetails format');
          }
        } else {
          throw Exception(
              'Invalid response format: salespaymentdetails not found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  void SalesPaymentDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Sales Payments'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      Paymentdetailsamounts = [];
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Responsive.isDesktop(context)
                    ? Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BillNo',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 100
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  width: 100,
                                  color: Colors.grey[100],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['billno'] ?? ''),
                                    onChanged: (newValue) {
                                      BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
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
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Name',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.25,
                                child: Container(
                                  height: 24,
                                  width: 100,
                                  color: Colors.grey[100],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['name'] ?? ''),
                                    onChanged: (newValue) {
                                      BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
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
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  width: 100,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                    focusNode: ContactFocuNode,
                                    textInputAction: TextInputAction.next,
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['contact'] ?? ''),
                                    onChanged: (newValue) {
                                      CustomerContactController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
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
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  width: 100,
                                  color: Colors.grey[100],
                                  child: DateTimePicker(
                                    controller: TextEditingController(
                                        text: data['dt'] ?? ''),
                                    focusNode:
                                        DateFocuNode, // Add the focus node here
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    dateLabelText: '',
                                    onChanged: (val) {
                                      // Update selectedDate when the date is changed
                                      setState(() {
                                        selecteddt = DateTime.parse(val);
                                      });
                                      // print(val);
                                    },
                                    validator: (val) {
                                      // print(val);
                                      return null;
                                    },
                                    onSaved: (val) {
                                      // print(val);
                                    },
                                    style: TextStyle(fontSize: 13),
                                    textInputAction: TextInputAction.next,
                                    // onFieldSubmitted: (_) => _fieldFocusChange(
                                    //     context,
                                    //     DateFocuNode,
                                    //     BalanceFocuNode), // Switch focus to the next field
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paytype',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 24,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                    focusNode: BalanceFocuNode,
                                    textInputAction: TextInputAction.next,
                                    // onFieldSubmitted: (_) => _fieldFocusChange(
                                    //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['paymenttype'] ?? ''),
                                    onChanged: (newValue) {
                                      BalanceAmtController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
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
                          SizedBox(width: 20),
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
                                  height: 24,
                                  color: Colors.grey[100],
                                  child: TextFormField(
                                    focusNode: BalanceFocuNode,
                                    textInputAction: TextInputAction.next,
                                    // onFieldSubmitted: (_) => _fieldFocusChange(
                                    //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['amount'] ?? ''),
                                    onChanged: (newValue) {
                                      BalanceAmtController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
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
                          SizedBox(width: 20),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BillNo',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[100],
                                      child: TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['billno'] ?? ''),
                                        onChanged: (newValue) {
                                          BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Name',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[100],
                                      child: TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['name'] ?? ''),
                                        onChanged: (newValue) {
                                          BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[100],
                                      child: TextFormField(
                                        focusNode: ContactFocuNode,
                                        textInputAction: TextInputAction.next,
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['contact'] ?? ''),
                                        onChanged: (newValue) {
                                          CustomerContactController.text =
                                              newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      width: 100,
                                      color: Colors.grey[100],
                                      child: DateTimePicker(
                                        controller: TextEditingController(
                                            text: data['dt'] ?? ''),
                                        focusNode:
                                            DateFocuNode, // Add the focus node here
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        dateLabelText: '',
                                        onChanged: (val) {
                                          // Update selectedDate when the date is changed
                                          setState(() {
                                            selecteddt = DateTime.parse(val);
                                          });
                                          // print(val);
                                        },
                                        validator: (val) {
                                          // print(val);
                                          return null;
                                        },
                                        onSaved: (val) {
                                          // print(val);
                                        },
                                        style: TextStyle(fontSize: 12),
                                        textInputAction: TextInputAction.next,
                                        // onFieldSubmitted: (_) => _fieldFocusChange(
                                        //     context,
                                        //     DateFocuNode,
                                        //     BalanceFocuNode), // Switch focus to the next field
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Paytype',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      color: Colors.grey[100],
                                      child: TextFormField(
                                        focusNode: BalanceFocuNode,
                                        textInputAction: TextInputAction.next,
                                        // onFieldSubmitted: (_) => _fieldFocusChange(
                                        //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['paymenttype'] ?? ''),
                                        onChanged: (newValue) {
                                          BalanceAmtController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
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
                              SizedBox(width: 20),
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
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 24,
                                      color: Colors.grey[100],
                                      child: TextFormField(
                                        focusNode: BalanceFocuNode,
                                        textInputAction: TextInputAction.next,
                                        // onFieldSubmitted: (_) => _fieldFocusChange(
                                        //     context, BalanceFocuNode, PaymentTypeFocuNode),
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['amount'] ?? ''),
                                        onChanged: (newValue) {
                                          BalanceAmtController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 350 : 350,
                      width: MediaQuery.of(context).size.width * 0.7,
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 10.0, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.notes_rounded,
                                                  size: 15, color: Colors.blue),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Sales Billno",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.paid_outlined,
                                                  size: 15, color: Colors.blue),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Amount",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (Paymentdetailsamounts.isNotEmpty)
                                ...Paymentdetailsamounts.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> data = entry.value;
                                  var billno = data['billno'].toString();
                                  var amount = data['amount'].toString();
                                  var date = data['dt'].toString();

                                  bool isEvenRow = index % 2 ==
                                      0; // Using index for row color
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10,
                                      bottom: 5.0,
                                      top: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                billno,
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
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                amount,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [],
        ),
      ),
    );
  }

  Widget _tableview() {
    double screenHeight = MediaQuery.of(context).size.height;
    if (Responsive.isDesktop(context)) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: SingleChildScrollView(
                child: Container(
                  height: Responsive.isDesktop(context)
                      ? screenHeight * 0.75
                      : 350, // height: Responsive.isDesktop(context)
                  //     ? MediaQuery.of(context).size.width * 0.37
                  //     : 350,
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.5
                      : 700,
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text('Payment Details',
                                    style: commonLabelTextStyle),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 25,
                                    width: 255.0,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .format_list_numbered_rtl_rounded,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Billno",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_2_outlined,
                                            size: 15,
                                            color: Colors.blue,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            size: 15,
                                            color: Colors.blue,
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
                                    width: 255.0,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.date_range,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("dt",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment_outlined,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Payment",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.notes_sharp,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Cheq",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.date_range_outlined,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Cheqdt",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Flexible(
                                //   child: Container(
                                //     height: 25,
                                //     width: 255.0,
                                //     decoration: BoxDecoration(
                                //       color: Colors.grey[300],
                                //     ),
                                //     child: Center(
                                //       child: Row(
                                //         children: [
                                //           Icon(
                                //             Icons.refresh_rounded,
                                //             size: 15,
                                //             color: Colors.blue,
                                //           ),
                                //           SizedBox(
                                //             width: 5,
                                //           ),
                                //           Text(
                                //             "Refer",
                                //             textAlign: TextAlign.center,
                                //             style: TextStyle(
                                //                 color: Colors.white,
                                //                 fontWeight: FontWeight.w500),
                                //           ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.real_estate_agent_outlined,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Amount",
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
                          if (PaymenttableData.isNotEmpty)
                            ...PaymenttableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> data = entry.value;
                              var paymentid = data['id'].toString();

                              var billno = data['billno'].toString();
                              var name = data['name'].toString();
                              var contact = data['contact'].toString();
                              var dt = data['dt'].toString();
                              var paymenttype = data['paymenttype'].toString();
                              var chequeno = data['chequeno'].toString();
                              var chequedt = data['chequedt'].toString();
                              var reference = data['reference'].toString();
                              var amount = data['amount'].toString();
                              bool isEvenRow =
                                  PaymenttableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onTap: () {
                                  // SalesPaymentDetails(data);
                                  FetchPaymentdetailsamounts(data);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10,
                                      bottom: 5.0,
                                      top: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 255.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(billno,
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
                                          width: 255.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
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
                                          height: 30,
                                          width: 255.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(dt,
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
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(paymenttype,
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
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(chequeno,
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
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(chequedt,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                      // Flexible(
                                      //   child: Container(
                                      //     height: 30,
                                      //     width: 255.0,
                                      //     decoration: BoxDecoration(
                                      //       color: rowColor,
                                      //       border: Border.all(
                                      //         color: Color.fromARGB(
                                      //             255, 226, 225, 225),
                                      //       ),
                                      //     ),
                                      //     child: Center(
                                      //       child: Text(
                                      //         reference,
                                      //         textAlign: TextAlign.center,
                                      //         style: TextStyle(
                                      //           color: Colors.black,
                                      //           fontSize: 13,
                                      //           fontWeight: FontWeight.w400,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),

                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 255.0,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(amount,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: SingleChildScrollView(
                child: Container(
                  height: Responsive.isDesktop(context)
                      ? screenHeight * 0.75
                      : 350, // height: Responsive.isDesktop(context)
                  //     ? MediaQuery.of(context).size.width * 0.37
                  //     : 350,
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.3
                      : 450,
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child:
                                    Text('Sales Details', style: HeadingStyle),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 25,
                                    width: 255.0,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.notes_sharp,
                                            color: Colors.blue,
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Billno",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.date_range_outlined,
                                            color: Colors.blue,
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Dt",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.attach_money_sharp,
                                            color: Colors.blue,
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("FinalAmt",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.paid,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("PaidAmt",
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
                          if (tableData.isNotEmpty)
                            ...tableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> data = entry.value;
                              var date = data['dt'].toString();
                              var billno = data['billno'].toString();
                              var finalamount = data['finalamount'].toString();
                              var paidamount = data['paidamount'].toString();
                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                    bottom: 5.0,
                                    top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: 255.0,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(date,
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
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(billno,
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
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(finalamount,
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
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(paidamount,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 300 : 350,
                      width: Responsive.isDesktop(context) ? 800 : 500,
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Payment Details',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .format_list_numbered_rtl_rounded,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "B.No",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_2_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Name",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.call,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Cont",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.date_range,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Dt",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.payment_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Pay",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.notes_sharp,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Cheq",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.date_range_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "C.Dt",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Flexible(
                                    //   child: Container(
                                    //     height: 25,
                                    //     decoration: BoxDecoration(
                                    //       color: maincolor,
                                    //       border: Border.all(
                                    //         color: Colors.black,
                                    //       ),
                                    //     ),
                                    //     child: Center(
                                    //       child: Text(
                                    //         "Refere",
                                    //         textAlign: TextAlign.center,
                                    //         style: TextStyle(
                                    //             color: Colors.black,
                                    //             fontWeight: FontWeight.w500),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),

                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .real_estate_agent_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Amt",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (PaymenttableData.isNotEmpty)
                                ...PaymenttableData.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> data = entry.value;
                                  var billno = data['billno'].toString();
                                  var name = data['name'].toString();
                                  var contact = data['contact'].toString();
                                  var dt = data['dt'].toString();
                                  var paymenttype =
                                      data['paymenttype'].toString();
                                  var chequeno = data['chequeno'].toString();
                                  var chequedt = data['chequedt'].toString();
                                  var reference = data['reference'].toString();
                                  var amount = data['amount'].toString();
                                  bool isEvenRow =
                                      PaymenttableData.indexOf(data) % 2 == 0;
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

                                  return GestureDetector(
                                    onTap: () {
                                      // SalesPaymentDetails(data);
                                      FetchPaymentdetailsamounts(data);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 10,
                                          bottom: 5.0,
                                          top: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  billno,
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
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
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
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  contact,
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
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  dt,
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
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  paymenttype,
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
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  chequeno,
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
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  chequedt,
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
                                          // Flexible(
                                          //   child: Container(
                                          //     height: 30,
                                          //     decoration: BoxDecoration(
                                          //       color: rowColor,
                                          //       border: Border.all(
                                          //         color: Color.fromARGB(
                                          //             255, 226, 225, 225),
                                          //       ),
                                          //     ),
                                          //     child: Center(
                                          //       child: Text(
                                          //         reference,
                                          //         textAlign: TextAlign.center,
                                          //         style: TextStyle(
                                          //           color: Colors.black,
                                          //           fontSize: 13,
                                          //           fontWeight: FontWeight.w400,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),

                                          Flexible(
                                            child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  amount,
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
                                    ),
                                  );
                                }).toList()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: SingleChildScrollView(
              child: Container(
                height: Responsive.isDesktop(context) ? 400 : 350,
                width: 600,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Sales Details',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 25,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.notes_sharp,
                                          color: Colors.blue,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Billno",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.date_range_outlined,
                                          color: Colors.blue,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Dt",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.attach_money_outlined,
                                          color: Colors.blue,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "FinalAmt",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 25,
                                  width: 255.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.paid,
                                          color: Colors.blue,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "PaidAmt",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (tableData.isNotEmpty)
                          ...tableData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> data = entry.value;
                            var date = data['dt'].toString();
                            var billno = data['billno'].toString();
                            var finalamount = data['finalamount'].toString();
                            var paidamount = data['paidamount'].toString();
                            bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                            Color? rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10, bottom: 5.0, top: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: 30,
                                      width: 255.0,
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          date,
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
                                      width: 255.0,
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          billno,
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
                                      width: 255.0,
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          finalamount,
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
                                      width: 255.0,
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          paidamount,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
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
                    'Payments Successfully..!!',
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

  void AmountWarningMessage() {
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
                'Please Check the Payment Details For this Supplier',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void WarninngMessage() {
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
                'Please fill in all fields',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}
