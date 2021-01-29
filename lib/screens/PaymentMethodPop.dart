import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/screens/CashPayment.dart';
import 'package:mcncashier/screens/FinalPaymentScreen.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/screens/SubPaymentMethodPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class PaymentMethodPop extends StatefulWidget {
  // Opning ammount popup
  PaymentMethodPop(
      {Key key,
      this.subTotal,
      this.grandTotal,
      this.onClose,
      this.currentMode = ""})
      : super(key: key);
  final double grandTotal;
  final double subTotal;
  final String currentMode;
  Function onClose;

  @override
  PaymentMethodPopState createState() => PaymentMethodPopState();
}

class PaymentMethodPopState extends State<PaymentMethodPop> {
  // OrderPayment orderpayment = new OrderPayment();
  List<Payments> paymenttyppeList = [];
  List<Payments> allPaymentTypes = [];
  List<OrderPayment> splitpaymentList = [];
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  LocalAPI localAPI = LocalAPI();
  bool isLoading = false;
  var errorMSG = "";
  var newAmmount;
  bool ispaymented = true;
  double updatedAmmount = 0.00;
  bool isSpliting = false;
  double splitedPayment = 0.00;
  Branch branchdata;
  Payments seletedPayment;
  MST_Cart cartData;
  TextEditingController digitController = new TextEditingController();
  TextEditingController codeInput = new TextEditingController();
  TextEditingController remarkInputController = new TextEditingController();
  TextEditingController refInputController = new TextEditingController();
  List walletList = [
    "ewallet",
    "e-wallet",
    "e wallet",
    "ipay88",
    "i-pay88",
    "i pay88",
    "i-pay 88",
    "i pay 88"
  ];
  @override
  void initState() {
    super.initState();
    setState(() {
      newAmmount = widget.grandTotal;
      updatedAmmount = widget.grandTotal;
    });
    getPaymentMethods();
  }

  getPaymentMethods() async {
    var result = await localAPI.getPaymentMethods();
    List<Payments> mainPaymentList = result
        .where((i) => i.isParent == 0 && i.name.toLowerCase().contains('cash'))
        .toList();
    if (result.length != 0) {
      setState(() {
        paymenttyppeList = mainPaymentList;
        allPaymentTypes = result;
      });
    }
    await SyncAPICalls.logActivity(
        "payment", "Opened payments listing popup", "payment", 1);
  }

  insertPaymentOption(Payments payment) {
    if (walletList.contains(seletedPayment.name.toLowerCase())) {
      setState(() {
        seletedPayment = payment;
      });
      enterwalletOption();
    } else if (seletedPayment.name.toLowerCase().contains("card")) {
      setState(() {
        seletedPayment = payment;
      });
      enterDigitCode();
    } else {
      cashPayment(payment);
    }
  }

