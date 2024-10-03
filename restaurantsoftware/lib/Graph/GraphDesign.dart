import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesWeekChart extends StatefulWidget {
  const SalesWeekChart({Key? key}) : super(key: key);

  @override
  State<SalesWeekChart> createState() => _SalesWeekChartState();
}

class _SalesWeekChartState extends State<SalesWeekChart> {
  List<BarChartModel> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/SalesGraphCharts/$cusid'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (mounted) {
        setState(() {
          data = jsonData['Last7DaysDetails'].map<BarChartModel>((entry) {
            final dt = entry['dt'].toString();
            final amount = double.parse(entry['amount_sum'].toString());
            return BarChartModel(
              dt: dt,
              amount: amount,
            );
          }).toList();
        });
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Responsive.isDesktop(context))
          Center(
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.38,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: maincolor,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text('Last 7 Days', style: HeadingStyle),
                        ),
                      ),
                      Expanded(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelRotation: 45,
                          ),
                          series: <ChartSeries>[
                            BarSeries<BarChartModel, String>(
                              dataSource: data,
                              xValueMapper: (BarChartModel sales, _) => sales.dt,
                              yValueMapper: (BarChartModel sales, _) => sales.amount,
                              dataLabelSettings: DataLabelSettings(isVisible: true),
                              color: subcolor,
                            ),
                          ],
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class BarChartModel {
  final String dt;
  final double amount;

  BarChartModel({
    required this.dt,
    required this.amount,
  });
}
class SalesMonthChart extends StatefulWidget {
  const SalesMonthChart({Key? key}) : super(key: key);

  @override
  State<SalesMonthChart> createState() => _SalesMonthChartState();
}

class _SalesMonthChartState extends State<SalesMonthChart> {
  List<Map<String, dynamic>> lastWeekPurchaseData = [];

  @override
  void initState() {
    super.initState();
    Salespiechart();
  }

  Future<void> Salespiechart() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/SalesGraphCharts/$cusid';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['LastMonthDetails'] != null) {
      lastWeekPurchaseData =
          List<Map<String, dynamic>>.from(jsonData['LastMonthDetails']);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ChartData> lineChartDataList = lastWeekPurchaseData
        .where((data) => data['dt'] != null && data['amount_sum'] != null)
        .map((data) {
          final date = data['dt'] as String?;
          final amount = double.parse(data['amount_sum'] as String);
          return ChartData(date!, amount);
        })
        .toList();

