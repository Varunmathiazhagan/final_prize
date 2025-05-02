import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;

class StudentProfilePage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentProfilePage({Key? key, required this.studentData})
      : super(key: key);

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _linkedinController;
  late TextEditingController _phoneController;
  late TextEditingController _personalEmailController;
  late TextEditingController _departmentController;
  late TextEditingController _joiningYearController;
  late TextEditingController _passingYearController;

  @override
  void initState() {
    super.initState();
    _linkedinController =
        TextEditingController(text: widget.studentData['linkedin'] ?? '');
    _phoneController =
        TextEditingController(text: widget.studentData['phone'] ?? '');
    _personalEmailController =
        TextEditingController(text: widget.studentData['personalEmail'] ?? '');
    _departmentController =
        TextEditingController(text: widget.studentData['department'] ?? '');
    _joiningYearController =
        TextEditingController(text: widget.studentData['joiningYear'] ?? '');
    _passingYearController =
        TextEditingController(text: widget.studentData['passingYear'] ?? '');
  }

  @override
  void dispose() {
    _linkedinController.dispose();
    _phoneController.dispose();
    _personalEmailController.dispose();
    _departmentController.dispose();
    _joiningYearController.dispose();
    _passingYearController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/student/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': widget.studentData['username'],
            'linkedin': _linkedinController.text,
            'phone': _phoneController.text,
            'personalEmail': _personalEmailController.text,
            'department': _departmentController.text,
            'joiningYear': _joiningYearController.text,
            'passingYear': _passingYearController.text,
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
        title: Text('Student Profile'),
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
                    controller: _personalEmailController,
                    decoration: InputDecoration(
                      labelText: 'Personal Email',
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
                    controller: _departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(MdiIcons.school),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _joiningYearController,
                    decoration: InputDecoration(
                      labelText: 'Joining Year',
                      prefixIcon: Icon(MdiIcons.calendar),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _passingYearController,
                    decoration: InputDecoration(
                      labelText: 'Passing Year',
                      prefixIcon: Icon(MdiIcons.calendarCheck),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
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
