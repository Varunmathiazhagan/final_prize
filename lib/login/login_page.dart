import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _adminFormKey = GlobalKey<FormState>();
  final _studentFormKey = GlobalKey<FormState>();
  final _alumniFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  TabController? _tabController;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _login(String role) async {
    final formKey = role == 'admin'
        ? _adminFormKey
        : role == 'student'
            ? _studentFormKey
            : _alumniFormKey;
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final username = _usernameController.text;
      final password = _passwordController.text;

      if (role == 'student' &&
          !RegExp(r'^[\w]+\.\d{2}[a-zA-Z]+@kongu\.edu$').hasMatch(username)) {
        setState(() {
          _errorMessage =
              'Please use a valid Kongu domain email (e.g., sujithg.22it@kongu.edu)';
          _isLoading = false;
        });
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'role': role,
          }),
        );

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && mounted) {
          if (role == 'admin') {
            Navigator.pushNamed(context, '/admin_portal');
          } else if (role == 'student') {
            Navigator.pushNamed(context, '/student_dashboard',
                arguments: data['user']);
          } else {
            Navigator.pushNamed(context, '/alumni_dashboard',
                arguments: data['user']);
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = data['message'] ?? 'Login failed';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Network error: Unable to connect to the server';
          });
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(MdiIcons.school, color: Colors.white),
            SizedBox(width: 8),
            Text('AlumniConnect'),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Admin'),
            Tab(text: 'Student'),
            Tab(text: 'Alumni'),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLoginForm('admin', _adminFormKey),
            _buildLoginForm('student', _studentFormKey),
            _buildLoginForm('alumni', _alumniFormKey),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(String role, GlobalKey<FormState> formKey) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == 'admin'
                      ? MdiIcons.accountKey
                      : role == 'student'
                          ? MdiIcons.accountSchool
                          : MdiIcons.accountStar,
                  size: 48,
                  color: Colors.blueAccent,
                ),
                SizedBox(height: 16),
                Text(
                  '${role.capitalize()} Login',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: role == 'student' ? 'Kongu Email' : 'Username',
                    prefixIcon: Icon(MdiIcons.account),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ${role == 'student' ? 'Kongu email' : 'username'}';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(MdiIcons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: Icon(MdiIcons.login),
                        label: Text('Login'),
                        onPressed: () => _login(role),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                if (role == 'alumni') ...[
                  SizedBox(height: 16),
                  TextButton.icon(
                    icon: Icon(MdiIcons.accountPlus),
                    label: Text('Sign Up as Alumni'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/alumni_signup');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tabController?.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
