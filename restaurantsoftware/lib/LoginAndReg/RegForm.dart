// import 'dart:convert';
// import 'dart:math';
// import 'package:restaurantsoftware/Modules/constaints.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:restaurantsoftware/Database/IpAddress.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:crypto/crypto.dart';
// import 'package:restaurantsoftware/LoginAndReg/Login.dart';
// import 'package:restaurantsoftware/Modules/Responsive.dart';
// import 'package:restaurantsoftware/Modules/Style.dart';
// import 'package:pinput/pinput.dart';

// void main() {
//   runApp(RegistrationDialog());
// }

// bool _isEmailVerified = false;

// class RegistrationDialog extends StatefulWidget {
//   @override
//   State<RegistrationDialog> createState() => _RegistrationDialogState();
// }

// class _RegistrationDialogState extends State<RegistrationDialog> {
//   String _deviceIdentifier = '';

//   final _formKey = GlobalKey<FormState>();

//   FocusNode nameFocus = FocusNode();

//   FocusNode emailFocus = FocusNode();

//   FocusNode mobileFocus = FocusNode();

//   FocusNode businessNameFocus = FocusNode();

//   FocusNode stateFocus = FocusNode();

//   FocusNode districtFocus = FocusNode();

//   FocusNode cityFocus = FocusNode();

//   FocusNode businessGstFocus = FocusNode();

//   FocusNode affiliateFocus = FocusNode();

//   FocusNode ButtonFocus = FocusNode();

//   FocusNode passwordFocus = FocusNode();

//   TextEditingController nameController = TextEditingController();

//   TextEditingController emailController = TextEditingController();

//   TextEditingController mobileController = TextEditingController();

//   TextEditingController businessnameController = TextEditingController();

//   TextEditingController stateController = TextEditingController();

//   TextEditingController districtController = TextEditingController();

//   TextEditingController cityController = TextEditingController();

//   TextEditingController businessGstController = TextEditingController();

//   TextEditingController affiliateController = TextEditingController();

//   TextEditingController passwordController = TextEditingController();

//   @override
//   void initState() {
//     fetchStates();
//     _getDeviceIdentifier();
//     fetchLastTrialID();
//     fetchLastCusID();
//     super.initState();
//   }

//   Future<bool> _isEmailAlreadyRegistered(String email) async {
//     String? Url = '$IpAddress/TrialUserRegistration/';
//     bool hasNextPage = true;

//     while (hasNextPage) {
//       final response = await http.get(Uri.parse(Url!));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> results = data['results'];

//         for (var user in results) {
//           if (user['email'] == email) {
//             return true;
//           }
//         }

//         hasNextPage = data['next'] != null;

