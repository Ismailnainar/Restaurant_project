import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Chart.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Exit",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          content: Text(
            "Are you sure you want to exit?",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(color: Colors.black)))),
              child: Text("Yes"),
              onPressed: () async {
                SystemNavigator.pop();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(color: Colors.black)))),
              child: Text(
                "No",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed =
            await _showExitConfirmationDialog(context) ?? false;
        return exitConfirmed;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: EdgeInsets.only(left: 5, top: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.home,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Dashboard", style: HeadingStyle),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Tooltip(
                                      message: "Shop Info",
                                      child: GestureDetector(
                                          onTap: () =>
                                              showShopInfoDialog(context),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Icon(
                                              Icons.account_circle,
                                              size: 22,
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Tooltip(
                                      message: "Software Version",
                                      child: GestureDetector(
                                        onTap: () => _showVersionInfo(context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Icon(
                                            Icons.notifications,
                                            size: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Tooltip(
                                      message: "Help",
                                      child: GestureDetector(
                                          onTap: () =>
                                              _showCompanyDetailsDialog(
                                                  context),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Icon(
                                              Icons.help,
                                              size: 22,
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (Responsive.isDesktop(context))
                          dashboarddesktopview(),
                        if (Responsive.isMobile(context) ||
                            Responsive.isTablet(context))
                          dashboardmobileTabletview()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showVersionInfo(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String? cusid = await SharedPrefs.getCusId();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          width: 250,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/imgs/software-engineer.png',
                      ),
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome !!!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.blueAccent.shade100),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: 'Software Version ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: version,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Your software will expire in 30 days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => PlanSelectionPage(cusid!)),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text('Upgrade'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class dashboarddesktopview extends StatefulWidget {
  const dashboarddesktopview({Key? key}) : super(key: key);

  @override
  State<dashboarddesktopview> createState() => _dashboarddesktopviewState();
}

class _dashboarddesktopviewState extends State<dashboarddesktopview> {
  @override
  void initState() {
    super.initState();
    fetchSalesTotalAmount();
    fetchOrderSalesTotalAmount();
    fetchPurchaseTotalAmount();
    fetchVendorSalesTotalAmount();
  }

  int totalSalesAmount = 0;

  Future<void> fetchSalesTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    // Assuming the JSON response is an object
    if (data is Map<String, dynamic>) {
      var salesFinalAmountToday = data['today_total_sales'];
      double amount = salesFinalAmountToday as double;
      totalSalesAmount = amount.toInt();
    }

    if (mounted) {
      // Check if the widget is still mounted before calling setState
      setState(() {
        totalSalesAmount = totalSalesAmount;
      });
    }
  }

  int totalOrderSalesAmount = 0;

  Future<void> fetchOrderSalesTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    // Assuming the JSON response is an object
    if (data is Map<String, dynamic>) {
      var OrdersalesFinalAmountToday = data['today_order_sales'];
      double amount = OrdersalesFinalAmountToday as double;
      totalOrderSalesAmount = amount.toInt();
    }

    if (mounted) {
      // Check if the widget is still mounted before calling setState
      setState(() {
        totalOrderSalesAmount = totalOrderSalesAmount;
      });
    }
  }

  int totalPurchaseAmount = 0;

  Future<void> fetchPurchaseTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    if (data is Map<String, dynamic>) {
      var purchaseFinalAmountToday = data['today_purchase_sales'];
      double amount = purchaseFinalAmountToday as double;
      totalPurchaseAmount = amount.toInt();
    }

    if (mounted) {
      setState(() {
        totalPurchaseAmount = totalPurchaseAmount;
      });
    }
  }

  int totalVendorSalesAmount = 0;

  Future<void> fetchVendorSalesTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    if (data is Map<String, dynamic>) {
      var VendorsalesFinalAmountToday = data['today_vendor_sales'];
      double amount = VendorsalesFinalAmountToday as double;
      totalVendorSalesAmount = amount.toInt();
    }

    if (mounted) {
      setState(() {
        totalVendorSalesAmount = totalVendorSalesAmount;
      });
    }
  }

  KeyEventResult _onKeyPressed(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyLabel) {
        case 'F1':
          _openProductDetails();
          return KeyEventResult.handled;
        case 'F2':
          _openPurchase();
          return KeyEventResult.handled;
        case 'F3':
          _openSales();
          return KeyEventResult.handled;
        case 'F4':
          _openOrderSales();
          return KeyEventResult.handled;
        case 'F5':
          _openVendorSales();
          return KeyEventResult.handled;

        case 'F6':
          _openExpense();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _openProductDetails() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 1200,
            height: 800,
            padding: EdgeInsets.all(16),
            child: Stack(
              children: [
                // AddProductDetailsPage(),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 23),
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
  }

  void _openPurchase() {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => NewPurchaseEntryPage(),
    //   ),
    // );
  }

  void _openSales() {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => NewSalesEntry(
    //             Fianlamount: TextEditingController(),
    //             cusnameController: TextEditingController(),
    //             TableNoController: TextEditingController(),
    //             cusaddressController: TextEditingController(),
    //             cuscontactController: TextEditingController(),
    //             scodeController: TextEditingController(),
    //             snameController: TextEditingController(),
    //             TypeController: TextEditingController(),
    //             salestableData: [],
    //           )),
    // );
  }

  void _openOrderSales() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 1200,
            height: 800,
            padding: EdgeInsets.all(16),
            child: Stack(
              children: [
                // NewOrderSalesEntry(),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 23),
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
  }

  void _openVendorSales() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 1200,
            height: 800,
            padding: EdgeInsets.all(16),
            child: Stack(
              children: [
                // NewVendorSalesEntry(),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 23),
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
  }

  void _openExpense() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 1200,
            height: 800,
            padding: EdgeInsets.all(16),
            child: Stack(
              children: [
                // ExpenseEntry(),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 23),
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              // color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Row(
                    children: [
                      Center(
                        child: Container(
                          height: 350,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: buildMobileLayout(context),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 350,
                          width: MediaQuery.of(context).size.width * 0.31,
                          // color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 0, left: 10),
                                child: Text(
                                  "Last 7 Days Income",
                                  style: commonLabelTextStyle,
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 0),
                                child: IncomeGraphDashboard(),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Focus(
                    autofocus: true,
                    onKey: _onKeyPressed,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: Responsive.isDesktop(context)
                              ? EdgeInsets.only(right: 10, left: 25)
                              : EdgeInsets.only(right: 10, left: 25, top: 15),
                          child: Text("Order Details",
                              style: commonLabelTextStyle),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          DataTableExample(),
                                        ],
                                      ),
                                      Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // More rounded design
                                        ),
                                        shadowColor: Colors.grey.shade300,
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  'Quick Access',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey
                                                        .shade700, // Darker and more professional font
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              _buildQuickAccessRow([
                                                _buildGradientButton(
                                                    'Add Product F1',
                                                    Icons.fastfood,
                                                    const Color(0xFF33B1F1),
                                                    _openProductDetails),
                                                SizedBox(width: 5),
                                                _buildGradientButton(
                                                    'Purchase F2',
                                                    Icons.shopping_cart,
                                                    Colors.pinkAccent,
                                                    _openPurchase),
                                              ]),
                                              SizedBox(height: 12),
                                              _buildQuickAccessRow([
                                                _buildGradientButton(
                                                    'Sales F3',
                                                    Icons.shopify,
                                                    Colors.tealAccent.shade700,
                                                    _openSales),
                                                SizedBox(width: 5),
                                                _buildGradientButton(
                                                    'Order Sales F4',
                                                    Icons.shopping_bag,
                                                    Colors.deepPurpleAccent,
                                                    _openOrderSales),
                                              ]),
                                              SizedBox(height: 12),
                                              _buildQuickAccessRow([
                                                _buildGradientButton(
                                                    'Vendor Sales F5',
                                                    Icons.storefront_outlined,
                                                    Colors
                                                        .orangeAccent.shade400,
                                                    _openVendorSales),
                                                SizedBox(width: 5),
                                                _buildGradientButton(
                                                    'Expense F6',
                                                    Icons.attach_money,
                                                    Colors.greenAccent.shade700,
                                                    _openExpense),
                                              ]),
                                            ],
                                          ),
                                        ),
                                      )
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
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Column(
                  children: [
                    TopSellingCardview(),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    ExpensesChartView(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }

  Widget _buildGradientButton(
      String label, IconData icon, Color borderColor, VoidCallback onPressed) {
    return GradientContainer(
      label: label,
      icon: icon,
      borderColor: borderColor,
      onPressed: onPressed,
      iconSize: 20, // Optional custom icon size
      textStyle: TextStyle(color: Colors.black), // Optional custom text style
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    // Example target amounts for progress calculation
    double salesTarget = 10000;
    double purchaseTarget = 10000;
    double orderSalesTarget = 10000;
    double vendorSalesTarget = 10000;

    // Calculate progress values dynamically based on actual amounts
    double salesProgress = totalSalesAmount / salesTarget;
    double purchaseProgress = totalPurchaseAmount / purchaseTarget;
    double orderSalesProgress = totalOrderSalesAmount / orderSalesTarget;
    double vendorSalesProgress = totalVendorSalesAmount / vendorSalesTarget;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCard(context, 'Today Sale', "₹ $totalSalesAmount",
                  Icons.shopify, Colors.pink, salesProgress),
              buildCard(context, 'Today Purchase', "₹ $totalPurchaseAmount",
                  Icons.shopping_cart, Colors.blue, purchaseProgress),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCard(
                  context,
                  'Today Order Sales',
                  "₹ $totalOrderSalesAmount",
                  Icons.local_shipping,
                  Colors.green,
                  orderSalesProgress),
              buildCard(
                  context,
                  'Today Vendor Sales',
                  "₹ $totalVendorSalesAmount",
                  Icons.store,
                  Colors.purple,
                  vendorSalesProgress),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, double progressValue) {
    return Container(
      height: 150, // Increased height for the progress bar
      width: Responsive.isMobile(context) || Responsive.isTablet(context)
          ? 250
          : MediaQuery.of(context).size.width * 0.14,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon inside a circle container with background color
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color, // Background color for the icon
                    ),
                    padding: const EdgeInsets.all(
                        10), // Padding inside the container
                    child: Icon(
                      icon,
                      size: 20, // Icon size
                      color: Colors.white, // Icon color
                    ),
                  ),
                  SizedBox(width: 10), // Space between the icon and text
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textStyle.copyWith(
                            fontSize: 14,
                          ), // Title style
                        ),
                        SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: commonLabelTextStyle.copyWith(
                            fontSize: 20,
                            color: const Color.fromARGB(
                                255, 34, 80, 117), // Subtitle style
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Linear progress bar
              LinearProgressIndicator(
                value: progressValue.clamp(
                    0.0, 1.0), // Clamp value between 0 and 1
                backgroundColor:
                    Colors.grey[300], // Background color of the bar
                valueColor: AlwaysStoppedAnimation<Color>(color), // Bar color
                minHeight: 6, // Height of the progress bar
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class dashboardmobileTabletview extends StatefulWidget {
  const dashboardmobileTabletview({Key? key}) : super(key: key);

  @override
  State<dashboardmobileTabletview> createState() =>
      _dashboardmobileTabletviewState();
}

class _dashboardmobileTabletviewState extends State<dashboardmobileTabletview> {
  @override
  void initState() {
    super.initState();
    fetchSalesTotalAmount();
    fetchOrderSalesTotalAmount();
    fetchVendorSalesTotalAmount();
    fetchPurchaseTotalAmount();
  }

  int totalSalesAmount = 0;

  Future<void> fetchSalesTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    // Assuming the JSON response is an object
    if (data is Map<String, dynamic>) {
      var salesFinalAmountToday = data['today_total_sales'];
      double amount = salesFinalAmountToday as double;
      totalSalesAmount = amount.toInt();
    }

    if (mounted) {
      // Check if the widget is still mounted before calling setState
      setState(() {
        totalSalesAmount = totalSalesAmount;
      });
    }
  }

  int totalOrderSalesAmount = 0;

  Future<void> fetchOrderSalesTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    // Assuming the JSON response is an object
    if (data is Map<String, dynamic>) {
      var OrdersalesFinalAmountToday = data['today_order_sales'];
      double amount = OrdersalesFinalAmountToday as double;
      totalOrderSalesAmount = amount.toInt();
    }

    if (mounted) {
      // Check if the widget is still mounted before calling setState
      setState(() {
        totalOrderSalesAmount = totalOrderSalesAmount;
      });
    }
  }

  int totalVendorSalesAmount = 0;

  Future<void> fetchVendorSalesTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    // Assuming the JSON response is an object
    if (data is Map<String, dynamic>) {
      var VendorsalesFinalAmountToday = data['today_vendor_sales'];
      double amount = VendorsalesFinalAmountToday as double;
      totalVendorSalesAmount = amount.toInt();
    }

    if (mounted) {
      // Check if the widget is still mounted before calling setState
      setState(() {
        totalVendorSalesAmount = totalVendorSalesAmount;
      });
    }
  }

  int totalPurchaseAmount = 0;

  Future<void> fetchPurchaseTotalAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardTodayRecordsView/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var data = json.decode(response.body);

    // Assuming the JSON response is an object
    if (data is Map<String, dynamic>) {
      var purchaseFinalAmountToday = data['today_purchase_sales'];
      double amount = purchaseFinalAmountToday as double;
      totalPurchaseAmount = amount.toInt();
    }

    if (mounted) {
      // Check if the widget is still mounted before calling setState
      setState(() {
        totalPurchaseAmount = totalPurchaseAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            // color: const Color.fromARGB(255, 240, 240, 240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      // height: 340,
                      // color: const Color.fromARGB(255, 255, 255, 255),
                      child: buildMobileLayout(context)),
                ),
                TopSellingCardview(),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Container(
                    height: 400,
                    width: MediaQuery.of(context).size.width * 0.74,
                    // color: Color.fromARGB(255, 255, 255, 255),
                    child: Column(
                      children: [
                        Padding(
                          padding: Responsive.isDesktop(context)
                              ? EdgeInsets.only(
                                  right: 10,
                                  left: 10,
                                )
                              : EdgeInsets.only(right: 10, left: 10, top: 15),
                          child: Text("Order Details",
                              style: commonLabelTextStyle),
                        ),
                        SingleChildScrollView(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 15, right: 8),
                          child: DataTableExample(),
                        )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    // width: MediaQuery.of(context).size.width * 1,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: Responsive.isDesktop(context)
                              ? EdgeInsets.only(
                                  right: 10,
                                  left: 10,
                                )
                              : EdgeInsets.only(right: 10, left: 10, top: 15),
                          child: Text("Last 7 Days Income",
                              style: commonLabelTextStyle),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: IncomeGraphDashboard(),
                        )),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    children: [ExpensesChartView()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    // Example target amounts for progress calculation
    double salesTarget = 10000;
    double purchaseTarget = 10000;
    double orderSalesTarget = 10000;
    double vendorSalesTarget = 10000;

    // Calculate progress values dynamically based on actual amounts
    double salesProgress = totalSalesAmount / salesTarget;
    double purchaseProgress = totalPurchaseAmount / purchaseTarget;
    double orderSalesProgress = totalOrderSalesAmount / orderSalesTarget;
    double vendorSalesProgress = totalVendorSalesAmount / vendorSalesTarget;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCard(context, 'Today Sale', "₹ $totalSalesAmount",
                  Icons.shopify, Colors.pink, salesProgress),
              buildCard(context, 'Today Purchase', "₹ $totalPurchaseAmount",
                  Icons.shopping_cart, Colors.blue, purchaseProgress),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCard(
                  context,
                  'Today Order Sales',
                  "₹ $totalOrderSalesAmount",
                  Icons.local_shipping,
                  Colors.green,
                  orderSalesProgress),
              buildCard(
                  context,
                  'Today Vendor Sales',
                  "₹ $totalVendorSalesAmount",
                  Icons.store,
                  Colors.purple,
                  vendorSalesProgress),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, double progressValue) {
    return Container(
      height: 150,
      width: Responsive.isMobile(context) || Responsive.isTablet(context)
          ? MediaQuery.of(context).size.width * 0.44
          : MediaQuery.of(context).size.width * 0.170,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon inside a circle container with background color
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color, // Background color for the icon
                    ),
                    padding: const EdgeInsets.all(
                        10), // Padding inside the container
                    child: Icon(
                      icon,
                      size: 20, // Icon size
                      color: Colors.white, // Icon color
                    ),
                  ),
                  SizedBox(width: 10), // Space between the icon and text
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textStyle.copyWith(
                            fontSize: 14,
                          ), // Title style
                        ),
                        SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: commonLabelTextStyle.copyWith(
                            fontSize: 20,
                            color: const Color.fromARGB(
                                255, 34, 80, 117), // Subtitle style
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Linear progress bar
              LinearProgressIndicator(
                value: progressValue.clamp(
                    0.0, 1.0), // Clamp value between 0 and 1
                backgroundColor:
                    Colors.grey[300], // Background color of the bar
                valueColor: AlwaysStoppedAnimation<Color>(color), // Bar color
                minHeight: 6, // Height of the progress bar
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: tableView());
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardOrderSalesDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['order_today_details'] != null) {
      var orderSalesDetails = jsonData['order_today_details'] as List;
      tableData = List<Map<String, dynamic>>.from(orderSalesDetails);
    }

    if (mounted) {
      setState(() {
        totalAmount = tableData.isNotEmpty
            ? double.parse(tableData.first['finalamount'].toString())
            : 0.0;
      });
    }
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: Responsive.isDesktop(context)
          ? EdgeInsets.only(
              left: 20,
              right: 20,
            )
          : EdgeInsets.only(
              left: 20,
              right: 20,
            ),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
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
            child: Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.40
                  : MediaQuery.of(context).size.width * 0.90,
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
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.blue.shade300,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
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
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                          height: Responsive.isDesktop(context) ? 25 : 30,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Final",
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
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Delivery",
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
                    int index = entry.key; // Get the index of the current entry
                    var data =
                        entry.value; // Get the data corresponding to this index
                    var cusname = data['cusname'].toString();
                    var contact = data['contact'].toString();
                    var finalamount = data['finalamount'].toString();
                    var deliverydate = data['deliverydate'].toString();

                    Color rowColor = index % 2 == 0
                        ? Color.fromARGB(224, 255, 255, 255)
                        : Color.fromARGB(255, 223, 225, 226);

                    final List<Color> dynamicColors = [
                      Colors.green.shade300,
                      Colors.pink.shade300,
                      Colors.purple.shade300,
                      Colors.yellow,
                      Colors.teal,
                      Colors.cyan,
                      Colors.brown,
                    ];

                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, right: 0, top: 5, bottom: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.grey.shade300, width: 2.0),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: dynamicColors[
                                          index % dynamicColors.length],
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      cusname,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.grey.shade300, width: 2.0),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  contact,
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
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.grey.shade300, width: 2.0),
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: dynamicColors[
                                          index % dynamicColors.length],
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      finalamount,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
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
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.grey.shade300, width: 2.0),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  deliverydate,
                                  textAlign: TextAlign.center,
                                  style: TableRowTextStyle,
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
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/imgs/delivery-man.png',
                              width: 50, // Adjust width as needed
                              height: 50, // Adjust height as needed
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                'No orders available to delivery!!!',
                                style: textStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                }
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class TopSellingCardview extends StatefulWidget {
  @override
  State<TopSellingCardview> createState() => _TopSellingCardviewState();
}

class _TopSellingCardviewState extends State<TopSellingCardview> {
  List<Map<String, dynamic>> topSellingItems = [];

  @override
  void initState() {
    super.initState();
    fetchTopSellingItems();
  }

  Future<void> fetchTopSellingItems() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/DashboardTopSelling/$cusid/';
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        dynamic fetchedItems = data['top_selling_items'];

        if (fetchedItems is List) {
          topSellingItems = List<Map<String, dynamic>>.from(fetchedItems);
          setState(() {});
        } else {
          print('Expected a List, but received: $fetchedItems');
        }
      } else {
        print(
            'Failed to fetch top selling items. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching top selling items: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 251, 251),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Container(
                padding: EdgeInsets.only(left: 10, top: 6, bottom: 6),
                color: Colors.green,
                child: Center(
                  child: Text(
                    'Top Selling Products',
                    style: commonWhiteStyle,
                  ),
                ),
              ),
            ),
            SizedBox(height: 9.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 6; i++) _buildCardWidget(i),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidget(int index) {
    String itemName = index < topSellingItems.length
        ? topSellingItems[index]['Itemname']
        : 'Not Available';

    // Only show image if the item is not "Not Available"
    String? itemImageAsset = itemName != 'Not Available'
        ? _getProductImage(index)
        : null; // Set to null for "Not Available"

    return SmallCard(
      name: itemName,
      imageUrl: itemImageAsset, // Pass null if "Not Available"
    );
  }

  // Helper method to get the correct image asset path
  String _getProductImage(int index) {
    const List<String> productImages = [
      'assets/imgs/thai-food.png',
      'assets/imgs/ramen.png',
      'assets/imgs/balanced-diet.png',
      'assets/imgs/bibimbap.png',
      'assets/imgs/salad.png',
      'assets/imgs/fried-rice.png',
    ];
    return productImages[index % productImages.length]; // Loop through images
  }
}

class SmallCard extends StatelessWidget {
  final String name;
  final String? imageUrl; // Allow imageUrl to be nullable

  SmallCard({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Color textColor = name == "Not Available" ? Colors.grey : maincolor;
    FontWeight fontWeight =
        name == "Not Available" ? FontWeight.normal : FontWeight.bold;

    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Card(
        elevation: 3.0,
        color: Colors.grey.shade100,
        child: Container(
          height:
              35.0, // Increased height for better centering of both image and text
          padding: EdgeInsets.all(4.0),
          child: Center(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align items to the start
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center items vertically
              children: [
                // Fixed size container for the image
                if (imageUrl != null)
                  Container(
                    width: 40.0, // Fixed width for consistent alignment
                    height: 40.0, // Fixed height for consistent alignment
                    alignment: Alignment.center,
                    child: Image.asset(
                      imageUrl!,
                      fit: BoxFit
                          .contain, // Ensure the image fits within the container
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to an icon or placeholder on error
                        return Icon(Icons.image_not_supported,
                            size: 40.0, color: Colors.grey);
                      },
                    ),
                  ),
                SizedBox(width: 8.0), // Space between the image and text
                // Fixed size container for the text
                Container(
                  constraints: BoxConstraints(
                      maxWidth: 150), // Limit text width if needed
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: textColor,
                      fontWeight: fontWeight,
                    ),
                    textAlign:
                        TextAlign.start, // Text starts directly after the image
                    overflow:
                        TextOverflow.ellipsis, // Handle long text with ellipsis
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradientContainer extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color borderColor;
  final Function onPressed;
  final double iconSize;
  final TextStyle textStyle;

  const GradientContainer({
    Key? key,
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.onPressed,
    this.iconSize = 22, // Larger default icon size for a bolder look
    this.textStyle = const TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold), // Bold text style
  }) : super(key: key);

  @override
  _GradientContainerState createState() => _GradientContainerState();
}

class _GradientContainerState extends State<GradientContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onPressed(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 110,
          height: 60,
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    colors: [
                      widget.borderColor.withOpacity(0.8),
                      Colors.white.withOpacity(0.9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, widget.borderColor.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(15), // More rounded edges
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.borderColor.withOpacity(0.6),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: widget.borderColor,
                  size: widget.iconSize,
                ),
                SizedBox(height: 6),
                Text(
                  widget.label,
                  style: widget.textStyle.copyWith(
                    fontSize: 14, // Slightly bigger font size for readability
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// For help section to company

void _showCompanyDetailsDialog(BuildContext context) async {
  try {
    final response = await http.get(Uri.parse('$IpAddress/CompanyDetails/'));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body) as List;
      final companyData = data[0] as Map<String, dynamic>;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: 350,
              child: CompanyDetailsForm(
                companyData: companyData,
              ),
            ),
          );
        },
      );
    } else {
      print(
          'Failed to load company details. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching company details: $e');
  }
}

class CompanyDetailsForm extends StatelessWidget {
  final Map<String, dynamic> companyData;

  CompanyDetailsForm({required this.companyData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Close',
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.black, size: 25),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/imgs/buyp.png',
              width: 100,
            ),
            SizedBox(height: 20),
            _buildTextField('Technology Partner', companyData['companyname']),
            SizedBox(height: 16),
            _buildTextField('Address', companyData['address']),
            SizedBox(height: 16),
            _buildTextField('Contact', companyData['contact']),
            SizedBox(height: 16),
            _buildTextField('Mail ID', companyData['mailid']),
            SizedBox(height: 16),
            _buildTextField('Website', companyData['website']),
            SizedBox(height: 20),
            _buildSocialMediaIcons(companyData),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? value) {
    bool isAddressField = label == 'Address';

    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      maxLines: isAddressField ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: const Color.fromARGB(255, 70, 68, 68), fontSize: 16),
        hintText: value,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      style: commonLabelTextStyle,
    );
  }

  Widget _buildSocialMediaIcons(Map<String, dynamic> companyData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
            'assets/imgs/instagram.png', companyData['instagramid']),
        SizedBox(width: 10),
        _buildSocialIcon('assets/imgs/facebook.png', companyData['facebook']),
        SizedBox(width: 10),
        _buildSocialIcon('assets/imgs/twitter.png', companyData['twitterid']),
        SizedBox(width: 10),
        _buildSocialIcon('assets/imgs/linkedin.png', companyData['linkedin']),
        SizedBox(width: 10),
        _buildSocialIcon('assets/imgs/youtube.png', companyData['youtube']),
      ],
    );
  }

  Widget _buildSocialIcon(String assetPath, String? url) {
    return GestureDetector(
      onTap: () async {
        if (url != null) {
          // Ensure the URL starts with 'http://' or 'https://'
          final Uri uri = Uri.tryParse(url) ?? Uri();
          if (uri.isAbsolute && await canLaunchUrl(uri)) {
            try {
              await launchUrl(uri);
            } catch (e) {
              print('Could not launch $url: $e');
            }
          } else {
            print('Invalid URL: $url');
          }
        } else {
          print('No URL provided');
        }
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// For Update ShopInfo

class ShopInfoDialog extends StatefulWidget {
  @override
  _ShopInfoDialogState createState() => _ShopInfoDialogState();
}

class _ShopInfoDialogState extends State<ShopInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _shopNameController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _cityPincodeController = TextEditingController();
  TextEditingController _gstNoController = TextEditingController();
  TextEditingController _fssaiController = TextEditingController();

  int? _shopId;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      if (cusid == null || cusid.isEmpty) {
        print('Customer ID is null or empty');
        return;
      }

      final response = await http.get(Uri.parse('$IpAddress/Shopinfo/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] is List && data['results'].isNotEmpty) {
          final shop = (data['results'] as List).firstWhere(
            (shop) => shop['cusid'] == cusid,
            orElse: () => null,
          );

          if (shop != null) {
            setState(() {
              _shopId = shop['id'];
              _shopNameController.text = shop['shopname'] ?? 'No data';
              _contactController.text = shop['contact'] ?? 'No data';
              _addressController.text = shop['doorno'] ?? 'No data';
              _areaController.text = shop['area'] ?? 'No data';
              _cityPincodeController.text =
                  '${shop['city'] ?? 'No data'} - ${shop['pincode'] ?? 'No data'}';
              _gstNoController.text = shop['gstno'] ?? 'No data';
              _fssaiController.text = shop['fssai'] ?? 'No data';

              if (shop['shoplogo'] != null) {
                _imageUrl = shop['shoplogo'];
              }
            });
          } else {
            print('No shop details found for the given cusid');
          }
        } else {
          print('No shop details available');
        }
      } else {
        throw Exception('Failed to load shop details');
      }
    } catch (e) {
      print('Error fetching shop details: $e');
    }
  }

  String base64Image = '';

  Future<void> _updateShopDetails() async {
    if (!_formKey.currentState!.validate()) {
      print('Form is not valid');
      return;
    }

    String? cusid = await SharedPrefs.getCusId();

    if (_shopId == null) {
      print('Shop ID is null');
      return;
    }

    // Check if a new image is selected
    if (_image != null) {
      try {
        Uint8List imageBytes = await _image!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      } catch (e) {
        print('Error encoding image: $e');
        return;
      }
    }

    // Use the old image URL if no new image is selected
    String finalBase64Image = base64Image.isNotEmpty
        ? base64Image
        : (_imageUrl != null
            ? _imageUrl!
            : 'iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAYAAAD0eNT6AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAACAASURBVHic7N13eFRV');

    // Ensure base64 padding for the image
    finalBase64Image =
        finalBase64Image.padRight((finalBase64Image.length + 3) ~/ 4 * 4, '=');

    final updatedData = {
      'cusid': cusid,
      'shopname': _shopNameController.text,
      'contact': _contactController.text,
      'doorno': _addressController.text,
      'area': _areaController.text,
      'city': _cityPincodeController.text.split(' - ').first,
      'pincode': _cityPincodeController.text.split(' - ').last,
      'gstno': _gstNoController.text,
      'fssai': _fssaiController.text,
      'shoplogo': finalBase64Image, // Include the image in the update
    };

    try {
      final response = await http.put(
        Uri.parse('$IpAddress/Shopinfo/$_shopId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Shop details updated successfully');
        Navigator.of(context).pop(); // Close the dialog after saving
        // Optionally refresh the details
        _fetchShopDetails();
      } else {
        print('Failed to update shop details: ${response.body}');
        throw Exception(
            'Failed to update shop details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating shop details: $e');
    }
  }

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
                  'Upload Image',
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
                  'Would you like to update the image?',
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
                        setState(() {
                          _isImageUploaded = true;
                          ImageUpdateMode = false;
                        });
                        Navigator.pop(context);
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
                      child: Text(
                        '✍ Update',
                        style: commonWhiteStyle,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        constraints: BoxConstraints(maxHeight: 600),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Close',
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.black, size: 25),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Stack(
                  children: [
                    ClipOval(
                      child: _image != null
                          ? kIsWeb
                              ? Image.network(
                                  _image!.path,
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                )
                              : Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                )
                          : _imageUrl != null
                              ? Image.memory(
                                  base64Decode(_imageUrl!.split(',').last),
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            getImage();
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      _buildTextField(
                          'Shop Name', _shopNameController, Icons.store),
                      _buildTextField(
                          'Contact', _contactController, Icons.phone),
                      _buildTextField(
                          'Address', _addressController, Icons.location_on,
                          maxLines: 2),
                      _buildTextField(
                          'Area', _areaController, Icons.location_city),
                      _buildTextField('City-Pincode', _cityPincodeController,
                          Icons.pin_drop),
                      _buildTextField(
                          'GST No', _gstNoController, Icons.business_center),
                      _buildTextField(
                          'FSSAI No', _fssaiController, Icons.verified_user),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _updateShopDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                ),
                child: Text('Save', style: commonWhiteStyle),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String labelText, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }
}

void showShopInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ShopInfoDialog();
    },
  );
}
