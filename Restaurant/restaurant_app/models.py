import json
from django.db import models


class CompanyDetails(models.Model):
    companyname =  models.CharField(max_length=200, default="")
    address = models.CharField(max_length=200, default="")
    contact =  models.CharField(max_length=200, default="")
    mailid = models.CharField(max_length=200, default="")
    website =  models.CharField(max_length=200, default="")
    instagramid = models.CharField(max_length=200, default="")
    twitterid =  models.CharField(max_length=200, default="")
    facebook = models.CharField(max_length=200, default="")
    linkedin =  models.CharField(max_length=200, default="")
    pinterest = models.CharField(max_length=200, default="")
    youtube = models.CharField(max_length=200, default="")
    printdetails = models.CharField(max_length=200, default="")


    class Meta:
        db_table = "CompanyDetails_tbl"
        ordering = ["id"] 

class Shopinfo(models.Model):
    cusid = models.CharField(max_length=200)
    shopname = models.CharField(max_length=200, default="")
    doorno =models.CharField(max_length=200, default="")
    area = models.CharField(max_length=200, default="")
    area2 =  models.CharField(max_length=200, default="")
    city = models.CharField(max_length=200, default="")
    pincode =models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    gstno =models.CharField(max_length=200, default="")
    fssai = models.CharField(max_length=200, default="")
    shoplogo= models.BinaryField(default=b'',null=True, blank=True)


    class Meta:
        db_table = "ShopInfo_tbl"
        ordering = ["id"] 

class LogReport(models.Model):
    cusid = models.CharField(max_length=200)
    role = models.CharField(max_length=200, default="")
    dt = models.DateTimeField(default="")
    description = models.CharField(max_length=200, default="")


    class Meta:
        db_table = "LogReport_tbl"
        ordering = ["id"] 

# Settings
class CustomerId(models.Model):
    customerid = models.CharField(max_length=200)

    class Meta:
        db_table = "CustomerId_tbl"
        ordering = ["id"] 

class TrialID(models.Model):
    trialid = models.CharField(max_length=200)

    class Meta:
        db_table = "TrialID_tbl"
        ordering = ["id"] 


class TrialUserRegistrationModel(models.Model):
    cusid = models.CharField(max_length=200)
    trialid = models.CharField(max_length=200 ,default="")
    email = models.CharField(max_length=200, default="")
    fullname = models.CharField(max_length=200, default="")
    businessname = models.CharField(max_length=200, default="")
    phoneno = models.CharField(max_length=200, default="")
    address = models.CharField(max_length=200, default="")
    state = models.CharField(max_length=200, default="")
    district = models.CharField(max_length=200, default="")
    city = models.CharField(max_length=200, default="")
    password = models.CharField(max_length=200, default="")
    trialstartdate = models.DateField(default="")
    trialenddate = models.DateField(default="")
    businessgstno = models.CharField(max_length=200, default="")
    software = models.CharField(max_length=200, default="")
    status = models.CharField(max_length=200, default="")
    macid = models.CharField(max_length=200, default="")
    trialstatus = models.CharField(max_length=200, default="")
    installdate = models.DateField(default="")
    closedate = models.DateField(default="")

    class Meta:
        db_table = "TrialUserResgistration_tbl"
        ordering = ["id"]  

class Amc_tbl(models.Model):
    cusid = models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default="")
    macid = models.CharField(max_length=200, default="")
    dt = models.DateField()
    expirydt = models.DateField()
    status = models.CharField(max_length=200, default="")
    type = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "Amc_tbl"
        ordering = ["id"] 
        
class Settings_ProductCategory(models.Model):
    cusid = models.CharField(max_length=200)
    cat = models.CharField(max_length=200,default="")
    type = models.CharField(max_length=200,default="")
    class Meta:
        db_table = "ItemCategory_tbl"
        ordering = ["id"]  

class Settings_ProductDetailsSNo(models.Model):
    cusid = models.CharField(max_length=200)    
    sno = models.CharField(max_length=200)

    class Meta:
        db_table = "ItemSno_tbl"
        ordering = ["id"] 

