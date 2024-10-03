import 'package:flutter/material.dart';

void _showCompanyDetailsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Company Details'),
        content: Container(
          width: double.maxFinite,
          child: CompanyDetailsForm(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

class CompanyDetailsForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 20),
          _buildTextField('Technology Partner', 'Enter Technology Partner'),
          SizedBox(height: 16),
          _buildTextField('Address', 'Enter Address'),
          SizedBox(height: 16),
          _buildTextField('Contact', 'Enter Contact Number'),
          SizedBox(height: 16),
          _buildTextField('Mail ID', 'Enter Email Address'),
          SizedBox(height: 16),
          _buildTextField('Website', 'Enter Website URL'),
          SizedBox(height: 20),
          _buildSocialMediaIcons(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    );
  }

  Widget _buildSocialMediaIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset('assets/imgs/instagram.png', width: 30),
        Image.asset('assets/imgs/facebook.png', width: 30),
        Image.asset('assets/imgs/twitter.png', width: 30),
        Image.asset('assets/imgs/linkedin.png', width: 30),
        Image.asset('assets/imgs/youtube.png', width: 30),
      ],
    );
  }
}
