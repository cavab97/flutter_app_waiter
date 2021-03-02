import 'dart:async';
import 'dart:convert';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/Reservation.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:toast/toast.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

DatabaseHelper databaseHelper = DatabaseHelper();
LocalAPI localAPI = LocalAPI();
Timer timer;
double taxvalues = 0;

class CommunFun {
  static loginText() {
    return Text(Strings.loginText,
        style: TextStyle(
            color: StaticColor.colorWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold));
  }

  static verticalSpace(double val) {
    return SizedBox(
      height: val,
    );
  }

  static horisontalSpace(double val) {
    return SizedBox(
      width: val,
    );
  }

  static checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static isLogged() async {
    var loginUser = await localAPI.getShift();//Preferences.getStringValuesSF(Constant.IS_LOGIN);
    if (loginUser != null) {
      return true;
    } else {
      return false;
    }
  }

  static overLayLoader() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: StaticColor.colorWhite),
      child: CircularProgressIndicator(
        strokeWidth: 4,
        backgroundColor: StaticColor.lightGrey,
      ),
    );
  }

  static divider() {
    // Simple divider
    return Padding(
      padding: EdgeInsets.all(10),
      child: Divider(
        height: 1,
        thickness: 1.0,
        color: Colors.grey[400],
      ),
    );
  }

  static forgotPasswordText(context) {
    // forgot password text
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Text(
        Strings.forgotPassword,
        style: TextStyle(color: Colors.blue, fontSize: 22),
      ),
    );
  }

  static roundedButton(text, BuildContext context, _onPress) {
    SizeConfig().init(context);

    //round button like Login button
    return RaisedButton(
      padding: EdgeInsets.only(
          top: SizeConfig.safeBlockVertical * 3,
          bottom: SizeConfig.safeBlockVertical * 3),
      onPressed: _onPress,
      child: Text(text, style: Styles.whiteBold()),
      color: StaticColor.deepOrange,
      textColor: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  static searchBar(onChange) {
    // search input
    TextField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: Icon(
            Icons.search,
            color: Colors.deepOrange,
            size: 40,
          ),
        ),
        hintText: "Search product here...",
        hintStyle: TextStyle(fontSize: 25.0, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(top: 25, bottom: 25),
        fillColor: Colors.white,
      ),
      style: TextStyle(color: Colors.black, fontSize: 25.0),
      onChanged: (e) {
        print(e);
      },
    );
  }

  /*Cal Service Charge*/
  static Future<double> countServiceCharge(serviceCharge, subtotal) async {
    if (serviceCharge == null) {
      var branchid = await getbranchId();
      Branch branchData = await localAPI.getbranchData();
      serviceCharge = branchData.serviceCharge;
    }
    // else if (service_charge < 0) {
    //   var branchid = await getbranchId();
    //   Branch branchData = await localAPI.getBranchData(branchid);
    //   service_charge = branchData.serviceCharge;
    // }

    if (serviceCharge != null) {
      return subtotal * serviceCharge / 100;
    } else {
      return 0.00;
    }
  }

  /*get Service Percentage*/
  static getServiceChargePer() async {
    var branchID = await getbranchId();
    Branch branchData = await localAPI.getbranchData();
    var serviceCharge = branchData.serviceCharge;
    if (serviceCharge != null) {
      return serviceCharge;
    } else {
      return 0;
    }
  }

  static getDoubleValue(var value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    } else {
      return value;
    }
  }

  static getTextAndSplit(String value) {
    // var maximumLength = 32;
    // var total = value.length;
    // var totalParagraph = total / 32;
    // var arr = value.split('');

    // var completeWord = List.from(arr);
    // print(arr);
    // for (int i = 4; i < arr.length; i++) {
    //   print((i + 1) % 32);

    //   if ((i + 1) % 36 == 1 || (i + 1) % 36 == 2 || (i + 1) % 36 == 3) {
    //     completeWord.insert(i, " ");
    //   }
    // }

    // String paragraph = completeWord.join();

    return value;
  }

  static getDecimalFormat(String value) {
    /* var s1 = value.replaceAll(".", "");
    s1 = "000" + s1;
    var position = s1.length - 2;
    var output =
        [s1.substring(0, position), ".", s1.substring(position)].join(""); */

    return double.tryParse(value).toStringAsFixed(2);
  }

  static deviceInfo() async {
    // Device Info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceData;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          "deviceId": androidInfo.device,
          "deviceToken": androidInfo.androidId,
          "deviceType": androidInfo.type
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          "deviceId": iosInfo.identifierForVendor,
          "deviceToken": iosInfo.utsname.machine,
          "deviceType": iosInfo.name
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return deviceData;
  }

  static loader(context) {
    // basic Loader
    return Center(
      child: Container(
        height: 50.0,
        width: 50.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
        ),
      ),
    );
  }

  static showToast(context, message) {
    try {
      //Navigator.of(context).pop();
      Toast.show(
        message,
        context,
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } catch (e) {
      print(e);
    }
  }

  static syncDailog(context, title) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        content: Builder(
          builder: (context) {
            return Container(
              height: 150,
              width: 150,
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CommunFun.loader(context),
                  SizedBox(
                    height: 30,
                  ),
                  Text(title, style: Styles.normalBlack())
                ],
              )),
            );
          },
        ));
  }

  static openSyncPop(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return syncDailog(context, Strings.syncText);
      },
    );
  }

  static compareandUpdateTable(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionString =
        packageInfo.version.split(" ")[0] + '+' + packageInfo.buildNumber;
    var result = await Preferences.getStringValuesSF(Constant.lastAppVersion);
    String lastAppVersion = result ?? "";
    if (lastAppVersion == versionString) return;
    List<Map<String, String>> updateTableMaps =
        await SyncAPICalls.getCompareTableQuery(context, versionString);
    int excuted = 0;
    int gotError = 0;
    for (Map<String, String> tableObject in updateTableMaps) {
      print("update table : " + tableObject['table_name']);
      excuted = await databaseHelper.runQuery(tableObject["delete"]);
      excuted = await databaseHelper.runQuery(tableObject["create"]);
      //await databaseHelper.getTableExist(tableObject['table_name']);
      if (excuted == 1) {
        print("update table : " + tableObject['table_name'] + ' Success');
        List<Map<String, dynamic>> dataList =
            await SyncAPICalls.getTableData(context, tableObject['table_name']);
        List result = [];
        if (tableObject['table_name'] == "users") {
          print('update users');
        }
        String text = "update " +
            dataList.length.toString() +
            " records to table " +
            tableObject['table_name'];

        await SyncAPICalls.logActivity("update Database", text, "sync", 1);
        if (dataList != null && dataList.length > 0) {
          for (Map<String, dynamic> data in dataList) {
            result.add(await databaseHelper.insertData(
                tableObject['table_name'], data));
          }
        }
        print(result);
      } else {
        gotError = 1;
        print("update table : " + tableObject['table_name'] + ' Failed');
      }
    }
    if (gotError == 0) {
      Preferences.setStringToSF(Constant.lastAppVersion, versionString);
    } else {
      Preferences.removeSinglePref(Constant.lastAppVersion);
    }
  }

  static syncOrdersANDStore(context, isClose) async {
    await compareandUpdateTable(context);
    await CommunFun.getsetWebOrders(context);
    await SyncAPICalls.sendCustomerTable(context);
    await SyncAPICalls.syncOrderstoDatabase(context);
    await SyncAPICalls.sendInvenotryTable(context);
    await SyncAPICalls.sendCustomerWineInventory(context);
    await SyncAPICalls.sendCancledOrderTable(context);
    await SyncAPICalls.sendTerminalLogTable(context);
    await SyncAPICalls.sendShiftTable(context);
    await SyncAPICalls.sendShiftdetails(context);

    await CommunFun.syncAfterSuccess(context, false);
    if (isClose && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static syncAfterSuccess(context, isOpen) async {
    if (isOpen) {
      openSyncPop(context);
    }
    var lastSync = await Preferences.getStringValuesSF(Constant.LastSync_Table);
    if (context == null) {
      return;
    } else if (lastSync == null) {
      CommunFun.getDataTables1(context, isOpen);
    } else if (lastSync == "1") {
      CommunFun.getDataTables2(context, isOpen);
    } else if (lastSync == "2") {
      CommunFun.getDataTables3(context, isOpen);
    } else if (lastSync == "3") {
      CommunFun.getDataTables4(context, isOpen);
    } else if (lastSync == "4") {
      CommunFun.getDataTables5(context, isOpen);
    } else {
      Navigator.of(context).pop();
      Navigator.pushNamedAndRemoveUntil(
          context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
          arguments: {"isAssign": false});
    }
  }

  static setServerTime(data, lastSync) async {
    if (data != null) {
      await Preferences.setStringToSF(
          Constant.SERVER_TIME_ZONE, data["data"]["timezone"]);
      await Preferences.setStringToSF(
          Constant.SERVER_DATE_TIME, data["data"]["serverdatetime"]);
    }
    await Preferences.setStringToSF(Constant.LastSync_Table, lastSync);
  }

  static getDataTables1(context, isOpen) async {
    // start with 1 tables
    var data1 = await SyncAPICalls.getDataServerBulk1(context); //api call 1
    if (data1 != null) {
      databaseHelper.insertData1(data1["data"]);
      CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data2_1 =
        await SyncAPICalls.getDataServerBulk2_1(context); //api call 2_1
    if (data2_1 != null) {
      databaseHelper.insertData2_1(data2_1["data"]);
      CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data2_2 =
        await SyncAPICalls.getDataServerBulk2_2(context); //api call 2_2
    if (data2_2 != null) {
      databaseHelper.insertData2_2(data2_2["data"]);
      CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data2_3 =
        await SyncAPICalls.getDataServerBulk2_3(context); //api call 2_3
    if (data2_3 != null) {
      databaseHelper.insertData2_3(data2_3["data"]);
      CommunFun.setServerTime(null, "2");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data3 = await SyncAPICalls.getDataServerBulk3(context); // call 3
    if (data3 != null) {
      databaseHelper.insertData3(data3["data"]);
      CommunFun.setServerTime(null, "3");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data4_1 = await SyncAPICalls.getDataServerBulk4_1(context);
    if (data4_1 != null) {
      databaseHelper.insertData4_1(data4_1["data"]);
      CommunFun.setServerTime(null, "4");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data4_2 = await SyncAPICalls.getDataServerBulk4_2(context);
    if (data4_2 != null) {
      var result = await databaseHelper.insertData4_2(data4_2["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting data4_3");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var wineStorageData = await SyncAPICalls.getWineStorageData(context);
    if (wineStorageData != null) {
      var result =
          await databaseHelper.insertWineStoragedata(wineStorageData["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting wine storage data.");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    getAssetsData(context, isOpen);
  }

  static getAssetsData(context, isOpen) async {
    var offset = await CommunFun.getOffset();
    var aceets = await SyncAPICalls.getAssets(context);
    if (aceets != null && aceets["status"] is int && aceets["status"] == 500) {
      print("Error when getting product image data");
      await checkUserDeleted(context);
      await checkpermission();
      await Navigator.pushNamed(context, Constant.SelectTableScreen,
          arguments: {"isAssign": false});
      isOpen = false;
    } else if (aceets != null) {
      await databaseHelper.accetsData(aceets["data"]);
      await Preferences.setStringToSF(
          Constant.OFFSET, aceets["data"]["next_offset"].toString());
      //print assets product image
      //print(aceets["data"]["product_image"]);
      if (offset == null) {
        if (aceets["data"]["next_offset"] != 0) {
          getAssetsData(context, isOpen);
        }
        var serverTime =
            await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
        if (serverTime == null) {
          Navigator.popAndPushNamed(context, Constant.PINScreen);
        } else {
          await checkUserDeleted(context);
          await checkpermission();
          await Navigator.popAndPushNamed(context, Constant.SelectTableScreen,
              arguments: {"isAssign": false});
          isOpen = false;
        }
        /* if (isOpen) {
          Navigator.of(context).pop();
        } */
      } else {
        if (aceets["data"]["next_offset"] == 0) {
          await CommunFun.setServerTime(aceets, "5");
        } else {
          getAssetsData(context, isOpen);
        }
      }
    } else {
      // handle Exaption
      print("Error when getting product image data");
      print("Error when getting product image data");
      await checkUserDeleted(context);
      await checkpermission();
      await Navigator.pushNamed(context, Constant.SelectTableScreen,
          arguments: {"isAssign": false});
      isOpen = false;
    }
  }

  static checkpermission() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var user = json.decode(loginUser);
    var id = user["id"];
    await checkUserPermission(id);
  }

  static checkUserDeleted(context) async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var user = json.decode(loginUser);
    var pin = user["user_pin"];
    List<User> checkUserExit = await localAPI.checkUserExit(pin);
    if (checkUserExit.length == 0) {
      checkoutMenualy(context, user["id"]);
    }
  }

  static checkoutMenualy(context, id) async {
    CheckinOut checkIn = new CheckinOut();
    var shiftid = await Preferences.getStringValuesSF(Constant.SHIFT_ID);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var date = DateTime.now();
    checkIn.id = int.parse(shiftid);
    checkIn.localID = await CommunFun.getLocalID();
    checkIn.terminalId = int.parse(terminalId);
    checkIn.userId = id;
    checkIn.branchId = int.parse(branchid);
    checkIn.status = "OUT";
    checkIn.timeInOut = date.toString();
    checkIn.sync = 0;
    await localAPI.userCheckInOut(checkIn);
    clearAfterCheckout(context);
    CommunFun.showToast(context, "User deleted from database.");
  }

  static clearAfterCheckout(context) async {
    await Preferences.removeSinglePref(Constant.IS_CHECKIN);
    await Preferences.removeSinglePref(Constant.SHIFT_ID);
    await Preferences.removeSinglePref(Constant.LOIGN_USER);
    await Preferences.removeSinglePref(Constant.USER_PERMISSION);
    await Navigator.pushNamed(context, Constant.PINScreen);
  }

  static getDataTables2(context, isOpen) async {
    // start api call fron second api
    var data2_1 =
        await SyncAPICalls.getDataServerBulk2_1(context); //api call 2_1
    if (data2_1 != null) {
      databaseHelper.insertData2_1(data2_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data2_1");
    }
    var data2_2 =
        await SyncAPICalls.getDataServerBulk2_2(context); //api call 2_2
    if (data2_2 != null) {
      databaseHelper.insertData2_2(data2_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data2_2");
    }
    var data2_3 =
        await SyncAPICalls.getDataServerBulk2_3(context); //api call 2_3
    if (data2_3 != null) {
      databaseHelper.insertData2_3(data2_3["data"]);
    } else {
      // handle Exaption
      print("Error when getting data2_3");
    }
    var data3 = await SyncAPICalls.getDataServerBulk3(context); //api call 3
    if (data3 != null) {
      databaseHelper.insertData3(data3["data"]);
    } else {
      // handle Exaption
      print("Error when getting data3");
    }
    var data4_1 =
        await SyncAPICalls.getDataServerBulk4_1(context); //api call 4_1
    if (data4_1 != null) {
      databaseHelper.insertData4_1(data4_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_1");
    }
    var data4_2 =
        await SyncAPICalls.getDataServerBulk4_2(context); //api call 4_2
    if (data4_2 != null) {
      var result = await databaseHelper.insertData4_2(data4_2["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting bulk4_2");
      }
    } else {
      // handle Exaption
      print("Error when getting data4_2");
    }
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var wineStorageData = await SyncAPICalls.getWineStorageData(context);
    if (wineStorageData != null) {
      print('getwineStorageData');
      var result =
          await databaseHelper.insertWineStoragedata(wineStorageData["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting wine storage data.");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    getAssetsData(context, isOpen);
  }

  static getDataTables3(context, isOpen) async {
    var data3 = await SyncAPICalls.getDataServerBulk3(context); // call from  3
    if (data3 != null) {
      databaseHelper.insertData3(data3["data"]);
    } else {
      // handle Exaption
      print("Error when getting data3");
    }

    var data4_1 =
        await SyncAPICalls.getDataServerBulk4_1(context); //api call 4_1
    if (data4_1 != null) {
      databaseHelper.insertData3(data4_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_1");
    }
    var data4_2 =
        await SyncAPICalls.getDataServerBulk4_2(context); //api call 4_2
    if (data4_2 != null) {
      databaseHelper.insertData4_2(data4_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_2");
    }
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var wineStorageData = await SyncAPICalls.getWineStorageData(context);
    if (wineStorageData != null) {
      print('getDataTables689');
      var result =
          await databaseHelper.insertWineStoragedata(wineStorageData["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting wine storage data.");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    getAssetsData(context, isOpen);
  }

  static getDataTables4(context, isOpen) async {
    //start from tables 4 API calls
    var data4_1 =
        await SyncAPICalls.getDataServerBulk4_1(context); //api call 4_1
    if (data4_1 != null) {
      databaseHelper.insertData4_1(data4_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_1");
    }
    var data4_2 =
        await SyncAPICalls.getDataServerBulk4_2(context); //api call 4_2
    if (data4_2 != null) {
      databaseHelper.insertData4_2(data4_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_2");
    }
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print('counry state city' + result);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var wineStorageData = await SyncAPICalls.getWineStorageData(context);
    if (wineStorageData != null) {
      print('getDataTables735');
      var result =
          await databaseHelper.insertWineStoragedata(wineStorageData["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting wine storage data.");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    getAssetsData(context, isOpen);
  }

  static getDataTables5(context, isOpen) async {
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var wineStorageData = await SyncAPICalls.getWineStorageData(context);
    if (wineStorageData != null) {
      print('getDataTables5');
      var result =
          await databaseHelper.insertWineStoragedata(wineStorageData["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "5");
      } else {
        print("Error when getting wine storage data.");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    getAssetsData(context, isOpen);
  }

  static checkDatabaseExit() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    if (db != null) {
      return true;
    } else {
      return false;
    }
  }

  static getTeminalKey() async {
    var terminalId = await localAPI.getTerminalKey();

    return terminalId;
  }

  static getbranchId() async {
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    return branchid;
  }

  static getCustomerData() async {
    Customer customer = new Customer();
    var localdata = await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    if (localdata != null) {
      var custData = json.decode(localdata);
      return customer = Customer.fromJson(custData);
    } else {
      return customer;
    }
  }

  static getTableData() async {
    Table_order table = new Table_order();
    var localdata = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (localdata != null) {
      var tableData = json.decode(localdata);
      return table = Table_order.fromJson(tableData);
    } else {
      return table;
    }
  }

  static getOffset() async {
    var offset = await Preferences.getStringValuesSF(Constant.OFFSET);
    return offset;
  }

  static getCurrentDateTime(DateTime dateTime) async {
    tz.initializeTimeZones();
    //converttoserver tiem
    var timeZone =
        await Preferences.getStringValuesSF(Constant.SERVER_TIME_ZONE);
    //print(timeZone);
    if (timeZone != null) {
      final detroitTime =
          new tz.TZDateTime.from(dateTime, tz.getLocation(timeZone));
      // print('Local India Time: ' + dateTime.toString());
      // print('Detroit Time: ' + detroitTime.toString());
      // DateTime serverDate = DateTime.parse(detroitTime.toString());
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(detroitTime);
      //print(formattedDate);
      return formattedDate;
    } else {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return formattedDate.toString();
    }
  }

  static getLocalID() async {
    var deviceInfo = await CommunFun.deviceInfo();
    var terminalId = await CommunFun.getTeminalKey();
    var localid = Platform.isAndroid
        ? "ANDROID" + deviceInfo["deviceId"] + terminalId
        : "IOS" + deviceInfo["deviceId"] + terminalId;
    return localid.toString();
  }

  static getuserDetails() async {
    User user = new User();
    var users = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (users != null) {
      var user1 = json.decode(users);
      return user = User.fromJson(user1);
    } else {
      return user;
    }
  }

  static processingPopup(context) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            content: Builder(
              builder: (context) {
                return Container(
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CommunFun.loader(context),
                      SizedBox(
                        height: 30,
                      ),
                      Text(Strings.procesing, style: TextStyle(fontSize: 30))
                    ],
                  )),
                );
              },
            ),
          );
        });
  }

  static savewebOrdersintoCart(cartdata) async {
    LocalAPI localAPI = LocalAPI();
    for (var i = 0; i < cartdata.length; i++) {
      var cart = cartdata[i];
      var cartdataitem = {
        "id": cart["cart_id"],
        "localID": cart["localID"],
        "user_id": cart["user_id"],
        "branch_id": cart["branch_id"],
        "sub_total": cart["sub_total"],
        "discount": cart["discount"],
        "discount_type": cart["discount_type"],
        "remark": cart["remark"],
        "tax": cart["tax"],
        "tax_json": cart["tax_json"],
        "voucher_id": cart["voucher_id"],
        "grand_total": cart["grand_total"],
        "total_qty": cart["total_qty"],
        "is_deleted": cart["is_deleted"],
        "created_by": cart["created_by"],
        "created_at": cart["created_at"],
        "customer_terminal": cart["customer_terminal"],
        "voucher_detail": cart["voucher_detail"],
        "sub_total_after_discount": cart["sub_total_after_discount"],
        "source": cart["source"],
        "total_item": cart["total_item"],
        "cart_payment_id": cart["cart_payment_id"],
        "cart_payment_response": cart["cart_payment_response"],
        "cart_payment_status": cart["cart_payment_status"],
      };
      var cartJson = MST_Cart.fromJson(cartdataitem);

      var detaildata = cart["cart_detail"];
      for (var j = 0; j < detaildata.length; j++) {
        var detailitem = detaildata[j];
        var cartDeatils = {
          "id": detailitem["cart_detail_id"],
          "cart_id": detailitem["cart_id"],
          "localID": detailitem["localID"],
          "product_id": detailitem["product_id"],
          "printer_id": detailitem["printer_id"],
          "product_name": detailitem["product_name"],
          "product_price": detailitem["product_price"],
          "product_detail_amount":
              (detailitem["product_price"] * detailitem["product_qty"]),
          "product_qty": detailitem["product_qty"],
          "product_net_price": detailitem["product_net_price"],
          "tax_id": detailitem["tax_id"],
          "tax_value": detailitem["tax_value"],
          "discount": detailitem["discount"],
          "discount_type": detailitem["discount_type"],
          "remark": detailitem["remark"],
          "is_deleted": detailitem["is_deleted"],
          "is_send_kichen": detailitem["is_send_kichen"],
          "cart_detail": detailitem["product_detail"],
          "issetMeal": detailitem["issetMeal"],
          "setmeal_product_detail": cart["setmeal_product_detail"],
          "has_composite_inventory": detailitem["has_composite_inventory"],
          "item_unit": detailitem["item_unit"],
          "created_by": detailitem["created_by"],
          "created_at": detailitem["created_at"]
        };
        var cartdetailJson = MSTCartdetails.fromJson(cartDeatils);

        await localAPI.updateWebCartdetails(cartdetailJson);
        var cartSubData = detailitem["cart_sub_detail"];
        for (var p = 0; p < cartSubData.length; p++) {
          var subdetailitem = cartSubData[p];
          var subdata = {
            "id": subdetailitem["csd_id"],
            "cart_details_id": subdetailitem["cart_detail_id"],
            "localID": subdetailitem["localID"],
            "product_id": subdetailitem["product_id"],
            "modifier_id": subdetailitem["modifier_id"],
            "modifier_price": subdetailitem["modifier_price"],
            "ca_id": subdetailitem["ca_id"],
            "attr_price": subdetailitem["attribute_price"],
          };
          var subjson = MSTSubCartdetails.fromJson(subdata);
          await localAPI.updateWebCartsubdetails(subjson);
        }
      }

      // Insert cart json
      await localAPI.updateWebCart(cartJson);
    }
  }

  static checkUserPermission(userid) async {
    LocalAPI localAPI = LocalAPI();
    List<PosPermission> permissions = await localAPI.getUserPermissions(userid);
    if (permissions.length > 0) {
      if (permissions[0].posPermissionName != null) {
        await Preferences.setStringToSF(
            Constant.USER_PERMISSION, permissions[0].posPermissionName);
      } else {
        await Preferences.removeSinglePref(Constant.USER_PERMISSION);
      }
    } else {
      await Preferences.removeSinglePref(Constant.USER_PERMISSION);
    }
  }

  static Future<String> getPemission() async {
    var permission =
        await Preferences.getStringValuesSF(Constant.USER_PERMISSION);
    if (permission != null) {
      return permission;
    } else {
      print("permission empty");
      return "";
    }
  }

  static autosyncAllTables(context) async {
    await getsetWebOrders(context);
    await SyncAPICalls.syncOrderstoDatabase(context);
    await SyncAPICalls.sendCancledOrderTable(context);
    await SyncAPICalls.sendInvenotryTable(context);
    await SyncAPICalls.sendCustomerWineInventory(context);
    await Preferences.removeSinglePref(Constant.LastSync_Table);
    await Preferences.removeSinglePref(Constant.OFFSET);
    await CommunFun.syncAfterSuccess(context, false);

    print(DateTime.now());
  }

  static getsetWebOrders(context) async {
    var res = await SyncAPICalls.getWebOrders(context);
    if (res != null && res.length < 1 || res["data"] == null) {
      print('getsetWebOrders api error');
      return;
    } else if (res == null) {
      print('get web orders response null');
    }
    var sertvertime = res["data"]["serverdatetime"];
    await Preferences.setStringToSF(
        Constant.ORDER_SERVER_DATE_TIME, sertvertime);
    var cartdata = res["data"]["cart"];
    await CommunFun.savewebOrdersintoCart(cartdata);
  }

  static checkisAutoSync(context) async {
    var isSync = await Preferences.getStringValuesSF(Constant.IS_AUTO_SYNC);
    if (isSync != null) {
      print(isSync);
      if (isSync == "true") {
        startAutosync(context);
      }
    }
  }

  static startAutosync(context) async {
    int timertime = 1;
    var isSynctimer = await Preferences.getStringValuesSF(Constant.SYNC_TIMER);
    if (isSynctimer != null && isSynctimer != "") {
      timertime = int.parse(isSynctimer);
    }
    print("++++++++++++++++++++++++++++++++++++");
    print(timertime);
    var _inactivityTimeout = Duration(minutes: timertime);
    timer =
        Timer(_inactivityTimeout, () => CommunFun.autosyncAllTables(context));
  }

  static stopAutoSync() {
    timer?.cancel();
  }

  static countTotalQty(List<MSTCartdetails> cartItems, productItem,
      [productQty = 1.0]) {
    double qty = 0;
    if (cartItems.length > 0) {
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        /* if (item.productId == productItem.productId) {
          item.productQty = productQty;
        } */
        qty += item.productQty;
      }
    } else {
      qty += productQty;
    }
    return qty;
  }

  static countSubtotal(List<MSTCartdetails> cartItems, price) {
    double subT = 0;
    if (cartItems.length > 0) {
      double selectedITemTotal = 0;
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        selectedITemTotal += item.productDetailAmount;
      }
      subT = selectedITemTotal + price;
    } else {
      subT += price;
    }
    return subT;
  }

  static countGrandtotal(subt, serviceCharge, tax, dis) {
    double grandTotal = 0;
    grandTotal = ((subt - dis) + serviceCharge + tax);
    return grandTotal;
  }

  static getTaxs() async {
    var branchid = await CommunFun.getbranchId();
    List<BranchTax> taxlists = await localAPI.getTaxList();
    return taxlists;
  }

  static countTax(subT) async {
    var taxlist = await CommunFun.getTaxs();
    var totalTax = [];
    double taxvalue = taxvalues;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        List<Tax> tax = await localAPI.getTaxName(taxlistitem.taxId);
        var taxval = taxlistitem.rate != null
            ? subT * double.parse(taxlistitem.rate) / 100
            : 0.0;
        taxval = double.parse(taxval.toStringAsFixed(2));
        taxvalue += taxval;
        taxvalues = taxvalue;
        var taxmap = {
          "id": taxlistitem.id,
          "tax_id": taxlistitem.taxId,
          "branch_id": taxlistitem.branchId,
          "rate": taxlistitem.rate,
          "status": taxlistitem.status,
          "updated_at": taxlistitem.updatedAt,
          "updated_by": taxlistitem.updatedBy,
          "taxAmount": taxval.toStringAsFixed(2),
          "taxCode": tax.length > 0 ? tax[0].code : "" //tax.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  static countDiscount(MST_Cart currentCart) {
    return currentCart != null && currentCart.discountAmount != null
        ? double.parse(currentCart.discountAmount.toStringAsFixed(2))
        : 0.00;
  }

  static getPrinter(productItem) async {
    Printer printer = new Printer();
    List<Printer> printerlist =
        await localAPI.getPrinter(productItem.productId.toString());
    if (printerlist.length > 0) {
      printer = printerlist[0];
    }
    return printer;
  }

  static addItemToCart(productItem, List<MSTCartdetails> cartItems,
      MST_Cart allcartData, callback, context) async {
    taxvalues = 0;
    MST_Cart cart = new MST_Cart();
    SaveOrder orderData = new SaveOrder();
    var branchid = await CommunFun.getbranchId();
    Table_order table = await CommunFun.getTableData();
    Customer customerData = await CommunFun.getCustomerData();
    User loginUser = await CommunFun.getuserDetails();
    Printer printer = await CommunFun.getPrinter(productItem);
    bool isEditing = false;
    MSTCartdetails sameitem;
    /* var contain = cartItems
        .where((element) => element.productId == productItem.productId);
    if (contain.isNotEmpty) {
      isEditing = true;
      var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
      List<MSTCartdetails> myModels = (json.decode(jsonString) as List)
          .map((i) => MSTCartdetails.fromJson(i))
          .toList();
      sameitem = myModels[0];
    } */
    if (productItem.hasInventory == 1) {
      var qty = productItem.qty ?? 1.0;
      if (isEditing) {
        qty = sameitem.productQty + qty;
      }
      List<ProductStoreInventory> cartval =
          await localAPI.checkItemAvailableinStore(productItem.productId);
      if (cartval.length > 0) {
        double storeqty = cartval[0].qty;
        if (storeqty < qty) {
          CommunFun.showToast(context, Strings.stockNotValilable);
          callback();
          return false;
        }
      }
    }
    var qty = await CommunFun.countTotalQty(cartItems, productItem);
    var disc = await CommunFun.countDiscount(allcartData);
    var subtotal = await CommunFun.countSubtotal(cartItems, productItem.price);
    var serviceCharge =
        await CommunFun.countServiceCharge(table.service_charge, subtotal);
    var serviceChargePer = table.service_charge == null
        ? await CommunFun.getServiceChargePer()
        : table.service_charge;
    var totalTax = await CommunFun.countTax(subtotal);
    var grandTotal = await CommunFun.countGrandtotal(
        subtotal, serviceCharge, taxvalues, disc);
    cart.user_id = customerData.customerId;
    cart.branch_id = int.parse(branchid);
    cart.sub_total = double.parse(subtotal.toStringAsFixed(2));
    cart.discountAmount = disc;
    cart.serviceCharge = CommunFun.getDoubleValue(serviceCharge);
    cart.serviceChargePercent = CommunFun.getDoubleValue(serviceChargePer);
    cart.table_id = table.table_id;
    cart.discountType = allcartData != null ? allcartData.discountType : 0;
    cart.total_qty = qty;
    cart.tax = double.parse(taxvalues.toStringAsFixed(2));
    cart.source = 2;
    cart.tax_json = json.encode(totalTax);
    cart.grand_total = double.parse(grandTotal.toStringAsFixed(2));
    cart.customer_terminal = customerData != null ? customerData.terminalId : 0;
    if (!isEditing) {
      cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    cart.created_by = loginUser.id;
    cart.localID = await CommunFun.getLocalID();
    if (allcartData != null) {
      cart.voucher_detail = allcartData.voucher_detail;
      cart.voucher_id = allcartData.voucher_id;
    }
    if (!isEditing) {
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    orderData.numberofPax = table != null ? table.number_of_pax : 0;
    orderData.isTableOrder = table != null ? 1 : 0;
    var cartid = await localAPI.insertItemTocart(
        allcartData != null ? allcartData.id : null,
        cart,
        productItem,
        orderData,
        table.table_id);
    ProductDetails cartItemproduct = new ProductDetails();
    cartItemproduct.qty = productItem.qty ?? 1;
    cartItemproduct.status = productItem.status;
    cartItemproduct.productId = productItem.productId;
    cartItemproduct.name = productItem.name;
    cartItemproduct.uuid = productItem.uuid;
    cartItemproduct.price = productItem.price;
    MSTCartdetails cartdetails = new MSTCartdetails();
    if (isEditing) {
      cartdetails.id = sameitem.id;
    }
    cartdetails.cartId = cartid;
    cartdetails.productId = productItem.productId;
    cartdetails.productName = productItem.name;
    cartdetails.productSecondName = productItem.name_2;
    cartdetails.productPrice = productItem.price;
    cartdetails.productDetailAmount = isEditing
        ? double.tryParse(productItem.price.toStringAsFixed(2)) +
            sameitem.productPrice
        : (cartItemproduct.qty *
            double.tryParse(productItem.price.toStringAsFixed(2)));
    cartdetails.productQty =
        isEditing ? sameitem.productQty + 1.0 : productItem.qty ?? 1.0;
    cartdetails.productNetPrice = productItem.oldPrice;
    cartdetails.createdBy = loginUser.id;
    cartdetails.cart_detail = jsonEncode(cartItemproduct);
    cartdetails.discountAmount = isEditing ? sameitem.discountAmount : 0;
    cartdetails.remark = isEditing ? sameitem.remark : "";
    cartdetails.issetMeal = 0;
    cartdetails.hasRacManagemant = productItem.hasRacManagemant;
    cartdetails.taxValue = taxvalues;
    cartdetails.printer_id = printer != null ? printer.printerId : 0;
    cartdetails.createdAt = await CommunFun.getLocalID();
    await localAPI.addintoCartDetails(cartdetails);
    //print(detailID);
    callback(cartdetails);
  }

  static addReservationToCart(Reservation reservation, Table_order tableOrder,
      SaveOrder orderData) async {
    try {
        String branchid = await CommunFun.getbranchId();
        MST_Cart cart = new MST_Cart();
        User loginUser = await CommunFun.getuserDetails();
        Customer customer = await CommunFun.getCustomerData();
        //Customer customer = await localAPI.getCustomerData(reservation.customerID);
        List<MSTCartdetails> reservationProductList =
            await localAPI.getReservationItems(reservation.resNo);

        List<MSTSubCartdetails> subDetail =
            await localAPI.getSubDetail(reservation.resNo);
        double subTotal = 0.00;
        double qty = 0;
        for (int i = 0; i < reservationProductList.length; i++) {
          subTotal += reservationProductList[i].productDetailAmount;
          qty += reservationProductList[i].productQty;
        }
        var serviceCharge =
            await CommunFun.countServiceCharge(tableOrder.service_charge, subTotal);
        var serviceChargePer = tableOrder.service_charge == null
            ? await CommunFun.getServiceChargePer()
            : tableOrder.service_charge;
        var totalTax = await CommunFun.countTax(subTotal);
        var grandTotal =
            await CommunFun.countGrandtotal(subTotal, serviceCharge, taxvalues, 0);
        cart.user_id = customer.customerId;
        cart.branch_id = int.parse(branchid);
        cart.sub_total = subTotal;
        cart.discountAmount = 0;
        cart.serviceCharge = CommunFun.getDoubleValue(serviceCharge);
        cart.serviceChargePercent = CommunFun.getDoubleValue(serviceChargePer);
        cart.table_id = tableOrder.table_id;
        cart.discountType = 0;
        cart.total_qty = qty;
        cart.tax = double.parse(taxvalues.toStringAsFixed(2));
        cart.source = 2;
        cart.tax_json = json.encode(totalTax);
        cart.grand_total = double.parse(grandTotal.toStringAsFixed(2));
        cart.customer_terminal = customer != null ? customer.terminalId : 0;
        cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
        cart.created_by = loginUser.id;
        cart.localID = await CommunFun.getLocalID();
        int cartID = await localAPI.insertReservationToCart(cart);
        for (int i = 0; i < reservationProductList.length; i++) {
          reservationProductList[i].cartId = cartID;
          reservationProductList[i].cart_detail = jsonEncode(cart);
        }
        orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
        orderData.numberofPax = reservation.pax;
        orderData.cartId = cartID;
        await localAPI.insertSaveOrders(orderData, tableOrder.table_id);
        await localAPI.reservationToCartProduct(
          reservationProductList,
          subDetail,
          reservation.resNo,
        );
    } 
    catch (error) {
      print(error);
      rethrow;
    }
  }

  static addReservationItem(ProductDetails productItem) async {
    try {
      User loginUser = await CommunFun.getuserDetails();
      Printer printer = await CommunFun.getPrinter(productItem);
      MSTCartdetails cartdetails = new MSTCartdetails();
      cartdetails.productId = productItem.productId;
      cartdetails.productName = productItem.name;
      cartdetails.productSecondName = productItem.name_2;
      cartdetails.productPrice = productItem.price;
      cartdetails.productDetailAmount = productItem.price;
      cartdetails.productQty = 1.0;
      cartdetails.productNetPrice = productItem.oldPrice;
      cartdetails.createdBy = loginUser.id;
      cartdetails.cart_detail = jsonEncode(productItem);
      cartdetails.discountAmount = 0;
      cartdetails.remark = "";
      cartdetails.issetMeal = 0;
      cartdetails.hasRacManagemant = productItem.hasRacManagemant;
      cartdetails.taxValue = taxvalues;
      cartdetails.printer_id = printer != null ? printer.printerId : 0;
      cartdetails.createdAt = await CommunFun.getLocalID();
    //await localAPI.addintoCartDetails(cartdetails);
    //print(detailID);
    return cartdetails;
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  static getCustomer() async {
    Customer customer;
    var customerData =
        await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    if (customerData != null) {
      var customers = json.decode(customerData);
      customer = Customer.fromJson(customers);
      return customer;
    } else {
      return customer;
    }
  }

// sendTokitched(itemList) async {
//   String ids = "";
//   var list = [];
//   for (var i = 0; i < itemList.length; i++) {
//     if (itemList[i].isSendKichen == null || itemList[i].isSendKichen == 0) {
//       if (ids == "") {
//         ids = itemList[i].id.toString();
//       } else {
//         ids = ids + "," + itemList[i].id.toString();
//       }
//       list.add(itemList[i]);
//     }
//     if (i == itemList.length - 1) {
//       if (list.length > 0) {
//         dynamic send = await localAPI.sendToKitched(ids);
//         openPrinterPop(list);
//       }
//     }
//   }
// }
  static checkRoundData(String total) {
    var parts = total.split('.');
    //First values
    String prefix = parts[0].trim();
    //Second values
    String postFilx = parts[1].trim();

    String round = total;

    int tempValue = int.parse(postFilx.substring(1));
    if (tempValue != 0 && tempValue != 5) {
      if (tempValue <= 2) {
        round = prefix + "." + postFilx.substring(0, 1) + "0";
      } else if (tempValue <= 7) {
        round = prefix + "." + postFilx.substring(0, 1) + "5";
      } else {
        int values = 0;
        if (int.parse(postFilx.substring(1)) == 9) {
          values = 1;
        } else {
          values = 2;
        }

        String tempRound = (int.parse(postFilx) + values).toString();
        double sum = 0.00;
        if (tempRound == "100") {
          sum = double.parse(prefix + ".00") + double.parse("1.00");
        } else {
          sum = double.parse(prefix + ".00") + double.parse("." + tempRound);
        }
        round = sum.toStringAsFixed(2);
      }
    }
    return round;
  }

  static calRounded(double total, double oldTotal) {
    double calRound = 0.00;
    if (total == oldTotal) {
      return calRound;
    } else {
      return calRound = total - oldTotal;
    }
  }

  static printClosingData(
      printerIP,
      context,
      Shift shifittem,
      String permissions,
      List<Payments> paymentMethods,
      List<OrderPayment> orderPayments,
      Branch branchData,
      Map<int, double> variance) async {
    PrintReceipt printKOT = PrintReceipt();

    var terminalID = await CommunFun.getTeminalKey();
    var grosssale = 0.00;
    var netsale = 0.00;
    var discountval = 0.00;
    var refundval = 0.00;
    var taxval = 0.00;
    var totalRend = 0.00;
    var textService = 0.00;
    double cashSale = 0.00;
    double roundingAmount = 0.00;
    double cashDeposit = 0.00;
    double cashRefund = 0.00;
    double cashRounding = 0.00;
    double payInAmmount = 0.00;
    double payOutAmmount = 0.00;
    double expectedVal = 0.00;
    int totalPax = 0;

    List<Orders> ordersList = await localAPI.getShiftInvoiceData(
        branchData.branchId, shifittem.createdAt);
    // Summery
    if (ordersList.length > 0) {
      for (var i = 0; i < ordersList.length; i++) {
        Orders order = ordersList[i];
        grosssale += order.sub_total;
        refundval += 0;
        netsale = grosssale - refundval;
        taxval += order.tax_amount;
        totalPax += order.pax ?? 0;
        roundingAmount += order.rounding_amount;
        textService += order.serviceCharge ?? 0;
        discountval += order.voucher_amount != null ? order.voucher_amount : 0;
        totalRend = (netsale + taxval + textService) - discountval;
      }
    }

    // cash drawer summery

    List<Drawerdata> result =
        await localAPI.getPayinOutammount(shifittem.appId);
    if (result.length > 0) {
      var drawerAmm = 0.00;
      for (var i = 0; i < result.length; i++) {
        Drawerdata drawer = result[i];
        if (drawer.amount != null) {
          drawerAmm += drawer.amount;
          cashSale += drawer.amount;
          cashDeposit = 0.00;
          cashRefund += drawer.isAmountIn == 0 ? drawer.amount : 0.00;
          cashRounding += 0.00;
          payInAmmount += drawer.isAmountIn == 1 ? drawer.amount : 0.00;
          payOutAmmount += drawer.isAmountIn == 2 ? drawer.amount : 0.00;
        }
      }
      expectedVal = drawerAmm;
    }

    /// Payment summery
    /* dynamic payments = await localAPI.getTotalPayment(terminalID, branchid);
    List<Payments> paymentMethods = payments["payment_method"];
    List<OrderPayment> orderPayments = payments["payments"];
    var branchID = await getbranchId();
    Branch branchData = await localAPI.getBranchData(branchID);
     */
    // branch Data

    // terminal Data
    Terminal terminalData = await localAPI.getTerminalDetails(terminalID);
    Function printShiftReport = () => printKOT.shiftReportPrint(
          printerIP,
          context,
          // Branch data
          branchData,
          totalPax,
          // terminal data
          terminalData,
          //Summery Sales data
          grosssale,
          refundval,
          discountval,
          netsale,
          taxval,
          textService,
          roundingAmount,
          totalRend,
          // Drawer Data
          shifittem,
          cashSale,
          cashDeposit,
          cashRefund,
          cashRounding,
          payInAmmount,
          payOutAmmount,
          expectedVal,
          // Paymemts Data
          orderPayments,
          paymentMethods,
          ordersList.length, variance,
        );
    if (permissions.contains(Constant.PRINT_RECIEPT)) {
      printShiftReport();
    } else {
      await SyncAPICalls.logActivity("print reciept",
          "Cashier has no permission for print reciept", "print reciept", 1);
      await CommonUtils.openPermissionPop(context, Constant.PRINT_RECIEPT,
          () async {
        await SyncAPICalls.logActivity("print reciept",
            "Manager given permission for print reciept", "print reciept", 1);
        printShiftReport();
      }, () {});
    }
  }

  static printShiftReportData(printerIP, context, shiftid, permissions) async {
    PrintReceipt printKOT = PrintReceipt();

    Shift shifittem = new Shift();
    var branchid = await CommunFun.getbranchId();
    var terminalID = await CommunFun.getTeminalKey();
    var grosssale = 0.00;
    var netsale = 0.00;
    var discountval = 0.00;
    var refundval = 0.00;
    var taxval = 0.00;
    var totalRend = 0.00;
    var textService = 0.00;
    double cashSale = 0.00;
    double roundingAmount = 0.00;
    double cashDeposit = 0.00;
    double cashRefund = 0.00;
    double cashRounding = 0.00;
    double payInAmmount = 0.00;
    double payOutAmmount = 0.00;
    double expectedVal = 0.00;
    int totalPax = 0;

    if (shiftid != null) {
      List<Shift> shift = await localAPI.getShiftData(shiftid);
      if (shift.length > 0) {
        shifittem = shift[0];
        //statringAmount = shifittem.startAmount !=nu shifittem.startAmount.toDouble();
      }
    }
    List<Orders> ordersList =
        await localAPI.getShiftInvoiceData(branchid, shifittem.createdAt);
    // Summery
    if (ordersList.length > 0) {
      for (var i = 0; i < ordersList.length; i++) {
        Orders order = ordersList[i];
        grosssale += order.sub_total;
        refundval += 0;
        netsale = grosssale - refundval;
        taxval += order.tax_amount;
        totalPax += order.pax ?? 0;
        roundingAmount += order.rounding_amount;
        textService += order.serviceCharge ?? 0;
        discountval += order.voucher_amount != null ? order.voucher_amount : 0;
        totalRend = (netsale + taxval + textService) - discountval;
      }
    }

    // cash drawer summery

    List<Drawerdata> result =
        await localAPI.getPayinOutammount(shifittem.appId);
    if (result.length > 0) {
      var drawerAmm = 0.00;
      for (var i = 0; i < result.length; i++) {
        Drawerdata drawer = result[i];
        if (drawer.amount != null) {
          drawerAmm += drawer.amount;
          cashSale += drawer.amount;
          cashDeposit = 0.00;
          cashRefund += drawer.isAmountIn == 0 ? drawer.amount : 0.00;
          cashRounding += 0.00;
          payInAmmount += drawer.isAmountIn == 1 ? drawer.amount : 0.00;
          payOutAmmount += drawer.isAmountIn == 2 ? drawer.amount : 0.00;
        }
      }
      expectedVal = drawerAmm;
    }

    /// Payment summery
    dynamic payments = await localAPI.getTotalPayment(terminalID, branchid);
    List<Payments> paymentMethods = payments["payment_method"];
    List<OrderPayment> orderPayments = payments["payments"];
    // branch Data
    var branchID = await getbranchId();
    Branch branchData = await localAPI.getbranchData();

    // terminal Data
    Terminal terminalData = await localAPI.getTerminalDetails(terminalID);
    if (permissions.contains(Constant.PRINT_RECIEPT)) {
      printKOT.shiftReportPrint(
          printerIP,
          context,
          // Branch data
          branchData,
          totalPax,
          // terminal data
          terminalData,
          //Summery Sales data
          grosssale,
          refundval,
          discountval,
          netsale,
          taxval,
          textService,
          roundingAmount,
          totalRend,
          // Drawer Data
          shifittem,
          cashSale,
          cashDeposit,
          cashRefund,
          cashRounding,
          payInAmmount,
          payOutAmmount,
          expectedVal,
          // Paymemts Data
          orderPayments,
          paymentMethods,
          ordersList.length);
    } else {
      await SyncAPICalls.logActivity("print reciept",
          "Cashier has no permission for print reciept", "print reciept", 1);
      await CommonUtils.openPermissionPop(context, Constant.PRINT_RECIEPT,
          () async {
        await SyncAPICalls.logActivity("print reciept",
            "Manager given permission for print reciept", "print reciept", 1);
        printKOT.shiftReportPrint(
            printerIP,
            context,
            // Branch data
            branchData,
            totalPax,
            // terminal data
            terminalData,
            //Summery Sales data
            grosssale,
            refundval,
            discountval,
            netsale,
            taxval,
            textService,
            roundingAmount,
            totalRend,
            // Drawer Data
            shifittem,
            cashSale,
            cashDeposit,
            cashRefund,
            cashRounding,
            payInAmmount,
            payOutAmmount,
            expectedVal,
            // Paymemts Data
            orderPayments,
            paymentMethods,
            ordersList.length);
      }, () {});
    }
  }
}
