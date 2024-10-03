import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:flutter/material.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MakePaymentPage extends StatefulWidget {
  final Plan plan;
  final String cusid;

  MakePaymentPage({required this.plan, required this.cusid});

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final TextEditingController ContactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startChecking();
    fetchcusid();
    fetchSerialNumber();
  }

  Future<void> fetchcusid() async {
    String url = '$IpAddress/TrialUserRegistration/';
    bool dataFound = false;

    while (url != null) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> results = data['results'];

          for (var result in results) {
            if (result['cusid'] == widget.cusid) {
              setState(() {
                fullnameController.text = result['fullname'] ?? '';
                businessNameController.text = result['businessname'] ?? '';
                cityController.text = result['city'] ?? '';

                ContactController.text = result['phoneno'] ?? '';
                addressController.text = result['address'] ?? '';
              });
              dataFound = true;
              break;
            }
          }

          if (dataFound) break;

          url = data['next'];
        } else {
          // Handle server error
          print('Error: Unable to fetch data.');
          break;
        }
      } catch (e) {
        // Handle exceptions
        print('Error: $e');
        break;
      }
    }

    if (!dataFound) {
      // Handle case where data is not found
      print('No data found for cusid = ${widget.cusid}');
    }
  }

  String serialNumber = '';
  int payment_queue_id = 0;
  int parsedSerialNumber = 0;
  Future<void> fetchSerialNumber() async {
    try {
      String baseUrl = 'https://payment.mybodottoday.com/PaymentQueueSerialNo/';
      var response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        var jsonData = json.decode(response.body);

        if (jsonData.isNotEmpty) {
          var lastSerialNumber = jsonData.last["serialno"];

          if (lastSerialNumber is int) {
            // If it's already an integer, you can directly use it
            serialNumber = (lastSerialNumber + 1).toString();
          } else if (lastSerialNumber is String) {
            // If it's a string, try to parse it to an integer
            parsedSerialNumber = int.tryParse(lastSerialNumber)!;

            if (parsedSerialNumber != null) {
              serialNumber = (parsedSerialNumber + 1).toString();
            } else {
              // Handle the case where the "serialno" cannot be parsed to an integer
              print('Unable to parse serial number as an integer.');
            }
          }

          // Display the final serial number
          print("Final Serial Number === $serialNumber");
        } else {
          // Handle the case where the "Member_details" array is empty
          print('No data found in "Member_details".');
        }
      } else {
        // Handle the case where the request to fetch serial number was not successful
        print(
            'Failed to fetch serial number. Server returned ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      // Handle any other errors that may occur
      print('An error occurred while fetching serial number: $e');
    }
  }

  Future<void> postFinalSerialNumber() async {
    try {
      await fetchSerialNumber();

      String baseUrl = "https://payment.mybodottoday.com/PaymentQueueSerialNo/";

      // You can use finalSerialNumber in the request body
      var postResponse = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: {
          "serialno": serialNumber,
          // Add other required parameters here
        },
      );

      if (postResponse.statusCode == 200) {
        print('Final Serial Number posted successfully: $serialNumber');
      } else {
        print(
            'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
      }
    } catch (e) {
      // Handle any other errors that may occur
      print('An error occurred while posting final serial number: $e');
    }
  }

  Future<void> Payment_queue() async {
    await fetchSerialNumber();
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String baseUrl = "https://payment.mybodottoday.com/PaymentQueue/";

      String name =
          fullnameController.text.isNotEmpty ? fullnameController.text : '';
      String businessname = businessNameController.text.isNotEmpty
          ? businessNameController.text
          : '';
      String contact =
          ContactController.text.isNotEmpty ? ContactController.text : '';
      String address =
          addressController.text.isNotEmpty ? addressController.text : 'null';
      String amount = widget.plan.price.toString(); // Ensure amount is a string

      print(
          "cusid : ${widget.cusid} , nameeee : $name, businessname : $businessname, contact : $contact, address : $address, softtitle: ${widget.plan.title}, amount : $amount");

      var postResponse = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
          "Content-Type":
              "application/x-www-form-urlencoded", // Added Content-Type header
        },
        body: {
          "cusid": widget.cusid,
          "billno": serialNumber,
          "name": name,
          "businessname": businessname,
          "contact": contact,
          "address": address,
          "softplan": widget.plan.title,
          "amount": widget.plan.price,
          "status": "Trial",
          "dt": formattedDate,
          "type": "Online"
        },
      );

      if (postResponse.statusCode == 200) {
        // Changed status code to 200 (OK)
        var responseJson = json.decode(postResponse.body);

        // Extract the 'billno' and its ID from the response
        String billno = responseJson['billno'];
        int paymentQueueId = responseJson['id'];

        print("Posted data successfully!");
        print("billno: $billno");
        print("ID: $paymentQueueId");
      } else {
        var responseJson = json.decode(postResponse.body);

        // Extract the 'billno' and its ID from the response
        String billno = responseJson['billno'];
        int paymentQueueId = responseJson['id'];

        print(
            "Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}");
      }
    } catch (e) {
      // Handle any other errors that may occur
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print('An error occurred: $e');
    }
  }

  void _launchURL() async {
    String cusid = Uri.encodeComponent(widget.cusid);
    String url = 'https://sales.buyp.in/payment.aspx?TID=$cusid';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error occurred while launching the URL: $e');
    }
  }

  Timer? _timer;
  bool _isTimerActive = true;
  void startChecking() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_isTimerActive) {
        await _checkPaymentHistory();
      }
    });
  }

  void stopChecking() {
    _timer?.cancel();
    _isTimerActive = false;
  }

  Future<void> _checkPaymentHistory() async {
    try {
      final response = await http.get(
          Uri.parse("https://payment.mybodottoday.com/PaymentQueueHistory/"));
      if (response.statusCode == 200) {
        // Parse and check the response
        final List<dynamic> data = json.decode(response.body);
        // print("response body : ${response.body}");
        bool found = false;
        for (var item in data) {
          if (item['cusid'] == widget.cusid &&
              item['PaymentStatus'] == "Success") {
            print('Found matching record: ${item.toString()}');
            found = true;
            stopChecking();
            await UpdateTrialUserRegistrationTable();
            await deletePaymentQueueData();
            await deletePaymentQueuehistoryData();
          }
        }
        if (!found) {
          print(
              'No matching records found for cusid: ${widget.cusid} with status: Sucess');
        }
      } else {
        // If the server returns an error code
        print('Failed to load data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  int deleted_payment_queue_id = 0;
  int deleted_payment_queue_history_id = 0;

  Future<void> getDataBySerialNo() async {
    String baseUrl = "https://payment.mybodottoday.com/PaymentQueue/";

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        // Parse the response JSON
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Find the item with the matching serial number
        final item = data.firstWhere((item) => item['cusid'] == widget.cusid,
            orElse: () => {'id': null});

        if (item['id'] != null) {
          // Extract the 'id' from the item
          deleted_payment_queue_id = item['id'];

          print('Found item with id: $deleted_payment_queue_id');
        } else {
          print('Item not found with serial number: ${widget.cusid}');
        }
      } else {
        print('Failed to retrieve data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> getpaymentqueuehistory() async {
    String baseUrl = "https://payment.mybodottoday.com/PaymentQueueHistory/";

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        // Parse the response JSON
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Find the item with the matching serial number
        final item = data.firstWhere((item) => item['cusid'] == widget.cusid,
            orElse: () => {'id': null});

        if (item['id'] != null) {
          // Extract the 'id' from the item
          deleted_payment_queue_history_id = item['id'];

          print('Found item with id: $deleted_payment_queue_history_id');
        } else {
          print('Item not found with serial number: ${widget.cusid}');
        }
      } else {
        print('Failed to retrieve data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> deletePaymentQueueData() async {
    await getDataBySerialNo();
    int id = deleted_payment_queue_id;
    print(deleted_payment_queue_id);
    final url = Uri.parse('https://payment.mybodottoday.com/PaymentQueue/$id/');

    try {
      var response = await http.delete(url);

      while (response.statusCode == 301 || response.statusCode == 302) {
        // Handle the redirect by fetching the new URL
        final newUrl = Uri.parse(response.headers['location']!);
        response = await http.delete(newUrl);
      }

      if (response.statusCode == 204) {
        print('Data deleted successfully');
      } else {
        print('Failed to delete data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> deletePaymentQueuehistoryData() async {
    await getpaymentqueuehistory();
    int id = deleted_payment_queue_history_id;
    print(deleted_payment_queue_history_id);
    final url =
        Uri.parse('https://payment.mybodottoday.com/PaymentQueueHistory/$id/');

    try {
      var response = await http.delete(url);

      while (response.statusCode == 301 || response.statusCode == 302) {
        // Handle the redirect by fetching the new URL
        final newUrl = Uri.parse(response.headers['location']!);
        response = await http.delete(newUrl);
      }

      if (response.statusCode == 204) {
        print('Data deleted successfully');
      } else {
        print('Failed to delete data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  late int userId;
  Future<void> fetchUserDetails(String cusid) async {
    String baseUrl = '$IpAddress/TrialUserRegistration/?cusid=$cusid';
    List<dynamic> allResults = [];

    Future<void> fetchPage(String url) async {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          // Add the results of the current page
          allResults.addAll(results);

          // Check if there's a next page and fetch it
          if (data['next'] != null) {
            await fetchPage(data['next']);
          } else {
            // Once all pages are fetched, process the results
            processResults(cusid, allResults);
          }
        } else {
          print('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    // Start fetching from the base URL
    await fetchPage(baseUrl);
  }

  void processResults(String cusid, List<dynamic> results) {
    // Filter the results based on cusid
    final filteredResults =
        results.where((user) => user['cusid'] == cusid).toList();

    if (filteredResults.isEmpty) {
      print('User with cusid $cusid not found.');
    } else {
      final user =
          filteredResults[0]; // Assuming you want the first matched user
      setState(() {
        userId = user['id']; // Adjust based on the actual key for ID
        print('User ID: $userId'); // Print or use the ID as needed
      });

      // Store the ID for future use if necessary
    }
  }

  Future<void> UpdateTrialUserRegistrationTable() async {
    await fetchUserDetails(widget.cusid);
    if (userId == null) {
      print('User ID is not set. Cannot update data.');
      return;
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    DateTime expiryDate;
    print('plan amount ${widget.plan.price}');
    // Determine the expiry date based on the plan value
    if (widget.plan.price == "299") {
      expiryDate = now.add(Duration(days: 30));
    } else if (widget.plan.price == "1699") {
      expiryDate = now.add(Duration(days: 180));
    } else {
      expiryDate = now.add(Duration(days: 365));
    }
    String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

    // Prepare data to be sent in the body
    Map<String, dynamic> putData = {
      "cusid": widget.cusid,
      "trailstatus": "Payment",
      "trialstartdate": formattedDate,
      "trialenddate": formattedExpiryDate,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putData);
    print('Request data: $jsonData'); // Print the data being sent

    // Make PUT request to the API with dynamic ID
    String apiUrl =
        '$IpAddress/TrialUserRegistration/$userId/'; // Use the dynamic ID
    try {
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        // Data updated successfully
        print('Data updated successfully');
      } else {
        // Data updating failed
        print(
            'Failed to update data: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
        backgroundColor: widget.plan.color,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: Responsive.isDesktop(context)
            ? EdgeInsets.only(right: 500, left: 500)
            : EdgeInsets.only(
                right: 80,
                left: 80,
              ),
        child: Center(
          child: Card(
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: widget.plan.color.withOpacity(0.1),
                    child: Image.asset(
                      widget.plan.icon,
                      height: 50,
                      width: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Plan: ${widget.plan.title}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.plan.color,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Amount: ₹ ${widget.plan.price}',
                    style: TextStyle(
                      fontSize: 20,
                      color: widget.plan.color,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard('Full Name: ${fullnameController.text}'),
                  SizedBox(height: 20),
                  _buildInfoCard(
                      'Business Name: ${businessNameController.text}'),
                  SizedBox(height: 20),
                  _buildInfoCard('City: ${cityController.text}'),
                  SizedBox(height: 20),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(widget.plan.color),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await Payment_queue();
                      await postFinalSerialNumber();
                      _launchURL();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 14.0,
                        right: 14.0,
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      child: Text(
                        'Proceed to Pay',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    final List<String> parts = text.split(': ');
    final String label = parts[0] + ': ';
    final String value = parts[1];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 102, 100, 100),
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}

class Plan {
  final String title;
  final String duration;
  final String price;
  final List<String> features;
  final Color color;
  final String icon;
  final String image;

  Plan({
    required this.title,
    required this.duration,
    required this.price,
    required this.features,
    required this.color,
    required this.icon,
    required this.image,
  });
}
