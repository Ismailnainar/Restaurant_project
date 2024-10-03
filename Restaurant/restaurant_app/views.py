from django.utils import timezone
from django.db.models import DateField
from django.db.models.functions import Cast
from django.db.models import Q

from django.http import HttpResponse
from django.views.generic import View

import time
from rest_framework import viewsets
from django.utils.timezone import make_aware
from calendar import month_name
from datetime import datetime, timedelta
import json
from django.shortcuts import render
from rest_framework import status
from django.db.models import Sum
from datetime import date
import json
from .models import *
from .serializers import  *
from rest_framework.decorators import api_view
from rest_framework import viewsets
from django.db.models import Sum
from rest_framework.response import Response
from datetime import date
from rest_framework import pagination
from django.middleware.csrf import get_token
from django.http import HttpResponse
from rest_framework.permissions import AllowAny
from restaurant_app import models
from django.db.models import Min
from rest_framework.exceptions import ValidationError

# Page Pagination

class CustomPagination(pagination.PageNumberPagination):
    page_size = 10
    page_size_query_param = "page_size"
    max_page_size = 100


class CompanyDetailsView(viewsets.ModelViewSet):
    queryset = CompanyDetails.objects.all()
    serializer_class = CompanyDetailsserializers


class ShopinfoView(viewsets.ModelViewSet):
    queryset = Shopinfo.objects.all()
    serializer_class = Shopinfoserializers
    pagination_class = CustomPagination

class LogReportView(viewsets.ModelViewSet):
    queryset = LogReport.objects.all()
    serializer_class = LogReportserializers
    pagination_class = CustomPagination
# Setting

class CustomerIdView(viewsets.ModelViewSet):
    queryset = CustomerId.objects.all()
    serializer_class = CustomerIdserializers
    pagination_class = CustomPagination

class CustomerI_LastdView(viewsets.ModelViewSet):
    queryset = CustomerId.objects.all()
    serializer_class = CustomerIdserializers

    def list(self, request, *args, **kwargs):
        
        # Filter the queryset by cusid
        queryset = self.get_queryset()
        
        if queryset.exists():
            # Extract the numeric part from the serial number for ordering
            queryset = sorted(queryset, key=lambda x: int(''.join(filter(str.isdigit, x.customerid))), reverse=True)
            highest_serial_no = queryset[0].customerid
        else:
            # Assume serial number as 0 if no records exist for the given cusid
            highest_serial_no = 0

        return Response({"customerid": highest_serial_no})


class TrialIDView(viewsets.ModelViewSet):
    queryset = TrialID.objects.all()
    serializer_class = TrialIDserializers
    pagination_class = CustomPagination

class TrialUserRegistrationView(viewsets.ModelViewSet):
    queryset = TrialUserRegistrationModel.objects.all()
    serializer_class =TrialUserRegistrationserializers
    pagination_class = CustomPagination

class Amc_tblView(viewsets.ModelViewSet):
    serializer_class = Amc_tblserializers
    
    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        if cusid:
            return Amc_tbl.objects.filter(cusid=cusid)
        return Amc_tbl.objects.none()  

class Settings_ProductCategoryAllDataView(viewsets.ModelViewSet):
    queryset = Settings_ProductCategory.objects.all()
    serializer_class = Settings_ProductCategorySerializer
    pagination_class = CustomPagination
 
class Settings_ProductCategoryView(viewsets.ModelViewSet):
    serializer_class = Settings_ProductCategorySerializer
    pagination_class = CustomPagination
  
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_ProductCategory.objects.filter(cusid=cusid).order_by('id')
        return Settings_ProductCategory.objects.all().order_by('id')
    
class SettingsProductDetailsSNoalldatasView(viewsets.ModelViewSet):
    queryset = Settings_ProductDetailsSNo.objects.all()
    serializer_class = Settings_ProductDetailsSNoserializer

class Settings_ProductDetailsSNoView(viewsets.ModelViewSet):
    queryset = Settings_ProductDetailsSNo.objects.all()
    serializer_class = Settings_ProductDetailsSNoserializer

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid is None:
            return Response({"error": "Customer ID is required"}, status=400)
        queryset = self.get_queryset().filter(cusid=cusid)
        if queryset.exists():
            highest_serial_no = queryset.order_by('-sno').first().sno
        else:
            # Assume serial number as 0 if no records exist for the given cusid
            highest_serial_no = 0  
        
        return Response({"sno": highest_serial_no})

class SettingsProductDetailsalldatasView(viewsets.ModelViewSet):
    queryset = Settings_ProductDetails.objects.all()
    serializer_class = Settings_ProductDetailsSerializer
    pagination_class = CustomPagination

class Settings_ProductDetailsView(viewsets.ModelViewSet):
    serializer_class = Settings_ProductDetailsSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_ProductDetails.objects.filter(cusid=cusid).order_by('id')
        return Settings_ProductDetails.objects.all().order_by('id')

class SettingsComboalldatasView(viewsets.ModelViewSet):
    queryset = Settings_ComboModel.objects.all()
    serializer_class = Settings_ComboSerializer
    pagination_class = CustomPagination

class Settings_ComboView(viewsets.ModelViewSet):
    serializer_class = Settings_ComboSerializer
    pagination_class = CustomPagination

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_ComboModel.objects.filter(cusid=cusid).order_by('id')
        return Settings_ComboModel.objects.all().order_by('id')

class GstDetailsalldatasView(viewsets.ModelViewSet):
    queryset = GstDetailsModel.objects.all()
    serializer_class = GstDetailsSerializer

class GstDetailsView(viewsets.ModelViewSet):
    serializer_class = GstDetailsSerializer

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return GstDetailsModel.objects.filter(cusid=cusid).order_by('id')
        return GstDetailsModel.objects.all().order_by('id')

class StaffDetailsalldatasView(viewsets.ModelViewSet): 
    queryset = StaffDetailsModel.objects.all()
    serializer_class = StaffDetailsSerializer
    pagination_class = CustomPagination
   
class StaffDetailsView(viewsets.ModelViewSet):
    serializer_class = StaffDetailsSerializer
    pagination_class = CustomPagination

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return StaffDetailsModel.objects.filter(cusid=cusid).order_by('id')
        return StaffDetailsModel.objects.all().order_by('id')

class PaymentMethodalldatasView(viewsets.ModelViewSet): 
    queryset = PaymentMethodModel.objects.all()
    serializer_class = PaymentMethodSerializer
    pagination_class = CustomPagination

class PaymentMethodView(viewsets.ModelViewSet):
    serializer_class = PaymentMethodSerializer

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return PaymentMethodModel.objects.filter(cusid=cusid).order_by('id')
        return PaymentMethodModel.objects.all().order_by('id')

class PointSettingalldatasView(viewsets.ModelViewSet): 
    queryset = PointSettingModel.objects.all()
    serializer_class = PointSettingSerializer

class PointSettingView(viewsets.ModelViewSet):
    serializer_class = PointSettingSerializer
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return PointSettingModel.objects.filter(cusid=cusid).order_by('id')
        return PointSettingModel.objects.all().order_by('id')

