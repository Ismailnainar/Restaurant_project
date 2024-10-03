import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class ChartData {
  ChartData(this.date, this.amount);
  final String date;
  final double amount;
}

class IncomeGraphDashboard extends StatefulWidget {
  const IncomeGraphDashboard({Key? key}) : super(key: key);

  @override
  State<IncomeGraphDashboard> createState() => _IncomeGraphDashboardState();
}

class _IncomeGraphDashboardState extends State<IncomeGraphDashboard> {
  List<Map<String, dynamic>> lastWeekPurchaseData = [];
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    piechart();
  }

  Future<void> piechart() async {
    String? cusid =
        await SharedPrefs.getCusId(); // Assuming SharedPrefs is defined
    String apiUrl = '$IpAddress/DashboardWeeklyRecords/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['IncomeLast7DaysDetails'] != null) {
      lastWeekPurchaseData =
          List<Map<String, dynamic>>.from(jsonData['IncomeLast7DaysDetails']);
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
          final amount = double.tryParse(data['amount_sum'] as String);
          if (date != null && amount != null && amount > 0) {
            return ChartData(date, amount);
          } else {
            return null;
          }
        })
        .whereType<ChartData>()
        .toList();

    return Row(
      children: [
        if (Responsive.isDesktop(context))
          Center(
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    children: [
                      Center(
                        child: SfCartesianChart(
                          palette: <Color>[Colors.blue], // Set a custom palette
                          primaryXAxis: CategoryAxis(
                            labelIntersectAction:
                                AxisLabelIntersectAction.rotate45,
                            labelPlacement: LabelPlacement.onTicks,
                            majorTickLines: MajorTickLines(size: 0),
                          ),
                          series: <ChartSeries>[
                            // Spline Area Chart for unique design
                            SplineAreaSeries<ChartData, String>(
                              dataSource: lineChartDataList,
                              xValueMapper: (ChartData data, _) =>
                                  data.date.substring(data.date.length - 2),
                              yValueMapper: (ChartData data, _) => data.amount,

                              // Applying a purple and blue gradient for the chart
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.blue.withOpacity(
                                      0.5), // Purple color with opacity
                                  Colors.blue.withOpacity(
                                      0.2) // Blue color with opacity
                                ],
                                stops: const [
                                  0.3,
                                  1
                                ], // Define how the gradient is distributed
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),

                              borderColor:
                                  Colors.blue, // Purple border around the chart
                              borderWidth: 2,

                              // Displaying data labels
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(fontSize: 10),
                              ),

                              markerSettings: MarkerSettings(
                                isVisible: true,
                                color:
                                    Colors.blue, // Purple color for the markers
                                shape: DataMarkerType.circle,
                              ),

                              enableTooltip: true,
                            ),
                          ],
                          tooltipBehavior: _tooltipBehavior,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (Responsive.isMobile(context) || Responsive.isTablet(context))
          Center(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.89,
                  child: Column(
                    children: [
                      Center(
                        child: SfCartesianChart(
                          palette: <Color>[Colors.blue],
                          primaryXAxis: CategoryAxis(
                            labelIntersectAction:
                                AxisLabelIntersectAction.rotate45,
                            labelPlacement: LabelPlacement.onTicks,
                            majorTickLines: MajorTickLines(size: 0),
                          ),
                          series: <ChartSeries>[
                            SplineAreaSeries<ChartData, String>(
                              dataSource: lineChartDataList,
                              xValueMapper: (ChartData data, _) =>
                                  data.date.substring(data.date.length - 2),
                              yValueMapper: (ChartData data, _) => data.amount,

                              // Applying a purple and blue gradient for the chart
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.blue.withOpacity(
                                      0.5), // Purple color with opacity
                                  Colors.blue.withOpacity(
                                      0.2) // Blue color with opacity
                                ],
                                stops: const [
                                  0.3,
                                  1
                                ], // Define how the gradient is distributed
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),

                              borderColor:
                                  Colors.blue, // Purple border around the chart
                              borderWidth: 2,

                              // Displaying data labels
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(fontSize: 10),
                              ),

                              markerSettings: MarkerSettings(
                                isVisible: true,
                                color:
                                    Colors.blue, // Purple color for the markers
                                shape: DataMarkerType.circle,
                              ),

                              enableTooltip: true,
                            ),
                          ],
                          tooltipBehavior: _tooltipBehavior,
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

class ExpensesChartView extends StatefulWidget {
  const ExpensesChartView({Key? key}) : super(key: key);

  @override
  State<ExpensesChartView> createState() => _ExpensesChartViewState();
}

class _ExpensesChartViewState extends State<ExpensesChartView> {
  List<Map<String, dynamic>> lastWeekPurchaseData = [];

  @override
  void initState() {
    super.initState();
    fetchPiedata();
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  Future<void> fetchPiedata() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/DashboardWeeklyRecords/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['ExpensesLast7DaysDetails'] != null) {
      lastWeekPurchaseData =
          List<Map<String, dynamic>>.from(jsonData['ExpensesLast7DaysDetails']);
    }

    DateTime now = DateTime.now();
    lastWeekPurchaseData = lastWeekPurchaseData.where((data) {
      DateTime date = DateTime.parse(data['dt']);
      return date.isAfter(now.subtract(Duration(days: 7))) &&
          date.isBefore(now.add(Duration(days: 1)));
    }).toList();

    // Assign unique colors
    for (int i = 0; i < lastWeekPurchaseData.length; i++) {
      lastWeekPurchaseData[i]['color'] = getRandomColor();
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _getDayOfWeek(String date) {
    DateTime parsedDate = DateTime.parse(date);
    switch (parsedDate.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PieChartData> pieChartDataList = lastWeekPurchaseData
        .where((data) => data['dt'] != null && data['amount_sum'] != null)
        .map((data) {
          final date = data['dt'] as String?;
          final amount = double.tryParse(data['amount_sum'].toString());
          final color = data['color'];
          if (date != null && amount != null && amount > 0) {
            return PieChartData(date, amount, color);
          } else {
            return null;
          }
        })
        .whereType<PieChartData>()
        .toList();

    double totalExpense =
        pieChartDataList.fold(0.0, (sum, data) => sum + data.amount);

    return Row(
      children: [
        if (Responsive.isDesktop(context))
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.21,
              height: MediaQuery.of(context).size.height * 0.50,
              child: _buildChart(pieChartDataList, totalExpense),
            ),
          ),
        if (Responsive.isMobile(context) || Responsive.isTablet(context))
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildChart(pieChartDataList, totalExpense),
            ),
          ),
      ],
    );
  }

  Widget _buildChart(List<PieChartData> pieChartDataList, double totalExpense) {
    return pieChartDataList.isNotEmpty
        ? SfCircularChart(
            title: ChartTitle(text: 'Last 7 days Expenses'),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x: point.y', // Customize the format here
            ),
            series: <CircularSeries>[
              RadialBarSeries<PieChartData, String>(
                dataSource: pieChartDataList,
                xValueMapper: (PieChartData data, _) =>
                    _getDayOfWeek(data.date),
                yValueMapper: (PieChartData data, _) => data.amount,
                pointColorMapper: (PieChartData data, index) => data.color,
                radius: '80%',
                innerRadius:
                    '70%', // Increase this for more space between segments
                strokeWidth: 15, // Adjust stroke width for spacing
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle:
                      TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
                dataLabelMapper: (PieChartData data, _) =>
                    '${_getDayOfWeek(data.date)}-${data.amount.toStringAsFixed(0)}',
              ),
            ],
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Total Expense',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('\$$totalExpense',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          )
        : noDataAvailable();
  }

  Widget noDataAvailable() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/imgs/receiver.png', width: 80, height: 80),
        Text('No Expenses available!',
            style: TextStyle(fontSize: 15, color: Colors.grey)),
      ],
    );
  }
}

class PieChartData {
  PieChartData(this.date, this.amount, this.color);
  final String date;
  final double amount;
  final Color color; // Add color property
}
