import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/CloseShiftPage.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/commanutils.dart';

class DrawerWid extends StatefulWidget {
  DrawerWid({Key key, this.onClose}) : super(key: key);
  Function onClose;
  @override
  DrawerWidState createState() => DrawerWidState();
}

class DrawerWidState extends State<DrawerWid> {
  PrintReceipt printKOT = PrintReceipt();
  List<Printer> printerreceiptList = new List<Printer>();
  var permissions = "";
  bool isShiftOpen = true;
  var userDetails;
  @override
  void initState() {
    super.initState();
    checkshift();
    setPermissons();
    getUserData();
    getAllPrinter();
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  getUserData() async {
    var user = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (user != null) {
      user = json.decode(user);
      setState(() {
        userDetails = user;
      });
    }
  }

  gotoTansactionPage() {
    if (isShiftOpen) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.TransactionScreen).then(backEvent);
    } else {
      CommunFun.showToast(context, Strings.shift_opne_alert_msg_transaction);
    }
  }

  backEvent(val) {
    widget.onClose();
  }

  checkshift() async {
    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    setState(() {
      isShiftOpen = isOpen != null && isOpen == "true" ? true : false;
    });
  }

  gotoWebCart() {
    if (isShiftOpen) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.WebOrderPages).then(backEvent);
    } else {
      CommunFun.showToast(context, Strings.shift_opne_alert_msg_webOrder);
    }
  }

  gotoWineStorage() {
    if (isShiftOpen) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.WineStorage).then(backEvent);
    } else {
      CommunFun.showToast(context, Strings.shift_opne_alert_wineStorage);
    }
  }

  getAllPrinter() async {
    List<Printer> printerDraft = await localAPI.getAllPrinterForecipt();
    setState(() {
      printerreceiptList = printerDraft;
    });
  }

  closeShift(context) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return CloseShiftPage(onClose: () {
            Navigator.of(context).pop();
            printKOT.testReceiptPrint(
                printerreceiptList[0].printerIp.toString(),
                context,
                "",
                Strings.openDrawer);
            openOpningAmmountPop(context, Strings.title_closing_amount);
          });
        });
  }

  openOpningAmmountPop(context, isopning) async {
    await showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: isopning,
              onEnter: (ammountext) {
                sendOpenShft(ammountext);
                if (isopning == Strings.title_opening_amount) {
                  if (printerreceiptList.length > 0) {
                    printKOT.testReceiptPrint(
                        printerreceiptList[0].printerIp.toString(),
                        context,
                        "",
                        Strings.openDrawer);
                  } else {
                    CommunFun.showToast(context, Strings.printer_not_available);
                  }
                }
              });
        });
  }

  sendOpenShft(ammount) async {
    setState(() {
      isShiftOpen = true;
    });
    Preferences.setStringToSF(Constant.IS_SHIFT_OPEN, isShiftOpen.toString());
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    User userdata = await CommunFun.getuserDetails();
    Shift shift = new Shift();

    int appid = await localAPI.getLastShiftAppID(terminalId);
    if (shiftid == null && appid != 0) {
      shift.appId = appid + 1;
    } else {
      shift.appId = shiftid == null ? 1 : int.parse(shiftid);
    }
    shift.terminalId = int.parse(terminalId);
    shift.branchId = int.parse(branchid);
    shift.userId = userdata.id;
    shift.uuid = await CommunFun.getLocalID();
    shift.status = 1;
    shift.serverId = 0;
    if (shiftid == null) {
      shift.startAmount = int.parse(ammount);
      shift.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    } else {
      shift.endAmount = int.parse(ammount);
      shift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    shift.updatedBy = userdata.id;
    var result = await localAPI.insertShift(shift, shiftid);
    if (shiftid == null) {
      await Preferences.setStringToSF(Constant.DASH_SHIFT, result.toString());
    } else {
      await Preferences.removeSinglePref(Constant.DASH_SHIFT);
      await Preferences.removeSinglePref(Constant.IS_SHIFT_OPEN);
      await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
      await CommunFun.printShiftReportData(
          printerreceiptList[0].printerIp.toString(),
          context,
          shiftid,
          permissions);
    }
    checkshift();
    await Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false});
  }

  gotoShiftReport() {
    if (isShiftOpen) {
      if (permissions.contains(Constant.VIEW_SHIFT)) {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, Constant.ShiftOrders).then(backEvent);
      } else {
        CommonUtils.openPermissionPop(context, Constant.VIEW_SHIFT, () async {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, Constant.ShiftOrders).then(backEvent);
        }, () {});
      }
    } else {
      CommunFun.showToast(context, Strings.shift_opne_alert_msg);
    }
  }

  syncOrdersTodatabase() async {
    if (permissions.contains(Constant.SYNC_ORDER)) {
      await CommunFun.opneSyncPop(context);
      await CommunFun.syncOrdersANDStore(context, true);
    } else {
      await CommonUtils.openPermissionPop(context, Constant.SYNC_ORDER,
          () async {
        await CommunFun.opneSyncPop(context);
        await CommunFun.syncOrdersANDStore(context, true);
      }, () {});
    }
  }

  syncAllTables() async {
    //Navigator.of(context).pop();
    if (permissions.contains(Constant.VIEW_SYNC)) {
      await Preferences.removeSinglePref(Constant.LastSync_Table);
      await Preferences.removeSinglePref(Constant.OFFSET);
      await CommunFun.opneSyncPop(context);
      await CommunFun.syncOrdersANDStore(context, false);
      await CommunFun.syncAfterSuccess(context, false);
    } else {
      await CommonUtils.openPermissionPop(context, Constant.VIEW_SYNC,
          () async {
        await Preferences.removeSinglePref(Constant.LastSync_Table);
        await Preferences.removeSinglePref(Constant.OFFSET);
        await CommunFun.opneSyncPop(context);
        await CommunFun.syncOrdersANDStore(context, false);
        await CommunFun.syncAfterSuccess(context, false);
      }, () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: MediaQuery.of(context).size.width / 3.2,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(
        top: 20,
      ),
      color: Colors.white,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                checkoutbtn(),
                SizedBox(width: SizeConfig.safeBlockVertical * 3),
                nameBtn()
              ],
            ),
            CommunFun.divider(),
            ListTile(
              onTap: () {
                gotoTansactionPage();
              },
              leading: Icon(
                Icons.art_track,
                color: Colors.black,
                size: SizeConfig.safeBlockVertical * 5,
              ),
              title: Text(
                Strings.transaction,
                style: Styles.drawerText(),
              ),
            ),
            ListTile(
              onTap: () {
                gotoWebCart();
              },
              leading: Icon(
                Icons.shopping_cart,
                color: Colors.black,
                size: SizeConfig.safeBlockVertical * 5,
              ),
              title: Text(
                Strings.web_orders,
                style: Styles.drawerText(),
              ),
            ),
            ListTile(
              onTap: () {
                gotoWineStorage();
              },
              leading: Icon(
                Icons.local_bar,
                color: Colors.black,
                size: SizeConfig.safeBlockVertical * 5,
              ),
              title: Text(
                Strings.wineStorage,
                style: Styles.drawerText(),
              ),
            ),
            ListTile(
                onTap: () {
                  if (isShiftOpen) {
                    if (permissions.contains(Constant.CLOSE_SHIFT)) {
                      closeShift(context);
                    } else {
                      CommonUtils.openPermissionPop(
                          context, Constant.CLOSE_SHIFT, () async {
                        closeShift(context);
                      }, () {});
                    }
                  } else {
                    if (permissions.contains(Constant.OPEN_SHIFT)) {
                      openOpningAmmountPop(
                          context, Strings.title_opening_amount);
                    } else {
                      CommonUtils.openPermissionPop(
                          context, Constant.OPEN_SHIFT, () async {
                        openOpningAmmountPop(
                            context, Strings.title_opening_amount);
                      }, () {});
                    }
                  }
                },
                leading: Icon(
                  Icons.open_in_new,
                  color: Colors.black,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                title: Text(
                    isShiftOpen ? Strings.close_shift : Strings.opne_shift,
                    style: Styles.drawerText())),
            // permissions.contains(Constant.VIEW_REPORT)
            //     ?
            ListTile(
              onTap: () {
                gotoShiftReport();
              },
              leading: Icon(
                Icons.filter_tilt_shift,
                color: Colors.black,
                size: SizeConfig.safeBlockVertical * 5,
              ),
              title: Text(
                Strings.shift_Report,
                style: Styles.drawerText(),
              ),
            ),
            //: SizedBox(),,
            // permissions.contains(Constant.VIEW_ORDER)
            ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  syncOrdersTodatabase();
                },
                leading: Icon(
                  Icons.transform,
                  color: Colors.black,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                title: Text(Strings.sync_orders, style: Styles.drawerText())),
            // : SizedBox(),
            ListTile(
                onTap: () async {
                  syncAllTables();
                },
                leading: Icon(
                  Icons.sync,
                  color: Colors.black,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                title: Text(Strings.sync, style: Styles.drawerText())),
            ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, Constant.SettingsScreen)
                      .then(backEvent);
                },
                leading: Icon(
                  Icons.settings,
                  color: Colors.black,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                title: Text(Strings.settings, style: Styles.drawerText())),
          ],
        ),
      ),
    );
  }

  Widget checkoutbtn() {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.all(10),
        onPressed: () {
          Navigator.pushNamed(context, Constant.PINScreen).then(backEvent);
        },
        child: Text(Strings.checkout, style: Styles.whiteBoldsmall()),
        color: Colors.deepOrange,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  Widget nameBtn() {
    return Expanded(
        child: RaisedButton(
      padding: EdgeInsets.all(10),
      onPressed: () {
        //Navigator.pushNamed(context, Constant.PINScreen).then(backEvent);
      },
      child: Text(
        userDetails != null ? userDetails["name"] : "",
        style: Styles.whiteBoldsmall(),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ));
  }
}
