import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Settings/ProductCategory.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(AddProductDetailsPage());
}

class AddProductDetailsPage extends StatefulWidget {
  @override
  _AddProductDetailsPageState createState() => _AddProductDetailsPageState();
}

class _AddProductDetailsPageState extends State<AddProductDetailsPage> {
  bool isSwitched = false;
  int number = 0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  String searchText = '';

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Convert search text to lowercase
    String searchTextLower = searchText.toLowerCase();

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) =>
            (data['name'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
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

  List<String> productNames = [];
  Future<void> fetchAllProductNames() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';

    while (true) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);
        for (var result in results) {
          String productName = result['name'];
          productNames.add(productName);
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
    print(productNames);
  }

  List<double> sgstPercentages = [0, 2.5, 6, 9, 14]; // List of SGST percentages
  List<bool> isSelectedsgst = []; // Initial state

  List<double> cgstPercentages = [0, 2.5, 6, 9, 14]; // List of SGST percentages
  List<bool> isSelectedcgst = []; // Initial state

  @override
  void initState() {
    isSelectedcgst = [true, false, false, false, false];
    isSelectedsgst = [true, false, false, false, false];

    super.initState();
    fetchsidebarmenulist();
    getrole();
    fetchPurchaseProductCodeo();
    fetchAllProductCategories();
    fetchProductDetails();
    fetchAllProductNames();
    fetchAllProductNameForCombo();
    ComboQtyCOntroller.text = "0";
    retailAmount.text = "0.0";
    WholeSalesretailAmount.text = "0.0";
    onlineAmount.text = "0.0";

    if (_selectedOption == "Normal") {
      ComboNameCOntroller.text = "";
      _CombotableData.clear();
    }
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String PurchaseProductCode = '';

  Future<void> fetchPurchaseProductCodeo() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetailsSNo/$cusid/';
    int maxSerialNumber = 0;

    try {
      while (true) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          int currentSerialNumber = int.parse(jsonData['sno'].toString());
          if (currentSerialNumber > maxSerialNumber) {
            maxSerialNumber = currentSerialNumber;
          }

          if (jsonData['next'] != null) {
            apiUrl = jsonData['next'];
          } else {
            break;
          }
        } else {
          throw Exception(
              'Failed to load serial number. Status code: ${response.statusCode}');
        }
      }

      setState(() {
        PurchaseProductCode = (maxSerialNumber + 1).toString();
      });
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  TextEditingController StatusController =
      TextEditingController(text: 'Normal');
  TextEditingController onlineAmount = TextEditingController();
  TextEditingController retailAmount = TextEditingController();
  TextEditingController WholeSalesretailAmount = TextEditingController();
  TextEditingController ProductCategoryController = TextEditingController();

  TextEditingController ProductNameCOntroller = TextEditingController();
  TextEditingController StockValueController = TextEditingController(text: '0');

  final FocusNode _RetailDineinFocus = FocusNode();

  final FocusNode _RetailTakeAwayFocus = FocusNode();

  final FocusNode _OnlineAmtFocus = FocusNode();

  final FocusNode _ProductNameFocus = FocusNode();

  final FocusNode SwitchFocus = FocusNode();
  final FocusNode StcokValueFocus = FocusNode();
  final FocusNode GstFocus = FocusNode();

  String _selectedOption = 'Normal';

  void _handleRadioValueChange(String? value) {
    setState(() {
      _selectedOption = value!;
    });
  }

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
        backgroundColor: Colors.grey[200],
        body: Row(children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 10, bottom: 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Product Details',
                          style: HeadingStyle,
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          child: Container(
                            height: Responsive.isDesktop(context)
                                ? screenHeight * 0.9
                                : 700,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 0),
                              child: Responsive.isDesktop(context)
                                  ? builDMainWebView()
                                  : builDMainMobileView(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // For image

  XFile? _image;
  final picker = ImagePicker();
  bool _isImageUploaded = false;

  Future getImage() async {
    print('Selecting image...');
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('Image selected: ${pickedFile.path}');
      setState(() {
        _image = pickedFile;
      });
      _showImageDialog(pickedFile);
    } else {
      print('No image selected.');
    }
  }

  bool ImageUpdateMode = false;

  void _showImageDialog(XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: EdgeInsets.all(20.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  ImageUpdateMode ? 'Uploaded Image' : 'Upload Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _image != null
                      ? kIsWeb
                          ? Image.network(_image!.path, fit: BoxFit.cover)
                          : Image.file(File(_image!.path), fit: BoxFit.cover)
                      : Container(),
                ),
                SizedBox(height: 20),
                Text(
                  ImageUpdateMode
                      ? 'Would you like to update the image?'
                      : 'Confirm image?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (ImageUpdateMode) {
                          getImage();
                          setState(() {
                            _isImageUploaded = true;
                            ImageUpdateMode = false;
                          });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _isImageUploaded = true;
                            ImageUpdateMode = false;
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 49, 48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                      ),
                      child: Text(ImageUpdateMode ? '✍ Update' : 'Ok',
                          style: commonWhiteStyle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget builDMainWebView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Product Code : $PurchaseProductCode',
                style: commonLabelTextStyle,
              ),
              Spacer(),
              Transform.scale(
                scale: 0.7,
                child: Radio<String>(
                  value: 'Normal',
                  groupValue: _selectedOption,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              Text('Normal'),
              SizedBox(width: 20.0),
              Transform.scale(
                scale: 0.7,
                child: Radio<String>(
                  value: 'Combo',
                  groupValue: _selectedOption,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              Text('Combo'),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
          buildwebView(),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
          SizedBox(
            height: 10,
          ),
          _selectedOption == 'Normal' ? tableView() : ComboView(),
          SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: hasPreviousPage ? () => loadPreviousPage() : null,
                ),
                SizedBox(width: 5),
                Text(
                  '$currentPage / $totalPages',
                  style: commonLabelTextStyle,
                ),
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
    );
  }

  Widget builDMainMobileView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Product Code : $PurchaseProductCode',
                style: commonLabelTextStyle,
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.scale(
                scale: 0.7,
                child: Radio<String>(
                  value: 'Normal',
                  groupValue: _selectedOption,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              Text('Normal'),
              SizedBox(width: 5.0),
              Transform.scale(
                scale: 0.7,
                child: Radio<String>(
                  value: 'Combo',
                  groupValue: _selectedOption,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              Text('Combo'),
            ],
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 1, //thickness of divider line
          ),
          buildMobileView(),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 1, //thickness of divider line
          ),
          SizedBox(
            height: 10,
          ),
          _selectedOption == 'Normal' ? tableView() : ComboView(),
          SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: hasPreviousPage ? () => loadPreviousPage() : null,
                ),
                SizedBox(width: 5),
                Text(
                  '$currentPage / $totalPages',
                  style: commonLabelTextStyle,
                ),
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
    );
  }

  int stockValue = 0;
  bool isUpdateMode = false;
  double selectedSgstPercentage = 0;
  double selectedCgstPercentage = 0;

  Widget buildwebView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Category',
                    style: commonLabelTextStyle,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Container(
                          height: 24,
                          width: 150,
                          child: ProductCategoryDropdown()),
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
                                      ProductCategory(),
                                      Positioned(
                                        right: 0.0,
                                        top: 0.0,
                                        child: IconButton(
                                          icon: Icon(Icons.cancel,
                                              color: Colors.red, size: 23),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            fetchAllProductCategories();
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
            ),
            SizedBox(width: 13),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Name', style: commonLabelTextStyle),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 24,
                        width: 150,
                        child: TextField(
                          onSubmitted: (value) {
                            _fieldFocusChange(
                                context, _ProductNameFocus, _RetailDineinFocus);
                            retailAmount.text = "";
                            checkNameExists();
                          },
                          controller: ProductNameCOntroller,
                          readOnly:
                              (_selectedOption == 'Combo' && isUpdateMode),
                          focusNode: _ProductNameFocus,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 13,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Retail Amount(DineIn)', style: commonLabelTextStyle),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 27,
                      width: 100,
                      child: TextField(
                        controller: retailAmount,
                        focusNode: _RetailDineinFocus,
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          _fieldFocusChange(context, _RetailDineinFocus,
                              _RetailTakeAwayFocus);
                          WholeSalesretailAmount.text = "";
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: AmountTextStyle,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 13,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Retail Amount(TakeAway)', style: commonLabelTextStyle),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 27,
                      width: 100,
                      child: TextField(
                        controller: WholeSalesretailAmount,
                        focusNode: _RetailTakeAwayFocus,
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          _fieldFocusChange(
                              context, _RetailTakeAwayFocus, _OnlineAmtFocus);
                          onlineAmount.text = "";
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: AmountTextStyle,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 13,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Online Amount', style: commonLabelTextStyle),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 27,
                      width: 100,
                      child: TextField(
                        controller: onlineAmount,
                        focusNode: _OnlineAmtFocus,
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          _fieldFocusChange(
                              context, _OnlineAmtFocus, SwitchFocus);
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: AmountTextStyle,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 13,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: commonLabelTextStyle,
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
                Focus(
                  focusNode: SwitchFocus,
                  child: Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                        _fieldFocusChange(
                            context, SwitchFocus, StcokValueFocus);
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 13,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child:
                      Text('Current Stock Value', style: commonLabelTextStyle),
                ),
                SizedBox(height: 5),
                Container(
                  height: 35,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 1,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            // Decrease the value by 1 when "-" button is tapped
                            int currentValue =
                                int.tryParse(StockValueController.text) ?? 0;
                            if (currentValue > 0) {
                              StockValueController.text =
                                  (currentValue - 1).toString();
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: subcolor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 6, right: 6, top: 2, bottom: 2),
                            child: Text(
                              "-",
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                            width: 45,
                            child: TextField(
                              focusNode: StcokValueFocus,
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                _fieldFocusChange(
                                    context, StcokValueFocus, GstFocus);
                              },
                              controller: StockValueController,
                              onChanged: (value) {
                                setState(() {
                                  stockValue = int.tryParse(value) ?? 0;
                                });
                              },
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            )),
                      ),
                      SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          setState(() {
                            // Decrease the value by 1 when "-" button is tapped
                            int currentValue =
                                int.tryParse(StockValueController.text) ?? 0;
                            StockValueController.text =
                                (currentValue + 1).toString();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: subcolor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 6, right: 6, top: 2, bottom: 2),
                            child: Text(
                              "+",
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              width: 13,
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: InkWell(
                  onTap: () {
                    if (_isImageUploaded == true) {
                      _showImageDialog(_image!);
                    } else {
                      getImage();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: _isImageUploaded ? subcolor : Colors.blue,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                          _isImageUploaded ? '👁 View Image' : '✍ Upload Image',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade200)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text('Cgst % ', style: commonLabelTextStyle),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 28,
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
                  ),
                ],
              ),
              SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sgst % ', style: commonLabelTextStyle),
                  SizedBox(height: 5),
                  Container(
                    height: 28,
                    child: ToggleButtons(
                      borderColor: Colors.grey,
                      fillColor: Color.fromARGB(255, 52, 108, 131),
                      borderWidth: 1,
                      selectedColor: Colors.white,
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
              SizedBox(
                width: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: isUpdateMode ? UpdateButton() : SaveButton(),
              ),
              SizedBox(
                width: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _DeleteItem(),
              ),
              SizedBox(
                width: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _RefreshItem(),
              ),
              SizedBox(
                width: 90,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 20.0),
                child: Container(height: 30, width: 140, child: Search()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMobileView() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product Category', style: commonLabelTextStyle),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            Container(
                                height: 24,
                                width: 115,
                                child: ProductCategoryDropdown()),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Container(
                                        width: 1150,
                                        height: 800,
                                        padding: EdgeInsets.all(16),
                                        child: Stack(
                                          children: [
                                            ProductCategory(),
                                            Positioned(
                                              right: 0.0,
                                              top: 0.0,
                                              child: IconButton(
                                                icon: Icon(Icons.cancel,
                                                    color: Colors.red,
                                                    size: 23),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
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
                                      left: 2, right: 6, top: 2, bottom: 2),
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
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product Name', style: commonLabelTextStyle),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 24,
                              width: 150,
                              child: TextField(
                                onSubmitted: (value) {
                                  _fieldFocusChange(context, _ProductNameFocus,
                                      _RetailDineinFocus);
                                  retailAmount.text = "";
                                  checkNameExists();
                                },
                                controller: ProductNameCOntroller,
                                focusNode: _ProductNameFocus,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Retail Amount(DineIn)',
                          style: commonLabelTextStyle),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 27,
                            width: 100,
                            child: TextField(
                              controller: retailAmount,
                              focusNode: _RetailDineinFocus,
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                _fieldFocusChange(context, _RetailDineinFocus,
                                    _RetailTakeAwayFocus);
                                WholeSalesretailAmount.text = "";
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
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
                              style: AmountTextStyle,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Retail Amount(Takeaway)',
                          style: commonLabelTextStyle),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 27,
                            width: 120,
                            child: TextField(
                              controller: WholeSalesretailAmount,
                              focusNode: _RetailTakeAwayFocus,
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                _fieldFocusChange(context, _RetailTakeAwayFocus,
                                    _OnlineAmtFocus);
                                onlineAmount.text = "";
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
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
                              style: AmountTextStyle,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Online Amount', style: commonLabelTextStyle),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 27,
                            width: 120,
                            child: TextField(
                              controller: onlineAmount,
                              focusNode: _OnlineAmtFocus,
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                _fieldFocusChange(
                                    context, _OnlineAmtFocus, SwitchFocus);
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
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
                              style: AmountTextStyle,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: commonLabelTextStyle,
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
                      Focus(
                        focusNode: SwitchFocus,
                        child: Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                              _fieldFocusChange(
                                  context, SwitchFocus, StcokValueFocus);
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text('Current Stock Value',
                            style: commonLabelTextStyle),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 1,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // Decrease the value by 1 when "-" button is tapped
                                  int currentValue =
                                      int.tryParse(StockValueController.text) ??
                                          0;
                                  if (currentValue > 0) {
                                    StockValueController.text =
                                        (currentValue - 1).toString();
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: subcolor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6, top: 2, bottom: 2),
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                  width: 45,
                                  child: TextField(
                                    focusNode: StcokValueFocus,
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (value) {
                                      _fieldFocusChange(
                                          context, StcokValueFocus, GstFocus);
                                    },
                                    controller: StockValueController,
                                    onChanged: (value) {
                                      setState(() {
                                        stockValue = int.tryParse(value) ?? 0;
                                      });
                                    },
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  )),
                            ),
                            SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // Decrease the value by 1 when "-" button is tapped
                                  int currentValue =
                                      int.tryParse(StockValueController.text) ??
                                          0;
                                  StockValueController.text =
                                      (currentValue + 1).toString();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: subcolor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6, top: 2, bottom: 2),
                                  child: Text(
                                    "+",
                                    style: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text('Cgst % ', style: commonLabelTextStyle),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 28,
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
                                for (int i = 0;
                                    i < isSelectedcgst.length;
                                    i++) {
                                  isSelectedcgst[i] = i == index;
                                }
                                if (isSelectedcgst[index]) {
                                  selectedCgstPercentage =
                                      cgstPercentages[index];
                                }
                              });
                            },
                            isSelected: isSelectedcgst,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0),
                    child: InkWell(
                      onTap: () {
                        if (_isImageUploaded == true) {
                          _showImageDialog(_image!);
                        } else {
                          getImage();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: _isImageUploaded ? subcolor : Colors.blue,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              _isImageUploaded
                                  ? '👁 View Image'
                                  : '✍ Upload Image',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade200)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text('Sgst % ', style: commonLabelTextStyle),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 28,
                        child: ToggleButtons(
                          borderColor: Colors.grey,
                          fillColor: Color.fromARGB(255, 52, 108, 131),
                          borderWidth: 1,
                          selectedColor: Colors.white,
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
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  isUpdateMode ? UpdateButton() : SaveButton(),
                  SizedBox(
                    width: 8,
                  ),
                  _DeleteItem(),
                  SizedBox(
                    width: 8,
                  ),
                  _RefreshItem(),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10.0,
                  ),
                  child: Container(height: 30, width: 110, child: Search()),
                ),
              ],
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

  void imageGet(base64Image) async {
    if (base64Image != null) {
      Uint8List bytes = base64Decode(base64Image);

      String tempPath = (await getTemporaryDirectory()).path;
      String tempFileName = DateTime.now().millisecondsSinceEpoch.toString();
      String tempFilePath = '$tempPath/$tempFileName.png';

      File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes);

      Image.file(File(tempFilePath));
    }
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: Responsive.isDesktop(context) ? screenHeight * 0.6 : 400,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.80
                  : MediaQuery.of(context).size.width * 1.8,
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.numbers,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Code",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fastfood,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 2),
                                    Text("ProdName",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
                                    Text("Product Cat",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.currency_bitcoin,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Retail(DineIn)",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    Text("Retail(TakeAway)₹",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.currency_exchange,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Online ₹",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.keyboard_option_key,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Stock",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
                                    Text("Stock Value",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
                                    Text("Cgst %",
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
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
                        ),
                        Flexible(
                          child: Container(
                            width: 265.0,
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
                        ),
                      ],
                    ),
                  ),
                  if (getFilteredData().isNotEmpty)
                    ...getFilteredData().map((data) {
                      var productcode = data['code'].toString();
                      var name = data['name'].toString();
                      var category = data['category'].toString();
                      var amount = data['amount'].toString();
                      var retailTakeaway = data['wholeamount'].toString();

                      var OnlineAmt = data['OnlineAmt'].toString();
                      var stock = data['stock'].toString();
                      var stockvalue = data['stockvalue'].toString();
                      var cgstper = data['cgstper'].toString();
                      var sgstper = data['sgstper'].toString();
                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, right: 0, top: 3.0),
                        child: GestureDetector(
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
                                    child: Text(
                                      productcode,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                  child: Tooltip(
                                    message: name,
                                    child: Center(
                                      child: Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle,
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
                                    child: Text(
                                      category,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                    child: Text(
                                      amount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                    child: Text(
                                      retailTakeaway,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                    child: Text(
                                      OnlineAmt,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                    // child: ElevatedButton(
                                    //   onPressed: () {},
                                    child: Container(
                                      // Wrap Text with Container for different styles
                                      child: Text(
                                        stock,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          // Add additional styles here
                                        ),
                                      ),
                                    ),
                                    //   style: ElevatedButton.styleFrom(
                                    //     minimumSize: Size(30.0, 25.0),
                                    //     backgroundColor:
                                    //         Color.fromARGB(255, 160, 6, 121),
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(5),
                                    //     ),
                                    //   ),
                                    // ),
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
                                    child: Text(
                                      stockvalue,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
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
                                          cgstper,
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
                                          sgstper,
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
                                            onPressed: () async {
                                              try {
                                                _isImageUploaded = true;
                                                ImageUpdateMode = true;

                                                String base64Image =
                                                    data['image'];

                                                if (base64Image != null) {
                                                  Uint8List bytes =
                                                      base64Decode(base64Image);

                                                  if (kIsWeb) {
                                                    _image = XFile.fromData(
                                                        bytes,
                                                        name: 'image.png');
                                                  } else {
                                                    String tempPath =
                                                        (await getTemporaryDirectory())
                                                            .path;
                                                    String tempFileName = DateTime
                                                            .now()
                                                        .millisecondsSinceEpoch
                                                        .toString();
                                                    String tempFilePath =
                                                        '$tempPath/$tempFileName.png';

                                                    File tempFile =
                                                        File(tempFilePath);
                                                    await tempFile
                                                        .writeAsBytes(bytes);

                                                    XFile imageFile =
                                                        XFile(tempFilePath);

                                                    setState(() {
                                                      _image = imageFile;
                                                    });
                                                  }
                                                }

                                                setState(() {
                                                  Productid =
                                                      data['id'].toString();
                                                  ProductCategoryController
                                                          .text =
                                                      data['category']
                                                          .toString();
                                                  ProductNameCOntroller.text =
                                                      data['name'].toString();
                                                  PurchaseProductCode =
                                                      data['code'].toString();
                                                  retailAmount.text =
                                                      data['amount'].toString();
                                                  WholeSalesretailAmount.text =
                                                      data['wholeamount']
                                                          .toString();
                                                  onlineAmount.text =
                                                      data['OnlineAmt']
                                                          .toString();
                                                  isSwitched = data['stock']
                                                          .toString() ==
                                                      'Yes';
                                                  double currentValue =
                                                      double.tryParse(data[
                                                                  'stockvalue']
                                                              .toString()) ??
                                                          0.0;
                                                  int intValue =
                                                      currentValue.toInt();
                                                  StockValueController.text =
                                                      intValue.toString();

                                                  // Update cgst percentage and initialize isSelectedcgst list
                                                  cgstper = data['cgstper']
                                                      .toString();
                                                  int cgstIndex =
                                                      cgstPercentages.indexOf(
                                                          double.parse(
                                                              cgstper));
                                                  isSelectedcgst =
                                                      List.generate(
                                                    cgstPercentages.length,
                                                    (index) =>
                                                        index == cgstIndex,
                                                  );

                                                  // Update sgst percentage and initialize isSelectedsgst list
                                                  sgstper = data['sgstper']
                                                      .toString();
                                                  int sgstIndex =
                                                      sgstPercentages.indexOf(
                                                          double.parse(
                                                              sgstper));
                                                  isSelectedsgst =
                                                      List.generate(
                                                    sgstPercentages.length,
                                                    (index) =>
                                                        index == sgstIndex,
                                                  );

                                                  isUpdateMode = true;

                                                  // For Combo
                                                  String status =
                                                      data['status'].toString();
                                                  if (status == "Combo") {
                                                    _selectedOption = 'Combo';
                                                    ComboNameCOntroller.text =
                                                        data['name'].toString();
                                                    String ComboName =
                                                        data['name'].toString();
                                                    _fetchComboDetails(
                                                        ComboName);
                                                    isMovingButtonVisible =
                                                        false;
                                                    isUpdateButtonVisible =
                                                        true;
                                                    isEditIconVisible = true;
                                                  }
                                                });
                                              } catch (e) {
                                                print("Error in onTap: $e");
                                              }
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
                        ),
                      );
                    }).toList()
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> ProductCategoryList = [];
  // Fetch Combo details when i double click Row

  Future<void> _fetchComboDetails(String comboName) async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_Combo/$cusid/';
    List<Map<String, dynamic>> filteredCombos = [];

    while (apiUrl != null) {
      final response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> comboList =
            List<Map<String, dynamic>>.from(jsonData['results']);

        for (var combo in comboList) {
          if (combo['name'] == comboName) {
            String itemName = combo['item'];
            String itemQty = combo['qty'].toString();
            filteredCombos.add({
              'id': combo['id'].toString(),
              'prodname': itemName,
              'qty': itemQty,
            });
            setState(() {
              // print('filteredCombos: $filteredCombos');
              _CombotableData.clear();
              _CombotableData.addAll(
                  filteredCombos.map((e) => e.cast<String, String>()));
            });
          }
        }
      }

      apiUrl = jsonData['next'];
    }
  }

  Future<void> fetchAllProductCategories() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductCategory/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductCategoryList.addAll(
              results.map<String>((item) => item['cat'].toString()));

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

  FocusNode productCategoryFocus = FocusNode();
  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

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
                _selectedIndex = currentIndex + 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex - 1];
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
              _fieldFocusChange(
                  context, productCategoryFocus, _ProductNameFocus);
            });
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
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          return ProductCategoryList;
        },
        itemBuilder: (context, suggestion) {
          final index = ProductCategoryList.indexOf(suggestion);
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
        onSuggestionSelected: (suggestion) {
          setState(() {
            ProductCategoryController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(_ProductNameFocus);
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

  String? selectedValue;

  void _addItem() async {
    if (ProductNameCOntroller.text.isEmpty ||
        retailAmount.text.isEmpty ||
        WholeSalesretailAmount.text.isEmpty ||
        onlineAmount.text.isEmpty ||
        onlineAmount.text == "0.0" ||
        retailAmount.text == "0.0" ||
        WholeSalesretailAmount.text == "0.0" ||
        onlineAmount.text == "0" ||
        retailAmount.text == "0" ||
        WholeSalesretailAmount.text == "0" ||
        selectedValue!.isEmpty) {
      WarninngMessage(context);
    } else if (productNames.any((name) =>
        name.toLowerCase() == ProductNameCOntroller.text.toLowerCase())) {
      AlreadyExistWarninngMessage();
    } else if (isSwitched == 'Yes' && StockValueController.text.isEmpty) {
      WarninngMessage(context);
    } else {
      String stockValueAsString = isSwitched ? 'Yes' : 'No';
      String productName = ProductNameCOntroller.text;
      String retailAmt = retailAmount.text;
      String WholeSalesretailAmt = WholeSalesretailAmount.text;
      String OnlineAmount = onlineAmount.text;
      String stockValue = StockValueController.text;
      if (StatusController.text != 'Combo') {
        StatusController.text = 'Normal';
      }
      String category = ProductCategoryController.text;
      String statuss = StatusController.text;

      String cgstperc = selectedCgstPercentage.toString();
      String sgstperc = selectedCgstPercentage.toString();
      print('cgstperc:$cgstperc,sgst:$sgstperc');
      String? cusid = await SharedPrefs.getCusId();

      String base64Image = '';

      if (_image != null) {
        try {
          Uint8List imageBytes = await _image!.readAsBytes();
          base64Image = base64Encode(imageBytes);
        } catch (e) {
          print('Error encoding image: $e');
          return;
        }
      }

      String finalBase64Image = base64Image.isEmpty
          ? "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"
          : base64Image;

      finalBase64Image = finalBase64Image.padRight(
          (finalBase64Image.length + 3) ~/ 4 * 4, '=');

      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "name": productName,
        "amount": retailAmt,
        "wholeamount": WholeSalesretailAmt,
        "stock": stockValueAsString,
        "stockvalue": stockValue,
        "cgstper": cgstperc,
        "cgstvalue": "0.0",
        "sgstper": sgstperc,
        "sgstvalue": "0.0",
        "finalamount": retailAmt,
        "code": PurchaseProductCode,
        "category": category,
        "OnlineAmt": OnlineAmount,
        "OnlineFinalAmt": OnlineAmount,
        "makingcost": '0',
        "status": statuss,
        'image': finalBase64Image,
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(postData);

      // Make POST request to the API
      String apiUrl = '$IpAddress/SettingsProductDetailsalldatas/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 201) {
        successfullySavedMessage(context);
        finalBase64Image = "";
        print('Data posted successfully');
        postDataWithIncrementedSerialNo();
        fetchPurchaseProductCodeo();
        fetchProductDetails();
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        postDataWithIncrementedSerialNo();
        fetchProductDetails();
      }
      await logreports("Product Details: ${productName}_${statuss}_Inserted");
      clearFields();
    }
  }

  void checkNameExists() async {
    bool codeExists = productNames.any((code) =>
        code.toLowerCase() == ProductNameCOntroller.text.toLowerCase());

    if (codeExists) {
      AlreadyExistWarninngMessage();
      ProductNameCOntroller.text = "";
      FocusScope.of(context).requestFocus(_ProductNameFocus);

      print('Staff code already exists');
    } else {
      print('Staff code is unique');
    }
  }

  void UpdateItems(String Productid) async {
    String stockValueAsString = isSwitched ? 'Yes' : 'No';
    String productName = ProductNameCOntroller.text;
    String retailAmt = retailAmount.text;
    String WholeSalesretailAmt = WholeSalesretailAmount.text;
    String OnlineAmount = onlineAmount.text;
    String stockValue = StockValueController.text;
    String category = ProductCategoryController.text;
    String cgstperc = selectedCgstPercentage.toString();
    String sgstperc = selectedCgstPercentage.toString();

    Uint8List imageBytes = await _image!.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    if (StatusController.text != 'Combo') {
      StatusController.text = 'Normal';
    }
    String statuss = StatusController.text;

    // print("Cate cgstperc: ${cgstperc}");

    String? cusid = await SharedPrefs.getCusId();

    Map<String, dynamic> putdata = {
      "cusid": "$cusid",
      "name": productName,
      "amount": retailAmt,
      "wholeamount": WholeSalesretailAmt,
      "stock": stockValueAsString,
      "stockvalue": stockValue,
      "cgstper": cgstperc,
      "cgstvalue": "0.0",
      "sgstper": sgstperc,
      "sgstvalue": "0.0",
      "finalamount": retailAmt,
      "code": PurchaseProductCode,
      "category": category,
      "OnlineAmt": OnlineAmount,
      "OnlineFinalAmt": OnlineAmount,
      "image": base64Image,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putdata);

    // Make PUT request to the API
    String apiUrl = '$IpAddress/SettingsProductDetailsalldatas/$Productid/';
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
      fetchProductDetails();
    } else {
      // Data updating failed
      print(
          'Failed to category update data: ${response.statusCode}, ${response.body}');
      fetchProductDetails();
    }
    await logreports("Product Details: ${productName}_${statuss}_Updated");
  }

  void clearFields() {
    ProductCategoryController.text = "";
    ProductNameCOntroller.text = "";
    retailAmount.text = "0.0";
    WholeSalesretailAmount.text = "0.0";
    onlineAmount.text = "0.0";
    StockValueController.text = "0";
    selectedValue = "";
    ComboNameCOntroller.text = "";
    setState(() {
      _selectedOption = 'Normal';
      _isImageUploaded = false;
      isSwitched = false;
      isUpdateMode = false;
      _CombotableData.clear();
      isSelectedcgst = [true, false, false, false, false];
      isSelectedsgst = [true, false, false, false, false];
    });
  }

  void deletedata(String Productid) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/SettingsProductDetailsalldatas/$Productid/';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    String productName = ProductNameCOntroller.text;
    if (StatusController.text != 'Combo') {
      StatusController.text = 'Normal';
    }
    String statuss = StatusController.text;

    if (response.statusCode == response.statusCode) {
      print('Data deleted successfully');
      successfullyDeleteMessage(context);

      fetchProductDetails();
    } else {
      // Data updating failed
      print('Failed to delete data: ${response.statusCode}, ${response.body}');
      fetchProductDetails();
    }
    await logreports("Product Details: ${productName}_${statuss}_Updated");
    clearFields();
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    String? cusid = await SharedPrefs.getCusId();
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "sno": PurchaseProductCode,
    };
    print('Serial No : $PurchaseProductCode');

    String jsonData = jsonEncode(postData);

    try {
      var response = await http.post(
        Uri.parse('$IpAddress/SettingsProductDetailsSNoalldatas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data. Error code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
    }
  }

  Widget SaveButton() {
    return ElevatedButton(
      onPressed: () {
        _addItem();
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
      onPressed: () {
        print("Product Code : $Productid");
        UpdateItems(Productid!);
        ProductNameCOntroller.clear();
        retailAmount.clear();
        WholeSalesretailAmount.clear();
        onlineAmount.clear();
        StockValueController.text = '0';
        selectedValue = '';
        selectedCgstPercentage = 0;
        selectedSgstPercentage = 0;
        setState(() {
          _isImageUploaded = true;
          _selectedOption = 'Normal';
          isSwitched = false;
          isUpdateMode = false;
          _CombotableData.clear();
        });
        successfullyUpdateMessage(context);
        clearFields();
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

  Widget _DeleteItem() {
    return ElevatedButton(
      onPressed: () {
        _showDeleteConfirmationDialog(Productid);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        backgroundColor: subcolor,
        minimumSize: Size(45.0, 31.0), // Set width and height
      ),
      child: Text('Delete', style: commonWhiteStyle),
    );
  }

  Widget _RefreshItem() {
    return ElevatedButton(
      onPressed: () {
        ProductCategoryController.text = "";
        ProductNameCOntroller.text = "";
        retailAmount.text = "0.0";
        WholeSalesretailAmount.text = "0.0";
        onlineAmount.text = "0.0";
        StockValueController.text = '0';
        selectedValue = '';
        selectedCgstPercentage = 0;
        selectedSgstPercentage = 0;
        setState(() {
          ImageUpdateMode = false;
          _isImageUploaded = false;
          _selectedOption = 'Normal';
          isSwitched = false;
          isUpdateMode = false;
          _CombotableData.clear();
        });
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        backgroundColor: subcolor,
        minimumSize: Size(45.0, 31.0), // Set width and height
      ),
      child: Text(
        'Refresh',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget Search() {
    return TextField(
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
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(1),
        ),
        contentPadding: EdgeInsets.only(left: 10.0, right: 4.0),
      ),
      style: TextStyle(fontSize: 13),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(Productid) async {
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
              onPressed: () {
                deletedata(Productid!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void AlreadyExistWarninngMessage() {
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
                    'Product name already exists..!!',
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

// For Combo

  FocusNode _ComboNameFocus = FocusNode();
  FocusNode ComboProdNameFocus = FocusNode();
  FocusNode ComboQtyFocus = FocusNode();
  FocusNode ComboAddFocus = FocusNode();

  TextEditingController ComboNameCOntroller = TextEditingController();
  TextEditingController ComboProdNameController = TextEditingController();
  TextEditingController ComboQtyCOntroller = TextEditingController();

  final List<Map<String, String>> _CombotableData = [];
  int _currentId = 1;

  void _AddComboTabledata() {
    setState(() {
      if (ComboNameCOntroller.text == "" ||
          ComboProdNameController.text == "" ||
          ComboQtyCOntroller.text == "0" ||
          ComboQtyCOntroller.text == "") {
        WarninngMessage(context);
        return;
      }
      _CombotableData.add({
        'id': _currentId.toString(),
        'prodname': ComboProdNameController.text,
        'qty': ComboQtyCOntroller.text,
      });
      _currentId++;
      ComboProdNameController.text = "";
      ComboQtyCOntroller.text = "0";
      FocusScope.of(context).requestFocus(ComboProdNameFocus);
    });
  }

  void _deleteComboTableData(int index) {
    setState(() {
      if (index >= 0 && index < _CombotableData.length) {
        _CombotableData.removeAt(index);
      }
    });
  }

  bool isMovingButtonVisible = true;
  bool isUpdateButtonVisible = false;
  bool isEditIconVisible = false;

  Widget ComboView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 20),
              Text('Add New Combo', style: HeadingStyle),
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      children: <Widget>[
                        CombotopWidget(),
                        SizedBox(height: 10),
                        Container(
                          height: 250,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: TableHeaderColor,
                                          child: Center(
                                            child: Text(
                                              "ProdName",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: TableHeaderColor,
                                          child: Center(
                                            child: Text(
                                              "Qty",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: TableHeaderColor,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 15,
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
                                if (_CombotableData.isNotEmpty)
                                  ..._CombotableData.map((data) {
                                    var id = data['id'].toString();
                                    var prodname = data['prodname'].toString();
                                    var qty = data['qty'].toString();

                                    int index = _CombotableData.indexOf(data);

                                    bool isEvenRow =
                                        _CombotableData.indexOf(data) % 2 == 0;
                                    Color? rowColor = isEvenRow
                                        ? Color.fromARGB(224, 255, 255, 255)
                                        : Color.fromARGB(224, 255, 255, 255);

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 0.0,
                                        right: 0.0,
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
                                                  prodname,
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
                                                  qty,
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (isEditIconVisible)
                                                      Flexible(
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.edit_square,
                                                            size: 18,
                                                            color: Colors.blue,
                                                          ),
                                                          onPressed: () {
                                                            ComboProdNameController
                                                                    .text =
                                                                data[
                                                                    'prodname']!;
                                                            ComboQtyCOntroller
                                                                    .text =
                                                                data['qty']!;
                                                          },
                                                        ),
                                                      ),
                                                    Flexible(
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          size: 18,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          if (isEditIconVisible ==
                                                              true) {
                                                            String? ProdId =
                                                                data['id']
                                                                    .toString();
                                                            _showDeleteComboConfirmationDialog(
                                                                ProdId);
                                                          } else {
                                                            _deleteComboTableData(
                                                                index);
                                                          }
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
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60.0),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/imgs/Combo.png',
                                          width: 50,
                                          height: 50,
                                        ),
                                        SizedBox(height: 10),
                                        Center(
                                          child: Text(
                                            '+ Add Combo',
                                            style: DropdownTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isUpdateButtonVisible)
                                ElevatedButton(
                                  onPressed: () {
                                    updateOrInsertRows(_CombotableData);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    backgroundColor:
                                        Color.fromRGBO(139, 27, 55, 1),
                                    minimumSize: Size(45.0, 31.0),
                                  ),
                                  child:
                                      Text('Update', style: commonWhiteStyle),
                                ),
                              SizedBox(width: 5),
                              if (isMovingButtonVisible)
                                ElevatedButton(
                                  onPressed: () {
                                    _MoveTableComboDetails();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    backgroundColor:
                                        Color.fromRGBO(139, 27, 55, 1),
                                    minimumSize: Size(45.0, 31.0),
                                  ),
                                  child: Text('Move', style: commonWhiteStyle),
                                ),
                            ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget CombotopWidget() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Combo Name',
                    style: commonLabelTextStyle,
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 24,
                    width: 130,
                    child: TextField(
                      onSubmitted: (value) {
                        _fieldFocusChange(
                            context, _ComboNameFocus, ComboProdNameFocus);
                      },
                      controller: ComboNameCOntroller,
                      focusNode: _ComboNameFocus,
                      readOnly: (_selectedOption == 'Combo' && isUpdateMode),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade500, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 7.0,
                        ),
                      ),
                      style: textStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'ProdCode : $code',
                  style: commonLabelTextStyle,
                ),
              ),
              SizedBox(width: 10),
              _buildProductNameDropdownForCombo('Product Name'),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qty',
                    style: commonLabelTextStyle,
                  ),
                  SizedBox(height: 6),
                  Container(
                    height: 24,
                    width: 100,
                    child: TextField(
                      onSubmitted: (value) {
                        _fieldFocusChange(
                            context, ComboQtyFocus, ComboAddFocus);
                      },
                      controller: ComboQtyCOntroller,
                      focusNode: ComboQtyFocus,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade500, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 7.0,
                        ),
                      ),
                      style: textStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: ElevatedButton(
                  focusNode: ComboAddFocus,
                  onPressed: () {
                    // For Table Updtate
                    if (isEditIconVisible == true) {
                      Map<String, dynamic> newData = {
                        'prodname': ComboProdNameController.text,
                        'qty': ComboQtyCOntroller.text,
                      };

                      updateOrAddRow(newData);

                      setState(() {});
                    } else {
                      _AddComboTabledata();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: Color.fromRGBO(139, 27, 55, 1),
                    minimumSize: Size(45.0, 31.0),
                  ),
                  child: Text(
                    'Add',
                    style: commonWhiteStyle,
                  ),
                ),
              ),
            ],
          ),
        if (Responsive.isMobile(context))
          Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Combo Name',
                        style: commonLabelTextStyle,
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 24,
                        width: 130,
                        child: TextField(
                          onSubmitted: (value) {
                            _fieldFocusChange(
                                context, _ComboNameFocus, ComboProdNameFocus);
                          },
                          controller: ComboNameCOntroller,
                          focusNode: _ComboNameFocus,
                          readOnly:
                              (_selectedOption == 'Combo' && isUpdateMode),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'ProdCode : $code',
                      style: commonLabelTextStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  _buildProductNameDropdownForCombo('Product Name'),
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qty',
                        style: commonLabelTextStyle,
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 24,
                        width: 100,
                        child: TextField(
                          onSubmitted: (value) {
                            _fieldFocusChange(
                                context, ComboQtyFocus, ComboAddFocus);
                          },
                          controller: ComboQtyCOntroller,
                          focusNode: ComboQtyFocus,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 7.0,
                            ),
                          ),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: ElevatedButton(
                      focusNode: ComboAddFocus,
                      onPressed: () {
                        // For Table Updtate
                        if (isEditIconVisible == true) {
                          Map<String, dynamic> newData = {
                            'prodname': ComboProdNameController.text,
                            'qty': ComboQtyCOntroller.text,
                          };

                          updateOrAddRow(newData);

                          setState(() {});
                        } else {
                          _AddComboTabledata();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        backgroundColor: Color.fromRGBO(139, 27, 55, 1),
                        minimumSize: Size(45.0, 31.0),
                      ),
                      child: Text(
                        'Add',
                        style: commonWhiteStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  void updateOrAddRow(Map<String, dynamic> newData) {
    String newProdName = newData['prodname'].toString();
    int newQty = int.tryParse(newData['qty'].toString()) ??
        0; // Ensure newQty is an integer
    String id = newData.containsKey('id') ? newData['id'].toString() : '';

    // Check if any input is empty or invalid
    if (ComboQtyCOntroller.text == "0" ||
        ComboQtyCOntroller.text.isEmpty ||
        ComboNameCOntroller.text.isEmpty ||
        ComboProdNameController.text.isEmpty) {
      WarninngMessage(context);
      return;
    }

    bool productExists = false;

    // Check if the product already exists in _CombotableData
    for (var row in _CombotableData) {
      if (row['prodname'] == newProdName) {
        int existingQty = int.tryParse(row['qty'].toString()) ??
            0; // Ensure existingQty is an integer
        row['qty'] =
            (existingQty + newQty).toString(); // Increment the quantity
        productExists = true;
        break;
      }
    }

    // If the product does not exist, add it to the list
    if (!productExists) {
      _CombotableData.add({
        'id': id,
        'prodname': newProdName,
        'qty': newQty.toString(),
      });
    }

    // Reset the input fields
    ComboProdNameController.text = "";
    ComboQtyCOntroller.text = "0";
    code = "";
  }

  Widget _buildProductNameDropdownForCombo(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: commonLabelTextStyle,
          ),
          Container(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Container(
                    height: 23,
                    width: 150,
                    child: ProductNamedropdownForCombo()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> ProductNameList = [];

  Future<void> fetchAllProductNameForCombo() async {
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
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  int? _selectedProdIndex;
  String? selectedProductName;
  bool _ProdNamefilterEnabled = true;
  int? _ProdNamehoveredIndex;

  // ProductName Combo

  Widget ProductNamedropdownForCombo() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(ComboProdNameController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProdIndex = currentIndex + 1;
                ComboProdNameController.text =
                    ProductNameList[currentIndex + 1];
                _ProdNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(ComboProdNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProdIndex = currentIndex - 1;
                ComboProdNameController.text =
                    ProductNameList[currentIndex - 1];
                _ProdNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedProductName = suggestion;
              ComboProdNameController.text = suggestion!;
              _ProdNamefilterEnabled = false;
              _fieldFocusChange(context, ComboProdNameFocus, ComboQtyFocus);
            });

            try {
              await fetchCodeByProdNameForCombo();

              FocusScope.of(context).requestFocus(ComboQtyFocus);
            } catch (e) {
              print('Error in onSuggestionSelected: $e');
            }
          },
          controller: ComboProdNameController,
          focusNode: ComboProdNameFocus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: TextStyle(fontSize: 11),
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
                                  ComboProdNameController.text) ==
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
            ComboProdNameController.text = suggestion!;
            _ProdNamefilterEnabled = false;
          });

          try {
            await fetchCodeByProdNameForCombo();

            FocusScope.of(context).requestFocus(ComboQtyFocus);
          } catch (e) {
            print('Error in onSuggestionSelected: $e');
          }
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

  String? code = "";

  // Fetch Code By ProductName

  TextEditingController ComboStatusController = TextEditingController();
  Future<String?> fetchCodeByProdNameForCombo() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';

    int page = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        String url = '$apiUrl?page=$page';

        http.Response response = await http.get(Uri.parse(url));
        var jsonData = json.decode(response.body);

        if (jsonData['results'] != null) {
          List<dynamic> results = jsonData['results'];

          for (var entry in results) {
            if (entry['name'] == ComboProdNameController.text) {
              double Code = double.parse(entry['code'].toString());
              code = Code.toString();
            }
          }
          page++;
          hasMorePages = jsonData['next'] != null;
        } else {
          hasMorePages = false;
        }
      }
      // print("Code of ${_ProductNameController.text} products: $totalAmount");
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  // For Delete

  void Combodeletedata(String ProdId) async {
    String comboName = ComboNameCOntroller.text;

    String apiUrl = '$IpAddress/SettingsComboalldatas/$ProdId/';
    print("url:$apiUrl");

    try {
      http.Response response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == response.statusCode) {
        _fetchComboDetails(comboName);
        print('Data Deleted successfully');
        successfullyDeleteMessage(context);
      } else {
        print(
            'Failed to Delete data: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error deleting data: $e');
      // Handle any exceptions that occur during the HTTP request
    }
  }

  // Update to the API-table

  // Save to Combo_setting Table

  void _MoveTableComboDetails() async {
    String apiUrl = '$IpAddress/SettingsComboalldatas/';

    if (_CombotableData.isEmpty || ComboNameCOntroller.text == "") {
      WarninngMessage(context);
      return;
    }

    try {
      for (var rowData in _CombotableData) {
        String? prodname = rowData['prodname'];
        int qty = int.parse(rowData['qty'].toString());

        String? cusid = await SharedPrefs.getCusId();
        Map<String, dynamic> requestData = {
          "cusid": "$cusid",
          'name': ComboNameCOntroller.text,
          'item': prodname,
          'qty': qty,
        };

        http.Response response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 201) {
          // print('Processed Data: $requestData');
          print('Failed to save data. Status code: ${response.statusCode}');
          // print('Response body: ${response.body}');
        }
      }

      if (mounted) {
        setState(() {
          _selectedOption = 'Normal';
          ComboStatusController.text = "Combo";
          StatusController.text = ComboStatusController.text;

          // Debugging prints to ensure values are set correctly
          print('ComboStatusController.text: ${ComboStatusController.text}');
          print('StatusController.text: ${StatusController.text}');
        });
        ProductNameCOntroller.text = ComboNameCOntroller.text;
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool?> _showDeleteComboConfirmationDialog(String ProdId) async {
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
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
              onPressed: () {
                Combodeletedata(ProdId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Delete',
                  style: TextStyle(color: sidebartext, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateOrInsertRows(
      List<Map<String, dynamic>> _CombotableData) async {
    try {
      for (var data in _CombotableData) {
        if (data['id'] == null ||
            data['prodname'] == null ||
            data['qty'] == null) {
          continue; // Skip incomplete data
        }

        final String id = data['id'].toString();
        final String prodname = data['prodname'];
        final double qtyDouble = double.tryParse(data['qty'].toString()) ?? 0.0;
        final int qty = qtyDouble.round();

        String? cusid = await SharedPrefs.getCusId();
        final Map<String, dynamic> rowData = {
          'id': id,
          'cusid': cusid,
          'name': ComboNameCOntroller.text,
          'item': prodname,
          'qty': qty,
        };

        print("Processing ID: $id with qty: $qty");

        if (id.isEmpty) {
          // ID is empty, perform an insert
          final insertResponse = await http.post(
            Uri.parse('$IpAddress/SettingsComboalldatas/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(rowData),
          );

          if (isValidJson(insertResponse.body)) {
            final responseBody = jsonDecode(insertResponse.body);
            if (responseBody['id'] != null) {
              print('Data for new entry inserted successfully');
            } else {
              print('Failed to insert data for new entry: $responseBody');
            }
          } else {
            print('Failed to insert data for new entry: Invalid JSON response');
          }
        } else {
          // ID is not empty, perform an update
          final updateResponse = await http.put(
            Uri.parse('$IpAddress/SettingsComboalldatas/$id/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(rowData),
          );
        }
      }

      setState(() {
        successfullyUpdateMessage(context);
        _selectedOption = "Normal";
      });
    } catch (e) {
      print('Error processing data: $e');
    }
  }

  bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
