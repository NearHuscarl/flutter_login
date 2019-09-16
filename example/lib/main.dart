import 'package:example/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

const primaryColor = Colors.purple;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: primaryColor,
        accentColor: Colors.yellow,
      ),
      home: LoginScreen(),
      routes: {
        // LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
  }
}
