import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Printer Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PrinterPreview(),
    );
  }
}

class PrinterPreview extends StatelessWidget {
  final String htmlContent = '''
    <h1>Bill Details</h1>
    <p>Restaurant Name: Example Restaurant</p>
    <p>Address: 123 Example St, City</p>
    <p>Contact: +1234567890</p>
    <hr/>
    <p>Bill No: 00123</p>
    <p>Payment Type: Cash</p>
    <p>Date: 10-Aug-2024</p>
    <p>Time: 12:34 PM</p>
    <hr/>
    <p><b>Items:</b></p>
    <p>Item 1: \$10.00</p>
    <p>Item 2: \$15.00</p>
    <p><b>Total: \$25.00</b></p>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Printer Preview'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Html(
            data: htmlContent,
            style: {
              'body': Style(
                fontSize: FontSize.medium,
                width:
                    Width(240.0), // 3 inches = 240 pixels at 80 pixels per inch
                margin: Margins.all(0),
                padding: HtmlPaddings.all(0),
              ),
              'h1': Style(
                fontSize: FontSize.large,
                fontWeight: FontWeight.bold,
              ),
              'p': Style(
                fontSize: FontSize.medium,
              ),
              'hr': Style(
                border:
                    Border(bottom: BorderSide(width: 1.0, color: Colors.black)),
              ),
            },
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';

// class PrinterPreview extends StatelessWidget {
//   final String htmlContent;

//   PrinterPreview({required this.htmlContent});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Printer Preview'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Html(
//             data: htmlContent,
//             style: {
//               'body': Style(
//                 fontSize: FontSize.medium,
//                 width: Width(240.0), // Set the width to 3 inches (240 pixels)
//                 margin: Margins.all(0), // Use Margins instead of EdgeInsets
//                 padding: HtmlPaddings.all(
//                     0), // Use HtmlPaddings instead of EdgeInsets
//               ),
//               'h1': Style(
//                 fontSize: FontSize.large,
//                 fontWeight: FontWeight.bold,
//               ),
//               'p': Style(
//                 fontSize: FontSize.medium,
//               ),
//               'hr': Style(
//                 border:
//                     Border(bottom: BorderSide(width: 1.0, color: Colors.black)),
//                 margin: Margins.symmetric(vertical: 5),
//               ),
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: PrinterPreview(
//       htmlContent: '''
//         <h1>Bill Details</h1>
//         <p>Restaurant Name: Example Restaurant</p>
//         <p>Address: 123 Example St, City</p>
//         <p>Contact: +1234567890</p>
//         <hr/>
//         <p>Bill No: 00123</p>
//         <p>Payment Type: Cash</p>
//         <p>Date: 10-Aug-2024</p>
//         <p>Time: 12:34 PM</p>
//         <hr/>
//         <p><b>Items:</b></p>
//         <p>Item 1: \$10.00</p>
//         <p>Item 2: \$15.00</p>
//         <p><b>Total: \$25.00</b></p>
//       ''',
//     ),
//   ));
// }