class SettingsPrinterDetailsalldatasView(viewsets.ModelViewSet): 
    queryset = Settings_PrinterDetails.objects.all()
    serializer_class = Settings_PrinterDetailsSerializer

class Settings_PrinterDetailsView(viewsets.ModelViewSet):
    serializer_class = Settings_PrinterDetailsSerializer
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_PrinterDetails.objects.filter(cusid=cusid).order_by('id')
        return Settings_PrinterDetails.objects.all().order_by('id')

class Settings_PasswordalldatasView(viewsets.ModelViewSet):
    queryset = Settings_PasswordModel.objects.all()
    serializer_class = Settings_PasswordSerializer
    pagination_class = CustomPagination

class Settings_PasswordView(viewsets.ModelViewSet):
    serializer_class = Settings_PasswordSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_PasswordModel.objects.filter(cusid=cusid).order_by('id')
        return Settings_PasswordModel.objects.all().order_by('id')

class Settings_RolealldatasView(viewsets.ModelViewSet):
    queryset = Settings_RoledModel.objects.all()
    serializer_class = Settings_RoleSerializer
    pagination_class = CustomPagination

class Settings_RoleView(viewsets.ModelViewSet):
    serializer_class = Settings_RoleSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_RoledModel.objects.filter(cusid=cusid).order_by('id')
        return Settings_RoledModel.objects.all().order_by('id')




class Settings_MenuitemView(viewsets.ModelViewSet):
    queryset = Settings_Menuitem.objects.all()
    serializer_class = Settings_MenuitemSerializer
    # pagination_class = CustomPagination


class Settings_usermanagementalldatasView(viewsets.ModelViewSet):
    queryset = Settings_usermanagement.objects.all()
    serializer_class = Settings_usermanagementSerializer
    pagination_class = CustomPagination


class Settings_usermanagementView(viewsets.ModelViewSet):
    serializer_class = Settings_usermanagementcusidSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Settings_usermanagement.objects.filter(cusid=cusid).order_by('id')
        return Settings_usermanagement.objects.all().order_by('id')

#/ Setting

# DashBoard

class DashboardTodayRecordsView(viewsets.ViewSet):
    def list(self, request, cusid=None, *args, **kwargs):
        today = date.today()
        
        # Filter the queryset for today's date, "Normal" status, and the provided cusid
        normal_sales = SalesRoundDetails_Model.objects.filter(Status='Normal', dt=today, cusid=cusid)
        vendor_sales = SalesRoundDetails_Model.objects.filter(Status='Vendor', dt=today, cusid=cusid)
        order_sales = OrderSalesRoundDetails_Model.objects.filter(dt=today, cusid=cusid)
        purchase_amount = PurchaseRoundDetails_Model.objects.filter(date=today, cusid=cusid)

        # Calculate the total amounts
        total_normal_amount = normal_sales.aggregate(Sum('finalamount'))['finalamount__sum'] or 0
        total_vendor_amount = vendor_sales.aggregate(Sum('finalamount'))['finalamount__sum'] or 0
        total_order_amount = order_sales.aggregate(Sum('finalamount'))['finalamount__sum'] or 0
        total_purchase_amount = purchase_amount.aggregate(Sum('total'))['total__sum'] or 0

        # Create the response data
        response_data = {
            'today_total_sales': total_normal_amount,
            'today_vendor_sales': total_vendor_amount,
            'today_order_sales': total_order_amount,
            'today_purchase_sales': total_purchase_amount
        }
        
        return Response(response_data)

class DashboardWeeklyRecordsView(viewsets.ViewSet):
    def list(self, request, cusid=None, *args, **kwargs):
        today = date.today()
        seven_days_ago = today - timedelta(days=7)
        
        # Filter IncomeModel and ExpenseModel queryset for last 7 days and the provided cusid
        income_last_7_days_queryset = IncomeModel.objects.filter(dt__gte=seven_days_ago, cusid=cusid)
        expenses_last_7_days_queryset = ExpenseModel.objects.filter(dt__gte=seven_days_ago, cusid=cusid)

        # Get unique dates in the last 7 days for income and expenses
        income_unique_dates = income_last_7_days_queryset.values_list("dt", flat=True).distinct()
        expenses_unique_dates = expenses_last_7_days_queryset.values_list("dt", flat=True).distinct()

        # Calculate the sum of amount for each date for income
        income_dt_wise_sum = []
        income_processed_dates = set()

        for dt in income_unique_dates:
            if dt not in income_processed_dates:
                daily_total = income_last_7_days_queryset.filter(dt=dt).aggregate(
                    amount_sum=Sum("amount")
                )
                income_dt_wise_sum.append(
                    {
                        "dt": dt.strftime("%Y-%m-%d"),
                        "amount_sum": str(daily_total["amount_sum"] or 0),
                    }
                )
                income_processed_dates.add(dt)

        # Calculate the sum of amount for each date for expenses
        expenses_dt_wise_sum = []
        expenses_processed_dates = set()

        for dt in expenses_unique_dates:
            if dt not in expenses_processed_dates:
                daily_total = expenses_last_7_days_queryset.filter(dt=dt).aggregate(
                    amount_sum=Sum("amount")
                )
                expenses_dt_wise_sum.append(
                    {
                        "dt": dt.strftime("%Y-%m-%d"),
                        "amount_sum": str(daily_total["amount_sum"] or 0),
                    }
                )
                expenses_processed_dates.add(dt)

        response = {
            "IncomeLast7DaysDetails": income_dt_wise_sum,
            "ExpensesLast7DaysDetails": expenses_dt_wise_sum,
        }

        return Response(response)

class DashboardOrderSalesDetailsView(viewsets.ModelViewSet):
    queryset = OrderSalesRoundDetails_Model.objects.all()
    serializer_class = OrderSalesRoundDetailSerializer

    def list(self, request,cusid=None, *args, **kwargs):
        # Get the current date (today) in the current timezone
        today = date.today()

        order_today = OrderSalesRoundDetails_Model.objects.filter(dt=today, cusid=cusid)
        sum_OrderSALES_amount_today = order_today.aggregate(total=Sum("finalamount"))[
            "total"
        ]

        order_today_details = [
            {
                "billno": record.billno,
                "finalamount": record.finalamount,
                "cusname": record.cusname,
                "contact": record.contact,
                "deliverydate": record.deliverydate,
            }
            for record in order_today
        ]

        response = {
            "sum_OrderSALES_amount_today": sum_OrderSALES_amount_today,
            "order_today_details": order_today_details,
        }
        return Response(response)