class Settings_ProductDetails(models.Model):
    cusid = models.CharField(max_length=200)
    name = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")
    wholeamount = models.CharField(max_length=200, default="")
    stock = models.CharField(max_length=200, default="")
    stockvalue = models.CharField(max_length=200, default="")
    cgstper = models.CharField(max_length=200, default="")
    cgstvalue = models.CharField(max_length=200, default="")
    sgstper = models.CharField(max_length=200, default="")
    sgstvalue = models.CharField(max_length=200, default="")
    finalamount = models.CharField(max_length=200, default="")
    code = models.CharField(max_length=200, default="")
    category = models.CharField(max_length=200, default="")
    OnlineAmt = models.CharField(max_length=200, default="")
    OnlineFinalAmt = models.CharField(max_length=200, default="")
    makingcost  = models.CharField(max_length=200, default="")
    status  = models.CharField(max_length=200, default="")
    image = models.BinaryField(default=b'',null=True, blank=True)
    
    class Meta:
        db_table = "NewItem_tbl"
        ordering = ["id"]  

class GstDetailsModel(models.Model):
    cusid = models.CharField(max_length=200,)
    name = models.CharField(max_length=200, default="")
    status = models.CharField(max_length=200, default="")
    gst = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "GstDetails_tbl"
        ordering = ["id"]  
       
class StaffDetailsModel(models.Model):
    cusid = models.CharField(max_length=200)

    code = models.CharField(max_length=200, default="")
    serventname = models.CharField(max_length=200, default="")
    address = models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    username = models.CharField(max_length=200, default="")
    pwd = models.CharField(max_length=200, default="")
    status = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "Servent_tbl"
        ordering = ["id"] 

class PaymentMethodModel(models.Model):
    cusid  = models.CharField(max_length=200)

    paytype = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "PaytypeSetting_tbl"
        ordering = ["id"]  

class PointSettingModel(models.Model):
    cusid = models.CharField(max_length=200,)

    point = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "Points_tbl"
        ordering = ["id"]  

class Settings_PrinterDetails(models.Model):
    cusid = models.CharField(max_length=200)
    type = models.CharField(max_length=200)
    name = models.CharField(max_length=200)
    printer = models.CharField(max_length=200)
    count = models.CharField(max_length=200)
    size = models.CharField(max_length=200)
    class Meta:
        db_table = "KitchenPrinter_tbl"
        ordering = ["id"]  

class Settings_ComboModel(models.Model):
    cusid = models.CharField(max_length=200, default="")

    name = models.CharField(max_length=200, default="")
    item = models.CharField(max_length=200, default="")
    qty  = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "CombooSettings_tbl"
        ordering = ["id"]  

class Settings_PasswordModel(models.Model):
    cusid = models.CharField(max_length=200, default="")
    role = models.CharField(max_length=200, default="")
    email = models.CharField(max_length=200, default="")
    password  = models.CharField(max_length=200, default="")
    datetime= models.DateTimeField(default="")  
    class Meta:
        db_table = "Password_tbl"
        ordering = ["id"]  

class Settings_RoledModel(models.Model):
    cusid = models.CharField(max_length=200, default="")
    role = models.CharField(max_length=200, default="")
   
    class Meta:
        db_table = "RoleSettings_tbl"
        ordering = ["id"]  



class Settings_Menuitem(models.Model):
    menu = models.CharField(max_length=200, default="")
    submenu = models.CharField(max_length=200, default="")
   
    class Meta:
        db_table = "Menu_tbl"
        ordering = ["id"]  




class Settings_usermanagement(models.Model):
    cusid = models.CharField(max_length=200, default="")
    role = models.CharField(max_length=200, default="")
    email = models.CharField(max_length=200, default="")
    menu = models.CharField(max_length=200, default="")
    CategoryStatus = models.CharField(max_length=200, default="")
   
    class Meta:
        db_table = "UserManagement_tbl"
        ordering = ["id"]  



