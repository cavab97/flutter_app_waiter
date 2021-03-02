import 'package:flutter/widgets.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/screens/Dashboard.dart';
import 'package:mcncashier/screens/Login.dart';
import 'package:mcncashier/screens/PINPage.dart';
import 'package:mcncashier/screens/SelectTable.dart';
import 'package:mcncashier/screens/Settings.dart';
import 'package:mcncashier/screens/TerminalScreen.dart';
import 'package:mcncashier/screens/Transactions.dart';
import 'package:mcncashier/screens/WebOrdersPage.dart';
import 'package:mcncashier/screens/Shift_Reports.dart';
import 'package:mcncashier/screens/WineStorage.dart';
import 'package:mcncashier/screens/outOfStock/OutofStock.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  //Constant.TerminalScreen: (BuildContext context) => TerminalKeyPage(),
  Constant.LoginScreen: (BuildContext context) => LoginPage(),
  Constant.PINScreen: (BuildContext context) => PINPage(),
  Constant.DashboardScreen: (BuildContext context) => DashboradPage(),
  Constant.TransactionScreen: (BuildContext context) => TransactionsPage(),
  Constant.SelectTableScreen: (BuildContext context) => SelectTablePage(),
  Constant.SettingsScreen: (BuildContext context) => SettingsPage(),
  Constant.WebOrderPages: (BuildContext context) => WebOrderPages(),
  Constant.ShiftOrders: (BuildContext context) => ShiftReports(),
  Constant.WineStorage: (BuildContext context) => WineStorage(),
  Constant.OutofStock: (BuildContext context) => OutofStock(),
};
