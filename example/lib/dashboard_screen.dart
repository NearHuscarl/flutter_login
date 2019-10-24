import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_login/flutter_login.dart';

import 'constants.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';

  Future<bool> _goToLogin(BuildContext context) {
    // we dont want to pop the screen, just replace it completely
    return Navigator.of(context).pushReplacementNamed('/').then((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuBtn = IconButton(
      color: theme.accentColor,
      icon: Icon(
        FontAwesomeIcons.bars,
      ),
      onPressed: () {},
    );
    final signOutBtn = IconButton(
      icon: Icon(
        FontAwesomeIcons.signOutAlt,
        color: theme.accentColor,
      ),
      onPressed: () => _goToLogin(context),
    );

    return WillPopScope(
      onWillPop: () => _goToLogin(context),
      child: Scaffold(
        appBar: AppBar(
          leading: menuBtn,
          actions: <Widget>[signOutBtn],
          title: Container(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Hero(
                        tag: Constants.logoTag,
                        child: Image.asset(
                          'assets/images/ecorp.png',
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  HeroText(
                    Constants.appName,
                    tag: Constants.titleTag,
                    viewState: ViewState.shrunk,
                    style: defaultLoginTitleStyle(theme)
                        .copyWith(color: Colors.orange),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ),
          backgroundColor: theme.primaryColor.withOpacity(.1),
          elevation: 0,
          textTheme: theme.accentTextTheme,
          iconTheme: theme.accentIconTheme,
        ),
        body: Container(
          color: theme.primaryColor.withOpacity(.1),
          child: Center(
            child: Text('Stuff'),
          ),
        ),
      ),
    );
  }
}
