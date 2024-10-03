// import 'package:ProductRestaurant/Settings/UserManagement.dart';
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Dashboard/Dashboard.dart';
import 'package:restaurantsoftware/DaySheet/ExpenseCategory.dart';
import 'package:restaurantsoftware/DaySheet/ExpenseEntry.dart';
import 'package:restaurantsoftware/DaySheet/IncomeEntry.dart';
import 'package:restaurantsoftware/Graph/Sales.dart';
import 'package:restaurantsoftware/Kitchen/UsageEntry.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:restaurantsoftware/OrderSales/EditOrderSales.dart';
import 'package:restaurantsoftware/OrderSales/NewOrderSales.dart';
import 'package:restaurantsoftware/OrderSales/OrderPaymentDetails.dart';
import 'package:restaurantsoftware/Purchase/Config/PurchaseCategory.dart';
import 'package:restaurantsoftware/Purchase/Config/PurchaseCustomer.dart';
import 'package:restaurantsoftware/Purchase/Config/PurchaseProductDetails.dart';
import 'package:restaurantsoftware/Purchase/EditPurchaseForm.dart';
import 'package:restaurantsoftware/Purchase/NewPurchaseEntry.dart';
import 'package:restaurantsoftware/Purchase/PurchasePaymentDetails.dart';
import 'package:restaurantsoftware/Reports/Reports.dart';
import 'package:restaurantsoftware/Sales/Config/SalesCustomer.dart';
import 'package:restaurantsoftware/Sales/Config/TableCount.dart';
import 'package:restaurantsoftware/Sales/EditSalesForm.dart';
import 'package:restaurantsoftware/Sales/NewSales.dart';
import 'package:restaurantsoftware/Sales/SalesPaymentDetails.dart';
import 'package:restaurantsoftware/Settings/AddProductsDetails.dart';
import 'package:restaurantsoftware/Settings/AddSalesPoint.dart';
import 'package:restaurantsoftware/Settings/GstDetails.dart';
import 'package:restaurantsoftware/Settings/LoginDetails.dart';
import 'package:restaurantsoftware/Settings/PaymentMethod.dart';
import 'package:restaurantsoftware/Settings/PrinterDetails.dart';
import 'package:restaurantsoftware/Settings/ProductCategory.dart';
import 'package:restaurantsoftware/Settings/StaffDetails.dart';
import 'package:restaurantsoftware/Settings/UserManagement.dart';
import 'package:restaurantsoftware/Sidebar/SidebarSubPage.dart';
import 'package:restaurantsoftware/Stock/StockPage.dart';
import 'package:restaurantsoftware/VendorSales/Config/VendorCustomer.dart';
import 'package:restaurantsoftware/VendorSales/NewVendorSales.dart';
import 'package:restaurantsoftware/VendorSales/VendorPaymentDetails.dart';
import 'package:restaurantsoftware/Wastage/Wastage.dart';
// import 'package:ProductRestaurant/Dashboard/Dashboard.dart';
// import 'package:ProductRestaurant/DaySheet/ExpenseCategory.dart';
// import 'package:ProductRestaurant/DaySheet/ExpenseEntry.dart';
// import 'package:ProductRestaurant/DaySheet/IncomeEntry.dart';
// import 'package:ProductRestaurant/Graph/Sales.dart';
// import 'package:ProductRestaurant/Kitchen/UsageEntry.dart';
// import 'package:ProductRestaurant/Modules/Responsive.dart';
// import 'package:ProductRestaurant/Modules/constaints.dart';
// import 'package:ProductRestaurant/OrderSales/EditOrderSales.dart';
// import 'package:ProductRestaurant/OrderSales/NewOrderSales.dart';
// import 'package:ProductRestaurant/OrderSales/OrderPaymentDetails.dart';
// import 'package:ProductRestaurant/Purchase/Config/PurchaseCategory.dart';
// import 'package:ProductRestaurant/Purchase/Config/PurchaseCustomer.dart';
// import 'package:ProductRestaurant/Purchase/Config/PurchaseProductDetails.dart';
// import 'package:ProductRestaurant/Purchase/EditPurchaseForm.dart';
// import 'package:ProductRestaurant/Purchase/NewPurchaseEntry.dart';
// import 'package:ProductRestaurant/Purchase/PurchasePaymentDetails.dart';
// import 'package:ProductRestaurant/QuickSales/QuickSales.dart';
// import 'package:ProductRestaurant/Reports/Reports.dart';
// import 'package:ProductRestaurant/Sales/Config/SalesCustomer.dart';
// import 'package:ProductRestaurant/Sales/Config/TableCount.dart';
// import 'package:ProductRestaurant/Sales/EditSalesForm.dart';
// import 'package:ProductRestaurant/Sales/NewSales.dart';
// import 'package:ProductRestaurant/Sales/SalesPaymentDetails.dart';
// import 'package:ProductRestaurant/Settings/AddProductsDetails.dart';
// import 'package:ProductRestaurant/Settings/AddSalesPoint.dart';
// import 'package:ProductRestaurant/Settings/GstDetails.dart';
// import 'package:ProductRestaurant/Settings/LoginDetails.dart';
// import 'package:ProductRestaurant/Settings/PaymentMethod.dart';
// import 'package:ProductRestaurant/Settings/PrinterDetails.dart';
// import 'package:ProductRestaurant/Settings/ProductCategory.dart';
// import 'package:ProductRestaurant/Settings/StaffDetails.dart';
// import 'package:ProductRestaurant/Sidebar/SidebarSubPage.dart';
// import 'package:ProductRestaurant/Stock/StockPage.dart';
// import 'package:ProductRestaurant/VendorSales/Config/VendorCustomer.dart';
// import 'package:ProductRestaurant/VendorSales/NewVendorSales.dart';
// import 'package:ProductRestaurant/VendorSales/VendorPaymentDetails.dart';
// import 'package:ProductRestaurant/Wastage/Wastage.dart';

