import 'package:flutter/widgets.dart';
import 'package:mcncashier/screens/Dashboard.dart';
import 'package:mcncashier/screens/Login.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/PINPage.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/Transactions.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/Login": (BuildContext context) => LoginPage(),
  "/PINPage": (BuildContext context) => PINPage(),
  "/Dashboard": (BuildContext context) => DashboradPage(),
  "/OpningAmmount": (BuildContext context) => OpeningAmmountPage(),
  "/TansactionsPage": (BuildContext context) => TransactionsPage(),
};
