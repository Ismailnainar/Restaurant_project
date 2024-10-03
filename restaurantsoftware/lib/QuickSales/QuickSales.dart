import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:scrollable/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickSalesMainPage extends StatefulWidget {
  @override
  _QuickSalesMainPageState createState() => _QuickSalesMainPageState();
}

class Product {
  final String name;
  final String price;
  final String imagePath;
  final double cgstPercentage;
  final double sgstPercentage;
  final String category;
  final String stock;
  final double stockValue;
  int quantity;
  bool isFavorite;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.cgstPercentage,
    required this.sgstPercentage,
    required this.category,
    required this.stock,
    required this.stockValue,
    this.quantity = 0,
    this.isFavorite = false,
  });

  double totalPrice = 0.0;
}

class _QuickSalesMainPageState extends State<QuickSalesMainPage> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool isLoading = false;
  String errorMessage = '';
  Product? selectedProduct;
  List<String> categories = ['All', 'Favorites'];
  String selectedCategory = 'All';
  List<Product> selectedProducts = [];
  List<dynamic> allCategories = [];
  List<dynamic> mainCategories = [];
  String selectedProductName = '';
  String selectedProductPrice = '';
  String formattedTotalAmount = '';
  double? selectedProductCGST;
  double? selectedProductSGST;
  int totalItems = 0;
  double totalAmount = 0.0;
  double discountAmount = 0.0;
  double cgstPercentage = 0.0;
  double sgstPercentage = 0.0;
  double finalTaxable = 0.0;
  double cgst = 0.0;
  double sgst = 0.0;
  double finAmt = 0.0;
  double finalAmount = 0.0;
  int quantity = 0; // Initialize the quantity
  double totalPrice = 0.0; // Initialize the totalPrice
  String selectedPaymentType = 'Cash';
  TextEditingController gstMethodController = TextEditingController();
  List<String> paymentTypes = [];
  String orderType = 'DineIn';
  List<String> servantNames = [];
  String selectedServantName = 'Choose';
  bool _isHovered = false;
  String? gstType; // Initialize as nullable
  late var _pageController = PageController();
  String? serialNo;
  String cusid = '';
  Timer? _timer;
  double stockValue = 0.0;
  String stock = '';
  late ScrollController _scrollController;
  bool _showFloatingButton = true;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 3);

    _loadFavoriteProducts();
    _saveFavoriteProducts;
    discountPercentageController.text = '0';
    discountAmountController.text = '0';
    fetchProducts();
    fetchCategories(); // Fetch categories from API
    fetchGstMethod();
    fetchServantNames();
    cusNameController = TextEditingController();
    contactController = TextEditingController();
    addressController = TextEditingController();
    gstMethodController = TextEditingController();
    tableNumberController = TextEditingController();
    scodeController = TextEditingController();
    fetchSerialNumber();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchSerialNumber(); // Fetch serial number every 10 sec
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent * 0.1) {
        setState(() {
          _showFloatingButton = false;
        });
      } else {
        setState(() {
          _showFloatingButton = true;
        });
      }
    });
  }

  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    fitchfinalAmountController.dispose();
    discountAmountController.dispose();
    discountPercentageController.dispose();
    finalAmountController.dispose();
    _nameFocusNode.dispose();
    _contactFocusNode.dispose();
    _addressFocusNode.dispose();
    _tableNoFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> fetchPaymentTypes() async {
    String? cusid = await SharedPrefs.getCusId();
    // String baseUrl = '$IpAddress/SalesCustomer/$cusid/';
    final url = Uri.parse('$IpAddress/PaymentMethod/$cusid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final paymentTypeNames = <String>[];
      for (final item in data) {
        final name = item['paytype'] as String;
        paymentTypeNames.add(name);
      }
      setState(() {
        paymentTypes = paymentTypeNames;
        if (paymentTypes.isNotEmpty) {
          selectedPaymentType = paymentTypes.first;
        }
      });
    } else {
      throw Exception('Failed to fetch payment types');
    }
  }

  Future<void> fetchGstMethod() async {
    String? cusid = await SharedPrefs.getCusId();

    final url = Uri.parse('$IpAddress/GstDetails/$cusid/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      for (final item in data) {
        if (item['name'] == 'Sales') {
          setState(() {
            gstType = item['gst'];
            gstMethodController.text =
                gstType!; // Set gstMethodController.text equal to gstType
          });

          break;
        }
      }
    } else {
      throw Exception('Failed to fetch GST method');
    }
  }

  Future<void> fetchAndShowPaymentTypesDialog(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await fetchPaymentTypes();
      showPaymentTypesDialog(context);
    } catch (e) {
      print('Error fetching payment types: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPaymentTypesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select PayTypes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: paymentTypes.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: paymentTypes.map((paymentType) {
                    return ListTile(
                      title: Text(
                        paymentType,
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          selectedPaymentType = paymentType;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              )
            : Text('No payment types found'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  Future<void> fetchServantNames() async {
    try {
      final response =
          await http.get(Uri.parse('$IpAddress/StaffDetailsalldatas/'));
      //  print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('Response data: $data');
        if (data is Map && data['results'] is List) {
          setState(() {
            servantNames = (data['results'] as List)
                .map((e) => e['serventname'].toString())
                .toList();
            //  print('Servant names: $servantNames');
          });
        } else {
          print('Error: "results" key is not a list');
        }
      } else {
        print(
            'Failed to fetch servant names. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch servant names');
      }
    } catch (e) {
      print('Error fetching servant names: $e');
    }
  }

  void showServantNamesDialog(BuildContext context, List<String> servantNames,
      Function(String) onServantSelected) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Select Servant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: servantNames.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: servantNames.map((servantName) {
                      return ListTile(
                        title: Text(
                          servantName,
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          onServantSelected(servantName);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    }).toList(),
                  ),
                )
              : Text('No servants found'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        );
      },
    );
  }

  void _navigateToNextPage() {
    if (_pageController.page! < 3) {
      // Assuming you have 4 pages
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToPreviousPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Product> favoriteProducts = []; // List to store selected products
  List<String> apiCategories = []; // List to store API fetched categories

  Future<void> fetchCategories() async {
    String? cusid = await SharedPrefs.getCusId();
    // String baseUrl = '$IpAddress/SalesCustomer/$cusid/';
    try {
      final response = await http.get(
        Uri.parse('$IpAddress/Settings_ProductCategory/$cusid/'),
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        var data = jsonDecode(response.body);

        if (data is Map && data.containsKey('results')) {
          var results = data['results'];

          // Check if results is a List
          if (results is List) {
            setState(() {
              apiCategories.clear();
              apiCategories.addAll(['All', 'Favorites']);

              apiCategories
                  .addAll(results.map((item) => item['cat'].toString()));
            });
          } else {
            print('Invalid format: Expected a List in results');
            print('Received results: $results');
          }
        } else {
          print(
              'Invalid format: Expected a Map with a results key in API response');
          print('Received data: $data');
        }
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _saveFavoriteProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteProductStrings = favoriteProducts.map((product) {
      return jsonEncode({
        'name': product.name,
        'price': product.price,
        'imagePath': product.imagePath,
        'quantity': product.quantity,
        'cgstPercentage': product.cgstPercentage,
        'sgstPercentage': product.sgstPercentage,
        'category': product.category,
      });
    }).toList();
    await prefs.setStringList('favoriteProducts', favoriteProductStrings);
  }

  Future<void> _loadFavoriteProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteProductStrings =
        prefs.getStringList('favoriteProducts');

    if (favoriteProductStrings != null) {
      favoriteProducts = favoriteProductStrings.map((productString) {
        Map<String, dynamic> productMap = jsonDecode(productString);

        return Product(
          name: productMap['name'],
          price: productMap['price'],
          imagePath: productMap['imagePath'],
          quantity: productMap['quantity'],
          cgstPercentage: productMap['cgstPercentage'],
          sgstPercentage: productMap['sgstPercentage'],
          category: productMap['category'],
          stock: productMap['stock'],
          stockValue: productMap['stockValue'],

          // makingCost: productMap['makingCost'],

          isFavorite:
              true, // Set the isFavorite flag to true for loaded products
        );
      }).toList();
    }
  }

  Future<void> fetchProducts() async {
    String? cusid = await SharedPrefs.getCusId();

    setState(() {
      isLoading = true;
    });

    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Assuming 'results' is the key containing product data
        List<dynamic> results = data['results'];

        List<Product> fetchedProducts = results.map((item) {
          // Handling potential null value in 'image'
          String? imagePath =
              item['image'] != null ? item['image'].toString() : '';

          return Product(
            name: item['name'].toString(),
            price: item['amount'].toString(),
            imagePath: imagePath ?? '',
            cgstPercentage: double.parse(item['cgstper'].toString()),
            sgstPercentage: double.parse(item['sgstper'].toString()),
            category: item['category'].toString(),
            stock:
                item['stock'].toString(), // Assuming 'stock' is a string in API
            stockValue: double.parse(item['stockvalue']
                .toString()), // Assuming 'stockvalue' is a number in API
          );
        }).toList();

        setState(() {
          allProducts = fetchedProducts;
          filteredProducts = fetchedProducts;
          isLoading = false;

          // Extract unique categories from the fetched products
          categories
              .addAll(fetchedProducts.map((p) => p.category).toSet().toList());
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${response.reasonPhrase}';
        });

        // Print error message
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });

      // Print error message
      print(errorMessage);
    }
  }

  void filterProductsByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredProducts = allProducts;
      } else if (category == 'Favorites') {
        filteredProducts = favoriteProducts;
      } else {
        filteredProducts =
            allProducts.where((p) => p.category == category).toList();
      }
    });
  }

  // Define icons for categories
  List<IconData> categoryIcons = [
    Icons.restaurant_menu, // Icon for 'All' category
    Icons.favorite, // Icon for 'Favorites' category
    Icons.rice_bowl,
    Icons.food_bank,
    Icons.fastfood,
    Icons.apple,
    Icons.local_drink,
  ];

  // Method to get the icon for a given category index
  IconData getCategoryIcon(int index) {
    if (index < categoryIcons.length) {
      return categoryIcons[index];
    } else {
      // Repeat the icons for categories beyond the first set
      return categoryIcons[2 + (index - 2) % (categoryIcons.length - 2)];
    }
  }

  TextEditingController taxAmountController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController finalTaxableAmountController = TextEditingController();
  TextEditingController fitchfinalTaxableAmountController =
      TextEditingController();
  TextEditingController cgstAmountController = TextEditingController();
  TextEditingController fitchcgstAmountController = TextEditingController();
  TextEditingController sgstAmountController = TextEditingController();
  TextEditingController fitchsgstAmountController = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  TextEditingController fitchfinalAmountController = TextEditingController();
  TextEditingController cgstAmount0Controller = TextEditingController();
  TextEditingController cgstAmount2_5Controller = TextEditingController();
  TextEditingController cgstAmount6Controller = TextEditingController();
  TextEditingController cgstAmount9Controller = TextEditingController();
  TextEditingController cgstAmount14Controller = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _contactFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _tableNoFocusNode = FocusNode();
  final FocusNode _sCodeFocusNode = FocusNode();
  final FocusNode _disAmtFocusNode = FocusNode();
  final FocusNode _disPercFocusNode = FocusNode();
  final FocusNode _saveDetailsFocusNode = FocusNode();

  TextEditingController cusNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController tableNumberController = TextEditingController();
  TextEditingController scodeController = TextEditingController();
  TextEditingController sNameControlelr = TextEditingController();
  // Declare the controllers
  TextEditingController cgst0AmountController = TextEditingController();
  TextEditingController cgst25AmountController = TextEditingController();
  TextEditingController cgst6AmountController = TextEditingController();
  TextEditingController cgst9AmountController = TextEditingController();
  TextEditingController cgst14AmountController = TextEditingController();
  TextEditingController sgst0AmountController = TextEditingController();
  TextEditingController sgst25AmountController = TextEditingController();
  TextEditingController sgst6AmountController = TextEditingController();
  TextEditingController sgst9AmountController = TextEditingController();
  TextEditingController sgst14AmountController = TextEditingController();

  TextEditingController itemsController = TextEditingController();
  Future<double> fetchMakingCost(String productName) async {
    String? cusid = await SharedPrefs.getCusId();

    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);

        if (responseBody is List<dynamic>) {
          for (var product in responseBody) {
            if (product['name'] == productName) {
              return double.tryParse(product['makingcost'].toString()) ?? 0.0;
            }
          }
        } else {
          //     print('Response is not a list: $responseBody');
        }
      } else {
        print('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return 0.0;
  }

  void updateControllersBasedOnSelectedProducts() {
    itemsController.text = selectedProducts.length.toString();
    double totalAmount = 0.0;
    double taxableAmount = 0.0;
    double totalCgstAmount = 0.0;
    double totalSgstAmount = 0.0;

    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
      totalAmount += productPrice;
      taxableAmount +=
          productPrice; // Adjust this as needed for taxable calculations

      // Calculate CGST and SGST based on percentage
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      double cgstAmount = 0.0;
      double sgstAmount = 0.0;

      // Calculate CGST and SGST amounts based on percentages
      if (productCGST > 0) {
        cgstAmount = productPrice * productCGST / 100;
      }
      if (productSGST > 0) {
        sgstAmount = productPrice * productSGST / 100;
      }

      totalCgstAmount += cgstAmount;
      totalSgstAmount += sgstAmount;
    }

    // Update the controllers with the calculated amounts
    finalAmountController.text = totalAmount.toStringAsFixed(2);
    taxAmountController.text = taxableAmount.toStringAsFixed(2);
    finalTaxableAmountController.text = taxableAmount.toStringAsFixed(2);
    cgstAmountController.text = totalCgstAmount.toStringAsFixed(2);
    sgstAmountController.text = totalSgstAmount.toStringAsFixed(2);
  }

  Future<void> saveDetails(BuildContext context, String paidAmount) async {
    final url = Uri.parse('$IpAddress/SalesRoundDetailsalldatas/');
    final now = DateTime.now();
    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final formattedDateTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    double totalAmount = 0.0;
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;
    String salesDetails = '';

    // Ensure default values for discount fields
    if (discountPercentageController.text.isEmpty) {
      discountPercentageController.text = '0';
    }
    if (discountAmountController.text.isEmpty) {
      discountAmountController.text = '0';
    }

    updateControllersBasedOnSelectedProducts();

    try {
      // Calculate total amount and CGST amounts
      for (Product product in selectedProducts) {
        String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
        double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
        totalAmount += productPrice;

        double productCGST = product.cgstPercentage ?? 0.0;

        double discountPercentage =
            double.tryParse(discountPercentageController.text) ?? 0.0;
        double productDiscountAmount =
            (productPrice * discountPercentage) / 100;
        double finalcgstAmount = productPrice - productDiscountAmount;
        double makingCost = await fetchMakingCost(product.name);

        if (productCGST == 0.0) {
          cgstAmount0 += (finalcgstAmount * 0.0 / 100);
        } else if (productCGST == 2.5) {
          cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
        } else if (productCGST == 6.0) {
          cgstAmount6 += (finalcgstAmount * 6.0 / 112);
        } else if (productCGST == 9.0) {
          cgstAmount9 += (finalcgstAmount * 9.0 / 118);
        } else if (productCGST == 14.0) {
          cgstAmount14 += (finalcgstAmount * 14.0 / 128);
        }
        salesDetails +=
            '{salesbillno:BTRM_1,category:${product.category},dt:$formattedDate,Itemname:${product.name},rate:${product.price},qty:${product.quantity},amount:$totalAmount,retailrate:${product.price},retail:${taxAmountController.text},cgst:${cgstAmountController.text},sgst:${sgstAmountController.text},serialno:1,sgstperc:${product.sgstPercentage},cgstperc:${product.cgstPercentage},makingcost:$makingCost,status:Normal,sno:1.0}';
      }

      salesDetails = salesDetails.replaceAll('}{', '},{');
      double finalAmount = double.tryParse(finalAmountController.text) ?? 0.0;
      String paidAmount = selectedPaymentType.toLowerCase() == 'credit'
          ? '0.0'
          : finalAmount.toStringAsFixed(2);

      double taxableAmount = double.tryParse(taxAmountController.text) ?? 0.0;
      double finalTaxable =
          double.tryParse(finalTaxableAmountController.text) ?? 0.0;

      String? cusid = await SharedPrefs.getCusId();

      final body = {
        'billno': serialNo,
        'cusid': cusid,
        'dt': formattedDate,
        'type': orderType,
        'tableno': tableNumberController.text.isEmpty
            ? 'null'
            : tableNumberController.text,
        'servent':
            selectedServantName == 'Choose' ? 'null' : selectedServantName,
        'count': itemsController.text,
        'amount': totalAmount,
        'discount': discountAmountController.text.isEmpty
            ? '0.0'
            : discountAmountController.text,
        'finalamount': finalAmountController.text.isEmpty
            ? '0.0'
            : finalAmountController.text,
        'cgst0': cgstAmount0.toStringAsFixed(2),
        'cgst25': cgstAmount2_5.toStringAsFixed(2),
        'cgst6': cgstAmount6.toStringAsFixed(2),
        'cgst9': cgstAmount9.toStringAsFixed(2),
        'cgst14': cgstAmount14.toStringAsFixed(2),
        'sgst0': cgstAmount0.toStringAsFixed(2),
        'sgst25': cgstAmount2_5.toStringAsFixed(2),
        'sgst6': cgstAmount6.toStringAsFixed(2),
        'sgst9': cgstAmount9.toStringAsFixed(2),
        'sgst14': cgstAmount14.toStringAsFixed(2),
        'totcgst': (cgstAmount0 +
                cgstAmount2_5 +
                cgstAmount6 +
                cgstAmount9 +
                cgstAmount14)
            .toStringAsFixed(2),
        'totsgst': (cgstAmount0 +
                cgstAmount2_5 +
                cgstAmount6 +
                cgstAmount9 +
                cgstAmount14)
            .toStringAsFixed(2),
        'paidamount': paidAmount,
        'scode': scodeController.text.isEmpty ? 'null' : scodeController.text,
        'sname': selectedServantName == 'Choose' ? 'null' : selectedServantName,
        'paytype': selectedPaymentType,
        'disperc': discountPercentageController.text.isEmpty
            ? '0.0'
            : discountPercentageController.text,
        'Status': 'Normal',
        'gststatus': gstMethodController.text.isEmpty
            ? 'null'
            : gstMethodController.text,
        'time': formattedDateTime,
        'customeramount': '0.0',
        'customerchange': '0.0',
        'taxstatus': gstType,
        'taxable': taxableAmount.toString(),
        'finaltaxable': finalTaxable.toString(),
        'SalesDetails': salesDetails,
      };

      // Conditionally add customer name if not empty
      if (cusNameController.text.isNotEmpty) {
        body['cusname'] = cusNameController.text;
      } else {
        body['cusname'] = 'null';
      }
      if (contactController.text.isNotEmpty) {
        body['contact'] = contactController.text;
      } else {
        body['contact'] = 'null';
      }
      if (tableNumberController.text.isNotEmpty) {
        body['tableno'] = tableNumberController.text;
      } else {
        body['tableno'] = 'null';
      }
      if (scodeController.text.isNotEmpty) {
        body['scode'] = scodeController.text;
      } else {
        body['scode'] = 'null';
      }
      if (discountAmountController.text.isNotEmpty) {
        body['discount'] = discountAmountController.text;
      } else {
        body['discount'] = '0.0';
      }
      if (discountPercentageController.text.isNotEmpty) {
        body['disperc'] = discountPercentageController.text;
      } else {
        body['disperc'] = '0.0';
      }

      final response = await http.post(url,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'});
      print('Request body: ${jsonEncode(body)}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Details saved successfully');
        // Show dialog with success message
        successfullySavedMessage(context);
      } else {
        // Request failed
        print('Failed to save details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      print('Error saving details: $e');
    }
  }

  // include discount
  void calculateDiscountAmountInclude() {
    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    // double totalPrice = double.tryParse(finalAmountController.text) ?? 0;
    double totalPrice = 0.0;

    itemsController.text = selectedProducts.length.toString();

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalPrice += productPrice;
    }

    double discountAmount = (totalPrice * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);

    // Initialize discount amounts for each CGST percentage
    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      print('Prodname: ${product.name}');
      print('ProdPrice: ${product.price}');
      print('Productgst: ${product.cgstPercentage}');
      print('Productsgst: ${product.sgstPercentage}');

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');

      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      print('prodprice : $productPrice');
      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }
      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');
    print('Total Price: $totalPrice');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount : $totalDiscountAmount');
    print('Final  0%: $discountAmount0');
    print('Final  2.5%: $discountAmount2_5');
    print('Final for 6%: $discountAmount6');
    print('Finalt for 9%: $discountAmount9');
    print('Final dr 14%: $discountAmount14');

    double totalAmount = 0.0;

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalAmount += productPrice;
    }
    // Calculate the final amount after applying the total discount
    double finalAmount = totalAmount - discountAmount;
    finalAmountController.text = finalAmount.toStringAsFixed(2);
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
      totalAmount;
    });

    // cgstAmount code

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      double finalcgstAmount = productPrice - productDiscountAmount;
      double totalPercentage = productCGST + productSGST;
      print('sadasdsadsadddd : $finalcgstAmount');
      print('tax : $totalPercentage');
      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalcgstAmount * 0.0 / 100);
      //     print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
      //     print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105) ;");

      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalcgstAmount * 6.0 / 112);
      //     print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112) ;");

      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalcgstAmount * 9.0 / 118);
      //     print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118) ;");

      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalcgstAmount * 14.0 / 128);
      //     print(" $cgstAmount14 += ($finalcgstAmount * 14 / 128) ;");

      //     break;
      // }

      if (productCGST == 0.0) {
        cgstAmount0 += (finalcgstAmount * 0.0 / 100);
        print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
        print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105);");
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalcgstAmount * 6.0 / 112);
        print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112);");
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalcgstAmount * 9.0 / 118);
        print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118);");
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalcgstAmount * 14.0 / 128);
        print(" $cgstAmount14 += ($finalcgstAmount * 14.0 / 128);");
      } else {
        print("Unsupported CGST value: $productCGST");
      }

      print('finalCGST : $finalcgstAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    print('Total CGST Amount: $totalCgstPercentAmount');

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    double finalTaxableAmount =
        finalAmount - (totalCgstPercentAmount + totalCgstPercentAmount);
    print('finalTax : $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
  }

  void calculateDiscountPercentageInclude() {
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    //double totalPrice = double.tryParse(finalAmountController.text) ?? 0;
    double totalPrice = 0.0;
    itemsController.text = selectedProducts.length.toString();

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalPrice += productPrice;
    }

// Update the final amount controller with the formatted total price
    finalAmountController.text = '₹${totalPrice.toStringAsFixed(2)}/-';

    // Calculate discount percentage using the specified formula
    double discountPercentage =
        (totalPrice != 0) ? (discountAmount * 100 / totalPrice) : 0;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);

    // Initialize discount amounts for each CGST percentage
    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      print('Product Name: ${product.name}');
      print('Product Price: ${product.price}');
      print('Product CGST Percentage: ${product.cgstPercentage}');
      print('Product SGST Percentage: ${product.sgstPercentage}');

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');

      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      print('price : $productPrice');
      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }
      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');
    print('Total Price: $totalPrice');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount Amount: $totalDiscountAmount');
    print('Final discount Amount for 0%: $discountAmount0');
    print('Final discount Amount for 2.5%: $discountAmount2_5');
    print('Final discount Amount for 6%: $discountAmount6');
    print('Final discount Amount for 9%: $discountAmount9');
    print('Final discount Amount for 14%: $discountAmount14');

    double totalAmount = 0.0;

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalAmount += productPrice;
    }
    double finalAmount = totalAmount - discountAmount;
    finalAmountController.text = finalAmount.toStringAsFixed(2);
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });

    print(' Amount: $finalAmount');

    // cgstAmount code

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      double finalcgstAmount = productPrice - productDiscountAmount;
      double totalPercentage = productCGST + productSGST;
      print('sadasdsadsadddd : $finalcgstAmount');
      print('tax : $totalPercentage');
      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalcgstAmount * 0.0 / 100);
      //     print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
      //     print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105) ;");

      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalcgstAmount * 6.0 / 112);
      //     print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112) ;");

      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalcgstAmount * 9.0 / 118);
      //     print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118) ;");

      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalcgstAmount * 14.0 / 128);
      //     print(" $cgstAmount14 += ($finalcgstAmount * 14 / 128) ;");

      //     break;
      // }
      if (productCGST == 0.0) {
        cgstAmount0 += (finalcgstAmount * 0.0 / 100);
        print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
        print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105) ;");
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalcgstAmount * 6.0 / 112);
        print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112) ;");
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalcgstAmount * 9.0 / 118);
        print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118) ;");
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalcgstAmount * 14.0 / 128);
        print(" $cgstAmount14 += ($finalcgstAmount * 14 / 128) ;");
      } else {
        print("Unknown CGST rate: $productCGST");
      }

      print('finalCGST : $finalcgstAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    print('Total CGST Amount: $totalCgstPercentAmount');

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    double finalTaxableAmount =
        finalAmount - (totalCgstPercentAmount + totalCgstPercentAmount);
    print('finalTax : $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
  }

  Map<String, dynamic> productDetails = {};

  // exclude discount
  void calculateDiscountAmountExclude() {
    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    // double totalTaxableAmount = double.tryParse(taxAmountController.text) ?? 0;

    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    // Calculate discount amount
    double discountAmount = (totalTaxableAmount * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);

    // Print values for debugging
    print('Total Taxable Amount: $totalTaxableAmount');
    print('Discount Percentage: $discountPercentage');
    print('Discount Amount: $discountAmount');
    // Initialize discount amounts for each CGST percentage

    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    // Calculate discount amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;

      print('Product Name: ${product.name}');
      print('Product Price: $productPrice');
      print('Product CGST Percentage: $productCGST');
      print('Product SGST Percentage: $productSGST');
      print('Product Taxable Amount: $productTaxableAmount');
      print('Product Discount Amount: $productDiscountAmount');

      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }

      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount Amount: $totalDiscountAmount');
    print('Final discount Amount for 0%: $discountAmount0');
    print('Final discount Amount for 2.5%: $discountAmount2_5');
    print('Final discount Amount for 6%: $discountAmount6');
    print('Final discount Amount for 9%: $discountAmount9');
    print('Final discount Amount for 14%: $discountAmount14');

    // // Calculate the final taxable amount after applying the discount
    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    print('Final Taxable Amount: $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    // Calculate CGST amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;
      double finalProductTaxableAmount =
          productTaxableAmount - productDiscountAmount;

      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      //     break;
      // }

      if (productCGST == 0.0) {
        cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      }

      print('Final CGST : $finalProductTaxableAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    // Calculate the final amount by adding total taxable amount, total CGST amount, and total SGST amount
    double finalAmount =
        totalTaxableAmount + (totalCgstPercentAmount + totalCgstPercentAmount);
    finalAmountController.text = finalAmount.toStringAsFixed(2);

    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });

//
    print('tax amount : $totalTaxableAmount');
    print('cgstAmount : $totalCgstPercentAmount');
    print('sgstAmount : $totalCgstPercentAmount');
    print('fin amount : $finalAmount');
  }

  void calculateDiscountPercentageExclude() {
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    // Calculate discount percentage using the total taxable amount
    double discountPercentage = (totalTaxableAmount != 0)
        ? (discountAmount * 100 / totalTaxableAmount)
        : 0;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);
    print('Total Taxable Amount: $totalTaxableAmount');

    // Initialize discount amounts for each CGST percentage
    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    // Calculate discount amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;

      print('Product Name: ${product.name}');
      print('Product Price: $productPrice');
      print('Product CGST Percentage: $productCGST');
      print('Product SGST Percentage: $productSGST');
      print('Product Taxable Amount: $productTaxableAmount');
      print('Product Discount Amount: $productDiscountAmount');

      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }
      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount Amount: $totalDiscountAmount');
    print('Final discount Amount for 0%: $discountAmount0');
    print('Final discount Amount for 2.5%: $discountAmount2_5');
    print('Final discount Amount for 6%: $discountAmount6');
    print('Final discount Amount for 9%: $discountAmount9');
    print('Final discount Amount for 14%: $discountAmount14');

    // Calculate the final taxable amount after applying the discount
    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    print('Final Taxable Amount: $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    // Calculate CGST amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;
      double finalProductTaxableAmount =
          productTaxableAmount - productDiscountAmount;

      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      //     break;
      // }

      if (productCGST == 0.0) {
        cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      }

      print('Final CGST : $finalProductTaxableAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    // Calculate the final amount by adding total taxable amount, total CGST amount, and total SGST amount
    double finalAmount =
        totalTaxableAmount + (totalCgstPercentAmount + totalCgstPercentAmount);
    finalAmountController.text = finalAmount.toStringAsFixed(2);
    print(' Amount: $finalAmount');

    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });
    String formattedtotAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(totalAmount);
    print('abcd : $formattedtotAmount');
    setState(() {
      totalAmount = formattedtotAmount as double;
    });
    print('tax amount : $totalTaxableAmount');
    print('cgstAmount : $totalCgstPercentAmount');
    print('sgstAmount : $totalCgstPercentAmount');
    print('fin amount : $finalAmount');
  }

  //non gst discount

  void calculateDisAmtNongst() {
    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    double discountAmount = (totalTaxableAmount * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);
    print('$totalTaxableAmount');
    print('$discountPercentage');
    print('dis amt : $discountAmount');

    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
    finalAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    print('$totalTaxableAmount');
    print('$finalTaxableAmount');
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalTaxableAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });
  }

  void calculateDisPercentNongst() {
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    // Calculate discount percentage using the total taxable amount
    double discountPercentage = (totalTaxableAmount != 0)
        ? (discountAmount * 100 / totalTaxableAmount)
        : 0;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);
    print('Total Taxable Amount: $totalTaxableAmount');

    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
    finalAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    print('$totalTaxableAmount');
    print('$finalTaxableAmount');
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalTaxableAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;
    bool isTablet = MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width <= 1200;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  bool isSaleOn = true; // Initial state of the switch

  void toggleSale(bool isSale) {
    setState(() {
      isSaleOn = isSale;
      if (!isSaleOn) {
        _fetchTableSalesData();
      }
    });
  }

  Future<void> fetchSerialNumber() async {
    String? cusid = await SharedPrefs.getCusId();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Sales_serialno/$cusid/'));
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        String serialNoString = jsonBody['serialno'];
        setState(() {
          serialNo = _incrementSerialNumber(
              serialNoString); // Update serial number with incremented value
          //   print('Fetched Serial Number: $serialNo');
        });
      } else {
        throw Exception('Failed to load serial number');
      }
    } catch (e) {
      print('Error fetching serial number: $e');
    }
  }

  String _incrementSerialNumber(String serialNoString) {
    // Split the serial number into alphabetic and numeric parts
    String alphabets = serialNoString.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    String numbers = serialNoString.replaceAll(RegExp(r'[^0-9]'), '');

    int number = int.parse(numbers);

    // Increment the number
    number += 1;

    return alphabets + number.toString();
  }

  Future<void> postSerialNumber() async {
    String? cusid = await SharedPrefs.getCusId();

    try {
      if (serialNo == null) {
        print('Missing serial number for posting');
        return;
      }

      final response = await http.post(
        Uri.parse('$IpAddress/Sales_serialnoalldatas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'cusid': cusid,
          'serialno': serialNo,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server returns a 201 CREATED or 200 OK response,
        // then the post was successful.
        print('Serial number posted successfully.');
      } else {
        // If the server did not return a 201 CREATED or 200 OK response,
        // then throw an exception.
        print('Failed to post serial number: ${response.statusCode}');
        // print('Response body: ${response.body}');
        throw Exception('Failed to post serial number');
      }
    } catch (e) {
      print('Error posting serial number: $e');
    }
  }

  Future<void> incomeDetails() async {
    int pageNumber = 1;
    bool postedSuccessfully = false;
    final now = DateTime.now();

    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    double finalAmount = double.tryParse(finalAmountController.text) ?? 0.0;

    while (!postedSuccessfully) {
      try {
        final response = await http.post(
          Uri.parse('$IpAddress/Sales_IncomeDetails/?page=$pageNumber'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "cusid": "BTRM_1",
            "dt": formattedDate,
            "description": "Sales Bill:$serialNo",
            "amount": finalAmount.toString()
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Income details posted successfully.');
          postedSuccessfully = true; // Exit the loop
        } else {
          print(
              'Failed to post income details on page $pageNumber. Status code: ${response.statusCode}');
          // print('Response body: ${response.body}');
          pageNumber++; // Try the next page
        }
      } catch (e) {
        print('Error posting income details on page $pageNumber: $e');
        pageNumber++; // Try the next page
      }
    }
  }

  Future<void> _fetchTableSalesData() async {
    String? cusid = await SharedPrefs.getCusId();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Sales_tableCount/$cusid/'));

      if (response.statusCode == 200) {
        // Parse the JSON response as a Map
        Map<String, dynamic> data = jsonDecode(response.body);

        print('Fetched data: $data'); // Debugging line to print fetched data

        // Extract the list of tables from the 'results' key
        List<dynamic> tableCounts = data['results'];

        if (tableCounts != null) {
          showTableSalesDialog(tableCounts, tableNumberController);
        } else {
          print('No table data available.');
        }
      } else {
        // Handle non-200 status codes
        print(
            'Failed to load table sales data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching table sales data: $e');
    }
  }

  void showTableSalesDialog(
      List<dynamic> tableCounts, TextEditingController controller) {
    final List<Widget> indoorCards = [];
    final List<Widget> outdoorCards = [];

    for (var table in tableCounts) {
      int count = int.parse(table['count'] as String);
      String baseCode = table['code'] as String;
      for (int i = 1; i <= count; i++) {
        String tableCode = '$baseCode$i';
        Widget card = GestureDetector(
          onTap: () {
            controller.text = tableCode;
            Navigator.of(context).pop();
          },
          child: Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.table_bar, size: 20),
                SizedBox(height: 5),
                Text(
                  tableCode,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );

        if (table['name'] == 'Indoor tables') {
          indoorCards.add(card);
        } else {
          outdoorCards.add(card);
        }
      }
    }

    showDialog(
      barrierDismissible:
          false, // Prevents closing the dialog when tapping outside
      context: context,
      builder: (BuildContext context) {
        var screenWidth = MediaQuery.of(context).size.width;
        var dialogWidth = screenWidth * 0.4;
        var isDesktop = screenWidth > 600;
        var cardsPerRow = isDesktop ? 7 : 2;

        return AlertDialog(
          title: Text('Table Sales'),
          content: Container(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Indoor Tables',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List<Widget>.generate(
                      indoorCards.length,
                      (index) => indoorCards[index],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Outdoor Tables',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List<Widget>.generate(
                      outdoorCards.length,
                      (index) => outdoorCards[index],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double itemWidth = (screenWidth - 2 * 30.0 - 3 * 16.0) / 4;

    GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swiped left
          toggleSale(false);
        } else if (details.primaryVelocity! > 0) {
          // Swiped right
          toggleSale(true);
        }
      },
    );
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  padding: EdgeInsets.all(16.0),
                  color: Colors.grey[400],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (serialNo != null)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.14,
                          height: 30,
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Center(
                            child: Text(
                              'Serial No: $serialNo', // Display fetched serial number
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (serialNo == null)
                        CircularProgressIndicator(), // Placeholder while loading
                      SizedBox(height: 16.0),

                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      // Category buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < apiCategories.length; i++)
                            GestureDetector(
                              onTap: () {
                                filterProductsByCategory(apiCategories[i]);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.14,
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 22),
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: selectedCategory == apiCategories[i]
                                      ? Colors.black.withOpacity(0.9)
                                      : null,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: selectedCategory == apiCategories[i]
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      getCategoryIcon(i),
                                      color:
                                          selectedCategory == apiCategories[i]
                                              ? Colors.white
                                              : Colors.black,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        width: 120,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            apiCategories[i],
                                            style: TextStyle(
                                              color: selectedCategory ==
                                                      apiCategories[i]
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 16,
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
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Products',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Add space between "Products" and category name
                                  Text(
                                    '($selectedCategory)', // Display selected category name
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/imgs/noprod.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      'No products found in the $selectedCategory category.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 16.0,
                                    crossAxisSpacing: 16.0,
                                    childAspectRatio: itemWidth / 320,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0, top: 5.0),
                                      child: _buildProductCard(
                                        filteredProducts[index].name,
                                        filteredProducts[index].price,
                                        filteredProducts[index].imagePath,
                                        filteredProducts[index].cgstPercentage,
                                        filteredProducts[index].sgstPercentage,
                                        filteredProducts[index].quantity,
                                        filteredProducts[index]
                                            .totalPrice
                                            .toDouble(),
                                        filteredProducts[index].isFavorite,
                                        filteredProducts[index].category,
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          // height: MediaQuery.of(context).size.height * 0.20,
                          height: MediaQuery.of(context).size.width > 1200
                              ? MediaQuery.of(context).size.height *
                                  0.20 // Desktop view
                              : MediaQuery.of(context).size.width > 600
                                  ? MediaQuery.of(context).size.height *
                                      0.25 // Tablet view
                                  : MediaQuery.of(context).size.height *
                                      0.40, // Mobile view

                          color: Color.fromRGBO(56, 37, 51, 1),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 15.0),
                                width: MediaQuery.of(context).size.width * 0.18,
                                // width: 280,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(
                                          child: Text(
                                            'Customer Details',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Name :',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                          SizedBox(width: 20),
                                          Container(
                                              width: 150,
                                              height: 30,
                                              child: TextField(
                                                controller: cusNameController,
                                                focusNode: _nameFocusNode,
                                                onEditingComplete: () {
                                                  print(
                                                      'Name: ${cusNameController.text}');
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _contactFocusNode);
                                                },
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 5.0),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey), // Border color when enabled
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .white), // Border color when focused
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.phone,
                                              color: Colors.white, size: 17),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Contact :',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                          SizedBox(width: 7),
                                          Container(
                                              width: 150,
                                              height: 30,
                                              child: TextField(
                                                focusNode: _contactFocusNode,
                                                onEditingComplete: () {
                                                  print(
                                                      'Contact: ${contactController.text}');
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _addressFocusNode);
                                                },
                                                controller: contactController,
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 5.0),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey), // Border color when enabled
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .white), // Border color when focused
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Address :',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                          SizedBox(width: 6),
                                          Container(
                                              width: 150,
                                              height: 30,
                                              child: TextField(
                                                focusNode: _addressFocusNode,
                                                onEditingComplete: () {
                                                  print(
                                                      'Address: ${addressController.text}');
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _tableNoFocusNode);
                                                },
                                                controller: addressController,
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 5.0),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey), // Border color when enabled
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .white), // Border color when focused
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 5),
                              VerticalDivider(
                                color: Colors.white,
                                thickness: 1,
                                width: 1,
                              ),
                              SizedBox(width: 10),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Type Details',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_long,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'GST Method :',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 120,
                                            height: 30,
                                            child: TextField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                              controller: gstMethodController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 5.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              readOnly: true,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.currency_rupee_sharp,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Pay Type :',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                fetchAndShowPaymentTypesDialog(
                                                    context);
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.payment,
                                                      color: Colors.black,
                                                      size: 15,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      selectedPaymentType,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 30),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Transform.scale(
                                                  scale:
                                                      0.8, // Adjust this value to scale the size of the radio button
                                                  child: Radio<String>(
                                                    value: 'DineIn',
                                                    groupValue: orderType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        orderType =
                                                            value.toString();
                                                      });
                                                    },
                                                    activeColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color>((Set<
                                                                    MaterialState>
                                                                states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .selected)) {
                                                        return Colors
                                                            .white; // Color when selected
                                                      }
                                                      return Colors
                                                          .white; // Color when not selected
                                                    }),
                                                  ),
                                                ),
                                                Text(
                                                  'DineIn',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 40,
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale:
                                                      0.8, // Adjust this value to scale the size of the radio button
                                                  child: Radio<String>(
                                                    value: 'Take Away',
                                                    groupValue: orderType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        orderType =
                                                            value.toString();
                                                      });
                                                    },
                                                    activeColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color>((Set<
                                                                    MaterialState>
                                                                states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .selected)) {
                                                        return Colors
                                                            .white; // Color when selected
                                                      }
                                                      return Colors
                                                          .white; // Color when not selected
                                                    }),
                                                  ),
                                                ),
                                                Text(
                                                  'Take Away',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              VerticalDivider(
                                color: Colors.white,
                                thickness: 1,
                                width: 1,
                              ),

                              Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 55.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 200,
                                              height: 30,
                                              // margin: const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          toggleSale(true),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSaleOn
                                                              ? Colors.blue
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .horizontal(
                                                            left:
                                                                Radius.circular(
                                                                    12),
                                                          ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Sales',
                                                          style: TextStyle(
                                                            color: isSaleOn
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          toggleSale(false),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSaleOn
                                                              ? Colors.white
                                                              : Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .horizontal(
                                                            right:
                                                                Radius.circular(
                                                                    12),
                                                          ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'TableSales',
                                                          style: TextStyle(
                                                            color: isSaleOn
                                                                ? Colors.black
                                                                : Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: AnimatedSwitcher(
                                                duration:
                                                    Duration(milliseconds: 300),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                          child: isSaleOn
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'assets/imgs/trend.png',
                                                        width: 40,
                                                        height: 40,
                                                        color: Colors.white),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Sales',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .table_restaurant,
                                                          color: Colors.white,
                                                          size: 17,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          'Table No :',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16),
                                                        ),
                                                        SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        Container(
                                                          width: 150,
                                                          height: 30,
                                                          child: TextField(
                                                            focusNode:
                                                                _tableNoFocusNode,
                                                            onEditingComplete:
                                                                () {
                                                              print(
                                                                  'tablNo: ${tableNumberController.text}');
                                                              FocusScope.of(
                                                                      context)
                                                                  .requestFocus(
                                                                      _sCodeFocusNode);
                                                            },
                                                            controller:
                                                                tableNumberController,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.0,
                                                            ),
                                                            decoration:
                                                                InputDecoration(
                                                                    hintStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.6),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey), // Border color when enabled
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white),
                                                                    ),
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            5.0,
                                                                        horizontal:
                                                                            5.0)),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .format_list_numbered,
                                                          color: Colors.white,
                                                          size: 17,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          'Scode :',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16),
                                                        ),
                                                        SizedBox(
                                                          width: 25.0,
                                                        ),
                                                        Container(
                                                          width: 150,
                                                          height: 30,
                                                          child: TextField(
                                                            focusNode:
                                                                _sCodeFocusNode,
                                                            onEditingComplete:
                                                                () {
                                                              print(
                                                                  'sCode: ${scodeController.text}');
                                                              FocusScope.of(
                                                                      context)
                                                                  .requestFocus(
                                                                      _disAmtFocusNode);
                                                            },
                                                            controller:
                                                                scodeController,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.0,
                                                            ),
                                                            decoration:
                                                                InputDecoration(
                                                                    hintStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.6),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey), // Border color when enabled
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white),
                                                                    ),
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            5.0,
                                                                        horizontal:
                                                                            5.0)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.person_add,
                                                          color: Colors.white,
                                                          size: 17,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          'SName :',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16),
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Center(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showServantNamesDialog(
                                                                  context,
                                                                  servantNames,
                                                                  (selectedName) {
                                                                setState(() {
                                                                  selectedServantName =
                                                                      selectedName;
                                                                });
                                                                print(
                                                                    'Selected Servant: $selectedName');
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 150,
                                                              height: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  selectedServantName,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //   ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  color: Colors.white,
                  thickness: 1,
                  width: 1,
                ),
                Container(
                  //height: 700,

                  height: screenHeight,
                  width: MediaQuery.of(context).size.width * 0.28,

                  color: Colors.grey[350],

                  child: Center(
                      child: selectedProducts.isNotEmpty
                          ? _buildSelectedProductDetails()
                          : Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(Icons.cancel),
                                      color: Colors.black,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/imgs/order.png',
                                          width: 65, height: 65),
                                      const SizedBox(height: 15),
                                      const Text(
                                        'No Product Selected',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width > 900
                        ? 900
                        : MediaQuery.of(context).size.width,
                    height: 75,
                    padding: EdgeInsets.all(12.0),
                    color: maincolor,
                    child: Row(
                      children: [
                        for (int i = 0; i < apiCategories.length; i++)
                          Container(
                            //  height: 100,
                            child: GestureDetector(
                              onTap: () {
                                filterProductsByCategory(apiCategories[i]);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width > 120
                                    ? 120
                                    : MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                    vertical: 1, horizontal: 10),
                                //margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: selectedCategory == apiCategories[i]
                                      ? Colors.white.withOpacity(0.9)
                                      : null,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: selectedCategory == apiCategories[i]
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      getCategoryIcon(i),
                                      color:
                                          selectedCategory == apiCategories[i]
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      apiCategories[i],
                                      style: TextStyle(
                                        color:
                                            selectedCategory == apiCategories[i]
                                                ? Colors.black
                                                : Colors.white,
                                        fontSize: 16,
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
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Products',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Add space between "Products" and category name
                                  Text(
                                    '($selectedCategory)', // Display selected category name
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/imgs/noprod.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'No products found in the $selectedCategory category.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 16.0,
                                    crossAxisSpacing: 16.0,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0, top: 5.0),
                                      child: _buildProductCard(
                                        filteredProducts[index].name,
                                        filteredProducts[index].price,
                                        filteredProducts[index].imagePath,
                                        filteredProducts[index].cgstPercentage,
                                        filteredProducts[index].sgstPercentage,
                                        filteredProducts[index].quantity,
                                        filteredProducts[index]
                                            .totalPrice
                                            .toDouble(),
                                        filteredProducts[index].isFavorite,
                                        filteredProducts[index].category,
                                        // filteredProducts[index].makingCost,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  color: Color.fromRGBO(56, 37, 51, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        width: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Customer Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Name :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 20),
                                Container(
                                    width: 100,
                                    height: 25,
                                    child: TextField(
                                      controller: cusNameController,
                                      focusNode: _nameFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Name: ${cusNameController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_contactFocusNode);
                                      },
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Contact :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 7),
                                Container(
                                    width: 100,
                                    height: 25,
                                    child: TextField(
                                      focusNode: _contactFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Contact: ${contactController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_addressFocusNode);
                                      },
                                      controller: contactController,
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Address :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 6),
                                Container(
                                    width: 100,
                                    height: 25,
                                    child: TextField(
                                      focusNode: _addressFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Address: ${addressController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_tableNoFocusNode);
                                      },
                                      controller: addressController,
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 5),
                      // Divider between the left and right containers
                      VerticalDivider(
                        color: Colors.white,
                        thickness: 1,
                        width: 1,
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 230,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Type Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'GST Method :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 80,
                                  height: 20,
                                  child: TextField(
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    controller: gstMethodController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 5.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    readOnly: true,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_rupee_sharp,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Pay Type :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      fetchAndShowPaymentTypesDialog(context);
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment,
                                            color: Colors.black,
                                            size: 15,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            selectedPaymentType,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.8, // Adjust this value to scale the size of the radio button
                                        child: Radio<String>(
                                          value: 'DineIn',
                                          groupValue: orderType,
                                          onChanged: (value) {
                                            setState(() {
                                              orderType = value.toString();
                                            });
                                          },
                                          activeColor: Colors.white,
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors
                                                  .white; // Color when selected
                                            }
                                            return Colors
                                                .white; // Color when not selected
                                          }),
                                        ),
                                      ),
                                      Text(
                                        'DineIn',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.8, // Adjust this value to scale the size of the radio button
                                        child: Radio<String>(
                                          value: 'Take Away',
                                          groupValue: orderType,
                                          onChanged: (value) {
                                            setState(() {
                                              orderType = value.toString();
                                            });
                                          },
                                          activeColor: Colors.white,
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors
                                                  .white; // Color when selected
                                            }
                                            return Colors
                                                .white; // Color when not selected
                                          }),
                                        ),
                                      ),
                                      Text(
                                        'Take Away',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      VerticalDivider(
                        color: Colors.white,
                        thickness: 1,
                        width: 1,
                      ),
                      Container(
                        width: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 55.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 150,
                                    height: 25,
                                    margin: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => toggleSale(true),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSaleOn
                                                    ? Colors.blue
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  left: Radius.circular(12),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Sales',
                                                style: TextStyle(
                                                  color: isSaleOn
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => toggleSale(false),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSaleOn
                                                    ? Colors.white
                                                    : Colors.blue,
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  right: Radius.circular(12),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'TableSales',
                                                style: TextStyle(
                                                  color: isSaleOn
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: isSaleOn
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/imgs/trend.png',
                                              width: 35,
                                              height: 35,
                                              color: Colors.white),
                                          SizedBox(height: 5),
                                          Text(
                                            'Sales',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.table_restaurant,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'Table No :',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Container(
                                                width: 100,
                                                height: 25,
                                                child: TextField(
                                                  focusNode: _tableNoFocusNode,
                                                  onEditingComplete: () {
                                                    print(
                                                        'tablNo: ${tableNumberController.text}');
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            _sCodeFocusNode);
                                                  },
                                                  controller:
                                                      tableNumberController,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                  decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.6),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey), // Border color when enabled
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 5.0)),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.format_list_numbered,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'Scode :',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                              SizedBox(
                                                width: 25.0,
                                              ),
                                              Container(
                                                width: 100,
                                                height: 25,
                                                child: TextField(
                                                  focusNode: _sCodeFocusNode,
                                                  onEditingComplete: () {
                                                    print(
                                                        'sCode: ${scodeController.text}');
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            _disAmtFocusNode);
                                                  },
                                                  controller: scodeController,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                  decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.6),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey), // Border color when enabled
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 5.0)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_add,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'SName :',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Center(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showServantNamesDialog(
                                                        context, servantNames,
                                                        (selectedName) {
                                                      setState(() {
                                                        selectedServantName =
                                                            selectedName;
                                                      });
                                                      print(
                                                          'Selected Servant: $selectedName');
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 25,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        selectedServantName,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            color: Colors.white,
            thickness: 1,
            width: 1,
          ),
          Container(
            height: screenHeight,
            width: MediaQuery.of(context).size.width > 430
                ? 430
                : MediaQuery.of(context).size.width,
            color: Colors.grey[200],
            child: Center(
              child: selectedProducts.isNotEmpty
                  ? _buildSelectedProductDetails()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/imgs/order.png',
                            width: 65, height: 65),
                        const SizedBox(height: 15),
                        const Text(
                          'No Product Selected',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    double screenHeight = MediaQuery.of(context).size.height;

    double calculateCGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * cgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * cgstPercent) / 100;
        case 'NonGst':
          return 0.0;
        default:
          return 0.0;
      }
    }

    double calculateSGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * sgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * sgstPercent) / 100;
        case 'NonGst':
          return 0.0;
        default:
          return 0.0;
      }
    }

    double calculateTaxableAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice - (cgstAmount + sgstAmount);
        case 'Excluding':
          return totalPrice;
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    double calculateFinalAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return totalPrice;
        case 'Excluding':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice + (cgstAmount + sgstAmount);
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    void showProductDetailsDialog({
      required String discountAmount,
      required String finalTaxable,
      required String cgst,
      required String sgst,
      required String finalAmount,
    }) {
      final ScrollController controller = ScrollController();
      fitchcgstAmountController.text = cgst;
      fitchsgstAmountController.text = sgst;
      fitchfinalTaxableAmountController.text = finalTaxable;
      fitchfinalAmountController.text = finalAmount;

      TextEditingController itemsController = TextEditingController();
      itemsController.text = productDetails.length.toString();

      double totalTaxableAmount = 0.0;
      productDetails.forEach((key, value) {
        totalTaxableAmount += calculateTaxableAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      taxAmountController.text = totalTaxableAmount.toStringAsFixed(2);

      finalTaxableAmountController.text = totalTaxableAmount.toStringAsFixed(2);
      double totalCGSTAmount = 0.0;
      productDetails.forEach((key, value) {
        totalCGSTAmount += calculateCGST(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      cgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);
      sgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);

      double totalFinalAmount = 0.0;
      productDetails.forEach((key, value) {
        totalFinalAmount += calculateFinalAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      finalAmountController.text = totalFinalAmount.toStringAsFixed(2);

      Container buildStyledTextField(TextEditingController controller) {
        return Container(
          width: 100,
          height: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ),
              controller: controller,
              readOnly: true,
            ),
          ),
        );
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Product Details',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                content: ScrollConfiguration(
                  behavior: ScrollBehavior()
                      .copyWith(overscroll: false, scrollbars: false),
                  child: ScrollableView(
                    controller: controller,
                    scrollBarVisible: true,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: Colors.grey[200],
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior()
                              .copyWith(overscroll: false, scrollbars: false),
                          child: SingleChildScrollView(
                            // scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 160,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Quantity',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Total',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 105,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Taxable Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Retail Rate',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            'Final Amt',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children:
                                            productDetails.entries.map((entry) {
                                          double cgstAmount = calculateCGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double sgstAmount = calculateSGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double taxableAmount =
                                              calculateTaxableAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);
                                          print(
                                              'taxableAmount : $taxableAmount');
                                          double finalAmount =
                                              calculateFinalAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical:
                                                    4.0), // Add spacing between products
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 160,
                                                      child: Center(
                                                        child: Text(
                                                          entry.key,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          entry
                                                              .value['quantity']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '₹${entry.value['totalPrice']}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          cgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          sgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['cgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['sgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          finalAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'No.of.items',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              buildStyledTextField(
                                                  itemsController),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Taxable Amount',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                taxAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount %',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountPercentageController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'Including') {
                                                        calculateDiscountAmountInclude();
                                                      } else if (gstType ==
                                                          'Excluding') {
                                                        calculateDiscountAmountExclude();
                                                      } else if (gstType ==
                                                          'NonGst') {
                                                        calculateDisAmtNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountAmountController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'Including') {
                                                        calculateDiscountPercentageInclude();
                                                      } else if (gstType ==
                                                          'Excluding') {
                                                        calculateDiscountPercentageExclude();
                                                      } else if (gstType ==
                                                          'NonGst') {
                                                        calculateDisPercentNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Taxable',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalTaxableAmountController
                                                        .text.isEmpty
                                                    ? finalTaxableAmountController
                                                    : fitchfinalTaxableAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Cgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchcgstAmountController
                                                        .text.isEmpty
                                                    ? cgstAmountController
                                                    : fitchcgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Sgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchsgstAmountController
                                                        .text.isEmpty
                                                    ? sgstAmountController
                                                    : fitchsgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalAmountController
                                                        .text.isEmpty
                                                    ? finalAmountController
                                                    : fitchfinalAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          });
    }

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                height: 70,
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < apiCategories.length; i++)
                        GestureDetector(
                          onTap: () {
                            filterProductsByCategory(apiCategories[i]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width > 85
                                  ? 85
                                  : MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: selectedCategory == apiCategories[i]
                                    ? Colors.black.withOpacity(0.9)
                                    : null,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: selectedCategory == apiCategories[i]
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    getCategoryIcon(i),
                                    color: selectedCategory == apiCategories[i]
                                        ? Colors.white
                                        : Colors.black,
                                    size: 20,
                                  ),
                                  Container(
                                    width: 100, // Set the desired width
                                    child: Text(
                                      apiCategories[i],
                                      style: TextStyle(
                                        color:
                                            selectedCategory == apiCategories[i]
                                                ? Colors.white
                                                : Colors.black,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign
                                          .center, // Optionally center the text
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
              ),
              Stack(
                children: [
                  Container(
                    height: 540,
                    child: filteredProducts.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/imgs/noprod.png',
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'No products found in the $selectedCategory category.',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1, // Adjusted for 2 columns
                              mainAxisSpacing: 2.0,
                              crossAxisSpacing: 2.0,
                              childAspectRatio:
                                  2.15, // Adjusted ratio for proper height
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                child: _buildProductCard(
                                  filteredProducts[index].name,
                                  filteredProducts[index].price,
                                  filteredProducts[index].imagePath,
                                  filteredProducts[index].cgstPercentage,
                                  filteredProducts[index].sgstPercentage,
                                  filteredProducts[index].quantity,
                                  filteredProducts[index].totalPrice.toDouble(),
                                  filteredProducts[index].isFavorite,
                                  filteredProducts[index].category,
                                  // filteredProducts[index].makingCost,
                                ),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 14,
                    child: Visibility(
                      visible: _showFloatingButton,
                      child: SizedBox(
                        width: 80, // Set the desired width
                        //height: 50, // Set the desired height
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: subcolor, // Foreground color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4), // Adjust padding as needed
                          ),
                          onPressed: () async {
                            if (selectedPaymentType == "Credit" &&
                                cusNameController.text.isEmpty) {
                              showAlert(context,
                                  "Customer name is required for credit payment type.");
                              return;
                            }
                            await postSerialNumber();
                            if (!(selectedPaymentType == "Credit")) {
                              await incomeDetails();
                            }
                            String paidAmount =
                                selectedPaymentType.toLowerCase() == 'credit'
                                    ? '0.0'
                                    : finalAmount.toStringAsFixed(2);

                            await saveDetails(context, paidAmount);
                            setState(() {
                              // Reset the form fields
                              tableNumberController.clear();
                              itemsController.clear();
                              discountAmountController.clear();
                              finalAmountController.clear();
                              scodeController.clear();
                              cusNameController.clear();
                              contactController.clear();
                              discountPercentageController.clear();
                              taxAmountController.clear();
                              finalTaxableAmountController.clear();
                              addressController.clear();
                              selectedProducts.clear(); // Deselect products
                              servantNames.clear();
                              paymentTypes.clear();
                            });
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Icon(
                              Icons.download_outlined,
                              size: 15,
                            ),
                          ),
                          label: Padding(
                            padding: const EdgeInsets.only(
                                top: 2, bottom: 2, right: 2),
                            child: Text(
                              'Save',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  // Positioned(
                  //   bottom: 16,
                  //   right: 18,
                  //   child: Visibility(
                  //     visible: _showFloatingButton,
                  //     child: SizedBox(
                  //       width: 100, // Set the desired width
                  //       height: 50, // Set the desired height
                  //       child: FloatingActionButton.extended(
                  //         backgroundColor: subcolor,
                  //         foregroundColor: Colors.white,
                  //         onPressed: () async {
                  //           if (selectedPaymentType == "Credit" &&
                  //               cusNameController.text.isEmpty) {
                  //             showAlert(context,
                  //                 "Customer name is required for credit payment type.");
                  //             return;
                  //           }
                  //           await postSerialNumber();
                  //           if (!(selectedPaymentType == "Credit")) {
                  //             await incomeDetails();
                  //           }
                  //           String paidAmount =
                  //               selectedPaymentType.toLowerCase() == 'credit'
                  //                   ? '0.0'
                  //                   : finalAmount.toStringAsFixed(2);

                  //           await saveDetails(context, paidAmount);
                  //           setState(() {
                  //             // Reset the form fields
                  //             tableNumberController.clear();
                  //             itemsController.clear();
                  //             discountAmountController.clear();
                  //             finalAmountController.clear();
                  //             scodeController.clear();
                  //             cusNameController.clear();
                  //             contactController.clear();
                  //             discountPercentageController.clear();
                  //             taxAmountController.clear();
                  //             finalTaxableAmountController.clear();
                  //             addressController.clear();
                  //             selectedProducts.clear(); // Deselect products
                  //             servantNames.clear();
                  //             paymentTypes.clear();
                  //           });
                  //         },
                  //         icon: Icon(
                  //           Icons.download_outlined,
                  //           size: 15,
                  //         ),
                  //         label: Text(
                  //           'Save',
                  //           style: TextStyle(fontSize: 15),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
              Container(
                height: 640,
                color: Colors.white,
                child: Center(
                  child: selectedProducts.isNotEmpty
                      ? _buildSelectedProductDetails()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showProductDetailsDialog(
                                        discountAmount:
                                            discountAmount.toString(),
                                        finalTaxable:
                                            "${finalTaxableAmountController.text}",
                                        cgst: "${cgstAmountController.text}",
                                        sgst: "${sgstAmountController.text}",
                                        finalAmount:
                                            "${finalAmountController.text}",
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MouseRegion(
                                          onEnter: (event) =>
                                              setState(() => _isHovered = true),
                                          onExit: (event) => setState(
                                              () => _isHovered = false),
                                          child: Text(
                                            'Product Details',
                                            style: TextStyle(
                                              color: _isHovered
                                                  ? Colors.blue
                                                  : Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[200],
                                          ),
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' Tap "product details" to view the details',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                            SizedBox(height: 180),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/imgs/order.png',
                                      width: 65, height: 65),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'No Product Selected',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateProductDetails(Product product) {
    // Calculate the new total price
    product.totalPrice =
        double.parse(product.price.replaceAll('₹', '')) * product.quantity;

    print('Total Price: ₹${product.totalPrice.toStringAsFixed(2)}');

    setState(() {
      int index = selectedProducts.indexWhere((p) => p.name == product.name);
      if (index != -1) {
        // Product is already in the list, update its details
        selectedProducts[index] = product;
        print('Updated product in selectedProducts list');
      } else {
        // Product is not in the list, add it
        selectedProducts.add(product);
        print('Added product to selectedProducts list');
      }
    });
  }

  Widget buildProductDetails(Product product) {
    // Create a TextEditingController for the quantity field
    TextEditingController _quantityController =
        TextEditingController(text: product.quantity.toString());

    // Calculate the initial total price
    double totalPrice =
        double.parse(product.price.replaceAll('₹', '')) * product.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 32,
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                iconSize: 15,
                color: Colors.red,
                onPressed: () {
                  int quantity = int.parse(_quantityController.text);
                  if (quantity > 1) {
                    quantity--;
                    _quantityController.text = quantity.toString();
                    product.quantity = quantity;
                    updateProductDetails(product);
                  }
                },
              ),
              Text(
                '${product.quantity}',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add),
                iconSize: 15,
                color: Colors.green,
                onPressed: () {
                  int quantity = int.parse(_quantityController.text);
                  quantity++;
                  _quantityController.text = quantity.toString();
                  product.quantity = quantity;
                  updateProductDetails(product);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total: ₹${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    String name,
    String price,
    String imagePath,
    double? cgstPercentage,
    double? sgstPercentage,
    int quantity,
    double totalPrice,
    bool isFavorite,
    String category,
    // double makingCost,
  ) {
    final base64Data = imagePath.substring(imagePath.indexOf(',') + 1);
    final imageBytes = base64.decode(base64Data);
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    int productIndex =
        selectedProducts.indexWhere((product) => product.name == name);
    bool productIsSelected = productIndex != -1;
    bool isProductFavorite =
        favoriteProducts.any((product) => product.name == name);

    Color textColor = productIsSelected ? Colors.black : Colors.black;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double itemWidth = (screenWidth - 2 * 30.0 - 3 * 16.0) / 4;

    void addOrUpdateFavoriteProduct(
      String name,
      String price,
      String imagePath,
      double? cgstPercentage,
      double? sgstPercentage,
    ) {
      int existingIndex =
          favoriteProducts.indexWhere((product) => product.name == name);
      if (existingIndex != -1) {
        // Product already exists, update its details
        favoriteProducts[existingIndex] = Product(
          name: name,
          price: price,
          imagePath: imagePath,
          cgstPercentage: cgstPercentage ?? 0,
          sgstPercentage: sgstPercentage ?? 0,
          isFavorite: true, category: '', stock: '',
          stockValue: stockValue ?? 0,
          // makingCost: makingCost, // Set as favorite
        );
      } else {
        // Product is not in the list, add it
        favoriteProducts.add(Product(
          name: name,
          price: price,
          imagePath: imagePath,
          cgstPercentage: cgstPercentage ?? 0,
          sgstPercentage: sgstPercentage ?? 0,
          isFavorite: true, category: '',
          stock: '',
          stockValue: stockValue ?? 0,
          // makingCost: makingCost, // Set as favorite
        ));
      }
      _saveFavoriteProducts(); // Save the updated favorite products
    }

    void showMessage(String message, bool added) {
      Color dialogColor = added ? Colors.green : Colors.green;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true); // Close the dialog after 2 seconds
          });

          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Material(
                // color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: dialogColor,
                    // borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    void addToCart(Product product) {
      setState(() {
        int productIndex =
            filteredProducts.indexWhere((p) => p.name == product.name);
        if (productIndex != -1) {
          // Product already exists in cart
          if (filteredProducts[productIndex].stock == 'No') {
            // Unlimited quantity for products with 'Stock: No'
            filteredProducts[productIndex].quantity++;
            // showMessage('Product added to cart', true);
          } else if (filteredProducts[productIndex].stock == 'Yes') {
            // Limited quantity based on 'Stock Value' for products with 'Stock: Yes'
            if (filteredProducts[productIndex].quantity <
                filteredProducts[productIndex].stockValue) {
              filteredProducts[productIndex].quantity++;
              // showMessage('Product added to cart', true);
            } else {
              // Show alert or message that stock is limited
              showDialog(
                barrierDismissible:
                    false, // Prevents closing the dialog when tapping outside
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Stock Limit Reached"),
                    content: Text(
                        " ${filteredProducts[productIndex].name} available quantity is ${filteredProducts[productIndex].stockValue}..Kindly add stock to proceed"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          // Show another dialog with more information
                          Navigator.of(context)
                              .pop(); // Close the initial dialog
                          showDialog(
                            barrierDismissible:
                                false, // Prevents closing the dialog when tapping outside
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return AlertDialog(
                                    title: Text("Confirm Addition"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "You are about to add beyond the stock limit. Are you sure you want to continue?"),
                                        SizedBox(height: 10),
                                        Container(
                                          width: isDesktop ? 90 : 110,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                color: Colors.red,
                                                iconSize: 14,
                                                onPressed: () {
                                                  setState(() {
                                                    if (product.quantity > 1) {
                                                      product.quantity--;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text(
                                                product.quantity.toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                color: Colors.green,
                                                iconSize: 14,
                                                onPressed: () {
                                                  setState(() {
                                                    product.quantity++;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Confirm"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the confirmation dialog
                                          updateProductDetails(
                                              product); // Update product details in the parent widget
                                          showMessage(
                                              'Product added to cart', true);
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the confirmation dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: () {
                          setState(() {
                            // Check if stock value is available and update quantity
                            if (filteredProducts[productIndex].stockValue !=
                                null) {
                              // Convert double to int, assuming stockValue is a double
                              filteredProducts[productIndex].quantity =
                                  filteredProducts[productIndex]
                                      .stockValue
                                      .toInt();

                              // Update the TextField controller to reflect the new quantity
                              // Note: Use a TextEditingController instance for persistent changes
                              TextEditingController _controller =
                                  TextEditingController();
                              _controller.text = filteredProducts[productIndex]
                                  .quantity
                                  .toString();

                              print(
                                  "Product: ${filteredProducts[productIndex].name}, Quantity set to: ${filteredProducts[productIndex].quantity}");
                            } else {}
                          });
                          updateProductDetails(product);
                          Navigator.of(context).pop();
                          showMessage(
                              "Current stock available: ${filteredProducts[productIndex].stockValue}",
                              false);
                          Timer(Duration(seconds: 2), () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }
        } else {
          // Product does not exist in cart, add it with quantity 1
          filteredProducts.add(Product(
            name: product.name,
            price: product.price,
            imagePath: product.imagePath,
            cgstPercentage: product.cgstPercentage,
            sgstPercentage: product.sgstPercentage,
            category: product.category,
            stock: product.stock,
            stockValue: product.stockValue,
            quantity: 1,
          ));
          showMessage('Product added to cart', true);
        }
      });
    }

    return GestureDetector(
      onTap: () {
        addToCart(Product(
          name: name,
          price: price,
          imagePath: imagePath,
          cgstPercentage: cgstPercentage!,
          sgstPercentage: sgstPercentage!,
          category: category,
          stock: stock,
          stockValue: stockValue,
          quantity: quantity,
        ));
        setState(() {
          int productIndex = selectedProducts.indexWhere((p) => p.name == name);
          if (productIndex != -1) {
            // Product is already in the list, increase the quantity
            selectedProducts[productIndex].quantity++;
          } else {
            // Product is not in the list, add it with initial quantity 1
            selectedProducts.add(Product(
              name: name,
              price: price,
              imagePath: imagePath,
              cgstPercentage: cgstPercentage,
              sgstPercentage: sgstPercentage,
              category: category,
              quantity: 1,
              stock: stock,
              stockValue: stockValue,
            ));
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(
            left: isDesktop ? 0 : 30.0,
            right: isDesktop ? 0 : 30.0,
            top: isDesktop ? 0 : 15.0),
        width: isDesktop
            ? itemWidth // Reduced width
            : MediaQuery.of(context).size.width * 0.8, // Reduced width
        height: isDesktop
            ? MediaQuery.of(context).size.height > 430
                ? 430
                : MediaQuery.of(context)
                    .size
                    .height // 30% of the screen height for desktop
            : MediaQuery.of(context).size.height * 0.8, // Adjusted height
        decoration: BoxDecoration(
          color: productIsSelected
              ? Color.fromARGB(255, 202, 199, 202)
              // ? Color.fromARGB(248, 184, 183, 185)
              // ? Color.fromARGB(244, 209, 207, 207)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: isDesktop
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isProductFavorite = !isProductFavorite;
                            if (isProductFavorite) {
                              addOrUpdateFavoriteProduct(
                                name,
                                price,
                                imagePath,
                                cgstPercentage,
                                sgstPercentage,
                              );
                              showMessage('Product added to favorites!', true);
                            } else {
                              favoriteProducts.removeWhere(
                                  (product) => product.name == name);
                              showMessage(
                                  'Product removed from favorites!', false);
                              _saveFavoriteProducts(); // Save the updated favorite products
                            }
                          });
                        },
                        icon: Icon(
                          isProductFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isProductFavorite ? Colors.red : Colors.black,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        45.0), // Half of the width/height to make it a circle
                    child: Image.memory(
                      imageBytes, // Ensure the correct path to your image
                      height: MediaQuery.of(context).size.height > 90
                          ? 90
                          : MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.height > 90
                          ? 90
                          : MediaQuery.of(context).size.height,
                      fit: BoxFit
                          .cover, // This ensures the image fits within the container
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Price: $price',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(45.0),
                          child: Image.memory(
                            imageBytes,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: 150,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Price: $price',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            if (!productIsSelected)
                              ElevatedButton(
                                onPressed: () {
                                  // Your onPressed logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            if (productIsSelected)
                              buildProductDetails(
                                  selectedProducts[productIndex])
                          ]),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isProductFavorite = !isProductFavorite;
                                if (isProductFavorite) {
                                  addOrUpdateFavoriteProduct(
                                    name,
                                    price,
                                    imagePath,
                                    cgstPercentage,
                                    sgstPercentage,
                                  );
                                  showMessage(
                                      'Product added to favorites!', true);
                                } else {
                                  favoriteProducts.removeWhere(
                                      (product) => product.name == name);
                                  showMessage(
                                      'Product removed from favorites!', false);
                                  _saveFavoriteProducts();
                                }
                              });
                            },
                            icon: Icon(
                              isProductFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isProductFavorite ? Colors.red : Colors.black,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      if (productIsSelected)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  for (var product in selectedProducts) {
                                    if (product.name == name) {
                                      selectedProducts.remove(product);
                                      break;
                                    }
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSelectedProductDetails() {
    bool isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return buildMobileView();
    } else {
      return buildDesktopView();
    }
  }

  Widget buildMobileView() {
    double totalAmount = 0.0;

    Map<String, Map<String, dynamic>> productDetails = {};

    void updateProductDetails(Product product) {
      final productPrice = double.parse(product.price.replaceAll('₹', ''));

      if (productDetails.containsKey(product.name)) {
        productDetails[product.name]!['quantity'] += product.quantity;
        productDetails[product.name]!['totalPrice'] +=
            productPrice * product.quantity;
      } else {
        productDetails[product.name] = {
          'quantity': product.quantity,
          'totalPrice': productPrice * product.quantity,
          'cgstPercentage': product.cgstPercentage ?? 0.0,
          'sgstPercentage': product.sgstPercentage ?? 0.0,
        };
      }

      totalAmount = 0.0;
      productDetails.forEach((_, details) {
        totalAmount += details['totalPrice'] as double;
      });

      print('Total Amount: $totalAmount');
    }

    Widget buildRowHeaders() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: Colors.black,
                    size: 20,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                    size: 20,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Qty',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    color: Colors.black,
                    size: 18,
                  ),
                  Text(
                    'Total Price',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget buildProductDetails(
        String productName, int quantity, double totalPrice, Product product) {
      TextEditingController _quantityController =
          TextEditingController(text: product.quantity.toString());
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                child: Text(
                  productName,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Text(
                  '${product.quantity}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
              const SizedBox(width: 60),
              Container(
                  width: 60,
                  child: Text(
                    '$totalPrice',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () {
                  setState(() {
                    for (var product in selectedProducts) {
                      if (product.name == product.name) {
                        selectedProducts.remove(product);
                        break;
                      }
                    }
                  });
                },
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
        ],
      );
    }

    double calculateCGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * cgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * cgstPercent) / 100;
        case 'NonGst':
          return 0.0;
        default:
          return 0.0;
      }
    }

    double calculateSGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * sgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * sgstPercent) / 100;
        case 'NonGst':
          return 0.0;
        default:
          return 0.0;
      }
    }

    double calculateTaxableAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice - (cgstAmount + sgstAmount);
        case 'Excluding':
          return totalPrice;
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    double calculateFinalAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return totalPrice;
        case 'Excluding':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice + (cgstAmount + sgstAmount);
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    void showProductDetailsDialog({
      required String discountAmount,
      required String finalTaxable,
      required String cgst,
      required String sgst,
      required String finalAmount,
    }) {
      final ScrollController controller = ScrollController();
      fitchcgstAmountController.text = cgst;
      fitchsgstAmountController.text = sgst;
      fitchfinalTaxableAmountController.text = finalTaxable;
      fitchfinalAmountController.text = finalAmount;

      TextEditingController itemsController = TextEditingController();
      itemsController.text = productDetails.length.toString();

      double totalTaxableAmount = 0.0;
      productDetails.forEach((key, value) {
        totalTaxableAmount += calculateTaxableAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      taxAmountController.text = totalTaxableAmount.toStringAsFixed(2);

      finalTaxableAmountController.text = totalTaxableAmount.toStringAsFixed(2);
      double totalCGSTAmount = 0.0;
      productDetails.forEach((key, value) {
        totalCGSTAmount += calculateCGST(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      cgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);
      sgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);

      double totalFinalAmount = 0.0;
      productDetails.forEach((key, value) {
        totalFinalAmount += calculateFinalAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      finalAmountController.text = totalFinalAmount.toStringAsFixed(2);

      Container buildStyledTextField(TextEditingController controller) {
        return Container(
          width: 100,
          height: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ),
              controller: controller,
              readOnly: true,
            ),
          ),
        );
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Product Details',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                content: ScrollConfiguration(
                  behavior: ScrollBehavior()
                      .copyWith(overscroll: false, scrollbars: false),
                  child: ScrollableView(
                    controller: controller,
                    scrollBarVisible: true,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: Colors.grey[200],
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior()
                              .copyWith(overscroll: false, scrollbars: false),
                          child: SingleChildScrollView(
                            // scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 160,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Quantity',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Total',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 105,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Taxable Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Retail Rate',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            'Final Amt',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children:
                                            productDetails.entries.map((entry) {
                                          double cgstAmount = calculateCGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double sgstAmount = calculateSGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double taxableAmount =
                                              calculateTaxableAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);
                                          print(
                                              'taxableAmount : $taxableAmount');
                                          double finalAmount =
                                              calculateFinalAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical:
                                                    4.0), // Add spacing between products
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 160,
                                                      child: Center(
                                                        child: Text(
                                                          entry.key,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          entry
                                                              .value['quantity']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '₹${entry.value['totalPrice']}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          cgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          sgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['cgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['sgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          finalAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'No.of.items',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              buildStyledTextField(
                                                  itemsController),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Taxable Amount',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                taxAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount %',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountPercentageController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'Including') {
                                                        calculateDiscountAmountInclude();
                                                      } else if (gstType ==
                                                          'Excluding') {
                                                        calculateDiscountAmountExclude();
                                                      } else if (gstType ==
                                                          'NonGst') {
                                                        calculateDisAmtNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountAmountController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'Including') {
                                                        calculateDiscountPercentageInclude();
                                                      } else if (gstType ==
                                                          'Excluding') {
                                                        calculateDiscountPercentageExclude();
                                                      } else if (gstType ==
                                                          'NonGst') {
                                                        calculateDisPercentNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Taxable',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalTaxableAmountController
                                                        .text.isEmpty
                                                    ? finalTaxableAmountController
                                                    : fitchfinalTaxableAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Cgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchcgstAmountController
                                                        .text.isEmpty
                                                    ? cgstAmountController
                                                    : fitchcgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Sgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchsgstAmountController
                                                        .text.isEmpty
                                                    ? sgstAmountController
                                                    : fitchsgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalAmountController
                                                        .text.isEmpty
                                                    ? finalAmountController
                                                    : fitchfinalAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          });
    }

    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showProductDetailsDialog(
                  discountAmount: discountAmount.toString(),
                  finalTaxable: "${finalTaxableAmountController.text}",
                  cgst: "${cgstAmountController.text}",
                  sgst: "${sgstAmountController.text}",
                  finalAmount: "${finalAmountController.text}",
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    onEnter: (event) => setState(() => _isHovered = true),
                    onExit: (event) => setState(() => _isHovered = false),
                    child: Text(
                      'Product Details',
                      style: TextStyle(
                        color: _isHovered ? Colors.blue : Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: 8), // Add spacing between text and icon
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.0,
                      ),
                    ),
                    TextSpan(
                      text: ' Tap "product details" to view the details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Display the row headers only if there are selected products
            if (selectedProducts.isNotEmpty) buildRowHeaders(),
            const SizedBox(height: 13),
            // Display the details of selected products
            Container(
              height: 268,
              // color: Colors.white,
              child: ScrollConfiguration(
                behavior: ScrollBehavior()
                    .copyWith(overscroll: false, scrollbars: false),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: selectedProducts.map((product) {
                      // Update product details map
                      updateProductDetails(product);

                      return buildProductDetails(
                          product.name,
                          product.quantity,
                          double.parse(product.price.replaceAll('₹', '')) *
                              product.quantity,
                          product);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: Color.fromRGBO(56, 37, 51, 1),
            width: MediaQuery.of(context).size.width,
            height: 170,
            child: PageView(
              controller: _pageController,
              children: [
                //first container
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToPreviousPage,
                        child: Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 25),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Customer Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Name :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 20),
                                Container(
                                    width: 150,
                                    height: 30,
                                    child: TextField(
                                      controller: cusNameController,
                                      focusNode: _nameFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Name: ${cusNameController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_contactFocusNode);
                                      },
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Contact :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 7),
                                Container(
                                    width: 150,
                                    height: 30,
                                    child: TextField(
                                      focusNode: _contactFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Contact: ${contactController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_addressFocusNode);
                                      },
                                      controller: contactController,
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Address :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 6),
                                Container(
                                    width: 150,
                                    height: 30,
                                    child: TextField(
                                      focusNode: _addressFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Address: ${addressController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_tableNoFocusNode);
                                      },
                                      controller: addressController,
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                      GestureDetector(
                        onTap: _navigateToNextPage,
                        child: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
                //second
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToPreviousPage,
                        child: Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 25),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Type Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'GST Method :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 100,
                                  height: 30,
                                  child: TextField(
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    controller: gstMethodController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 5.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    readOnly: true,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_rupee_sharp,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Pay Type :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      fetchAndShowPaymentTypesDialog(context);
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment,
                                            color: Colors.black,
                                            size: 15,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            selectedPaymentType,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //    SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.8, // Adjust this value to scale the size of the radio button
                                        child: Radio<String>(
                                          value: 'DineIn',
                                          groupValue: orderType,
                                          onChanged: (value) {
                                            setState(() {
                                              orderType = value.toString();
                                            });
                                          },
                                          activeColor: Colors.white,
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors
                                                  .white; // Color when selected
                                            }
                                            return Colors
                                                .white; // Color when not selected
                                          }),
                                        ),
                                      ),
                                      Text(
                                        'DineIn',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.8, // Adjust this value to scale the size of the radio button
                                        child: Radio<String>(
                                          value: 'Take Away',
                                          groupValue: orderType,
                                          onChanged: (value) {
                                            setState(() {
                                              orderType = value.toString();
                                            });
                                          },
                                          activeColor: Colors.white,
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors
                                                  .white; // Color when selected
                                            }
                                            return Colors
                                                .white; // Color when not selected
                                          }),
                                        ),
                                      ),
                                      Text(
                                        'Take Away',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                      GestureDetector(
                        onTap: _navigateToNextPage,
                        child: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
                //third
                Container(
                  height: 50,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 85.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 200,
                                        height: 30,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => toggleSale(true),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSaleOn
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.horizontal(
                                                      left: Radius.circular(12),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Sales',
                                                    style: TextStyle(
                                                      color: isSaleOn
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => toggleSale(false),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSaleOn
                                                        ? Colors.white
                                                        : Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.horizontal(
                                                      right:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'TableSales',
                                                    style: TextStyle(
                                                      color: isSaleOn
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: isSaleOn
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/trend.png',
                                              width: 35,
                                              height: 35,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Sales',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.table_restaurant,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'Table No :',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Container(
                                                  width: 150,
                                                  height: 30,
                                                  child: TextField(
                                                    focusNode:
                                                        _tableNoFocusNode,
                                                    onEditingComplete: () {
                                                      print(
                                                          'tablNo: ${tableNumberController.text}');
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _sCodeFocusNode);
                                                    },
                                                    controller:
                                                        tableNumberController,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                    ),
                                                    decoration: InputDecoration(
                                                        hintStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey), // Border color when enabled
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5.0,
                                                                    horizontal:
                                                                        5.0)),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.format_list_numbered,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'Scode :',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 25.0,
                                                ),
                                                Container(
                                                  width: 150,
                                                  height: 30,
                                                  child: TextField(
                                                    focusNode: _sCodeFocusNode,
                                                    onEditingComplete: () {
                                                      print(
                                                          'sCode: ${scodeController.text}');
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _disAmtFocusNode);
                                                    },
                                                    controller: scodeController,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                    ),
                                                    decoration: InputDecoration(
                                                        hintStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey), // Border color when enabled
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5.0,
                                                                    horizontal:
                                                                        5.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person_add,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'SName :',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Center(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showServantNamesDialog(
                                                          context, servantNames,
                                                          (selectedName) {
                                                        setState(() {
                                                          selectedServantName =
                                                              selectedName;
                                                        });
                                                        print(
                                                            'Selected Servant: $selectedName');
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 150,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          selectedServantName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 25,
                        child: GestureDetector(
                          onTap: _navigateToPreviousPage,
                          child: Icon(
                            Icons.arrow_circle_left,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 25,
                        child: GestureDetector(
                          onTap: _navigateToNextPage,
                          child: Icon(
                            Icons.arrow_circle_right,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //four
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToPreviousPage,
                        child: Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 120),
                              Column(
                                children: [
                                  Text(
                                    '₹$totalAmount',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Dis %:',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 5),
                                    Column(children: [
                                      SizedBox(
                                        width: 65,
                                        height: 25,
                                        child: Center(
                                          child: TextFormField(
                                            focusNode: _disAmtFocusNode,
                                            onEditingComplete: () {
                                              print(
                                                  'discountAmount: ${discountAmountController.text}');
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      _disPercFocusNode);
                                            },
                                            style:
                                                TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: '',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .grey), // Border color when enabled
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 9.0,
                                                horizontal: 9.0,
                                              ),
                                            ),
                                            controller:
                                                discountPercentageController,
                                            onChanged: (value) {
                                              if (gstType == 'Including') {
                                                calculateDiscountAmountInclude();
                                              } else if (gstType ==
                                                  'Excluding') {
                                                calculateDiscountAmountExclude();
                                              } else if (gstType == 'NonGst') {
                                                calculateDisAmtNongst();
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                    ])
                                  ]),
                              SizedBox(
                                width: 35,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dis Amt:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 65,
                                        height: 25,
                                        child: Center(
                                          child: TextFormField(
                                            focusNode: _disPercFocusNode,
                                            onEditingComplete: () {
                                              print(
                                                  'discountPerc: ${discountPercentageController.text}');
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      _saveDetailsFocusNode);
                                            },
                                            style:
                                                TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: '',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .grey), // Border color when enabled
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 9.0,
                                                      horizontal: 9.0),
                                            ),
                                            controller:
                                                discountAmountController,
                                            onChanged: (value) {
                                              if (gstType == 'Including') {
                                                calculateDiscountPercentageInclude();
                                              } else if (gstType ==
                                                  'Excluding') {
                                                calculateDiscountPercentageExclude();
                                              } else if (gstType == 'NonGst') {
                                                calculateDisPercentNongst();
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'RS.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    5), // Space before the vertical line
                                            Container(
                                              width:
                                                  1, // Width of the vertical line
                                              height:
                                                  30, // Height of the vertical line
                                              color: Colors
                                                  .black, // Color of the vertical line
                                            ),
                                            SizedBox(
                                                width:
                                                    6), // Space after the vertical line
                                            Text(
                                              '${fitchfinalAmountController.text.isEmpty ? NumberFormat.currency(
                                                  locale: 'en_IN',
                                                  symbol: '₹',
                                                ).format(totalAmount) : fitchfinalAmountController.text}/-',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 15),
                              Container(
                                width: 100,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (selectedPaymentType == "Credit" &&
                                        cusNameController.text.isEmpty) {
                                      showAlert(context,
                                          "Customer name is required for credit payment type.");
                                      return;
                                    }
                                    await postSerialNumber();
                                    if (!(selectedPaymentType == "Credit")) {
                                      await incomeDetails();
                                    }
                                    String paidAmount =
                                        selectedPaymentType.toLowerCase() ==
                                                'credit'
                                            ? '0.0'
                                            : finalAmount.toStringAsFixed(2);

                                    await saveDetails(context, paidAmount);
                                    setState(() {
                                      // Reset the form fields
                                      tableNumberController.clear();
                                      itemsController.clear();
                                      discountAmountController.clear();
                                      finalAmountController.clear();
                                      scodeController.clear();
                                      cusNameController.clear();
                                      contactController.clear();
                                      discountPercentageController.clear();
                                      taxAmountController.clear();
                                      finalTaxableAmountController.clear();
                                      addressController.clear();
                                      selectedProducts
                                          .clear(); // Deselect products
                                      servantNames.clear();
                                      paymentTypes.clear();
                                    });
                                  },
                                  focusNode: _saveDetailsFocusNode,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue, // Text color

                                    textStyle: TextStyle(fontSize: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ]),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: _navigateToNextPage,
                        child: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ))
    ]);
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert', style: TextStyle(fontSize: 15)),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Adjust the radius here
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDesktopView() {
    int productIndex =
        selectedProducts.indexWhere((product) => product.name == product.name);
    const double mmWidth = 80.0; // 80 mm

    double pixels = mmWidth * MediaQuery.of(context).devicePixelRatio / 25.4;
    // void _showDialog() {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return Dialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         child: Container(
    //           width: pixels,
    //           // height: 100,
    //           padding: const EdgeInsets.all(16.0),
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Colors.grey.withOpacity(0.5),
    //                 spreadRadius: 2,
    //                 blurRadius: 5,
    //                 offset: const Offset(0, 3),
    //               ),
    //             ],
    //             borderRadius: BorderRadius.circular(8),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               Text(
    //                 'Menaka Restarunt',
    //                 style: TextStyle(
    //                   fontSize: 15,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               SizedBox(height: 8),
    //               Text(
    //                 '123 Main Street',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'Tenkasi-123456',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'GST No: 1234567890',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'FSSAI No: ABC123XYZ456',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'Contact: +91 9876543210',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               SizedBox(height: 10),
    //               // DashedDivider(),
    //               SizedBox(height: 10),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [Text('BillNo : 01'), Text('payType:cash')],
    //               ),
    //               SizedBox(height: 5),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [Text('Date:21.06.2024'), Text('Time:5.00 PM')],
    //               ),
    //               SizedBox(height: 10),
    //               // DashedDivider(),
    //             ],
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }

    num totalAmount = 0;

    Map<String, Map<String, dynamic>> productDetails = {};
    void updateProductDetails(Product product) {
      final productPrice = double.parse(product.price.replaceAll('₹', ''));

      if (productDetails.containsKey(product.name)) {
        productDetails[product.name]!['quantity'] = product.quantity;
        productDetails[product.name]!['totalPrice'] =
            productPrice * product.quantity;
      } else {
        productDetails[product.name] = {
          'quantity': product.quantity,
          'totalPrice': productPrice * product.quantity,
          'cgstPercentage': product.cgstPercentage ?? 0.0,
          'sgstPercentage': product.sgstPercentage ?? 0.0,
        };
      }

      print('Product details updated:');
      print('Name: ${product.name}');
      print('Updated Quantity: ${productDetails[product.name]!['quantity']}');
      print(
          'Updated Total Price: ₹${productDetails[product.name]!['totalPrice']}');
      print(
          'CGST Percentage: ${productDetails[product.name]!['cgstPercentage']}');
      print(
          'SGST Percentage: ${productDetails[product.name]!['sgstPercentage']}');

      totalAmount = 0.0;
      productDetails.forEach((_, details) {
        totalAmount += details['totalPrice'] as double;
      });

      print('Total Amount: $totalAmount');
    }

    Widget buildRowHeaders() {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag,
                      color: Colors.black), // Icon for name
                  SizedBox(width: 3),
                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.black,
                      //    fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.shopping_cart,
                      color: Colors.black), // Icon for quantity
                  SizedBox(width: 3),
                  Text(
                    'Quantity',
                    style: TextStyle(
                      color: Colors.black,
                      //    fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.attach_money,
                      color: Colors.black), // Icon for total price
                  SizedBox(width: 3),
                  Text(
                    'Total Price',
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

// Define the buildProductDetails function
    Widget buildProductDetails(
        String name, int quantity, double totalPrice, Product product) {
      return Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Container(
            width: 80,
            child: Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          SizedBox(
            width: 65,
          ),
          Container(
            width: 90,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  color: Colors.red,
                  iconSize: 15,
                  onPressed: () {
                    setState(() {
                      if (quantity > 1) {
                        product.quantity--;
                      }
                    });
                  },
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  iconSize: 15,
                  onPressed: () {
                    setState(() {
                      product.quantity++;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 65,
          ),
          Text(
            '₹$totalPrice',
            style: TextStyle(fontSize: 15),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            iconSize: 16,
            onPressed: () {
              setState(() {
                selectedProducts.remove(product);
              });
            },
          ),
        ],
      );
    }

    double calculateCGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          print(totalPrice);
          print(cgstPercent);
          print(sgstPercent);

          return (totalPrice * cgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * cgstPercent) / 100;
        case 'NonGst':
          return 0.0; // No GST for non-GST items
        default:
          return 0.0;
      }
    }

    double calculateSGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * sgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * sgstPercent) / 100;
        case 'NonGst':
          return 0.0; // No GST for non-GST items
        default:
          return 0.0;
      }
    }

    double calculateTaxableAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice - (cgstAmount + sgstAmount);
        case 'Excluding':
          return totalPrice;
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    double calculateFinalAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return totalPrice;
        case 'Excluding':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice + (cgstAmount + sgstAmount);

        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    void showProductDetailsDialog({
      required String discountAmount,
      required String finalTaxable,
      required String cgst,
      required String sgst,
      required String finalAmount,
    }) {
      final ScrollController controller = ScrollController();
      fitchcgstAmountController.text = cgst;
      fitchsgstAmountController.text = sgst;
      fitchfinalTaxableAmountController.text = finalTaxable;
      fitchfinalAmountController.text = finalAmount;

      TextEditingController itemsController = TextEditingController();
      itemsController.text = productDetails.length.toString();

      double totalTaxableAmount = 0.0;
      productDetails.forEach((key, value) {
        totalTaxableAmount += calculateTaxableAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      taxAmountController.text = totalTaxableAmount.toStringAsFixed(2);

      finalTaxableAmountController.text = totalTaxableAmount.toStringAsFixed(2);
      double totalCGSTAmount = 0.0;
      productDetails.forEach((key, value) {
        totalCGSTAmount += calculateCGST(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      cgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);
      sgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);

      double totalFinalAmount = 0.0;
      productDetails.forEach((key, value) {
        totalFinalAmount += calculateFinalAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      finalAmountController.text = totalFinalAmount.toStringAsFixed(2);

      Container buildStyledTextField(TextEditingController controller) {
        return Container(
          width: 100,
          height: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ),
              controller: controller,
              readOnly: true,
            ),
          ),
        );
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Product Details',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                content: ScrollConfiguration(
                  behavior: ScrollBehavior()
                      .copyWith(overscroll: false, scrollbars: false),
                  child: ScrollableView(
                    controller: controller,
                    scrollBarVisible: true,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: Colors.grey[200],
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior()
                              .copyWith(overscroll: false, scrollbars: false),
                          child: SingleChildScrollView(
                            // scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 160,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Quantity',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Total',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 105,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Taxable Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Retail Rate',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            'Final Amt',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children:
                                            productDetails.entries.map((entry) {
                                          double cgstAmount = calculateCGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double sgstAmount = calculateSGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double taxableAmount =
                                              calculateTaxableAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);
                                          print(
                                              'taxableAmount : $taxableAmount');
                                          double finalAmount =
                                              calculateFinalAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical:
                                                    4.0), // Add spacing between products
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 160,
                                                      child: Center(
                                                        child: Text(
                                                          entry.key,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          entry
                                                              .value['quantity']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '₹${entry.value['totalPrice']}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          cgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          sgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['cgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['sgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          finalAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'No.of.items',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              buildStyledTextField(
                                                  itemsController),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Taxable Amount',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                taxAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount %',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountPercentageController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'include') {
                                                        calculateDiscountAmountInclude();
                                                      } else if (gstType ==
                                                          'exclude') {
                                                        calculateDiscountAmountExclude();
                                                      } else if (gstType ==
                                                          'non gst') {
                                                        calculateDisAmtNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountAmountController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'include') {
                                                        calculateDiscountPercentageInclude();
                                                      } else if (gstType ==
                                                          'exclude') {
                                                        calculateDiscountPercentageExclude();
                                                      } else if (gstType ==
                                                          'non gst') {
                                                        calculateDisPercentNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Taxable',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalTaxableAmountController
                                                        .text.isEmpty
                                                    ? finalTaxableAmountController
                                                    : fitchfinalTaxableAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Cgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchcgstAmountController
                                                        .text.isEmpty
                                                    ? cgstAmountController
                                                    : fitchcgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Sgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchsgstAmountController
                                                        .text.isEmpty
                                                    ? sgstAmountController
                                                    : fitchsgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalAmountController
                                                        .text.isEmpty
                                                    ? finalAmountController
                                                    : fitchfinalAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          });
    }

    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align to start

      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showProductDetailsDialog(
                    discountAmount: discountAmount.toString(),
                    finalTaxable: "${finalTaxableAmountController.text}",
                    cgst: "${cgstAmountController.text}",
                    sgst: "${sgstAmountController.text}",
                    finalAmount: "${finalAmountController.text}",
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      onEnter: (event) => setState(() => _isHovered = true),
                      onExit: (event) => setState(() => _isHovered = false),
                      child: Text(
                        'Product Details',
                        style: TextStyle(
                          color: _isHovered ? Colors.blue : Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13.0,
                        ),
                      ),
                      TextSpan(
                        text: ' Tap "product details" to view the details',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(width: 45),

              const SizedBox(height: 25),

              // Display the row headers only if there are selected products
              if (selectedProducts.isNotEmpty) buildRowHeaders(),
              const SizedBox(height: 10),
              // Display the details of selected products
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    height: 300,
                    // color: Colors.white,
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior()
                          .copyWith(overscroll: false, scrollbars: false),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: selectedProducts.map((product) {
                            // Calculate total price based on quantity and price
                            double totalPrice = product.quantity *
                                double.parse(product.price.replaceAll('₹', ''));
                            updateProductDetails(product);
                            return buildProductDetails(
                              product.name,
                              product.quantity,
                              totalPrice,
                              product,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SingleChildScrollView(
                  child: Container(
                    color: Color.fromRGBO(56, 37, 51, 1),
                    width: MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.width *
                            0.28 // Desktop view
                        : MediaQuery.of(context).size.width > 600
                            ? MediaQuery.of(context).size.width *
                                0.36 // Tablet view
                            : MediaQuery.of(context)
                                .size
                                .width, // Mobile view (not currently used)
                    height: MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.height *
                            0.20 // Desktop view
                        : MediaQuery.of(context).size.width > 600
                            ? MediaQuery.of(context).size.height *
                                0.16 // Tablet view
                            : MediaQuery.of(context).size.height *
                                0.40, // Mobile view

                    //  width: MediaQuery.of(context).size.width * 0.28,
                    // height: MediaQuery.of(context).size.height * 0.20,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 150),
                              Column(
                                children: [
                                  Text(
                                    '₹$totalAmount',
                                    style: const TextStyle(
                                        fontSize: 19, color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dis %:',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 7),
                                  Column(children: [
                                    SizedBox(
                                      width: 65,
                                      height: 25,
                                      child: Center(
                                        child: TextFormField(
                                          focusNode: _disAmtFocusNode,
                                          onEditingComplete: () {
                                            print(
                                                'discountAmount: ${discountAmountController.text}');
                                            FocusScope.of(context).requestFocus(
                                                _disPercFocusNode);
                                          },
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .grey), // Border color when enabled
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 9.0,
                                              horizontal: 9.0,
                                            ),
                                          ),
                                          controller:
                                              discountPercentageController,
                                          onChanged: (value) {
                                            if (gstType == 'Including') {
                                              calculateDiscountAmountInclude();
                                            } else if (gstType == 'Excluding') {
                                              calculateDiscountAmountExclude();
                                            } else if (gstType == 'NonGst') {
                                              calculateDisAmtNongst();
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                  ])
                                ]),
                            SizedBox(
                              width: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dis Amt:',
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 65,
                                      height: 25,
                                      child: Center(
                                        child: TextFormField(
                                          focusNode: _disPercFocusNode,
                                          onEditingComplete: () {
                                            print(
                                                'discountPerc: ${discountPercentageController.text}');
                                            FocusScope.of(context).requestFocus(
                                                _saveDetailsFocusNode);
                                          },
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .grey), // Border color when enabled
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 9.0,
                                                    horizontal: 9.0),
                                          ),
                                          controller: discountAmountController,
                                          onChanged: (value) {
                                            if (gstType == 'Including') {
                                              calculateDiscountPercentageInclude();
                                            } else if (gstType == 'Excluding') {
                                              calculateDiscountPercentageExclude();
                                            } else if (gstType == 'NonGst') {
                                              calculateDisPercentNongst();
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 150,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'RS.',
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                              width:
                                                  5), // Space before the vertical line
                                          Container(
                                            width:
                                                1, // Width of the vertical line
                                            height:
                                                30, // Height of the vertical line
                                            color: Colors
                                                .black, // Color of the vertical line
                                          ),
                                          SizedBox(
                                              width:
                                                  6), // Space after the vertical line
                                          Text(
                                            '${fitchfinalAmountController.text.isEmpty ? NumberFormat.currency(
                                                locale: 'en_IN',
                                                symbol: '₹',
                                              ).format(totalAmount) : fitchfinalAmountController.text}/-',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 40),
                            Container(
                              width: 100,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (selectedPaymentType == "Credit" &&
                                      cusNameController.text.isEmpty) {
                                    showAlert(context,
                                        "Customer name is required for credit payment type.");
                                    return;
                                  }
                                  await postSerialNumber();
                                  if (!(selectedPaymentType == "Credit")) {
                                    await incomeDetails();
                                  }
                                  String paidAmount =
                                      selectedPaymentType.toLowerCase() ==
                                              'credit'
                                          ? '0.0'
                                          : finalAmount.toStringAsFixed(2);

                                  await saveDetails(context, paidAmount);
                                  setState(() {
                                    // Reset the form fields
                                    tableNumberController.clear();
                                    itemsController.clear();
                                    discountAmountController.clear();
                                    finalAmountController.clear();
                                    scodeController.clear();
                                    cusNameController.clear();
                                    contactController.clear();
                                    discountPercentageController.clear();
                                    taxAmountController.clear();
                                    finalTaxableAmountController.clear();
                                    addressController.clear();
                                    selectedProducts
                                        .clear(); // Deselect products
                                    servantNames.clear();
                                    paymentTypes.clear();
                                  });
                                },
                                focusNode: _saveDetailsFocusNode,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue, // Text color
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15), // Padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded corners
                                  ),
                                ),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ]),
                    ),
                  ),
                )
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
