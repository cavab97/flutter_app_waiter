import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcncashier/components/DrawerWidget.dart';
import 'package:mcncashier/components/QrScanAndGenrate.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Reservation.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/reservation/addEditReservation.dart';
import 'package:mcncashier/screens/reservation/reservationManagement.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/models/colorTable.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import '../components/communText.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SelectTablePage extends StatefulWidget {
  // PIN Enter PAGE
  SelectTablePage({Key key}) : super(key: key);
  @override
  _SelectTablePageState createState() => _SelectTablePageState();
}

class _SelectTablePageState extends State<SelectTablePage>
    with SingleTickerProviderStateMixin {
  TextEditingController paxController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<TablesDetails> tableList = new List<TablesDetails>();
  List<int> mergeTableList = [];
  PrintReceipt printKOT = PrintReceipt();
  List<Printer> printerList = new List<Printer>();
  List<Printer> printerreceiptList = new List<Printer>();
  TablesDetails selectedTable;
  var orderid;
  TablesDetails mergeInTable;
  TablesDetails changeInTable;
  bool isLoading = false;
  bool isMergeing = false;
  bool isChangingTable = false;
  bool isAssigning = false;
  String qrCodeString = "";
  bool isChanging = false;
  bool isShiftOpen = true;
  bool isMenuopen = true;
  bool changingColors = false;
  var permissions = "";
  TabController _tabController;
  MaterialColor tableSelectedColor = Colors.orange;
  List<ColorTable> tableColors = new List<ColorTable>();
  List<Reservation> reservationList = [];

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    _tabController = new TabController(length: 2, vsync: this);
    checkisInit();
    checkISlogin();
  }

  checkisInit() async {
    //var isInit = await CommunFun.checkDatabaseExit();
    // if (isInit == true) {
      afterInit();
    // } else {
    //   await databaseHelper.initializeDatabase();
    //   afterInit();
    // }
  }

  getReservationList() async {
    /* var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    List<Shift> shift = [];
    if (shiftid != null) {
      shift = await localAPI.getShiftData(shiftid);
    }
    DateTime today;
    String dateFrom;
    if (shift.length > 0) {
      Shift shiftItem = shift[0];
      dateFrom = shiftItem.createdAt ?? shiftItem.updatedAt;
    }
    if (dateFrom == null) {
      today = DateTime.now();
      dateFrom = DateTime(today.year, today.month, 1).toString();
    }
    int tID = int.tryParse(await CommunFun.getTeminalKey()); */
    List<Reservation> resList = await localAPI.getReservationList();
    setState(() {
      reservationList = resList;
    });
  }

  checkISlogin() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (loginUser == null) {
      Navigator.pushNamed(context, Constant.PINScreen);
    }
  }

  afterInit() async {
    try {
    getTablesColor();
    await getTables();
    checkshift();
    await getAllPrinter();
    setPermissons();
    Map arguments = new Map();
    if (this.mounted) {
      arguments = ModalRoute.of(context).settings.arguments as Map;
    }
    if (arguments != null) {
      int updatedTableId = arguments['updatedTableId'];
      Function callbackFunction = arguments['callbackFunction'];
      if (updatedTableId != null && updatedTableId > 0) {
        List<MSTCartdetails> cartLists = arguments['cartLists'];
        if (cartLists != null && cartLists.length > 0) {
          sendTokitched(cartLists, updatedTableId);
        }
      } else if (callbackFunction != null) {
        callbackFunction(context);
      }
    }

    getReservationList();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    if (this.mounted) {
      setState(() {
        permissions = permission;
      });
    }
  }

  checkshift() async {
    /*Set terminal name for print receipt only */
   /*  if (Strings.terminalName.isEmpty) {
      var terminalkey = await CommunFun.getTeminalKey();
      Terminal terminalData = await localAPI.getTerminalDetails(terminalkey);
      if (terminalData != null) {
        Strings.terminalName = terminalData.terminalName;
      }
    } */

    var isOpen = await localAPI.getShift();
    if (this.mounted) {
      setState(() {
        isShiftOpen = isOpen ?? false;
      });
    }
  }

  getTables() async {
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }

    var currentCart = [];
    MST_Cart cart;

    var branchid = await CommunFun.getbranchId();
    List<TablesDetails> tables = await localAPI.getTables(branchid);

    for (int i = 0; i < tables.length; i++) {
      currentCart = await localAPI.getSaveOrder(tables[i].saveorderid);

      if (currentCart.isNotEmpty) {
        cart = await localAPI.getCartData(currentCart[0].cartId);

        if (cart != null) {
          tables[i].currentAmount = cart.grand_total;
        }
      }

      currentCart = [];
    }

    if (this.mounted) {
      setState(() {
        tableList = tables;
        isLoading = false;
      });
    }
  }

  viewOrder() async {
    // view order data if already order in table
    var tableid = selectedTable.tableId;
    List<Table_order> order = await localAPI.getTableOrders(tableid);
    await Preferences.setStringToSF(Constant.TABLE_DATA, json.encode(order[0]));
    setState(() {
      isMenuopen = true;
      //isMenuopen = false;
    });
    Navigator.of(context).pushNamedAndRemoveUntil(
        Constant.DashboardScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false}).then(backToRefresh);
  }

  backToRefresh(value) {
    //print('backToRefresh');
    getTables();
  }

  openPrinterPop(cartLists, isReprint, TablesDetails tableSelect) {
    for (int i = 0; i < printerList.length; i++) {
      List<MSTCartdetails> tempCart = new List<MSTCartdetails>();
      tempCart.clear();
      for (int j = 0; j < cartLists.length; j++) {
        MSTCartdetails temp = MSTCartdetails();

        if (printerList[i].printerId == cartLists[j].printer_id) {
          temp = cartLists[j];
          tempCart.add(temp);
        }
      }
      if (tempCart.length > 0) {
        printKOT.checkKOTPrint(
          printerList[i].printerIp.toString(),
          tableSelect.tableName,
          context,
          tempCart,
          tableSelect.numberofpax.toString(),
          isReprint,
        );
      }
    }
  }

  sendTokitched(itemList, int tableId) async {
    TablesDetails tableSelect =
        tableList.firstWhere((ele) => ele.tableId == tableId);
    String ids = "";
    var list = [];
    for (var i = 0; i < itemList.length; i++) {
      if (itemList[i].isSendKichen == null || itemList[i].isSendKichen == 0) {
        if (ids == "") {
          ids = itemList[i].id.toString();
        } else {
          ids = ids + "," + itemList[i].id.toString();
        }
        list.add(itemList[i]);
      }
      if (i == itemList.length - 1) {
        if (list.length > 0) {
          await openPrinterPop(list, false, tableSelect);
          await localAPI.sendToKitched(ids);
        }
        return false;
      }
    }
  }

  ontableTap(table) async {
    setState(() {
      selectedTable = table;
      isMenuopen = true;
    });
    paxController.text =
        table.numberofpax != null ? table.numberofpax.toString() : "";
    var tableid = selectedTable.tableId;
    List<Table_order> order = await localAPI.getTableOrders(tableid);
    if (order.length > 0) {
      viewOrder();
    } else {
      addNewOrder();
    }
  }

  ontableLongTap(table) {
    setState(() {
      selectedTable = table;
      //isMenuopen = true;
    });
    paxController.text =
        table.numberofpax != null ? table.numberofpax.toString() : "";
  }

  changeColors() {
    Future.delayed(Duration(seconds: 1), () {
      if (this.mounted) {
        setState(() {
          tableSelectedColor = (tableSelectedColor == null ||
                  tableSelectedColor == Colors.orange)
              ? Colors.grey
              : Colors.orange;
          if (isMergeing || isChangingTable) {
            changeColors();
            changingColors = true;
          } else
            changingColors = false;
        });
      }
    });
  }

  mergeTabledata(TablesDetails table) async {
    try {
      setState(() {
        isLoading = true;
      });
      // Merge table
      TablesDetails table1 = mergeInTable;
      TablesDetails table2 = table;
      Table_order tableOrder = new Table_order();
      var pax = table1.numberofpax != null ? table1.numberofpax : 0;
      pax += table2.numberofpax != null ? table2.numberofpax : 0;
      tableOrder.number_of_pax = pax ?? 0;
      tableOrder.table_id = table1.tableId;
      tableOrder.save_order_id =
          table1.saveorderid != 0 ? table1.saveorderid : 0;
      tableOrder.is_merge_table = "1";
      tableOrder.merged_table_id = table2.tableId;
      tableOrder.assignTime =
          await CommunFun.getCurrentDateTime(DateTime.now());
      await localAPI.mergeTableOrder(tableOrder);
      setState(() {
        isMergeing = false;
        mergeInTable = null;
        isLoading = false;
      });
      await getTables();
      CommunFun.showToast(context, Strings.tableMeargedMsg);
      getTables();
    } catch (e) {
      print(e);
    }
  }

  mergeTable(table) async {
    if (table == null) {
      CommunFun.showToast(context, "Please select table first");
    } else {
      if (isMergeing && mergeInTable == table) {
        setState(() {
          isMergeing = false;
          mergeInTable = null;
        });
      } else {
        if (permissions.contains(Constant.JOIN_TABLE)) {
          setState(() {
            isMenuopen = true;
            isMergeing = true;
            mergeInTable = table;
          });
        } else {
          await SyncAPICalls.logActivity("join table",
              "Cashier has no permission for Join Table", "table", 1);
          CommonUtils.openPermissionPop(context, Constant.JOIN_TABLE, () async {
            setState(() {
              isMenuopen = true;
              //isMenuopen = false;
              isMergeing = true;
              mergeInTable = table;
            });
            await SyncAPICalls.logActivity("join table",
                "Manager given permission for join table", "table", 1);
          }, () {});
        }
      }
      if (!changingColors) changeColors();
    }
  }

  selectTableForNewOrder() async {
    //if ((int.tryParse(paxController.text) ?? 0) <= selectedTable.tableCapacity) {
    Table_order tableOrder = new Table_order();
    tableOrder.table_id = selectedTable.tableId;
    tableOrder.number_of_pax = int.tryParse(paxController.text) ?? 0;
    tableOrder.save_order_id = selectedTable.saveorderid;
    tableOrder.service_charge =
        await CommunFun.getDoubleValue(selectedTable.tableServiceCharge);
    tableOrder.assignTime = await CommunFun.getCurrentDateTime(DateTime.now());
    await localAPI.insertTableOrder(tableOrder);
    await Preferences.setStringToSF(
        Constant.TABLE_DATA, json.encode(tableOrder));
    paxController.text = "";
    //Navigator.of(context).pop();
    if (!isChanging) {
      Navigator.popAndPushNamed(context, Constant.DashboardScreen)
          .then(backToRefresh);
    } else
      await getTables();
  }

  reservationToOrder(Reservation reservation) async {
    reservation.isArr = true;
    localAPI.addReservation(reservation, reservation.id);
    SaveOrder orderData = new SaveOrder();
    orderData.orderName = selectedTable.tableName;
    orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    orderData.numberofPax = (int.tryParse(paxController.text)) ?? 0;
    orderData.cartId = orderid;
    Table_order tableOrder = new Table_order();
    tableOrder.table_id = selectedTable.tableId;
    tableOrder.number_of_pax = int.tryParse(paxController.text) ?? 0;
    tableOrder.save_order_id = selectedTable.saveorderid;
    tableOrder.service_charge =
        await CommunFun.getDoubleValue(selectedTable.tableServiceCharge);
    tableOrder.assignTime = await CommunFun.getCurrentDateTime(DateTime.now());
    await localAPI.insertTableOrder(tableOrder);
    await CommunFun.addReservationToCart(reservation, tableOrder, orderData);
    await Preferences.setStringToSF(
        Constant.TABLE_DATA, json.encode(tableOrder));

    Navigator.of(context).pushNamedAndRemoveUntil(
        Constant.DashboardScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false}).then(backToRefresh);
    /* Navigator.popAndPushNamed(context, Constant.DashboardScreen)
        .then(backToRefresh); */
  }

  changePaxForCurrentOrder() async {
    List<Table_order> toList =
        await localAPI.getTableOrders(selectedTable.tableId);
    Table_order tableOrder = toList[0];
    tableOrder.number_of_pax = int.tryParse(paxController.text) ?? 0;
    await localAPI.updateTablePax(tableOrder);
    await Preferences.setStringToSF(
        Constant.TABLE_DATA, json.encode(tableOrder));
    setState(() {
      selectedTable.numberofpax = int.tryParse(paxController.text) ?? 0;
    });
    paxController.text = "";
  }
  /*   else {
      CommunFun.showToast(context, Strings.table_paxMsg);
    }
  } */

  assignTabletoOrder() async {
    setState(() {
      isLoading = true;
    });
    if (int.tryParse(paxController.text) <= selectedTable.tableCapacity) {
      SaveOrder orderData = new SaveOrder();
      orderData.orderName = selectedTable.tableName;
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
      orderData.numberofPax = (int.tryParse(paxController.text)) ?? 0;
      orderData.cartId = orderid;
      Table_order tableorder = new Table_order();
      tableorder.table_id = selectedTable.tableId;
      tableorder.number_of_pax = (int.tryParse(paxController.text)) ?? 0;
      tableorder.service_charge = selectedTable.tableServiceCharge;
      tableorder.assignTime =
          await CommunFun.getCurrentDateTime(DateTime.now());
      await localAPI.insertTableOrder(tableorder);
      await localAPI.insertSaveOrders(orderData, selectedTable.tableId);
      await localAPI.updateTableidintocart(orderid, selectedTable.tableId);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      //getTables();
      await Navigator.pushNamed(context, Constant.WebOrderPages);
    } else {
      CommunFun.showToast(context, Strings.tablePaxMsg);
    }
  }

  opnPaxDailog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return paxalertDailog(context);
      },
    );
  }

  openQrcodePop() async {
    if (permissions.contains(Constant.PRINT_QR)) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return QRCodesImagePop(
              ip: selectedTable.tableQr,
              onClose: () {},
            );
          });
    } else {
      await SyncAPICalls.logActivity("print Qr code",
          "Cashier has no permission for print QR Code", "table", 1);
      await CommonUtils.openPermissionPop(context, Constant.PRINT_QR, () async {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return QRCodesImagePop(
                ip: selectedTable.tableQr,
                onClose: () {},
              );
            });
        await SyncAPICalls.logActivity("print Qr code",
            "Manager given permission for print QR Code", "table", 1);
      }, () {});
    }
  }

  openReservationList() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReservationMgmt(onClose: (List<Reservation> resList) {
          if (this.mounted) {
            setState(() {
              reservationList = resList;
            });
          }
        }, onArrived: (Reservation res) {
          TablesDetails table =
              tableList.firstWhere((ele) => ele.tableId == res.tableID);
          if (this.mounted) {
            setState(() {
              selectedTable = table;
            });
            reservationToOrder(res);
          }
        });
      },
    );
  }

  openReservationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReservationDetail(
          isUpdate: false,
          selTable: selectedTable,
        );
      },
    );
  }

  cancleTableOrder() async {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () async {
      Navigator.of(context).pop();
      cancleTOrder();
    }, Strings.warning, Strings.cancleOrderMsg, Strings.yes, Strings.no, true);
  }

  cancleTOrder() async {
    setState(() {
      isLoading = true;
      if (selectedTable.merged_table_id != null) {
        mergeTableList.remove(selectedTable.merged_table_id);
      }
    });
    if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
      List<SaveOrder> cartID =
          await localAPI.gettableCartID(selectedTable.saveorderid);
      if (cartID.length > 0) {
        await localAPI.removeCartItem(cartID[0].cartId, selectedTable.tableId);
      }
    } else {
      await localAPI.deleteTableOrder(selectedTable.tableId);
    }
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    setState(() {
      isLoading = false;
      isMenuopen = true;
      selectedTable = null;
      //isMenuopen = false;
    });
    await getTables();
  }

  changeTablePop() {
    if (isChangingTable) {
      setState(() {
        isChangingTable = false;
        changingColors = false;
      });
    } else {
      CommonUtils.showAlertDialog(context, () {
        Navigator.of(context).pop();
      }, () async {
        Navigator.of(context).pop();
        if (permissions.contains(Constant.CHANGE_TABLE)) {
          setState(() {
            isMenuopen = true;
            isChangingTable = true;
          });
        } else {
          await SyncAPICalls.logActivity("change table",
              "Cashier has no permission for change table", "table", 1);
          await CommonUtils.openPermissionPop(context, Constant.CHANGE_TABLE,
              () async {
            setState(() {
              isMenuopen = true;
              isChangingTable = true;
            });
            await SyncAPICalls.logActivity("change table",
                "Manager given permission for change table", "Order", 1);
          }, () {});
        }
      }, Strings.warning, Strings.changeTableMsg, Strings.yes, Strings.no,
          true);
    }
  }

  changeTableToOtherTable(table) async {
    var cartid;
    // if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
    //   List<SaveOrder> cartID =
    //       await localAPI.gettableCartID(selectedTable.saveorderid);
    //   if (cartID.length > 0) {
    //     cartid = cartID[0].cartId;
    //   }
    // }
    await localAPI.changeTable(selectedTable.tableId, table.tableId, cartid);
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tableid != null) {
      var tableddata = json.decode(tableid);
      Table_order tabledata = Table_order.fromJson(tableddata);
      if (tabledata.table_id == selectedTable.tableId) {
        tabledata.table_id = table.tableId;
        tabledata.service_charge = table.tableServiceCharge;

        await Preferences.setStringToSF(
            Constant.TABLE_DATA, jsonEncode(tabledata));
      }
    }
    await getTables();
    setState(() {
      changeInTable = null;
      isChangingTable = false;
      selectedTable = null;
    });
  }

  changePax() async {
    if (permissions.contains(Constant.CHANG_PAX)) {
      setState(() {
        isChanging = true;
      });
      opnPaxDailog();
    } else {
      await SyncAPICalls.logActivity(
          "change pax", "Cashier has no permission for change pax", "table", 1);
      await CommonUtils.openPermissionPop(context, Constant.CHANG_PAX,
          () async {
        setState(() {
          isChanging = true;
        });
        await opnPaxDailog();
        await SyncAPICalls.logActivity("change pax",
            "Manager given permission for change pax", "table", 1);
      }, () {});
    }
  }

  Color colorConvert(String color) {
    color = color.replaceAll("#", "");
    if (color.length == 6) {
      return Color(int.parse("0xFF" + color));
    } else if (color.length == 8) {
      return Color(int.parse("0x" + color));
    }
    return Colors.black;
  }

  getTablesColor() async {
    List<ColorTable> tables = await localAPI.getTablesColor();
    if (this.mounted) {
      setState(() {
        tableColors = tables;
        isLoading = false;
      });
    }
  }

  addNewOrder() async {
    if (permissions.contains(Constant.NEW_ORDER)) {
      setState(() {
        isChanging = false;
      });
      selectTableForNewOrder();
      //opnPaxDailog();
    } else {
      await SyncAPICalls.logActivity(
          "New Order", "Cashier has no permission for new order", "table", 1);
      await CommonUtils.openPermissionPop(context, Constant.NEW_ORDER,
          () async {
        setState(() {
          isChanging = false;
        });
        selectTableForNewOrder();
        await SyncAPICalls.logActivity(
            "New Order", "Manager given permission for new order", "table", 1);
        //opnPaxDailog();
      }, () {});
    }
  }

  void selectOption(choice) {
    // Causes the app to rebuild with the new _selectedChoice.
  }

  openDrawer() {
    scaffoldKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _willPopCallback() async {
      return false;
    }

    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    SizeConfig().init(context);
    if (arguments != null && this.mounted) {
      setState(() {
        isAssigning = arguments['isAssign'];
        orderid = arguments['orderID'];
      });
    }

    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        drawer: DrawerWid(
          onClose: () {
            backToRefresh("drawer");
          },
        ),
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
              icon: Icon(
                Icons.dehaze,
                color: StaticColor.colorWhite,
                size: SizeConfig.safeBlockVertical * 5,
              )),
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            child: Image.asset(Strings.assetHeaderLogo,
                fit: BoxFit.contain, gaplessPlayback: true),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.refresh, //reload data
                  size: 26.0,
                ),
              )
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: StaticColor.colorWhite,
            unselectedLabelStyle: Styles.whiteBoldsmall(),
            indicator: BoxDecoration(color: StaticColor.deepOrange),
            labelColor: StaticColor.colorWhite,
            labelStyle: Styles.whiteBoldsmall(),
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    Strings.dineIn,
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    Strings.takeAway,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            new GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SafeArea(
                  child: Stack(children: <Widget>[
                    TabBarView(
                      controller: _tabController,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(10),
                                  height: MediaQuery.of(context).size.height,
                                  width: isMenuopen
                                      ? MediaQuery.of(context).size.width / 1.5
                                      : MediaQuery.of(context).size.width / 0.9,
                                  child: tablesListwidget(1)),
                              menuItemDiv(),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                height: MediaQuery.of(context).size.height,
                                width: isMenuopen
                                    ? MediaQuery.of(context).size.width / 1.5
                                    : MediaQuery.of(context).size.width,
                                child: tablesListwidget(2),
                              ),
                              menuItemDiv(),
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                )),
            !isShiftOpen
                ? Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        color: Colors.white70.withOpacity(0.9),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              Strings.shiftTextLable,
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 4),
                            ),
                            SizedBox(height: 15),
                            Text(
                              Strings.closed,
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 6,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 30),
                            shiftbtn(() async {
                              if (permissions.contains(Constant.OPENING)) {
                                openOpningAmmountPop(
                                    Strings.titleOpeningAmount);
                              } else {
                                await SyncAPICalls.logActivity(
                                    "Opning",
                                    "Cashier has no permission for Open store",
                                    "table",
                                    1);
                                await CommonUtils.openPermissionPop(
                                    context, Constant.OPENING, () async {
                                  openOpningAmmountPop(
                                      Strings.titleOpeningAmount);
                                  await SyncAPICalls.logActivity(
                                      "Opning",
                                      "Manager given permission for Open store",
                                      "table",
                                      1);
                                }, () {});
                              }
                            })
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
      onWillPop: _willPopCallback,
    );
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
      shift.startAmount = double.parse(ammount);
      shift.updatedAt =
          shift.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    } else {
      shift.endAmount = double.parse(ammount);
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
      checkshift();
    }
    Navigator.of(context).pop();
    Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false});
  }

  openOpningAmmountPop(isopning) async {
    await showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: isopning,
              onEnter: (ammountext) {
                sendOpenShft(ammountext);
                if (isopning == Strings.titleOpeningAmount) {
                  if (printerreceiptList.length > 0) {
                    printKOT.testReceiptPrint(
                        printerreceiptList[0].printerIp.toString(),
                        context,
                        "",
                        Strings.openDrawer,
                        true);
                  } else {
                    CommunFun.showToast(context, Strings.printerNotAvailable);
                  }
                }
              });
        });
  }

  getAllPrinter() async {
    List<Printer> printer = await localAPI.getAllPrinterForKOT();
    List<Printer> printerDraft = await localAPI.getAllPrinterForecipt();
    if (this.mounted) {
      setState(() {
        printerList = printer;
        printerreceiptList = printerDraft;
      });
    }
  }

  Widget shiftbtn(Function onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 15, left: 30, right: 30, bottom: 15),
      onPressed: onPress,
      child: Text(
        Strings.openShift,
        style: TextStyle(
            color: StaticColor.deepOrange,
            fontSize: SizeConfig.safeBlockVertical * 4),
      ),
      color: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1, style: BorderStyle.solid, color: StaticColor.deepOrange),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget menuItemDiv() {
    return isMenuopen
        ? Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 3.5,
                decoration: BoxDecoration(
                  border: Border.all(color: StaticColor.colorGrey),
                ),
                child: optionsList(context),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (selectedTable != null && this.mounted) {
                      setState(() {
                        isChangingTable = false;
                        changeInTable = null;
                        selectedTable = null;
                      });
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3.5,
                  ),
                ),
              ),
            ],
          )
        : SizedBox();
  }

  Widget optionsList(context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: selectedTable == null
          ? [
              /* tableButton(FontAwesomeIcons.conciergeBell,
                  Strings.reservation + Strings.withManagement, context, () {
                openReservationList();
              }), */
              Container(
                height: MediaQuery.of(context).size.height * .1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /* Text(
                      'Select a Table',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ), */
                  ],
                ),
              ),
            ]
          : tableOption(selectedTable),
    );
  }

  List<Widget> tableOption(TablesDetails selectedTable) {
    List<Widget> tableOptionWidget = [];
    tableOptionWidget.add(Text(
      selectedTable != null && selectedTable.numberofpax == null
          ? selectedTable.tableName
          : selectedTable.tableName +
              " : " +
              selectedTable.numberofpax.toString(),
      textAlign: TextAlign.center,
      style: Styles.whiteMediumBold(),
    ));
    if (selectedTable.numberofpax == null) {
      tableOptionWidget.addAll(
        [
          tableButton(
            Icons.supervised_user_circle,
            Strings.newOrder,
            context,
            addNewOrder,
          ),
        ],
      );
    }
    tableOptionWidget.add(
      tableButton(
        Icons.call_merge,
        isMergeing ? Strings.cancelMergeOrder : Strings.mergeOrder,
        context,
        () => mergeTable(selectedTable),
      ),
    );
    if (false && selectedTable.tableQr != null) {
      tableOptionWidget.add(
        tableButton(
          Icons.cancel,
          Strings.scanQRcode,
          context,
          openQrcodePop,
        ),
      );
    }

    if (selectedTable.numberofpax != null) {
      tableOptionWidget.addAll(
        [
          tableButton(
            Icons.supervised_user_circle,
            Strings.changePax,
            context,
            changePax,
          ),
          tableButton(
            Icons.remove_red_eye,
            Strings.viewOrder,
            context,
            viewOrder,
          ),
          tableButton(
            Icons.change_history,
            !isChangingTable ? Strings.changeTable : Strings.cancelChangeTable,
            context,
            changeTablePop,
          ),
          tableButton(
            Icons.cancel,
            Strings.cancleOrder,
            context,
            () async {
              if (permissions.contains(Constant.CANCEL_ORDER)) {
                cancleTableOrder();
              } else {
                await SyncAPICalls.logActivity(
                    "cancel table Order",
                    "Cashier has no permission for cancel table order",
                    "table",
                    1);
                await CommonUtils.openPermissionPop(
                    context, Constant.CANCEL_ORDER, () async {
                  await cancleTableOrder();
                  await SyncAPICalls.logActivity(
                      "cancel table Order",
                      "Manager given permission for cancel table order",
                      "table",
                      1);
                }, () {});
              }
            },
          ),
        ],
      );
    }
    if (selectedTable != null &&
        selectedTable.numberofpax == null &&
        reservationList.length > 0 &&
        reservationList.any((ele) =>
            ele.tableID == selectedTable.tableId && ele.isArr != true)) {
      Reservation reservation = reservationList.firstWhere(
          (ele) =>
              ele.tableID == selectedTable.tableId &&
              ele.isArr != true &&
              DateTime.now()
                      .difference(DateTime.tryParse(ele.resFrom))
                      .inMinutes <
                  30, orElse: () {
        print('no element');
        return new Reservation();
      });
      if (reservation.id != null) {
        tableOptionWidget.add(
          tableButton(
            FontAwesomeIcons.utensils,
            Strings.reservationArrived,
            context,
            () => reservationToOrder(reservation),
          ),
        );
      }
    }
    /* if (selectedTable.status == 1) {
      tableOptionWidget.add(
        tableButton(
            FontAwesomeIcons.conciergeBell, Strings.createReservation, context,
            () async {
          if (permissions.contains(Constant.addReservation)) {
            openReservationDialog();
          } else {
            await CommonUtils.openPermissionPop(
                context, Constant.addReservation, () async {
              await openReservationDialog();
              await SyncAPICalls.logActivity("reservation",
                  "Manager given permission for make reservation", "table", 1);
            }, () {});
          }
        }),
      );
    } */
    return tableOptionWidget;
  }

  Widget closeButton(context) {
    return Positioned(
      top: -30,
      right: -20,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: StaticColor.colorRed,
              borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget changeTable(context) {
    return GestureDetector(
      onTap: () {
        changeTablePop();
      },
      child: Text(Strings.changeTable,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget tableButton(icon, name, context, onclick) {
    return new OutlineButton(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: StaticColor.colorWhite),
          SizedBox(width: 20),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Styles.whiteSimpleSmall(),
          )
        ],
      ),
      borderSide: BorderSide(
          color: StaticColor.colorBlack, width: 1, style: BorderStyle.solid),
      onPressed: onclick,
      shape: new RoundedRectangleBorder(
        side: BorderSide(
            color: StaticColor.colorBlack, width: 1, style: BorderStyle.solid),
        borderRadius: new BorderRadius.circular(0.0),
      ),
    );
  }

  Widget changePaxbtn(context) {
    return GestureDetector(
      onTap: () {
        changePax();
      },
      child: Text(Strings.changePax,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget cancleOrder(context) {
    return GestureDetector(
      onTap: () {
        cancleTableOrder();
      },
      child: Text(Strings.cancleOrder,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget viewOrderBtn(context) {
    return GestureDetector(
      onTap: () {
        viewOrder();
      },
      child: Text(Strings.viewOrder,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget paxTextInput() {
    return TextField(
      controller: paxController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: StaticColor.colorGrey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: StaticColor.colorGrey),
        ),
        prefixIcon: Icon(
          Icons.person,
          color: StaticColor.colorGrey400,
          size: SizeConfig.safeBlockVertical * 5,
        ),
        hintText: Strings.enterPax,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 3,
            fontWeight: FontWeight.bold,
            color: StaticColor.colorGrey400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        fillColor: StaticColor.colorWhite,
      ),
      style: TextStyle(
          color: StaticColor.colorBlack,
          fontSize: SizeConfig.safeBlockVertical * 4),
      onChanged: (e) {},
      onSubmitted: (value) {
        /* setState(() {
          tableList.map((e) {
            if (e == selectedTable) {
              return e.numberofpax = int.tryParse(value);
            } else
              return e;
          });
        }); */

        if (isChanging) {
          changePaxForCurrentOrder();
          Navigator.of(context).pop();
        }
        /* if (!isMergeing) {
          if (isAssigning) {
            assignTabletoOrder();
          } else {
            selectTableForNewOrder();
          }
        } */
      },
    );
  }

  Widget enterButton(Function _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: _onPress,
      child: Text(
        isChanging ? Strings.changePax : Strings.enterPax,
        style: TextStyle(
            color: StaticColor.colorWhite,
            fontSize: SizeConfig.safeBlockVertical * 4),
      ),
      color: StaticColor.deepOrange,
      textColor: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget paxalertDailog(context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: EdgeInsets.zero,
        title: Stack(
          // popup header
          overflow: Overflow.visible,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: StaticColor.colorBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              padding: EdgeInsets.zero,
              height: SizeConfig.safeBlockVertical * 9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(isChanging ? Strings.changePax : Strings.enterPax,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 3,
                          color: StaticColor.colorWhite)),
                ],
              ),
            ),
            closeButton(context), //popup close btn
          ],
        ),
        content: Builder(
          builder: (context) {
            KeyboardVisibilityNotification().addNewListener(
              onHide: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
            );
            return Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      paxTextInput(),
                      SizedBox(
                        height: 30,
                      ),
                      enterButton(() {
                        if (isChanging) {
                          changePaxForCurrentOrder();
                          Navigator.of(context).pop();
                        }
                        /* 
                        if (!isMergeing) {
                          if (isAssigning) {
                            assignTabletoOrder();
                          } else {
                            selectTableForNewOrder();
                          }
                        } */
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget tablesListwidget(type) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 4.5;
    if (isAssigning) {
      var list = tableList
          .where((x) => x.numberofpax == 0 || x.numberofpax == null)
          .toList();
      setState(() {
        tableList = list;
      });
    }
    if (isMergeing || isChangingTable) {
      var list = tableList.toList();
      //var list = tableList.where((x) => x.tableId != selectedTable.tableId).toList();
      setState(() {
        tableList = list;
      });
      if (tableList.length == 0) {
        CommunFun.showToast(context, Strings.tableNotAvalilable);
      }
    }
    List<TablesDetails> newtableList = new List<TablesDetails>();
    if (type == 1) {
      //TakeAway
      var dainIn = tableList.where((x) => x.tableType == 1).toList();
      newtableList = dainIn;
    } else {
      // DineIn
      var takeAway = tableList.where((x) => x.tableType == 2).toList();
      newtableList = takeAway;
    }

    return GridView.count(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: isMenuopen ? 4 : 6,
      children: newtableList.map((table) {
        if (table.occupiedMinute == null && table.assignTime != null) {
          final date2 = DateTime.now();
          table.occupiedMinute = double.tryParse(date2
              .difference(DateTime.parse(table.assignTime))
              .inMinutes
              .toString());
        }
        if (table.merged_table_id != null &&
            !mergeTableList.contains(table.merged_table_id)) {
          setState(() {
            if (!isLoading) mergeTableList.add(table.merged_table_id);
          });
        }
        var selected;
        if (tableColors.length > 0 && table.occupiedMinute != null) {
          selected = tableColors.firstWhere(
              (item) => item.timeMinute >= table.occupiedMinute, orElse: () {
            if (table.occupiedMinute >=
                tableColors[tableColors.length - 1].timeMinute) {
              return tableColors[tableColors.length - 1];
            } else
              return null;
          });
        }
        var time;
        if (selected != null) {
          var d = Duration(
              minutes: int.parse(table.occupiedMinute.round().toString()));
          List<String> parts = d.toString().split(':');
          time = '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          onTap: () {
            if (mergeTableList.contains(table.tableId)) {
            } else if (selectedTable != null &&
                selectedTable.tableId == table.tableId) {
            } else if (isMergeing) {
              if (table.merged_table_id == null) {
                //mergeInTable.
                mergeTabledata(table);
              } else {
                CommunFun.showToast(context, Strings.tableAlreadyMerged);
              }
            } else if (isChangingTable) {
              if (table.saveorderid == 0) {
                changeTableToOtherTable(table);
              } else {
                CommunFun.showToast(context, Strings.tableAlreadyOccupied);
              }
            } else {
              ontableLongTap(table);
            }
          },
          onDoubleTap: () {
            ontableTap(table);
          },
          child: Container(
            width: itemHeight,
            height: itemWidth,
            margin: EdgeInsets.all(5),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Hero(
                  tag: table.tableId,
                  child: Container(
                    decoration: new BoxDecoration(
                        color: selected != null
                            ? colorConvert(selected.colorCode)
                            : StaticColor.colorWhite,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0))),
                    width: MediaQuery.of(context).size.width,
                    height: itemHeight / 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          table.tableName.isEmpty
                              ? SizedBox(height: 0)
                              : SizedBox(height: 30),
                          Text(
                            table.merged_table_id != null
                                ? table.tableName +
                                    " : " +
                                    table.merge_table_name.toString()
                                : table.tableName,
                            style: Styles.blackMediumBold(),
                          ),
                        ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: itemHeight / 2),
                  width: MediaQuery.of(context).size.width,
                  //height: itemHeight / 5,
                  decoration: BoxDecoration(
                      color: table.is_merge_table != null
                          ? Colors.blue
                          : ((isMergeing || isChangingTable) &&
                                  selectedTable != null &&
                                  selectedTable.tableId == table.tableId)
                              ? tableSelectedColor
                              : (selectedTable != null &&
                                      selectedTable.tableId == table.tableId)
                                  ? Colors.orange
                                  : table.numberofpax != null
                                      ? StaticColor.deepOrange
                                      : StaticColor.colorGrey600,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      mergeTableList.contains(table.tableId)
                          ? Text(
                              "-",
                              style: Styles.whiteSimpleSmall(),
                            )
                          : //table.numberofpax != null
                          Text(
                              Strings.amount +
                                  ' : ' +
                                  Strings.currency +
                                  (table.currentAmount == null
                                      ? "0.00"
                                      : table.currentAmount.toStringAsFixed(2)),
                              style: Styles.whiteSimpleSmall())
                      /* Text(
                                  Strings.vacant +
                                      "0" +
                                      "/" +
                                      table.tableCapacity.toString(),
                                  style: Styles.whiteSimpleSmall()) */
                    ],
                  ),
                ),
                /* Positioned(
                  top: 10,
                  left: 10,
                  child: Text(
                    table.numberofpax != null
                        ? Strings.orders + " 1 "
                        : Strings.orders + " 0 ",
                    style: Styles.blackMediumBold(),
                  ),
                ), */
                Positioned(
                  top: 10,
                  right: 10,
                  child: Text(
                    time != null ? time.toString() : "",
                    style: TextStyle(
                        // White text
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                        fontFamily: Strings.fontFamily),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