#/ Settings

# Sales

class SalesCustomerModel(models.Model):
    cusid= models.CharField(max_length=200)
    cusname= models.CharField(max_length=200, default="")
    address= models.CharField(max_length=200, default="")
    contact= models.CharField(max_length=200, default="")
    mailid= models.CharField(max_length=200, default="")
    feedback= models.CharField(max_length=200, default="")
    Points= models.CharField(max_length=200, default="")
    dateofbirth= models.DateField()  
    marriagedt= models.DateField()  
    opnamnt= models.CharField(max_length=200, default="")


    class Meta:
        db_table = "CustomerSettings_tbl"
        ordering = ["id"]  

class Sales_tableCount(models.Model):
    cusid= models.CharField(max_length=200)
    name= models.CharField(max_length=200, default="")
    count= models.CharField(max_length=200, default="")
    code= models.CharField(max_length=200, default="")
    class Meta:
        db_table = "TableCount_tbl"  
        ordering = ["id"]   

class SalesPaymentSno(models.Model):
    cusid = models.CharField(max_length=200)
    sno = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "SalesPaymentSno_tbl"   
        ordering = ["id"]  

class SalesPaymentRoundDetails(models.Model):
    cusid = models.CharField(max_length=200)
    billno = models.CharField(max_length=200, default="")
    name = models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    dt= models.DateField()  
    paymenttype = models.CharField(max_length=200, default="")
    chequeno = models.CharField(max_length=200, default="")
    chequedt = models.CharField(max_length=200, default="")
    reference = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")
    salespaymentdetails= models.TextField(default="")    
    class Meta:
        db_table = "SalesPayment_tbl"   
        ordering = ["id"]  

class Sales_serialno(models.Model):
    cusid = models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "SalesSerialNo_tbl"   
        ordering = ["id"]  

class SalesRoundDetails_Model(models.Model):
      cusid= models.CharField(max_length=200,)
      billno= models.CharField(max_length=200, default="")
      dt=  models.DateField()  
      type= models.CharField(max_length=200, default="")
      tableno= models.CharField(max_length=200, default="")
      servent= models.CharField(max_length=200, default="")
      count= models.CharField(max_length=200, default="")
      amount= models.CharField(max_length=200, default="")
      discount= models.CharField(max_length=200, default="")
      vat= models.CharField(max_length=200, default="")
      finalamount= models.CharField(max_length=200, default="")
      cgst0 = models.CharField(max_length=200, default="")
      cgst25 = models.CharField(max_length=200, default="")
      cgst6= models.CharField(max_length=200, default="")
      cgst9= models.CharField(max_length=200, default="")
      cgst14= models.CharField(max_length=200, default="")
      sgst0= models.CharField(max_length=200, default="")
      sgst25= models.CharField(max_length=200, default="")
      sgst6= models.CharField(max_length=200, default="")
      sgst9= models.CharField(max_length=200, default="")
      sgst14= models.CharField(max_length=200, default="")
      totcgst= models.CharField(max_length=200, default="")
      totsgst= models.CharField(max_length=200, default="")
      paidamount= models.CharField(max_length=200, default="")
      scode= models.CharField(max_length=200, default="")
      sname= models.CharField(max_length=200, default="")
      cusname= models.CharField(max_length=200, default="")
      contact= models.CharField(max_length=200, default="")
      paytype= models.CharField(max_length=200, default="")
      disperc= models.CharField(max_length=200, default="")
      famount= models.CharField(max_length=200, default="")
      vendorname= models.CharField(max_length=200, default="")
      vendorcomPerc= models.CharField(max_length=200, default="")
      CommisionAmt= models.CharField(max_length=200, default="")
      VendorDisPerc= models.CharField(max_length=200, default="")
      VendorDisamt= models.CharField(max_length=200, default="")
      FinalAmt= models.CharField(max_length=200, default="")
      TotalAmount= models.CharField(max_length=200, default="")
      Status= models.CharField(max_length=200, default="")
      OrderNo= models.CharField(max_length=200, default="")
      PointDis= models.CharField(max_length=200, default="")
      login= models.CharField(max_length=200, default="")
      gststatus= models.CharField(max_length=200, default="")
      time= models.DateTimeField()
      customeramount= models.CharField(max_length=200, default="")
      customerchange= models.CharField(max_length=200, default="")
      taxstatus= models.CharField(max_length=200, default="")
      serialno= models.CharField(max_length=200, default="")
      taxable= models.CharField(max_length=200, default="")
      finaltaxable= models.CharField(max_length=200, default="")
      SalesDetails = models.TextField(default="")  # Changed to TextField
         
      class Meta:
        db_table = "SalesRoundDetails_tbl"
        ordering = ["id"] 

