import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AdminPortalPage extends StatefulWidget {
  const AdminPortalPage({Key? key}) : super(key: key);

  @override
  _AdminPortalPageState createState() => _AdminPortalPageState();
}

class _AdminPortalPageState extends State<AdminPortalPage> {
  final _studentFormKey = GlobalKey<FormState>();
  final _alumniFormKey = GlobalKey<FormState>();
  String? studentName, studentRollNo, studentEmail;
  String? alumniName,
      alumniRollNo,
      alumniEmail,
      alumniDepartment,
      alumniPassedOutYear;
  List<dynamic> pendingAlumni = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingAlumni();
  }

  Future<void> _fetchPendingAlumni() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/admin/pending_alumni'),
      );
      if (response.statusCode == 200) {
        setState(() {
          pendingAlumni = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch pending alumni: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching pending alumni: $e')),
      );
    }
  }

  Future<void> _addStudent() async {
    if (_studentFormKey.currentState!.validate()) {
      _studentFormKey.currentState!.save();
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/admin/add_student'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': studentName,
            'rollNo': studentRollNo,
            'konguEmail': studentEmail,
          }),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${data['message']} (${data['emailStatus']})')),
          );
          _studentFormKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error: ${data['message']} (${data['error'] ?? ''})')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding student: $e')),
        );
      }
    }
  }

  Future<void> _addAlumni() async {
    if (_alumniFormKey.currentState!.validate()) {
      _alumniFormKey.currentState!.save();
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/admin/add_alumni'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': alumniName,
            'rollNo': alumniRollNo,
            'email': alumniEmail,
            'department': alumniDepartment,
            'passedOutYear': alumniPassedOutYear,
          }),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${data['message']} (${data['emailStatus']})')),
          );
          _alumniFormKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error: ${data['message']} (${data['error'] ?? ''})')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding alumni: $e')),
        );
      }
    }
  }

  Future<void> _bulkAddStudents() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null) {
        final file = result.files.single;
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3000/api/admin/bulk_add_students'),
        );
        request.files
            .add(await http.MultipartFile.fromPath('file', file.path!));
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error: ${data['message']} (${data['error'] ?? ''})')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading CSV: $e')),
      );
    }
  }

  Future<void> _approveAlumni(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/admin/approve_alumni'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${data['message']} (${data['emailStatus']})')),
        );
        _fetchPendingAlumni();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: ${data['message']} (${data['error'] ?? ''})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving alumni: $e')),
      );
    }
  }

  Future<void> _rejectAlumni(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/admin/reject_alumni'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${data['message']} (${data['emailStatus']})')),
        );
        _fetchPendingAlumni();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: ${data['message']} (${data['error'] ?? ''})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting alumni: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(MdiIcons.accountKey, color: Colors.white),
            SizedBox(width: 8),
            Text('Admin Portal'),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Student Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(MdiIcons.accountPlus, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('Add Student',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: _studentFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(MdiIcons.account),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                            onSaved: (value) => studentName = value,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Roll Number',
                              prefixIcon: Icon(MdiIcons.numeric),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                            onSaved: (value) => studentRollNo = value,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Kongu Email',
                              prefixIcon: Icon(MdiIcons.email),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) => !value!.contains('@kongu.edu')
                                ? 'Invalid Kongu email'
                                : null,
                            onSaved: (value) => studentEmail = value,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addStudent,
                            icon: Icon(MdiIcons.accountPlus),
                            label: Text('Add Student'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Add Alumni Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(MdiIcons.accountStar, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('Add Alumni',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: _alumniFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(MdiIcons.account),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                            onSaved: (value) => alumniName = value,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Roll Number',
                              prefixIcon: Icon(MdiIcons.numeric),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                            onSaved: (value) => alumniRollNo = value,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(MdiIcons.email),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                !value!.contains('@') ? 'Invalid email' : null,
                            onSaved: (value) => alumniEmail = value,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Department',
                              prefixIcon: Icon(MdiIcons.school),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                            onSaved: (value) => alumniDepartment = value,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Passed Out Year',
                              prefixIcon: Icon(MdiIcons.calendar),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                            onSaved: (value) => alumniPassedOutYear = value,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addAlumni,
                            icon: Icon(MdiIcons.accountStar),
                            label: Text('Add Alumni'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Bulk Add Students Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(MdiIcons.fileUpload, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('Bulk Add Students',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _bulkAddStudents,
                      icon: Icon(MdiIcons.fileUpload),
                      label: Text('Upload CSV'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Pending Alumni Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(MdiIcons.accountClock, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('Pending Alumni',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    SizedBox(height: 16),
                    pendingAlumni.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No pending alumni',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: pendingAlumni.length,
                            itemBuilder: (context, index) {
                              final alumni = pendingAlumni[index];
                              return ListTile(
                                leading: Icon(MdiIcons.account),
                                title: Text(alumni['name'] ?? 'N/A'),
                                subtitle: Text(alumni['email'] ?? 'N/A'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(MdiIcons.check,
                                          color: Colors.green),
                                      onPressed: () =>
                                          _approveAlumni(alumni['email']),
                                      tooltip: 'Approve',
                                    ),
                                    IconButton(
                                      icon: Icon(MdiIcons.close,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _rejectAlumni(alumni['email']),
                                      tooltip: 'Reject',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
