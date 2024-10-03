import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:restaurantsoftware/Modules/constaints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController _textController2 = TextEditingController();
  FocusNode UpdateNewFocus = FocusNode();
  final FocusNode _updateNewUserFocus = FocusNode();

  TextEditingController NewUserPasswordUpdateController =
      TextEditingController();
  List<String> NewUserUpdateRoleList = [];
  String? UserNameselectedValue;
  TextEditingController UpdateDropdownNewUserNameController =
      TextEditingController();
  String? selectedRole;
  String? selectedEmail;

  String? selectedValue;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> PasswordtableData = [];
  double PasswordtotalAmount = 0.0;
  List<String> UpdateNewUserRoleList = [];
  List<String> AddNewUserRoleList = [];

  TextEditingController AddNewUserRoleController = TextEditingController();
  FocusNode AddNewUserFocus = FocusNode();
  final FocusNode _addNewUserFocus = FocusNode();

  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  List<String> _uniqueMenus = []; // List of unique menu names
  List<Map<String, dynamic>> _subMenuItems = [];
  String _selectedMenu = '';
  String? _errorMessage;
  String menu = '';
  String email = '';
  bool hasUnsavedChanges = false;
  Map<String, List<int>> _selectedIndicesByMenu = {};

  var categoryStatusList = [];

  String role = '';
  void _toggleSelection(String menu, int index) {
    setState(() {
      final item = _subMenuItems[index]['submenu'];
      final isSelected = _selectedIndicesByMenu[menu]?.contains(index) ?? false;

      if (isSelected) {
        _selectedIndicesByMenu[menu]?.remove(index);
        _categoryStatusMap[item] = false; // Mark as unselected
      } else {
        _selectedIndicesByMenu[menu] = (_selectedIndicesByMenu[menu] ?? [])
          ..add(index);
        _categoryStatusMap[item] = true; // Mark as selected
      }

      hasUnsavedChanges = true; // Mark as having unsaved changes
    });
  }