# / Sales

# Purchase

class Purchse_serialno(models.Model):
    cusid= models.CharField(max_length=200)
    serialno = models.CharField(max_length=200)
    class Meta:
        db_table = "PurchaseSno_tbl"
        ordering = ["id"]  
        
class PurchaseProductCategory(models.Model):
    cusid = models.CharField(max_length=200)
    name = models.CharField(max_length=200, default=" ")
    class Meta:
        db_table = "PurchaseCategory_tbl"   
        ordering = ["id"]  

class PurchaseProductDetails(models.Model):
    cusid = models.CharField(max_length=200)
    name = models.CharField(max_length=200, default="")
    stock = models.CharField(max_length=200, default="")
    category = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")
    sgstperc = models.CharField(max_length=200, default="")
    cgstperc = models.CharField(max_length=200, default="")
    addstock = models.CharField(max_length=200, default="")
    
    class Meta:
        db_table = "RawMaterial_tbl"   
        ordering = ["id"]  

class PurchaseSupplierNames(models.Model):
    cusid = models.CharField(max_length=200)
    name = models.CharField(max_length=200, default="")
    address = models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    balance = models.CharField(max_length=200, default="")
    gstno = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "SupplierSetting_tbl"   
        ordering = ["id"]  
class PurchasePaymentSNo(models.Model):
    cusid = models.CharField(max_length=200)
    payno = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "PayNo_tbl"   
        ordering = ["id"]  

class PurchasePayments(models.Model):
    cusid = models.CharField(max_length=200)
    date = models.DateField()
    agentname = models.CharField(max_length=200, default="")
    paytype = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "PurchasePayments_tbl"
        ordering = ["id"]  

class PurchaseRoundDetails_Model(models.Model):
    cusid= models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default="")
    date = models.DateField()  
    purchasername = models.CharField(max_length=200, default="")
    count = models.CharField(max_length=200, default="")
    total = models.CharField(max_length=200, default="")
    name = models.CharField(max_length=200, default="")
    invoiceno = models.CharField(max_length=200, default="")
    finlaldis = models.CharField(max_length=200, default="")
    round = models.CharField(max_length=200, default="")
    cgst0 = models.CharField(max_length=200, default="")
    cgst25 = models.CharField(max_length=200, default="")
    cgst6 = models.CharField(max_length=200, default="")
    cgst9 = models.CharField(max_length=200, default="")
    cgst14 = models.CharField(max_length=200, default="")
    sgst0 = models.CharField(max_length=200, default="")
    sgst25 = models.CharField(max_length=200, default="")
    sgst6 = models.CharField(max_length=200, default="")
    sgst9 = models.CharField(max_length=200, default="")
    sgst14 = models.CharField(max_length=200, default="")
    igst0 = models.CharField(max_length=200, default="")
    igst5 = models.CharField(max_length=200, default="")
    igst12 = models.CharField(max_length=200, default="")
    igst18 = models.CharField(max_length=200, default="")
    igst28 = models.CharField(max_length=200, default="")
    cess = models.CharField(max_length=200, default="")
    totcgst = models.CharField(max_length=200, default="")
    totsgst = models.CharField(max_length=200, default="")
    totigst = models.CharField(max_length=200, default="")
    totcess = models.CharField(max_length=200, default="")
    proddis = models.CharField(max_length=200, default="")    
    taxable = models.CharField(max_length=200, default="")
    gstmethod = models.CharField(max_length=200, default="")
    disperc = models.CharField(max_length=200, default="")
    agentid = models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    gstno = models.CharField(max_length=200, default="")
    finaltaxable = models.CharField(max_length=200, default="")
    PurchaseDetails = models.TextField(default="")

    class Meta:
        db_table = "PurchaseRoundDetails_tbl"
        ordering = ["id"]  

