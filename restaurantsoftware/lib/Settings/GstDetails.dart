import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(GstDetailsForm());
}

class GstDetailsForm extends StatefulWidget {
  @override
  State<GstDetailsForm> createState() => _GstDetailsFormState();
}

class _GstDetailsFormState extends State<GstDetailsForm> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int selectedOption = 1; // Default selected option
  String searchText = '';

  @override
  void initState() {
    super.initState();

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
    String apiUrl = '$IpAddress/GstDetails/$cusid/';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> namelist = [];

      for (var item in data) {
        int gstID = item['id'];
        String gstName = item['name'];
        String gstStatus = item['status'];
        String gstGst = item['gst'];

        namelist.add({
          'id': gstID,
          'name': gstName,
          'status': gstStatus,
          'gst': gstGst,
        });
      }

      // Sort the data by 'id' in ascending order
      namelist.sort((a, b) => a['id'].compareTo(b['id']));

      setState(() {
        tableData = namelist;
      });
    }
  }

  final TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

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
                      Text(
                        'Gst Details',
                        style: HeadingStyle,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showFormDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          backgroundColor: subcolor,
                          minimumSize: Size(45.0, 31.0),
                        ),
                        child: Text(
                          'Add +',
                          style: commonWhiteStyle,
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
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
                                        color: Colors.black, width: 1.0),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  contentPadding:
                                      EdgeInsets.only(left: 10.0, right: 4.0),
                                ),
                                style: textStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: Responsive.isDesktop(context)
                            ? screenHeight * 0.7
                            : 440,
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 0.0, right: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cabin,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Name",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.percent,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Status",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.star_rate_sharp,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Gst",
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
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.call_to_action,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              "Actions",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle,
                                            ),
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
                                var status = data['status'].toString();
                                var gst = data['gst'].toString();
                                bool isEvenRow =
                                    tableData.indexOf(data) % 2 == 0;
                                Color? rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 255, 255, 255);

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0.0,
                                    right: 0.0,
                                    top: 3.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              status,
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
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
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
                                                  gst.isEmpty ? 'NonGst' : gst,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade200),
                                                ),
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.edit_square,
                                                      color: Colors.blue,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      Productid =
                                                          data['id'].toString();
                                                      _showFormDialog(context,
                                                          data: data,
                                                          productId: Productid);
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
                                                      _showDeleteConfirmationDialog(
                                                          data);
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
                              }).toList()
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ])),
    );
  }

  void _showFormDialog(BuildContext context,
      {Map<String, dynamic>? data, String? productId}) {
    String title = data == null ? 'Add Gst Details' : 'Update Gst Details';
    String saveButtonText = data == null ? 'Save' : 'Update';
    selectedValue = data != null ? data['name'] : null;
    selectedStatus = data != null ? data['status'] : null;
    selectedGst = data != null ? data['gst'] : null;
    isIncludingGst = selectedGst == 'Including';
    isExcludingGst = selectedGst == 'Excluding';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Container(
            width: 100,
            height: Responsive.isDesktop(context) ? 380 : 400,
            padding: EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    ),
                    Text(
                      title,
                      style: commonLabelTextStyle,
                    ),
                    SizedBox(height: 30),
                    _buildCombo('Name', initialValue: selectedValue,
                        onSelect: (value) {
                      selectedValue = value;
                    }),
                    SizedBox(height: 20),
                    _buildRadiobuttonAndGst('status',
                        initialValue: selectedStatus, setState: setState),
                    SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          if (data == null) {
                            _saveDataToAPI();
                          } else {
                            _UpdateDataToAPI(productId!);

                            print("Id : $productId");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          backgroundColor: subcolor,
                          minimumSize: Size(45.0, 31.0),
                        ),
                        child: Text(
                          saveButtonText,
                          style: commonWhiteStyle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  String? selectedStatus;
  String? selectedGst;
  bool isIncludingGst = true;
  bool isExcludingGst = true;

  String? selectedValue;
  List<String> nameComboList = [
    'Purchase',
    'Sales',
    'OrderSales',
    'VendorSales'
  ];

  Widget _buildRadiobuttonAndGst(String label,
      {String? initialValue, required StateSetter setState}) {
    List<bool> isSelected = [isIncludingGst, isExcludingGst];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: commonLabelTextStyle,
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Radio<String>(
                value: 'Gst',
                groupValue: initialValue,
                onChanged: (value) {
                  setState(() {
                    initialValue = value;
                    selectedStatus = value;
                    selectedGst = 'Including';
                    isIncludingGst = true;
                    isExcludingGst = false;
                  });
                },
                activeColor: Colors.blue,
              ),
              Text('Gst', style: textStyle),
              SizedBox(width: 16),
              Radio<String>(
                value: 'NonGst',
                groupValue: initialValue,
                onChanged: (value) {
                  setState(() {
                    initialValue = value;
                    selectedStatus = value;
                    selectedGst = null;
                    isIncludingGst = false;
                    isExcludingGst = false;
                  });
                },
                activeColor: Colors.blue,
              ),
              Text('NonGst', style: textStyle),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              selectedStatus == 'Gst'
                  ? _buildGst('Gst', isSelected, setState)
                  : SizedBox(),
            ],
          )
        ],
      ),
    );
  }

  FocusNode CatFocus = FocusNode();

  Widget CategoryDropdown({
    String? initialValue,
    void Function(String?)? onChanged,
  }) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          focusNode: CatFocus,
          items: nameComboList
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: textStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: initialValue,
          onChanged: (String? value) {
            onChanged?.call(value);
            _fieldFocusChange(context, CatFocus, GstFocus);
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              ),
              color: Colors.white,
            ),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down,
            ),
            iconSize: 14,
            iconEnabledColor: Colors.black,
            iconDisabledColor: Colors.grey,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 150,
            width: 150,
            decoration: BoxDecoration(),
            offset: const Offset(0, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all<double>(6),
              thumbVisibility: MaterialStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 30,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      );
    });
  }

  FocusNode GstFocus = FocusNode();

  Widget _buildGst(
    String label,
    List<bool> isSelected,
    StateSetter setState,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: commonLabelTextStyle),
          SizedBox(height: 10),
          Container(
            height: 30,
            child: Focus(
              focusNode: GstFocus,
              child: ToggleButtons(
                borderColor: Colors.grey,
                fillColor: Color.fromARGB(255, 52, 108, 131),
                borderWidth: 1,
                selectedColor: Colors.white,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Including',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Excluding',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    // Update isSelected list based on the selected index
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }

                    // Update isIncludingGst and isExcludingGst based on selected option
                    isIncludingGst = index == 0;
                    isExcludingGst = index == 1;
                  });
                },
                isSelected: isSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombo(String label,
      {String? initialValue, Function(String?)? onSelect}) {
    String? selectedValue = initialValue;

    return Container(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: commonLabelTextStyle,
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 150,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return CategoryDropdown(
                          initialValue: selectedValue,
                          onChanged: (String? value) {
                            setState(() {
                              selectedValue = value;
                              onSelect?.call(
                                  value); // Callback to update parent state
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  void _saveDataToAPI() async {
    String status = selectedStatus ?? 'Gst';
    String gst = status == 'Gst'
        ? (isIncludingGst ? 'Including' : 'Excluding')
        : 'NonGst';

    if (isNameAlreadyAdded(selectedValue)) {
      WarninngMessage();
      return;
    }

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/GstDetailsalldatas/';
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      'name': selectedValue,
      'status': status,
      'gst': gst,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(postData),
      headers: {'Content-Type': 'application/json'},
    );

    print('Request Data: $postData');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      print('Data saved successfully');
      // Close the dialog
      Navigator.of(context).pop();
      await logreports("Gst Details: ${selectedValue}_${status}_Inserted");
      // Fetch updated data
      await fetchData();
      successfullySavedMessage(context);

      // Reset the combo and radio button states
      setState(() {
        selectedValue = null; // or any default value
        selectedStatus = null; // or any default value
        isIncludingGst = true; // or set it to the default value
      });
    } else {
      // Handle error in saving data
      print('Failed to save data. Status code: ${response.statusCode}');
      // You may want to display an error message to the user
    }
  }

  int id = 0;

  void _UpdateDataToAPI(String Productid) async {
    // Extract the entered data
    String status = selectedStatus ?? 'Gst';
    String gst = status == 'Gst'
        ? (isIncludingGst ? 'Including' : 'Excluding')
        : 'NonGst';
    if (isNameAlreadyAdded(selectedValue)) {
      WarninngMessage();
      return;
    }
    // Make API request to save the data

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/GstDetailsalldatas/$Productid/';
    Map<String, dynamic> putData = {
      "cusid": "$cusid",
      'name': selectedValue,
      'status': status,
      'gst': gst,
    };

    http.Response response = await http.put(
      Uri.parse(apiUrl),
      body: json.encode(putData),
      headers: {'Content-Type': 'application/json'},
    );

    print('Request Data: $putData');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      print('Data saved successfully');
      // Close the dialog
      Navigator.of(context).pop();
    } else {
      // Handle error in saving data
      print('Failed to save data. Status code: ${response.statusCode}');
      // Close the dialog
      Navigator.of(context).pop();
    }
    await logreports("Gst Details: ${selectedValue}_${status}_Updated");
    await fetchData();
    successfullyUpdateMessage(context);
    setState(() {
      selectedValue = null; // or any default value
      selectedStatus = null; // or any default value
      isIncludingGst = true; // or set it to the default value
    });
  }

  bool isNameAlreadyAdded(String? name) {
    // Implement the logic to check if the name is already added
    return tableData.any((data) => data['name'] == name);
  }

  void _deleteData(int id) async {
    // Make API request to delete the data
    String apiUrl = '$IpAddress/GstDetailsalldatas/$id/';

    String status = selectedStatus ?? 'Gst';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    print('Delete Request: $apiUrl');
    print('Delete Response Status Code: ${response.statusCode}');
    print('Delete Response Body: ${response.body}');

    if (response.statusCode == 204) {
      // Successfully deleted data, you can handle the response accordingly
      print('Data deleted successfully');
      // Fetch updated data
      await logreports("Gst Details: ${selectedValue}_${status}_Deleted");

      await fetchData();
      successfullyDeleteMessage(context);
    } else {
      // Handle error in deleting data
      print('Failed to delete data. Status code: ${response.statusCode}');
      // You may want to display an error message to the user
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(Map<String, dynamic> data) async {
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
                  Text('Confirm Delete', style: commonLabelTextStyle),
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
                style: textStyle,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteData(data['id']);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete', style: commonWhiteStyle),
            ),
          ],
        );
      },
    );
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
                    'Name already exists..!!',
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
