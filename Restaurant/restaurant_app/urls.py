from django.urls import path, include
from . import views
from . import models
from rest_framework import routers
from restaurant_app.views import *

router = routers.DefaultRouter()


router.register("CompanyDetails", CompanyDetailsView, basename="CompanyDetails")
router.register("Shopinfo", ShopinfoView, basename="Shopinf")

# Settings
router.register("LogReport", LogReportView, basename="LogReport")

router.register("CustomerId", CustomerIdView, basename="CustomerId")
router.register("CustomerI_LastdView", CustomerI_LastdView, basename="CustomerI_LastdView")

router.register("TrialID", TrialIDView, basename="TrialID")
router.register("TrialUserRegistration", TrialUserRegistrationView, basename="TrialUserRegistration")

router.register("Settings_Passwordalldatas", Settings_PasswordalldatasView, basename="Settings_Passwordalldatas")

router.register("Settings_Rolealldatas", Settings_RolealldatasView, basename="Settings_Rolealldatas")
router.register(
    "SettingsProductCategory",
    views.Settings_ProductCategoryAllDataView,
    basename="Settings_ProductCategory",
)
router.register(
    "SettingsProductDetailsSNoalldatas",
    views.SettingsProductDetailsSNoalldatasView,
    basename="SettingsProductDetailsSNoalldatas",
)
router.register(
    "SettingsProductDetailsalldatas",
    views.SettingsProductDetailsalldatasView,
    basename="SettingsProductDetailsalldatas",
)
router.register("SettingsComboalldatas", views.SettingsComboalldatasView, basename="SettingsComboalldatas")
router.register("GstDetailsalldatas", views.GstDetailsalldatasView, basename="GstDetailsalldatas")
router.register("StaffDetailsalldatas", views.StaffDetailsalldatasView, basename="StaffDetailsalldatas")
router.register("PaymentMethodalldatas", views.PaymentMethodalldatasView, basename="PaymentMethodalldatas")
router.register("PointSettingalldatas", views.PointSettingalldatasView, basename="PointSettingalldatas")
router.register("SettingsPrinterDetailsalldatas", views.SettingsPrinterDetailsalldatasView, basename="SettingsPrinterDetailsalldatas")
router.register("Settings_Menuitem", views.Settings_MenuitemView, basename="Settings_Menuitem")
router.register("Settings_usermanagementalldatas", views.Settings_usermanagementalldatasView, basename="Settings_usermanagementalldatas")
# / Settings

# Sales
router.register("SalesCustomeralldatas", views.SalesCustomeralldatasView, basename="SalesCustomeralldatas")
router.register("SalesPaymentSnoalldatas", views.SalesPaymentSnoalldatasView, basename="SalesPaymentSnoalldatas")
router.register("SalesPaymentRoundDetailsalldata", SalesPaymentRoundDetailsalldatasView, basename="SalesPaymentRoundDetailsalldata")
router.register("SalesPaymentDetailedalldatas", SalesPaymentDetailedalldatasView, basename="SalesPaymentDetailedalldatas")
router.register("Sales_tableCountalldatas", views.Sales_tableCountalldatasView, basename="Sales_tableCountalldatas")
router.register("Sales_serialnoalldatas", views.Sales_serialnoalldatasView, basename="Sales_serialnoalldatas")
router.register("Sales_IncomeDetails", views.Sales_IncomeDetailsView, basename="Sales_IncomeDetails")
router.register("SalesRoundDetailsalldatas", views.SalesRoundDetailsalldatas_View, basename="SalesRoundDetailsalldatas")

router.register("Sales_tableCount", Sales_tableCountView, basename="Sales_tableCount")
# / Sales

# Purchase
router.register("PurchaseserialNoalldatas", views.PurchaseserialNoalldatasView, basename="PurchaseserialNoalldata")
router.register("PurchaseProductCategoryalldatas", views.PurchaseProductCategoryalldatasView, basename="PurchaseProductCategoryalldatas")
router.register("PurchaseProductDetailsalldatas", views.PurchaseProductDetailsalldatasView, basename="PurchaseProductDetailsalldata")
router.register("PurchaseSupplierNamesalldatas", views.PurchaseSupplierNamesalldatasView, basename="PurchaseSupplierNamesalldatas")
router.register("PurchaseRoundDetailsalldatas", views.PurchaseRoundDetailsalldatasView, basename="PurchaseRoundDetailsalldatas")
router.register("PurchasePaymentSNoalldatas", views.PurchasePaymentSNoalldatasView, basename="PurchasePaymentSNoalldatas")
router.register("PurchasePaymentsAlldatas", views.PurchasePaymentsAlldatasView, basename="PurchasePaymentsAlldatas")
router.register("Purchase_Expenses", views.Purchase_ExpensesView, basename="Purchase_Expenses")

# / Purchase

# Order Sales

router.register("Order_Snoalldata", views.Order_Snoalldata_View, basename="Order_Snoalldata")
router.register("OrderPaymentalldatas", views.OrderPaymentalldatas_View, basename="OrderPaymentalldatas")
router.register("OrderSalesRoundDetailsalldetails",views.OrderSalesRoundDetailsalldetails_View ,basename = "OrderSalesRoundDetailsalldetails")

# / Order Sales

# Vendor Sales
router.register("Vendor_Snoalldata", views.Vendor_Snoalldata_View, basename="Vendor_Snoalldata")
router.register("VendorsNamealldata", views.VendorsNamealldata, basename="VendorsNamealldata")
router.register("SalesFetchVendorPayDetails",views.SalesFetchVendorPaymentView,basename = "SalesFetchVendorPayDetails")
router.register("Vendorpayment", views.VendorpaymentView, basename="Vendorpayment")

# / Vendor Sales

# Stock

router.register("Stock_Snoalldata", views.Stock_Snoalldata_View, basename="Stock_Snoalldata")
router.register("Stock_Details_Roundalldata", views.Stock_Details_Roundalldata_View, basename="Stock_Details_Roundalldata")

# / Stock 

# wastage

router.register("Wastage_serialnoalldata", views.Wastage_serialnoalldata_view, basename="Wastage_serialnoalldata")
router.register("Wastage_Details_Roundalldata", views.Wastage_Details_Roundalldata_View, basename="Wastage_Details_Roundalldata")

# / Wastage

# Kitchen Usage

router.register("Usageserialnoalldata", views.Usageserialnoalldata_View, basename="Usageserialnoalldata")
router.register("UsageRound_Detailsalldata", views.UsageRound_Detailsalldata_View, basename="UsageRound_Detailsalldata")

# / Kitchen Usage

# DaySheet
router.register(
    "IncomeEntryDetailalldatas", views.IncomeEntryDetailalldatasView, basename="IncomeEntryDetailalldatas"
)
router.register("ExpenseCatalldata", views.ExpenseCatalldataView, basename="ExpenseCatalldata")
router.register(
    "ExpenseEntryDetailalldata", views.ExpenseEntryDetailalldataView, basename="ExpenseEntryDetailalldata"
)

# / DaySheet 

urlpatterns = [
    path("", include(router.urls)),
]