class sidebar extends StatefulWidget {
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

  const sidebar({
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
  State<sidebar> createState() => _sidebarState();
}

class _sidebarState extends State<sidebar> {
  bool _isMenuVisible = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isMobile(context))
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                color: isDarkTheme ? maincolor : sidebartext,
                child: menusitem(
                  onItemSelected: (content) {
                    setState(() {
                      _selectedContent = content;
                    });
                  },
                  settingsproductcategory: widget.settingsproductcategory,
                  settingsproductdetails: widget.settingsproductdetails,
                  settingsgstdetails: widget.settingsgstdetails,
                  settingsstaffdetails: widget.settingsstaffdetails,
                  settingspaymentmethod: widget.settingspaymentmethod,
                  settingsaddsalespoint: widget.settingsaddsalespoint,
                  settingsprinterdetails: widget.settingsprinterdetails,
                  settingslogindetails: widget.settingslogindetails,
                  purchasenewpurchase: widget.purchasenewpurchase,
                  purchaseeditpurchase: widget.purchaseeditpurchase,
                  purchasepaymentdetails: widget.purchasepaymentdetails,
                  purchaseproductcategory: widget.purchaseproductcategory,
                  purchaseproductdetails: widget.purchaseproductdetails,
                  purchaseCustomer: widget.purchaseCustomer,
                  salesnewsales: widget.salesnewsales,
                  saleseditsales: widget.saleseditsales,
                  salespaymentdetails: widget.salespaymentdetails,
                  salescustomer: widget.salescustomer,
                  salestablecount: widget.salestablecount,
                  quicksales: widget.quicksales,
                  ordersalesnew: widget.ordersalesnew,
                  ordersalesedit: widget.ordersalesedit,
                  ordersalespaymentdetails: widget.ordersalespaymentdetails,
                  vendorsalesnew: widget.vendorsalesnew,
                  vendorsalespaymentdetails: widget.vendorsalespaymentdetails,
                  vendorcustomer: widget.vendorcustomer,
                  stocknew: widget.stocknew,
                  wastageadd: widget.wastageadd,
                  kitchenusagesentry: widget.kitchenusagesentry,
                  report: widget.report,
                  daysheetincomeentry: widget.daysheetincomeentry,
                  daysheetexpenseentry: widget.daysheetexpenseentry,
                  daysheetexepensescategory: widget.daysheetexepensescategory,
                  graphsales: widget.graphsales,
                ),
              ),
            ),
          ),
        if (!Responsive.isMobile(context))
          Expanded(
              flex: 11,
              child: Container(
                color: sidebartext,
                child: _buildSelectedContent(),
              )),
        if (Responsive.isMobile(context))
          Expanded(
            child: Scaffold(
              appBar: _isMenuVisible
                  ? null
                  : AppBar(
                      backgroundColor: maincolor,
                      leading: IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          setState(() {
                            _isMenuVisible = !_isMenuVisible;
                          });
                        },
                      ),
                    ),
              // Your other Scaffold content goes here

              body: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuVisible = false;
                  });
                },
                child: Stack(
                  children: [
                    _buildSelectedContent(),
                    if (_isMenuVisible)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 150,
                        child: Container(
                          color: maincolor,
                          child: menusitem(
                            onItemSelected: (content) {
                              setState(() {
                                _selectedContent = content;
                                _isMenuVisible = false;
                              });
                            },
                            settingsproductcategory:
                                widget.settingsproductcategory,
                            settingsproductdetails:
                                widget.settingsproductdetails,
                            settingsgstdetails: widget.settingsgstdetails,
                            settingsstaffdetails: widget.settingsstaffdetails,
                            settingspaymentmethod: widget.settingspaymentmethod,
                            settingsaddsalespoint: widget.settingsaddsalespoint,
                            settingsprinterdetails:
                                widget.settingsprinterdetails,
                            settingslogindetails: widget.settingslogindetails,
                            purchasenewpurchase: widget.purchasenewpurchase,
                            purchaseeditpurchase: widget.purchaseeditpurchase,
                            purchasepaymentdetails:
                                widget.purchasepaymentdetails,
                            purchaseproductcategory:
                                widget.purchaseproductcategory,
                            purchaseproductdetails:
                                widget.purchaseproductdetails,
                            purchaseCustomer: widget.purchaseCustomer,
                            salesnewsales: widget.salesnewsales,
                            saleseditsales: widget.saleseditsales,
                            salespaymentdetails: widget.salespaymentdetails,
                            salescustomer: widget.salescustomer,
                            salestablecount: widget.salestablecount,
                            quicksales: widget.quicksales,
                            ordersalesnew: widget.ordersalesnew,
                            ordersalesedit: widget.ordersalesedit,
                            ordersalespaymentdetails:
                                widget.ordersalespaymentdetails,
                            vendorsalesnew: widget.vendorsalesnew,
                            vendorsalespaymentdetails:
                                widget.vendorsalespaymentdetails,
                            vendorcustomer: widget.vendorcustomer,
                            stocknew: widget.stocknew,
                            wastageadd: widget.wastageadd,
                            kitchenusagesentry: widget.kitchenusagesentry,
                            report: widget.report,
                            daysheetincomeentry: widget.daysheetincomeentry,
                            daysheetexpenseentry: widget.daysheetexpenseentry,
                            daysheetexepensescategory:
                                widget.daysheetexepensescategory,
                            graphsales: widget.graphsales,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _selectedContent = ''; // Track the selected content

  Widget _buildSelectedContent() {
    switch (_selectedContent) {
      case "Dashboard":
        return Dashboard();
      case 'Settings Product Catogory ':
        return ProductCategory();
      case 'Settings Product Details ':
        return AddProductDetailsPage();
      case 'Settings Gst Details':
        return GstDetailsForm();
      case 'Settings Staff Details':
        return StaffDetailsPage();
      case 'Settings Payment Method':
        return PaymentMethodSetting();
      case 'Add Sales Points':
        return AddSalesPointSetting();
      case 'Settings Printer Details':
        return printerdetails();
      case 'Settings Login Details':
        return LoginDetailsPage();
      case 'Settings User Management':
        return UserManagementPage();
      case 'New Sales':
        return NewSalesEntry(
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
        );

      case 'Edit Sales Details':
        return EditNewSalesEntry(
          cusnameController: TextEditingController(),
          TableNoController: TextEditingController(),
          cusaddressController: TextEditingController(),
          cuscontactController: TextEditingController(),
          scodeController: TextEditingController(),
          snameController: TextEditingController(),
          TypeController: TextEditingController(),
          salestableData: [],
          key: Key('editNewSalesEntryKey'),
        );

      case 'Sales Payment':
        return SalesPaymetdetails();
      case 'Sales Customer':
        return SalesCoutomer();
      case 'Sales Table Count':
        return Sales_TableCount();
      // case 'Quick Sales':
      //   return QuickSalesMainPage();
      case 'New Purchase':
        return NewPurchaseEntryPage();
      case 'Edit Purchase details':
        return EditPurchaseEntryPage();
      case 'Purchase Payment Details':
        return PaymentDetailsPage();
      case 'Purchase Product Category':
        return PurchaseProductCategory();
      case 'Purchase Product Details':
        return PurchaseProductDetails();
      case 'Purchase Customer':
        return PurchaseCustomerSupplier();
      case 'New Order Sales':
        return NewOrderSalesEntry();
      case 'Edit Order Sales':
        return EditOrderSales();
      case 'Order Sales Payment Details':
        return OrderPaymentDetails();
      case 'New Vendor Sales':
        return NewVendorSalesEntry();
      case 'Vendor Sales Payment  Details':
        return VendorPaymentDetails();
      case 'Vendor Customers':
        return VendorCustomer();
      case 'New Stock':
        return StockPage();
      case 'Add Wastage':
        return WastagePage();
      case 'Usage Entry':
        return UsageEntryKitchen();
      case 'Income Entry':
        return IncomeEntry();
      case 'Expense Entry':
        return ExpenseEntry();
      case 'Expense Category':
        return ExpenseCategory();
      case 'Report':
        return ReportPage();
      case 'Sales':
        return SalesChart();

      default:
        return Dashboard();
    }
  }
}


