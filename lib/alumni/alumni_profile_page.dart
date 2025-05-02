import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;

class AlumniProfilePage extends StatefulWidget {
  final Map<String, dynamic> alumniData;

  const AlumniProfilePage({Key? key, required this.alumniData})
      : super(key: key);

  @override
  _AlumniProfilePageState createState() => _AlumniProfilePageState();
}

class _AlumniProfilePageState extends State<AlumniProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _linkedinController;
  late TextEditingController _phoneController;
  late TextEditingController _otherEmailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.alumniData['company'] ?? '');
    _linkedinController =
        TextEditingController(text: widget.alumniData['linkedin'] ?? '');
    _phoneController =
        TextEditingController(text: widget.alumniData['phone'] ?? '');
    _otherEmailController =
        TextEditingController(text: widget.alumniData['otherEmail'] ?? '');
    _addressController =
        TextEditingController(text: widget.alumniData['address'] ?? '');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _linkedinController.dispose();
    _phoneController.dispose();
    _otherEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/admin/alumni/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': widget.alumniData['username'],
            'company': _companyController.text,
            'linkedin': _linkedinController.text,
            'phone': _phoneController.text,
            'otherEmail': _otherEmailController.text,
            'address': _addressController.text,
          }),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          Navigator.pop(context); // Return to dashboard
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumni Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Profile',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: 'Company',
                      prefixIcon: Icon(MdiIcons.briefcase),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _linkedinController,
                    decoration: InputDecoration(
                      labelText: 'LinkedIn',
                      prefixIcon: Icon(MdiIcons.linkedin),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(MdiIcons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _otherEmailController,
                    decoration: InputDecoration(
                      labelText: 'Other Email',
                      prefixIcon: Icon(MdiIcons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isNotEmpty && !value.contains('@')
                            ? 'Invalid email'
                            : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(MdiIcons.mapMarker),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _updateProfile,
                    icon: Icon(MdiIcons.contentSave),
                    label: Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