class DashboardTopSellingView(viewsets.ViewSet):
    def list(self, request, cusid=None, *args, **kwargs):
        target_date = date.today()

        # Filter sales details for the target date and statuses
        sales_details = SalesRoundDetails_Model.objects.filter(
            Q(dt=target_date, cusid=cusid) & (Q(Status='Normal') | Q(Status='Vendor'))
        )

        item_sales = {}

        for sale in sales_details:
            sales_details_str = sale.SalesDetails

            try:
                if sale.Status == 'Normal':
                    # Use the custom serializer to parse SalesDetails
                    serializer = DateWiseSalesRoundDetailsserillizers(sale)
                    sales_data_list = serializer.data['SalesDetails']
                elif sale.Status == 'Vendor':
                    # Vendor status uses a JSON array format
                    sales_data_list = json.loads(sales_details_str)
                else:
                    sales_data_list = []
            except json.JSONDecodeError:
                continue

            for sales_data in sales_data_list:
                itemname = sales_data.get("Itemname")
                qty = sales_data.get("qty")
                if itemname is not None and qty is not None:
                    if itemname in item_sales:
                        item_sales[itemname] += int(qty)
                    else:
                        item_sales[itemname] = int(qty)

        # Convert the item_sales dictionary to a list of dictionaries
        all_selling_items = [{"Itemname": item, "qty": qty} for item, qty in item_sales.items()]

        return Response({"top_selling_items": all_selling_items})


# / DashBoard

# Sales

class SalesCustomeralldatasView(viewsets.ModelViewSet):
    queryset = SalesCustomerModel.objects.all()
    serializer_class = SalesCustomerSerializer
    pagination_class = CustomPagination

class SalesCustomerView(viewsets.ModelViewSet):
    serializer_class = SalesCustomerSerializer
    pagination_class = CustomPagination

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return SalesCustomerModel.objects.filter(cusid=cusid).order_by('id')
        return SalesCustomerModel.objects.all().order_by('id')

class SalesPaymentSnoalldatasView(viewsets.ModelViewSet):
    queryset = SalesPaymentSno.objects.all()
    serializer_class = SalesPaymentSnoserializer

class SalesPaymentSnoView(viewsets.ModelViewSet):
    queryset = SalesPaymentSno.objects.all()
    serializer_class = SalesPaymentSnoserializer

    def list(self, request, cusid=None, *args, **kwargs):
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        # If queryset is not empty, get the highest serial number
        if queryset.exists():
            highest_serial_no = queryset.order_by('-sno').first().sno
        else:
            highest_serial_no = 0
        return Response({"sno": highest_serial_no})

class SalesPaymentRoundDetailsalldatasView(viewsets.ModelViewSet):
    queryset = SalesPaymentRoundDetails.objects.all()
    serializer_class = SalesPaymentRoundDetailsSerializers

class SalesPaymentRoundDetailsView(viewsets.ModelViewSet):
    serializer_class = SalesPaymentRoundDetailsSerializers

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return SalesPaymentRoundDetails.objects.filter(cusid=cusid).order_by('id')
        return SalesPaymentRoundDetails.objects.all().order_by('id')

class SalesPaymentDetailedalldatasView(viewsets.ModelViewSet):
    queryset = SalesPaymentRoundDetails.objects.all()
    serializer_class = SalesPaymentDetailedSerializers

class SalesPaymentDetaiedView(viewsets.ModelViewSet):
    serializer_class = SalesPaymentDetailedSerializers

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return SalesPaymentRoundDetails.objects.filter(cusid=cusid).order_by('id')
        return SalesPaymentRoundDetails.objects.all().order_by('id')

class Sales_tableCountalldatasView(viewsets.ModelViewSet):
    queryset = Sales_tableCount.objects.all()
    serializer_class = Sales_tableCountserializer
    pagination_class = CustomPagination

class Sales_tableCountView(viewsets.ModelViewSet):
    serializer_class = Sales_tableCountserializer
    pagination_class = CustomPagination

    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Sales_tableCount.objects.filter(cusid=cusid).order_by('id')
        return Sales_tableCount.objects.all().order_by('id')

class Sales_serialnoalldatasView(viewsets.ModelViewSet):
    serializer_class = Sales_serialnoserializers
    def get_queryset(self):
        return Sales_serialno.objects.all().order_by('id')

class Sales_serialnoView(viewsets.ModelViewSet):
    queryset = Sales_serialno.objects.all()
    serializer_class = Sales_serialnoserializers

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid is None:
            return Response({"error": "Customer ID is required"}, status=400)
        
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        
        if queryset.exists():
            # Extract the numeric part from the serial number for ordering
            queryset = sorted(queryset, key=lambda x: int(''.join(filter(str.isdigit, x.serialno))), reverse=True)
            highest_serial_no = queryset[0].serialno
        else:
            # Assume serial number as 0 if no records exist for the given cusid
            highest_serial_no = 0

        return Response({"serialno": highest_serial_no})

   
class Sales_IncomeDetailsView(viewsets.ModelViewSet):
    serializer_class = IncomeSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        return IncomeModel.objects.all().order_by('id')
   
class Sales_IncomeDetailsdatewiseView(viewsets.ModelViewSet):
    serializer_class = IncomeSerializer
    pagination_class = CustomPagination

    def get_queryset(self):
        queryset = IncomeModel.objects.all().order_by('id')
        cusid = self.kwargs.get('cusid')
        dt = self.kwargs.get('dt')

        if cusid:
            queryset = queryset.filter(cusid=cusid)
        if dt:
            queryset = queryset.filter(dt=dt)

        return queryset

class SalesRoundDetailsalldatas_View(viewsets.ModelViewSet):
    queryset = SalesRoundDetails_Model.objects.all()
    serializer_class = Sales_Details_Round_Serializer
    pagination_class = CustomPagination

class SalesRoundDetails_View(viewsets.ModelViewSet):
    serializer_class = Sales_Details_Round_Serializer
    pagination_class = CustomPagination
    
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return SalesRoundDetails_Model.objects.filter(cusid=cusid).order_by('id')
        return SalesRoundDetails_Model.objects.all().order_by('id')

class EditSalesreportsView(viewsets.ModelViewSet):
    serializer_class = DateWiseSalesRoundDetailsserillizers

    def get_queryset(self):
        # Get the parameters from URL
        cusid = self.kwargs.get('cusid')
        dt = self.kwargs.get('dt')
        billno = self.kwargs.get('billno')

        # Filter the queryset based on cusid first
        queryset = SalesRoundDetails_Model.objects.filter(cusid=cusid)

        # Further filter by dt and billno if they are provided
        if dt:
            queryset = queryset.filter(dt=dt)
        if billno:
            queryset = queryset.filter(billno=billno)

        return queryset
# / Sales

# Order Sales 
class Order_Snoalldata_View(viewsets.ModelViewSet):
    queryset = OrderSnoModel.objects.all()
    serializer_class = OrderSnoSerializer

class Order_Sno_View(viewsets.ModelViewSet):
    queryset = OrderSnoModel.objects.all()
    serializer_class = OrderSnoSerializer

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid is None:
            return Response({"error": "Customer ID is required"}, status=400)
        
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        
        if queryset.exists():
            # Extract the numeric part from the serial number for ordering
            queryset = sorted(queryset, key=lambda x: int(''.join(filter(str.isdigit, x.orderserialno))), reverse=True)
            highest_serial_no = queryset[0].orderserialno
        else:
            # Assume serial number as 0 if no records exist for the given cusid
            highest_serial_no = 0

        return Response({"orderserialno": highest_serial_no})

   