# / Purchase

# Order Sales

class OrderSnoModel(models.Model):
    cusid = models.CharField(max_length=200)
    orderserialno = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "OrderSalesSNo_tbl"
        ordering = ["id"]

class OrderPaymentModel(models.Model):
    cusid = models.CharField(max_length=200)
    billno = models.CharField(max_length=200, default="")
    dt = models.DateField( default="")
    cusname = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")
    paytype = models.CharField(max_length=200, default="")
    des = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "OrderPayment_tbl"
        ordering = ["id"]  

class OrderSalesRoundDetails_Model(models.Model):
    
    cusid = models.CharField(max_length=200)
    billno = models.CharField(max_length=200, default="")
    dt = models.DateField(default="")  
    cusname = models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    type = models.CharField(max_length=200, default="")
    count = models.CharField(max_length=200, default="")
    amount = models.CharField(max_length=200, default="")
    discount = models.CharField(max_length=200, default="")
    vat = models.CharField(max_length=200, default="")
    finalamount = models.CharField(max_length=200, default="")
    cgst0 = models.CharField(max_length=200, default="")
    cgst25 = models.CharField(max_length=200, default="")
    cgst6= models.CharField(max_length=200, default="")
    cgst9= models.CharField(max_length=200, default="")
    cgst14= models.CharField(max_length=200, default="")
    sgst0= models.CharField(max_length=200, default="")
    sgst25= models.CharField(max_length=200, default="")
    sgst6= models.CharField(max_length=200, default="")
    sgst9= models.CharField(max_length=200, default="")
    sgst14= models.CharField(max_length=200, default="")
    totcgst= models.CharField(max_length=200, default="")
    totsgst= models.CharField(max_length=200, default="")
    payableamount = models.CharField(max_length=200, default="")
    paidamount = models.CharField(max_length=200, default="")
    balanceamount = models.CharField(max_length=200, default="")
    deliverydate = models.DateField( default="")
    ordertype = models.CharField(max_length=200, default="")
    paytype = models.CharField(max_length=200, default="")
    time = models.DateTimeField(max_length=200, default="")
    gststatus = models.CharField(max_length=200, default="")
    taxstatus = models.CharField(max_length=200, default="")
    finaltaxable = models.CharField(max_length=200, default="")
    dispperc = models.CharField(max_length=200, default="")
    OrderDetails = models.TextField(default="")
    class Meta:
        db_table = "OrderSalesRoundDetails_tbl"
        ordering = ["id"]

# / Order Sales

# Vendor Sales

class VendorSnoModel(models.Model):
    cusid = models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "VendorSNo_tbl"
        ordering = ["id"]

class VendorsNameModel(models.Model):
    cusid = models.CharField(max_length=200)
    Name = models.CharField(max_length=200, default="")
    Address = models.CharField(max_length=200, default="")
    Contact = models.CharField(max_length=200, default="")
    MailId = models.CharField(max_length=200, default="")
    Commision =models.CharField(max_length=200, default="")  # Use timezone.now as the default    
    class Meta:
        db_table = "VendorCustomer_tbl"
        ordering = ["id"]


