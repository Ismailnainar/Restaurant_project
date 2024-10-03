from rest_framework import serializers

from .models import *

class CompanyDetailsserializers(serializers.ModelSerializer):
    class Meta:
        model = CompanyDetails
        fields = "__all__"

class Shopinfoserializers(serializers.ModelSerializer):
    class Meta:
        model = Shopinfo
        fields = "__all__"

class LogReportserializers(serializers.ModelSerializer):
    class Meta:
        model = LogReport
        fields = "__all__"
# Setting
class CustomerIdserializers(serializers.ModelSerializer):
    class Meta:
        model = CustomerId
        fields = "__all__"

class TrialIDserializers(serializers.ModelSerializer):
    class Meta:
        model = TrialID
        fields = "__all__"

class TrialUserRegistrationserializers(serializers.ModelSerializer):
    class Meta:
        model = TrialUserRegistrationModel
        fields = "__all__"

class Amc_tblserializers(serializers.ModelSerializer):
    class Meta:
        model = Amc_tbl
        fields = "__all__"

class Settings_ProductCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_ProductCategory
        fields = "__all__"

class Settings_ProductDetailsSNoserializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_ProductDetailsSNo
        fields = "__all__"

class Settings_ProductDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_ProductDetails
        fields = "__all__"

class GstDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = GstDetailsModel
        fields = "__all__"

class StaffDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = StaffDetailsModel
        fields = "__all__"
        
class Settings_PrinterDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_PrinterDetails
        fields = "__all__"

class PaymentMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentMethodModel
        fields = "__all__"

class PointSettingSerializer(serializers.ModelSerializer):
    class Meta:
        model = PointSettingModel
        fields = "__all__"

class Settings_ComboSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_ComboModel
        fields = "__all__"


class Settings_PasswordSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_PasswordModel
        fields = "__all__"

class Settings_RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_RoledModel
        fields = "__all__"


class Settings_MenuitemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_Menuitem
        fields = "__all__"

class Settings_usermanagementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_usermanagement
        fields = "__all__"


class Settings_usermanagementcusidSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings_usermanagement
        fields = "__all__"

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        CategoryStatus_list = []
        CategoryStatus = instance.CategoryStatus.strip('{}').split('}{')
        
        for detail in CategoryStatus:
            # Parse each detail string directly
            detail_dict = {}
            # Split the detail string by commas
            for field in detail.split(','):
                # Split each field by colon to get key and value
                key, value = field.split(':')
                # Remove any leading/trailing spaces and quotes from key and value
                key = key.strip().strip("'\"")
                value = value.strip().strip("'\"")
                # Add key-value pair to detail dictionary
                detail_dict[key] = value
            
            # Add parsed detail dictionary to SalesDetails_list
            CategoryStatus_list.append(detail_dict)
        
        representation['CategoryStatus'] =CategoryStatus_list
        return representation



#/ Setting

# Dashboard

# / Dashboard

# Sales 

class Sales_Details_Round_Serializer(serializers.ModelSerializer):
    class Meta:
        model = SalesRoundDetails_Model
        fields = "__all__"
        
# / Sales

# Purchase

class PurchaseRoundDetaileserializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseRoundDetails_Model
        fields = "__all__"

class PurchaseProductCategoryserializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseProductCategory
        fields = "__all__"
        
class PurchaseProductDetailsserializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseProductDetails
        fields = "__all__"

class PurchaseSupplierNameserializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseSupplierNames
        fields = "__all__"

class PurchasePaymentsserializer(serializers.ModelSerializer):
    class Meta:
        model = PurchasePayments
        fields = "__all__"

class PurchasePaymentSNoserializer(serializers.ModelSerializer):
    class Meta:
        model = PurchasePaymentSNo
        fields = "__all__"

class Purchse_serialnoserializer(serializers.ModelSerializer):
    class Meta:
        model = Purchse_serialno
        fields = "__all__"

class PurchaseProductDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseProductDetails
        fields = "__all__"

# / Purchase

# Order Sales
class OrderSnoSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderSnoModel
        fields = "__all__"

class OrderPaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderPaymentModel
        fields = "__all__"

class OrderSalesRoundDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderSalesRoundDetails_Model
        fields = "__all__"

# / Order Sales

# Vendor sales
class VendorSnoSerializer(serializers.ModelSerializer):
    class Meta:
        model = VendorSnoModel
        fields = "__all__"

class VendorsNameSerializer(serializers.ModelSerializer):
    class Meta:
        model = VendorsNameModel
        fields = "__all__"

class VendorpaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vendorpayment
        fields = "__all__"


# / Vendor sales



class Customernamewuisesalesseriallizers(serializers.ModelSerializer):
    class Meta:
        model = SalesRoundDetails_Model
        fields = "__all__"

