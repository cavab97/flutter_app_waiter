import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/services/Config.dart' as repo;
import 'package:mcncashier/components/colors.dart';

class SplashScreen extends StatefulWidget {
// PIN Enter PAGE
  SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenstate createState() => SplashScreenstate();
}

class SplashScreenstate extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getconfigdata();
    navigatePage();
  }

  getconfigdata() async {
    var res = await repo.getCongigData();
    if (res["status"] == Constant.STATUS200) {
      await Preferences.setStringToSF(
          Constant.SYNC_TIMER, res["data"]["sync_timer"]);
      await Preferences.setStringToSF(
          Constant.CURRENCY, res["data"]["currency"]);
    } else if (context != null) {
      CommunFun.showToast(context, res["message"]);
    }
  }

  setTimer() async {
    await CommunFun.checkisAutoSync(context);
  }

  navigatePage() {
    Future.delayed(const Duration(seconds: 4), () async {
      final bool isLogged = await CommunFun.isLogged();
      if (isLogged) {
        setTimer();
        /* await Navigator.pushNamedAndRemoveUntil(context,
            Constant.SelectTableScreen, (Route<dynamic> route) => false,
            arguments: {"isAssign": false}); */
      } /* else {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          Constant.PINScreen,
          (Route<dynamic> route) => false,
        );
      } */
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticColor.colorWhite,
      body: Center(
        child: Container(
          child: Image.asset("assets/splash_screen.png",
              fit: BoxFit.cover,
              gaplessPlayback: false,
              height: double.infinity,
              width: double.infinity),
        ),
      ),
    );
  }
}