class OrderPaymentalldatas_View(viewsets.ModelViewSet):
    queryset = OrderPaymentModel.objects.all()
    serializer_class = OrderPaymentSerializer
    pagination_class = CustomPagination

class OrderPayment_View(viewsets.ModelViewSet):
    serializer_class = OrderPaymentSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return OrderPaymentModel.objects.filter(cusid=cusid).order_by('id')
        return OrderSalesRoundDetails_Model.objects.all().order_by('id')

class OrderSalesRoundDetailsalldetails_View(viewsets.ModelViewSet):
    queryset = OrderSalesRoundDetails_Model.objects.all()
    serializer_class = OrderSalesRoundDetailSerializer
    pagination_class = CustomPagination

class OrderSalesRoundDetails_View(viewsets.ModelViewSet):
    serializer_class = OrderSalesRoundDetailSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return OrderSalesRoundDetails_Model.objects.filter(cusid=cusid).order_by('id')
        return OrderSalesRoundDetails_Model.objects.all().order_by('id')

class EditOrderSalesView(viewsets.ViewSet):
    def list(self, request, cusid=None, dt=None, billno=None):
        try:
            dt = datetime.strptime(dt, '%Y-%m-%d').date()

            # Filter by cusid first
            queryset = OrderSalesRoundDetails_Model.objects.filter(cusid=cusid)

            if not queryset.exists():
                return Response({'error': 'Customer not found'}, status=status.HTTP_404_NOT_FOUND)

            # Filter the results by dt
            queryset = queryset.filter(dt=dt)

            if not queryset.exists():
                return Response({'error': 'No orders found for the given date'}, status=status.HTTP_404_NOT_FOUND)

            # Finally, filter by billno
            queryset = queryset.filter(billno=billno)

            if queryset.exists():
                serializer = OrderSalesRoundDetailSerializer(queryset.first())
                return Response(serializer.data)
            else:
                return Response({'error': 'Order not found'}, status=status.HTTP_404_NOT_FOUND)

        except ValueError:
            return Response({'error': 'Invalid date format'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
# / Order Sales

# Purchase 

class PurchaseserialNoalldatasView(viewsets.ModelViewSet):
    queryset = Purchse_serialno.objects.all()
    serializer_class = Purchse_serialnoserializer

class Purchase_serialNoView(viewsets.ModelViewSet):
    queryset = Purchse_serialno.objects.all()
    serializer_class = Purchse_serialnoserializer

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid:
            queryset = self.get_queryset().filter(cusid=cusid)
            if queryset.exists():
                highest_serial_no = queryset.order_by('-serialno').first().serialno
                return Response({"serialNo": highest_serial_no})
            else:
                return Response({"serialNo": 0})  # or return Response({})
        else:
            return Response({"error": "cusid not provided"}, status=400)

class PurchaseProductCategoryalldatasView(viewsets.ModelViewSet):
    queryset = PurchaseProductCategory.objects.all()
    serializer_class = PurchaseProductCategoryserializer
    pagination_class = CustomPagination
    
class PurchaseProductCategoryView(viewsets.ModelViewSet):
    serializer_class = PurchaseProductCategoryserializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return PurchaseProductCategory.objects.filter(cusid=cusid).order_by('id')
        return PurchaseProductCategory.objects.all().order_by('id')

class PurchaseProductDetailsalldatasView(viewsets.ModelViewSet):
    queryset = PurchaseProductDetails.objects.all()
    serializer_class = PurchaseProductDetailsSerializer
    pagination_class = CustomPagination
    
class PurchaseProductDetailsView(viewsets.ModelViewSet):
    serializer_class = PurchaseProductDetailsSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return PurchaseProductDetails.objects.filter(cusid=cusid).order_by('id')
        return PurchaseProductDetails.objects.all().order_by('id')

class PurchasePaymentSNoalldatasView(viewsets.ModelViewSet):
    queryset = PurchasePaymentSNo.objects.all()
    serializer_class = PurchasePaymentSNoserializer
    pagination_class = CustomPagination

class PurchasePaymentSNoView(viewsets.ModelViewSet):
    queryset = PurchasePaymentSNo.objects.all()
    serializer_class = PurchasePaymentSNoserializer

    def list(self, request, cusid=None, *args, **kwargs):
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        # If queryset is not empty, get the highest serial number
        if queryset.exists():
            highest_serial_no = queryset.order_by('-payno').first().payno
            # Return response in the format payno: "3"
            return Response({"payno": highest_serial_no})
        else:
            # Return an empty response if queryset is empty
            return Response({})

class PurchasePaymentsAlldatasView(viewsets.ModelViewSet):
    queryset = PurchasePayments.objects.all()
    serializer_class = PurchasePaymentsserializer

class PurchasePaymentsView(viewsets.ModelViewSet):
    queryset = PurchasePayments.objects.all()
    serializer_class = PurchasePaymentsserializer
    
    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid:
            queryset = self.get_queryset().filter(cusid=cusid).order_by('id')
        else:
            queryset = self.get_queryset().order_by('id')
        
        serializer = self.get_serializer(queryset, many=True)
        data = {"results": [{"serial_no": idx + 1, **item} for idx, item in enumerate(serializer.data)]}
        return Response(data)

class Purchase_ExpensesView(viewsets.ModelViewSet):
    queryset = ExpenseModel.objects.all()
    serializer_class = ExpenseSerializer

class PurchaseSupplierNamesalldatasView(viewsets.ModelViewSet):
    queryset = PurchaseSupplierNames.objects.all()
    serializer_class = PurchaseSupplierNameserializer
    pagination_class = CustomPagination
    
class PurchaseSupplierNamesView(viewsets.ModelViewSet):
    serializer_class = PurchaseSupplierNameserializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return PurchaseSupplierNames.objects.filter(cusid=cusid).order_by('id')
        return PurchaseSupplierNames.objects.all().order_by('id')

class PurchaseRoundDetailsalldatasView(viewsets.ModelViewSet):
    queryset = PurchaseRoundDetails_Model.objects.all()
    serializer_class = PurchaseRoundDetaileserializer
    pagination_class = CustomPagination
    
class PurchaseRoundDetails_View(viewsets.ModelViewSet):
    serializer_class = PurchaseRoundDetaileserializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return PurchaseRoundDetails_Model.objects.filter(cusid=cusid).order_by('id')
        return PurchaseRoundDetails_Model.objects.all().order_by('id')

class EditPurchasereportsView(viewsets.ModelViewSet):
    serializer_class = DateWisePurchaseRoundDetailsserillizers

    def get_queryset(self):
        # Get the parameters from URL
        cusid = self.kwargs['cusid']
        date = self.kwargs['date']
        serialno = self.kwargs['serialno']
        
        # Filter the queryset based on cusid first
        queryset = PurchaseRoundDetails_Model.objects.filter(cusid=cusid)
        
        # Further filter by date and serialno if they are provided
        if date:
            queryset = queryset.filter(date=date)
        if serialno:
            queryset = queryset.filter(serialno=serialno)
        
        return queryset

# / Purchase 

# Vendor Sales
class Vendor_Snoalldata_View(viewsets.ModelViewSet):
    queryset = VendorSnoModel.objects.all()
    serializer_class = VendorSnoSerializer

class Vendor_Sno_View(viewsets.ModelViewSet):

    queryset = VendorSnoModel.objects.all()
    serializer_class = VendorSnoSerializer

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid is None:
            return Response({"error": "Customer ID is required"}, status=400)
        
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        
        if queryset.exists():
            # Extract the numeric part from the serial number for ordering
            queryset = sorted(queryset, key=lambda x: int(''.join(filter(str.isdigit, x.serialno))), reverse=True)
            highest_serial_no = queryset[0].serialno
        else:
            # Assume serial number as 0 if no records exist for the given cusid
            highest_serial_no = 0

        return Response({"serialno": highest_serial_no})
 
   
class VendorsNamealldata(viewsets.ModelViewSet):
    queryset = VendorsNameModel.objects.all()
    serializer_class = VendorsNameSerializer
    pagination_class = CustomPagination
    
class VendorsNameView(viewsets.ModelViewSet):
    serializer_class = VendorsNameSerializer
    pagination_class = CustomPagination
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return VendorsNameModel.objects.filter(cusid=cusid).order_by('id')
        return VendorsNameModel.objects.all().order_by('id')
    
class SalesFetchVendorPaymentView(viewsets.ModelViewSet):
    queryset = SalesRoundDetails_Model.objects.filter(Status="Vendor", paytype="Credit")
    serializer_class = Sales_Details_Round_Serializer
    pagination_class = CustomPagination

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        # Use pagination to paginate the queryset
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            response = [
                {
                    "id": record["id"],
                    "cusid": record["cusid"],
                    "billno": record["billno"],
                    "FinalAmt": record["FinalAmt"],
                    "dt": record["dt"],
                    "vendorname": record["vendorname"],
                    "paidamount": record["paidamount"],
                    "disperc": record["disperc"],
                    "vendorcomPerc": record["vendorcomPerc"],
                    "CommisionAmt": record["CommisionAmt"],
                    "TotalAmount": record["TotalAmount"],
                }
                for record in serializer.data
            ]
            return self.get_paginated_response(response)
       
        return Response(response)
    


class SalesFetchVendorPaymentcusidView(viewsets.ModelViewSet):
    serializer_class = Sales_Details_Round_Serializer
    pagination_class = CustomPagination

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        queryset = SalesRoundDetails_Model.objects.filter(Status="Vendor", paytype="Credit")
        if cusid:
            queryset = queryset.filter(cusid=cusid)
        return queryset

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        # Use pagination to paginate the queryset
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            response = [
                {
                    "id": record["id"],
                    "cusid": record["cusid"],
                    "billno": record["billno"],
                    "FinalAmt": record["FinalAmt"],
                    "dt": record["dt"],
                    "vendorname": record["vendorname"],
                    "paidamount": record["paidamount"],
                    "disperc": record["disperc"],
                    "vendorcomPerc": record["vendorcomPerc"],
                    "CommisionAmt": record["CommisionAmt"],
                    "TotalAmount": record["TotalAmount"],
                }
                for record in serializer.data
            ]
            return self.get_paginated_response(response)

        return Response([])

    

class VendorpaymentView(viewsets.ModelViewSet):
    queryset = Vendorpayment.objects.all()
    serializer_class = VendorpaymentSerializer
    pagination_class = CustomPagination
# / Vendor sales

# Stock
class Stock_Snoalldata_View(viewsets.ModelViewSet):
    queryset = Stock_Sno.objects.all()
    serializer_class = Stock_Sno_Serializer

class Stock_Sno_View(viewsets.ModelViewSet):
    queryset = Stock_Sno.objects.all()
    serializer_class = Stock_Sno_Serializer

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        if cusid is None:
            return Response({"error": "Customer ID is required"}, status=400)
        
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        
        if queryset.exists():
            # Get the highest serial number if records exist
            highest_serial_no = queryset.order_by('-serialno').first().serialno
        else:
            # Assume serial number as 0 if no records exist for the given cusid
            highest_serial_no = 0

        return Response({"serialno": highest_serial_no})
        
class Stock_Details_Roundalldata_View(viewsets.ModelViewSet):
    queryset = Stock_Details_Round.objects.all()
    serializer_class = Stock_Details_RoundSerializer

class Stock_Details_Round_View(viewsets.ModelViewSet):
    serializer_class = Stock_Details_RoundSerializer
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Stock_Details_Round.objects.filter(cusid=cusid).order_by('id')
        return Stock_Details_Round.objects.all().order_by('id')
    
# / Stock

# Wastage

class Wastage_serialnoalldata_view(viewsets.ModelViewSet):
    queryset = Wastage_serialno.objects.all()
    serializer_class = Wastage_serialnoSerializer

class Wastage_serialno_view(viewsets.ModelViewSet):
    queryset = Wastage_serialno.objects.all()
    serializer_class = Wastage_serialnoSerializer

    def list(self, request, cusid=None, *args, **kwargs):
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        # If queryset is not empty, get the highest serial number
        if queryset.exists():
            highest_serial_no = queryset.order_by('-serialno').first().serialno
        else:
            highest_serial_no = 0
        return Response({"serialno": highest_serial_no})
        
class Wastage_Details_Roundalldata_View(viewsets.ModelViewSet):
    queryset = Wastage_Details_Round.objects.all()
    serializer_class = Wastage_Details_RoundSerializer

class Wastage_Details_Round_view(viewsets.ModelViewSet):
    serializer_class = Wastage_Details_RoundSerializer
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return Wastage_Details_Round.objects.filter(cusid=cusid).order_by('id')
        return Wastage_Details_Round.objects.all().order_by('id')
    
# / Wastage

# Kitchen usage

class Usageserialnoalldata_View(viewsets.ModelViewSet):
    queryset = Usageserialno_Model.objects.all()
    serializer_class = Usageserialno_Serializer

class Usageserialno_View(viewsets.ModelViewSet):
    queryset = Usageserialno_Model.objects.all()
    serializer_class = Usageserialno_Serializer

    def list(self, request, cusid=None, *args, **kwargs):
        # Filter the queryset by cusid
        queryset = self.get_queryset().filter(cusid=cusid)
        # If queryset is not empty, get the highest serial number
        if queryset.exists():
            highest_serial_no = queryset.order_by('-serialno').first().serialno
        else:
            highest_serial_no = 0
        return Response({"serialno": highest_serial_no})

class UsageRound_Detailsalldata_View(viewsets.ModelViewSet):
    queryset = UsageRound_Details_Model.objects.all()
    serializer_class = UsageRound_Details_Serializer

class UsageRound_Details_View(viewsets.ModelViewSet):
    serializer_class = UsageRound_Details_Serializer
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return UsageRound_Details_Model.objects.filter(cusid=cusid).order_by('id')
        return UsageRound_Details_Model.objects.all().order_by('id')
    
# / Kitchen Usage

# DaySheet

class IncomeEntryDetailalldatasView(viewsets.ModelViewSet):
    queryset = IncomeModel.objects.all()
    serializer_class = IncomeSerializer
    pagination_class = CustomPagination
  
class IncomeEntryDetailView(viewsets.ModelViewSet):
    serializer_class = IncomeSerializer
    pagination_class = CustomPagination

    def get_queryset(self):
        today_date = date.today()
        cusid = self.kwargs.get('cusid', None)
        
        if cusid is not None:
            queryset = IncomeModel.objects.filter(dt=today_date, cusid=cusid)
        else:
            queryset = IncomeModel.objects.filter(dt=today_date)
        
        return queryset

class ExpenseCatalldataView(viewsets.ModelViewSet):
    queryset = ExpenseCatModel.objects.all()
    serializer_class = ExpenseCatSerializer
    
class ExpenseCatView(viewsets.ModelViewSet):
    serializer_class = ExpenseCatSerializer
    def get_queryset(self):
        cusid = self.kwargs.get('cusid', None)
        if cusid is not None:
            return ExpenseCatModel.objects.filter(cusid=cusid).order_by('id')
        return ExpenseCatModel.objects.all().order_by('id')

class ExpenseEntryDetailalldataView(viewsets.ModelViewSet):
    queryset = ExpenseModel.objects.all()
    serializer_class = ExpenseSerializer
    pagination_class = CustomPagination
  
class ExpenseEntryDetailView(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer
    pagination_class = CustomPagination

    def get_queryset(self):
        today_date = date.today()
        cusid = self.kwargs.get('cusid', None)
        
        if cusid is not None:
            queryset = ExpenseModel.objects.filter(dt=today_date, cusid=cusid)
        else:
            queryset = ExpenseModel.objects.filter(dt=today_date)
        
        return queryset

# / DaySheet

# Graph

class SalesGraphView(viewsets.ModelViewSet):
    queryset = SalesRoundDetails_Model.objects.all()
    serializer_class = Sales_Details_Round_Serializer

    def list(self, request, *args, **kwargs):
        cusid = kwargs.get('cusid')
        today = date.today()
        # Last 7 days
        seven_days_ago = today - timedelta(days=7)
        last_7_days_queryset = SalesRoundDetails_Model.objects.filter(dt__gte=seven_days_ago, cusid=cusid)
        unique_dates_last_7_days = last_7_days_queryset.values_list("dt", flat=True).distinct()
        dt_wise_sum_last_7_days = self.calculate_amount_sum(last_7_days_queryset, unique_dates_last_7_days)

        # Previous month
        last_month_start = today.replace(day=1) - timedelta(days=1)
        last_month_end = last_month_start.replace(day=1)
        last_month_queryset = SalesRoundDetails_Model.objects.filter(dt__range=(last_month_end, last_month_start), cusid=cusid)
        unique_dates_last_month = last_month_queryset.values_list("dt", flat=True).distinct()
        dt_wise_sum_last_month = self.calculate_amount_sum(last_month_queryset, unique_dates_last_month)

        # Previous year
        previous_year_start = today.replace(year=today.year - 1, month=1, day=1)
        previous_year_end = today.replace(year=today.year - 1, month=12, day=31)
        previous_year_queryset = SalesRoundDetails_Model.objects.filter(dt__range=(previous_year_start, previous_year_end), cusid=cusid)
        unique_months_previous_year = previous_year_queryset.dates('dt', 'month', order='ASC')
        month_wise_sum_previous_year = self.calculate_amount_sumYear(previous_year_queryset, unique_months_previous_year)

        response = {
            "Last7DaysDetails": dt_wise_sum_last_7_days,
            "LastMonthDetails": dt_wise_sum_last_month,
            "PreviousYearMonthWiseDetails": month_wise_sum_previous_year,
        }

        return Response(response)

    def calculate_amount_sum(self, queryset, unique_dates):
        dt_wise_sum = []
        processed_dates = set()  # Keep track of processed dates

        for dt in unique_dates:
            if dt not in processed_dates:
                daily_total = queryset.filter(dt=dt).aggregate(amount_sum=Sum("finalamount"))
                dt_wise_sum.append(
                    {
                        "dt": dt.strftime("%Y-%m-%d"),
                        "amount_sum": str(daily_total["amount_sum"] or 0),
                    }
                )
                processed_dates.add(dt)

        return dt_wise_sum
    
    def calculate_amount_sumYear(self, queryset, unique_dates):
        dt_wise_sumyear = []

        for dt in unique_dates:
            monthly_total = queryset.filter(dt__month=dt.month, dt__year=dt.year).aggregate(amount_sum=Sum("finalamount"))
            amount_sum = monthly_total["amount_sum"] if monthly_total["amount_sum"] is not None else 0
            dt_wise_sumyear.append(
                {
                    "dt": month_name[dt.month],
                    "amount_sum": str(amount_sum),
                }
            )

        return dt_wise_sumyear

# / Graph

# Reports

class DatewiseSalesReportView(viewsets.ModelViewSet):
    serializer_class = DateWiseSalesRoundDetailsserillizers

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')
        
        # First filter by cusid
        queryset = SalesRoundDetails_Model.objects.filter(cusid=cusid)
        
        # Then filter by date range and status
        queryset = queryset.filter(dt__range=[start_date, end_date], Status='Normal').order_by('id')

        # If no records found for the date range, find the next available date
        if not queryset.exists():
            next_available_date = SalesRoundDetails_Model.objects.filter(cusid=cusid, dt__gt=start_date, Status='Normal').aggregate(next_date=Min('dt')) # type: ignore
            if next_available_date['next_date']:
                start_date = next_available_date['next_date']
                queryset = SalesRoundDetails_Model.objects.filter(cusid=cusid, dt__range=[start_date, end_date], Status='Normal').order_by('id')
        
        return queryset

class TodaySalesReportView(viewsets.ModelViewSet):
    serializer_class = DateSelectedSalesRoundDetailsserillizers

    def get_queryset(self):
        cusid = self.kwargs.get('cusid') 
        dt_param = self.kwargs.get('dt')  
        
        # Check if cusid and dt_param are provided
        if not cusid or not dt_param:
            return Response({"error": "Customer ID and dt are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            target_dt = make_aware(datetime.strptime(dt_param, '%Y-%m-%d'))
        except ValueError:
            return Response({"error": "Invalid dt format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)

        # Filter by cusid first
        queryset = SalesRoundDetails_Model.objects.filter(cusid=cusid)

        # Filter the result by dt
        queryset = queryset.filter(dt=target_dt, Status='Normal')

        return queryset

class CusnamewiseSalesReportView(viewsets.ModelViewSet):
    
    def get_serializer_class(self):
        return Customernamewuisesalesseriallizers

    def get_queryset(self):
        cusid = self.request.query_params.get('cusid', None)  # Get cusid from query parameters
        cusname = self.kwargs.get('cusname')  # Get cusname from URL kwargs
        
        queryset = SalesRoundDetails_Model.objects.all()  # Start with all objects
        
        if cusid:
            queryset = queryset.filter(cusid=cusid)  # Filter by cusid if provided
        
        if cusname:
            queryset = queryset.filter(cusname=cusname)  # Filter by cusname
        
        queryset = queryset.order_by('dt')  # Order by dt

        return queryset
 
class CusnamewiseSalesPaymentReportView(viewsets.ModelViewSet):

    def get_serializer_class(self):
        return SalesPaymentRoundDetailsSerializers

    def get_queryset(self):
        cusid = self.request.query_params.get('cusid', None)  # Get cusid from query parameters
        name = self.kwargs.get('name')  # Get name from URL kwargs
        
        queryset = SalesPaymentRoundDetails.objects.all()  # Start with all objects
        
        if cusid:
            queryset = queryset.filter(cusid=cusid)  # Filter by cusid if provided
        
        if name:
            queryset = queryset.filter(name=name)  # Filter by name
        
        queryset = queryset.order_by('dt')  # Order by dt

        return queryset  

class Sales_Leadge_overall_repots(viewsets.ModelViewSet):
    queryset = SalesRoundDetails_Model.objects.all()
    serializer_class = Sales_Details_Round_tblSerializers
    pagination_class = CustomPagination

    def list(self, request, cusid=None, start_dt=None):
        if cusid is None or start_dt is None:
            return Response({"detail": "Customer ID and date parameters are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            target_dt = datetime.strptime(start_dt, "%Y-%m-%d")
        except ValueError:
            return Response({"detail": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)

        # Filter Sales_Details_Round_tbl data for the given cusid and before target_dt and status == 'Normal'
        sales_details = SalesRoundDetails_Model.objects.filter(cusid=cusid, dt__lt=target_dt, Status='Normal')
        salestotal = sales_details.aggregate(Sum('finalamount'))['finalamount__sum'] or 0

        # Filter SalesPaymentRound data for the given cusid and before target_dt
        sales_payments = SalesPaymentRoundDetails.objects.filter(cusid=cusid, dt__lt=target_dt)
        salespayment = sales_payments.aggregate(Sum('amount'))['amount__sum'] or 0

        # Calculate the final amount
        final_amount = salestotal - salespayment

        return Response({
            'salestotal': salestotal,
            'salespayment': salespayment,
            'final_amount': final_amount
        })

class DatewiseOrderSalesReportView(viewsets.ModelViewSet):
    serializer_class = OrderSalesRoundDetailSerializer

    def get_queryset(self):
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')
        cusid = self.kwargs.get('cusid')  # Assuming cusid is passed as a URL parameter
        
        # Adjust end_date to include records on the end_date itself
        end_date_adjusted = (datetime.strptime(end_date, '%Y-%m-%d') + timedelta(days=1)).strftime('%Y-%m-%d')
        
        # Get the maximum date before the adjusted end_date for the cusid
        max_date_before_end = OrderSalesRoundDetails_Model.objects.filter(cusid=cusid, dt__lt=end_date_adjusted).order_by('-dt').first()
        
        if max_date_before_end is not None:
            end_date = max_date_before_end.dt
        
        print("Adjusted End Date:", end_date)
        
        # Filter queryset by cusid, start_date, and end_date
        queryset = OrderSalesRoundDetails_Model.objects.filter(cusid=cusid, dt__range=[start_date, end_date]).order_by('dt')
        
        return queryset

class DeliveryDatewiseOrderSalesReportView(viewsets.ModelViewSet):
    serializer_class = OrderSalesRoundDetailSerializer

    def get_queryset(self):
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')
        cusid = self.kwargs.get('cusid')  # Assuming cusid is passed as a URL parameter
        
        # Adjust end_date to include records on the end_date itself
        end_date_inclusive = (datetime.strptime(end_date, '%Y-%m-%d') + timedelta(days=1)).strftime('%Y-%m-%d')
        
        # Get the maximum delivery date before the adjusted end_date for the given cusid
        max_date_before_end = OrderSalesRoundDetails_Model.objects.filter(cusid=cusid, deliverydate__lt=end_date_inclusive).order_by('-deliverydate').first()
        
        if max_date_before_end is not None:
            end_date_inclusive = max_date_before_end.deliverydate
            
        print("Adjusted End Date:", end_date_inclusive)
        
        # Filter queryset by cusid and date range, including end_date_inclusive
        queryset = OrderSalesRoundDetails_Model.objects.filter(cusid=cusid, deliverydate__range=[start_date, end_date_inclusive]).order_by('deliverydate')
        return queryset

class DatewiseVendorSalesReportView(viewsets.ModelViewSet):
    serializer_class = Sales_Details_Round_Serializer

    def get_queryset(self):
        start_date_str = self.kwargs.get('start_dt')
        end_date_str = self.kwargs.get('end_dt')
        cusid = self.kwargs.get('cusid')  # Assuming cusid is passed in the URL kwargs
        
        # Convert start_date and end_date from string to datetime.date objects
        start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
        end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        
        # Adjust end_date to include records up to and including end_date
        end_date_adjusted = end_date + timedelta(days=1)
        
        # Filter by max date before the adjusted end_date for the given cusid
        max_date_before_end = SalesRoundDetails_Model.objects.filter(
            cusid=cusid,
            dt__lt=end_date_adjusted,
            Status='Vendor'
        ).order_by('-dt').first()
        
        if max_date_before_end is not None:
            end_date = max_date_before_end.dt
        
        print("Adjusted End Date:", end_date)
        
        # Filter queryset by cusid, adjusted start_date, and end_date
        queryset = SalesRoundDetails_Model.objects.filter(
            cusid=cusid,
            dt__range=[start_date, end_date],
            Status='Vendor'
        ).order_by('dt')
        
        return queryset

class DatewisePurchaseReportView(viewsets.ModelViewSet):
    serializer_class = DateWisePurchaseRoundDetailsserillizers

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        start_date = self.kwargs.get('start_date')
        end_date = self.kwargs.get('end_date')
        
        # Query the purchase round details filtered by cusid and date range
        queryset = PurchaseRoundDetails_Model.objects.filter(
            cusid=cusid,
            date__range=[start_date, end_date]
        ).order_by('date')

        # If queryset is empty, find the next available date
        if not queryset.exists():
            next_available_date = PurchaseRoundDetails_Model.objects.filter(
                cusid=cusid,
                date__gt=start_date
            ).aggregate(next_date=Min('date'))
            
            if next_available_date['next_date']:
                start_date = next_available_date['next_date']
                queryset = PurchaseRoundDetails_Model.objects.filter(
                    cusid=cusid,
                    date__range=[start_date, end_date]
                ).order_by('date')
        
        return queryset

class AgentwisePurchaseReportView(viewsets.ModelViewSet):
    serializer_class = DateWisePurchaseRoundDetailsserillizers

    def get_queryset(self):
        purchasername = self.kwargs.get('purchasername')
        cusid = self.kwargs.get('cusid')
        start_dt = self.request.query_params.get('start_dt')
        end_dt = self.request.query_params.get('end_dt')

        queryset = PurchaseRoundDetails_Model.objects.filter(purchasername=purchasername, cusid=cusid)

        if start_dt and end_dt:
            # Assuming start_dt and end_dt are ISO format strings
            start_date = datetime.strptime(start_dt, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_dt, '%Y-%m-%d').date() + timedelta(days=1)  # end_dt is inclusive

            queryset = queryset.filter(date__range=(start_date, end_date))

        queryset = queryset.order_by('date')
        return queryset
    
class AgentwisePurchasePaymentReportView(viewsets.ModelViewSet):
   
    def get_serializer_class(self):
        return PurchasePaymentsserializer
    
    def get_queryset(self):
        cusid = self.kwargs.get('cusid')  # Assuming you retrieve cusid from URL kwargs
        agentname = self.kwargs.get('agentname')
        
        # Filter the queryset based on cusid first, then agentname
        queryset = PurchasePayments.objects.filter(cusid=cusid, agentname=agentname).order_by('date')
        return queryset
    
class Purchase_Leadge_overall_repots(viewsets.ModelViewSet):
    queryset = PurchaseRoundDetails_Model.objects.all()
    serializer_class = PurchaseRoundDetaileserializer
    pagination_class = CustomPagination

    def list(self, request, start_date=None, cusid=None):
        if start_date is None or cusid is None:
            return Response({"detail": "Date parameter or customer ID is missing."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            target_date = datetime.strptime(start_date, "%Y-%m-%d")
        except ValueError:
            return Response({"detail": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)

        # Filter PurchaseRoundDetails_Model data before target_date and matching cusid
        Purchase_details = PurchaseRoundDetails_Model.objects.filter(date__lt=target_date, cusid=cusid)
        purchasetotal = Purchase_details.aggregate(Sum('total'))['total__sum'] or 0

        # Filter PurchasePayments data before target_date and matching cusid
        Purchase_payments = PurchasePayments.objects.filter(date__lt=target_date, cusid=cusid)
        Purchasepayment = Purchase_payments.aggregate(Sum('amount'))['amount__sum'] or 0

        # Calculate the final amount
        final_amount = purchasetotal - Purchasepayment

        return Response({
            'purchasetotal': purchasetotal,
            'Purchasepayment': Purchasepayment,
            'final_amount': final_amount
        })

class DatewiseStockReportView(viewsets.ModelViewSet):
    serializer_class = Stock_Details_RoundSerializer

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')
        
        # Convert start_date and end_date to datetime objects for filtering
        start_datetime = timezone.datetime.strptime(start_date, '%Y-%m-%d').date()
        end_datetime = timezone.datetime.strptime(end_date, '%Y-%m-%d').date()

        # Retrieve the maximum date before end_date for the given cusid
        max_date_before_end = Stock_Details_Round.objects.filter(cusid=cusid, date__lt=end_datetime).order_by('-date').first()
        
        if max_date_before_end is not None:
            end_datetime = max_date_before_end.date
            
        print("Adjusted End Date:", end_datetime)
        
        # Filter queryset by cusid and date range, ignoring time
        queryset = Stock_Details_Round.objects.annotate(
            date_only=Cast('date', DateField())
        ).filter(
            cusid=cusid,
            date_only__range=[start_datetime, end_datetime]
        ).order_by('date')
        
        return queryset

class DatewiseWastageReportView(viewsets.ModelViewSet):
    serializer_class = Wastage_Details_RoundSerializer

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')

        # Ensure end_date includes the entire day by setting the end of the day
        end_date = f"{end_date} 23:59:59"

        # Filter by cusid first
        filtered_by_cusid = Wastage_Details_Round.objects.filter(cusid=cusid)
        
        # Find the maximum date before the end_date in the filtered_by_cusid queryset
        max_date_before_end = filtered_by_cusid.filter(date__lt=end_date).order_by('-date').first()
        
        if max_date_before_end is not None:
            end_date = max_date_before_end.date

        print("Adjusted End Date:", end_date)
        
        # Further filter the queryset by the date range
        queryset = filtered_by_cusid.filter(date__range=[start_date, end_date]).order_by('date')
        return queryset

class DatewiseKitchenUsageReportView(viewsets.ModelViewSet):
    serializer_class = UsageRound_Details_Serializer

    def get_queryset(self):
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')
        cusid = self.kwargs.get('cusid')

        # Filter by cusid first
        queryset = UsageRound_Details_Model.objects.filter(cusid=cusid)

        # Find the maximum date before the given end_date
        max_date_before_end = queryset.filter(dt__lt=end_date).order_by('-dt').first()

        if max_date_before_end is not None:
            end_date = max_date_before_end.dt

        print("Adjusted End Date:", end_date)

        # Filter the final queryset by the adjusted date range and cusid
        final_queryset = queryset.filter(dt__range=[start_date, end_date]).order_by('dt')

        return final_queryset

class DatewiseIncomeReportView(viewsets.ModelViewSet):
    serializer_class = IncomeSerializer

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')

        if cusid is None:
            raise ValueError("cusid is required")

        # Step 1: Filter by cusid
        cusid_filtered_queryset = IncomeModel.objects.filter(cusid=cusid)

        # Step 2: Adjust end_date to include all data up to and including end_dt
        max_date_before_end = cusid_filtered_queryset.filter(dt__lte=end_date).order_by('-dt').first()

        if max_date_before_end is not None:
            end_date = max_date_before_end.dt

        print("Adjusted End Date:", end_date)

        # Step 3: Filter by date range using the adjusted end date
        queryset = cusid_filtered_queryset.filter(dt__range=[start_date, end_date]).order_by('dt')

        return queryset
     
class DatewiseExpenseReportView(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer

    def get_queryset(self):
        cusid = self.kwargs.get('cusid')
        start_date = self.kwargs.get('start_dt')
        end_date = self.kwargs.get('end_dt')

        if cusid is None:
            raise ValueError("cusid is required")

        # Step 1: Filter by cusid
        cusid_filtered_queryset = ExpenseModel.objects.filter(cusid=cusid)

        # Step 2: Adjust end_date to include all data up to and including end_dt
        max_date_before_end = cusid_filtered_queryset.filter(dt__lte=end_date).order_by('-dt').first()

        if max_date_before_end is not None:
            end_date = max_date_before_end.dt

        print("Adjusted End Date:", end_date)

        # Step 3: Filter by date range using the adjusted end date
        queryset = cusid_filtered_queryset.filter(dt__range=[start_date, end_date]).order_by('dt')

        return queryset

# / Reports

# Razorpay


# / Razorpay