// Method to handle menu selection and reset submenu state
  void _onMenuSelected(String menu) {
    setState(() {
      _selectedMenu = menu;
      _fetchSubMenuItems(menu);

      // Reset selected indices for the new menu
      _selectedIndicesByMenu.clear();
    });
  }

  final FocusNode _addNewUserFocusNode = FocusNode(); // Add this line

  void _showValidationDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text('Kindly Check Your User Details...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).requestFocus(_addNewUserFocusNode);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _showSubMenus = false;
  void _validateAndSelectMenu(String? value) {
    if (AddNewUserRoleController.text.isEmpty ||
        UpdateDropdownNewUserNameController.text.isEmpty) {
      _showValidationDialog();
    } else if (hasUnsavedChanges) {
      // Show confirmation dialog for unsaved changes
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Unsaved Changes'),
            content: Text(
                'You have unsaved changes. Do you want to save them before switching menus?'),
            actions: [
              TextButton(
                onPressed: () async {
                  // Check if the category status map is empty
                  if (_categoryStatusMap.isEmpty) {
                    print('No records available');
                    await saveUser(); // Call saveUser if no records are available
                    Navigator.of(context).pop(); // Close the dialog
                    _switchMenu(value); // Switch to the new menu
                  } else {
                    String role = AddNewUserRoleController.text;
                    String email = UpdateDropdownNewUserNameController.text;

                    if (role.isEmpty || email.isEmpty) {
                      print('Role or email is not set');
                      return;
                    }

                    print('role : $role');
                    print('email : $email');

                    // Fetch user ID for update, including the current menu
                    int? userId =
                        await fetchIdForUpdate(role, email, _selectedMenu);

                    if (userId == null) {
                      print('ID is not available for update');
                      // Save as a new user if ID is not found
                      await saveUser();
                      Navigator.of(context).pop(); // Close the dialog
                      _switchMenu(value); // Switch to the new menu
                    } else {
                      await updateUserDetails(
                          userId); // Call the update function
                      Navigator.of(context).pop(); // Close the dialog
                      _switchMenu(value); // Switch to the new menu
                    }
                  }
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  _switchMenu(value);
                  Navigator.of(context).pop(); // Close the dialog
                  // Do not switch the menu if the user chooses not to save
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
    } else {
      _switchMenu(value);
    }
  }

  void _switchMenu(String? value) {
    setState(() {
      _selectedMenu = value!;
      _showSubMenus = true; // Allow submenu display after validation
      _fetchSubMenuItems(value);
      _fetchCategoryStatus(
          UpdateDropdownNewUserNameController.text, _selectedMenu);
      hasUnsavedChanges = false; // Reset unsaved changes flag
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
    fetchDetails();
    PasswordfetchData();
    _fetchSubMenuItems(menu);
    _fetchCategoryStatus(email, menu);
    fetchIdForUpdate(role, email, menu);
  }

  Future<void> PasswordfetchData() async {
    try {
      // Retrieve the user ID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');

      // Make an HTTP GET request to fetch password data
      final response =
          await http.get(Uri.parse('$IpAddress/Settings_Password/$cusid/'));

      if (response.statusCode == 200) {
        // Decode the response body
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() async {
            // Convert the fetched data to a list of maps
            PasswordtableData =
                List<Map<String, dynamic>>.from(data['results']);

            // Debugging: Print the fetched data
            // print('Fetched Password Data: $PasswordtableData');

            // Retrieve the selected role from the TextEditingController
            String selectedRole = AddNewUserRoleController.text.trim();
            // print('Selected Role from Controller: "$selectedRole"');

            if (selectedRole.isNotEmpty) {
              // Filter emails and IDs based on the selected role
              List<Map<String, dynamic>> filteredData = PasswordtableData.where(
                  (item) =>
                      item['role'] != null &&
                      item['role'].toString().trim() == selectedRole).toList();

              // Print the filtered data
              // print('Filtered Data: $filteredData');

              // Extract emails and IDs from the filtered data
              UpdateNewUserRoleList =
                  filteredData.map((item) => item['email'].toString()).toList();

              List<int> filteredIds =
                  filteredData.map((item) => item['id'] as int).toList();
              await processResults;
              // Debugging: Print the filtered emails and IDs
              // print('Filtered Emails: $UpdateNewUserRoleList');
              // print('Filtered IDs: $filteredIds');

              // Call the updateNewUserData function for each filtered ID
              // for (int id in filteredIds) {
              //   await updateNewUserData(id);
              // }
            } else {
              // Handle case when no role is selected
              UpdateNewUserRoleList = [];
              // print('Selected role is empty');
            }
          });
        } else {
          setState(() {
            UpdateNewUserRoleList = [];
          });
          print('No data available');
        }
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      // print('Failed to fetch passwords: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cusid = prefs.getString('cusid');
    final response =
        await http.get(Uri.parse('$IpAddress/Settings_Role/$cusid/'));
    // print('res: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final results = List<Map<String, dynamic>>.from(data['results']);
        results.removeWhere(
            (item) => item['role'].toString().toLowerCase() == 'admin');

        setState(() {
          AddNewUserRoleList =
              List<String>.from(results.map((item) => item['role'].toString()));
        });
        return results;
      } else {
        throw Exception('No data available');
      }
    } else {
      throw Exception('Failed to load details');
    }
  }

  Future<void> _fetchMenuItems() async {
    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Settings_Menuitem/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // print('Response data: $data'); // Debugging

        // Check if the data is a List
        if (data != null && data is List) {
          // Create a set to keep track of unique menu names
          final Set<String> uniqueMenuSet = Set<String>();

          // Extract unique menu names
          final List<String> uniqueMenus = data
              .where((item) => item['menu'] != null)
              .map<String>((item) => item['menu'] as String)
              .where((menu) {
            // Add to list only if it's not already in the set
            if (uniqueMenuSet.contains(menu)) {
              return false;
            } else {
              uniqueMenuSet.add(menu);
              return true;
            }
          }).toList();

          setState(() {
            _uniqueMenus = uniqueMenus;
            _fetchCategoryStatus(email, menu);
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
    }
  }

  Future<void> _fetchSubMenuItems(String menu) async {
    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Settings_Menuitem/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data != null && data is List) {
          final List<Map<String, dynamic>> submenuItems = data
              .where((item) => item['menu'] == menu)
              .map<Map<String, dynamic>>((item) => item)
              .toList();
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            _subMenuItems = submenuItems;
          });

          // Fetch CategoryStatus after fetching submenu items
          await _fetchCategoryStatus(email, menu);
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load submenu items');
      }
    } catch (e) {
      print('Error fetching submenu items: $e');
    }
  }

  bool isCategoryStatusTrue = false; // To store the overall category status
  Map<String, bool> _categoryStatusMap =
      {}; // To store status for each category

// //perfect code
  Future<void> _fetchCategoryStatus(
    String email,
    String menu,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cusid = prefs.getString('cusid');
    email = UpdateDropdownNewUserNameController
        .text; // Ensure this is correctly set
    try {
      String url = '$IpAddress/Settings_usermanagement/$cusid/';
      bool hasNextPage = true;
      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Log the entire response for debugging
          // print('API Response: $data');

          if (data['results'] != null && data['results'].isNotEmpty) {
            final results = data['results'];

            _categoryStatusMap.clear();

            // // Fetch Settings Category Status
            if (menu == 'Settings') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'Settings') {
                  final settingsCategoryStatus = result['CategoryStatus'];

                  // Ensure that settingsCategoryStatus is not empty
                  if (settingsCategoryStatus.isNotEmpty) {
                    _categoryStatusMap.addAll({
                      for (var status in settingsCategoryStatus)
                        if (status is Map)
                          for (var key in status.keys)
                            key: status[key] == 'true'
                    });

                    // Set Purchase State
                    settingsproductcategory =
                        settingsCategoryStatus[0]['product category'] == 'true';
                    settingsproductdetails =
                        settingsCategoryStatus[0]['product details'] == 'true';
                    settingsgstdetails =
                        settingsCategoryStatus[0]['gst details'] == 'true';
                    settingsstaffdetails =
                        settingsCategoryStatus[0]['staff details'] == 'true';
                    settingspaymentmethod =
                        settingsCategoryStatus[0]['payment method'] == 'true';
                    settingsaddsalespoint =
                        settingsCategoryStatus[0]['add sales points'] == 'true';
                    settingsprinterdetails =
                        settingsCategoryStatus[0]['printer details'] == 'true';
                    settingslogindetails =
                        settingsCategoryStatus[0]['login details'] == 'true';

                    print('Settings Category Status Map: $_categoryStatusMap');
                    return; // Exit after fetching settings
                  }
                }
              }
            }

            // Fetch Purchase Category Status
            if (menu == 'purchase') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'purchase') {
                  final purchaseCategoryStatus = result['CategoryStatus'][0];
                  final purchaseCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in purchaseCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  purchasenewpurchase =
                      purchaseCategoryStatus['new purchase'] == 'true';
                  purchaseeditpurchase =
                      purchaseCategoryStatus['edit purchase'] == 'true';
                  purchasepaymentdetails =
                      purchaseCategoryStatus['payment details'] == 'true';
                  purchaseproductcategory =
                      purchaseCategoryStatus['product category'] == 'true';
                  purchaseproductdetails =
                      purchaseCategoryStatus['product details'] == 'true';
                  purchaseCustomer =
                      purchaseCategoryStatus['purchas customer'] == 'true';

                  print('Purchase Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'sales') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'sales') {
                  final salesCategoryStatus = result['CategoryStatus'][0];
                  final salesCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in salesCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  // setState(() {
                  salesnewsale = salesCategoryStatus['new sales'] == 'true';
                  saleseditsales = salesCategoryStatus['edit sales'] == 'true';
                  salespaymentdetails =
                      salesCategoryStatus['payment details'] == 'true';
                  salescustomer =
                      salesCategoryStatus['sales customer'] == 'true';
                  salestablecount =
                      salesCategoryStatus['table count'] == 'true';
                  print('sales Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'quick sales') {
              for (var result in results) {
                if (result['email'] == email &&
                    result['menu'] == 'quick sales') {
                  final quicksalesCategoryStatus = result['CategoryStatus'][0];
                  final quicksalesCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in quicksalesCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  quicksales =
                      quicksalesCategoryStatus['quick sales'] == 'true';
                  print('qsales Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'order sales') {
              for (var result in results) {
                if (result['email'] == email &&
                    result['menu'] == 'order sales') {
                  final ordersalesCategoryStatus = result['CategoryStatus'][0];
                  final ordersalesCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in ordersalesCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  ordersalesnew =
                      ordersalesCategoryStatus['new order sales'] == 'true';
                  ordersalesedit =
                      ordersalesCategoryStatus['edit order slaes'] == 'true';
                  ordersalespaymentdetails =
                      ordersalesCategoryStatus['payment details'] == 'true';
                  print('order Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'vendor sales') {
              for (var result in results) {
                if (result['email'] == email &&
                    result['menu'] == 'vendor sales') {
                  final vendorsalesCategoryStatus = result['CategoryStatus'][0];
                  final vendorsalesCategoryStatusList =
                      result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in vendorsalesCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  vendorsalesnew =
                      vendorsalesCategoryStatus['new vendorsales'] == 'true';
                  vendorsalespaymentdetails =
                      vendorsalesCategoryStatus['payment details'] == 'true';
                  vendorcustomer =
                      vendorsalesCategoryStatus['vendor customers'] == 'true';
                  print('vendro Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'stock') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'stock') {
                  final stocksalesCategoryStatus = result['CategoryStatus'][0];
                  final stocksalesCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in stocksalesCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  stocknew = stocksalesCategoryStatus['new stock'] == 'true';
                  print('stock Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'wastage') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'wastage') {
                  final wastageCategoryStatus = result['CategoryStatus'][0];
                  final wastageCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in wastageCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  wastageadd = wastageCategoryStatus['add wastage'] == 'true';
                  print('wastage Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'kitchen') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'kitchen') {
                  final kitchenCategoryStatus = result['CategoryStatus'][0];
                  final kitchenCategoryStatusList = result['CategoryStatus'];

                  _categoryStatusMap.addAll({
                    for (var status in kitchenCategoryStatusList)
                      if (status is Map)
                        for (var key in status.keys) key: status[key] == 'true'
                  });

                  // Set Purchase State
                  kitchenusagesentry =
                      kitchenCategoryStatus['usage entry'] == 'true';
                  print('kitcehn Category Status Map: $_categoryStatusMap');
                  return; // Exit after fetching purchase
                }
              }
            }
            if (menu == 'reports') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'reports') {
                  final reportCategoryStatus = result['CategoryStatus'];

                  // Ensure that reportCategoryStatus is not empty
                  if (reportCategoryStatus.isNotEmpty) {
                    _categoryStatusMap.addAll({
                      for (var status in reportCategoryStatus)
                        if (status is Map)
                          for (var key in status.keys)
                            key: status[key] == 'true'
                    });

                    // Set Purchase State
                    report = reportCategoryStatus[0]['reports'] == 'true';

                    print('Report Category Status Map: $_categoryStatusMap');
                    return; // Exit after fetching report
                  }
                }
              }
            }
            if (menu == 'daysheet') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'daysheet') {
                  final daysheetCategoryStatus = result['CategoryStatus'];

                  // Ensure that daysheetCategoryStatus is not empty
                  if (daysheetCategoryStatus.isNotEmpty) {
                    _categoryStatusMap.addAll({
                      for (var status in daysheetCategoryStatus)
                        if (status is Map)
                          for (var key in status.keys)
                            key: status[key].toString() == 'true'
                    });

                    // Set Purchase State
                    daysheetincomeentry = (daysheetCategoryStatus[0]
                            ['income entry'] as String?) ==
                        'true';
                    daysheetexpenseentry = (daysheetCategoryStatus[0]
                            ['expense entry'] as String?) ==
                        'true';
                    daysheetexepensescategory = (daysheetCategoryStatus[0]
                            ['expense category'] as String?) ==
                        'true';

                    print('daysheet Category Status Map: $_categoryStatusMap');
                    return; // Exit after fetching report
                  }
                }
              }
            }
            if (menu == 'graph') {
              for (var result in results) {
                if (result['email'] == email && result['menu'] == 'graph') {
                  final graphCategoryStatus = result['CategoryStatus'];

                  // Ensure that daysheetCategoryStatus is not empty
                  if (graphCategoryStatus.isNotEmpty) {
                    _categoryStatusMap.addAll({
                      for (var status in graphCategoryStatus)
                        if (status is Map)
                          for (var key in status.keys)
                            key: status[key].toString() == 'true'
                    });

                    // Set Purchase State
                    daysheetincomeentry =
                        (graphCategoryStatus[0]['graph'] as String?) == 'true';

                    print('graph Category Status Map: $_categoryStatusMap');
                    return; // Exit after fetching report
                  }
                }
              }
            }

            if (data['next'] != null) {
              url = data['next']; // Update URL to the next page
            } else {
              hasNextPage = false; // No more pages to fetch
            }
          } else {
            // print('No Category Status data available');
          }
        } else {
          throw Exception('Failed to load category status');
        }
      }
    } catch (e) {
      print('Error fetching category status: $e');
    }
  }

//correct save code
  Future<void> saveUser() async {
    if (_categoryStatusMap.isEmpty) {
      print('CategoryStatus cannot be empty');
      return;
    }

    // Construct CategoryStatus string dynamically from _subMenuItems
    String categoryStatusString = _subMenuItems.map((item) {
      String category =
          item['submenu']; // Assuming 'submenu' is the key for category
      bool status = _categoryStatusMap[category] ?? false;
      return '$category:$status';
    }).join(',');
    print('submenu: $_subMenuItems');
    print('categoryStatusString: $categoryStatusString');

    categoryStatusString = '{$categoryStatusString}';

    final Map<String, dynamic> userData = {
      "id": 1, // You might want to generate or fetch this dynamically
      "cusid": "BTRM_1", // Example static value
      "role": AddNewUserRoleController.text,
      "email": UpdateDropdownNewUserNameController.text,
      "menu": _selectedMenu,
      "CategoryStatus": categoryStatusString, // Dynamically constructed string
    };

    final response = await http.post(
      Uri.parse(
          '$IpAddress/Settings_usermanagementalldatas/'), // Replace with your URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 204) {
      // Check if the response body indicates success
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true) {
        // Assuming your API returns a 'success' field
        print('User saved successfully');
        successRoleAdded(); // Call the success dialog here
        await Future.delayed(Duration(seconds: 1));
        hasUnsavedChanges = false;
      } else {
        // print('Failed to save user: ${response.body}');
      }
    } else {
      // print('Failed to save user: ${response.body}');
    }
  }

  void successRoleAdded() {
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
                    'Successfully Added..!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  Future<int?> fetchIdForUpdate(String role, String email, String menu) async {
    try {
      bool hasNextPage = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');
      String url = '$IpAddress/Settings_usermanagementalldatas';
      while (hasNextPage) {
        // Fetch user management data
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            List<dynamic> results = data['results'];

            for (var user in results) {
              String? userRole = user['role'];
              String? userEmail = user['email'];
              String? userMenu = user['menu'];
              int? userId = user['id'];

              // Check for matching role, email, and menu
              if (userRole == role && userEmail == email && userMenu == menu) {
                print('Matching User ID: $userId');
                return userId; // Return the found user ID
              }
              if (data['next'] != null) {
                url = data['next']; // Update URL to the next page
              } else {
                hasNextPage = false; // No more pages to fetch
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return null; // Return null if no match is found
  }

  Future<void> updateUserDetails(int userId) async {
    if (_categoryStatusMap.isEmpty) {
      print('CategoryStatus cannot be empty');
      return;
    }

    // Construct the CategoryStatus string dynamically
    String categoryStatusString = _subMenuItems.map((item) {
      String category = item['submenu'];
      bool status = _categoryStatusMap[category] ?? false;
      return '$category:$status';
    }).join(',');
    categoryStatusString = '{$categoryStatusString}';

    final Map<String, dynamic> userData = {
      "role": AddNewUserRoleController.text,
      "email": UpdateDropdownNewUserNameController.text,
      "menu": _selectedMenu,
      "CategoryStatus": categoryStatusString,
    };

    try {
      final response = await http.put(
        Uri.parse('$IpAddress/Settings_usermanagementalldatas/$userId/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
        successRoleAdded(); // Call the success dialog here
        hasUnsavedChanges = false; // Reset unsaved changes flag
      } else {
        print('Failed to update user: ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width * 0.6;
    bool isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 8.0 : 3.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 12,
                      child: Container(
                        height: screenHeight,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(
                            isDesktop ? 8.0 : 3.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'User Management',
                                  style: HeadingStyle,
                                ),
                              ),
                              Divider(color: Colors.grey[300]),
                              SizedBox(
                                height:
                                    Responsive.isDesktop(context) ? 20.0 : 5.0,
                              ),
                              _newUsertopWebDesign(),
                              SizedBox(
                                height:
                                    Responsive.isDesktop(context) ? 20.0 : 5.0,
                              ),
                              Divider(color: Colors.grey[300]),
                              SizedBox(
                                height:
                                    Responsive.isDesktop(context) ? 10.0 : 2.0,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Row(
                                  children: [
                                    // Menu Column
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? 250
                                            : 160,
                                        // height: 500,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  isDesktop ? 26 : 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        Icons.menu,
                                                        size: 20,
                                                        color: subcolor,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Menu Items',
                                                          style: HeadingStyle),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15.0),
                                                  Expanded(
                                                    child: ListView(
                                                      children: _uniqueMenus
                                                          .map((menuItem) {
                                                        return Row(
                                                          children: [
                                                            Radio<String>(
                                                              value: menuItem,
                                                              groupValue:
                                                                  _selectedMenu,
                                                              onChanged:
                                                                  (value) {
                                                                _validateAndSelectMenu(
                                                                    value);
                                                              },
                                                            ),
                                                            Text(menuItem,
                                                                style:
                                                                    commonLabelTextStyle),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? screenWidth
                                            : 180,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        // height:500,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  isDesktop ? 26 : 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text('Submenu Items',
                                                      style: HeadingStyle),
                                                  SizedBox(height: 20.0),
                                                  Expanded(
                                                    child: _showSubMenus
                                                        ? SingleChildScrollView(
                                                            // Make the GridView scrollable on mobile
                                                            child: GridView
                                                                .builder(
                                                              physics:
                                                                  NeverScrollableScrollPhysics(), // Disable GridView scrolling
                                                              shrinkWrap:
                                                                  true, // Allow GridView to take only necessary space
                                                              gridDelegate:
                                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          Responsive.isDesktop(context)
                                                                              ? 5
                                                                              : 1, // Change based on screen size
                                                                      crossAxisSpacing: Responsive.isDesktop(
                                                                              context)
                                                                          ? 16.0
                                                                          : 8.0,
                                                                      mainAxisSpacing: Responsive.isDesktop(
                                                                              context)
                                                                          ? 16.0
                                                                          : 8.0,
                                                                      childAspectRatio: Responsive.isDesktop(
                                                                              context)
                                                                          ? 1.8
                                                                          : 2.9 // Adjusted aspect ratio for mobile
                                                                      ),

                                                              itemCount:
                                                                  _subMenuItems
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final item =
                                                                    _subMenuItems[
                                                                        index];
                                                                final isSelected =
                                                                    _selectedIndicesByMenu[_selectedMenu]
                                                                            ?.contains(index) ??
                                                                        false;

                                                                // Determine the color based on the category status and selection state
                                                                final categoryStatus =
                                                                    _categoryStatusMap[
                                                                            item['submenu']] ??
                                                                        false;
                                                                final containerColor = isSelected
                                                                    ? subcolor
                                                                    : (categoryStatus
                                                                        ? subcolor
                                                                        : Colors
                                                                            .white);
                                                                final textColor = isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : (categoryStatus
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black);
                                                                final iconColor = isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : (categoryStatus
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black);

                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    _toggleSelection(
                                                                        _selectedMenu,
                                                                        index);
                                                                    setState(
                                                                        () {}); // Refresh to show updated state
                                                                  },
                                                                  child:
                                                                      Tooltip(
                                                                    message: categoryStatus
                                                                        ? 'Double-click to select this item'
                                                                        : '',
                                                                    preferBelow:
                                                                        false, // Show tooltip above the container
                                                                    child:
                                                                        Container(
                                                                      width: Responsive.isDesktop(
                                                                              context)
                                                                          ? 100
                                                                          : 80, // Adjusted width for mobile
                                                                      height: Responsive.isDesktop(
                                                                              context)
                                                                          ? 100
                                                                          : 30, // Adjusted height for mobile
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          4.0), // Reduced padding for mobile
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color:
                                                                            containerColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.black.withOpacity(0.3),
                                                                            spreadRadius:
                                                                                1,
                                                                            blurRadius:
                                                                                4,
                                                                            offset:
                                                                                Offset(0, 2),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Responsive.isDesktop(
                                                                              context)
                                                                          ? Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.production_quantity_limits,
                                                                                  size: 20.0,
                                                                                  color: iconColor,
                                                                                ),
                                                                                SizedBox(height: 4.0),
                                                                                Text(
                                                                                  item['submenu'] ?? '',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: textColor,
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              // Use Row for mobile layout

                                                                              children: [
                                                                                SizedBox(width: 15.0), // Space between icon and text

                                                                                Icon(
                                                                                  Icons.production_quantity_limits,
                                                                                  size: 15.0,
                                                                                  color: iconColor,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 4.0,
                                                                                ),
                                                                                SingleChildScrollView(
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  child: Container(
                                                                                    child: Text(
                                                                                      item['submenu'] ?? '',
                                                                                      style: TextStyle(
                                                                                        fontSize: 12.0, // Adjusted font size for mobile
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: textColor,
                                                                                      ),
                                                                                      textAlign: TextAlign.start, // Align text to start
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons.menu,
                                                                  size:
                                                                      isDesktop
                                                                          ? 40
                                                                          : 20,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Text(
                                                                  'Kindly select a menu item',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        isDesktop
                                                                            ? 16
                                                                            : 13,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 25.0),
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            // Check if the category status map is empty
                                                            if (_categoryStatusMap
                                                                .isEmpty) {
                                                              print(
                                                                  'No records available');
                                                              await saveUser(); // Call saveUser if no records are available
                                                            } else {
                                                              String role =
                                                                  AddNewUserRoleController
                                                                      .text;
                                                              String email =
                                                                  UpdateDropdownNewUserNameController
                                                                      .text;

                                                              if (role.isEmpty ||
                                                                  email
                                                                      .isEmpty) {
                                                                print(
                                                                    'Role or email is not set');
                                                                return;
                                                              }

                                                              print(
                                                                  'role : $role');
                                                              print(
                                                                  'email : $email');

                                                              // Fetch user ID for update, including the current menu
                                                              int? userId =
                                                                  await fetchIdForUpdate(
                                                                      role,
                                                                      email,
                                                                      _selectedMenu);

                                                              if (userId ==
                                                                  null) {
                                                                print(
                                                                    'ID is not available for update');
                                                                // Perform POST request here if needed
                                                                await saveUser(); // Save as a new user if ID is not found
                                                              } else {
                                                                await updateUserDetails(
                                                                    userId); // Call the update function
                                                              }
                                                            }
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2.0),
                                                            ),
                                                            backgroundColor:
                                                                subcolor,
                                                            minimumSize: Size(
                                                                isDesktop
                                                                    ? 45.0
                                                                    : 20.0,
                                                                isDesktop
                                                                    ? 31.0
                                                                    : 20.0), // Set width and height
                                                          ),
                                                          child: Text(
                                                            'Save',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _newUsertopWebDesign() {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Role',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: Responsive.isDesktop(context)
                        ? 150
                        : MediaQuery.of(context).size.width * 0.30,
                    child: Container(
                      height: 25,
                      width: 100,
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(child: AddNewUserRoleDropdown()),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Id',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              Container(
                width: Responsive.isDesktop(context)
                    ? 150
                    : MediaQuery.of(context).size.width * 0.32,
                child: Container(
                  height: 25,
                  width: 100,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Container(child: UpdateNewUserRoleDropdownCode()),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  // Clear the controllers and lists to refresh the UI
                  AddNewUserRoleController.clear();
                  UpdateDropdownNewUserNameController.clear();
                  _subMenuItems.clear();

                  // Optionally, you can reset any other state variables here
                  // For example, resetting selected values or loading new data
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(isDesktop ? 45.0 : 25.0,
                    isDesktop ? 31.0 : 25.0), // Set width and height
              ),
              child: Text(
                'Refresh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget AddNewUserRoleDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                AddNewUserRoleList.indexOf(AddNewUserRoleController.text);
            if (currentIndex < AddNewUserRoleList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                AddNewUserRoleController.text =
                    AddNewUserRoleList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                AddNewUserRoleList.indexOf(AddNewUserRoleController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                AddNewUserRoleController.text =
                    AddNewUserRoleList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: AddNewUserFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedValue = suggestion;
              AddNewUserRoleController.text = suggestion!;
              _filterEnabled = false;
              _fieldFocusChange(context, AddNewUserFocus, _addNewUserFocus);
            });
          },
          controller: AddNewUserRoleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return AddNewUserRoleList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return AddNewUserRoleList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = AddNewUserRoleList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
                          AddNewUserRoleList.indexOf(
                                  AddNewUserRoleController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion,
                    style: DropdownTextStyle,
                  ),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            AddNewUserRoleController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(_addNewUserFocus);

            // Debugging: Check the controller text
            // print('Controller Updated: ${AddNewUserRoleController.text}');
            print('Selected Role: $suggestion');

            // Fetch data with the updated role
            PasswordfetchData();
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

//perfect code for dropdown
//do only filtered
  Widget UpdateNewUserRoleDropdownCode() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = UpdateNewUserRoleList.indexOf(
                UpdateDropdownNewUserNameController.text);
            if (currentIndex < AddNewUserRoleList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                UpdateDropdownNewUserNameController.text =
                    UpdateNewUserRoleList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = UpdateNewUserRoleList.indexOf(
                UpdateDropdownNewUserNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                UpdateDropdownNewUserNameController.text =
                    UpdateNewUserRoleList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: UpdateNewFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedValue = suggestion;
              UpdateDropdownNewUserNameController.text = suggestion!;
              _filterEnabled = false;
              _fieldFocusChange(context, UpdateNewFocus, _updateNewUserFocus);
              PasswordfetchData();
            });
          },
          controller: UpdateDropdownNewUserNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return UpdateNewUserRoleList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return UpdateNewUserRoleList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = UpdateNewUserRoleList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
                          UpdateNewUserRoleList.indexOf(
                                  UpdateDropdownNewUserNameController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion,
                    style: DropdownTextStyle,
                  ),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            UpdateDropdownNewUserNameController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(_updateNewUserFocus);
            print('Selected Email: $suggestion');

            PasswordfetchData();
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
