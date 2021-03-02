import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/screens/SplashScreen.dart';
import 'package:mcncashier/theme/theme.dart';
import 'package:wifi/wifi.dart';

import 'httpServer/slave.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLogged = await CommunFun.isLogged();
  runApp(MyApp(islogin: isLogged));
}

class MyApp extends StatefulWidget {
  // main Product list page
  MyApp({Key key, this.islogin}) : super(key: key);
  final bool islogin;
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var intitialRoute;

  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    databaseHelper.initializeDatabase();
    Future.delayed(Duration(seconds: 3), () {
      serverStart();
    });
  }

  void serverStart() async {
    final String address = await Wifi.ip;
    print('enter Server started:');
    SlaveModel.start(address);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print("paused");
        break;
      case AppLifecycleState.resumed:
        print("resumed");
        break;
      case AppLifecycleState.inactive:
        print("Inactive");
        timer?.cancel();
        break;
      case AppLifecycleState.detached:
        print("Detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      title: 'cashierApp',
      theme: appTheme(),
      // initialRoute:
      //     widget.islogin ? Constant.DashboardScreen : Constant.TerminalScreen,
      routes: routes,
    );
  }
}
