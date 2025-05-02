import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AlumniDashboardPage extends StatelessWidget {
  final Map<String, dynamic> alumniData;

  const AlumniDashboardPage({Key? key, required this.alumniData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumni Dashboard'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.accountEdit),
            onPressed: () => Navigator.pushNamed(context, '/alumni_profile',
                arguments: alumniData),
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
                    Icon(MdiIcons.accountStar,
                        size: 40, color: Colors.blueAccent),
                    SizedBox(width: 16),
                    Text(
                      alumniData['name'] ?? 'N/A',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(MdiIcons.numeric),
                  title: Text('Roll Number: ${alumniData['rollNo'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.email),
                  title: Text('Email: ${alumniData['email'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.school),
                  title:
                      Text('Department: ${alumniData['department'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.calendarCheck),
                  title: Text(
                      'Passed Out Year: ${alumniData['passedOutYear'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.briefcase),
                  title: Text('Company: ${alumniData['company'] ?? 'N/A'}'),
                ),
                ListTile(
                  leading: Icon(MdiIcons.linkedin),
                  title: Text('LinkedIn: ${alumniData['linkedin'] ?? 'N/A'}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
