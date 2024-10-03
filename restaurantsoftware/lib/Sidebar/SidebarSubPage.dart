import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/LoginAndReg/Login.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Purchase/NewPurchaseEntry.dart';
import 'package:restaurantsoftware/QuickSales/QuickSales.dart';
import 'package:restaurantsoftware/Sales/NewSales.dart';

import 'package:shared_preferences/shared_preferences.dart';

class menusitem extends StatefulWidget {
  final Function(String) onItemSelected;
  final bool settingsproductcategory;
  final bool settingsproductdetails;
  final bool settingsgstdetails;
  final bool settingsstaffdetails;
  final bool settingspaymentmethod;
  final bool settingsaddsalespoint;
  final bool settingsprinterdetails;
  final bool settingslogindetails;
  final bool purchasenewpurchase;
  final bool purchaseeditpurchase;
  final bool purchasepaymentdetails;
  final bool purchaseproductcategory;
  final bool purchaseproductdetails;
  final bool purchaseCustomer;
  final bool salesnewsales;
  final bool saleseditsales;
  final bool salespaymentdetails;
  final bool salescustomer;
  final bool salestablecount;
  final bool quicksales;
  final bool ordersalesnew;
  final bool ordersalesedit;
  final bool ordersalespaymentdetails;
  final bool vendorsalesnew;
  final bool vendorsalespaymentdetails;
  final bool vendorcustomer;
  final bool stocknew;
  final bool wastageadd;
  final bool kitchenusagesentry;
  final bool report;
  final bool daysheetincomeentry;
  final bool daysheetexpenseentry;
  final bool daysheetexepensescategory;
  final bool graphsales;

  const menusitem({
    Key? key,
    required this.onItemSelected,
    required this.settingsproductcategory,
    required this.settingsproductdetails,
    required this.settingsgstdetails,
    required this.settingsstaffdetails,
    required this.settingspaymentmethod,
    required this.settingsaddsalespoint,
    required this.settingsprinterdetails,
    required this.settingslogindetails,
    required this.purchasenewpurchase,
    required this.purchaseeditpurchase,
    required this.purchasepaymentdetails,
    required this.purchaseproductcategory,
    required this.purchaseproductdetails,
    required this.purchaseCustomer,
    required this.salesnewsales,
    required this.saleseditsales,
    required this.salespaymentdetails,
    required this.salescustomer,
    required this.salestablecount,
    required this.quicksales,
    required this.ordersalesnew,
    required this.ordersalesedit,
    required this.ordersalespaymentdetails,
    required this.vendorsalesnew,
    required this.vendorsalespaymentdetails,
    required this.vendorcustomer,
    required this.stocknew,
    required this.wastageadd,
    required this.kitchenusagesentry,
    required this.report,
    required this.daysheetincomeentry,
    required this.daysheetexpenseentry,
    required this.daysheetexepensescategory,
    required this.graphsales,
  }) : super(key: key);

  @override
  State<menusitem> createState() => _menusitemState();
}

class _menusitemState extends State<menusitem> {
  bool _isExpanded = false;
  bool _isExpandedSales = false;
  bool _isExpandedQuickSales = false;
  bool _isExpandedHome = false;
  bool _isExpandedPurchase = false;
  bool _isExpandedOrderSales = false;
  bool _isExpandedVendorSales = false;
  bool _isExpandedStock = false;
  bool _isExpandedWastage = false;
  bool _isExpandedKitchen = false;
  bool _isExpandedReport = false;
  bool _isExpandedDaySheet = false;
  bool _isExpandedGraph = false;
  bool _isExpandedLogout = false;

  bool _isHoversettings = false;
  bool _isHoversales = false;
  bool _isHoverpurchase = false;
  bool _isHoverOrderSales = false;
  bool _isHoverVendorSales = false;
  bool _isHoverStock = false;
  bool _isHoverWastage = false;
  bool _isHoverKitchen = false;
  bool _isHoverReport = false;
  bool _isHoverHome = false;
  bool _isHoverDaySheet = false;
  bool _isHoverGraph = false;
  bool _isHoverLogout = false;
  bool _isHoverQuicksales = false;

  bool _isExpandedSubitems = false;
  String _selectedDashboardItem = '';

  String? cusid;
  @override
  void initState() {
    super.initState();
    _getCusId();
  }

  // String? cusid = await SharedPrefs.getCusId();
  Future<void> _getCusId() async {
    String? id = await SharedPrefs.getCusId();
    setState(() {
      cusid = id;
    });
  }