  cashPayment(Payments payment) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return CashPaymentPage(
              paymentType: payment,
              ammountext: updatedAmmount,
              onEnter: (ammount) {
                Navigator.of(context).pop();
                if (widget.currentMode == "refund") {
                  showFinalScreenDialog(payment, double.parse(ammount));
                  return true;
                } else if (double.parse(ammount) < widget.grandTotal) {
                  setState(() {
                    isSpliting = true;
                    ispaymented = false;
                  });
                } else {
                  finalPayment(payment, double.parse(ammount));
                }
              });
        });
  }

  showFinalScreenDialog(payment, ammount) async {
    List<OrderPayment> totalPayment = [];
    OrderPayment orderpayment = new OrderPayment();
    orderpayment.op_method_id = payment.paymentId;
    orderpayment.remark = remarkInputController.text;
    orderpayment.approval_code = codeInput.text;
    orderpayment.last_digits = digitController.text;
    orderpayment.reference_number = refInputController.text;
    orderpayment.is_split = isSpliting ? 1 : 0;
    orderpayment.op_amount = (ammount * -1);
    double change = 0.0;
    if (ammount > widget.grandTotal) {
      change = ammount - widget.grandTotal;
      orderpayment.op_amount_change = change;
    }
    totalPayment.add(orderpayment);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return FinalEndScreen(
          total: widget.grandTotal,
          totalPaid: 0,
          change: ammount, //* -1),
          onClose: () {
            Navigator.of(context).pop();
            widget.onClose(totalPayment);
          },
        );
      },
    );
  }

  finalPayment(Payments payment, ammount) async {
    List<OrderPayment> totalPayment = [];
    if (!isSpliting) {
      OrderPayment orderpayment = new OrderPayment();
      orderpayment.op_method_id = payment.paymentId;
      orderpayment.remark = remarkInputController.text;
      orderpayment.approval_code = codeInput.text;
      orderpayment.last_digits = digitController.text;
      orderpayment.reference_number = refInputController.text;
      orderpayment.is_split = isSpliting ? 1 : 0;
      orderpayment.op_amount = ammount;
      double change = 0.0;
      if (ammount > widget.grandTotal) {
        change = ammount - widget.grandTotal;
        orderpayment.op_amount_change = change;
      }
      orderpayment.isCash = payment.name.toLowerCase() == "cash" ? 1 : 0;
      totalPayment.add(orderpayment);
      await SyncAPICalls.logActivity("payment",
          "Select for payment" + payment.name.toString(), "payment", 1);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return FinalEndScreen(
                total: widget.grandTotal,
                totalPaid: ammount,
                change: change,
                onClose: () {
                  widget.onClose(totalPayment);
                });
          });
    } else if (isSpliting && splitedPayment >= widget.grandTotal) {
      for (var i = 0; i < splitpaymentList.length; i++) {
        OrderPayment orderpayment = splitpaymentList[i];
        totalPayment.add(orderpayment);
      }
      double change = 0.0;
      if (splitedPayment > widget.grandTotal) {
        change = splitedPayment - widget.grandTotal;
      }
      await SyncAPICalls.logActivity("payment",
          "Select for payment" + payment.name.toString(), "payment", 1);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return FinalEndScreen(
                total: widget.grandTotal,
                totalPaid: splitedPayment,
                change: change,
                onClose: () {
                  Navigator.of(context).pop();
                  widget.onClose(totalPayment);
                });
          });
    } else {
      var lastamount = widget.grandTotal;
      if (splitpaymentList.length > 0) {
        for (var i = 0; i < splitpaymentList.length; i++) {
          OrderPayment orderpayment = splitpaymentList[i];
          totalPayment.add(orderpayment);
          lastamount = lastamount - orderpayment.op_amount;
        }
      }
      OrderPayment orderpayment = new OrderPayment();
      orderpayment.op_amount = ammount;
      orderpayment.op_method_id = seletedPayment.paymentId;
      orderpayment.remark = remarkInputController.text;
      orderpayment.approval_code = codeInput.text;
      orderpayment.last_digits = digitController.text;
      orderpayment.reference_number = refInputController.text;
      orderpayment.is_split = isSpliting ? 1 : 0;
      lastamount = lastamount - orderpayment.op_amount;
      setState(() {
        splitedPayment = splitedPayment + ammount;
        updatedAmmount = lastamount;
        splitpaymentList = totalPayment;
        ispaymented = true;
      });
      double change = 0.0;
      if (splitedPayment > widget.grandTotal) {
        change = splitedPayment - widget.grandTotal;
        orderpayment.op_amount_change = change;
      }
      await SyncAPICalls.logActivity("payment",
          "Select for payment" + payment.name.toString(), "payment", 1);
      totalPayment.add(orderpayment);
      if (splitedPayment >= widget.grandTotal) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return FinalEndScreen(
                  total: widget.grandTotal,
                  totalPaid: splitedPayment,
                  change: change,
                  onClose: () {
                    Navigator.of(context).pop();
                    widget.onClose(totalPayment);
                  });
            });
      }
      refInputController.text = "";
      remarkInputController.text = "";
      codeInput.text = "";
      digitController.text = "";
    }
  }

  enterwalletOption() {
    showEwalletoptionPop(context);
  }

  enterDigitCode() {
    showEnterPinPop(context);
  }

  checkPIN() {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      cashPayment(seletedPayment);
    }
  }

  checkRefNum() {
    if (_formKey1.currentState.validate()) {
      Navigator.of(context).pop();
      cashPayment(seletedPayment);
      // finalPayment(seletedPayment);
    }
  }

  closeSplit() {
    setState(() {
      isSpliting = false;
      ispaymented = false;
    });
  }

  // splitPayment() {
  //   setState(() {
  //     isSpliting = true;
  //     ispaymented = false;
  //   });

  //   showDialog(
  //       // Opning Ammount Popup
  //       context: context,
  //       builder: (BuildContext context) {
  //         return OpeningAmmountPage(
  //             ammountext: newAmmount.toString(),
  //             onEnter: (ammount) {
  //               double newap = splitedPayment + double.parse(ammount);
  //               setState(() {
  //                 splitedPayment = newap;
  //                 updatedAmmount = double.parse(ammount);
  //               });
  //               OrderPayment payment = new OrderPayment();
  //               payment.op_amount =
  //                   ammount != null ? double.parse(ammount) : newAmmount;
  //               splitpaymentList.add(payment);
  //               setState(() {
  //                 splitpaymentList = splitpaymentList;
  //               });
  //             });
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            decoration: BoxDecoration(
              color: StaticColor.colorWhite,
              border: Border(
                bottom: BorderSide(color: StaticColor.colorBlack),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Total", style: Styles.blackMediumBold()),
                Text(widget.grandTotal.toStringAsFixed(2),
                    style: Styles.blackMediumBold()),
              ],
            ),
          ),
          closeButton(context), //popup close btn
        ],
      ),
      content: mainContent(), // Popup body contents
    );
  }

  Widget mainContent() {
    return Container(
      //height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width / 3,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: paymenttyppeList.map((payment) {
                return ListTile(
                    contentPadding: EdgeInsets.all(5),
                    leading: Hero(
                      tag: payment.paymentId != null ? payment.paymentId : 0,
                      child: Container(
                        //color: StaticColor.colorGrey,
                        width: 40,
                        height: 40,
                        child: payment.base64 != ""
                            ? CommonUtils.imageFromBase64String(payment.base64)
                            : new Image.asset(
                                Strings.noImageAsset,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      ),
                    ),
                    /*Icon(
                payment.name.contains("Wallet")
                    ? Icons.account_balance_wallet
                    : Icons.credit_card,
                color: StaticColor.colorBlack,
                size: SizeConfig.safeBlockVertical * 7,
              ),*/
                    // Container(
                    //     height: 70,
                    //     width: 70,
                    //     child: Image.asset("assets/bg.jpg")),
                    onTap: () {
                      setState(() {
                        seletedPayment = payment;
                      });
                      List<Payments> subList = allPaymentTypes
                          .where((i) => i.isParent == payment.paymentId)
                          .toList();
                      if (subList.length > 0) {
                        openSubPaymentDialog(subList);
                      } else {
                        insertPaymentOption(payment);
                      }
                    },
                    title: Text(payment.name, style: Styles.blackMediumBold()),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: StaticColor.colorBlack,
                      size: SizeConfig.safeBlockVertical * 4,
                    ));
              }).toList(),
            ),
            /* Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: StaticColor.colorGrey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              child: ListTile(
                // onTap: () {
                //   {
                //     splitPayment();
                //   }
                // },
                // leading: IconButton(
                //   onPressed: () {
                //    // closeSplit();
                //   },
                //   icon: Icon(
                //     ispaymented ? Icons.call_split : Icons.close,
                //     color: StaticColor.colorBlack,
                //     size: SizeConfig.safeBlockVertical * 4,
                //   ),
                // ),
                title: Text(
                  "Ammount to Pay",
                  // "Ammount to Pay",
                  style: Styles.blackMediumBold(),
                ),
                trailing: Text(
                  updatedAmmount.toStringAsFixed(2),
                  style: Styles.blackMediumBold(),
                ),
              ),
            ) */
          ],
        ),
      ),
    );
  }

  openSubPaymentDialog(List<Payments> subList) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return SubPaymentMethodPop(
            subList: subList,
            subTotal: widget.subTotal,
            grandTotal: updatedAmmount,
            onClose: (mehtod) {
              Navigator.of(context).pop();
              insertPaymentOption(mehtod);
            },
          );
        });
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

  showEnterPinPop(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.all(20),
          title: Center(child: Text("Card Payment")),
          content: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            height: MediaQuery.of(context).size.height / 2.4,
            child: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(Strings.enterLast, style: Styles.blackMediumBold()),
                  SizedBox(
                    height: 20,
                  ),
                  digitInput(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(Strings.approvalCode, style: Styles.blackMediumBold()),
                  SizedBox(
                    height: 20,
                  ),
                  approvalCode(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(Strings.remark, style: Styles.blackMediumBold()),
                  SizedBox(
                    height: 20,
                  ),
                  remarkInput()
                ],
              ),
            )),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(Strings.cancel, style: Styles.orangeSmall()),
            ),
            FlatButton(
              onPressed: () {
                checkPIN();
              },
              child: Text(Strings.done, style: Styles.orangeSmall()),
            ),
          ],
        );
      },
    );
  }

  Widget digitInput() {
    return TextFormField(
      controller: digitController,
      validator: (value) {
        if (value.isEmpty) {
          return Strings.digitValidationMsg;
        } else if (value.length < 4) {
          return Strings.minimumReqMsg;
        }
        return null;
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        WhitelistingTextInputFormatter.digitsOnly
      ],
      keyboardType: TextInputType.number,
      maxLength: 4,
      decoration: InputDecoration(
        errorStyle: TextStyle(
            color: StaticColor.colorRed,
            fontSize: SizeConfig.safeBlockVertical * 2),
        hintText: Strings.enterDigit,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 2,
            color: StaticColor.colorGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        filled: true,
        contentPadding: EdgeInsets.all(15),
        fillColor: StaticColor.colorWhite,
      ),
      style: Styles.greysmall(),
      onChanged: (e) {
        setState(() {
          errorMSG = "";
        });
      },
    );
  }

  Widget approvalCode() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return Strings.approvalCodeMsg;
        }
        return null;
      },
      controller: codeInput,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        errorStyle: TextStyle(
            color: StaticColor.colorRed,
            fontSize: SizeConfig.safeBlockVertical * 2),
        hintText: Strings.enterCode,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 2,
            color: StaticColor.colorGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        filled: true,
        contentPadding: EdgeInsets.all(15),
        fillColor: StaticColor.colorWhite,
      ),
      style: Styles.greysmall(),
      onChanged: (e) {
        setState(() {
          errorMSG = "";
        });
      },
    );
  }

  Widget remarkInput() {
    return TextFormField(
      controller: remarkInputController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        errorStyle: TextStyle(
            color: StaticColor.colorRed,
            fontSize: SizeConfig.safeBlockVertical * 2),
        hintText: Strings.enterRemark,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 2,
            color: StaticColor.colorGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        filled: true,
        contentPadding: EdgeInsets.all(15),
        fillColor: StaticColor.colorWhite,
      ),
      style: Styles.greysmall(),
      onChanged: (e) {
        setState(() {
          errorMSG = "";
        });
      },
    );
  }

  Widget refInput() {
    return TextFormField(
      controller: refInputController,
      validator: (value) {
        if (value.isEmpty) {
          return Strings.referenceNumMsg;
        }
        return null;
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        errorStyle: TextStyle(
            color: StaticColor.colorRed,
            fontSize: SizeConfig.safeBlockVertical * 2),
        hintText: Strings.enterRefNum,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 2,
            color: StaticColor.colorGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: StaticColor.colorGrey),
        ),
        filled: true,
        contentPadding: EdgeInsets.all(15),
        fillColor: StaticColor.colorWhite,
      ),
      style: Styles.greysmall(),
      onChanged: (e) {
        setState(() {
          errorMSG = "";
        });
      },
    );
  }

  showEwalletoptionPop(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.all(20),
          title: Center(child: Text(Strings.walletPayment)),
          content: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            height: MediaQuery.of(context).size.height / 2.4,
            child: SingleChildScrollView(
                child: Form(
              key: _formKey1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(Strings.enterRefNum, style: Styles.blackMediumBold()),
                  SizedBox(
                    height: 20,
                  ),
                  refInput(),
                  SizedBox(
                    height: 20,
                  ),
                  Text(Strings.remark, style: Styles.blackMediumBold()),
                  SizedBox(
                    height: 20,
                  ),
                  remarkInput()
                ],
              ),
            )),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(Strings.cancel, style: Styles.orangeSmall()),
            ),
            FlatButton(
              onPressed: () {
                checkRefNum();
              },
              child: Text(Strings.done, style: Styles.orangeSmall()),
            ),
          ],
        );
      },
    );
  }
}
