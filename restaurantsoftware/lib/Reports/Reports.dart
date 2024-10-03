import 'package:restaurantsoftware/Reports/Sales/oneDayReport.dart';
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/Reports/Others/DaySheetReport.dart';
import 'package:restaurantsoftware/Reports/Others/ProductCodeFinder.dart';
import 'package:restaurantsoftware/Reports/Others/UsageReport.dart';
import 'package:restaurantsoftware/Reports/Others/WastageReport.dart';
import 'package:restaurantsoftware/Reports/Purchase/AgentwiseReport.dart';
import 'package:restaurantsoftware/Reports/Purchase/PurchaseLedgerreport.dart';
import 'package:restaurantsoftware/Reports/Purchase/PurchaseReport.dart';
import 'package:restaurantsoftware/Reports/Sales/BillWiseSalesCountReport.dart';
import 'package:restaurantsoftware/Reports/Sales/DailySalesDetails.dart';
import 'package:restaurantsoftware/Reports/Sales/CustomerSalesReport.dart';
import 'package:restaurantsoftware/Reports/Sales/OrderSalesReport.dart';
import 'package:restaurantsoftware/Reports/Sales/PaymentTypeReport.dart';
import 'package:restaurantsoftware/Reports/Sales/ProductSalesCountReport.dart';
import 'package:restaurantsoftware/Reports/Sales/SalesAuditingreport.dart';
import 'package:restaurantsoftware/Reports/Sales/SalesLedgerreport.dart';
import 'package:restaurantsoftware/Reports/Sales/SalesReport.dart';
import 'package:restaurantsoftware/Reports/Sales/ServantSales.dart';
import 'package:restaurantsoftware/Reports/Sales/VendorSalesReport.dart';
import 'package:restaurantsoftware/Reports/Stock/OverAllStockReport.dart';
import 'package:restaurantsoftware/Reports/Stock/ProductStock.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String searchText = '';

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData, String key) {
    if (searchText.isEmpty) {
      return tableData;
    }

    return tableData
        .where((data) =>
            (data[key] ?? '').toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> tableDatasales = [
    {'sales': 'Sales Report'},
    {'sales': 'Daily Sales Details'},
    {'sales': 'One Day Report'},
    {'sales': 'CustomerWise Sales Report'},
    {'sales': 'Product Sales Count'},
    {'sales': 'Billwise Sales Count'},
    {'sales': 'Payment Type'},
    {'sales': 'Servant Sales'},
    {'sales': 'Sales Ledger'},
    {'sales': 'Sales Auditing'},
    {'sales': 'Order Sales'},
    {'sales': 'Vendor Sales'},
  ];

  List<Map<String, dynamic>> tableDatapurchase = [
    {'purchase': 'Purchase Report'},
    {'purchase': 'Agentwise Report'},
    {'purchase': 'Purchase Ledger Report'},
  ];

  List<Map<String, dynamic>> tableDataOthers = [
    {'others': 'Wastage Report'},
    {'others': 'Usage Report'},
    {'others': 'DaySheet Report'},
    {'others': 'Product Code Finder'},
  ];
  List<Map<String, dynamic>> tableDataStock = [
    {'Stock': 'OverAll Stock'},
    {'Stock': 'Product Stock'},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredSalesData =
        getFilteredData(tableDatasales, 'sales');
    List<Map<String, dynamic>> filteredPurchaseData =
        getFilteredData(tableDatapurchase, 'purchase');
    List<Map<String, dynamic>> filteredOthersData =
        getFilteredData(tableDataOthers, 'others');
    List<Map<String, dynamic>> filteredStockData =
        getFilteredData(tableDataStock, 'Stock');

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: HeadingStyle,
                ),
                SizedBox(height: 5),
                Divider(color: Colors.grey[300], thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 30,
                      width: 160,
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 10.0, right: 4.0),
                          ),
                          style: textStyle),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildTable('Sales', filteredSalesData),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildTable(
                                        'Purchase', filteredPurchaseData),
                                    SizedBox(height: 10),
                                    buildTable('Others', filteredOthersData),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildTable('Stock', filteredStockData),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getSectionColor(String title) {
    switch (title) {
      case 'Sales':
        return Colors.blue.withOpacity(0.3);
      case 'Purchase':
        return Colors.purple.withOpacity(0.3);
      case 'Stock':
        return Colors.yellow.withOpacity(0.5);
      case 'Others':
        return Colors.red.withOpacity(0.3);
      default:
        return Colors.orange.withOpacity(0.3);
    }
  }

  Color getHoverColor(String title) {
    switch (title) {
      case 'Sales':
        return Colors.blue.shade300.withOpacity(0.6);
      case 'Purchase':
        return Colors.purple.shade300.withOpacity(0.6);
      case 'Stock':
        return Colors.yellow.shade300.withOpacity(0.9);
      case 'Others':
        return Colors.red.shade300.withOpacity(0.6);
      default:
        return Colors.orange.shade300.withOpacity(0.6);
    }
  }

  Widget buildTable(String title, List<Map<String, dynamic>> data) {
    Color containerColor = getSectionColor(title);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textStyle),
          SizedBox(height: 5),
          if (data.isNotEmpty)
            Container(
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var value = data[index].values.first.toString();
                  bool isEvenRow = index % 2 == 0;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: MouseRegion(
                      onEnter: (_) =>
                          setState(() => data[index]['hover'] = true),
                      onExit: (_) =>
                          setState(() => data[index]['hover'] = false),
                      child: GestureDetector(
                        onTap: () {
                          navigateToReportDetails(title, value);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: data[index]['hover'] == true
                                ? getHoverColor(title)
                                : containerColor,
                            border: Border.all(
                                color: Color.fromARGB(255, 226, 225, 225)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(value, style: commonLabelTextStyle),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _selectedContent = '';

  void _onReportSelected(String content) {
    setState(() {
      _selectedContent = content;
    });
  }

  void navigateToReportDetails(String title, String value) {
// Sales Report
    if (value == 'Sales Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Salesreport(),
          );
        },
      );
    } else if (value == 'CustomerWise Sales Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: CustomerWiseReports(),
          );
        },
      );
    } else if (value == 'Daily Sales Details') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: DailySalesDetailsReport(),
          );
        },
      );
    } else if (value == 'One Day Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: oneDayReport(), // Your existing widget
          );
        },
      );
    } else if (value == 'Product Sales Count') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: ProductSalesCountReport(),
          );
        },
      );
    } else if (value == 'Billwise Sales Count') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: BillWiseSalesCountReport(),
          );
        },
      );
    } else if (value == 'Payment Type') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: PaymentTypeReport(),
          );
        },
      );
    } else if (value == 'Sales Ledger') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SalesLedgerReport(),
          );
        },
      );
    } else if (value == 'Sales Auditing') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SalesAudingReport(),
          );
        },
      );
    } else if (value == 'Servant Sales') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: ServantSalesReport(),
          );
        },
      );
    } else if (value == 'Order Sales') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: OrderSalesReport(),
          );
        },
      );
    } else if (value == 'Vendor Sales') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: VendorSalesReport(),
          );
        },
      );
    }
    //Purchase
    else if (value == 'Purchase Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Purchasereport(),
          );
        },
      );
    } else if (value == 'Agentwise Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: AgentwisePurchasereport(),
          );
        },
      );
    } else if (value == 'Purchase Ledger Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: PurchaseLedgerReport(),
          );
        },
      );
    }
    //Others
    else if (value == 'Usage Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: UsageReport(),
          );
        },
      );
    } else if (value == 'Wastage Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: WastageReport(),
          );
        },
      );
    } else if (value == 'Product Code Finder') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: ProductCodeFinder(),
          );
        },
      );
    } else if (value == 'DaySheet Report') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: DaysheetReport(),
          );
        },
      );
    }
    //StockReports
    else if (value == 'OverAll Stock') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: AddStockDetailsReport(),
          );
        },
      );
    } else if (value == 'Product Stock') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: ProductStockReport(),
          );
        },
      );
    }
  }
}