class DateWiseSalesRoundDetailsserillizers(serializers.ModelSerializer):
    class Meta:
        model = SalesRoundDetails_Model
        fields = "__all__"

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        SalesDetails_list = []
        SalesDetails = instance.SalesDetails.strip('{}').split('}{')
        
        for detail in SalesDetails:
            # Parse each detail string directly
            detail_dict = {}
            # Split the detail string by commas
            for field in detail.split(','):
                # Split each field by colon to get key and value
                key, value = field.split(':')
                # Remove any leading/trailing spaces and quotes from key and value
                key = key.strip().strip("'\"")
                value = value.strip().strip("'\"")
                # Add key-value pair to detail dictionary
                detail_dict[key] = value
            
            # Add parsed detail dictionary to SalesDetails_list
            SalesDetails_list.append(detail_dict)
        
        representation['SalesDetails'] = SalesDetails_list
        return representation
    
class DateSelectedSalesRoundDetailsserillizers(serializers.ModelSerializer):
    class Meta:
        model = SalesRoundDetails_Model
        fields = [ 'SalesDetails', 'count', 'paytype']
        
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        SalesDetails_list = []
        SalesDetails = instance.SalesDetails.strip('{}').split('}{')
        
        for detail in SalesDetails:
            # Parse each detail string directly
            detail_dict = {}
            # Split the detail string by commas
            for field in detail.split(','):
                # Split each field by colon to get key and value
                key, value = field.split(':')
                # Remove any leading/trailing spaces and quotes from key and value
                key = key.strip().strip("'\"")
                value = value.strip().strip("'\"")
                # Add key-value pair to detail dictionary
                detail_dict[key] = value
            
            # Add parsed detail dictionary to SalesDetails_list
            SalesDetails_list.append(detail_dict)
        
        representation['SalesDetails'] = SalesDetails_list
        return representation


class DateWisePurchaseRoundDetailsserillizers(serializers.ModelSerializer):
    class Meta:
        model = PurchaseRoundDetails_Model
        fields = "__all__"

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        PurchaseDetails_list = []
        PurchaseDetails = instance.PurchaseDetails.strip('{}').split('}{')
        
        for detail in PurchaseDetails:
            # Parse each detail string directly
            detail_dict = {}
            # Split the detail string by commas
            for field in detail.split(','):
                # Split each field by colon to get key and value
                key, value = field.split(':')
                # Remove any leading/trailing spaces and quotes from key and value
                key = key.strip().strip("'\"")
                value = value.strip().strip("'\"")
                # Add key-value pair to detail dictionary
                detail_dict[key] = value
            
            # Add parsed detail dictionary to PurchaseDetails_list
            PurchaseDetails_list.append(detail_dict)
        
        representation['PurchaseDetails'] = PurchaseDetails_list
        return representation
    

class SalesCustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = SalesCustomerModel
        fields = "__all__"

class Sales_serialnoserializers(serializers.ModelSerializer):
    class Meta:
        model = Sales_serialno
        fields = "__all__"

class Sales_Details_Round_tblSerializers(serializers.ModelSerializer):
    class Meta:
        model = SalesRoundDetails_Model
        fields = "__all__"

class SalesPaymentRoundDetailsSerializers(serializers.ModelSerializer):
    class Meta:
        model = SalesPaymentRoundDetails
        fields = "__all__"
    
class SalesPaymentDetailedSerializers(serializers.ModelSerializer):
    class Meta:
        model = SalesPaymentRoundDetails
        fields = "__all__"

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        
        # Parse salespaymentdetails string into a list of dictionaries
        sales_payment_details = instance.salespaymentdetails.strip('[]').split('}, {')
        sales_details_list = []
        for detail in sales_payment_details:
            # Fixing the starting '{' in the first dictionary
            if detail.startswith('{'):
                detail = detail[1:]
            # Fixing the ending '}' in the last dictionary
            if detail.endswith('}'):
                detail = detail[:-1]
            detail_dict = {}
            for field in detail.split(','):
                key, value = field.split(':')
                detail_dict[key.strip().strip("'\"")] = value.strip().strip("'\"")
            sales_details_list.append(detail_dict)
        
        representation['salespaymentdetails'] = sales_details_list
        return representation

class SalesPaymentSnoserializer(serializers.ModelSerializer):
    class Meta:
        model = SalesPaymentSno
        fields = "__all__"

class Sales_tableCountserializer(serializers.ModelSerializer):
    class Meta:
        model = Sales_tableCount
        fields = "__all__"

# For Order

#For Vendor Sales


# For Daysheet
class IncomeSerializer(serializers.ModelSerializer):
    class Meta:
        model = IncomeModel
        fields = "__all__"

class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseModel
        fields = "__all__"

class ExpenseCatSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseCatModel
        fields = "__all__"


# For Stock
class Stock_Sno_Serializer(serializers.ModelSerializer):
    class Meta:
        model = Stock_Sno
        fields = "__all__"
class Stock_Details_RoundSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stock_Details_Round
        fields = "__all__"


# For Wastage
class Wastage_serialnoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wastage_serialno
        fields = "__all__"

class Wastage_Details_RoundSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wastage_Details_Round
        fields = "__all__"


# For Kitchen-Usage
class Usageserialno_Serializer(serializers.ModelSerializer):
    class Meta:
        model = Usageserialno_Model
        fields = "__all__"
class UsageRound_Details_Serializer(serializers.ModelSerializer):
    class Meta:
        model = UsageRound_Details_Model
        fields = "__all__"

class PrintInfo_tblserillizer(serializers.ModelSerializer):
    class Meta:
        model = PrintInfo_tbl
        fields = "__all__"