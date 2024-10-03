import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
// import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextStyle commonLabelTextStyle =
    TextStyle(color: Colors.black, fontSize: 14.5, fontWeight: FontWeight.w100);

TextStyle textStyle =
    TextStyle(color: Color.fromARGB(255, 73, 72, 72), fontSize: 14.5);

TextStyle AmountTextStyle =
    TextStyle(color: Color.fromARGB(255, 73, 72, 72), fontSize: 18);

const TextStyle HeadingStyle = TextStyle(
  color: Colors.black,
  fontSize: 16,
);

const TextStyle DropdownTextStyle = TextStyle(
  color: Color.fromARGB(255, 73, 72, 72),
  fontSize: 13,
);

const TextStyle commonWhiteStyle = TextStyle(
    color: Color.fromARGB(255, 243, 234, 234),
    fontSize: 14,
    fontWeight: FontWeight.bold);

BoxDecoration TableHeaderColor = BoxDecoration(
  color: Colors.grey[200],
);

const TextStyle TableRowTextStyle = TextStyle(
  color: Color.fromARGB(255, 73, 72, 72),
  fontSize: 14,
);

void successfullySavedMessage(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully Saved..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

void successfullyDeleteMessage(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully Deleted..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

void WarninngMessage(context) {
  showDialog(
    barrierDismissible: false,
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
              Icon(Icons.check_circle_rounded, color: Colors.yellow, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kindly fill all the fields..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

void successfullyUpdateMessage(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully Updated..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

bool settingsproductcategory = false;
bool settingsproductdetails = false;
bool settingsgstdetails = false;
bool settingsstaffdetails = false;
bool settingspaymentmethod = false;
bool settingsaddsalespoint = false;
bool settingsprinterdetails = false;
bool settingslogindetails = false;
bool purchasenewpurchase = false;
bool purchaseeditpurchase = false;
bool purchasepaymentdetails = false;
bool purchaseproductcategory = false;
bool purchaseproductdetails = false;
bool purchaseCustomer = false;
bool salesnewsale = false;
bool saleseditsales = false;
bool salespaymentdetails = false;
bool salescustomer = false;
bool salestablecount = false;
bool quicksales = false;
bool ordersalesnew = false;
bool ordersalesedit = false;
bool ordersalespaymentdetails = false;
bool vendorsalesnew = false;
bool vendorsalespaymentdetails = false;
bool vendorcustomer = false;
bool stocknew = false;
bool wastageadd = false;
bool kitchenusagesentry = false;
bool report = false;
bool daysheetincomeentry = false;
bool daysheetexpenseentry = false;
bool daysheetexepensescategory = false;
bool graphsales = false;
bool isLoading = true;
String errorMessage = '';

Future<String?> getrole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

Future<void> fetchsidebarmenulist() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  String? cusid = prefs.getString('cusid');

  if (email == null) {
    isLoading = false;
    errorMessage = 'Email not found';
    return;
  }

  String baseUrl = '$IpAddress/Settings_usermanagement/$cusid/';
  List<dynamic> allResults = [];

  Future<void> fetchPage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];
        allResults.addAll(results);

        // Check if there's a next page
        if (data['next'] != null) {
          await fetchPage(data['next']);
        } else {
          // Process all results once all pages are fetched
          processResults(email, allResults);
        }
      } else {
        // setState(() {
        isLoading = false;
        errorMessage = 'Failed to load settings';
        // });
      }
    } catch (e) {
      // setState(() {
      isLoading = false;
      errorMessage = 'Error: $e';
      // });
    }
  }

  // Start fetching from the base URL
  await fetchPage(baseUrl);
}

void processResults(String email, List<dynamic> results) {
  for (var result in results) {
    if ((result['email'] == email && result['menu'] == 'Settings')) {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      settingsproductcategory = categoryStatus['product category'] == 'true';
      settingsproductdetails = categoryStatus['product  details'] == 'true';
      settingsgstdetails = categoryStatus['gst details'] == 'true';
      settingsstaffdetails = categoryStatus['staff details'] == 'true';
      settingspaymentmethod = categoryStatus['payment method'] == 'true';
      settingsaddsalespoint = categoryStatus['add sales points'] == 'true';
      settingsprinterdetails = categoryStatus['printer detials'] == 'true';
      settingslogindetails = categoryStatus['login details'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'purchase') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      purchasenewpurchase = categoryStatus['new purchase'] == 'true';
      purchaseeditpurchase = categoryStatus['edit purchase'] == 'true';
      purchasepaymentdetails = categoryStatus['payment details'] == 'true';
      purchaseproductcategory = categoryStatus['product category'] == 'true';
      purchaseproductdetails = categoryStatus['product details'] == 'true';
      purchaseCustomer = categoryStatus['purchas customer'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'sales') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      salesnewsale = categoryStatus['new sales'] == 'true';
      saleseditsales = categoryStatus['edit sales'] == 'true';
      salespaymentdetails = categoryStatus['payment details'] == 'true';
      salescustomer = categoryStatus['sales customer'] == 'true';
      salestablecount = categoryStatus['table count'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'quick sales') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      quicksales = categoryStatus['quick sales'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'order sales') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      ordersalesnew = categoryStatus['new order sales'] == 'true';
      ordersalesedit = categoryStatus['edit order sales'] == 'true';
      ordersalespaymentdetails = categoryStatus['payment details'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'vendor sales') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      vendorsalesnew = categoryStatus['new vendorsales'] == 'true';
      vendorsalespaymentdetails = categoryStatus['payment details'] == 'true';
      vendorcustomer = categoryStatus['vendor customers'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'stock') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      stocknew = categoryStatus['new stock'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'wastage') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      wastageadd = categoryStatus['add wastage'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'kitchen') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      kitchenusagesentry = categoryStatus['usage entry'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'report') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      report = categoryStatus['reports'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'daysheet') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      daysheetincomeentry = categoryStatus['income entry'] == 'true';
      daysheetexpenseentry = categoryStatus['expense entry'] == 'true';
      daysheetexepensescategory = categoryStatus['expense category'] == 'true';
      isLoading = false;
      // });
    }
    if (result['email'] == email && result['menu'] == 'graph') {
      final categoryStatus = result['CategoryStatus'][0];

      // setState(() {
      graphsales = categoryStatus['graph'] == 'true';
      isLoading = false;
      // });
    }
  }
}

Future<void> logreports(String description) async {
  String? cusid = await SharedPrefs.getCusId();

  String? role = await SharedPrefs.getRole();
  String? email = await SharedPrefs.getEmail();

  DateTime currentDate = DateTime.now();
  String formattedDateTime =
      DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(currentDate.toUtc());
  String insertUrl = '$IpAddress/LogReport/';
  try {
    http.Response response = await http.post(
      Uri.parse(insertUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "cusid": "$cusid",
        "role": "$role-$email",
        "dt": formattedDateTime,
        "description": description
      }),
    );
    if (response.statusCode == 201) {
      print('Successfully Password cusid ID: $cusid');
    } else {
      print('Failed to insert Trial ID. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
