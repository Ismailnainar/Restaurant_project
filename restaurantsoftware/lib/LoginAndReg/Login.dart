
import 'package:pinput/pinput.dart';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/LoginAndReg/OnboardingScreen.dart';
import 'package:restaurantsoftware/LoginAndReg/RegForm.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
// import 'package:ProductRestaurant/Database/IpAddress.dart';
// import 'package:ProductRestaurant/LoginAndReg/OnboardingScreen.dart';
// import 'package:ProductRestaurant/Modules/Style.dart';
// import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'package:ProductRestaurant/LoginAndReg/RegForm.dart';
// import 'package:ProductRestaurant/Modules/Responsive.dart';

class LoginScreen extends StatefulWidget {
  final String email;

  final String password;

  LoginScreen({required this.email, required this.password});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode EmailFocusNode = FocusNode();
  FocusNode PasswordFocusNode = FocusNode();
  FocusNode LoginButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.text = widget.password;
  }

  Future<void> _login() async {
    String apiUrl = '$IpAddress/Settings_Passwordalldatas/';
    String role = '';

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        bool hasNextPage = true;
        bool isValidUser = false;

        while (hasNextPage) {
          final response = await http.get(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );

          if (response.statusCode == response.statusCode) {
            final Map<String, dynamic> data = jsonDecode(response.body);
            final List<dynamic> results = data['results'];

            for (var user in results) {
              if (user['email'] == email && user['password'] == password) {
                isValidUser = true;
                String cusid = user['cusid'];
                role = user['role'];

                await saveCusId(cusid);
                await saveEmail(email);
                await saveRole(role);

                break;
              }
            }

            hasNextPage = data['next'] != null;
            if (hasNextPage) {
              apiUrl = data['next'];
            }

            if (isValidUser) {
              break;
            }
          } else {
            print('Failed to connect to the server: ${response.statusCode}');
            _showErrorDialog('Failed to connect to the server');
            return;
          }
        }

        if (isValidUser) {
          print('Login with $role successful');
          await _storeLoginState();
          await logreports("Login Form: Login");
          successfullyLoginMessage(role);
        } else {
          _showErrorDialog('Invalid email or password');
        }
      } catch (e) {
        print('An error occurred: $e');
        _showErrorDialog('An unexpected error occurred');
      }
    }
  }

  Future<bool> _isEmailAlreadyRegistered(String email) async {
    String? Url = '$IpAddress/Settings_Passwordalldatas/';
    bool hasNextPage = true;

    while (hasNextPage) {
      final response = await http.get(Uri.parse(Url!));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        for (var user in results) {
          if (user['email'] == email) {
            return true;
          }
        }

        hasNextPage = data['next'] != null;

        if (hasNextPage) {
          Url = data['next'];
        }
      } else {
        throw Exception('Failed to load data from API');
      }
    }

    return false;
  }

  Future<void> saveCusId(String cusid) async {
    await SharedPrefs.saveCusId(cusid);
  }

  Future<void> saveEmail(String email) async {
    await SharedPrefs.saveEmail(email);
  }

  Future<void> saveRole(String role) async {
    await SharedPrefs.saveRole(role);
  }

  Future<void> _storeLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  void successfullyLoginMessage(String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle_rounded, color: Colors.green),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Login with $role Successfully !!',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
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
                Icon(Icons.check_circle_rounded,
                    color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/Login.jpg'),
            fit: BoxFit.cover,
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: Responsive.isDesktop(context)
              ? EdgeInsets.only(
                  left: 440.0, right: 440.0, top: 80.0, bottom: 50.0)
              : EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to Restaurant',
                        style: HeadingStyle,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        focusNode: EmailFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, EmailFocusNode, PasswordFocusNode),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        style: commonLabelTextStyle,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: PasswordFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, PasswordFocusNode, LoginButtonFocusNode),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }

                          return null;
                        },
                        style: commonLabelTextStyle,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        focusNode: LoginButtonFocusNode,
                        onPressed: () {
                          _login();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('Login', style: commonWhiteStyle),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Navigate to register screen
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Don\'t have an account?',
                                    style: commonLabelTextStyle),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: Dialog(
                                            child: RegistrationDialog(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 30, 151, 34),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Row(
                                  children: [
                                    Text('Kindly note the email & password',
                                        style: textStyle),
                                  ],
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (_emailController.text.isEmpty) {
                                          _showErrorDialog(
                                              'Kindly enter your registered mail');
                                          return;
                                        }

                                        bool emailExists =
                                            await _isEmailAlreadyRegistered(
                                                _emailController.text);
                                        if (emailExists) {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: 500,
                                                  height: 500,
                                                  padding: EdgeInsets.all(16),
                                                  child: Stack(
                                                    children: [
                                                      ForgotPasswordEmailOTP(
                                                        email: _emailController
                                                            .text,
                                                      ),
                                                      Positioned(
                                                        right: 0.0,
                                                        top: 0.0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                              Icons.cancel,
                                                              color: Colors.red,
                                                              size: 23),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          _showErrorDialog(
                                              'Email not registered. Please enter a valid email.');
                                        }
                                      },
                                      child: Text(
                                        'Forgot Password',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordEmailOTP extends StatefulWidget {
  final String email;

  ForgotPasswordEmailOTP({required this.email});

  @override
  _ForgotPasswordEmailOTPState createState() => _ForgotPasswordEmailOTPState();
}

class _ForgotPasswordEmailOTPState extends State<ForgotPasswordEmailOTP> {
  final String apiUrl = 'https://control.msg91.com';
  final String authKey = '427100A0dJwJQnRj66b5df13P1';
  final String fromEmail = 'registration@buyptechnologies.com';
  final String emailTemplateId = 'restbuyp_forgotpassword';
  String _generatedOtp = '';
  bool _otpSent = false;
  bool _isResendAvailable = false;

  final PinTheme defaultPinTheme = PinTheme(
    width: 40,
    height: 40,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
    ),
    decoration: BoxDecoration(
      color: Colors.green.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.transparent),
    ),
  );

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String generateOtp() {
    final random = Random();
    final otp = List.generate(6, (index) => random.nextInt(10)).join();
    return otp;
  }

  Future<void> _sendEmailOtp() async {
    final otp = generateOtp();
    final url = Uri.parse('$apiUrl/api/v5/email/send');

    final headers = {
      'accept': 'application/json',
      'authkey': authKey,
      'content-type': 'application/json',
    };

    final payload = jsonEncode({
      'recipients': [
        {
          'to': [
            {'name': 'Recipient', 'email': widget.email}
          ],
          'variables': {'user_name': 'Buyp Technologies', 'otp': otp}
        }
      ],
      'from': {'name': 'Buyp Technologies', 'email': fromEmail},
      'domain': 'buyptechnologies.com',
      'template_id': emailTemplateId
    });

    try {
      final response = await http.post(url, headers: headers, body: payload);

      if (response.statusCode == 200) {
        _showSuccessOTPSendDialog('OTP send successfully to your email !!');
        setState(() {
          _generatedOtp = otp;
          _otpSent = true;
        });
      } else {
        _showWarningDialog('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      _showWarningDialog('An error occurred: $e');
    }
  }

  void _validateOtp(String enteredOtp) {
    if (enteredOtp == _generatedOtp) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              width: 500,
              height: 500,
              padding: EdgeInsets.all(16),
              child: Stack(
                children: [
                  PasswordScreen(email: widget.email),
                  Positioned(
                    right: 0.0,
                    top: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red, size: 23),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _showSuccessOTPSendDialog('OTP verified successfully!');

      _pinController.clear();
    } else {
      _showWarningDialog('Invalid OTP !!');
      _pinController.clear();
    }
  }

  void _showWarningDialog(String message) {
    showDialog(
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
                Icon(Icons.check_circle_rounded,
                    color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
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

  void _showSuccessOTPSendDialog(String message) {
    showDialog(
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
                    message,
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

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth =
                constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Fogot Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(
                  Icons.lock,
                  size: 40,
                  color: Colors.black,
                ),
                const SizedBox(height: 30),
                Text(
                  _otpSent ? 'Enter OTP' : 'Send OTP to your email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (!_otpSent) const SizedBox(height: 30),
                if (!_otpSent)
                  Container(
                    width: maxWidth,
                    child: TextField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, color: Colors.black54),
                        suffixIcon: Tooltip(
                          message: 'Send OTP',
                          child: IconButton(
                            onPressed: () {
                              _sendEmailOtp();
                            },
                            icon: Icon(Icons.send),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                if (_otpSent)
                  Column(
                    children: [
                      Pinput(
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: Colors.black),
                          ),
                        ),
                        controller: _pinController,
                        onCompleted: _validateOtp,
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          final enteredOtp = _pinController.text;
                          _validateOtp(enteredOtp);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          child: Text(
                            'Verify OTP',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          _sendEmailOtp();
                        },
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  FocusNode passwordFocus = FocusNode();
  FocusNode confirmpasswordFocus = FocusNode();
  FocusNode buttonFocus = FocusNode();

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _validatePasswords() async {
    if (_passwordController.text != _confirmpasswordController.text) {
      _showWarningDialog("Passwords do not match!");
    } else {
      try {
        final userInfo = await _fetchPasswordIdAndRoleByEmail(widget.email);

        if (userInfo != null) {
          final role = userInfo['role'];
          print('role:$role');
          if (role == 'admin') {
            await _updatePasswordTable();
            await _updateTrialUserTable();
          } else {
            await _updatePasswordTable();
          }
        } else {
          _showWarningDialog("User not found!");
        }
      } catch (e) {
        _showWarningDialog("An error occurred: $e");
        print("An error occurred: $e");
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchPasswordIdAndRoleByEmail(
      String email) async {
    String? nextUrl = '$IpAddress/Settings_Passwordalldatas/';
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl), headers: headers);
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          final List<dynamic> users = jsonResponse['results'];
          final user = users.firstWhere(
            (user) => user['email'] == email,
            orElse: () => null,
          );

          if (user != null) {
            return {
              'id': user['id'],
              'role': user['role'],
            };
          }

          nextUrl = jsonResponse['next'];
        } else {
          print("Failed to fetch user data: ${response.body}");
          return null;
        }
      }
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }

    print("User not found with the provided email.");
    return null;
  }

  Future<int?> _fetchTrialUserIdByEmail(String email) async {
    String? nextUrl = '$IpAddress/TrialUserRegistration/';
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl), headers: headers);
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          final List<dynamic> users = jsonResponse['results'];
          final user = users.firstWhere(
            (user) => user['email'] == email,
            orElse: () => null,
          );

          if (user != null) {
            return user['id'];
          }

          nextUrl = jsonResponse['next'];
        } else {
          print("Failed to fetch user data: ${response.body}");
          return null;
        }
      }
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }

    print("User not found with the provided email.");
    return null;
  }

  Future<void> _updatePasswordTable() async {
    if (_passwordController.text != _confirmpasswordController.text) {
      _showWarningDialog("Passwords do not match!");
      return;
    }

    final userInfo = await _fetchPasswordIdAndRoleByEmail(widget.email);

    if (userInfo == null) {
      _showWarningDialog("User not found!");
      return;
    }

    final userId = userInfo['id'];
    final url = Uri.parse('$IpAddress/Settings_Passwordalldatas/$userId/');
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'password': _passwordController.text,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        _showSuccessDialog("Password updated successfully!");
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(email: '', password: ''),
          ),
        );
      } else {
        _showWarningDialog("Failed to update password: ${response.body}");
        print("Failed to update password: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> _updateTrialUserTable() async {
    if (_passwordController.text != _confirmpasswordController.text) {
      _showWarningDialog("Passwords do not match!");
      return;
    }

    final userId = await _fetchTrialUserIdByEmail(widget.email);

    if (userId == null) {
      _showWarningDialog("User not found!");
      return;
    }

    final url = Uri.parse('$IpAddress/TrialUserRegistration/$userId/');
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'password': _passwordController.text,
      'cusid': userId,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("updated successfully for TrialUser!");
      } else {
        _showWarningDialog("Failed to update TrialUser: ${response.body}");
        print("Failed to update TrialUser: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth =
                constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Enter New Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: maxWidth,
                  child: TextField(
                    focusNode: passwordFocus,
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    onSubmitted: (_) => _fieldFocusChange(
                        context, passwordFocus, confirmpasswordFocus),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.black54),
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: maxWidth,
                  child: TextField(
                    focusNode: confirmpasswordFocus,
                    onSubmitted: (_) => _fieldFocusChange(
                        context, confirmpasswordFocus, buttonFocus),
                    controller: _confirmpasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.black54),
                      suffixIcon: IconButton(
                        onPressed: _toggleConfirmPasswordVisibility,
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: _validatePasswords,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Text(
                      'Update Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
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
                    message,
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

  void _showWarningDialog(String message) {
    showDialog(
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
                Icon(Icons.check_circle_rounded,
                    color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