    return Row(
      children: [
        if (Responsive.isDesktop(context))
          Center(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: maincolor,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.38,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Last Month',
                              style: HeadingStyle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: SfCartesianChart(
                              palette: <Color>[
                                subcolor,
                              ],
                              primaryXAxis: CategoryAxis(
                                labelIntersectAction:
                                    AxisLabelIntersectAction.rotate45,
                                labelPlacement: LabelPlacement.onTicks,
                                majorTickLines: MajorTickLines(size: 0),
                              ),
                              series: <ChartSeries>[
                                LineSeries<ChartData, String>(
                                  dataSource: lineChartDataList,
                                  xValueMapper: (ChartData data, _) =>
                                      data.date.substring(data.date.length - 2),
                                  yValueMapper: (ChartData data, _) =>
                                      data.amount,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: false,
                                  ),
                                ),
                              ],
                              tooltipBehavior: TooltipBehavior(
                                enable: true,
                                header: '',
                                format: 'Amount: \$point.y',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.date, this.amount);
  final String date;
  final double amount;
}

class SalesYearChart extends StatefulWidget {
  const SalesYearChart({Key? key}) : super(key: key);

  @override
  State<SalesYearChart> createState() => _SalesYearChartState();
}

class _SalesYearChartState extends State<SalesYearChart> {
  List<BarChartModel> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/SalesGraphCharts/$cusid'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (mounted) {
        setState(() {
          data = jsonData['PreviousYearMonthWiseDetails']
              .map<BarChartModel>((entry) {
            final dt = entry['dt'].toString();
            final amount = double.parse(entry['amount_sum'].toString());
            return BarChartModel(
              dt: dt,
              amount: amount,
            );
          }).toList();
        });
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Responsive.isDesktop(context))
          Center(
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.43,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: maincolor,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Last year',
                            style: HeadingStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelRotation: 45,
                          ),
                          series: <ChartSeries>[
                            BarSeries<BarChartModel, String>(
                              dataSource: data,
                              xValueMapper: (BarChartModel sales, _) => sales.dt,
                              yValueMapper: (BarChartModel sales, _) => sales.amount,
                              dataLabelSettings: DataLabelSettings(isVisible: true),
                              color: subcolor,
                            ),
                          ],
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}




// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:restaurantsoftware/Database/IpAddress.dart';
// import 'package:restaurantsoftware/Modules/Responsive.dart';
// import 'package:restaurantsoftware/Modules/Style.dart';
// import 'package:restaurantsoftware/Modules/constaints.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:charts_flutter/flutter.dart' as charts;

// class SalesWeekChart extends StatefulWidget {
//   const SalesWeekChart({Key? key}) : super(key: key);

//   @override
//   State<SalesWeekChart> createState() => _SalesWeekChartState();
// }

// class _SalesWeekChartState extends State<SalesWeekChart> {
//   List<Map<String, dynamic>> lastmonthsalescard = [];
//   List<BarChartModel> data = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     String? cusid = await SharedPrefs.getCusId();
//     final response =
//         await http.get(Uri.parse('$IpAddress/SalesGraphCharts/$cusid'));

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);

//       if (mounted) {
//         setState(() {
//           data = jsonData['Last7DaysDetails'].map<BarChartModel>((entry) {
//             final dt = entry['dt'].toString();
//             final amount = double.parse(entry['amount_sum'].toString());
//             final color = charts.ColorUtil.fromDartColor(
//               subcolor,
//             );

//             return BarChartModel(
//               dt: dt,
//               amount: amount,
//               color: color,
//             );
//           }).toList();
//         });
//       }
//     } else {
//       print('Failed to fetch data: ${response.statusCode}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat('#,##,###', 'en_IN');

//     List<charts.Series<BarChartModel, String>> series = [
//       charts.Series(
//         id: "amount",
//         data: data,
//         domainFn: (BarChartModel series, _) => series.dt,
//         measureFn: (BarChartModel series, _) => series.amount,
//         colorFn: (BarChartModel series, _) => series.color,
//         labelAccessorFn: (BarChartModel series, _) =>
//             '₹${currencyFormat.format(series.amount.round())}',
//       ),
//     ];

//     return Row(
//       children: [
//         if (Responsive.isDesktop(context))
//           Center(
//             child: Row(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.38,
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: maincolor,
//                     ),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
//                   child: Column(
//                     children: [
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Text('Last 7 Days', style: HeadingStyle),
//                         ),
//                       ),
//                       Expanded(
//                         child: charts.BarChart(
//                           series,
//                           animate: true,
//                           domainAxis: charts.OrdinalAxisSpec(
//                             renderSpec: charts.SmallTickRendererSpec(
//                               labelRotation: 45,
//                               labelAnchor: charts.TickLabelAnchor.after,
//                               labelJustification:
//                                   charts.TickLabelJustification.outside,
//                             ),
//                             tickProviderSpec:
//                                 charts.StaticOrdinalTickProviderSpec(
//                               // Provide a list of your 'dt' values as tick labels
//                               <charts.TickSpec<String>>[
//                                 for (var bar in data) charts.TickSpec(bar.dt),
//                               ],
//                             ),
//                           ),
//                           barRendererDecorator:
//                               charts.BarLabelDecorator<String>(
//                             labelPosition: charts.BarLabelPosition.outside,
//                             labelPadding: 5,
//                             labelAnchor: charts.BarLabelAnchor.end,
//                             outsideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                             insideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//               ],
//             ),
//           ),
//         if (Responsive.isMobile(context) || Responsive.isTablet(context))
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.835,
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: maincolor,
//                     ),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
//                   child: Column(
//                     children: [
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Text(
//                             'Last 7 Days',
//                             style: HeadingStyle,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: charts.BarChart(
//                           series,
//                           animate: true,
//                           domainAxis: charts.OrdinalAxisSpec(
//                             renderSpec: charts.SmallTickRendererSpec(
//                               labelRotation: 45,
//                               labelAnchor: charts.TickLabelAnchor.after,
//                               labelJustification:
//                                   charts.TickLabelJustification.outside,
//                             ),
//                             tickProviderSpec:
//                                 charts.StaticOrdinalTickProviderSpec(
//                               // Provide a list of your 'dt' values as tick labels
//                               <charts.TickSpec<String>>[
//                                 for (var bar in data) charts.TickSpec(bar.dt),
//                               ],
//                             ),
//                           ),
//                           barRendererDecorator:
//                               charts.BarLabelDecorator<String>(
//                             labelPosition: charts.BarLabelPosition.outside,
//                             labelPadding: 5,
//                             labelAnchor: charts.BarLabelAnchor.end,
//                             outsideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                             insideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

// class PieChartData {
//   PieChartData(this.date, this.amount);
//   final String date;
//   final double amount;
//   late Color color; // Color assigned to each data point
// }

// class ChartData {
//   ChartData(this.date, this.amount);
//   final String date;
//   final double amount;
// }

// class SalesMonthChart extends StatefulWidget {
//   const SalesMonthChart({Key? key}) : super(key: key);

//   @override
//   State<SalesMonthChart> createState() => _SalesMonthChartState();
// }

// class _SalesMonthChartState extends State<SalesMonthChart> {
//   List<Map<String, dynamic>> lastWeekPurchaseData = [];
//   List<Map<String, dynamic>> RadianchartData = [];

//   @override
//   void initState() {
//     super.initState();
//     Salespiechart();
//   }

//   Future<void> Salespiechart() async {
//     String? cusid = await SharedPrefs.getCusId();
//     String apiUrl = '$IpAddress/SalesGraphCharts/$cusid';
//     http.Response response = await http.get(Uri.parse(apiUrl));
//     var jsonData = json.decode(response.body);

//     if (jsonData['LastMonthDetails'] != null) {
//       lastWeekPurchaseData =
//           List<Map<String, dynamic>>.from(jsonData['LastMonthDetails']);
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<ChartData> lineChartDataList = lastWeekPurchaseData
//         .where((data) => data['dt'] != null && data['amount_sum'] != null)
//         .map((data) {
//           final date = data['dt'] as String?;
//           final amount = double.parse(data['amount_sum'] as String);
//           if (date != null && amount != null) {
//             return ChartData(date, amount);
//           } else {
//             return null;
//           }
//         })
//         .whereType<ChartData>()
//         .toList();

//     return Row(
//       children: [
//         if (Responsive.isDesktop(context))
//           Center(
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: maincolor,
//                     ),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.38,
//                     height: MediaQuery.of(context).size.height * 0.6,
//                     child: Column(
//                       children: [
//                         Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Text(
//                               'Last Month',
//                               style: HeadingStyle,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Center(
//                             child: SfCartesianChart(
//                               palette: <Color>[
//                                 subcolor,
//                               ],
//                               primaryXAxis: CategoryAxis(
//                                 labelIntersectAction:
//                                     AxisLabelIntersectAction.rotate45,
//                                 labelPlacement: LabelPlacement.onTicks,
//                                 majorTickLines: MajorTickLines(size: 0),
//                               ),
//                               series: <ChartSeries>[
//                                 LineSeries<ChartData, String>(
//                                   dataSource: lineChartDataList,
//                                   xValueMapper: (ChartData data, _) {
//                                     return data.date
//                                         .substring(data.date.length - 2);
//                                   },
//                                   yValueMapper: (ChartData data, _) =>
//                                       data.amount,
//                                   dataLabelSettings: DataLabelSettings(
//                                     isVisible: false,
//                                   ),
//                                 ),
//                               ],
//                               tooltipBehavior: TooltipBehavior(
//                                 enable: true,
//                                 header: '',
//                                 format: 'Amount: \$point.y',
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         if (Responsive.isMobile(context) || Responsive.isTablet(context))
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: maincolor,
//                     ),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.835,
//                     height: MediaQuery.of(context).size.height * 0.60,
//                     child: Column(
//                       children: [
//                         Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Text(
//                               'Last Month',
//                               style: HeadingStyle,
//                             ),
//                           ),
//                         ),
//                         Center(
//                           child: SfCartesianChart(
//                             palette: <Color>[
//                               subcolor, // Color for the first series
//                             ],
//                             primaryXAxis: CategoryAxis(
//                               labelIntersectAction:
//                                   AxisLabelIntersectAction.rotate45,
//                               labelPlacement: LabelPlacement.onTicks,
//                               majorTickLines: MajorTickLines(size: 0),
//                               // title: AxisTitle(text: 'Date'),
//                             ),
//                             series: <ChartSeries>[
//                               LineSeries<ChartData, String>(
//                                 dataSource: lineChartDataList,
//                                 xValueMapper: (ChartData data, _) {
// // Show only the last 2 characters of the date
//                                   return data.date
//                                       .substring(data.date.length - 2);
//                                 },
//                                 yValueMapper: (ChartData data, _) =>
//                                     data.amount,
//                                 dataLabelSettings: DataLabelSettings(
//                                   isVisible: false, // Disable data labels
//                                 ),
//                               ),
//                             ],
//                             tooltipBehavior: TooltipBehavior(
//                               enable: true,
//                               header: '',
//                               format: 'Amount: \$point.y',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

// class BarChartModel {
//   final String dt;
//   final double amount;
//   final charts.Color color;

//   BarChartModel({
//     required this.dt,
//     required this.amount,
//     required this.color,
//   });

//   @override
//   String toString() {
//     return dt; // Display the year as the label for the bar chart
//   }
// }

// class SalesYearChart extends StatefulWidget {
//   const SalesYearChart({Key? key}) : super(key: key);

//   @override
//   State<SalesYearChart> createState() => _SalesYearChartState();
// }

// class _SalesYearChartState extends State<SalesYearChart> {
//   List<BarChartModel> data = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     String? cusid = await SharedPrefs.getCusId();
//     final response =
//         await http.get(Uri.parse('$IpAddress/SalesGraphCharts/$cusid'));

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);

//       if (mounted) {
//         setState(() {
//           data = jsonData['PreviousYearMonthWiseDetails']
//               .map<BarChartModel>((entry) {
//             final dt = entry['dt'].toString();
//             final amount = double.parse(entry['amount_sum'].toString());
//             final color = charts.ColorUtil.fromDartColor(
//               subcolor,
//             );

//             return BarChartModel(
//               dt: dt,
//               amount: amount,
//               color: color,
//             );
//           }).toList();
//         });
//       }
//     } else {
//       print('Failed to fetch data: ${response.statusCode}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat('#,##,###', 'en_IN');

//     List<charts.Series<BarChartModel, String>> series = [
//       charts.Series(
//         id: "amount",
//         data: data,
//         domainFn: (BarChartModel series, _) => series.dt,
//         measureFn: (BarChartModel series, _) => series.amount,
//         colorFn: (BarChartModel series, _) => series.color,
//         labelAccessorFn: (BarChartModel series, _) =>
//             '₹${currencyFormat.format(series.amount.round())}',
//       ),
//     ];

//     return Row(
//       children: [
//         if (Responsive.isDesktop(context))
//           Center(
//             child: Row(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.43,
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: maincolor,
//                     ),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                   child: Column(
//                     children: [
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Text(
//                             'Last year',
//                             style: HeadingStyle,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: charts.BarChart(
//                           series,
//                           animate: true,
//                           domainAxis: charts.OrdinalAxisSpec(
//                             renderSpec: charts.SmallTickRendererSpec(
//                               labelRotation: 45,
//                               labelAnchor: charts.TickLabelAnchor.after,
//                               labelJustification:
//                                   charts.TickLabelJustification.outside,
//                             ),
//                             tickProviderSpec:
//                                 charts.StaticOrdinalTickProviderSpec(
//                               // Provide a list of your 'dt' values as tick labels
//                               <charts.TickSpec<String>>[
//                                 for (var bar in data) charts.TickSpec(bar.dt),
//                               ],
//                             ),
//                           ),
//                           barRendererDecorator:
//                               charts.BarLabelDecorator<String>(
//                             labelPosition: charts.BarLabelPosition.outside,
//                             labelPadding: 5,
//                             labelAnchor: charts.BarLabelAnchor.end,
//                             outsideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                             insideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//               ],
//             ),
//           ),
//         if (Responsive.isMobile(context) || Responsive.isTablet(context))
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.835,
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: maincolor,
//                     ),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                   child: Column(
//                     children: [
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Text(
//                             'Last year',
//                             style: commonLabelTextStyle,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: charts.BarChart(
//                           series,
//                           animate: true,
//                           domainAxis: charts.OrdinalAxisSpec(
//                             renderSpec: charts.SmallTickRendererSpec(
//                               labelRotation: 45,
//                               labelAnchor: charts.TickLabelAnchor.after,
//                               labelJustification:
//                                   charts.TickLabelJustification.outside,
//                             ),
//                             tickProviderSpec:
//                                 charts.StaticOrdinalTickProviderSpec(
//                               // Provide a list of your 'dt' values as tick labels
//                               <charts.TickSpec<String>>[
//                                 for (var bar in data) charts.TickSpec(bar.dt),
//                               ],
//                             ),
//                           ),
//                           barRendererDecorator:
//                               charts.BarLabelDecorator<String>(
//                             labelPosition: charts.BarLabelPosition.outside,
//                             labelPadding: 5,
//                             labelAnchor: charts.BarLabelAnchor.end,
//                             outsideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                             insideLabelStyleSpec: charts.TextStyleSpec(
//                               color:
//                                   charts.ColorUtil.fromDartColor(Colors.black),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }
