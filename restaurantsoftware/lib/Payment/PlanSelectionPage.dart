import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Payment/MakePaymentPage.dart';
import 'package:restaurantsoftware/Sidebar/SidebarMainPage.dart';

class PlanSelectionPage extends StatelessWidget {
  final String cusid;

  PlanSelectionPage(this.cusid);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the number of columns based on screen width
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'Cancel',
                    child: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.black, size: 25),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // String? role = await getrole();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => sidebar(
                        //             onItemSelected: (content) {},
                        //             settingsproductcategory: role == 'admin'
                        //                 ? true
                        //                 : settingsproductcategory,
                        //             settingsproductdetails: role == 'admin'
                        //                 ? true
                        //                 : settingsproductdetails,
                        //             settingsgstdetails: role == 'admin'
                        //                 ? true
                        //                 : settingsgstdetails,
                        //             settingsstaffdetails: role == 'admin'
                        //                 ? true
                        //                 : settingsstaffdetails,
                        //             settingspaymentmethod: role == 'admin'
                        //                 ? true
                        //                 : settingspaymentmethod,
                        //             settingsaddsalespoint: role == 'admin'
                        //                 ? true
                        //                 : settingsaddsalespoint,
                        //             settingsprinterdetails: role == 'admin'
                        //                 ? true
                        //                 : settingsprinterdetails,
                        //             settingslogindetails: role == 'admin'
                        //                 ? true
                        //                 : settingslogindetails,
                        //             purchasenewpurchase: role == 'admin'
                        //                 ? true
                        //                 : purchasenewpurchase,
                        //             purchaseeditpurchase: role == 'admin'
                        //                 ? true
                        //                 : purchaseeditpurchase,
                        //             purchasepaymentdetails: role == 'admin'
                        //                 ? true
                        //                 : purchasepaymentdetails,
                        //             purchaseproductcategory: role == 'admin'
                        //                 ? true
                        //                 : purchaseproductcategory,
                        //             purchaseproductdetails: role == 'admin'
                        //                 ? true
                        //                 : purchaseproductdetails,
                        //             purchaseCustomer: role == 'admin'
                        //                 ? true
                        //                 : purchaseCustomer,
                        //             salesnewsales:
                        //                 role == 'admin' ? true : salesnewsale,
                        //             saleseditsales:
                        //                 role == 'admin' ? true : saleseditsales,
                        //             salespaymentdetails: role == 'admin'
                        //                 ? true
                        //                 : salespaymentdetails,
                        //             salescustomer:
                        //                 role == 'admin' ? true : salescustomer,
                        //             salestablecount: role == 'admin'
                        //                 ? true
                        //                 : salestablecount,
                        //             quicksales:
                        //                 role == 'admin' ? true : quicksales,
                        //             ordersalesnew:
                        //                 role == 'admin' ? true : ordersalesnew,
                        //             ordersalesedit:
                        //                 role == 'admin' ? true : ordersalesedit,
                        //             ordersalespaymentdetails: role == 'admin'
                        //                 ? true
                        //                 : ordersalespaymentdetails,
                        //             vendorsalesnew:
                        //                 role == 'admin' ? true : vendorsalesnew,
                        //             vendorsalespaymentdetails: role == 'admin'
                        //                 ? true
                        //                 : vendorsalespaymentdetails,
                        //             vendorcustomer:
                        //                 role == 'admin' ? true : vendorcustomer,
                        //             stocknew: role == 'admin' ? true : stocknew,
                        //             wastageadd:
                        //                 role == 'admin' ? true : wastageadd,
                        //             kitchenusagesentry: role == 'admin'
                        //                 ? true
                        //                 : kitchenusagesentry,
                        //             report: role == 'admin' ? true : report,
                        //             daysheetincomeentry: role == 'admin'
                        //                 ? true
                        //                 : daysheetincomeentry,
                        //             daysheetexpenseentry: role == 'admin'
                        //                 ? true
                        //                 : daysheetexpenseentry,
                        //             daysheetexepensescategory: role == 'admin'
                        //                 ? true
                        //                 : daysheetexepensescategory,
                        //             graphsales:
                        //                 role == 'admin' ? true : graphsales,
                        //           )),
                        // );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: (screenWidth > 600 ? 1 : 0.9),
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final plans = [
                    Plan(
                      title: 'Silver',
                      duration: 'For One month',
                      price: '299',
                      features: [
                        'Multiple User',
                        'Choose User',
                        'Quick Dashboard',
                      ],
                      color: Colors.blueAccent,
                      icon: 'assets/imgs/silver-badge.png',
                      image: 'assets/imgs/buyp_insta.png',
                    ),
                    Plan(
                      title: 'Diamond',
                      duration: 'For One Year',
                      price: '3000',
                      features: [
                        'Multiple User',
                        'Choose User',
                        'Quick Dashboard',
                      ],
                      color: Colors.redAccent,
                      icon: 'assets/imgs/crown.png',
                      image: 'assets/imgs/buyp_insta.png',
                    ),
                    Plan(
                      title: 'Gold',
                      duration: 'For Six Month',
                      price: '1699',
                      features: [
                        'Multiple User',
                        'Choose User',
                        'Quick Dashboard',
                      ],
                      color: Colors.orangeAccent,
                      icon: 'assets/imgs/coin.png',
                      image: 'assets/imgs/buyp_insta.png',
                    ),
                  ];
                  final plan = plans[index];
                  return PlanContainer(
                    title: plan.title,
                    duration: plan.duration,
                    price: plan.price,
                    features: plan.features,
                    color: plan.color,
                    icon: plan.icon,
                    image: plan.image,
                    onSelect: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MakePaymentPage(plan: plan, cusid: cusid),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanContainer extends StatefulWidget {
  final String title;
  final String duration;
  final String price;
  final List<String> features;
  final Color color;
  final String icon;
  final String image;
  final VoidCallback onSelect;

  const PlanContainer({
    Key? key,
    required this.title,
    required this.duration,
    required this.price,
    required this.features,
    required this.color,
    required this.icon,
    required this.image,
    required this.onSelect,
  }) : super(key: key);

  @override
  _PlanContainerState createState() => _PlanContainerState();
}

class _PlanContainerState extends State<PlanContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _animation,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final isWideScreen = screenWidth > 600;

              double width = isWideScreen ? 250 : maxWidth * 0.9;
              double height = screenWidth <= 600
                  ? 500
                  : 400; // Increase height for mobile view

              if (widget.title == 'Diamond') {
                width = isWideScreen ? 270 : maxWidth * 0.9;
                height = isWideScreen
                    ? 500
                    : 500; // Specific height for 'Diamond' plan
              }

              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isHovered ? width + 20 : width,
                height: _isHovered ? height + 20 : height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color.withOpacity(0.8), widget.color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: _isHovered ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: screenWidth > 600 ? 30 : 20,
                          backgroundImage: AssetImage(widget.image),
                        ),
                        SizedBox(height: 10),
                        CircleAvatar(
                          radius: screenWidth > 600 ? 20 : 15,
                          backgroundColor: Colors.white,
                          child:
                              Image.asset(widget.icon, height: 25, width: 25),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.price,
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.duration,
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Divider(color: Colors.white70),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: widget.features
                              .map((feature) => Text(
                                    '• $feature',
                                    style: TextStyle(
                                        fontSize: screenWidth > 600 ? 15 : 13,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: widget.onSelect,
                          style: ElevatedButton.styleFrom(
                            // primary: Colors.white,
                            // onPrimary: widget.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text('Select Plan'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}
