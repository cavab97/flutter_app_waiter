import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/theme/theme.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cashierApp',
      theme: appTheme(),
      initialRoute: '/TerminalKeyPage',
      routes: routes,
    );
  }
}
