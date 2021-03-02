import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/services/Config.dart' as repo;

class PINPage extends StatefulWidget {
  // PIN Enter PAGE
  PINPage({Key key}) : super(key: key);

  @override
  _PINPageState createState() => _PINPageState();
}

class _PINPageState extends State<PINPage> {
  var pinNumber = "";
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isCheckIn = false;
  bool isLoading = false;
  LocalAPI localAPI = LocalAPI();

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    checkAlreadyclockin();
  }

  checkAlreadyclockin() async {
    var isClockin = await localAPI.getShift();

    setState(() {
      isCheckIn = isClockin ?? false;
    });

    await SyncAPICalls.logActivity(
        "check in/out", "Opened check in out page", "checkIn", 1);
  }

  addINPin(val) async {
    if (pinNumber.length < 6) {
      var currentpinNumber = pinNumber;
      currentpinNumber += val;
      setState(() {
        pinNumber = currentpinNumber;
      });
    }
  }

  clearPin() {
    setState(() {
      pinNumber = "";
    });
  }

  syncAllTables() async {
    await Preferences.removeSinglePref(Constant.LastSync_Table);
    await Preferences.removeSinglePref(Constant.OFFSET);
    await CommunFun.openSyncPop(context);
    await CommunFun.syncOrdersANDStore(context, false);
    await CommunFun.syncAfterSuccess(context, false);
    getconfigdata();

    await SyncAPICalls.logActivity(
        "Sync tables", "Cashier click sync", "all tables", 1);
  }

  getconfigdata() async {
    var res = await repo.getCongigData();
    if (res["status"] == Constant.STATUS200) {
      await Preferences.setStringToSF(
          Constant.SYNC_TIMER, res["data"]["sync_timer"]);
      await Preferences.setStringToSF(
          Constant.CURRENCY, res["data"]["currency"]);
    } else {
      CommunFun.showToast(context, res["message"]);
    }
  }

  clockInwithPIN() async {
    if (!isCheckIn) {
      if (pinNumber.length >= 6) {
        List<User> checkUserExit = await localAPI.checkUserExit(pinNumber);
        if (checkUserExit.length != 0) {
          setState(() {
            isLoading = true;
          });
          User user = checkUserExit[0];
          CheckinOut checkIn = new CheckinOut();
          var terminalId = await CommunFun.getTeminalKey();
          var branchid = await CommunFun.getbranchId();
          var date = DateTime.now();
          checkIn.localID = await CommunFun.getLocalID();
          checkIn.terminalId = int.parse(terminalId);
          checkIn.userId = user.id;
          //checkIn.branchId = int.parse(branchid);
          checkIn.status = "IN";
          checkIn.timeInOut = date.toString();
          checkIn.createdAt = date.toString();
          checkIn.sync = 0;
          var result = await localAPI.userCheckInOut(checkIn);
          await Preferences.setStringToSF(
              Constant.LOIGN_USER, json.encode(user));
          await CommunFun.checkUserPermission(user.id);
          await Preferences.setStringToSF(Constant.IS_CHECKIN, "true");
          await Preferences.setStringToSF(Constant.SHIFT_ID, result.toString());
          await SyncAPICalls.logActivity("Check In",
              user.name.toString() + " checked In", "user_checkinout", 1);
          await Navigator.pushNamedAndRemoveUntil(context,
              Constant.SelectTableScreen, (Route<dynamic> route) => false,
              arguments: {"isAssign": false});
          if (this.mounted) {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          if (this.mounted) {
            setState(() {
              isLoading = false;
            });
          }
          CommunFun.showToast(context, Strings.invalidPinMsg);
        }
      } else {
        if (pinNumber.length >= 6) {
          CommunFun.showToast(context, Strings.invalidPinMsg);
        } else {
          CommunFun.showToast(context, Strings.pinValidationMessage);
        }
      }
    } else {
      CommunFun.showToast(context, Strings.alreadyClockinMsg);
    }
  }

  clockOutwithPIN() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (loginUser == null) {
      CommunFun.showToast(context, Strings.noUserClockIn);
      return;
    }
    var user = json.decode(loginUser);
    var pin = user["user_pin"];
    if (isCheckIn) {
      if (pinNumber.length >= 6 && pin.toString() == pinNumber) {
        setState(() {
          isLoading = true;
        });
        CheckinOut checkIn = new CheckinOut();
        var shiftid = await Preferences.getStringValuesSF(Constant.SHIFT_ID);
        var terminalId = await CommunFun.getTeminalKey();
        var branchid = await CommunFun.getbranchId();
        var date = DateTime.now();
        checkIn.id = int.parse(shiftid);
        checkIn.localID = await CommunFun.getLocalID();
        checkIn.terminalId = int.parse(terminalId);
        checkIn.userId = user["id"];
        //checkIn.branchId = int.parse(branchid);
        checkIn.status = "OUT";
        checkIn.timeInOut = date.toString();
        checkIn.sync = 0;
        await SyncAPICalls.logActivity(
            "Check OUT", user["name"] + " checked Out", "user_checkinout", 1);
        await localAPI.userCheckInOut(checkIn);
        clearAfterCheckout();
      } else {
        if (pinNumber.length >= 6) {
          CommunFun.showToast(context, Strings.invalidPinMsg);
        } else {
          CommunFun.showToast(context, Strings.pinValidationMessage);
        }
      }
    } else {
      CommunFun.showToast(context, Strings.alreadyClockoutMsg);
    }
  }

  clearAfterCheckout() async {
    await Preferences.removeSinglePref(Constant.IS_CHECKIN);
    await Preferences.removeSinglePref(Constant.SHIFT_ID);
    await Preferences.removeSinglePref(Constant.LOIGN_USER);
    await Preferences.removeSinglePref(Constant.USER_PERMISSION);

    await Navigator.pushNamedAndRemoveUntil(
      context,
      Constant.PINScreen,
      (Route<dynamic> route) => false,
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _willPopCallback() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      child: LoadingOverlay(
          child: SafeArea(
            child: Scaffold(
              key: scaffoldKey,
              body: Container(
                //page background image
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Strings.assetsBG), fit: BoxFit.cover),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: StaticColor.colorWhite),
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.height / 1.2,
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.top,
                        border: TableBorder(
                            horizontalInside: BorderSide(
                                width: 1,
                                color: StaticColor.colorGrey,
                                style: BorderStyle.solid)),
                        columnWidths: {
                          0: FractionColumnWidth(.2),
                          1: FractionColumnWidth(.4),
                        },
                        children: [
                          TableRow(children: [
                            imageview(context),
                            getNumbers(context)
                          ]) // Part 1 image with logo
                          , // Part 2  Muber keypade
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading: isLoading,
          color: StaticColor.colorLightBlack,
          progressIndicator: CommunFun.overLayLoader()),
      onWillPop: _willPopCallback,
    );
  }

  Widget imageview(context) {
    return Container(
      // width: MediaQuery.of(context).size.width / 2.9,
      height: MediaQuery.of(context).size.height / 1.2,
      decoration: BoxDecoration(
        color: StaticColor.colorGrey,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), topLeft: Radius.circular(30)),
        // image: DecorationImage(
        //     image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            // login logo
            height: SizeConfig.safeBlockVertical * 10,
            child: Image.asset(
              Strings.assetHeaderLogo,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget getNumbers(context) {
    // Numbers buttons
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 80),
      height: MediaQuery.of(context).size.height / 1.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /* isCheckIn
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                            padding: EdgeInsets.only(right: 40, top: 10),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: SizeConfig.safeBlockVertical * 7,
                            )),
                      ],
                    )
                  : SizedBox(),*/

            Container(
              child: new Stack(
                children: [
                  Container(
                    margin:
                        EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        Strings.pinNumber,
                        style: Styles.communBlack(),
                      ),
                    ),
                  ),
                  isCheckIn
                      ? Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              padding: EdgeInsets.only(
                                  right: SizeConfig.safeBlockVertical * 5),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.close,
                                color: StaticColor.colorBlack,
                                size: SizeConfig.safeBlockVertical * 7,
                              )),
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              padding: EdgeInsets.only(
                                  right: SizeConfig.safeBlockVertical * 5),
                              onPressed: () async {
                                // await Navigator.pushNamedAndRemoveUntil(
                                //   context,
                                //   Constant.TerminalScreen,
                                //   (Route<dynamic> route) => false,
                                // );
                              },
                              icon: Icon(
                                Icons.close,
                                color: StaticColor.colorBlack,
                                size: SizeConfig.safeBlockVertical * 7,
                              )),
                        ),
                  isCheckIn
                      ? Positioned(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.safeBlockVertical * 3 * .5,
                              horizontal: SizeConfig.safeBlockVertical * 3,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.sync),
                              onPressed: syncAllTables,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            /* mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      Strings.pin_Number,
                      style: Styles.blackBoldLarge(),
                    )
                  ]),*/
            SizedBox(
              height: SizeConfig.safeBlockVertical * 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  pinNumber.length >= 1 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 2 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 3 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 4 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 5 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 6 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical * 4,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("1", () {
                        addINPin("1");
                      }), // using custom widget _button
                      _button("2", () {
                        addINPin("2");
                      }),
                      _button("3", () {
                        addINPin("3");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("4", () {
                        addINPin("4");
                      }), // using custom widget _button
                      _button("5", () {
                        addINPin("5");
                      }),
                      _button("6", () {
                        addINPin("6");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("7", () {
                        addINPin("7");
                      }), // using custom widget _button
                      _button("8", () {
                        addINPin("8");
                      }),
                      _button("9", () {
                        addINPin("9");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _buttonCN(Strings.btnclockin, () {
                        clockInwithPIN();
                      }),
                      _button("0", () {
                        addINPin("0");
                      }),
                      _buttonCN(Strings.btnclockout, () {
                        clockOutwithPIN();
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              clearPin();
                            },
                            child: Text(Strings.clear,
                                style: Styles.orangeMedium()))
                      ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: StaticColor.colorGrey)),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Text(number,
          textAlign: TextAlign.center, style: Styles.communBlack()),
      textColor: StaticColor.colorBlack,
      color: StaticColor.lightGrey100,
      onPressed: f,
    );
  }

  Widget _buttonCN(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(
            color: StaticColor.colorGrey,
          )),
      height: MediaQuery.of(context).size.height / 8.7,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Text(number,
          textAlign: TextAlign.center, style: Styles.blackBoldsmall()),
      textColor: StaticColor.colorBlack,
      color: StaticColor.lightGrey100,
      onPressed: f,
    );
  }
}