class Vendorpayment(models.Model):
    cusid = models.CharField(max_length=200)
    billno = models.CharField(max_length=200, default="")
    cusname = models.CharField(max_length=200, default="")
    dt = models.DateField()
    amount =models.CharField(max_length=200, default="")
    description = models.CharField(max_length=200, default="")
    paytype = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "Vendorpayment_tbl"
        ordering = ["id"] 

# / Vendor Sales

# DaySheet

class IncomeModel(models.Model):
    cusid=models.CharField(max_length=200,)
    dt = models.DateField(default=" ") 
    description = models.CharField(max_length=200, default=" ")
    amount = models.CharField(max_length=200, default=" ")

    class Meta:
        db_table = "Income_tbl"
        ordering = ["id"]  

class ExpenseModel(models.Model):
    cusid = models.CharField(max_length=200)
    dt = models.DateField(default=" ")
    cat = models.CharField(max_length=200, default=" ")
    amount = models.CharField(max_length=200, default=" ")
    description = models.CharField(max_length=200, default=" ")
    name = models.CharField(max_length=200, default="")
    type = models.CharField(max_length=200, default=" ")

    class Meta:
        db_table = "Expence_tbl"
        ordering = ["id"]  

class ExpenseCatModel(models.Model):
    cusid = models.CharField(max_length=200)

    name = models.CharField(max_length=200, default="")

    class Meta:
        db_table = "ExpCat_tbl"
        ordering = ["id"]  
 
# / DaySheet

# Kitchen Usage

class Usageserialno_Model(models.Model):
    cusid = models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default=" ")


    class Meta:
        db_table = "MaterialUsageSno_tbl"
        ordering = ["id"]

class UsageRound_Details_Model(models.Model):
    cusid = models.CharField(max_length=200)
    billno = models.CharField(max_length=200, default=" ")

    dt = models.DateField(auto_now_add=True)
    employee = models.CharField(max_length=200, default=" ")
    count = models.CharField(max_length=200, default=" ")
    name = models.CharField(max_length=200, default="")
    UsageDetails = models.TextField()

    class Meta:
        db_table = "MaterialUsageRoundDetails_tbl"
        ordering = ["id"]

# / Kitchen Usage

# Stock 
class Stock_Sno(models.Model):
    cusid = models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default=" ")


    class Meta:
        db_table = "StockSNo_tbl"
        ordering = ["id"]

class Stock_Details_Round(models.Model):
    cusid = models.CharField(max_length=200)

    serialno = models.CharField(max_length=200, default="")
    date = models.DateTimeField(auto_now_add=True)
    agentname = models.CharField(max_length=200, default="")
    itemcount = models.CharField(max_length=200, default="")
    status = models.CharField(max_length=200, default="")
    StockDetails = models.TextField()

    class Meta:
        db_table = "StockRoundDetails_tbl"
        ordering = ["id"] 


# / Stock 

# Wastage

class Wastage_serialno(models.Model):
    cusid = models.CharField(max_length=200)
    serialno = models.CharField(max_length=200, default=" ")


    class Meta:
        db_table = "WastageSerialno_tbl"
        ordering = ["id"]


class  Wastage_Details_Round(models.Model):
    cusid = models.CharField(max_length=200)

    serialno = models.CharField(max_length=200, default="")
    date = models.DateTimeField(auto_now_add=True)
    agentname = models.CharField(max_length=200, default="")
    itemcount = models.CharField(max_length=200, default="")
    status = models.CharField(max_length=200, default="")
    WastageDetails = models.TextField()

    class Meta:
        db_table = "WastageRoundDetails_tbl"
        ordering = ["id"] 

# / Wastage


class PrintInfo_tbl(models.Model):
    shopname = models.CharField(max_length=200, default="")
    area = models.CharField(max_length=200, default="")
    area2 = models.CharField(max_length=200, default="")
    city = models.CharField(max_length=200, default="")
    gstno = models.CharField(max_length=200, default="")
    fssai = models.CharField(max_length=200, default="")
    contact = models.CharField(max_length=200, default="")
    class Meta:
        db_table = "PrinterInfo_tbl"
        ordering = ["id"]  
