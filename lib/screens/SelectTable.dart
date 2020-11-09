import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/DrawerWidget.dart';
import 'package:mcncashier/components/QrScanAndGenrate.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

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
  PrintReceipt printKOT = PrintReceipt();
  List<Printer> printerList = new List<Printer>();
  List<Printer> printerreceiptList = new List<Printer>();
  var selectedTable;
  var number_of_pax;
  var orderid;
  var mergeInTable;
  var changeInTable;
  bool isLoading = false;
  bool isMergeing = false;
  bool isChangingTable = false;
  bool isAssigning = false;
  bool isChanging = false;
  bool isShiftOpen = true;
  bool isMenuOpne = false;
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getTables();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    _tabController = new TabController(length: 2, vsync: this);
    checkshift();
    getAllPrinter();
  }

  checkshift() async {
    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    setState(() {
      isShiftOpen = isOpen != null && isOpen == "true" ? true : false;
    });
  }

  getTables() async {
    // Tables List call
    setState(() {
      isLoading = true;
    });
    var branchid = await CommunFun.getbranchId();
    List<TablesDetails> tables = await localAPI.getTables(branchid);
    setState(() {
      tableList = tables;
      isLoading = false;
    });
  }

  viewOrder() async {
    // view order data if already order in table
    var tableid = selectedTable.tableId;
    List<Table_order> order = await localAPI.getTableOrders(tableid);
    await Preferences.setStringToSF(Constant.TABLE_DATA, json.encode(order[0]));
    Navigator.pushNamed(context, Constant.DashboardScreen);
  }

  ontableTap(table) {
    // select table for new order
    setState(() {
      selectedTable = table;
      isMenuOpne = true;
    });
    // if (isAssigning) {
    //   opnPaxDailog();
    // } else {
    paxController.text =
        table.numberofpax != null ? table.numberofpax.toString() : "";
    //   openSelectTablePop();
    // }
  }

  mergeTabledata(TablesDetails table) async {
    // Merge table
    TablesDetails table1 = mergeInTable;
    TablesDetails table2 = table;
    Table_order table_order = new Table_order();
    var pax = table1.numberofpax != null ? table1.numberofpax : 0;
    pax += table2.numberofpax != null ? table2.numberofpax : 0;
    table_order.number_of_pax = pax;
    table_order.table_id = table1.tableId;
    table_order.save_order_id =
        table1.saveorderid != 0 ? table1.saveorderid : 0;
    table_order.is_merge_table = "1";
    table_order.merged_table_id = table2.tableId;
    var result = await localAPI.mergeTableOrder(table_order);
    setState(() {
      isMergeing = false;
      mergeInTable = null;
    });
    CommunFun.showToast(context, Strings.table_mearged_msg);
    getTables();
  }

  mergeTable(table) {
    setState(() {
      isMergeing = true;
      mergeInTable = table;
    });
  }

  selectTableForNewOrder() async {
    if (int.parse(paxController.text) <= selectedTable.tableCapacity) {
      Table_order table_order = new Table_order();
      table_order.table_id = selectedTable.tableId;
      table_order.number_of_pax = int.parse(paxController.text);
      table_order.save_order_id = selectedTable.saveorderid;
      var result = await localAPI.insertTableOrder(table_order);
      await Preferences.setStringToSF(
          Constant.TABLE_DATA, json.encode(table_order));
      paxController.text = "";
      Navigator.of(context).pop();
      if (!isChanging) {
        Navigator.pushNamed(context, Constant.DashboardScreen);
      }
      getTables();
    } else {
      CommunFun.showToast(context, "Please enter pax minimum table capcity.");
    }
  }

  assignTabletoOrder() async {
    if (int.parse(paxController.text) <= selectedTable.tableCapacity) {
      SaveOrder orderData = new SaveOrder();
      orderData.orderName = selectedTable.tableName;
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
      orderData.numberofPax = int.parse(paxController.text);
      orderData.cartId = orderid;
      Table_order tableorder = new Table_order();
      tableorder.table_id = selectedTable.tableId;
      tableorder.number_of_pax = int.parse(paxController.text);
      await localAPI.insertTableOrder(tableorder);
      await localAPI.insertSaveOrders(orderData, selectedTable.tableId);
      await localAPI.updateTableidintocart(orderid, selectedTable.tableId);
      Navigator.pushNamed(context, Constant.WebOrderPages);
    } else {
      CommunFun.showToast(context, "Please enter pax minimum table capcity.");
    }
  }

  openSelectTablePop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //return alertDailog(context);
      },
    );
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

  cancleTableOrder() async {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () async {
      Navigator.of(context).pop();
      if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
        List<SaveOrder> cartID =
            await localAPI.gettableCartID(selectedTable.saveorderid);
        if (cartID.length > 0) {
          await localAPI.removeCartItem(
              cartID[0].cartId, selectedTable.tableId);
        }
      } else {
        await localAPI.deleteTableOrder(selectedTable.tableId);
      }
      await Preferences.removeSinglePref(Constant.TABLE_DATA);
      await getTables();
    }, "Warning", "Are you want sure cancel this table order?", "Yes", "No",
        true);
  }

  changeTablePop() {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      setState(() {
        isChangingTable = true;
      });
    }, "Warning", "Are you want sure to change your table?", "Yes", "No", true);
  }

  changeTableToOtherTable(table) async {
    var cartid;
    if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
      List<SaveOrder> cartID =
          await localAPI.gettableCartID(selectedTable.saveorderid);
      if (cartID.length > 0) {
        cartid = cartID[0].cartId;
      }
    }
    var tables = await localAPI.changeTable(
        selectedTable.tableId, table.tableId, cartid);
    print(tables);
    setState(() {
      changeInTable = null;
      isChangingTable = false;
    });
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tableid != null) {
      var tableddata = json.decode(tableid);
      Table_order tabledata = Table_order.fromJson(tableddata);
      if (tabledata.table_id == selectedTable.tableId) {
        tabledata.table_id = table.tableId;
        await Preferences.setStringToSF(
            Constant.TABLE_DATA, jsonEncode(tabledata));
      }
    }
    await getTables();
  }

  changePax() {
    setState(() {
      isChanging = true;
    });
    opnPaxDailog();
  }

  addNewOrder() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return QRCodesImagePop(
            ip: selectedTable.tableQr,
            onClose: () {
              setState(() {
                isChanging = false;
              });
              opnPaxDailog();
            },
          );
        });
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
    setState(() {
      isAssigning = arguments['isAssign'];
      orderid = arguments['orderID'];
    });
    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        drawer: DrawerWid(),
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
              icon: Icon(
                Icons.dehaze,
                color: Colors.white,
                size: SizeConfig.safeBlockVertical * 5,
              )),
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            child: Image.asset(Strings.asset_headerLogo,
                fit: BoxFit.contain, gaplessPlayback: true),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.white,
            unselectedLabelStyle: Styles.whiteBoldsmall(),
            indicator: BoxDecoration(color: Colors.deepOrange),
            labelColor: Colors.white,
            labelStyle: Styles.whiteBoldsmall(),
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Dine In",
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
                    "Take Away",
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
                                  width: isMenuOpne
                                      ? MediaQuery.of(context).size.width / 1.5
                                      : MediaQuery.of(context).size.width,
                                  child: tablesListwidget(1)),
                              menuItemDiv()
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
                                  width: isMenuOpne
                                      ? MediaQuery.of(context).size.width / 1.5
                                      : MediaQuery.of(context).size.width,
                                  child: tablesListwidget(2)),
                              menuItemDiv()
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
                            shiftbtn(() {
                              openOpningAmmountPop(
                                  Strings.title_opening_amount);
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
    shift.appId = int.parse(terminalId);
    shift.terminalId = int.parse(terminalId);
    shift.branchId = int.parse(branchid);
    shift.userId = userdata.id;
    shift.uuid = await CommunFun.getLocalID();
    shift.status = 1;
    if (shiftid == null) {
      shift.startAmount = int.parse(ammount);
    } else {
      shift.shiftId = int.parse(shiftid);
      shift.endAmount = int.parse(ammount);
    }
    shift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    shift.updatedBy = userdata.id;
    var result = await localAPI.insertShift(shift);
    if (shiftid == null) {
      await Preferences.setStringToSF(Constant.DASH_SHIFT, result.toString());
    } else {
      await Preferences.removeSinglePref(Constant.DASH_SHIFT);
      await Preferences.removeSinglePref(Constant.IS_SHIFT_OPEN);
      await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
      checkshift();
    }
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
                if (isopning == Strings.title_opening_amount) {
                  if (printerreceiptList.length > 0) {
                    printKOT.testReceiptPrint(
                        printerreceiptList[0].printerIp.toString(),
                        context,
                        "",
                        "OpenDrawer");
                  } else {
                    CommunFun.showToast(context, Strings.printer_not_available);
                  }
                }
              });
        });
  }

  getAllPrinter() async {
    List<Printer> printer = await localAPI.getAllPrinterForKOT();
    List<Printer> printerDraft = await localAPI.getAllPrinterForecipt();
    setState(() {
      printerList = printer;
      printerreceiptList = printerDraft;
    });
  }

  Widget openShiftButton(context) {
    // Payment button
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          color: Colors.black87,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.shiftTextLable,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 4),
              ),
              SizedBox(height: 25),
              Text(
                Strings.closed,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 6,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              shiftbtn(() {
                openOpningAmmountPop(Strings.title_opening_amount);
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget shiftbtn(Function onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 15, left: 30, right: 30, bottom: 15),
      onPressed: onPress,
      child: Text(
        Strings.open_shift,
        style: TextStyle(
            color: Colors.deepOrange,
            fontSize: SizeConfig.safeBlockVertical * 4),
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1, style: BorderStyle.solid, color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget menuItemDiv() {
    return isMenuOpne
        ? Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width / 3.5,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: optionsList(context))
        : SizedBox();
  }

  Widget optionsList(context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        selectedTable != null
            ? Text(
                selectedTable.numberofpax == null
                    ? selectedTable.tableName
                    : selectedTable.tableName +
                        " : " +
                        selectedTable.numberofpax.toString(),
                textAlign: TextAlign.center,
                style: Styles.whiteMediumBold(),
              )
            : SizedBox(),
        selectedTable.numberofpax == null
            ? neworder_button(
                Icons.supervised_user_circle, Strings.new_order, context, () {
                addNewOrder();
              })
            : SizedBox(),
        selectedTable.numberofpax != null
            ? neworder_button(
                Icons.supervised_user_circle, Strings.change_pax, context, () {
                changePax();
              })
            : SizedBox(),
        selectedTable.numberofpax != null
            ? neworder_button(Icons.remove_red_eye, Strings.view_order, context,
                () {
                viewOrder();
              })
            : SizedBox(),
        selectedTable.numberofpax != null
            ? neworder_button(
                Icons.change_history, Strings.change_table, context, () {
                changeTablePop();
              })
            : SizedBox(),
        selectedTable.numberofpax != null
            ? neworder_button(Icons.cancel, Strings.cancle_order, context, () {
                cancleTableOrder();
              })
            : SizedBox(),
        neworder_button(Icons.call_merge, Strings.merge_order, context, () {
          mergeTable(selectedTable);
        })
      ],
    );
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
              color: Colors.red, borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.clear,
              color: Colors.white,
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
      child: Text(Strings.change_table,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget neworder_button(icon, name, context, onclick) {
    return new OutlineButton(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            SizedBox(width: 20),
            Text(name,
                textAlign: TextAlign.center, style: Styles.whiteSimpleSmall())
          ],
        ),
        borderSide:
            BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid),
        onPressed: onclick,
        shape: new RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.black, width: 1, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(0.0)));
  }

  Widget changePaxbtn(context) {
    return GestureDetector(
      onTap: () {
        changePax();
      },
      child: Text(Strings.change_pax,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget cancleOrder(context) {
    return GestureDetector(
      onTap: () {
        cancleTableOrder();
      },
      child: Text(Strings.cancle_order,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget viewOrderBtn(context) {
    return GestureDetector(
      onTap: () {
        viewOrder();
      },
      child: Text(Strings.view_order,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget paxTextInput() {
    return TextField(
      controller: paxController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        prefixIcon: Icon(
          Icons.person,
          color: Colors.grey[400],
          size: SizeConfig.safeBlockVertical * 5,
        ),
        hintText: Strings.enter_pax,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 3,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        fillColor: Colors.white,
      ),
      style: TextStyle(
          color: Colors.black, fontSize: SizeConfig.safeBlockVertical * 4),
      onChanged: (e) {},
    );
  }

  Widget enterButton(Function _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: _onPress,
      child: Text(
        isChanging ? Strings.change_pax : Strings.enterPax,
        style: TextStyle(
            color: Colors.white, fontSize: SizeConfig.safeBlockVertical * 4),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget paxalertDailog(context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: EdgeInsets.all(0),
        title: Stack(
          // popup header
          overflow: Overflow.visible,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              padding: EdgeInsets.all(0),
              height: SizeConfig.safeBlockVertical * 9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(isChanging ? Strings.change_pax : Strings.enterPax,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 3,
                          color: Colors.white)),
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
                        if (!isMergeing) {
                          if (isAssigning) {
                            assignTabletoOrder();
                          } else {
                            selectTableForNewOrder();
                          }
                        }
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
      var list =
          tableList.where((x) => x.tableId != selectedTable.tableId).toList();
      setState(() {
        tableList = list;
      });
      if (tableList.length == 0) {
        CommunFun.showToast(context, "Table not available for merge.");
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
      crossAxisCount: isMenuOpne ? 4 : 6,
      children: newtableList.map((table) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          onTap: () {
            if (isMergeing) {
              if (table.merged_table_id == null) {
                mergeTabledata(table);
              } else {
                CommunFun.showToast(
                    context, "Table already merged with other table");
              }
            }
            if (isChangingTable) {
              if (table.saveorderid == 0) {
                changeTableToOtherTable(table);
              } else {
                CommunFun.showToast(context, "Table already occupied");
              }
            } else {
              ontableTap(table);
            }
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
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0))),
                    width: MediaQuery.of(context).size.width,
                    height: itemHeight / 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 30),
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
                      color: table.numberofpax != null
                          ? Colors.deepOrange
                          : Colors.grey[600],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      table.numberofpax != null
                          ? Text(
                              Strings.occupied +
                                  table.numberofpax.toString() +
                                  "/" +
                                  table.tableCapacity.toString(),
                              style: Styles.whiteSimpleSmall())
                          : Text(
                              Strings.vacant +
                                  "0" +
                                  "/" +
                                  table.tableCapacity.toString(),
                              style: Styles.whiteSimpleSmall())
                    ],
                  ),
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child: Text(
                        table.numberofpax != null
                            ? Strings.orders + " 1 "
                            : Strings.orders + " 0 ",
                        style: Styles.blackMediumBold()))
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
