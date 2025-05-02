import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class StudentDashboardPage extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboardPage({Key? key, required this.studentData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.accountEdit),
            onPressed: () => Navigator.pushNamed(context, '/student_profile',
                arguments: studentData),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.account, size: 40, color: Colors.blueAccent),
                    SizedBox(width: 16),
                    Text(
                      studentData['name'] ?? 'N/A',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(MdiIcons.numeric),
                  title: Text('Roll Number: ${studentData['rollNo'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.email),
                  title: Text('Email: ${studentData['konguEmail'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.school),
                  title:
                      Text('Department: ${studentData['department'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.calendar),
                  title: Text(
                      'Joining Year: ${studentData['joiningYear'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.calendarCheck),
                  title: Text(
                      'Passing Year: ${studentData['passingYear'] ?? 'N/A'}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