  bool get _isAnySettingsTrue {
    return widget.settingsproductcategory ||
        widget.settingsproductdetails ||
        widget.settingsgstdetails ||
        widget.settingsstaffdetails ||
        widget.settingspaymentmethod ||
        widget.settingsaddsalespoint ||
        widget.settingsprinterdetails ||
        widget.settingslogindetails;
  }

  bool get _isAnysalesTrue {
    return widget.salesnewsales ||
        widget.saleseditsales ||
        widget.salescustomer ||
        widget.salespaymentdetails ||
        widget.salestablecount;
  }

  bool get _isAnyPurchaseTrue {
    return widget.purchasenewpurchase ||
        widget.purchaseeditpurchase ||
        widget.purchaseCustomer ||
        widget.purchasepaymentdetails ||
        widget.purchaseproductcategory ||
        widget.purchaseproductcategory;
  }

  bool get _isAnyOrderSalesTrue {
    return widget.ordersalesedit ||
        widget.ordersalesnew ||
        widget.ordersalespaymentdetails;
  }

  bool get _isAnyVendorSalesTrue {
    return widget.vendorsalesnew ||
        widget.vendorsalespaymentdetails ||
        widget.vendorcustomer;
  }

  bool get _isAnyDaySheetTrue {
    return widget.daysheetincomeentry ||
        widget.daysheetexpenseentry ||
        widget.daysheetexepensescategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 34, 59),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    'assets/imgs/buyp_insta.png',
                    height: 35,
                    width: 35,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    'assets/imgs/buyp.png',
                    height: 55,
                    width: 80,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 5, left: 10),
                  //   child: RichText(
                  //     text: TextSpan(
                  //       children: <TextSpan>[
                  //         TextSpan(
                  //           text: 'B',
                  //           style: TextStyle(
                  //               fontSize: 22,
                  //               color: Colors.blue,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //         TextSpan(
                  //           text: 'U',
                  //           style: TextStyle(
                  //               fontSize: 22,
                  //               color: Colors.purple,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //         TextSpan(
                  //           text: 'Y',
                  //           style: TextStyle(
                  //               fontSize: 22,
                  //               color: Colors.yellow,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //         TextSpan(
                  //           text: 'P',
                  //           style: TextStyle(
                  //               fontSize: 22,
                  //               color: Colors.red,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "$cusid",
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade300),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.grey[500],
            ),
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoverHome = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoverHome = false;
                });
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpandedHome = !_isExpandedHome;
                    _isExpanded = false;
                    _isExpandedPurchase = false;
                    _isExpandedSales = false;
                    _isExpandedOrderSales = false;
                    _isExpandedVendorSales = false;
                    _isExpandedStock = false;
                    _isExpandedReport = false;
                    _isExpandedWastage = false;
                    _isExpandedKitchen = false;
                    _isExpandedDaySheet = false;
                    _isExpandedGraph = false;
                    _isExpandedLogout = false;

                    if (!_isExpandedHome) {
                      _isExpandedSubitems = false;
                    }
                  });
                  widget.onItemSelected("Dashboard");
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isHoverHome ? sidebarselect : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isExpandedHome
                            ? (isDarkTheme
                                ? sidebarselect.withOpacity(0.3)
                                : sidebarselect.withOpacity(0.3))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
                                Icon(
                                  Icons.dashboard_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverHome
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedHome
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedHome
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  "Dashboard",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDarkTheme
                                        ? (_isHoverHome
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedHome
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedHome
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isExpandedHome) ...[
              _buildHomeList(),
            ],

            if (_isAnySettingsTrue)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoversettings = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoversettings = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      _isExpandedSales = false;
                      _isExpandedPurchase = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedHome = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      _isExpandedSubitems = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoversettings
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpanded
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.settings,
                                    size: 13,
                                    color: isDarkTheme
                                        ? (_isHoversettings
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpanded
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpanded
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Settings",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoversettings
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpanded
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpanded
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoversettings
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpanded
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpanded
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpanded) ...[
              _buildDashboardList(),
            ],

            if (_isAnyPurchaseTrue)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverpurchase = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverpurchase = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedPurchase = !_isExpandedPurchase;
                      _isExpanded = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      _isExpandedKitchen = false;
                      _isExpandedHome = false;

                      if (!_isExpandedPurchase) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverpurchase
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedPurchase
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverpurchase
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedPurchase
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedPurchase
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Purchase",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverpurchase
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedPurchase
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedPurchase
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedPurchase
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverpurchase
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedPurchase
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedPurchase
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedPurchase) ...[
              _buildPurchaseList(),
            ],

            if (_isAnysalesTrue)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoversales = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoversales = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedSales = !_isExpandedSales;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isHoverReport = false;
                      _isExpandedHome = false;

                      if (!_isExpandedSales) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _isHoversales ? sidebarselect : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedSales
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.shopify,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoversales
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedSales
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedSales
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Sales",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoversales
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedSales
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedSales
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedSales
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoversales
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedSales
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedSales
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedSales) ...[
              _buildSalesList(),
            ],

            if (widget.quicksales)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverQuicksales = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverQuicksales = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedQuickSales = !_isExpandedQuickSales;
                      _isExpanded = false;
                      _isExpandedSales = false;
                      _isExpandedPurchase = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isHoverReport = false;
                      _isExpandedHome = false;

                      if (!_isExpandedQuickSales) {
                        _isExpandedSubitems = false;
                      }
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuickSalesMainPage()),
                    );

                    // widget.onItemSelected("Quick Sales");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverQuicksales
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedQuickSales
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.shop,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverQuicksales
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedQuickSales
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedQuickSales
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Quick Sales",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverQuicksales
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedQuickSales
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedQuickSales
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedQuickSales) ...[
              _buildQuickSalesList(),
            ],

            if (_isAnyOrderSalesTrue)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverOrderSales = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverOrderSales = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedOrderSales = !_isExpandedOrderSales;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      _isExpandedHome = false;

                      if (!_isExpandedOrderSales) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverOrderSales
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedOrderSales
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverOrderSales
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedOrderSales
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedOrderSales
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Order Sales",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverOrderSales
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedOrderSales
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedOrderSales
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedOrderSales
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverOrderSales
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedOrderSales
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedOrderSales
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedOrderSales) ...[
              _buildOrderSalesList(),
            ],

            if (_isAnyVendorSalesTrue)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverVendorSales = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverVendorSales = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedVendorSales = !_isExpandedVendorSales;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedDaySheet = false;
                      _isExpandedHome = false;

                      _isExpandedGraph = false;

                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      if (!_isExpandedVendorSales) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverVendorSales
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedVendorSales
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverVendorSales
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedVendorSales
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedVendorSales
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Vendor Sales",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverVendorSales
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedVendorSales
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedVendorSales
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedVendorSales
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverVendorSales
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedVendorSales
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedVendorSales
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedVendorSales) ...[
              _buildVendorSalesList(),
            ],

            if (widget.stocknew)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverStock = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverStock = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedStock = !_isExpandedStock;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedHome = false;

                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      if (!_isExpandedStock) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _isHoverStock ? sidebarselect : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedStock
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.shopping_basket_rounded,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverStock
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedStock
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedStock
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Stock",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverStock
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedStock
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedStock
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedStock
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverStock
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedStock
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedStock
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedStock) ...[
              _buildStockList(),
            ],

            if (widget.wastageadd)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverWastage = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverWastage = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedWastage = !_isExpandedWastage;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedKitchen = false;
                      _isExpandedHome = false;

                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      if (!_isExpandedWastage) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverWastage
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedWastage
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverWastage
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedWastage
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedWastage
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Wastage",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverWastage
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedWastage
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedWastage
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedWastage
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverWastage
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedWastage
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedWastage
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedWastage) ...[
              _buildWastageList(),
            ],

            if (widget.kitchenusagesentry)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverKitchen = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverKitchen = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedKitchen = !_isExpandedKitchen;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedHome = false;

                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isHoverReport = false;
                      if (!_isExpandedKitchen) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverKitchen
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedKitchen
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.restaurant,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverKitchen
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedKitchen
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedKitchen
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Kitchen",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverKitchen
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedKitchen
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedKitchen
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedKitchen
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverKitchen
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedKitchen
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedKitchen
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedKitchen) ...[
              _buildKitchenList(),
            ],

            if (widget.report)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverReport = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverReport = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedReport = !_isExpandedReport;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedHome = false;

                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedKitchen = false;
                      _isExpandedDaySheet = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      if (!_isExpandedReport) {
                        _isExpandedSubitems = false;
                      }
                    });
                    widget.onItemSelected("Report");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _isHoverReport ? sidebarselect : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedReport
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10),
                              Icon(
                                Icons.file_copy,
                                size: 15,
                                color: isDarkTheme
                                    ? (_isHoverReport
                                        ? Colors.black
                                        : sidebartext)
                                    : (isDarkTheme
                                        ? (_isExpandedReport
                                            ? sidebartext
                                            : maincolor)
                                        : (_isExpandedReport
                                            ? Colors.black
                                            : Colors.black)),
                              ),
                              SizedBox(width: 15),
                              Text(
                                "Report",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: isDarkTheme
                                      ? (_isHoverReport
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedReport
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedReport
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedReport) ...[
              _buildReportList(),
            ],

            if (_isAnyDaySheetTrue)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverDaySheet = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverDaySheet = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedDaySheet = !_isExpandedDaySheet;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedHome = false;

                      _isExpandedKitchen = false;
                      _isExpandedGraph = false;
                      _isExpandedLogout = false;
                      _isExpandedReport = false;
                      if (!_isExpandedDaySheet) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHoverDaySheet
                            ? sidebarselect
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedDaySheet
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.calendar_month,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverDaySheet
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedDaySheet
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedDaySheet
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "DaySheet",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverDaySheet
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedDaySheet
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedDaySheet
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedDaySheet
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverDaySheet
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedDaySheet
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedDaySheet
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedDaySheet) ...[
              _buildDaySheetList(),
            ],

            if (widget.graphsales)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverGraph = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverGraph = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedGraph = !_isExpandedGraph;
                      _isExpanded = false;
                      _isExpandedPurchase = false;
                      _isExpandedSales = false;
                      _isExpandedOrderSales = false;
                      _isExpandedVendorSales = false;
                      _isExpandedHome = false;

                      _isExpandedStock = false;
                      _isExpandedWastage = false;
                      _isExpandedDaySheet = false;
                      _isExpandedKitchen = false;
                      _isExpandedReport = false;

                      _isExpandedLogout = false;
                      if (!_isExpandedGraph) {
                        _isExpandedSubitems = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _isHoverGraph ? sidebarselect : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isExpandedGraph
                              ? (isDarkTheme
                                  ? sidebarselect.withOpacity(0.3)
                                  : sidebarselect.withOpacity(0.3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.stacked_bar_chart,
                                    size: 15,
                                    color: isDarkTheme
                                        ? (_isHoverGraph
                                            ? Colors.black
                                            : sidebartext)
                                        : (isDarkTheme
                                            ? (_isExpandedGraph
                                                ? sidebartext
                                                : maincolor)
                                            : (_isExpandedGraph
                                                ? Colors.black
                                                : Colors.black)),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Graph",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkTheme
                                          ? (_isHoverGraph
                                              ? Colors.black
                                              : sidebartext)
                                          : (isDarkTheme
                                              ? (_isExpandedGraph
                                                  ? sidebartext
                                                  : maincolor)
                                              : (_isExpandedGraph
                                                  ? Colors.black
                                                  : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  _isExpandedGraph
                                      ? Icons.keyboard_arrow_down_outlined
                                      : Icons.keyboard_arrow_up_outlined,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverGraph
                                          ? Colors.black
                                          : sidebartext)
                                      : (isDarkTheme
                                          ? (_isExpandedGraph
                                              ? sidebartext
                                              : maincolor)
                                          : (_isExpandedGraph
                                              ? Colors.black
                                              : Colors.black)),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isExpandedGraph) ...[
              _buildGraphist(),
            ],
            InkWell(
              onTap: () {
                setState(() {
                  _isExpandedLogout = !_isExpandedLogout;
                  _isExpanded = false;
                  _isExpandedPurchase = false;
                  _isExpandedSales = false;
                  _isExpandedOrderSales = false;
                  _isExpandedVendorSales = false;
                  _isExpandedHome = false;
                  _isExpandedStock = false;
                  _isExpandedWastage = false;
                  _isExpandedDaySheet = false;
                  _isExpandedKitchen = false;
                  _isExpandedReport = false;
                  _isExpandedGraph = false;

                  if (!_isExpandedLogout) {
                    _isExpandedSubitems = false;
                  }
                });
                if (_isExpandedLogout) {
                  showLogoutDialog(context);
                }
              },
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHoverLogout = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHoverLogout = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          _isHoverLogout ? sidebarselect : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isExpandedLogout
                            ? (isDarkTheme
                                ? sidebarselect.withOpacity(0.3)
                                : sidebarselect.withOpacity(0.3))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
                                Icon(
                                  Icons.logout,
                                  size: 15,
                                  color: isDarkTheme
                                      ? (_isHoverLogout
                                          ? Colors.black
                                          : sidebartext)
                                      : (_isExpandedLogout
                                          ? Colors.black
                                          : Colors.black),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDarkTheme
                                        ? (_isHoverLogout
                                            ? Colors.black
                                            : sidebartext)
                                        : (_isExpandedLogout
                                            ? Colors.black
                                            : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Padding(
            //   padding:
            //       const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       IconButton(
            //           onPressed: () {
            //             showLogoutDialog(context);
            //           },
            //           icon: Icon(Icons.logout, color: sidebartext, size: 15)),
            //       Text(
            //         'Logout',
            //         style: TextStyle(fontSize: 14, color: sidebartext),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(
            //   height: 15,
            // ),

            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Icon(
                  isDarkTheme ? Icons.nightlight_round : Icons.wb_sunny,
                  size: 20,
                  color: isDarkTheme ? sidebartext : maincolor,
                ),
                SizedBox(width: 8),
                Text(
                  isDarkTheme ? "Dark Mode" : "Light Mode",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDarkTheme ? sidebartext : maincolor,
                  ),
                ),
                SizedBox(width: 2),
                Switch(
                  value: isDarkTheme,
                  onChanged: (value) {
                    setState(() {
                      isDarkTheme = !isDarkTheme; // Toggle the value
                    });
                  },
                  activeColor: Colors.green,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHomeList() {
    return Column(
      children: [
        //_buildDashboardListItem(Icons.home, "Pro ", () {})
      ],
    );
  }

  Widget _buildDashboardList() {
    return Column(
      children: [
        if (widget.settingsproductcategory)
          _buildDashboardListItem(Icons.home, "Product Catogory ", () {
            _handleSubMenuItemSelected("Product Catogory ");
            widget.onItemSelected("Settings Product Catogory ");
          }),
        if (widget.settingsproductdetails)
          _buildDashboardListItem(Icons.fastfood, "Product Details ", () {
            _handleSubMenuItemSelected("Product Details ");
            widget.onItemSelected("Settings Product Details ");
          }),
        if (widget.settingsgstdetails)
          _buildDashboardListItem(Icons.attach_money, "Gst Details", () {
            _handleSubMenuItemSelected("Gst Details");
            widget.onItemSelected("Settings Gst Details");
          }),
        if (widget.settingsstaffdetails)
          _buildDashboardListItem(Icons.person, "Staff Details", () {
            _handleSubMenuItemSelected("Staff Details");
            widget.onItemSelected("Settings Staff Details");
          }),
        if (widget.settingspaymentmethod)
          _buildDashboardListItem(Icons.payment, "Payment Method", () {
            _handleSubMenuItemSelected("Payment Method");
            widget.onItemSelected("Settings Payment Method");
          }),
        if (widget.settingsaddsalespoint)
          _buildDashboardListItem(Icons.add, "Add Sales Points", () {
            _handleSubMenuItemSelected("Add Sales Points");
            widget.onItemSelected("Add Sales Points");
          }),
        if (widget.settingsprinterdetails)
          _buildDashboardListItem(Icons.print, "Printer Details", () {
            _handleSubMenuItemSelected("Printer Details");
            widget.onItemSelected("Settings Printer Details");
          }),
        if (widget.settingslogindetails)
          _buildDashboardListItem(Icons.login, "Login Details", () {
            _handleSubMenuItemSelected("Login Details");
            widget.onItemSelected("Settings Login Details");
          }),
        if (widget.settingslogindetails)
          _buildDashboardListItem(Icons.manage_accounts, "User Management", () {
            _handleSubMenuItemSelected("User Management");
            widget.onItemSelected("Settings User Management");
          }),
      ],
    );
  }

  bool get _isAnySalesconfigTrue {
    return widget.salescustomer || widget.salestablecount;
  }

  Widget _buildSalesList() {
    return Column(
      children: [
        if (widget.salesnewsales)
          _buildDashboardListItem(Icons.shopping_bag, "New Sales", () {
            _handleSubMenuItemSelected("New Sales");
            // widget.onItemSelected("New Sales");
            // NewStock();
          }),
        if (widget.saleseditsales)
          _buildDashboardListItem(Icons.edit, "Edit Sales", () {
            _handleSubMenuItemSelected("Edit Sales");
            widget.onItemSelected("Edit Sales Details");
          }),
        if (widget.salespaymentdetails)
          _buildDashboardListItem(Icons.payment, "Payment Details", () {
            _handleSubMenuItemSelected("Payment Details");
            widget.onItemSelected("Sales Payment");
          }),
        if (_isAnySalesconfigTrue)
          _buildDashboardListItem(Icons.format_list_bulleted_rounded, "Config",
              () {
            _handleSubMenuItemSelected("Config");
          }),
        if (_selectedDashboardItem == "Config" && _isExpandedSubitems) ...[
          if (widget.salescustomer)
            _buildDashboardListItem(
              Icons.category,
              "Sales Customer",
              () {
                widget.onItemSelected("Sales Customer");
              },
            ),

          if (widget.salestablecount)
            _buildDashboardListItem(
              Icons.fastfood_sharp,
              "Table Count",
              () {
                widget.onItemSelected("Sales Table Count");
              },
            ),
          // _buildDashboardListItem(
          //   Icons.person,
          //   "Billno Reset",
          //   () {
          //     widget.onItemSelected("Sales Billno Reset");
          //   },
          // ),
        ],
      ],
    );
  }

  bool get _isAnyPurchaseconfigTrue {
    return widget.purchaseproductcategory ||
        widget.purchaseproductdetails ||
        widget.purchaseCustomer;
  }

  Widget _buildPurchaseList() {
    return Column(
      children: [
        if (widget.purchasenewpurchase)
          _buildDashboardListItem(Icons.shopping_cart_checkout, "New Purchase",
              () {
            _handleSubMenuItemSelected("New Purchase");
            widget.onItemSelected("New Purchase");
          }),
        if (widget.purchaseeditpurchase)
          _buildDashboardListItem(Icons.edit, "Edit Purchase", () {
            _handleSubMenuItemSelected("Edit Purchase");
            widget.onItemSelected("Edit Purchase details");
          }),
        if (widget.purchasepaymentdetails)
          _buildDashboardListItem(Icons.payment, "Payment Details  ", () {
            _handleSubMenuItemSelected("Payment Details  ");
            widget.onItemSelected("Purchase Payment Details");
          }),
        if (_isAnyPurchaseconfigTrue)
          _buildDashboardListItem(Icons.format_list_bulleted_rounded, "Config ",
              () {
            _handleSubMenuItemSelected("Config ");
          }),
        if (_selectedDashboardItem == "Config " && _isExpandedSubitems) ...[
          if (widget.purchaseproductcategory)
            _buildDashboardListItem(
              Icons.category,
              "Product Category",
              () {
                widget.onItemSelected("Purchase Product Category");
              },
            ),
          if (widget.purchaseproductdetails)
            _buildDashboardListItem(
              Icons.fastfood_sharp,
              "Product Details",
              () {
                widget.onItemSelected("Purchase Product Details");
              },
            ),
          if (widget.purchaseCustomer)
            _buildDashboardListItem(
              Icons.person,
              "Purchase Customer",
              () {
                widget.onItemSelected("Purchase Customer");
              },
            ),
        ],
      ],
    );
  }

  Widget _buildOrderSalesList() {
    return Column(
      children: [
        if (widget.ordersalesnew)
          _buildDashboardListItem(
              Icons.shopping_cart_outlined, "New Order Sales", () {
            _handleSubMenuItemSelected("New Order Sales");
            widget.onItemSelected("New Order Sales");
          }),
        if (widget.ordersalesedit)
          _buildDashboardListItem(Icons.edit_document, "Edit Order Sales", () {
            _handleSubMenuItemSelected("Edit Order Sales");
            widget.onItemSelected("Edit Order Sales");
          }),
        if (widget.ordersalespaymentdetails)
          _buildDashboardListItem(Icons.payment, "Payment Details ", () {
            _handleSubMenuItemSelected("Payment Details ");
            widget.onItemSelected("Order Sales Payment Details");
          }),
      ],
    );
  }

  Widget _buildQuickSalesList() {
    return Column(
      children: [],
    );
  }

  Widget _buildVendorSalesList() {
    return Column(
      children: [
        if (widget.vendorsalesnew)
          _buildDashboardListItem(
              Icons.shopping_bag_outlined, "New Vendor Sales", () {
            _handleSubMenuItemSelected("New Vendor Sales");
            widget.onItemSelected("New Vendor Sales");
          }),
        if (widget.vendorsalespaymentdetails)
          _buildDashboardListItem(Icons.person, "Payment  Details", () {
            _handleSubMenuItemSelected("Payment  Details");
            widget.onItemSelected("Vendor Sales Payment  Details");
          }),
        if (widget.vendorsalesnew)
          _buildDashboardListItem(Icons.settings, "Config  ", () {
            _handleSubMenuItemSelected("Config  ");
          }),
        if (_selectedDashboardItem == "Config  " && _isExpandedSubitems) ...[
          if (widget.vendorcustomer)
            _buildDashboardListItem(
              Icons.category,
              "Vendor Customers",
              () {
                widget.onItemSelected("Vendor Customers");
              },
            ),
        ],
      ],
    );
  }

  Widget _buildStockList() {
    return Column(
      children: [
        if (widget.stocknew)
          _buildDashboardListItem(
              Icons.shopping_cart_checkout_outlined, "New Stock", () {
            _handleSubMenuItemSelected("New Stock");
            widget.onItemSelected("New Stock");
          }),
      ],
    );
  }

  Widget _buildWastageList() {
    return Column(
      children: [
        if (widget.wastageadd)
          _buildDashboardListItem(Icons.delete_forever_rounded, "Add Wastage",
              () {
            _handleSubMenuItemSelected("Add Wastage");
            widget.onItemSelected("Add Wastage");
          }),
      ],
    );
  }

  Widget _buildKitchenList() {
    return Column(
      children: [
        if (widget.kitchenusagesentry)
          _buildDashboardListItem(Icons.restaurant_menu_outlined, "Usage Entry",
              () {
            _handleSubMenuItemSelected("Usage Entry");
            widget.onItemSelected("Usage Entry");
          }),
      ],
    );
  }

  Widget _buildReportList() {
    return Column(
      children: [],
    );
  }

  Widget _buildDaySheetList() {
    return Column(
      children: [
        if (widget.daysheetincomeentry)
          _buildDashboardListItem(Icons.attach_money_sharp, "Income Entry", () {
            _handleSubMenuItemSelected("Income Entry");
            widget.onItemSelected("Income Entry");
          }),
        if (widget.daysheetexpenseentry)
          _buildDashboardListItem(
              Icons.currency_exchange_outlined, "Expense Entry", () {
            _handleSubMenuItemSelected("Expense Entry");
            widget.onItemSelected("Expense Entry");
          }),
        if (widget.daysheetexepensescategory)
          _buildDashboardListItem(
              Icons.format_list_bulleted_rounded, "Config   ", () {
            _handleSubMenuItemSelected("Config   ");
          }),
        if (_selectedDashboardItem == "Config   " && _isExpandedSubitems) ...[
          if (widget.daysheetexepensescategory)
            _buildDashboardListItem(
              Icons.file_open,
              "Expense Category",
              () {
                widget.onItemSelected("Expense Category");
              },
            ),
        ],
      ],
    );
  }

  Widget _buildLogoutList() {
    return Column(
      children: [
        _buildDashboardListItem(Icons.shopping_bag, "Logout", () {
          showLogoutDialog(context);
        }),
      ],
    );
  }

  Widget _buildGraphist() {
    return Column(
      children: [
        if (widget.graphsales)
          _buildDashboardListItem(Icons.shopping_bag, "Sales ", () {
            _handleSubMenuItemSelected("Sales ");
            widget.onItemSelected("Sales");
          }),
      ],
    );
  }

  void _handleSubMenuItemSelected(String text) {
    setState(() {
      if (_selectedDashboardItem == text) {
        _isExpandedSubitems = !_isExpandedSubitems;
      } else {
        _selectedDashboardItem = text;
        _isExpandedSubitems = true;
      }
    });
  }

  Widget _buildDashboardListItem(
      IconData icon, String text, VoidCallback onPressed,
      {List<Widget>? subItems}) {
    final bool isSelected = _selectedDashboardItem == text;
    final bool isHovered = _hoveredItems[text] ?? false;

    final bool isSubMenu = text == "Sales Customer" ||
        text == "Table Count" ||
        text == "Billno Reset" ||
        text == "Product Category" ||
        text == "Product Details" ||
        text == "Purchase Customer" ||
        text == "Vendor Customers" ||
        text == "Expense Category" ||
        text == "Last 7 Days" ||
        text == "Last 1 Month" ||
        text == "Last 1 Year";

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredItems[text] = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredItems[text] = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (text == "New Sales") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewSalesEntry(
                        Fianlamount: TextEditingController(),
                        cusnameController: TextEditingController(),
                        TableNoController: TextEditingController(),
                        cusaddressController: TextEditingController(),
                        cuscontactController: TextEditingController(),
                        scodeController: TextEditingController(),
                        snameController: TextEditingController(),
                        TypeController: TextEditingController(),
                        salestableData: [],
                        isSaleOn: true,
                      )),
            );
          } else if (text == "New Purchase") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewPurchaseEntryPage()),
            );
          } else if (text == "Quick Sales") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuickSalesMainPage()),
            );
          } else {
            onPressed();
          }
        },
        child: Container(
          width: 190,
          decoration: BoxDecoration(
            color: isSelected || (subItems != null && _isExpandedSubitems)
                ? sidebarselect
                : (isHovered ? sidebarselect : sidebarselect.withOpacity(0.3)),
            // borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: isSubMenu ? 35 : 20,
                  right: 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected || (subItems != null && _isExpandedSubitems)
                            ? sidebarselect
                            : (isHovered ? sidebarselect : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 10.0),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: isSubMenu ? 12 : 12,
                          color: isDarkTheme
                              ? (isSelected || isHovered
                                  ? Colors.black
                                  : sidebartext)
                              : (isDarkTheme
                                  ? (isSelected ? Colors.black : Colors.black)
                                  : Colors.black),
                        ),
                        SizedBox(width: 10),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: isSubMenu ? 13 : 13,

                            color: isDarkTheme
                                ? (isSelected || isHovered
                                    ? Colors.black
                                    : sidebartext)
                                : (isDarkTheme
                                    ? (isSelected ? Colors.black : Colors.black)
                                    : Colors.black),
                            // color: isDarkTheme
                            //     ? sidebartext // Dark theme
                            //     : (isSelected || isHovered
                            //         ? sidebartext
                            //         : maincolor), // !Dark theme
                          ),
                        ),
                        Spacer(),
                        if (subItems != null)
                          Icon(
                            _selectedDashboardItem == text &&
                                    _isExpandedSubitems
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: isDarkTheme
                                ? sidebartext // Dark theme
                                : (isSelected || isHovered
                                    ? sidebartext
                                    : maincolor),
                          ),
                        if (text == "Config" ||
                            text == "Config " ||
                            text == "Config  " ||
                            text == "Config   ")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.keyboard_arrow_down_outlined
                                    : Icons.keyboard_arrow_up_outlined,
                                size: 15,
                                color: isDarkTheme
                                    ? (isSelected || isHovered
                                        ? Colors.black
                                        : sidebartext)
                                    : (isDarkTheme
                                        ? (isSelected
                                            ? Colors.black
                                            : Colors.black)
                                        : Colors.black),
                              ),
                              SizedBox(width: 10),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
              if (isSelected && subItems != null && _isExpandedSubitems)
                ...subItems,
            ],
          ),
        ),
      ),
    );
  }

  Map<String, bool> _hoveredItems = {
    'Product Catogory ': false,
    'Product Category': false,
    'GST Details': false,
    'Staff Details': false,
    'Payment Method': false,
    'Add Sales Points': false,
    'Printer Details': false,
    'Login Details': false,
    'New Sales': false,
    'Product Details': false,
    'Sales Customer': false,
    'Table Count': false,
    'Billno Reset': false,
    'New Purchase': false,
    'Edit Purchase ': false,
    'Edit Sales': false,
    'Payment Details': false,
    'Payment Details  ': false,
    'Payment Details ': false,
    'Product Details ': false,
    'New Order Sales': false,
    'New Vendor Sales': false,
    'Payment  Details': false,
    'Configuration': false,
    'Vendor Customers': false,
    'New Stock': false,
    'Add Wastage': false,
    "Usage Entry": false,
    "Income Entry": false,
    "Expense Entry": false,
  };

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Logout ",
            style: TextStyle(fontSize: 13),
          ),
          content: Text(
            "Are you sure you want to Logout?",
            style: TextStyle(fontSize: 12),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await logreports("LogOut");
                await SharedPrefs.clearAll();
                await logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen(
                            email: '',
                            password: '',
                          )),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 5.0,
                  right: 5.0,
                  top: 2.0,
                  bottom: 2.0,
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 5.0,
                  right: 5.0,
                  top: 2.0,
                  bottom: 2.0,
                ),
                child: Text(
                  'No',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }
}
