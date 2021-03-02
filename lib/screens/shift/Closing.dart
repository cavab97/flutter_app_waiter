import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/printer/printerconfig.dart';

class ClosingPage extends StatefulWidget {
  ClosingPage({Key key, this.onClose}) : super(key: key);
  Function onClose;
  @override
  _ClosingPageState createState() => _ClosingPageState();
}

class _ClosingPageState extends State<ClosingPage> {
  double defaultFontSize = 22;
  LocalAPI localAPI = LocalAPI();
  Map<String, String> closingData = new Map();
  Map<String, String> drawerData = new Map();
  Map<int, double> variance = new Map();
  List<Payments> paymentList = [];
  List<OrderPayment> orderPaymentList = [];
  Branch branch;
  String terminalID;
  Shift currentShift;
  String openShiftDateTime;
  String currentNumber;
  int currentEditPaymentId = 0;
  bool isCalculateCash = false;
  double totalCalcAmount = 0.00;
  int currentQtyIndex = 0;
  List<String> calculatePaymentType = ["cash"];
  ScrollController _scrollController = ScrollController();
  List<double> cashType = [100, 50, 20, 10, 5, 1, .5, .2, .1, .05];
  List<int> qtyEveryType = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  String permissions = "";
  List<Printer> printerreceiptList = new List<Printer>();
  bool isClosing = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    getAllPrinter();
    getPermission();
    await getShift();
    await getTerminalID();
    await getBranch();
    getOrdersData();
    getPayments();
    getDrawerData();
  }

  String getCapitalize(String aStringToCapitalize) {
    return aStringToCapitalize
        .split(" ")
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join(" ");
  }

  getAllPrinter() async {
    List<Printer> printerDraft = await localAPI.getAllPrinterForecipt();
    setState(() {
      printerreceiptList = printerDraft;
    });
  }

  getPermission() async {
    String permissionString = await CommunFun.getPemission();
    setState(() {
      permissions = permissionString;
    });
  }

  getShift() async {
    String shiftID = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    Shift cShift;
    if (shiftID != null) {
      cShift = (await localAPI.getShiftData(shiftID))[0];
    }
    if (this.mounted) {
      currentShift = cShift;
      drawerData["intial_cash"] = cShift.startAmount.toStringAsFixed(2);
    }
  }

  getBranch() async {
    String brandID = await CommunFun.getbranchId();
    Branch currentBranch = await localAPI.getbranchData();
    String lastCreatedAt =
        DateTime.parse(currentShift.createdAt ?? currentShift.updatedAt)
            .toString();
    if (this.mounted) {
      setState(() {
        branch = currentBranch;
        openShiftDateTime = lastCreatedAt;
      });
    }
  }

  getTerminalID() async {
    String tID = await CommunFun.getTeminalKey();
    if (this.mounted) {
      setState(() {
        terminalID = tID;
      });
    }
  }

  getOrdersData() async {
    Map<String, String> ordersClosingData = await localAPI.getClosingData(
        branch.branchId.toString(), terminalID, openShiftDateTime);
    if (this.mounted) {
      setState(() {
        closingData.addAll(ordersClosingData);
      });
    }
  }

  getPayments() async {
    final payments = await localAPI.getTotalPayment(
        terminalID, branch.branchId, openShiftDateTime);
    if (this.mounted) {
      setState(() {
        paymentList = payments["payment_method"];
        orderPaymentList = payments["payments"];
      });
    }
  }

  getDrawerData() async {
    Map<String, String> drawerClosingData =
        await localAPI.getDrawerData(terminalID, openShiftDateTime);
    if (this.mounted && drawerClosingData != null) {
      setState(() {
        drawerData.addAll(drawerClosingData);
      });
    }
  }

  clearClick() {
    if (this.mounted) {
      setState(() {
        if (isCalculateCash) {
          currentNumber = "0";
          qtyEveryType[currentQtyIndex] = 0;
        } else {
          currentNumber = "0.00";
        }
      });
    }
  }

  closedShift() async {
    User userdata = await CommunFun.getuserDetails();
    Shift updateShift = currentShift;
    double calculateAmount = 0;
    if (this.mounted) {
      setState(() {
        isClosing = true;
        currentQtyIndex = 0;
        currentEditPaymentId = 0;
        currentNumber = "0.00";
      });
    }
    for (var i = 0; i < orderPaymentList.length; i++) {
      int paymentId = orderPaymentList[i].op_method_id;
      calculateAmount += (orderPaymentList[i].op_amount + variance[paymentId]);
    }
    updateShift.status = 1;
    updateShift.serverId = 0;
    updateShift.endAmount = calculateAmount;
    updateShift.updatedBy = userdata.id;
    updateShift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    await Preferences.removeSinglePref(Constant.DASH_SHIFT);
    await Preferences.removeSinglePref(Constant.IS_SHIFT_OPEN);
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    await CommunFun.printClosingData(
      printerreceiptList[0].printerIp.toString(),
      context,
      updateShift,
      permissions,
      paymentList,
      orderPaymentList,
      branch,
      variance,
    );
  }

  backspaceClick() {
    if (currentNumber != "0") {
      String currentnumber =
          currentNumber.replaceAll('.', '').replaceAll("^0+", "");
      currentnumber = currentnumber.substring(0, currentnumber.length - 1);
      if (currentnumber.length == 0) {
        currentnumber = "0";
      }
      if (isCalculateCash) {
      } else {
        if (currentnumber != null && currentnumber.length > 0) {
          switch (currentnumber.length) {
            case 1:
              currentnumber = "0.0" + currentnumber;
              break;
            case 2:
              currentnumber = "0." + currentnumber;
              break;
            default:
              String output = [
                currentnumber.substring(0, currentnumber.length - 2),
                ".",
                currentnumber.substring(currentnumber.length - 2)
              ].join("");
              currentnumber = output;
              break;
          }
        }
      }
      setState(() {
        currentNumber = currentnumber;
        if (isCalculateCash) {
          qtyEveryType[currentQtyIndex] = int.tryParse(currentnumber);
        }
      });
    }
  }

  numberClick(val) {
    // add  value in prev value

    String currentnumber = "";
    if (currentNumber != null) {
      currentnumber = currentNumber.replaceAll('.', '').replaceAll("^0+", "");
    }
    if (double.tryParse(currentnumber) == 0) {
      currentnumber = "";
    } else if (currentnumber != "") {
      currentnumber = int.tryParse(currentnumber).toString();
    }
    currentnumber = currentnumber == "0" ? "" : currentnumber;
    if (isCalculateCash) {
      currentnumber += val;
    } else {
      if (val.length > 3) {
        currentnumber = val;
      } else {
        switch (currentnumber.length + val.length) {
          case 1:
            if (currentnumber == "0" || currentnumber == "") {
              currentnumber = "0.0" + val;
            } else {
              currentnumber = "0." + currentnumber + val;
            }
            break;
          case 2:
            currentnumber = "0." + currentnumber + val;
            break;
          default:
            currentnumber += val;
            String output = [
              currentnumber.substring(0, currentnumber.length - 2),
              ".",
              currentnumber.substring(currentnumber.length - 2)
            ].join("");
            currentnumber = output;
            break;
        }
      }
    }

    /* double totalAmount = totalNeedPaid ?? 0;
    if (double.tryParse(currentnumber) > totalAmount) {
      currentnumber = totalAmount.toString();
    } */
    if (this.mounted && currentNumber != currentnumber) {
      setState(() {
        currentNumber = currentnumber;
        if (isCalculateCash) {
          qtyEveryType[currentQtyIndex] = int.tryParse(currentnumber);
        }
      });
    }
  }

  List<TableRow> paymentWidgetList() {
    return paymentList.map((payment) {
      OrderPayment orderPayment = orderPaymentList
          .firstWhere((ele) => ele.op_method_id == payment.paymentId);
      if (variance[payment.paymentId] == null) {
        variance[payment.paymentId] = 0.00;
      }
      bool isEditable = true;
      if (payment.name.toLowerCase().contains('cash')) {
        isEditable = true;
      }
      return TableRow(
        decoration: BoxDecoration(
          color: currentEditPaymentId == payment.paymentId
              ? Colors.lime[200]
              : Colors.transparent,
        ),
        children: [
          Text(payment.name, style: TextStyle(fontSize: defaultFontSize)),
          Text(
            permissions.contains(Constant.viewSystemAmount)
                ? (orderPayment.op_amount ?? 0).toStringAsFixed(2)
                : "**.**",
            style: TextStyle(fontSize: defaultFontSize),
            textAlign: TextAlign.right,
          ),
          isEditable
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      permissions.contains(Constant.viewSystemAmount)
                          ? (orderPayment.op_amount +
                                  variance[payment.paymentId])
                              .toStringAsFixed(2)
                          : variance[payment.paymentId].toStringAsFixed(2),
                      style: TextStyle(fontSize: defaultFontSize),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: isClosing
                          ? null
                          : () {
                              setState(() {
                                currentEditPaymentId = payment.paymentId;
                                if (calculatePaymentType
                                    .contains(payment.name.toLowerCase())) {
                                  isCalculateCash = true;
                                  currentNumber = "0";
                                } else {
                                  currentNumber =
                                      orderPayment.op_amount.toStringAsFixed(2);
                                }
                              });
                            },
                      child: Icon(
                        FontAwesomeIcons.calculator,
                        size: defaultFontSize * 1.25,
                      ),
                    ),
                  ],
                )
              : Text(
                  orderPayment.op_amount.toStringAsFixed(2),
                  style: TextStyle(fontSize: defaultFontSize),
                  textAlign: TextAlign.right,
                ),
          Text(
            variance[payment.paymentId].toStringAsFixed(2),
            style: TextStyle(fontSize: defaultFontSize),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            height: 35,
          ),
        ],
      );
    }).toList();
  }

  List<TableRow> otherAmountWidgetList() {
    List<String> dataKey = closingData.keys
        .toList()
        .map((key) => getCapitalize(key.replaceAll('_', ' ')))
        .toList();
    List<String> dataVal = closingData.values.toList();
    return dataKey.map((data) {
      int index = dataKey.indexOf(data);
      return TableRow(children: [
        Text(data, style: TextStyle(fontSize: defaultFontSize)),
        Text(
          permissions.contains(Constant.viewSalesAmount)
              ? dataVal[index]
              : '**.**',
          style: TextStyle(fontSize: defaultFontSize),
          textAlign: TextAlign.right,
        ),
        SizedBox(),
        SizedBox(),
        SizedBox(
          height: 35,
        ),
      ]);
    }).toList();
  }

  List<TableRow> cashTypeWidgetList() {
    double calAmount = 0.00;
    return cashType.map((type) {
      int indexOfType = cashType.indexOf(type);
      calAmount += (type * qtyEveryType[indexOfType]);
      if (indexOfType == cashType.length - 1 && this.mounted) {
        setState(() {
          totalCalcAmount = calAmount;
        });
      }
      return TableRow(children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Text(
            (type % 1 != 0
                    ? type.toStringAsFixed(2)
                    : type.toInt().toString()) +
                ' x',
            style: TextStyle(fontSize: defaultFontSize),
            textAlign: TextAlign.right,
          ),
        ),
        GestureDetector(
          onTap: () {
            if (this.mounted) {
              setState(() {
                currentQtyIndex = indexOfType;
              });
            }
          },
          child: Container(
            color: currentQtyIndex == indexOfType
                ? Colors.yellow[200]
                : Colors.white,
            child: Text(
              qtyEveryType[indexOfType].toString(),
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Text(
          (type * qtyEveryType[indexOfType]).toStringAsFixed(2),
          style: TextStyle(fontSize: defaultFontSize),
          textAlign: TextAlign.right,
        ),
        SizedBox(
          height: 30,
        ),
      ]);
    }).toList();
  }

  Widget _button(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (number == "00") ? (resize * 2) : resize,
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.subdirectory_arrow_left, size: 30),
        textColor: Colors.white,
        color: isClosing
            ? Colors.grey
            : (number == Strings.enter ? Colors.green[900] : Colors.grey[100]),
        disabledColor: Colors.grey[100],
        onPressed: isClosing ? null : f,
      ),
    );
  }

  Widget _backbutton(Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: resize,
      padding: EdgeInsets.all(5),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.grey)),
        child: Icon(
          Icons.backspace,
          color: Colors.black,
          size: SizeConfig.safeBlockVertical * 4,
        ),
        textColor: Colors.black,
        color: isClosing ? Colors.grey : Colors.grey[100],
        onPressed: isClosing ? null : f,
      ),
    );
  }

  Widget _clearbutton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: resize,
      padding: EdgeInsets.all(5),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.grey)),
        // child: Icon(
        //   Icons.highlight_remove_sharp,
        //   color: Colors.black,
        //   size: SizeConfig.safeBlockVertical * 4,
        // ),
        child: Text(number),
        textColor: Colors.black,
        color: isClosing ? Colors.grey : Colors.grey[100],
        onPressed: isClosing ? null : f,
      ),
    );
  }

  Widget calculateActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton.icon(
          minWidth: defaultFontSize * 10,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.red,
          icon: Icon(Icons.close, size: defaultFontSize * 2),
          label: Text(
            'Cancel',
            style: TextStyle(fontSize: defaultFontSize * 2),
          ),
          onPressed: () {
            if (this.mounted) {
              setState(() {
                isCalculateCash = false;
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.red),
          ),
        ),
        SizedBox(width: 20),
        FlatButton.icon(
          minWidth: defaultFontSize * 10,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.green,
          icon: Icon(
            Icons.check,
            size: defaultFontSize * 2,
          ),
          label: Text(
            'OK',
            style: TextStyle(fontSize: defaultFontSize * 2),
          ),
          onPressed: () {
            if (orderPaymentList.length > 0 && currentEditPaymentId > 0) {
              OrderPayment orderPayment = orderPaymentList.firstWhere(
                  (ele) => ele.op_method_id == currentEditPaymentId);
              variance[currentEditPaymentId] =
                  totalCalcAmount - orderPayment.op_amount;
              setState(() {
                currentQtyIndex = 0;
                currentEditPaymentId = 0;
                isCalculateCash = false;
                currentNumber = "0.00";
              });
            } else if (currentEditPaymentId == 0 && this.mounted) {
              setState(() {
                isCalculateCash = false;
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget drawerInfo() {
    return Table(children: [
      TableRow(children: [
        Text("Intial Cash", style: TextStyle(fontSize: defaultFontSize)),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Text(
            drawerData["intial_cash"] ?? "0.00",
            style: TextStyle(fontSize: defaultFontSize),
            textAlign: TextAlign.right,
          ),
        ),
        Text("Cash In", style: TextStyle(fontSize: defaultFontSize)),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Text(
            drawerData["cash_in"] ?? "0.00",
            style: TextStyle(fontSize: defaultFontSize),
            textAlign: TextAlign.right,
          ),
        ),
        Text("Cash Out", style: TextStyle(fontSize: defaultFontSize)),
        Text(
          drawerData["cash_out"] ?? "0.00",
          style: TextStyle(fontSize: defaultFontSize),
          textAlign: TextAlign.right,
        ),
        Padding(
          padding: EdgeInsets.only(right: 50),
        ),
      ])
    ]);
  }

  Widget calculateCash() {
    OrderPayment currentOrderPayment = orderPaymentList.firstWhere(
        (ele) => ele.op_method_id == currentEditPaymentId,
        orElse: () => null);
    return Column(
      children: [
        //TableRow(children: [Text('height: 10,')]),
        Table(columnWidths: {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
          3: FixedColumnWidth(1),
        }, children: [
          TableRow(children: [
            SizedBox(),
            Text('System Amount', style: TextStyle(fontSize: defaultFontSize)),
            Text(
              (currentOrderPayment != null
                  ? currentOrderPayment.op_amount.toStringAsFixed(2)
                  : "0.00"),
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.right,
            ),
            SizedBox(),
          ])
        ]),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          thickness: 3,
        ),
        SizedBox(
          height: 10,
        ),
        Table(columnWidths: {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(3),
          3: FixedColumnWidth(1),
        }, children: [
          TableRow(children: [
            Text(
              'Charge',
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.right,
            ),
            Text(
              'Quantity',
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.center,
            ),
            Text(
              'Amount',
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.right,
            ),
            SizedBox(),
          ])
        ]),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(children: [
              Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                columnWidths: {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(3),
                  3: FixedColumnWidth(1),
                },
                children: cashTypeWidgetList(),
              ),
            ]),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          thickness: 3,
        ),
        SizedBox(
          height: 10,
        ),

        Table(columnWidths: {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
          3: FixedColumnWidth(1),
        }, children: [
          TableRow(children: [
            SizedBox(),
            Container(
              color: qtyEveryType.length == currentQtyIndex
                  ? Colors.yellow[200]
                  : Colors.transparent,
              child: Text('Total',
                  style: TextStyle(
                    fontSize: defaultFontSize,
                  )),
            ),
            Container(
              color: qtyEveryType.length == currentQtyIndex
                  ? Colors.yellow[200]
                  : Colors.transparent,
              child: Text(
                totalCalcAmount.toStringAsFixed(2),
                style: TextStyle(fontSize: defaultFontSize),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(),
          ])
        ]),
      ],
    );
  }

  Widget paymentTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Table(defaultColumnWidth: FixedColumnWidth(120), columnWidths: {
          0: FixedColumnWidth(200),
          4: FixedColumnWidth(1),
        }, children: [
          TableRow(children: [
            Text('Payment Type', style: TextStyle(fontSize: defaultFontSize)),
            Text(
              'System Amount',
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.right,
            ),
            Text(
              'Collected',
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.right,
            ),
            Text(
              'Variance',
              style: TextStyle(fontSize: defaultFontSize),
              textAlign: TextAlign.right,
            ),
            SizedBox(),
          ])
        ]),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Table(
                        defaultColumnWidth: FixedColumnWidth(120),
                        columnWidths: {
                          0: FixedColumnWidth(200),
                          4: FixedColumnWidth(1),
                        },
                        children: otherAmountWidgetList()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Table(
                        defaultColumnWidth: FixedColumnWidth(120),
                        columnWidths: {
                          0: FixedColumnWidth(200),
                          4: FixedColumnWidth(1),
                        },
                        children: paymentWidgetList()),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double defaultHeight = MediaQuery.of(context).size.height;
    return Material(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 10),
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: defaultHeight * .1,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Closing',
                      style: TextStyle(
                        fontSize: defaultFontSize * 2,
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.green),
                            ),
                            color: isClosing ? Colors.grey : Colors.green[400],
                            child: InkWell(
                              onTap: isClosing
                                  ? null
                                  : () {
                                      closedShift();
                                    },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save),
                                    Text(
                                      'Confirm',
                                      style:
                                          TextStyle(fontSize: defaultFontSize),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.green),
                            ),
                            color: Colors.brown[200],
                            child: InkWell(
                              onTap: () async {
                                await SyncAPICalls.logActivity("transaction",
                                    "Click view Transaction", "transaction", 1);
                                Navigator.pushNamed(
                                    context, Constant.TransactionScreen);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.art_track),
                                    Text(
                                      Strings.transaction,
                                      style:
                                          TextStyle(fontSize: defaultFontSize),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.green),
                            ),
                            color: isClosing ? Colors.grey : Colors.blue[200],
                            child: InkWell(
                              onTap: () async {
                                await SyncAPICalls.logActivity("open drawer",
                                    "Cashier click open drawer", "drawer", 1);
                                if (printerreceiptList.length == 0) {
                                  return CommunFun.showToast(
                                      context, Strings.printerNotAvailable);
                                }
                                PrintReceipt printKOT = PrintReceipt();
                                Function printReceipt = () =>
                                    printKOT.testReceiptPrint(
                                        printerreceiptList[0]
                                            .printerIp
                                            .toString(),
                                        context,
                                        "",
                                        Strings.openDrawer,
                                        true);
                                if (permissions
                                    .contains(Constant.OPEN_DRAWER)) {
                                  printReceipt();
                                } else {
                                  await CommonUtils.openPermissionPop(
                                      context, Constant.OPEN_DRAWER, () async {
                                    await SyncAPICalls.logActivity(
                                        "open drawer",
                                        "Manager given permission for open drawer",
                                        "drawer",
                                        1);
                                    printReceipt();
                                  }, () {});
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.all_inbox_outlined),
                                    Text(
                                      "Open Cash Drawer",
                                      style:
                                          TextStyle(fontSize: defaultFontSize),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.green),
                            ),
                            color: isClosing ? Colors.white : Colors.grey,
                            child: InkWell(
                              onTap: () {
                                if (this.mounted) {
                                  setState(() {
                                    isClosing = false;
                                  });
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.undo),
                                    Text(
                                      'Redo Closing',
                                      style:
                                          TextStyle(fontSize: defaultFontSize),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.green),
                            ),
                            color: Colors.red[400],
                            child: InkWell(
                              onTap: () {
                                if (isClosing) {
                                  Navigator.of(context).popAndPushNamed(
                                      Constant.SelectTableScreen,
                                      arguments: {"isAssign": false});
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close),
                                    Text(
                                      'Close',
                                      style:
                                          TextStyle(fontSize: defaultFontSize),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Flexible(flex: 1, child: Text('')),
                                Expanded(
                                  flex: 5,
                                  child: isCalculateCash
                                      ? calculateCash()
                                      : paymentTypes(),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.3 /
                                          6 *
                                          4,
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical * 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          color: isClosing
                                              ? Colors.grey
                                              : Colors.grey[200],
                                        ),
                                        padding: EdgeInsets.all(
                                            SizeConfig.safeBlockVertical * 1),
                                        child: Text(
                                          currentNumber ?? "0.00",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: defaultFontSize * 1.25),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    _button("7", () {
                                      numberClick('7');
                                    }), // using custom widget button
                                    _button("8", () {
                                      numberClick('8');
                                    }),
                                    _button("9", () {
                                      numberClick('9');
                                    }),
                                    _backbutton(() {
                                      backspaceClick();
                                    }),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    _button("4", () {
                                      numberClick('4');
                                    }), // using custom widget button
                                    _button("5", () {
                                      numberClick('5');
                                    }),
                                    _button("6", () {
                                      numberClick('6');
                                    }),

                                    _clearbutton("CLR", () {
                                      clearClick();
                                    }),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _button("1", () {
                                                numberClick('1');
                                              }),
                                              _button("2", () {
                                                numberClick('2');
                                              }),
                                              _button("3", () {
                                                numberClick('3');
                                              }),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              _button("0", () {
                                                numberClick('0');
                                              }),
                                              _button("00", () {
                                                numberClick('00');
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                      _button(Strings.enter, () {
                                        OrderPayment orderPayment =
                                            orderPaymentList.firstWhere((ele) =>
                                                ele.op_method_id ==
                                                currentEditPaymentId);
                                        Payments currentPayment =
                                            paymentList.firstWhere((ele) =>
                                                ele.paymentId ==
                                                currentEditPaymentId);
                                        if (isCalculateCash &&
                                            currentQtyIndex >
                                                ((qtyEveryType.length - 1) /
                                                    2)) {
                                          _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.ease,
                                          );
                                        }
                                        /* if (isCalculateCash &&
                                            qtyEveryType.length - 1 ==
                                                currentQtyIndex) {} */
                                        setState(() {
                                          if (isCalculateCash) {
                                            if (qtyEveryType.length ==
                                                currentQtyIndex) {
                                              currentQtyIndex = 0;
                                              isCalculateCash = false;
                                              currentNumber = "0.00";
                                              variance[currentEditPaymentId] =
                                                  totalCalcAmount -
                                                      orderPayment.op_amount;
                                            } else {
                                              qtyEveryType[currentQtyIndex] =
                                                  int.tryParse(currentNumber);
                                              currentQtyIndex++;
                                              currentNumber = "0";
                                            }
                                          } else {
                                            if (calculatePaymentType.contains(
                                                currentPayment.name
                                                    .toLowerCase())) {
                                            } else {
                                              variance[currentEditPaymentId] =
                                                  double.tryParse(
                                                          currentNumber) -
                                                      orderPayment.op_amount;
                                            }
                                            currentNumber = "0.00";
                                            currentEditPaymentId = 0;
                                          }
                                        });
                                      })
                                    ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: isCalculateCash
                            ? calculateActionBar()
                            : drawerInfo()),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
