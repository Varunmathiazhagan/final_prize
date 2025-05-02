import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;

class AlumniSignupPage extends StatefulWidget {
  @override
  _AlumniSignupPageState createState() => _AlumniSignupPageState();
}

class _AlumniSignupPageState extends State<AlumniSignupPage> {
  final _formKey = GlobalKey<FormState>();
  String? name, rollNo, email, department, passedOutYear;
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/alumni/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'rollNo': rollNo,
            'email': email,
            'department': department,
            'passedOutYear': passedOutYear,
          }),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alumni Signup')),
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
                  Row(
                    children: [
                      Icon(MdiIcons.accountStar, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Alumni Signup',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(MdiIcons.account),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => name = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Roll Number',
                      prefixIcon: Icon(MdiIcons.numeric),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => rollNo = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(MdiIcons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        !value!.contains('@') ? 'Invalid email' : null,
                    onSaved: (value) => email = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(MdiIcons.school),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => department = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Passed Out Year',
                      prefixIcon: Icon(MdiIcons.calendar),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => passedOutYear = value,
                  ),
                  SizedBox(height: 16),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _signup,
                          icon: Icon(MdiIcons.send),
                          label: Text('Submit Signup Request'),
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