//         if (hasNextPage) {
//           Url = data['next'];
//         }
//       } else {
//         throw Exception('Failed to load data from API');
//       }
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth > 600) {
//           // Web view
//           return Container(
//             width: MediaQuery.of(context).size.width * 0.57,
//             child: IntrinsicHeight(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                       child: Image.asset(
//                         'assets/imgs/RiceMobile.jpg',
//                         height: 500,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Container(
//                       padding: const EdgeInsets.only(left: 30.0),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 30),
//                             const Padding(
//                               padding: EdgeInsets.only(right: 18.0),
//                               child: Center(
//                                 child: Text(
//                                   'Registration Information',
//                                   style: HeadingStyle,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 35),
//                             Row(
//                               children: [
//                                 buildTextField(
//                                   label: 'Full Name',
//                                   controller: nameController,
//                                   focusNode: nameFocus,
//                                   nextFocusNode: emailFocus,
//                                   icon: Icons.person,
//                                 ),
//                                 const SizedBox(width: 30),
//                                 Container(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Text(
//                                             'Email',
//                                             style: commonLabelTextStyle,
//                                           ),
//                                           SizedBox(
//                                             width: 4,
//                                           ),
//                                           Text(
//                                             '*',
//                                             style: TextStyle(
//                                               color: Colors.red,
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 6),
//                                       Row(
//                                         children: [
//                                           Container(
//                                             height: 25,
//                                             width: Responsive.isDesktop(context)
//                                                 ? 180
//                                                 : 220,
//                                             child: TextFormField(
//                                               onFieldSubmitted: (value) {
//                                                 _validateEmail(value);
//                                               },
//                                               controller: emailController,
//                                               focusNode: emailFocus,
//                                               validator: (value) {
//                                                 return _validateEmail(value);
//                                               },
//                                               decoration: InputDecoration(
//                                                 prefixIcon: Container(
//                                                   color: Colors.blue
//                                                       .withOpacity(0.1),
//                                                   child: Icon(Icons.email,
//                                                       color: Colors.blue,
//                                                       size: 14),
//                                                 ),
//                                                 enabledBorder:
//                                                     OutlineInputBorder(
//                                                   borderSide: BorderSide(
//                                                     color: Colors.grey.shade400,
//                                                     width: 1.0,
//                                                   ),
//                                                 ),
//                                                 focusedBorder:
//                                                     OutlineInputBorder(
//                                                   borderSide: BorderSide(
//                                                     color: Colors.grey.shade700,
//                                                     width: 1.0,
//                                                   ),
//                                                 ),
//                                                 contentPadding:
//                                                     const EdgeInsets.symmetric(
//                                                   vertical: 4.0,
//                                                   horizontal: 7.0,
//                                                 ),
//                                               ),
//                                               style: textStyle,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 3),
//                                           ElevatedButton(
//                                             onPressed: () async {
//                                               if (emailController
//                                                   .text.isNotEmpty) {
//                                                 bool emailExists =
//                                                     await _isEmailAlreadyRegistered(
//                                                         emailController.text);
//                                                 if (emailExists) {
//                                                   _showErrorDialog(
//                                                       'Email already exists. kindly use a different email.');
//                                                 } else {
//                                                   showDialog(
//                                                     barrierDismissible: false,
//                                                     context: context,
//                                                     builder:
//                                                         (BuildContext context) {
//                                                       return Dialog(
//                                                         child: Container(
//                                                           width: 500,
//                                                           height: 500,
//                                                           padding:
//                                                               EdgeInsets.all(
//                                                                   16),
//                                                           child: Stack(
//                                                             children: [
//                                                               EmailOtpPage(
//                                                                 email:
//                                                                     emailController
//                                                                         .text,
//                                                                 onOtpVerified:
//                                                                     (isVerified) {
//                                                                   setState(() {
//                                                                     _isEmailVerified =
//                                                                         isVerified;
//                                                                   });
//                                                                 },
//                                                               ),
//                                                               Positioned(
//                                                                 right: 0.0,
//                                                                 top: 0.0,
//                                                                 child:
//                                                                     IconButton(
//                                                                   icon: Icon(
//                                                                       Icons
//                                                                           .cancel,
//                                                                       color: Colors
//                                                                           .red,
//                                                                       size: 23),
//                                                                   onPressed:
//                                                                       () {
//                                                                     Navigator.of(
//                                                                             context)
//                                                                         .pop();
//                                                                   },
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   );
//                                                 }
//                                               } else {
//                                                 _showErrorDialog(
//                                                     'Kindly enter your email..!!');
//                                               }
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               foregroundColor: Colors.white,
//                                               backgroundColor: _isEmailVerified
//                                                   ? Colors.green
//                                                   : const Color.fromARGB(
//                                                       255, 177, 236, 179),
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 10),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.0),
//                                               ),
//                                             ),
//                                             child: Text(
//                                               _isEmailVerified
//                                                   ? 'Verified'
//                                                   : 'Verify',
//                                               style: TextStyle(
//                                                   color: _isEmailVerified
//                                                       ? Colors.white
//                                                       : Colors.black),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             Row(
//                               children: [
//                                 buildTextField(
//                                   label: 'Mobile No',
//                                   controller: mobileController,
//                                   focusNode: mobileFocus,
//                                   nextFocusNode: businessNameFocus,
//                                   icon: Icons.phone,
//                                   enabled: _isEmailVerified,
//                                 ),
//                                 const SizedBox(width: 30),
//                                 buildTextField(
//                                   label: 'Business Name',
//                                   controller: businessnameController,
//                                   focusNode: businessNameFocus,
//                                   nextFocusNode: stateFocus,
//                                   icon: Icons.business,
//                                   enabled: _isEmailVerified,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 Container(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Text(
//                                             'State',
//                                             style: commonLabelTextStyle,
//                                           ),
//                                           SizedBox(
//                                             width: 4,
//                                           ),
//                                           Text(
//                                             '*',
//                                             style: TextStyle(
//                                                 color: Colors.red,
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         height: 6,
//                                       ),
//                                       Row(
//                                         children: [
//                                           Container(
//                                             height: 25,
//                                             width: Responsive.isDesktop(context)
//                                                 ? 200
//                                                 : 220,
//                                             child: StatedropdownForCombo(),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 30),
//                                 Container(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Text(
//                                             'District',
//                                             style: commonLabelTextStyle,
//                                           ),
//                                           SizedBox(
//                                             width: 4,
//                                           ),
//                                           Text(
//                                             '*',
//                                             style: TextStyle(
//                                                 color: Colors.red,
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         height: 6,
//                                       ),
//                                       Row(
//                                         children: [
//                                           Container(
//                                             height: 25,
//                                             width: Responsive.isDesktop(context)
//                                                 ? 200
//                                                 : 220,
//                                             child:
//                                                 DistrictNamedropdownForCombo(),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 buildTextField(
//                                   label: 'City',
//                                   controller: cityController,
//                                   focusNode: cityFocus,
//                                   nextFocusNode: passwordFocus,
//                                   icon: Icons.area_chart_rounded,
//                                   enabled: _isEmailVerified,
//                                 ),
//                                 const SizedBox(width: 30),
//                                 buildPasswordTextField(
//                                   label: 'Password',
//                                   controller: passwordController,
//                                   focusNode: passwordFocus,
//                                   nextFocusNode: businessGstFocus,
//                                   icon: Icons.password,
//                                   enabled: _isEmailVerified,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 buildOptionalTextField(
//                                   label: 'Business Gst No',
//                                   controller: businessGstController,
//                                   focusNode: businessGstFocus,
//                                   nextFocusNode: affiliateFocus,
//                                   icon: Icons.numbers,
//                                   enabled: _isEmailVerified,
//                                 ),
//                                 const SizedBox(width: 30),
//                                 buildOptionalTextField(
//                                   label: 'Affiliate Id',
//                                   controller: affiliateController,
//                                   focusNode: affiliateFocus,
//                                   nextFocusNode: ButtonFocus,
//                                   icon: Icons.people,
//                                   enabled: _isEmailVerified,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 TextButton(
//                                   focusNode: ButtonFocus,
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                         MaterialStateProperty.all<Color>(
//                                             Colors.black),
//                                     shape: MaterialStateProperty.all<
//                                         RoundedRectangleBorder>(
//                                       RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(15.0),
//                                         side: const BorderSide(
//                                             color: Colors.black),
//                                       ),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Register();
//                                     if (_formKey.currentState!.validate()) {
//                                       String email =
//                                           emailController.text.trim();
//                                       String password =
//                                           passwordController.text.trim();

//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => LoginScreen(
//                                               email: email, password: password),
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: const Padding(
//                                     padding: EdgeInsets.only(
//                                       left: 14.0,
//                                       right: 14.0,
//                                       top: 8.0,
//                                       bottom: 8.0,
//                                     ),
//                                     child: Text('Register',
//                                         style: commonWhiteStyle),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 65.0),
//                                   child: TextButton(
//                                     style: ButtonStyle(
//                                         shape: MaterialStateProperty.all<
//                                                 RoundedRectangleBorder>(
//                                             RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15.0),
//                                                 side: const BorderSide(
//                                                     color: Colors.black)))),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: Padding(
//                                       padding: EdgeInsets.only(
//                                           left: 14.0,
//                                           right: 14.0,
//                                           top: 8.0,
//                                           bottom: 8.0),
//                                       child: Text('Quit', style: textStyle),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           // Mobile view
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 Image.asset(
//                   'assets/imgs/RiceMobile.jpg',
//                   width: double.infinity,
//                   height: 300,
//                   fit: BoxFit.cover,
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 20),
//                         const Center(
//                           child: Text('Registration Information',
//                               style: HeadingStyle),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildTextField(
//                                 label: 'Full Name',
//                                 controller: nameController,
//                                 focusNode: nameFocus,
//                                 nextFocusNode: emailFocus,
//                                 icon: Icons.person,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         'Email',
//                                         style: commonLabelTextStyle,
//                                       ),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         '*',
//                                         style: TextStyle(
//                                           color: Colors.red,
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Row(
//                                     children: [
//                                       Container(
//                                         height: 25,
//                                         width: Responsive.isDesktop(context)
//                                             ? 200
//                                             : 220,
//                                         child: TextFormField(
//                                           onFieldSubmitted: (value) {
//                                             _validateEmail(value);
//                                           },
//                                           controller: emailController,
//                                           focusNode: emailFocus,
//                                           validator: (value) {
//                                             return _validateEmail(value);
//                                           },
//                                           decoration: InputDecoration(
//                                             prefixIcon: Container(
//                                               color:
//                                                   Colors.blue.withOpacity(0.1),
//                                               child: Icon(Icons.email,
//                                                   color: Colors.blue, size: 14),
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey.shade400,
//                                                 width: 1.0,
//                                               ),
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey.shade700,
//                                                 width: 1.0,
//                                               ),
//                                             ),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                               vertical: 4.0,
//                                               horizontal: 7.0,
//                                             ),
//                                           ),
//                                           style: textStyle,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 3),
//                                       ElevatedButton(
//                                         onPressed: () async {
//                                           if (emailController.text.isNotEmpty) {
//                                             bool emailExists =
//                                                 await _isEmailAlreadyRegistered(
//                                                     emailController.text);
//                                             if (emailExists) {
//                                               _showErrorDialog(
//                                                   'Email already exists. Please use a different email.');
//                                             } else {
//                                               showDialog(
//                                                 barrierDismissible: false,
//                                                 context: context,
//                                                 builder:
//                                                     (BuildContext context) {
//                                                   return Dialog(
//                                                     child: Container(
//                                                       width: 500,
//                                                       height: 500,
//                                                       padding:
//                                                           EdgeInsets.all(16),
//                                                       child: Stack(
//                                                         children: [
//                                                           EmailOtpPage(
//                                                             email:
//                                                                 emailController
//                                                                     .text,
//                                                             onOtpVerified:
//                                                                 (isVerified) {
//                                                               setState(() {
//                                                                 _isEmailVerified =
//                                                                     isVerified;
//                                                               });
//                                                             },
//                                                           ),
//                                                           Positioned(
//                                                             right: 0.0,
//                                                             top: 0.0,
//                                                             child: IconButton(
//                                                               icon: Icon(
//                                                                   Icons.cancel,
//                                                                   color: Colors
//                                                                       .red,
//                                                                   size: 23),
//                                                               onPressed: () {
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                               },
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               );
//                                             }
//                                           } else {
//                                             _showErrorDialog(
//                                                 'Kindly enter your email..!!');
//                                           }
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           foregroundColor: Colors.white,
//                                           backgroundColor: _isEmailVerified
//                                               ? Colors.green
//                                               : const Color.fromARGB(
//                                                   255, 177, 236, 179),
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           _isEmailVerified
//                                               ? 'Verified'
//                                               : 'Verify',
//                                           style: TextStyle(
//                                               color: _isEmailVerified
//                                                   ? Colors.white
//                                                   : Colors.black),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildTextField(
//                                 label: 'Mobile No',
//                                 controller: mobileController,
//                                 focusNode: mobileFocus,
//                                 nextFocusNode: businessNameFocus,
//                                 icon: Icons.phone,
//                                 enabled: _isEmailVerified,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildTextField(
//                                 label: 'Business Name',
//                                 controller: businessnameController,
//                                 focusNode: businessNameFocus,
//                                 nextFocusNode: stateFocus,
//                                 icon: Icons.business,
//                                 enabled: _isEmailVerified,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text('State',
//                                           style: commonLabelTextStyle),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         '*',
//                                         style: TextStyle(
//                                           color: Colors.red,
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Container(
//                                     height: 25,
//                                     width: Responsive.isDesktop(context)
//                                         ? 200
//                                         : 220,
//                                     child: StatedropdownForCombo(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text('District',
//                                           style: commonLabelTextStyle),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         '*',
//                                         style: TextStyle(
//                                           color: Colors.red,
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Container(
//                                     height: 25,
//                                     width: Responsive.isDesktop(context)
//                                         ? 200
//                                         : 220,
//                                     child: DistrictNamedropdownForCombo(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildTextField(
//                                 label: 'City',
//                                 controller: cityController,
//                                 focusNode: cityFocus,
//                                 nextFocusNode: passwordFocus,
//                                 icon: Icons.area_chart_rounded,
//                                 enabled: _isEmailVerified,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildPasswordTextField(
//                                 label: 'Password',
//                                 controller: passwordController,
//                                 focusNode: passwordFocus,
//                                 nextFocusNode: businessGstFocus,
//                                 icon: Icons.password,
//                                 enabled: _isEmailVerified,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildOptionalTextField(
//                                 label: 'Business Gst No',
//                                 controller: businessGstController,
//                                 focusNode: businessGstFocus,
//                                 nextFocusNode: affiliateFocus,
//                                 icon: Icons.numbers,
//                                 enabled: _isEmailVerified,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildOptionalTextField(
//                                 label: 'Affiliate Id',
//                                 controller: affiliateController,
//                                 focusNode: affiliateFocus,
//                                 nextFocusNode: ButtonFocus,
//                                 icon: Icons.people,
//                                 enabled: _isEmailVerified,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 30),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               focusNode: ButtonFocus,
//                               style: ButtonStyle(
//                                 backgroundColor:
//                                     MaterialStateProperty.all<Color>(
//                                         Colors.black),
//                                 shape: MaterialStateProperty.all<
//                                     RoundedRectangleBorder>(
//                                   RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15.0),
//                                     side: const BorderSide(color: Colors.black),
//                                   ),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 Register();
//                                 if (_formKey.currentState!.validate()) {
//                                   String email = emailController.text.trim();
//                                   String password =
//                                       passwordController.text.trim();

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => LoginScreen(
//                                           email: email, password: password),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: const Padding(
//                                 padding: EdgeInsets.only(
//                                   left: 14.0,
//                                   right: 14.0,
//                                   top: 8.0,
//                                   bottom: 8.0,
//                                 ),
//                                 child:
//                                     Text('Register', style: commonWhiteStyle),
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             TextButton(
//                               style: ButtonStyle(
//                                 shape: MaterialStateProperty.all<
//                                     RoundedRectangleBorder>(
//                                   RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15.0),
//                                     side: const BorderSide(color: Colors.black),
//                                   ),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                   left: 14.0,
//                                   right: 14.0,
//                                   top: 8.0,
//                                   bottom: 8.0,
//                                 ),
//                                 child: Text(
//                                   'Quit',
//                                   style: textStyle,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }

//   Widget buildTextField(
//       {required String label,
//       required TextEditingController controller,
//       required FocusNode focusNode,
//       required FocusNode nextFocusNode,
//       required IconData icon,
//       final bool? enabled}) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: commonLabelTextStyle,
//               ),
//               SizedBox(
//                 width: 4,
//               ),
//               Text(
//                 '*',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 6,
//           ),
//           Row(
//             children: [
//               Container(
//                 height: 25,
//                 width: Responsive.isDesktop(context) ? 200 : 220,
//                 child: TextFormField(
//                     enabled: enabled,
//                     onFieldSubmitted: (value) {
//                       FocusScope.of(context).requestFocus(nextFocusNode);
//                     },
//                     controller: controller,
//                     focusNode: focusNode,
//                     decoration: InputDecoration(
//                       prefixIcon: Padding(
//                         padding: const EdgeInsets.only(right: 5.0),
//                         child: Container(
//                           color: Colors.blue.withOpacity(0.1),
//                           child: Icon(icon, color: Colors.blue, size: 14),
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade400,
//                           width: 1.0,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade700,
//                           width: 1.0,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0,
//                         horizontal: 7.0,
//                       ),
//                     ),
//                     style: textStyle),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildOptionalTextField(
//       {required String label,
//       required TextEditingController controller,
//       required FocusNode focusNode,
//       required FocusNode nextFocusNode,
//       required IconData icon,
//       final bool? enabled}) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: commonLabelTextStyle,
//               ),
//               SizedBox(
//                 width: 4,
//               ),
//               Text(
//                 '(optional)',
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 31, 165, 35),
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 6,
//           ),
//           Row(
//             children: [
//               Container(
//                 height: 25,
//                 width: Responsive.isDesktop(context) ? 200 : 220,
//                 child: TextFormField(
//                     onFieldSubmitted: (value) {
//                       FocusScope.of(context).requestFocus(nextFocusNode);
//                     },
//                     enabled: enabled,
//                     controller: controller,
//                     focusNode: focusNode,
//                     decoration: InputDecoration(
//                       prefixIcon: Padding(
//                         padding: const EdgeInsets.only(right: 5.0),
//                         child: Container(
//                           color: Colors.blue.withOpacity(0.1),
//                           child: Icon(icon, color: Colors.blue, size: 14),
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade400,
//                           width: 1.0,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade700,
//                           width: 1.0,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0,
//                         horizontal: 7.0,
//                       ),
//                     ),
//                     style: textStyle),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   bool _obscureText = true;

//   Widget buildPasswordTextField(
//       {required String label,
//       required TextEditingController controller,
//       required FocusNode focusNode,
//       required FocusNode nextFocusNode,
//       required IconData icon,
//       final bool? enabled}) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: commonLabelTextStyle,
//               ),
//               SizedBox(
//                 width: 4,
//               ),
//               Text(
//                 '*',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 6,
//           ),
//           Row(
//             children: [
//               Container(
//                 height: 25,
//                 width: Responsive.isDesktop(context) ? 200 : 220,
//                 child: TextFormField(
//                     onFieldSubmitted: (value) {
//                       FocusScope.of(context).requestFocus(nextFocusNode);
//                     },
//                     controller: controller,
//                     enabled: enabled,
//                     obscureText: _obscureText,
//                     decoration: InputDecoration(
//                       prefixIcon: Padding(
//                         padding: const EdgeInsets.only(right: 5.0),
//                         child: Container(
//                           color: Colors.blue.withOpacity(0.1),
//                           child: Icon(icon, color: Colors.blue, size: 14),
//                         ),
//                       ),
//                       suffixIcon: InkWell(
//                         onTap: () {
//                           setState(() {
//                             _obscureText = !_obscureText;
//                           });
//                         },
//                         child: Icon(
//                           _obscureText
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                           color: Colors.black,
//                           size: 16,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade400,
//                           width: 1.0,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade700,
//                           width: 1.0,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0,
//                         horizontal: 7.0,
//                       ),
//                     ),
//                     style: textStyle),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _fieldFocusChange(
//       BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
//     currentFocus.unfocus();
//     FocusScope.of(context).requestFocus(nextFocus);
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       _showErrorDialog('Kindly enter your email..!!');
//     } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
//         .hasMatch(value!)) {
//       _showErrorDialog('Kindly enter a valid email..!!');
//     } else if (!_isEmailVerified) {
//       _showErrorDialog('Kindly verify your email..!!');
//     } else {
//       FocusScope.of(context).requestFocus(mobileFocus);
//     }
//     return null;
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(color: Colors.yellow, width: 2),
//           ),
//           content: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               gradient: LinearGradient(
//                 colors: [Colors.yellowAccent.shade100, Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             padding: EdgeInsets.all(8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle_rounded,
//                     color: Colors.yellow, size: 24),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: TextStyle(fontSize: 13, color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );

//     Future.delayed(Duration(seconds: 1), () {
//       Navigator.of(context).pop();
//     });
//   }

//   List<String> states = [];
//   Map<String, String> stateIso2Map = {};
//   List<String> districts = [];
//   bool isLoadingDistricts = false;

//   int? _selectedStateIndex;
//   bool _StatefilterEnabled = true;
//   int? _statehoveredIndex;

//   Widget StatedropdownForCombo() {
//     return TypeAheadFormField<String>(
//       textFieldConfiguration: TextFieldConfiguration(
//         controller: stateController,
//         focusNode: stateFocus,
//         enabled: _isEmailVerified,
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: const EdgeInsets.only(right: 5.0),
//             child: Container(
//               color: Colors.blue.withOpacity(0.1),
//               child: Icon(Icons.location_city, color: Colors.blue, size: 14),
//             ),
//           ),
//           suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Colors.grey.shade400,
//               width: 1.0,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Colors.grey.shade700,
//               width: 1.0,
//             ),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 4.0,
//             horizontal: 7.0,
//           ),
//         ),
//         style: DropdownTextStyle,
//         onChanged: (text) {
//           setState(() {
//             _StatefilterEnabled = true;
//           });
//         },
//       ),
//       suggestionsCallback: (pattern) {
//         if (_StatefilterEnabled && pattern.isNotEmpty) {
//           return states.where(
//               (item) => item.toLowerCase().contains(pattern.toLowerCase()));
//         } else {
//           return states;
//         }
//       },
//       itemBuilder: (context, suggestion) {
//         final index = states.indexOf(suggestion);
//         return MouseRegion(
//           onEnter: (_) => setState(() {
//             _statehoveredIndex = index;
//           }),
//           onExit: (_) => setState(() {
//             _statehoveredIndex = null;
//           }),
//           child: Container(
//             color: _selectedStateIndex == index
//                 ? Colors.grey.withOpacity(0.3)
//                 : _selectedStateIndex == null &&
//                         states.indexOf(stateController.text) == index
//                     ? Colors.grey.withOpacity(0.1)
//                     : Colors.transparent,
//             height: 28,
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 10.0,
//               ),
//               dense: true,
//               title: Padding(
//                 padding: const EdgeInsets.only(bottom: 5.0),
//                 child: Text(
//                   suggestion,
//                   style: DropdownTextStyle,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       suggestionsBoxDecoration: const SuggestionsBoxDecoration(
//         constraints: BoxConstraints(maxHeight: 150),
//       ),
//       onSuggestionSelected: (String? suggestion) async {
//         setState(() {
//           stateController.text = suggestion!;
//           _StatefilterEnabled = false;
//           fetchDistricts(stateIso2Map[suggestion]!);
//         });
//       },
//       noItemsFoundBuilder: (context) => Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           'No Items Found!!!',
//           style: DropdownTextStyle,
//         ),
//       ),
//     );
//   }

//   int? _selectedDistrictIndex;
//   int? _DistricthoveredIndex;
//   bool _DistrictfilterEnabled = true;

//   Widget DistrictNamedropdownForCombo() {
//     return TypeAheadFormField<String>(
//       textFieldConfiguration: TextFieldConfiguration(
//         controller: districtController,
//         focusNode: districtFocus,
//         enabled: _isEmailVerified,
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: const EdgeInsets.only(right: 5.0),
//             child: Container(
//               color: Colors.blue.withOpacity(0.1),
//               child: Icon(Icons.location_on, color: Colors.blue, size: 14),
//             ),
//           ),
//           suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Colors.grey.shade400,
//               width: 1.0,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Colors.grey.shade700,
//               width: 1.0,
//             ),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 4.0,
//             horizontal: 7.0,
//           ),
//         ),
//         style: DropdownTextStyle,
//         onChanged: (text) {
//           setState(() {
//             _DistrictfilterEnabled = true;
//           });
//         },
//       ),
//       suggestionsCallback: (pattern) {
//         if (_DistrictfilterEnabled && pattern.isNotEmpty) {
//           return districts.where(
//               (item) => item.toLowerCase().contains(pattern.toLowerCase()));
//         } else {
//           return districts;
//         }
//       },
//       itemBuilder: (context, suggestion) {
//         final index = districts.indexOf(suggestion);
//         return MouseRegion(
//           onEnter: (_) => setState(() {
//             _DistricthoveredIndex = index;
//           }),
//           onExit: (_) => setState(() {
//             _DistricthoveredIndex = null;
//           }),
//           child: Container(
//             color: _selectedDistrictIndex == index
//                 ? Colors.grey.withOpacity(0.3)
//                 : _selectedDistrictIndex == null &&
//                         districts.indexOf(districtController.text) == index
//                     ? Colors.grey.withOpacity(0.1)
//                     : Colors.transparent,
//             height: 28,
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 10.0,
//               ),
//               dense: true,
//               title: Padding(
//                 padding: const EdgeInsets.only(bottom: 5.0),
//                 child: Text(
//                   suggestion,
//                   style: DropdownTextStyle,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       suggestionsBoxDecoration: const SuggestionsBoxDecoration(
//         constraints: BoxConstraints(maxHeight: 150),
//       ),
//       onSuggestionSelected: (String? suggestion) async {
//         setState(() {
//           districtController.text = suggestion!;
//           _DistrictfilterEnabled = false;
//           FocusScope.of(context).requestFocus(cityFocus);
//         });
//       },
//       noItemsFoundBuilder: (context) => Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           'No Items Found!!!',
//           style: DropdownTextStyle,
//         ),
//       ),
//     );
//   }

//   Future<void> fetchStates() async {
//     var url =
//         Uri.parse('https://api.countrystatecity.in/v1/countries/IN/states');
//     var headers = {
//       'X-CSCAPI-KEY': 'eGNkOGtuYk42RmtCdVc1bDczbzI5eE9MZGdGTk5tN2NNY1Y1MktQaQ=='
//     };

//     try {
//       var response = await http.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         List<dynamic> stateList = data;
//         List<String> stateNames =
//             stateList.map<String>((state) => state['name'].toString()).toList();

//         for (var state in stateList) {
//           stateIso2Map[state['name']] = state['iso2'];
//         }

//         setState(() {
//           states = stateNames;
//         });
//       } else {
//         print('Failed to fetch states: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error fetching states: $e');
//     }
//   }

//   Future<void> fetchDistricts(String stateCode) async {
//     setState(() {
//       isLoadingDistricts = true;
//       districts = [];
//       districtController.text = '';
//     });

//     var url = Uri.parse(
//         'https://api.countrystatecity.in/v1/countries/IN/states/$stateCode/cities');
//     var headers = {
//       'X-CSCAPI-KEY': 'eGNkOGtuYk42RmtCdVc1bDczbzI5eE9MZGdGTk5tN2NNY1Y1MktQaQ=='
//     };

//     try {
//       var response = await http.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         List<dynamic> districtList = data;
//         List<String> districtNames = districtList
//             .map<String>((district) => district['name'].toString())
//             .toList();
//         setState(() {
//           districts = districtNames;
//         });

//         FocusScope.of(context).requestFocus(districtFocus);
//       } else {
//         print('Failed to fetch districts: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error fetching districts: $e');
//     } finally {
//       setState(() {
//         isLoadingDistricts = false;
//       });
//     }
//   }

//   Future<void> _getDeviceIdentifier() async {
//     String? deviceId;

//     try {
//       if (kIsWeb) {
//         deviceId = _generateWebIdentifier();
//       } else {
//         final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//         if (Platform.isAndroid) {
//           AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
//           deviceId = androidInfo.id;
//         } else if (Platform.isIOS) {
//           IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
//           deviceId = iosInfo.identifierForVendor;
//         } else {
//           deviceId = 'Unsupported platform';
//         }
//       }

//       setState(() {
//         _deviceIdentifier = deviceId ?? 'Failed to get device ID.';
//       });
//     } catch (e) {
//       setState(() {
//         _deviceIdentifier = 'Error fetching device ID: $e';
//       });
//     }
//   }

//   String _generateWebIdentifier() {
//     var bytes = utf8.encode(DateTime.now().toString());
//     var hash = sha256.convert(bytes);
//     return hash.toString();
//   }

//   String? lastTrialID = "";

//   Future<void> fetchLastTrialID() async {
//     String apiUrl = '$IpAddress/TrialID/';
//     bool hasNextPage = true;

//     try {
//       Set<int> uniqueTrialIDs = {};

//       while (hasNextPage) {
//         http.Response response = await http.get(Uri.parse(apiUrl));

//         if (response.statusCode == 200) {
//           Map<String, dynamic> dataMap = json.decode(response.body);
//           List<dynamic> results = dataMap['results'];

//           if (results.isNotEmpty) {
//             for (var item in results) {
//               String fetchTrialID = item['trialid'];
//               int? trialID = int.tryParse(fetchTrialID);
//               if (trialID != null) {
//                 uniqueTrialIDs.add(trialID);
//               }
//             }
//           } else {
//             print('The list is empty.');
//           }

//           hasNextPage = dataMap['next'] != null;

//           if (hasNextPage) {
//             apiUrl = dataMap['next'];
//           }
//         } else {
//           print('Failed to fetch data. Status code: ${response.statusCode}');
//         }
//       }

//       if (uniqueTrialIDs.isNotEmpty) {
//         int highestTrialID = uniqueTrialIDs.reduce((a, b) => a > b ? a : b);
//         int incrementedTrialID = highestTrialID + 1;

//         setState(() {
//           lastTrialID = incrementedTrialID.toString();
//         });
//       } else {
//         setState(() {
//           lastTrialID = '0';
//         });
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   Future<void> Passwordtbl(String cusid, String email, String password) async {
//     DateTime currentDate = DateTime.now();
//     String formattedDateTime =
//         DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(currentDate.toUtc());
//     String insertUrl = '$IpAddress/Settings_Passwordalldatas/';
//     try {
//       http.Response response = await http.post(
//         Uri.parse(insertUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           "cusid": cusid,
//           "role": "admin",
//           "email": email,
//           "password": password,
//           "datetime": formattedDateTime
//         }),
//       );
//       if (response.statusCode == 201) {
//         print('Successfully Password cusid ID: $cusid');
//       } else {
//         print('Failed to insert Trial ID. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<void> insertTrialID(String trialID) async {
//     DateTime currentDate = DateTime.now();
//     String formattedDateTime =
//         DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(currentDate.toUtc());

//     String insertUrl = '$IpAddress/TrialID/';
//     try {
//       http.Response response = await http.post(
//         Uri.parse(insertUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'trialid': trialID,
//         }),
//       );
//       if (response.statusCode == 201) {
//         print('Successfully inserted Trial ID: $trialID');
//       } else {
//         print('Failed to insert Trial ID. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   String? lastCusID = "";
//   void fetchLastCusID() async {
//     String apiUrl = '$IpAddress/CustomerId/';
//     bool hasNextPage = true;

//     try {
//       while (hasNextPage) {
//         http.Response response = await http.get(Uri.parse(apiUrl));

//         if (response.statusCode == 200) {
//           Map<String, dynamic> dataMap = json.decode(response.body);
//           List<dynamic> results = dataMap['results'];

//           if (results.isNotEmpty) {
//             List<Map<String, dynamic>> cusIDMaps = results.map((item) {
//               String cusID = item['customerid'] as String;
//               int numericPart =
//                   int.tryParse(cusID.replaceFirst('BTRM_', '')) ?? 0;
//               return {'customerid': cusID, 'numericPart': numericPart};
//             }).toList();

//             cusIDMaps
//                 .sort((a, b) => a['numericPart'].compareTo(b['numericPart']));

//             List sortedCusIDs =
//                 cusIDMaps.map((item) => item['customerid']).toList();

//             String lastCusIDString = sortedCusIDs.last;

//             int lastNumber =
//                 int.tryParse(lastCusIDString.replaceFirst('BTRM_', '')) ?? 0;

//             int incrementedCusID = lastNumber + 1;

//             setState(() {
//               lastCusID = 'BTRM_$incrementedCusID';
//             });
//           } else {
//             setState(() {
//               lastCusID = 'BTRM_1';
//             });
//           }

//           hasNextPage = dataMap['next'] != null;
//           if (hasNextPage) {
//             apiUrl = dataMap['next'];
//           }
//         } else {
//           print('Failed to fetch data. Status code: ${response.statusCode}');
//         }
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   Future<void> insertCusID(String cusID) async {
//     String insertUrl = '$IpAddress/CustomerId/';
//     try {
//       http.Response response = await http.post(
//         Uri.parse(insertUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'customerid': cusID,
//         }),
//       );
//       if (response.statusCode == 201) {
//         print('Successfully inserted Customer ID: $cusID');
//       } else {
//         print(
//             'Failed to insert Customer ID. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<void> _sendWhatsAppMessage() async {
//     String name = nameController.text;
//     String phoneNumber = mobileController.text;

//     String countryCode = '91';

//     if (!phoneNumber.startsWith(countryCode)) {
//       phoneNumber = '$countryCode$phoneNumber';
//     }

//     final phoneNumberRegex = RegExp(r'^\d{10,15}$');
//     if (!phoneNumberRegex.hasMatch(phoneNumber)) {
//       _showErrorDialog(
//           "Invalid phone number format. Please include country code.");
//       return;
//     }

//     final payload = {
//       "integrated_number": "15557002820",
//       "content_type": "template",
//       "payload": {
//         "messaging_product": "whatsapp",
//         "type": "template",
//         "template": {
//           "name": "restaurant_sofware_install",
//           "language": {"code": "en", "policy": "deterministic"},
//           "namespace": null,
//           "to_and_components": [
//             {
//               "to": [phoneNumber],
//               "components": [
//                 {
//                   "type": "body",
//                   "parameters": [
//                     {"type": "text", "text": name}
//                   ]
//                 }
//               ]
//             }
//           ]
//         }
//       }
//     };

//     // Send HTTP POST request
//     final response = await http.post(
//       Uri.parse(
//           'https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'authkey': '427100AkYVnbWfrImB66b0b0eeP1',
//       },
//       body: json.encode(payload),
//     );

//     if (response.statusCode == 200) {
//       print("Notification sent successfully!");
//     } else {
//       print("Failed to send notification. Response: ${response.body}");
//     }
//   }

//   void Register() async {
//     if (nameController.text == "" ||
//         emailController.text == "" ||
//         mobileController.text == "" ||
//         businessnameController.text == "" ||
//         stateController.text == "" ||
//         districtController.text == "" ||
//         cityController.text == "") {
//       _showErrorDialog('Kindly verify your email..!!');
//       return;
//     } else {
//       String FullName = nameController.text;
//       String Email = emailController.text;
//       String businessName = businessnameController.text;
//       String MobileNo = mobileController.text;
//       String state = stateController.text;
//       String district = districtController.text;
//       String city = cityController.text;
//       String password = passwordController.text;

//       DateTime currentDate = DateTime.now();
//       String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
//       DateTime trialEndDate = currentDate.add(Duration(days: 30));
//       String formattedTrialEndDate =
//           DateFormat('yyyy-MM-dd').format(trialEndDate);

//       String status = "Active";

//       if (currentDate.isAfter(trialEndDate)) {
//         status = "Stop";
//       }
//       Map<String, dynamic> postData = {
//         "cusid": lastCusID,
//         "trialid": lastTrialID,
//         "email": Email,
//         "fullname": FullName,
//         "businessname": businessName,
//         "phoneno": MobileNo,
//         "state": state,
//         "district": district,
//         "city": city,
//         "password": password,
//         "trialstartdate": formattedDate,
//         "trialenddate": formattedTrialEndDate,
//         "software": "HotelManagement",
//         "status": status,
//         "macid": _deviceIdentifier,
//         "trialstatus": "Trial",
//         "installdate": formattedDate,
//         "closedate": formattedDate,
//       };

//       String base64Image = '';

//       if (_image != null) {
//         try {
//           Uint8List imageBytes = await _image!.readAsBytes();
//           base64Image = base64Encode(imageBytes);
//         } catch (e) {
//           print('Error encoding image: $e');
//           return;
//         }
//       }

//       String BurgerBase64Image = base64Image.isEmpty
//           ? "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"
//           : base64Image;

//       BurgerBase64Image = BurgerBase64Image.padRight(
//           (BurgerBase64Image.length + 3) ~/ 4 * 4, '=');

//       String PizzaBase64Image = base64Image.isEmpty
//           ? "/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAoGBxMTExYUFBQYGBYZGyIdGhoaGxwfIB0iIRwcIR0aHBwcHysiJBwpHR0cJDQjKC4uMTExHSI3PDcwOyswMS4BCwsLDw4PHRERHTIlISk5OTI3MTYwMDE5OTI7MzI5MzYwOTA5OzIwMjIwMDAwMDAyOTAwMDAwMDEwMDIwMDAwMP/AABEIAOUA3AMBIgACEQEDEQH/xAAbAAACAwEBAQAAAAAAAAAAAAAABgQFBwMCAf/EAD0QAAEDAgQDBgMHAwMEAwAAAAECAxEAIQQFEjEGQVETImFxgZEyQqEHFFKxwdHwI2LhFXLxM0OCkhZjov/EABoBAAIDAQEAAAAAAAAAAAAAAAAEAgMFAQb/xAAvEQACAgEEAQIEBgIDAQAAAAABAgADEQQSITFBIlETcYGRBTJhocHwI7FCYuEU/9oADAMBAAIRAxEAPwDX6KKKIQoooohCiiiiEKKKKIQoor5qFEJ9ormrEJqOrMJkJAJHI2qt7UXsya1sehJlFVSM3Vq0lEeM/oakKzARMpF+f/NVrqq2GQZI0OOxJtFQFZu2FJRIlQJ8IEc/WpSnxEi/lUxch6Mi1bDsTrRXA4oCJtO0/wANdQ4P5/ipLYrHAMiVI7nqivgNfanOQoooohCiiiiEKKKKIQoooohCiiiiEKKKKIQoorhicWlHnUXdUGWOBOgEnAnYmuD2NQm0iek/pVJmOcqSkqVATcSTB/nlSlmmdQruyZ2NiR4Xv7VmWfiXO2sfeaFOgL8scR6fzlAMCfPlPSuD+cLiUp/460irx0Oo1qCmz0PdJI5RfetDbxstBSEmCnu7elq5W11udzY+UldSlOMDMonc5g9/uzYTF/He8mumBzIJSSInmTaK6Z9khfa1ICUuC4mwPgeQJ5K96QM5xC25bXKVA6bCRbbnz63pS2q1HBJ+Ue0yVahSF4x2I443MG1KB7ROvkAR60HHxOpI0nqB6x50mM5Q1pK1PJJH4yRvBtp58udS8tZdxKCwy+FQJ+YxyMKIsCTMedQFZJyp5lzU1hc54Hv/ABL/AC/PhiFFLaCpIiTAAgmwH1pnRYADlzH+edJOQ8JYnCoXJSpZOoQTfbuzsDb8qm59xOrDNa76jYJI99+n6U2FVG6OZn2YcgJ1GLFYxMCCQeqhbyNRUcQBr/qSmFQTyI5GazN/jJb8oVCQrcJJUTPkPyqbk62k2LqlE20Eb+kdag+9W3dGXpp6yuDzNSZzpDo/pqBV+n0rsM3SLL6xPKaz/Dq7BfbGUp+YAX/4/wCbVeIUl0SF903B5VMau1eZS+iQHjqOTTgUJBkV7pZyoqaIhWpPPmf1Jq+w2K1C4j+b+X8tWjTqBYOeD7TOupKHjkSRRRRTEohRRRRCFFFFEIUUUUQhRRUTM8YG0+JsKg7hFLN0JJVLHAnPMcxCCEjc/wAv4UsYjOgFq1WgkCOduQ6zXPHOFSjCtINiZkny6VQYxCg6goAKgsKAJ3SIJ57m9eetvfUWcnC+02qNMqL7mdc0cdUdTiFpSqdKtyOfwG5tF9qpMzzBzXpabBTudUJMG0KNgAbeZqw4mxrzhLwOiBdomQALSD1PTwNVeJwzuIYS4HOz0lQKkgTYAoJ1EA7kG87erVKoDgfeXWlkq3efaXWX5OXCkgp7EJCtJJBB56YkEWESdzTJgczDOlrdskBJPy+HvWb8MZtjMM8GnjZQCgT3pHnuR+XtWgFKFSpU6FcxcpPWr3RkYMpmd8TeuGjPl2OnuLAFviGx9x9Kh5xwyw84HFoCusk+htXlI7VtKdRIRb+5UDcxtNTsI4Y0LEchefemWUOuDzFlZkbKnEVs04OQu6VFKbfLqMCLAkyBYe561Ly3BtYMC4AG/j1J6nnTMEWg0pfaFhwGSoBRMEDTAufPn+9Z/wALb1Ghez+ljxGJjHIca7UTpMxIiY5x50o8VZe2+pCnnNKfgCSZk7i3ImT7UzM4MM4dpm50IAM7kx3ifEmT61U5tkpcw8K/EFDTGoEEEEE85ppkOflK6328iV+U5jh2BoYQ22hJgqCU6lbSpSt71cMv4XEkIUUrcT3gCAFp6KSpMEelZkeDVPLWQV6ZAKgY0jnqRpvYi4tvXfMMD/pSmnWVr0W1ahzMQQYuP7R1mpqqsO+YMzA5j3nXDzjoKEuJ7JQuqYUI5GBBHjbpHOk/GZccO42hBLuqdhEQRa3gTY1oAfDuCQ6kWdCVQLRr39Tq+tUnEObstO9lOnQkAACwJAJvtqIKRJPteqLK1UkGPaGx2baOe5DwL3YoVpSQd40qPp/iavctzZRGsbjoZjaQR1m9JCu1u6rWjvd4E2vJnyCY26V6YzBaXUhYJQfn523M/MmeR9NqTC+rKmadunR+PM1XJMwU42CsQoGFAbSOafPeKswZpIy/OUqQnSob98zYAdY5eu1NGXY4LuOgJ9eYrS02qDHY3c87qtK1bFgMD29pYUUCinolCiiiiEKKKKITy4sJBJ5UjZvnSHFknUYJCYsABub9fypgz/EBctTb5v2/f/NKz7Wom3d+WJ6/EfORasb8QuLn4a9efnNXQ0hRvbv+J5Yx0rSlpsFw2BUSYnc/SvmbJUwVLWiDp3BmZFtJ23+tWGUtaXNUp06SJJEzMXi4tPvTAjDNvIKV6VgiNrXsR1251XTUWXbnmXNqRW+SMiZFjcc44b/9wABCCoQAbJi1xteal4rNAy0MOhKZF1OXnUfi09LHTO8edaG1wm0wpSmUpk3hYJt+FKtwPL1ml/M8uwz61pWgNupGooKSkwOaiLLb2mLxz5VcKWQ8wt1i2DCjiKGVPJKwopGmbkczHU7x1NPWCWhhwdo42po9FTeLCOlIbuW4hTxaA0qBKSQCUpHKItH71V4jK0sY5oNqUoAjWtSSm95kCRF7HofCr0wc8xOzjE2bAZiC6pATCYEGPYVZtpE7n9KWsic7RS31A6CAlJjkm2ojkCT7Uz4HFpUNxbY+VWUvxiUWLg8Tq4gj1pd4ozJhvQHYUC62go5jtF6Qs32HePpXvMOJkhUgBVyEQd4tf1FrVRZk6yoqW5hwVOadZJJPdOpMd7uwqDaKpZ0LZHUuSpwOe46YtsknpPSvCWO7t61TYfitLkJWIk3I29j+hpkwy0qTKTY7XmmEdHziUujL3EjiJ5xp0hKgQRq7M21AyFRF+u21qr3MydcYLKGEFKRJBElItGmfI87+G9PGOy9p4w4idMxfaY2I8hX1rK0tpCEbeO58zS+0hyVl29doBESOG8wW92TISpLTQAk7qI+HmdvWpfFvCq8R30KKD8w5EwBPnAA9Ktc+AwadSSlIN4kCT/Ol6W8q+0JeIxbWGS2o61hMgqn+5emPhSkE36VxanfOe5NNQamDIcT7lnDONlGvTpQfjXB7p5JAEmP5Ffc1yxZfW2nVpIBBURJAkSAOZOq567Vo7yeQ9ZpZOWvLxRWCOzSIkn6RzvPSqr6TWAFGTG6dc7sWbAwP79YpYfAqw+IUENnSU6lSRBiZAJ32Ft6a+G81K3Oz0kEAKNthEC/jv71b5nlbbjehQkfznS3l+NCDKRJSVJChFwLAke9/3qkjYQxkxZ/9CEY5jlhMYNamz1tP6eFTqTcTmfd7WIUjnzj+Xpswj+pPjzrR0upFgxMrU0FMH+5naiiinYrCuWKe0JKvautU3EOIhMTAG/8APOqb32VlpZUm9wIvtKK3ZUo3kmf29hFSmsMkhSpCUp+JZE+iQNzFLuDxOh3tFAqBseQsdhH83qJxPmD2ISU4dK0tIPeUkbA2JHOxNzWPp0U+o9zVvLDgdS5fxOFWiMM8CqYJUee52Fj+9Q8BxG/hyUr223H0Nx7xUTGcFsYm7LgaTAmE7nbvTz86mYfgfCMIKnl64F1LXqM+F/pT4rQeoHETLseDzGnK+IkLA1Ob/isR+lWmLwbbyDqAJKVJBgSAoQYPjWd5fw85qU8ytSW1fClZkKA5lJO31pkweN7INgpMkEBEmARyB6dK4LOMHmcNfPEsnsMjDoKygqCUCSkTsI/nSlLHlLp1qQ0CqYMEwRcJB6naRHlTYnFuqHeaOk2N+u+xBFZpjUu4B9SUK1oCrp6CZAN52iDVThgMqMCOaTYch+47ZZmraj2T6BAsDBgnoLfT/NTs+7jDpbISSkhI/uIhIHrSm3nzDoO6FJ3QZMnkEk9ZsDTU7mLQS12sawJIib6Y29frXA4C9zt9GGDqD8pnHGHEqWAlDN16QnVzsL/oPeqDLc8xSySlOpI+KI50x/aVwsS4h9pIGsjukECVEC/ITInnVzw7k7SGAlKYTPTeNz1uZ9Iq3cqoBjmLksxLExc/18IhLqIJ2kR7cqZuBM+Uhck/0VSDJ+Hfve4+tKf2m4BPaNoZSSUiVxy86jcGPrSl9CtggpCjMAkgAXHU+1GwbN69idU7n2N0ZoOd8VLWV6FKQiflsfNRiZPSa+cM5q686ELUo6ElxKlGD+GCBYi8weYqm4daac0apkKOozySSqSJ2gbwPWrrhl3U+OzHcWVEmLiQSJm4H0pEWMXG45yZqXJUlJVVxjzIvH3GjCcK/h3BqfKdKUlJIvsudoETvNqtPstyNpvDNvaQVkSVSCuSm5UoE30mAmbClbG8Fv4vM1AABCdJWtYOkCbCBuTB7sjncVq2DYbYSGm06UgW6eJjrNa1Ywonn3xkgT7ilwklXofHlUFCFC4+HkOZ8ZrtjMRKwlIlI36VUYPPUqxIZQtKklKigpk6lJA1Aq+HmLedRtG7idTgTvnGpxBQlzRbvEbxFwOnnvSIw3D3ZtlSW0/9RwJuT8osdvCnDFtvpaWlQCp7yVoBBUJkjTfvRyE0ktvuoWSygrUqNOme6esbTHXasxyynB7m3oh/jYrL9GJ7B5DSlFS1G6SPhGnnMmY5dPSW7CYoBSVTY2P89DWYcMIWnEKW+lQXJsqSbm5k7+daEnFhQ0gRUBeKrOTKtSm5RkeOTGWiomV4jW2CQQRYz4c6l1vBgygiYbDacGeH3AlJUdgJpDzvNe1XoTFwJJtFzO/hy8abOJVHsikfNY+XMeopBDWp9SU20AW9T+31rM17sXFY+c0dFWoUuZNw2SOOg6QbQJJED396vMpyBbMgqb0cgAZHmYvO9UrOLxDCwtKFKQd+Y9QPW9WzfFjR3bXHUH85vUqa0VcHuRusdjxK7MuCXFuFSVJCFH5ZkfUA/SqF/KEMulBeS4tBTOuUjqRcxsRz61oOD4hYXsr+etROIuHGcZCtWh0bKHP+1aeY+oqyykFf8Z5hTeFb/IOJQZmcUCHEQlsASLEK9jIH8io+IxAcQXZdStIPdQoKERvpMpUJgxFRcZwzmGGJDaVLb/8ArJI8uzNx6Co2UYrEjEJbU2UwkrIcBTCdlHSYPI7+fSl13q3qEaxUyEhup9yz7WlMKKMQwpaUz32/iHQKQsJExvBtemLhziDC5i4p5LBb2hToSCsiAFCJ223/ACqtzDP8tdJaQpKnp0iEXneZIum3kbRNUGLwba1spfdW22l25RCAAJgQAeYEmRvtzp3eMhSJnBDgssfs+yxKUrf0pUUJ1JKheeX1pNyZBcWLiVFUald5ZAnvEmST7crUwucSHEtuMBIAVqQhUghQHzxOqPMUvYJtxuGzIQVbpMFKhspXKx6725UhqAu7C9TZ0LOamB7/AIjhmCvvGFkgFxKbp/uHL6TSo1xEltCW9KgoWgiB5zXZx94uJLDoS4o3TaFc1FQi43IPTnVw1lWHStK8aWhq2TBSFGYuSoiOcA/SupmwDPyi1qfBbH1xFzB8HvZkvtFrLYHzAc+gv05/vU1P2dOtvJbQpS0ASVLiE9LcyYNq0nLeyQ2lLKUhsDuhMRG9ot61KChT4pXaFJmebmDlhM4zLLXmZQMOnvAp1tzed7HYnpt5U0cJZP2LKQZKyBqJ/LyE1Z5g+hESRqUQEjmSSBbymoGc5l2KfiAJi25vtalmqVH3HmMNqLLkCY/9lsC2jnHX+GoONzJMEIhRO0X9z0pTxHE4UvQpSp2gIV9SbCp+V4jXdIAH4iQSfC1hVh1C9CVHTsvJlg7lzjrSm0r0aviWUhXiUwbQdj4Un4jE4hLzbCENQhRSNDagEiUkK1dpO8mDtpB3imvHcVYdhOkqOqQmIMSdgTsK65dhm1qLiRKlmVH02qSncciQxgHM6KUUoZSSdRMT1Gkk8vCumFy5KSTAv0FR0v8Aa4iAO40NP/kYn2FveroqG5IA5zVTKrsW9pLcyjHvKPOk9i2p1KJIFz0AqkyDMgtzWvmCQBaPMeVNz2IbVKQpCgdwFJPuJpWzvB4dC4QiFQZgm3kJgCk9TWPzZ65wY7pHDKUYHJ8y74azZLrjreykq28PlV5EH6Gr6s84PdLWKCQhI1p0rM3MXCoN9j5WrQ61dI+6sRHWVfDtIlFxWowAOk/z61mmLzpTa3CmQsmAAmRAHxfz6U/cY45LbiQb6kx694ifCxrMc4db1qnVKjaDz2g+EUhcd2oM0dEuKxkR+4afW6hMqKhpkqO/lUnF8RFhCU/d9ckhSQZ6SYIkyDbyqJwGClmSCDsBfr0PWrTOmFkakWWPhJHPx8K6rlR3FrgPiEESRggy8hASjs9N2ykAATuBA2PMGvK8M+2fhC0/ib3/APXr5QKVcNxepCtD7ZQfmSbEf3J6pnoQav8AJOJWXDLT6HE84PeT4KG8+dNggjOYsQwlvl+ZpPd+bobH25VHx+TsuqUtTZ1qSU6ipW0GIg+JrnxFl/3hIKHS04nZUSD4LTzHiLj3BV8bm2Pw0h1IdgwVJJ26iaGORg8/rOIOcjiIHFeAVhsQCHipWkKUk3KFJMaSeYIghW5BvTfhcOjELw3ajukmwjco1C/oR4UrcZ543j1taEKQ+FFpSSPiBjSqRzBEcjcchWj5Bw8U/d0puUnUo8gNESfeAKjYCyjjmWKcFuZUOJYZfKOzJSk/CDpJ8JF/yq0/07753sMEJNgtK7R0NpPqJqm4ja0Yx9JPzyJvuAQR71yy7Pww6lxs3BhSeoO6T4Gx9BWWrFbCrDIzzKE1dlb5Uxky/hz7oVrUtK3lAkGDpSANiSbifK3KuDuPw2MLfbqSlSfkUNp6z4XHK9Uua5visS6FLAXh0/ClshKVeLkm0TceHS5sXuGVvMlx1aA6qSFN3SJ+ETaQBb0p0MoHp6EcJZhvc9+YwIdZw/w4lOmICVEQLk/r4VS8T/abh8IkhIW85yABCJ8Vq5eU0rYBxxkFtbiXSTYokeEaiAfafOmLLcKwq+JI/wBvIdN6BqgG2nH3xKbG06p2S397i7wZmWLxmNTisQpQBPdEEISmCYTO0kC/OnDijCPBZeaIUhcBYNwItMdOvlXzH4xnQSgJCALdV+Q6ePt4XmUPa2Uo0JgyIjl0jaKiX+K5UftI6XVFX4ESUZ0gK76QohQhSDeekEGd+oqVhcz0q/pFUKkLJTPZyk6VkDkFCr3E8Ostr1EkJmQlKUkjrCyJjz6xVplGRsIBW0CAdwbz7+dRTTsGwDNSzV07TgcmZy3wpjXICnVKEyXO0kkERIKpm2004YNXZNJYw4kxBVaB1NgBNXa8hbJNoBmYsL7+Fd8LgEtgJAAA2q5zaRtxiZ2UHI5lZg2UYZok2AuepJ/UmlzFYt3EErUuGUzKUk6txBjbTvfexuNqZOL2z2Y0mO972MT63pWzPNm8M0kKTqWPhbmBEWKyPlA5c6rcbRtzNDRpldwGWJ+0r84WjDpgrUtxUkauXw6VDyN59OVT8mxweLRcI7VSCCrrCjfpJH5mkzMMS7inCQCtRM2BIHICeSRTHw9h2H2tKSEvtx3xMG8xEi8byAZ+tRrLLwI7ddWqhT+b3/viMSspU0627qCjASqPMA38pFPDKpSD4Up4YKU1JVySfIzP+KacH8CfKnNCeWAmHrWyAW7iL9qWJ7JxpUH4CfAQd/ZRrOswSsOAG0mZkxMXJ3vPPyrWvtCfYaQh14KVBhKUxcnbe1t6zvPH0lxxG6gCQSUCxiIn5twYHKq7VxcSI7oiSgkbAZk8AEJWtSvlCSRtzsenOmrg7Nnu17F0SFgqTfVBG9+QI/SlbJcYEQggRqEqEaoIE96doHLnTJwq3qxYWlKUgBRIG4BACQbx5COvjSxGHjupINR44jbneWtOtwpCVK+UncHqDv7Uq5jwhh0AkaiQJUZJJPgP0pyx+FDo06ylX4hy8elUPFgebwwWi6m9OpWkEKAEEwfGCaaZ/SZj0rucDPcUGM4zBpwpYd7ibaXSDPT4r+31q/yLPnlynFoH9QkIUmY8UjrHiaX0cT6wQttIXEd0FJ57CYjyoY4mQkaVNyfOyfGw3sL+VVraw48TWOkR+McywyfgxxGKU42y04J1BxxagBq2VaZO5gR5inz/AFRrDIIUrWuJWrYG3LonoKUnOKB92QlJWlQA1HQYE/KVWki23j5VW4/LSArEYlSnUgSlCh/TAIsSi2tfO4gee1yWnOBz+szbtMy/mGBPnFeJTicRrbVCVIHeVYSJ2PMRA9KocblakGSQQed7+u1RmOIVYtakBlKUoBPdEQPEbV7Lyk22HQ7UvYpVjns8zItXD5HUm5PjVBXZKPcX3SCbb2VPUGIqyaW+hoYdwwNapAt5+nP1qkRhz3SoR08R4X61Mcxq1dnqJUtSNI8kkiSfKbml3BwQJP47hCgPB5n1DwSSvnNh5WH88K9HEKF1mefl5/tU7L8nDiQEvM9qTOkqmOggb+9c8VwspBKnnkgC5ABAHuTUNqgZaUgiQnceIK1FUJ3JvJ5AeJ2rlmXGmLwziP6Rb1JCk6ge8DzA6b2ricZ2jzYaQOzbJKAuwUofOq2wmyfGa0HA5a7mLSRiUobCVT3ZJMDlMFI9ad06KnY5PiO1VlVyeJw+znOHsaFPOJUQnuapiCYJhJEEDuz0nnTkrDlF028tv8VzyrLGsMgNtyECYJO0mT7mpfaDkR6G3lH6U+igdCDkkzyzjiD3tj/N67qx6B/BVfiAwnvLAEnlNz4io6nMOBKu6PFX6gwK6WxxmAXPOJPzFbK0Q4YB2vBPlSdxLwS3iFdoy4tJmVJIK0q8lKMp9z4VZrzVSD/SPd8b/wCa8P5m4tPxaV7BQJG9I2WjyuT8o3TvT8rY+spsnwgw5Wg4RRtBOtI1czYG89D49ar8nwxbzF5xCC2hwpIQdPdASE/KYuQaasZisI0ErxOJSlX9ykpk9YO9UeH4gy57EFSH1rI7oASYtzBi4q5M7TxIuyls+ZNXmgDrjKQRyTO0kSI8p+lOuX/9NH+0Ul5A6lT7xPe0FKRzuU3+ke9O2Ejs0f7RUtJXyZXqnHGIufaLlP3hpCOeqx6fwTWa8TYJ9lwANggABJUAT7+gvvWu8VWZ1nZBk+Xlz8vKkvGZhq+JtJai6fnHrzqjVMUszGtEWZMDxEXDyVAOhI6co22I5ec1o/BWUpZSVRBVvJ9gPAUtHA4Ur7Rb6ksgErSR3jp+VPifDzvTXwxnzOM7rLOnTuFkkgdSAYj1qGN2GB+kt1Ltt2848xnZZm4rs5hhFxPtH1r6EBIgewqlzvi7D4UpS6uFqmAPDe/IDqbU2tSgczMyT1POZ8IYN0d5nSZmU90+scqV+K8iw+EbR2SIK1CFfERF7KNwdqlL+1NjWUoSpwcykz9dj6V0znMGsxYbQyqDOodUkAxI6TVduzGOo5p7bEcEnI+cTUYd1wp1FQbQoFW5BmSSrxO1O3EuFLzJSq507dTHh40lKxjuHUppxBEgpcSdzPjzEbU+8O4n7xh0k/8AUR3V8jI2J8xBpZAwJH2jmsffhvEQmWlIZS0EAJFglIMarX3lSyfmPWvjbnYK04hIQOpgg/t+VX+e4n7kC6Wu0Ur4QClMKvck7QOdL2ERiMdr7YdlAJBUnUDvs4qZ2Pw9DtVpqNg3GZltaP6T9J4zPFYdIJaA2JCW1zP/AIgR7xvV9wnwdi3Qh8PNt2siVFaRJOlxBTEySd+Y33rxwrw20XG3GiQW1BSpnvTBuCPhMR6eFaK2QFBUCeosY6SOVTroUg55i7UqoxFLNsW6wNLrK3FD57IT59xRn2qqexinhqO8Tp5VpoSlwR9FCbeH8NVGY8JsqJUgAKUCCmbH05Hxqp9H5BzCsIp6inw9hWVt2RANyg2g+BG45io+e5s5rU00pSGWzB0qhSyNype4AMiB0v4MWU4FYBSptUpMQOR5T4eO1KGK1IW+CO8pZMKnYkmI9RXGOBNv8PRS5zzj+5nv78+HWj2i9KUaz3tyVKASSPi+Hny867M8Wrw6pCu7MK/z4eNVGd50hLiAlIACQCem0W6zqJ86usRg2HGg4yAsaYUB48z9ahWWwGOZPVNltpA+0m55xCt1ollpC3dAJDi9KUySCQIvEXuDcUr5NnjrjmhYJDar6bJtNkiAPhuLG8XNecVlzgQkoWSi4kRqEiIib25+FdeGcEoa3VEwJJO3WLD+XpouNmTyZnbDv46l5iM1UhWtagGzGlJ+JUwRBtyPpTFlWEbeQh0AnUkETuJG1IWDcOJIaJK1KAQkgWAkmfQQbeNajlGEDTYSNgAB4RSqlmbBjGqCKi7RzEX7RciEpUlrtT2axGnVuAAUgEEqBOoR0O1UnB2WDBpU+8kBcyhtWrUTAiE6bna8wK0/N8vQ+gpUJ6f4NKGWcJIQ6pSlGJsVX9JnlVpuKVkARWpA5yfEs+F3SAoqSNTi9ZI6kbeERFPiEwAOgApU4cw0PaRcSCfDmAfG31pvpnQsxr3HzKNWAHwJFzfD9oytETKTWN/cnUq1alaRJJF9Gmykn+0n1rbqQcxYQzinUqAAUkqT0IMFVugMz51HWLgB5foLMMVioXihS9aQW9dxNiFcwTttetEyHGsBsFstpSRvIAPiaVMVlaHGXEpTYkFMfsdjXlrLFDDKZSiFD5Z5fivSdFw5wfpHdUgZcw+0jj/sCMPh1y8sAqcTBCASfdVtthvVG1k6nxrfUpTqhGpUEgdBG252qvynJ8Q04VQFQQVJW3OxkReCKbmMwSZVCUlQI0j5SeUdQRTjWA4AMQrrPMUv/ibzK1uIxCEhJGlK4GraQCTFgbinrgbLUnW4mwK1EGCAR4TeJmomXlDzqEqCVahKoMgFNjH/ALfQU7YZIQISIFUNYXO1vE667OvMhcRcONYlISoQrYLG6f3HhSAnHP5U8vU2tTUkEwQFgEwpPIGxiTcRWqsOzJNUvEWWjFBTa1FLSSkkAAlZvCTINp0mBTBQEAicruZQVPIi0OKsG+NS8S0BPwrBQR/7b/8AFQnOIMOApnBw44oFIWAAlIPMdT504Y3gbBPNBtTACQO7HdI3uCL86zL/AOOuZZjggntGlAkLA2F7KOwV4UFNoM6rbyABL3Lc9dwTraXCFISEpJNgW1KIJJ2BSYJP9sc60fA49l5sONLS4g80qChbcAi0is2xgL6NawgJEjSokEgxIjxHWqzhTLn0uOJwq3m+9qWltfcIMwQlQKOXzXtEwbRpvU+mX36J1TfkfrNYfeTuDHmDULMMy0IKjOqLX2tvHOlzMuNUYdXZutYlKojvJSZIAkjSFWuLzVbxTnGIUgAt9m2oSNUFSvMJsBt5121sLmUUVb3Cx14YzY4hxStEBKUjX1N5B8hH1qv49yBxR+8M3UkQsDmnkrzH5R0pXyTH4lhPboIWlNloEhJG5EclX3iQR0p+4fz5t9uUTJ5Hl1E7z51Cl0sXYTzLn3aa3enX8frMfz7S3q1JlYjxKbg2HIzvzt5zSZfmuIaWSlYubo31TEzYEdQT41uOe8BsPpJACV3IVc3Jkggbp8OXKklfATzZgYd0nqktLQfUqSoDzFWomxdpGZC/UfHfeDj9IZC4XUhBAmJJnrXrH4pt5z7iy4BF3SkTb8A5T19vIf4azbQW2mG2QoXcW6mQOkImCet6reF8AjBPhDqR2uziwVEpNzqSB8Wo6TtMdKpNJAJ8+Jz43qAE0jhzJGcO3DaeV1Hc/wCPAVYOq5Ck3HcYvNpJCUoEWC41eqUkj61Z8G8QqxTOpSO9qImIBudqjjjEiyuTuaXrqkBIJqn4icZDXwEk90AePkRbmajZ+l1TqUJkGQLXEk/tJrvmmC1kIQIAFz4m0n0/OlrLMgooyeB9YxVWEIZj3zO/2d4DQ2twjc6U/wC0bfv602VEyfChplCAIgbVLrWpr21hZnXWbrC0KWPtBy9ame2aA7RsGPI/5imevLzYUkpOxEGrLEDoVPmRrcowYTOMpxp7NIkyEzf9P81OwuZgkkpIjn+cjpS9m+HcwmILagdCiezgW22PjPvVvgFKShLhbGlW0kSQet/zrzWx6bfYTeJSyvPvLdLLa++Bel7iDhkOOakEjVc3gTAE28KlZfmCVrVokBs94E7E8r8+dRuK860NhKVAlaZ7p5GQBPoZjoOtPsONw8xRKGawKJ8y5xnDSplHaKTGs7DmfM7G+1WieMJUErYAO8BZkjmUd3SojpIpGwubpZCQAXEmSsbX6dYia5v52ty5SlAKtgbpg33Em3TnNCFs8CaK6Snpx9cmbQzCkpUkylQBB623rmy6UKXYG8gc9gCaqeBMSVYBoKMqAIvyGowPaKvcOxKiqYi3v/BWgvOMTAsXazL7GdPvRKZAvFp2rN87xS3XwHJARK1pgbzHd6x48jTtxNitLUTE9P5zpG4l0toDkgkW0n5o3BNUapjjAjWh2K2WkTip0FKG0wFAa1zuTEAW5JTy8auvs2y9aErfVIDhgJvcJm59aT8vK8Q4FLTI1Am9zJvFa12UMFDZ0lIhM8qWqBU4Pcc1dy/DCIc57kXiTh1OJSgwkOIMpUpIVbmk+EVX55wkHGFEuKW6kagrYED5Up2A/Wr/AAOMUslJEkdOkSKmxTxVXWZS2NWwImWMY5ZQpBJIV3T5gHcE6gbC95q14Qy9TTIc1EEqNosLxyvXLO0MIKCogd4gyQLBUcxMnwq9y3GNONf0ZHL4goQPcTSFdTIxbE0L7kdAoHMu8DjgQJieu4PqLetWKXBz/nrtSnh8UWlnW0YN9aPzKJiesXq4wmJSRqbWCBvFo80nY1oVW7vnM568SyfWnSbA+xrNc2Sw1iXFJ0NJX+EACQACABYctqceIM1DbC1lWyZERfoJHjWI8WF8BKlFV1ElSTG/S9oFvKq7DvfbmTQbF3Ymh8aZuwlhKEpaJICkmUDlc3qL9nueoaaUl5SSVKlATeLAQfaaT/uWEewrRbH9YKhd1QomL3MCwECBvz3pt4d4e7GAbEpnyn9aovc1qcdxqmsOvJ4je5ikhPaG+5np0iu+TYYuK1HndXlyT/OlVGGClICdhPuAf1Ipuy3DaEARBNz+g9BUNCDa+89D/cq1RCLtHf8AEk0UUVsTPhRRRRCVXEmSpxLWnZYug+PTyrMmX3mHHWHlQpJsDHwxNp3vNbFSrx7wgMWjtGjpfR8Kuv8AafA0nqtKtoz5jel1JrOD1F5nDNpdKhdtwAnzixIm873qp4tyUXWgEFN7cwfA13ydbi3OyWgB1MJWkAgWHIHw2psewCez7yyR0gW8Kxs2ZP8A1/17TZFqoQQe4g5dws880FFaQmO6C38M3MEH3q/yrgxI0lxztdJ2CRA8epPmTV3leI0ylCRpmxJvPO3SpTmIDSe6ASbmr69SrY/eL3PZkgS0Yw7aEhKREADy/l/rXtpQbQoqI7yio35bD/8AIFJmbcRutoKQ2EuEKUSpQCYB3lRE2/SlHE8cOv8A9NJ0p/uMz4mLehmnvjc5UcRMaVyOY15tnqXXdxpBAKlEBAvaVG3puagcWkLLOgpUlKrqG3eTPtpANRcRgVuMASQVA3tax6Gw8qqsiexQjDuMlwBQOoGQne0ATzO9/GogfE9XmcPoOMRp4aybU6BOnTz8qecE2nUoE303/el5jBrTK2wQbmOZvtB6+lXeWPqJkoIlF5Hl+9cVPWCwkLGOOJwwGI7RCAhC0pmCVAAmLdZ5T61apOm0n9vauGFxBKykBJiIM3AI5/WpjpgTzpsLhcyknJmd5pkrWJUv7wVKShStARqBEqEmxFxEXtCq8ZLlreGKgys7zKyq8bpOq6eg6QN6lYTH6XXClJMLVEyLkmwjxPtX1WWqcQstpDjgF0hQBnkJNt+tKbmwAI2FUZJl3hXC4gFQAPgZ5+XOk9/MGl4lxSypDiFFKQlSh3UmPlIkSCTPWuXAuZYpeIdRiELQoAQggiBfabmw351xzvI1P4h5TIlSCAoA7kpBMe9x/mhvTz5jOkZATu8jiScxy99X9RpaloUJI7ix+R5+1Rsnwa1KLCgDIOkuAqvzEzbnVM3jHGVQS4hUkmCoGYN4kReKt+H84fcV39KtKSoq0jVJsElQF7Tv0qoueSY2awVPEtMp4aQ4vvqSpKT3G2yQlJF533mmfE2IbSAVK59P8VTZTigkpDYhR+MnaevnTJlOWlZ1ruOp5+Hl/wAVChjfwPfn5TOv/wAZ/vcmZdgwYVHdT8PifxeXSrKiitpVCjAmYSScmFFFFdnIUUUUQhRRRRCL/E2QdpLzMB0C/wDd/mk5GYPHuLBbg3H4oJEGa1GqLizhhGLbICi27HdcHLmAeomkdVoxaMqcGOafU7DhuRFXCugq0lRlWxF4PKY5GpodSlJ1KBVEGbH0m00oY3B47AuQ+jWnk6kTbxG/tUvC5uh3/uISvkVHukHnJvNud7VjvpHqYYHImsrraMg8ThxRnCVv9ktCVIKEjTYGZMq1RYz16C1fEowygO+lMCOzWm5MiPxJJkC9jXrPOFHVFK0qSoKG2xH02mqVWCeT3VEpjYFM/qI86Z3Zwc4MuUowCjxGzLHAFdmgns1bTHdVcymDYgj+WqavOXG1DtcPqKT8afmF7m386VQZFlzphQlJSCATzJIkx6CnLA5o12SgtIGgSb/UTyNWI+fOInq1Xd6RmRHONbEpwy1RyBv62q2y/OXHGdTjfZlRIKRc7kC/lSqnihg3UlIQQDY96TyIphwKw62kqENmSJMEieUXq5LGz6oo+nIGSMS4yhcpJnVJN4jnYDwAgehrxgc4S868lJ1IaABUNiozIHkBHvVDxHncIQxh3Egq+NQElKbTHRRn86XW84cw7elhKR2hAkyYEEdbm5I6ePK5rFUdydeid13eT1JuEU065KHVt9oZOqBJ8FGQD4SDUzhFpbIeIJUkuq7x3PjPOlfC5m0ygocbURERafKCQY86ZOE8wU4yUpkBKoTESAbkEnmD1pXKjkGO36YBDj9JKz7NFLUG2kanCI1RZAPMq5nokV7yBlbDSkuIAWdS5kSepP8Ad+9TAQdrEfMZkxM8unSorOXtuK1KcWskkKCTCR1B/Kq/iLnGcmKisBcHqL2LzlT6iRhg4nYKVaY6GIqRlmDxDuzaWkfNef0A+lOKEoslCBAskAD6VZ4HABIBUBPIch+58auTStYck4H7yD6wKNqj95V5Nw6lIBUIHTmfE/yavwIr7RWhVUlYwoxM6yxrDljCiiirZCFFFFEIUUUUQhRRRRCFFFFEJyxWGQ4kpWkEUnZvwKmdSEIcT+Ei48jTtRVdlS2DmWV2Mhypmc/eHGjo0BITZKTYjwBNuQronMmlylWkrTtMXB5z0mn3E4VDghaQrzFLua/Z/g3latBQqZJQSJ/3Ab8t6zm/Djzho6mtX/kJWpdSQVK7hB2B3rg8MO9IIBi1verN7gXUI+8rHoI/f610w/CQZAglwbrndSvxGOXhSr/h+oPORL11dI94s4fIGSvUUgpTvIG/IefpVurDoJICjMDb9PCvGaIcQqWmVBIPeEG/iK+F+FalIWEhMkgHfy3n86oCWqdjZ+fMvNyuNwMXc9f+7qB0lZuEjaCDN4mxFU/+pvqBDbZQtX4Rfx71yJHQ9acczZDsFponURdSVHzsBHuRU/CZc4lSdDBTIuSjb2ptRYRjbn7wfVAIBmJuVcNPukaypI6bG+9+nrTPk+TOYcq0aQLQDNzzM9KYm8ue6R7D9Zru1kyie+u3QVMaWxj6oq2sAGBKFph9RT2ixafgGny51a5Zky4v3Qdydz6VdYfBIRsm/U3P88q701Voa0bceTFLNU7Db0JwwuES2LC/U713oop6KwoooohCiiiiEKKKKIQoooohCiiiiEKKKKIQoooohCiiiiEKKKKIQoooohPtfKKKIQoooohCiiiiEKKKKIQoooohCiiiiEKKKKIT/9k="
//           : base64Image;

//       PizzaBase64Image = PizzaBase64Image.padRight(
//           (PizzaBase64Image.length + 3) ~/ 4 * 4, '=');

//       String AppleJuiceBase64Image = base64Image.isEmpty
//           ? "/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAoHCBYVFRgWFhYZGRgZGR0aGhoYHBwZGBkcGRwZHBoZHRocIS4lHB4rHx4cJzgmKy8xNTU1GiU7QDs0Py40NTEBDAwMEA8QHhISHzErJSs3MTY2NjQ2MTQ2NDQ1NDQ0NDQ0NDQ0ND00NjQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NP/AABEIAOEA4QMBIgACEQEDEQH/xAAcAAEAAgMBAQEAAAAAAAAAAAAABQYBAwQCBwj/xABAEAACAQIEAwUFBQYFBAMAAAABAgADEQQSITEFQVEGImFxkTKBobHBE1Jy0fAHFEJikuEVIzOismOC4vEkNML/xAAaAQEAAgMBAAAAAAAAAAAAAAAAAwQBAgUG/8QAKREAAgIBAwQBBAIDAAAAAAAAAAECAxEEEiETMUFRYRQicbGBkSMy8P/aAAwDAQACEQMRAD8A+zREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQDETyw0lDTieIpEr9ozAEr37NqDYi515dZXu1Easbk+TKRfokBw3tIrkLUARjoD/CTrzO3LeT95vXbCxZi8mDMxE4eJcTpYdc1VwoOg3JJ6ADUzdySWWDuiUqv2+S9qdB2/EwT4ANzlxpEkC4sbC43sbai/OawtjPO15wDbERJAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCImIAicFfitJDlZtfAE28yBadiuCLj4TVSTbS8GXFpZaPcpPG6IWuynZ7OBzIOh9+YH4e67Sv8AaXA/aKKqDMybga5lO9upG/rztK2rrc6+O65CKdWQqbH+xB5yc7McZYMtFzdW0QndTqcviDt4SLezryvuGPLwJ6HqfjIxmKtfZlN/Igzj1zlVNSRtg+g9o+NjDJoL1G9kch4nw+c+Y43EPVcs7FmJGp6dB0Elu0GO+3qZ+RVbDoLC49xvI4Ja5P8A6kt+olZN88Lsa4JvsVw4PXDMLhFz+GbQJ6XJHis+kyD7LcM+wogn23AZrixGndXroD6kycnV0teytJ92YMxESyBERAEREAREQBERAEREAREQBERAMRE58TikpqWchQOZ+XifAQ2EvRsdwBckADmdBKfw/iNasxp5yWIa7HupodbBRpr43035To4pjqtamGpqwW5soUs5tcAnSy9QNeRvK82CrlsxpuMwsbKFF7i5IOoJsNifdOfdd9ywnhevJepp+15az+i3Jw2moJy/aMV1IVbHyNrDU8jNOC4l9iGVlJUEZStiBmGa2p0FtZG4VqzABmYcspLWA6HkR4azWMMUZiVYqWvzJubksSd+gHSY62EnFNGel3Unk7uIcbeojoEy3IF8wJZSdRoLKSLjedXD+LqiZSCSBplAsbDffn9ZGVaWYC2YHnodef5zaymyjJcBg10BAG9+QJ8prG6zc2ZlVDakjxxDh6sc9EhSdWRjYXP8Sk7eOokFj8M1i5UjIt3PIKNmJ5ac+ltZOuRub3XqCLjw6mRvEKbPTfNXyK1N0KIqZmRr3Qlr669Oekr2VqTy+PeCOVKxlHJxHhTUFRiQysoKkaAk62110vMcFqYdXD13zZTdUUZtR/Ex2IHQXvz8btgOCUGooHAr9xRnqAMTlFhbSyjwEjsd2Cwrm6GpSPRGuv8AS4a3utJ46Jxe+OPhMqt+CawXHKFX2ai36E5T6GSc+dVOwldfYq03/HmQ25bBpc+DcONCkELs9t77A21C6XC32BvLlUrW8TX8mCTiIlgwIiIAiIgCIiAIiIAiIgCIiAIiIBiV2jiaa95mGfYk2vfmL7+plhM+U4o2r1F+7UYejGVtRb00mWdNV1G0XOvxJG0DjfzvOWvxJCbEXHLQyEpsDvPT1QNpzLNa14RfhpF8kh/iSXuEXTna8y/GfAekhwxJnQoFpW+vn4SJXpI+Wzu/xa/ITanFelhIuw5RlMkjr5ekYelj7J1OIg9Jz8Q4gllDW7zBRcXuW0A/XSRi4e8j+MYfKua57hD/ANJB+V5PHWNr/Ui+lWe5auBMRiCqmyZCSg9m4KgEDYHXlLXKL2LLHEVCSTanbXxYflL1Onp5b4JnP1Edk8GYiJOQCIiAIiIAiIgCIiAIiIAiIgCIiAIiIBifKeMrlxVYf9Qn+rvfWfVp8x7UUiMbVsN8p9UX6gyjr1/jT+S9oHixr4PFF50pQD8/cJx0KZntkdTcb/Lx0nnpts7KXpkimDt/czlx1TLoJn/EaiizKD0Iv+c5KmZrkjz8D0kbwuxmEZbsyJHAYcsl/GbDRIO2kkuH0stJB4XPmdTNlcAKdLnlbb3kbCWOl9pUle9z/JwU00kVxod0r97T+rST32oGlr6crC/vOkguNNd1AF9b6eF/7STskkzMZNy5JjsKv+ZXPRUHqX/KXSVDsIv+uf5lHoCfrLfO9pFilHK1bzc/+8GYiJZKwiIgCIiAIiIAiIgCIiAIiIAiIgCImIAlO7ZYOz06wNiStNhyYMWsT4g/OXGVjtw2WlTPSqh/3r+cg1MU63kmok1YsFUfMpO9gbECSrobA5SNBynihVRndBo9yR42N/XeWSjQDIt98ov4cr+POcFUb08HWsv2NZRW2JA1Btz5TiNZT3QDra3vlkx/Cs4tmI+6Ba3mxt+vEyNTgmU6k2UC55d0DaVp0Sj3JK9RBrLfJErWZToxHvkhSq1GUd7nvqD77GxkdivaOXa8luH1LILgetucgTa8li7G1SS5OD95cE7b+XumtEZmLXsSQAeYF4qPeb8OLlR1ZR6sJvXJuSXszNJRzgtHY/CBKLEbvVqMfcxUf7VEn5Gdnv8AQQ9S7f1Ox+slJ66tYgkvR5mxtzbfszERJDQREQBERAEREAREQBERAEREARExAETTWroouzKoGt2IA87ma6OPpOAy1EYHYqwIPkQdZq5xXkzh+jqlZ7er/wDFY9Cp9HQ/IGWNKgOxB8jeQfbRb4Vx5n0Vj8wJpbzXLHpm9XFi/JRajMmIDDqd+dwR9ZaaPFGKKSQunX9XlPxFazo2/sE+gMmrtVRVAu2umwHjcmeb6s4rETu2VxlhyJfFcYW3dcZuRJYL6Wt19ZxjiGYkFgS2mVTfU+Mw3ByosVubbg6+u0zwygitmIIOo12GvwM1lKcniXBGoVRi3Hk3rw5T3fAa8rzxieFFVurW8Nx/aSqi57p3nnE0zbbrJXTFQbwQq6W5clU/dW8514OnZ6f4x8Ln6TpoA8xPDaPTP8zH3KjmQUxXUj+S5Za3Fr4LT2a/+rQ53pqb+Yv9ZKSO7OrbC0B/0af/ABE0UOLM2NqYb7MBUpJU+0zXLFyQBly6DutrfkOunq4vhHnpLMngmomImxqZiYmYAiIgCIiAIiIAiIgGIia61QKCTsBeYbSWWZSzwcnEOILSGxZj7Kjc/kPEytY/ieIOrDKv3VNjbxYan4CSuHrqxJOrHc/TyEzi6CuNTpOVqLrrF/jXBdriq+HHL+Sn8Y4jRqUKyZRdqb688wUka+YEleFVEp4XDoB7NBAbDc5BmPredQwmGpHNkUt94gFvWYxPE6bqdRb5GU+lJRxN+ck8ISk02ngrnEcdla6syEbWJA9xUzXS7W1KtNsNXAZnVslQWGwJIYD+W9iPfITjOJUORf8AI/kZxYJv81Gv/Fb+oFfrLNTklx2OpbRVKHK5S4ZZ8NhTUZBzNJLHocoAJ98snC+EVKa3JBPUX99wRtIPhXEUpGkWHdZMpPSzd0+q/GW8cboKuUuL3tb9C0ghXB53PHc5907FhRWUbKmYLoCx52HIjpIKtmLZrWvr895NPjVBuGvcWAnFWxKkkmw/V+Wkj1G1rh9iOndF9jxw+uFYEgDXWwAv5yabE020BGx1Om29r6yk43GMGulgPUHzvNTYt8uY3GhJA1Un8J+d5pVqnGO3CaJ56Nze7OCxPiqZBCsLkaddfP8AW04+IkAAjXLRrNf8KEfWVunxG1vaNvw/K07xiy5JINjhqzeGrIn1M2py5r4FlWxF6THU6FGmGOuRQANSdANuniZVeIcY+zxL18yoKlBEVQb1CUeoQdRYLZ9/K19SInH4v7FczkM9tFJzAG27Hn+Ee+1rGk8Q4gztmLFiTc35/lLz1FljwuEaafQp5lLt+y6Vu0VYtcVCvlv/AFe0feZI4PjVU2zVSwPU/UfWfPsJirkEaeeolmwPfAPy/WokbbSw2XJVVpdl/ResJxR11vmXmDv6ydweMWoLjcbjmP7eMqGEqd2dmFrlGDLy5dRzEmpvlB8vKOVdp08uPct0TXRqhlDDYi4mydRPPKOeZiImQIiIAiIgGJAdsMZ9lhyR/EwHzP0k/Kl+0WkThQR/DUU+oYfWRXLNbRPpsdaOfaKS/G2VSQ2pH6+PynLX7SVLWzH85F1BYESLrOTp4znKLR6l9PvglK/HHubtr5zRV40dr6H6jWQOJc3mi5m3STXJBK5J4SJOtjC25nRwvEd9Pxp/yEiAbTfh6mVs3Q5vTWZ2JGN+5YPoWDoF0pqACbuve2Fnbf3NJPD8OuhOdrg62A/9yFp4nIhb7mIce4gGXyjWUoRYG+oFrG28584Zb5KkpuKTRXKNN1IyvmHRv0ZtruxvuD4yTCX9mw/l2v5dZx16DBwt73F720HgT1lWcZYJIzTfJEg3NjJqpwsmltut9vPTzkNie69t7H1k43aE/YsGQeyRofC2ot8L3mK4xecv8El8rMR2Irx4Q4OmpOp15n4SRxOECI55igq/11kJ+U10eLJpq4v4Fh8iRMcbxualXa+ipRHMbuzc7HZeksUZc+fTIrXJ4T9r9lErYwtud5FvUsdZ6pVNLGanXWdCEVHgu2Syd2Adb+Pzll4RiADb1ErGHw19ZN8P033685rNJldtNNFzpVctmG3MSVQhluOkgeH1wwtzGhkphatu70+UrNtFOef6LF2dxF1ZD/Cbjya9x6gn3yblW4AbVyOTIfW6y0zsaSe6pfBzL0lN4MxESyQiIiAYiJQO13bhqTNRw9sw0aobMAeYVdifE6b6GRzmoLLBfpE9pcL9rhqqgXOUkea94D4T4tjON4ir/qV6ja5rFzlBGxCiwBHgJL9lu2dTDORWapVot7QYlnQ/eXMfVf0YFqYyeGuDMXiSkvBF4pbSFqneWLtjhzQrso1puA9JhsUYaWPhsfK/OVOrUkXnB6KNilBSR4qC885J7NrT0dh5xk1ZodZ4VtfdPeJOszgqYYOx5FbXvzDE7G3Ibzbxkincocst71MyVPF0f+umCfjLtwKsn2KkkAtTQtqBc5VvqfH5yiYFCyP4pRPohWdOBrMt16Lb0nPs7szGO+KPoLVBlNiAOfeNyD/MP17t+MVyLXYnz1lUocWddANL7cvSd/76xNgoF+nWU57vJLGho21KeZ2bx0nPjaPdNiRpyklSUBep57zXiGGUm3vO0rqTyTplcXDsDfMSL73N5txoIw9bvaM1JLeIp1nOu/MCd9epZLAat6AAi5+IE4uKWGHe+37x8sP/AORnQ0zcpZ+CKx5wn7RSnUqdZvRMw03E6HCuLHfkfrOemhVtfWXN2V8k00SWCN+Vus7VSxvy5zRSS1jv1naBqDy6SJy5Ku7EjswNYqwN/A+IOxlgWpqD4WP0leoUxfw008JKK9r+Q+silyzSxpvJaOy12q3+7TN/MlQPkZbpX+yeFK0c53qEMPwj2fXU/wDdLBOvpYbalnzyce6W6bwZiIlkiEREA1uoIIOoIsR4GUXjf7O1e7UKn2f8jguvua91Hnml9iaShGXdA+Lr2AxwfLkSw2cOuT3A97/bILj2EehXekwAZTewsRZgGFjbUaz9Cz5p+1LgxZ6VdFJLA02AuSSt2TQeGf0ErW0JLMQj5njeIVXVEd2ZEvkU2IS9r5Ry2Gm2kisSjIbNbqCDdWB2IPSWF+DVFNnSx+6wZTbyJvab8dwuo9NEyL3b2tfNqSbEkn4W2kMZpcMs03SgseCsJWFp7bEC1pvxXZupTu1SoiKOdyzHwCgXYzRgOzuKxKu+Go1aqIbM2ULr0UZjmNraC51HWTqCl2ZO9Xwc+JxINrTo4a3dfncqfIDMD8xO/C9mmUEvcMDY3BFm6EnbXkZ4/wANdGGbW+nd2sd/fNZOONqK87XNclq4LTzUVYc6f/ByPoZhKRznxvI/h+IrUFQLqnfBBFx7Ra/UaH4c5PYPiVEotR3CM+YNTFMuVCmwJYMu+40lO2mUnmJfouUYLJw0yEa5nb++0wb6+YnunxDCuyr3SXIUXWotyTYXIUged524rEYFEtdM4tf23F+ey3AsfOVnp5yy2uxb+qgsEfUqmpbI+XwN7H0npywQgk3672nbQq4XRhWw4vrtVLe8Fd56x3EMMtF2Wuj5ACUWmwJuyroWsN2Ej+mt8R4/gz9VX7/ZEYdS2VSbkc/ObOM0x+7MGNs1V2sd2uqJp7tZFv2nAHcpeRZrf7VF/wDdNnFnd8NSezM7Gpfck2amAPgxlqmqUHl+StqbVJYiU3B4kg5Wvyt79QfK0mQwYTlHAq9QqS1MWARVd0VwBoBYasR7+QnJ+9NTYqQWtpmUEqfhLtle7mIp1a24mWLC3AH1nWhO36tOXC4HEsmYUjtcKSA5H4SdPI2PhO/B8Kx1T2MI7eOamo95ZwBKzosb7CV0M5yjfRNgNZY+zXDDiXuR/lKe+eTHcIPE8+g8xNnBOwlRsr4pwo50qep8mqfMKPfLbxGuuEoKtJVGoVF2UXuSbDfn5kyarSPO6fb0U7tQn9sO5MAWmZVGXGKq1ftGbmVspFj1XKPDblJPgfFxWBVhkqL7S3uCPvL4eHL4zoJ84KbTxkmYiJsaiIiAIiIAmJmIByY3CLVQo4uCN+YPUHkRIqn2Tww3Dt5uR/xtJ+Jo4Rk8tGckLR7K4JTcYakT1ZQ59XuZLUqSqAqqFUbBQAB5ATZMzZJLsYNGKwyVFKOAytoQec4D2cwhFv3elb8C39bXkrEw4p90Cs8Q7GYaomVVNMjYqSeVrEE7eVpXz+ziwNqgJvodRcchl2HrPo0TR1RfgkjbJLB8qP7Pa+Y3YFeWXKDfle5Onje81r2BrlrEaWNiLb8r30t77z6zE16EfbNuvL0j5tT/AGdHcty2v7J57aN8Jrxn7PGamyqxLmwu5AS2ZSToxN7Dp6T6bEfTwHXkfKsJ+yxtM9UHqBp8gfnLMnYimQoqOSF9kKMoW+p3Jv6S3xMxpijDtkysDsPhLWKsR4t9QLzTW7CYfQ0yyMOZ749Dz8by2xJNkfRpvl7KlR7HEb17/wDZb/8AUsOAwCUVsu53J3PnOyJnCMNticHFOHCuqgsVs2bQa/2khMQzBGpw21rVKmi5fa033Pjy6aTZguHrTZnuWZt2O9hy/XQTuiY2rOTOXjBmIibGBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAP/2Q=="
//           : base64Image;

//       AppleJuiceBase64Image = AppleJuiceBase64Image.padRight(
//           (AppleJuiceBase64Image.length + 3) ~/ 4 * 4, '=');

//       if (businessGstController.text.isNotEmpty) {
//         postData["businessgstno"] = businessGstController.text;
//       }

//       String jsonData = jsonEncode(postData);

//       // print('PostData:$postData');

//       String apiUrl = '$IpAddress/TrialUserRegistration/';
//       http.Response response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonData,
//       );

//       if (response.statusCode == 201) {
//         print('Data posted successfully');
//         successfullySavedMessage(context);

//         await Passwordtbl(
//           lastCusID!,
//           Email,
//           password,
//         );

//         await insertTrialID(lastTrialID!);
//         await insertCusID(lastCusID!);

//         //  Send WhatsApp message

//         _sendWhatsAppMessage();

//         // Print Setting
//         await insertPrinterSettingData(
//             "Sales", "SalesPriner", "Microsoft Print to PDF", 1, "3Inch");
//         await insertPrinterSettingData(
//             "Kitchen", "KitchenPriner", "Microsoft Print to PDF", 1, "4Inch");
//         // Point Setting
//         await insertToPointSettingData();
//         // Product Category
//         await insertProductCategory("Burger", "KitchenPrinter");
//         await insertProductCategory("Pizza", "SalesPrinter");
//         await insertProductCategory("Juice", "KitchenPrinter");
//         // Payment Type
//         await insertPaymentMethod("Cash");
//         await insertPaymentMethod("Card");
//         await insertPaymentMethod("GPay");
//         await insertPaymentMethod("Paytm");
//         await insertPaymentMethod("PhonePay");
//         await insertPaymentMethod("Credit");

//         // Gst Details
//         await insertGstDetails('Sales', 'NonGst', 'NonGst');
//         await insertGstDetails('Purchase', 'NonGst', 'NonGst');
//         await insertGstDetails('OrderSales', 'NonGst', 'NonGst');
//         await insertGstDetails('VendorSales', 'NonGst', 'NonGst');
//         // Product Details
//         await insertProductDetails(
//             'Chicken Pizza',
//             '150',
//             '150',
//             'No',
//             '50',
//             '2.5',
//             '0.0',
//             '2.5',
//             '0.0',
//             '150',
//             '1',
//             'Pizza',
//             '180',
//             '180',
//             '0',
//             'Normal',
//             PizzaBase64Image);
//         await insertProductDetails(
//             'Chicken Cheese Burger',
//             '100',
//             '100',
//             'Yes',
//             '60',
//             '9',
//             '0.0',
//             '9',
//             '0.0',
//             '100',
//             '2',
//             'Burger',
//             '120',
//             '120',
//             '0',
//             'Normal',
//             BurgerBase64Image);
//         await insertProductDetails(
//             'Apple Juice',
//             '50',
//             '50',
//             'No',
//             '20',
//             '0',
//             '0.0',
//             '0',
//             '0.0',
//             '50',
//             '3',
//             'Juice',
//             '60',
//             '60',
//             '0',
//             'Normal',
//             AppleJuiceBase64Image);

//         // Insert Product Code

//         await insertProductCode(BigInt.from(1));
//         await insertProductCode(BigInt.from(2));
//         await insertProductCode(BigInt.from(3));

//         clerFields();
//       } else {
//         print('Failed to post data: ${response.statusCode}, ${response.body}');
//       }
//     }
//   }

//   void clerFields() {
//     nameController.text = "";
//     emailController.text = "";
//     mobileController.text = "";
//     businessnameController.text = "";
//     stateController.text = "";
//     districtController.text = "";
//     cityController.text = "";
//     passwordController.text = "";
//     businessGstController.text = "";
//     affiliateController.text = "";
//   }

// // Insert to Point Setting
//   Future<void> insertToPointSettingData() async {
//     final String point = "1";
//     final String amount = "100";

//     if (point.isNotEmpty && amount.isNotEmpty) {
//       final Uri apiUrl = Uri.parse('$IpAddress/PointSettingalldatas/');

//       if (lastCusID == null) {
//         print('Customer ID is null');
//         return;
//       }

//       final Map<String, dynamic> data = {
//         "cusid": lastCusID,
//         "point": point,
//         "amount": amount,
//       };

//       try {
//         final response = await http.post(
//           apiUrl,
//           headers: {'Content-Type': 'application/json; charset=UTF-8'},
//           body: jsonEncode(data),
//         );

//         if (response.statusCode == 201) {
//           print('PointData posted successfully');
//         } else {
//           print(
//               'Failed to post PointData. Status code: ${response.statusCode}');
//         }
//       } catch (error) {
//         print('Error posting PointData: $error');
//       }
//     } else {
//       print('Point or amount is empty');
//     }
//   }

// // Insert Product Category
//   Future<void> insertProductCategory(String cat, String type) async {
//     Map<String, dynamic> postData = {
//       "cusid": lastCusID,
//       'cat': cat,
//       'type': type,
//     };

//     String apiUrl = '$IpAddress/SettingsProductCategory/';

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode(postData),
//       );

//       if (response.statusCode == 201) {
//         print('ProductCategory inserted successfully');
//       } else {
//         print(
//             'Failed to post ProductCategory. Status code: ${response.statusCode}, ${response.body}');
//       }
//     } catch (error) {
//       print('Error posting ProductCategory: $error');
//     }
//   }

// // Insert to Printer Setting
//   Future<void> insertPrinterSettingData(
//       String type, String name, String printer, int count, String size) async {
//     Map<String, dynamic> postData = {
//       "cusid": lastCusID,
//       "type": type,
//       "name": name,
//       "printer": printer,
//       "count": count,
//       "size": size,
//     };

//     String apiUrl = '$IpAddress/SettingsPrinterDetailsalldatas/';

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode(postData),
//       );

//       if (response.statusCode != 201) {
//         print(
//             'Failed to post PrinterData for $name. Status code: ${response.statusCode}, ${response.body}');
//       }
//     } catch (error) {
//       print('Error posting PrinterData for $name: $error');
//     }
//   }

// // Insert to Payment Type
//   Future<void> insertPaymentMethod(String paytype) async {
//     String apiUrl = '$IpAddress/PaymentMethodalldatas/';
//     Map<String, dynamic> postData = {
//       "cusid": lastCusID,
//       'paytype': paytype,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(postData),
//       );

//       if (response.statusCode == 201) {
//         print('PaymentData saved successfully');
//       } else {
//         print(
//             'Failed to save PaymentData. Status code: ${response.statusCode}, ${response.body}');
//       }
//     } catch (error) {
//       print('Error posting PaymentData: $error');
//     }
//   }

//   // Insert to Gst Details

//   Future<void> insertGstDetails(String name, gststatus, gst) async {
//     String apiUrl = '$IpAddress/GstDetailsalldatas/';
//     Map<String, dynamic> postData = {
//       "cusid": lastCusID,
//       'name': name,
//       'status': gststatus,
//       'gst': gst,
//     };

//     http.Response response = await http.post(
//       Uri.parse(apiUrl),
//       body: json.encode(postData),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 201) {
//       print('GstData saved successfully');
//     } else {
//       print('Failed to save data. Status code: ${response.statusCode}');
//     }
//   }

//   // Insert Product Details

//   XFile? _image;

//   Future<void> insertProductDetails(
//     String name,
//     String amount,
//     String wholeamount,
//     String stock,
//     String stockvalue,
//     String cgstper,
//     String cgstvalue,
//     String sgstper,
//     String sgstvalue,
//     String finalamount,
//     String code,
//     String category,
//     String OnlineAmt,
//     String OnlineFinalAmt,
//     String makingcost,
//     String status,
//     String image,
//   ) async {
//     Map<String, dynamic> postData = {
//       "cusid": lastCusID,
//       "name": name,
//       "amount": amount,
//       "wholeamount": wholeamount,
//       "stock": stock,
//       "stockvalue": stockvalue,
//       "cgstper": cgstper,
//       "cgstvalue": cgstvalue,
//       "sgstper": sgstper,
//       "sgstvalue": sgstvalue,
//       "finalamount": finalamount,
//       "code": code,
//       "category": category,
//       "OnlineAmt": OnlineAmt,
//       "OnlineFinalAmt": OnlineFinalAmt,
//       "makingcost": makingcost,
//       "status": status,
//       'image': image,
//     };

//     String jsonData = jsonEncode(postData);

//     String apiUrl = '$IpAddress/SettingsProductDetailsalldatas/';
//     http.Response response = await http.post(
//       Uri.parse(apiUrl),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonData,
//     );

//     if (response.statusCode == 201) {
//       print('ProductDetails posted successfully');
//     } else {
//       print(
//           'Failed to post ProductDetails data: ${response.statusCode}, ${response.body}');
//     }
//   }

//   Future<void> insertProductCode(BigInt sno) async {
//     String apiUrl = '$IpAddress/SettingsProductDetailsSNoalldatas/';
//     Map<String, dynamic> postData = {
//       "cusid": lastCusID,
//       'sno': sno.toString(),
//     };

//     try {
//       http.Response response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode(postData),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 201) {
//         print('Product Code Data saved successfully');
//       } else {
//         print('Failed to save data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
// }

// class EmailOtpPage extends StatefulWidget {
//   final String email;
//   final Function(bool) onOtpVerified;

//   EmailOtpPage({required this.email, required this.onOtpVerified});

//   @override
//   _EmailOtpPageState createState() => _EmailOtpPageState();
// }

// class _EmailOtpPageState extends State<EmailOtpPage> {
//   final String apiUrl = 'https://control.msg91.com';
//   final String authKey = '427100A0dJwJQnRj66b5df13P1';
//   final String fromEmail = 'registration@buyptechnologies.com';
//   final String emailTemplateId = 'restbuyp_otp';
//   String _generatedOtp = '';
//   bool _otpSent = false;
//   bool _isResendAvailable = false;

//   final PinTheme defaultPinTheme = PinTheme(
//     width: 40,
//     height: 40,
//     textStyle: const TextStyle(
//       fontSize: 16,
//       color: Colors.black,
//     ),
//     decoration: BoxDecoration(
//       color: Colors.green.shade100,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: Colors.transparent),
//     ),
//   );

//   final TextEditingController _pinController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();

//   String generateOtp() {
//     final random = Random();
//     final otp = List.generate(6, (index) => random.nextInt(10)).join();
//     return otp;
//   }

//   Future<void> _sendEmailOtp() async {
//     final otp = generateOtp();
//     final url = Uri.parse('$apiUrl/api/v5/email/send');

//     final headers = {
//       'accept': 'application/json',
//       'authkey': authKey,
//       'content-type': 'application/json',
//     };

//     final payload = jsonEncode({
//       'recipients': [
//         {
//           'to': [
//             {'name': 'Recipient', 'email': widget.email}
//           ],
//           'variables': {'company_name': 'Buyp Technologies', 'otp': otp}
//         }
//       ],
//       'from': {'name': 'Buyp Technologies', 'email': fromEmail},
//       'domain': 'buyptechnologies.com',
//       'template_id': emailTemplateId
//     });

//     try {
//       final response = await http.post(url, headers: headers, body: payload);

//       if (response.statusCode == 200) {
//         _showSuccessOTPSendDialog('OTP send successfully to your email !!');
//         setState(() {
//           _generatedOtp = otp;
//           _otpSent = true;
//         });
//       } else {
//         _showWarningDialog('Failed to send OTP: ${response.body}');
//       }
//     } catch (e) {
//       _showWarningDialog('An error occurred: $e');
//     }
//   }

//   void _validateOtp(String enteredOtp) {
//     if (enteredOtp == _generatedOtp) {
//       widget.onOtpVerified(true);
//       Navigator.of(context).pop();
//       _showSuccessOTPSendDialog('OTP verified successfully!');
//       _pinController.clear();
//     } else {
//       _showWarningDialog('Invalid OTP !!');
//       _pinController.clear();
//     }
//   }

//   void _showWarningDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(color: Colors.yellow, width: 2),
//           ),
//           content: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               gradient: LinearGradient(
//                 colors: [Colors.yellowAccent.shade100, Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             padding: EdgeInsets.all(8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle_rounded,
//                     color: Colors.yellow, size: 24),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: TextStyle(fontSize: 13, color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );

//     Future.delayed(Duration(seconds: 1), () {
//       Navigator.of(context).pop();
//     });
//   }

//   void _showSuccessOTPSendDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(color: Colors.green, width: 2),
//           ),
//           content: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               gradient: LinearGradient(
//                 colors: [Colors.greenAccent.shade100, Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             padding: EdgeInsets.all(8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: TextStyle(fontSize: 13, color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );

//     Future.delayed(Duration(seconds: 1), () {
//       Navigator.of(context).pop();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _emailController.text = widget.email;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             double maxWidth =
//                 constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   'OTP Verification',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 const Icon(
//                   Icons.lock,
//                   size: 40,
//                   color: Colors.black,
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   _otpSent ? 'Enter OTP' : 'Send OTP to your email',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if (!_otpSent) const SizedBox(height: 30),
//                 if (!_otpSent)
//                   Container(
//                     width: maxWidth,
//                     child: TextField(
//                       controller: _emailController,
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.email, color: Colors.black54),
//                         suffixIcon: Tooltip(
//                           message: 'Send OTP',
//                           child: IconButton(
//                             onPressed: () {
//                               _sendEmailOtp();
//                             },
//                             icon: Icon(Icons.send),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 30),
//                 if (_otpSent)
//                   Column(
//                     children: [
//                       Pinput(
//                         length: 6,
//                         defaultPinTheme: defaultPinTheme,
//                         focusedPinTheme: defaultPinTheme.copyWith(
//                           decoration: defaultPinTheme.decoration!.copyWith(
//                             border: Border.all(color: Colors.black),
//                           ),
//                         ),
//                         controller: _pinController,
//                         onCompleted: _validateOtp,
//                       ),
//                       const SizedBox(height: 30),
//                       TextButton(
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateProperty.all<Color>(Colors.green),
//                           shape:
//                               MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                         ),
//                         onPressed: () {
//                           final enteredOtp = _pinController.text;
//                           _validateOtp(enteredOtp);
//                         },
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                             left: 10.0,
//                             right: 10.0,
//                             top: 6.0,
//                             bottom: 6.0,
//                           ),
//                           child: Text(
//                             'Verify OTP',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       InkWell(
//                         onTap: () {
//                           _sendEmailOtp();
//                         },
//                         child: Text(
//                           'Resend OTP',
//                           style: TextStyle(
//                             decoration: TextDecoration.underline,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:restaurantsoftware/Database/IpAddress.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';
import 'package:restaurantsoftware/LoginAndReg/Login.dart';
import 'package:restaurantsoftware/Modules/Responsive.dart';
import 'package:restaurantsoftware/Modules/Style.dart';

void main() {
  runApp(RegistrationDialog());
}

class RegistrationDialog extends StatefulWidget {
  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  String _deviceIdentifier = '';

  final _formKey = GlobalKey<FormState>();

  FocusNode nameFocus = FocusNode();

  FocusNode emailFocus = FocusNode();

  FocusNode mobileFocus = FocusNode();

  FocusNode businessNameFocus = FocusNode();

  FocusNode stateFocus = FocusNode();

  FocusNode districtFocus = FocusNode();

  FocusNode cityFocus = FocusNode();

  FocusNode businessGstFocus = FocusNode();

  FocusNode affiliateFocus = FocusNode();

  FocusNode ButtonFocus = FocusNode();

  FocusNode passwordFocus = FocusNode();

  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController mobileController = TextEditingController();

  TextEditingController businessnameController = TextEditingController();

  TextEditingController stateController = TextEditingController();

  TextEditingController districtController = TextEditingController();

  TextEditingController cityController = TextEditingController();

  TextEditingController businessGstController = TextEditingController();

  TextEditingController affiliateController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    fetchStates();
    _getDeviceIdentifier();
    fetchLastTrialID();
    fetchLastCusID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Web view
          return Container(
            width: MediaQuery.of(context).size.width * 0.54,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Image.asset(
                        'assets/imgs/RiceMobile.jpg',
                        height: 500,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            const Padding(
                              padding: EdgeInsets.only(right: 18.0),
                              child: Center(
                                child: Text(
                                  'Registration Information',
                                  style: HeadingStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                            Row(
                              children: [
                                buildTextField(
                                  label: 'Full Name',
                                  controller: nameController,
                                  focusNode: nameFocus,
                                  nextFocusNode: emailFocus,
                                  icon: Icons.person,
                                ),
                                const SizedBox(width: 30),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Email',
                                            style: commonLabelTextStyle,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: Responsive.isDesktop(context)
                                                ? 200
                                                : 220,
                                            child: TextFormField(
                                                onFieldSubmitted: (value) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          mobileFocus);
                                                },
                                                controller: emailController,
                                                focusNode: emailFocus,
                                                validator: (value) {
                                                  return _validateEmail(value);
                                                },
                                                decoration: InputDecoration(
                                                  prefixIcon: Container(
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                    child: Icon(Icons.email,
                                                        color: Colors.blue,
                                                        size: 14),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade700,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 7.0,
                                                  ),
                                                ),
                                                style: textStyle),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                buildTextField(
                                  label: 'Mobile No',
                                  controller: mobileController,
                                  focusNode: mobileFocus,
                                  nextFocusNode: businessNameFocus,
                                  icon: Icons.phone,
                                ),
                                const SizedBox(width: 30),
                                buildTextField(
                                  label: 'Business Name',
                                  controller: businessnameController,
                                  focusNode: businessNameFocus,
                                  nextFocusNode: stateFocus,
                                  icon: Icons.business,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'State',
                                            style: commonLabelTextStyle,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: Responsive.isDesktop(context)
                                                ? 200
                                                : 220,
                                            child: StatedropdownForCombo(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'District',
                                            style: commonLabelTextStyle,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: Responsive.isDesktop(context)
                                                ? 200
                                                : 220,
                                            child:
                                                DistrictNamedropdownForCombo(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                buildTextField(
                                  label: 'City',
                                  controller: cityController,
                                  focusNode: cityFocus,
                                  nextFocusNode: passwordFocus,
                                  icon: Icons.area_chart_rounded,
                                ),
                                const SizedBox(width: 30),
                                buildPasswordTextField(
                                  label: 'Password',
                                  controller: passwordController,
                                  focusNode: passwordFocus,
                                  nextFocusNode: businessGstFocus,
                                  icon: Icons.password,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                buildOptionalTextField(
                                  label: 'Business Gst No',
                                  controller: businessGstController,
                                  focusNode: businessGstFocus,
                                  nextFocusNode: affiliateFocus,
                                  icon: Icons.numbers,
                                ),
                                const SizedBox(width: 30),
                                buildOptionalTextField(
                                  label: 'Affiliate Id',
                                  controller: affiliateController,
                                  focusNode: affiliateFocus,
                                  nextFocusNode: ButtonFocus,
                                  icon: Icons.people,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  focusNode: ButtonFocus,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: const BorderSide(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Register();
                                    if (_formKey.currentState!.validate()) {
                                      String email =
                                          emailController.text.trim();
                                      String password =
                                          passwordController.text.trim();

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(
                                              email: email, password: password),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 14.0,
                                      right: 14.0,
                                      top: 8.0,
                                      bottom: 8.0,
                                    ),
                                    child: Text('Register',
                                        style: commonWhiteStyle),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(right: 65.0),
                                  child: TextButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                side: const BorderSide(
                                                    color: Colors.black)))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 14.0,
                                          right: 14.0,
                                          top: 8.0,
                                          bottom: 8.0),
                                      child: Text('Quit', style: textStyle),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Mobile view
          return SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/imgs/RiceMobile.jpg',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Center(
                          child: Text('Registration Information',
                              style: HeadingStyle),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                label: 'Full Name',
                                controller: nameController,
                                focusNode: nameFocus,
                                nextFocusNode: emailFocus,
                                icon: Icons.person,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Email',
                                        style: commonLabelTextStyle,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 25,
                                    width: Responsive.isDesktop(context)
                                        ? 200
                                        : 220,
                                    child: TextFormField(
                                      onFieldSubmitted: (value) {
                                        FocusScope.of(context)
                                            .requestFocus(mobileFocus);
                                      },
                                      controller: emailController,
                                      focusNode: emailFocus,
                                      validator: (value) {
                                        return _validateEmail(value);
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Container(
                                          color: Colors.blue.withOpacity(0.1),
                                          child: Icon(Icons.email,
                                              color: Colors.blue, size: 14),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade700,
                                            width: 1.0,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 7.0,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                label: 'Mobile No',
                                controller: mobileController,
                                focusNode: mobileFocus,
                                nextFocusNode: businessNameFocus,
                                icon: Icons.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                label: 'Business Name',
                                controller: businessnameController,
                                focusNode: businessNameFocus,
                                nextFocusNode: stateFocus,
                                icon: Icons.business,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('State',
                                          style: commonLabelTextStyle),
                                      SizedBox(width: 4),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 25,
                                    width: Responsive.isDesktop(context)
                                        ? 200
                                        : 220,
                                    child: StatedropdownForCombo(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('District',
                                          style: commonLabelTextStyle),
                                      SizedBox(width: 4),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 25,
                                    width: Responsive.isDesktop(context)
                                        ? 200
                                        : 220,
                                    child: DistrictNamedropdownForCombo(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                label: 'City',
                                controller: cityController,
                                focusNode: cityFocus,
                                nextFocusNode: passwordFocus,
                                icon: Icons.area_chart_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildPasswordTextField(
                                label: 'Password',
                                controller: passwordController,
                                focusNode: passwordFocus,
                                nextFocusNode: businessGstFocus,
                                icon: Icons.password,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildOptionalTextField(
                                label: 'Business Gst No',
                                controller: businessGstController,
                                focusNode: businessGstFocus,
                                nextFocusNode: affiliateFocus,
                                icon: Icons.numbers,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildOptionalTextField(
                                label: 'Affiliate Id',
                                controller: affiliateController,
                                focusNode: affiliateFocus,
                                nextFocusNode: ButtonFocus,
                                icon: Icons.people,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              focusNode: ButtonFocus,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Register();
                                if (_formKey.currentState!.validate()) {
                                  String email = emailController.text.trim();
                                  String password =
                                      passwordController.text.trim();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(
                                          email: email, password: password),
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  left: 14.0,
                                  right: 14.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                child:
                                    Text('Register', style: commonWhiteStyle),
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 14.0,
                                  right: 14.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                child: Text(
                                  'Quit',
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required IconData icon,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: commonLabelTextStyle,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              Container(
                height: 25,
                width: Responsive.isDesktop(context) ? 200 : 220,
                child: TextFormField(
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    },
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Container(
                          color: Colors.blue.withOpacity(0.1),
                          child: Icon(icon, color: Colors.blue, size: 14),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 7.0,
                      ),
                    ),
                    style: textStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOptionalTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required IconData icon,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: commonLabelTextStyle,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '(optional)',
                style: TextStyle(
                  color: Color.fromARGB(255, 31, 165, 35),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              Container(
                height: 25,
                width: Responsive.isDesktop(context) ? 200 : 220,
                child: TextFormField(
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    },
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Container(
                          color: Colors.blue.withOpacity(0.1),
                          child: Icon(icon, color: Colors.blue, size: 14),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 7.0,
                      ),
                    ),
                    style: textStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _obscureText = true;

  Widget buildPasswordTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required IconData icon,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: commonLabelTextStyle,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              Container(
                height: 25,
                width: Responsive.isDesktop(context) ? 200 : 220,
                child: TextFormField(
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    },
                    controller: controller,
                    focusNode: focusNode,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Container(
                          color: Colors.blue.withOpacity(0.1),
                          child: Icon(icon, color: Colors.blue, size: 14),
                        ),
                      ),
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
                          size: 16,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 7.0,
                      ),
                    ),
                    style: textStyle),
              ),
            ],
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

  void showEmptyWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 252, 248, 248),
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kindly check your details..!!',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      showEmptyWarning();
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        .hasMatch(value!)) {
      _showErrorDialog(context);
    }
    return null;
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 252, 248, 248),
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kindly enter a valid email..!!',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  List<String> states = [];
  Map<String, String> stateIso2Map = {};
  List<String> districts = [];
  bool isLoadingDistricts = false;

  int? _selectedStateIndex;
  bool _StatefilterEnabled = true;
  int? _statehoveredIndex;

  Widget StatedropdownForCombo() {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: stateController,
        focusNode: stateFocus,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Container(
              color: Colors.blue.withOpacity(0.1),
              child: Icon(Icons.location_city, color: Colors.blue, size: 14),
            ),
          ),
          suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade700,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 7.0,
          ),
        ),
        style: DropdownTextStyle,
        onChanged: (text) {
          setState(() {
            _StatefilterEnabled = true;
          });
        },
      ),
      suggestionsCallback: (pattern) {
        if (_StatefilterEnabled && pattern.isNotEmpty) {
          return states.where(
              (item) => item.toLowerCase().contains(pattern.toLowerCase()));
        } else {
          return states;
        }
      },
      itemBuilder: (context, suggestion) {
        final index = states.indexOf(suggestion);
        return MouseRegion(
          onEnter: (_) => setState(() {
            _statehoveredIndex = index;
          }),
          onExit: (_) => setState(() {
            _statehoveredIndex = null;
          }),
          child: Container(
            color: _selectedStateIndex == index
                ? Colors.grey.withOpacity(0.3)
                : _selectedStateIndex == null &&
                        states.indexOf(stateController.text) == index
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
      onSuggestionSelected: (String? suggestion) async {
        setState(() {
          stateController.text = suggestion!;
          _StatefilterEnabled = false;
          fetchDistricts(stateIso2Map[suggestion]!);
        });
      },
      noItemsFoundBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No Items Found!!!',
          style: DropdownTextStyle,
        ),
      ),
    );
  }

  int? _selectedDistrictIndex;
  int? _DistricthoveredIndex;
  bool _DistrictfilterEnabled = true;

  Widget DistrictNamedropdownForCombo() {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: districtController,
        focusNode: districtFocus,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Container(
              color: Colors.blue.withOpacity(0.1),
              child: Icon(Icons.location_on, color: Colors.blue, size: 14),
            ),
          ),
          suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade700,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 7.0,
          ),
        ),
        style: DropdownTextStyle,
        onChanged: (text) {
          setState(() {
            _DistrictfilterEnabled = true;
          });
        },
      ),
      suggestionsCallback: (pattern) {
        if (_DistrictfilterEnabled && pattern.isNotEmpty) {
          return districts.where(
              (item) => item.toLowerCase().contains(pattern.toLowerCase()));
        } else {
          return districts;
        }
      },
      itemBuilder: (context, suggestion) {
        final index = districts.indexOf(suggestion);
        return MouseRegion(
          onEnter: (_) => setState(() {
            _DistricthoveredIndex = index;
          }),
          onExit: (_) => setState(() {
            _DistricthoveredIndex = null;
          }),
          child: Container(
            color: _selectedDistrictIndex == index
                ? Colors.grey.withOpacity(0.3)
                : _selectedDistrictIndex == null &&
                        districts.indexOf(districtController.text) == index
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
      onSuggestionSelected: (String? suggestion) async {
        setState(() {
          districtController.text = suggestion!;
          _DistrictfilterEnabled = false;
          FocusScope.of(context).requestFocus(cityFocus);
        });
      },
      noItemsFoundBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No Items Found!!!',
          style: DropdownTextStyle,
        ),
      ),
    );
  }

  Future<void> fetchStates() async {
    var url =
        Uri.parse('https://api.countrystatecity.in/v1/countries/IN/states');
    var headers = {
      'X-CSCAPI-KEY': 'eGNkOGtuYk42RmtCdVc1bDczbzI5eE9MZGdGTk5tN2NNY1Y1MktQaQ=='
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> stateList = data;
        List<String> stateNames =
            stateList.map<String>((state) => state['name'].toString()).toList();

        for (var state in stateList) {
          stateIso2Map[state['name']] = state['iso2'];
        }

        setState(() {
          states = stateNames;
        });
      } else {
        print('Failed to fetch states: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> fetchDistricts(String stateCode) async {
    setState(() {
      isLoadingDistricts = true;
      districts = [];
      districtController.text = '';
    });

    var url = Uri.parse(
        'https://api.countrystatecity.in/v1/countries/IN/states/$stateCode/cities');
    var headers = {
      'X-CSCAPI-KEY': 'eGNkOGtuYk42RmtCdVc1bDczbzI5eE9MZGdGTk5tN2NNY1Y1MktQaQ=='
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> districtList = data;
        List<String> districtNames = districtList
            .map<String>((district) => district['name'].toString())
            .toList();
        setState(() {
          districts = districtNames;
        });

        FocusScope.of(context).requestFocus(districtFocus);
      } else {
        print('Failed to fetch districts: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching districts: $e');
    } finally {
      setState(() {
        isLoadingDistricts = false;
      });
    }
  }

  Future<void> _getDeviceIdentifier() async {
    String? deviceId;

    try {
      if (kIsWeb) {
        deviceId = _generateWebIdentifier();
      } else {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          deviceId = iosInfo.identifierForVendor;
        } else {
          deviceId = 'Unsupported platform';
        }
      }

      setState(() {
        _deviceIdentifier = deviceId ?? 'Failed to get device ID.';
      });
    } catch (e) {
      setState(() {
        _deviceIdentifier = 'Error fetching device ID: $e';
      });
    }
  }

  String _generateWebIdentifier() {
    var bytes = utf8.encode(DateTime.now().toString());
    var hash = sha256.convert(bytes);
    return hash.toString();
  }

  String? lastTrialID = "";

  Future<void> fetchLastTrialID() async {
    String apiUrl = '$IpAddress/TrialID/';
    bool hasNextPage = true;

    try {
      Set<int> uniqueTrialIDs = {};

      while (hasNextPage) {
        http.Response response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          Map<String, dynamic> dataMap = json.decode(response.body);
          List<dynamic> results = dataMap['results'];

          if (results.isNotEmpty) {
            for (var item in results) {
              String fetchTrialID = item['trialid'];
              int? trialID = int.tryParse(fetchTrialID);
              if (trialID != null) {
                uniqueTrialIDs.add(trialID);
              }
            }
          } else {
            print('The list is empty.');
          }

          hasNextPage = dataMap['next'] != null;

          if (hasNextPage) {
            apiUrl = dataMap['next'];
          }
        } else {
          print('Failed to fetch data. Status code: ${response.statusCode}');
        }
      }

      if (uniqueTrialIDs.isNotEmpty) {
        int highestTrialID = uniqueTrialIDs.reduce((a, b) => a > b ? a : b);
        int incrementedTrialID = highestTrialID + 1;

        setState(() {
          lastTrialID = incrementedTrialID.toString();
        });
      } else {
        setState(() {
          lastTrialID = '0';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> Passwordtbl(String cusid, String email, String password) async {
    DateTime currentDate = DateTime.now();
    String formattedDateTime =
        DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(currentDate.toUtc());
    String insertUrl = '$IpAddress/Settings_Passwordalldatas/';
    try {
      http.Response response = await http.post(
        Uri.parse(insertUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "cusid": cusid,
          "role": "admin",
          "email": email,
          "password": password,
          "datetime": formattedDateTime
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

  Future<void> insertTrialID(String trialID) async {
    DateTime currentDate = DateTime.now();
    String formattedDateTime =
        DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(currentDate.toUtc());

    String insertUrl = '$IpAddress/TrialID/';
    try {
      http.Response response = await http.post(
        Uri.parse(insertUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'trialid': trialID,
        }),
      );
      if (response.statusCode == 201) {
        print('Successfully inserted Trial ID: $trialID');
      } else {
        print('Failed to insert Trial ID. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String? lastCusID = "";
  void fetchLastCusID() async {
    String apiUrl = '$IpAddress/CustomerId/';
    bool hasNextPage = true;

    try {
      while (hasNextPage) {
        http.Response response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          Map<String, dynamic> dataMap = json.decode(response.body);
          List<dynamic> results = dataMap['results'];

          if (results.isNotEmpty) {
            List<Map<String, dynamic>> cusIDMaps = results.map((item) {
              String cusID = item['customerid'] as String;
              int numericPart =
                  int.tryParse(cusID.replaceFirst('BTRM_', '')) ?? 0;
              return {'customerid': cusID, 'numericPart': numericPart};
            }).toList();

            cusIDMaps
                .sort((a, b) => a['numericPart'].compareTo(b['numericPart']));

            List sortedCusIDs =
                cusIDMaps.map((item) => item['customerid']).toList();

            String lastCusIDString = sortedCusIDs.last;

            int lastNumber =
                int.tryParse(lastCusIDString.replaceFirst('BTRM_', '')) ?? 0;

            int incrementedCusID = lastNumber + 1;

            setState(() {
              lastCusID = 'BTRM_$incrementedCusID';
            });
          } else {
            setState(() {
              lastCusID = 'BTRM_1';
            });
          }

          hasNextPage = dataMap['next'] != null;
          if (hasNextPage) {
            apiUrl = dataMap['next'];
          }
        } else {
          print('Failed to fetch data. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> insertCusID(String cusID) async {
    String insertUrl = '$IpAddress/CustomerId/';
    try {
      http.Response response = await http.post(
        Uri.parse(insertUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'customerid': cusID,
        }),
      );
      if (response.statusCode == 201) {
        print('Successfully inserted Customer ID: $cusID');
      } else {
        print(
            'Failed to insert Customer ID. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void Register() async {
    if (nameController.text == "" ||
        emailController.text == "" ||
        mobileController.text == "" ||
        businessnameController.text == "" ||
        stateController.text == "" ||
        districtController.text == "" ||
        cityController.text == "") {
      showEmptyWarning();
      return;
    } else {
      String FullName = nameController.text;
      String Email = emailController.text;
      String businessName = businessnameController.text;
      String MobileNo = mobileController.text;
      String state = stateController.text;
      String district = districtController.text;
      String city = cityController.text;
      String password = passwordController.text;

      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      DateTime trialEndDate = currentDate.add(Duration(days: 30));
      String formattedTrialEndDate =
          DateFormat('yyyy-MM-dd').format(trialEndDate);

      String status = "Active";

      if (currentDate.isAfter(trialEndDate)) {
        status = "Stop";
      }
      Map<String, dynamic> postData = {
        "cusid": lastCusID,
        "trialid": lastTrialID,
        "email": Email,
        "fullname": FullName,
        "businessname": businessName,
        "phoneno": MobileNo,
        "state": state,
        "district": district,
        "city": city,
        "password": password,
        "trialstartdate": formattedDate,
        "trialenddate": formattedTrialEndDate,
        "software": "HotelManagement",
        "status": status,
        "macid": _deviceIdentifier,
        "trialstatus": "Trial",
        "installdate": formattedDate,
        "closedate": formattedDate,
      };

      String base64Image = '';

      if (_image != null) {
        try {
          Uint8List imageBytes = await _image!.readAsBytes();
          base64Image = base64Encode(imageBytes);
        } catch (e) {
          print('Error encoding image: $e');
          return;
        }
      }

      String BurgerBase64Image = base64Image.isEmpty
          ? "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"
          : base64Image;

      BurgerBase64Image = BurgerBase64Image.padRight(
          (BurgerBase64Image.length + 3) ~/ 4 * 4, '=');

      String PizzaBase64Image = base64Image.isEmpty
          ? "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"
          : base64Image;

      PizzaBase64Image = PizzaBase64Image.padRight(
          (PizzaBase64Image.length + 3) ~/ 4 * 4, '=');

      String AppleJuiceBase64Image = base64Image.isEmpty
          ? "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"
          : base64Image;

      AppleJuiceBase64Image = AppleJuiceBase64Image.padRight(
          (AppleJuiceBase64Image.length + 3) ~/ 4 * 4, '=');

      if (businessGstController.text.isNotEmpty) {
        postData["businessgstno"] = businessGstController.text;
      }

      String jsonData = jsonEncode(postData);

      // print('PostData:$postData');

      String apiUrl = '$IpAddress/TrialUserRegistration/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 201) {
        print('Data posted successfully');
        successfullySavedMessage(context);

        await Passwordtbl(
          lastCusID!,
          Email,
          password,
        );

        await insertTrialID(lastTrialID!);
        await insertCusID(lastCusID!);

        // Print Setting
        await insertPrinterSettingData(
            "Sales", "SalesPriner", "Microsoft Print to PDF", 1, "3Inch");
        await insertPrinterSettingData(
            "Kitchen", "KitchenPriner", "Microsoft Print to PDF", 1, "4Inch");
        // Point Setting
        await insertToPointSettingData();
        // Product Category
        await insertProductCategory("Burger", "KitchenPrinter");
        await insertProductCategory("Pizza", "SalesPrinter");
        await insertProductCategory("Juice", "KitchenPrinter");
        // Payment Type
        await insertPaymentMethod("Cash");
        await insertPaymentMethod("Card");
        await insertPaymentMethod("GPay");
        await insertPaymentMethod("Paytm");
        await insertPaymentMethod("PhonePay");
        await insertPaymentMethod("Credit");

        // Gst Details
        await insertGstDetails('Sales', 'NonGst');
        await insertGstDetails('Purchase', 'NonGst');
        await insertGstDetails('OrderSales', 'NonGst');
        await insertGstDetails('VendorSales', 'NonGst');
        // Product Details
        await insertProductDetails(
            'Chicken Pizza',
            '150',
            '150',
            'No',
            '50',
            '2.5',
            '0.0',
            '2.5',
            '0.0',
            '150',
            '1',
            'Pizza',
            '180',
            '180',
            '0',
            'Normal',
            PizzaBase64Image);
        await insertProductDetails(
            'Chicken Cheese Burger',
            '100',
            '100',
            'Yes',
            '60',
            '9',
            '0.0',
            '9',
            '0.0',
            '100',
            '2',
            'Burger',
            '120',
            '120',
            '0',
            'Normal',
            BurgerBase64Image);
        await insertProductDetails(
            'Apple Juice',
            '50',
            '50',
            'No',
            '20',
            '0',
            '0.0',
            '0',
            '0.0',
            '50',
            '3',
            'Juice',
            '60',
            '60',
            '0',
            'Normal',
            AppleJuiceBase64Image);

        // Insert Product Code

        await insertProductCode(BigInt.from(1));
        await insertProductCode(BigInt.from(2));
        await insertProductCode(BigInt.from(3));

        clerFields();
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
    }
  }

  void clerFields() {
    nameController.text = "";
    emailController.text = "";
    mobileController.text = "";
    businessnameController.text = "";
    stateController.text = "";
    districtController.text = "";
    cityController.text = "";
    passwordController.text = "";
    businessGstController.text = "";
    affiliateController.text = "";
  }

// Insert to Point Setting
  Future<void> insertToPointSettingData() async {
    final String point = "1";
    final String amount = "100";

    if (point.isNotEmpty && amount.isNotEmpty) {
      final Uri apiUrl = Uri.parse('$IpAddress/PointSettingalldatas/');

      if (lastCusID == null) {
        print('Customer ID is null');
        return;
      }

      final Map<String, dynamic> data = {
        "cusid": lastCusID,
        "point": point,
        "amount": amount,
      };

      try {
        final response = await http.post(
          apiUrl,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          print('PointData posted successfully');
        } else {
          print(
              'Failed to post PointData. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error posting PointData: $error');
      }
    } else {
      print('Point or amount is empty');
    }
  }

// Insert Product Category
  Future<void> insertProductCategory(String cat, String type) async {
    Map<String, dynamic> postData = {
      "cusid": lastCusID,
      'cat': cat,
      'type': type,
    };

    String apiUrl = '$IpAddress/SettingsProductCategory/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 201) {
        print('ProductCategory inserted successfully');
      } else {
        print(
            'Failed to post ProductCategory. Status code: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error posting ProductCategory: $error');
    }
  }

// Insert to Printer Setting
  Future<void> insertPrinterSettingData(
      String type, String name, String printer, int count, String size) async {
    Map<String, dynamic> postData = {
      "cusid": lastCusID,
      "type": type,
      "name": name,
      "printer": printer,
      "count": count,
      "size": size,
    };

    String apiUrl = '$IpAddress/SettingsPrinterDetailsalldatas/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(postData),
      );

      if (response.statusCode != 201) {
        print(
            'Failed to post PrinterData for $name. Status code: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error posting PrinterData for $name: $error');
    }
  }

// Insert to Payment Type
  Future<void> insertPaymentMethod(String paytype) async {
    String apiUrl = '$IpAddress/PaymentMethodalldatas/';
    Map<String, dynamic> postData = {
      "cusid": lastCusID,
      'paytype': paytype,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 201) {
        print('PaymentData saved successfully');
      } else {
        print(
            'Failed to save PaymentData. Status code: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error posting PaymentData: $error');
    }
  }

  // Insert to Gst Details

  Future<void> insertGstDetails(String name, gststatus) async {
    String apiUrl = '$IpAddress/GstDetailsalldatas/';
    Map<String, dynamic> postData = {
      "cusid": lastCusID,
      'name': name,
      'status': gststatus,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(postData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      print('GstData saved successfully');
    } else {
      print('Failed to save data. Status code: ${response.statusCode}');
    }
  }

  // Insert Product Details

  XFile? _image;

  Future<void> insertProductDetails(
    String name,
    String amount,
    String wholeamount,
    String stock,
    String stockvalue,
    String cgstper,
    String cgstvalue,
    String sgstper,
    String sgstvalue,
    String finalamount,
    String code,
    String category,
    String OnlineAmt,
    String OnlineFinalAmt,
    String makingcost,
    String status,
    String image,
  ) async {
    Map<String, dynamic> postData = {
      "cusid": lastCusID,
      "name": name,
      "amount": amount,
      "wholeamount": wholeamount,
      "stock": stock,
      "stockvalue": stockvalue,
      "cgstper": cgstper,
      "cgstvalue": cgstvalue,
      "sgstper": sgstper,
      "sgstvalue": sgstvalue,
      "finalamount": finalamount,
      "code": code,
      "category": category,
      "OnlineAmt": OnlineAmt,
      "OnlineFinalAmt": OnlineFinalAmt,
      "makingcost": makingcost,
      "status": status,
      'image': image,
    };

    String jsonData = jsonEncode(postData);

    String apiUrl = '$IpAddress/SettingsProductDetailsalldatas/';
    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    if (response.statusCode == 201) {
      print('ProductDetails posted successfully');
    } else {
      print(
          'Failed to post ProductDetails data: ${response.statusCode}, ${response.body}');
    }
  }

  Future<void> insertProductCode(BigInt sno) async {
    String apiUrl = '$IpAddress/SettingsProductDetailsSNoalldatas/';
    Map<String, dynamic> postData = {
      "cusid": lastCusID,
      'sno': sno.toString(),
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(postData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Product Code Data saved successfully');
      } else {
        print('Failed to save data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}