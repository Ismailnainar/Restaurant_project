import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurantsoftware/LoginAndReg/Login.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1920, 1080),
      builder: (context, child) {
        return MaterialApp(
         title: 'Restaurant Management',
          theme: ThemeData(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all<Color>(Colors.transparent),
              trackColor: MaterialStateProperty.all<Color>(Colors.transparent),
            ),
            fontFamily: 'Source Sans 3',
            primaryColor: Colors.blue,
            textTheme: TextTheme().apply(bodyColor: Colors.black),
            // backgroundColor: Colors.yellow,
          ),
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String shopNames = '';

  @override
  void initState() {
    super.initState();
    _loadShopName();
    fetchsidebarmenulist();
    getrole();
  }

  Future<void> _loadShopName() async {
    String? role = await getrole();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shopNames =
          prefs.getString('Restaurant Software') ?? 'Restaurant Software';
    });

    Timer(Duration(seconds: 3), () {
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn
              ? sidebar(
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
                )
              : LoginScreen(
                  email: '',
                  password: '',
                ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 211, 211, 211),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  "assets/imgs/Cooking.png",
                  height: 300.0,
                  width: 300.0,
                ),
                Text(
                  shopNames,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                ),
                SizedBox(
                  height: 50,
                ),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
