import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class ShiftList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<Shift>> getShiftData(context, shiftId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Shift> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.shift_datails;
      var stringParams = {"shift_id": shiftId};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list =
            data.length > 0 ? data.map((c) => Shift.fromJson(c)).toList() : [];
      }
    } else {
      var result =
          await db.query('shift', where: "shift_id = ?", whereArgs: [shiftId]);
      list = result.isNotEmpty
          ? result.map((c) => Shift.fromJson(c)).toList()
          : [];
    }
    return list;
  }

  Future<int> insertShift(context, Shift shift) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    var result;
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.add_shift;
      var stringParams = shift.toJson();
      result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = result["shift_id"];
      }
    } else {
      print(shift.shiftId);
      if (shift.shiftId != null) {
        result = await db.update("shift", shift.toJson(),
            where: 'shift_id = ?', whereArgs: [shift.shiftId]);
      } else {
        result = await db.insert("shift", shift.toJson());
      }
      var dis = shift.shiftId != null ? "Update shift" : "Insert shift";
      await SyncAPICalls.logActivity("Product", dis, "shift", result);
    }
    print(result);
    return result;
  }

  Future<List<Drawerdata>> getPayinOutammount(shiftid) async {
    List<Drawerdata> drawerList = new List<Drawerdata>();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.drawer_data;
      var stringParams = {"shift_id": shiftid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        drawerList = data.length > 0
            ? data.map((c) => Drawerdata.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "SELECT * from drawer where shift_id = " + shiftid.toString();
      var mealList = await db.rawQuery(qry);
      drawerList = mealList.isNotEmpty
          ? mealList.map((c) => Drawerdata.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Meals product List", "Meals product List", "drawer", shiftid);
    }
    return drawerList;
  }
}
