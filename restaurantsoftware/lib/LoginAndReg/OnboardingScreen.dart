import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';
// import 'package:ProductRestaurant/Modules/Style.dart';
// import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchsidebarmenulist();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomPaint(
            painter: ArcPainter(),
            child: SizedBox(
              height: screenSize.height / 1.4,
              width: screenSize.width,
            ),
          ),
          Positioned(
            top: 50, // Adjust this value to move the image up or down
            right: 5,
            left: 5,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0), // Add bottom padding here
              child: Lottie.asset(
                tabs[_currentIndex].lottieFile,
                key: Key('${Random().nextInt(999999999)}'),
                width: 300,
                height: 300,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 270,
              child: Column(
                children: [
                  Flexible(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: tabs.length,
                      itemBuilder: (BuildContext context, int index) {
                        OnboardingModel tab = tabs[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 38.0),
                              child: Text(
                                tab.title,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              tab.subtitle,
                              style: const TextStyle(
                                fontSize: 15.0,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                      onPageChanged: (value) {
                        setState(() {
                          _currentIndex = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < tabs.length; index++)
                        _DotIndicator(isSelected: index == _currentIndex),
                    ],
                  ),
                  const SizedBox(height: 75)
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? role = await getrole();

          if (_currentIndex == 2) {
            fetchsidebarmenulist();
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
                ),
              ),
            );
          } else {
            fetchsidebarmenulist();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        },
        child: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path orangeArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 170)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 170)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(orangeArc, Paint()..color = Colors.orange);

    Path whiteArc = Path()
      ..moveTo(0.0, 0.0)
      ..lineTo(0.0, size.height - 185)
      ..quadraticBezierTo(
          size.width / 2, size.height - 70, size.width, size.height - 185)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(whiteArc, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isSelected;

  const _DotIndicator({Key? key, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6.0,
        width: 6.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

class OnboardingModel {
  final String lottieFile;
  final String title;
  final String subtitle;

  OnboardingModel(this.lottieFile, this.title, this.subtitle);
}

List<OnboardingModel> tabs = [
  OnboardingModel(
    'assets/json/order.json',
    'Quick Billing',
    'Generate bills quickly and efficiently for all your orders.',
  ),
  OnboardingModel(
    'assets/json/interaction.json',
    'Table Management',
    'Manage table reservations and occupancy with ease.',
  ),
  OnboardingModel(
    'assets/json/delivery.json',
    'Order Tracking',
    'Track orders in real-time and ensure timely delivery.',
  ),
];
