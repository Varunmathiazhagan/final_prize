import 'package:flutter/material.dart';
import 'package:alumniconnect/login/login_page.dart';
import 'package:alumniconnect/admin/admin_portal.dart';
import 'package:alumniconnect/student/student_dashboard_page.dart';
import 'package:alumniconnect/student/student_profile_page.dart';
import 'package:alumniconnect/alumni/alumni_signup_page.dart';
import 'package:alumniconnect/alumni/alumni_dashboard_page.dart';
import 'package:alumniconnect/alumni/alumni_profile_page.dart';

void main() {
  runApp(AlumniConnectApp());
}

class AlumniConnectApp extends StatelessWidget {
  const AlumniConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlumniConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(color: Colors.blueAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/admin_portal': (context) => AdminPortalPage(),
        '/student_dashboard': (context) => StudentDashboardPage(
              studentData: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/student_profile': (context) => StudentProfilePage(
              studentData: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/alumni_signup': (context) => AlumniSignupPage(),
        '/alumni_dashboard': (context) => AlumniDashboardPage(
              alumniData: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/alumni_profile': (context) => AlumniProfilePage(
              alumniData: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
      },
    );
  }
}
