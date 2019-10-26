import 'package:flutter/services.dart';
import 'package:login_example/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'transition_route_observer.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.orange,
          cursorColor: Colors.orange,
          textTheme: TextTheme(
            display2: TextStyle(
              fontSize: 45.0,
              fontWeight: FontWeight.normal,
              color: Colors.deepPurple,
            ),
            caption: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
              color: Colors.deepPurple[300],
            ),
          )),
      home: LoginScreen(),
      navigatorObservers: [TransitionRouteObserver()],
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
  }
}
