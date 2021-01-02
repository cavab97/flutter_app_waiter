import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class DiscountPad extends StatefulWidget {
  // Opning ammount popup
  DiscountPad({
    Key key,
    this.selectedProduct,
    this.issetMeal,
    this.cartID,
    this.onClose,
  }) : super(key: key);

  final bool issetMeal;
  final MSTCartdetails selectedProduct;
  final int cartID;
  Function onClose;

  @override
  _DiscountPadState createState() => _DiscountPadState();
}

class _DiscountPadState extends State<DiscountPad> {
  double paidAmount = 0;
  String currentNumber = "0";
  String currentDiscountType = "RM";
  LocalAPI localAPI = LocalAPI();
  double totalAmount = 0;
  TextEditingController extraNotes = new TextEditingController();
  MST_Cart currentCart = new MST_Cart();
  FocusNode myFocusNode = FocusNode();
  bool validNotes = false;
  bool isEnter = false;
  @override
  void initState() {
    super.initState();
    setState(() {});
    currentNumber = totalAmount.toStringAsFixed(2);
    if (widget.selectedProduct != null) {
      extraNotes.text = widget.selectedProduct.discountRemark ?? "";
      dicsountTypeClick(widget.selectedProduct.discountType == 1 ? "%" : "RM");
      currentNumber = widget.selectedProduct.discountAmount.toStringAsFixed(2);
    } else {
      getCart();
    }
    extraNotes.addListener(() {
      if (!isEnter) isEnter = true;
      if (!validNotes && extraNotes.text.trim().isNotEmpty && this.mounted) {
        setState(() {
          validNotes = true;
        });
      } else if (this.mounted &&
          extraNotes.text.trim().isEmpty &&
          extraNotes.text.length > 0) {
        setState(() {
          validNotes = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    if (myFocusNode != null) myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal,
            vertical: SizeConfig.safeBlockVertical),
        height: SizeConfig.safeBlockVertical * 9,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.black),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal,
                  vertical: SizeConfig.safeBlockVertical),
              child: Text(
                "Discount" + (widget.selectedProduct == null ? ' Bill' : ''),
                style: Styles.communBlack(),
              ),
              // Text(
              //     currentDiscountType == "RM"
              //         ? currentDiscountType +
              //             CommunFun.getDecimalFormat(currentNumber)
              //         : CommunFun.getDecimalFormat(currentNumber) +
              //             currentDiscountType,
              //     style: Styles.communBlack()),
            ),
            Spacer(),
            CloseButtonWidget(inputContext: context),
          ],
        ),
      ),
      content: getNumbers(context), // Popup body contents
    );
  }

  getCart() async {
    MST_Cart getCart = await localAPI.getCartData(widget.cartID);
    dicsountTypeClick(getCart.discountType == 1 ? "%" : "RM");
    setState(() {
      currentNumber = getCart.discountAmount.toStringAsFixed(2);
      extraNotes.text = getCart.discountRemark;
      currentCart = getCart;
    });
  }

  backspaceClick() {
    if (currentNumber != "0") {
      String currentnumber =
          currentNumber.replaceAll('.', '').replaceAll("^0+", "");
      currentnumber = currentnumber.substring(0, currentnumber.length - 1);
      if (currentnumber.length == 0 && this.mounted) {
        setState(() {
          currentNumber = "0.00";
        });
      } else if (currentnumber != null && currentnumber.length > 0) {
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
        setState(() {
          currentNumber = currentnumber;
        });
      }
    }
  }

  clearClick() {
    if (this.mounted) {
      setState(() {
        currentNumber = "0.00";
      });
    }
  }

  numberClick(val) {
    // add  value in prev value

    String currentnumber =
        currentNumber.replaceAll('.', '').replaceAll("^0+", "");
    currentnumber = currentnumber == "0" ? "" : currentnumber;
    switch (currentnumber.length + val.length) {
      case 1:
        if (currentnumber == "0" || currentnumber == "") {
          currentnumber = "0.0" + val;
        } else {
          currentnumber = "0." + currentnumber + val;
        }
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
    double totalAmount = 0;
    if (widget.selectedProduct != null) {
      if (widget.selectedProduct.discountType == 1) {
        totalAmount = widget.selectedProduct.productDetailAmount /
            (1 - (widget.selectedProduct.discountAmount / 100));
      } else {
        totalAmount = widget.selectedProduct.discountAmount +
            widget.selectedProduct.productDetailAmount;
      }
    } else {
      totalAmount = currentCart.sub_total;
    }

    if (currentDiscountType == "RM" &&
        double.tryParse(currentnumber) > totalAmount) {
      currentnumber = totalAmount.toString();
    } else if (currentDiscountType == "%" &&
        double.tryParse(currentnumber) > 100) {
      currentnumber = "100.00";
    }
    if (this.mounted && currentNumber != currentnumber) {
      setState(() {
        currentNumber = currentnumber;
      });
    }
  }

  setDiscount() async {
    if (extraNotes.text.isEmpty && this.mounted) {
      setState(() {
        isEnter = true;
      });
      if (myFocusNode != null) {
        myFocusNode.requestFocus();
      }
    } else {
      if (widget.selectedProduct != null) {
        await localAPI.updateItemDiscount(widget.selectedProduct, widget.cartID,
            currentNumber, currentDiscountType, extraNotes.text.trim());
      } else {
        await localAPI.applyBillDiscount(widget.cartID, currentNumber,
            currentDiscountType, extraNotes.text.trim());
      }
      Navigator.of(context).pop();
      widget.onClose();
    }
  }

  bool validateTextField(String userInput) {
    if (userInput == null || (userInput.isEmpty)) {
      return false;
    }
    return true;
  }

  dicsountTypeClick(val) {
    // add  value in prev value

    if (this.mounted) {
      setState(() {
        currentDiscountType = val;
        currentNumber = "0";
      });
      if (val == "RM") {
      } else if (val == "%") {}
    }
  }

  Widget mainContent() {
    return getNumbers(context);
  }

  Widget _button(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    Color buttonColor = Colors.grey[100];
    if (number == Strings.enter) {
      buttonColor = Colors.green[900];
    } else if ((number == "%" && currentDiscountType == "%") ||
        (number == "Cash" && currentDiscountType != "%")) {
      buttonColor = Colors.orange[200];
    }
    return Container(
      width: (number == "00") || (number == "%") || (number == "Cash")
          ? (resize * 2)
          : resize,
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.save, size: 30),
        textColor: Colors.white,
        color: buttonColor,
        onPressed: f,
      ),
    );
  }

  Widget _totalbutton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (resize * 4),
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.whiteMediumBold())
            : Icon(
                Icons.subdirectory_arrow_left,
                size: 30,
                color: Colors.white,
              ),
        textColor: Colors.black,
        color: Colors.blue[900],
        onPressed: f,
      ),
    );
  }

  Widget splshsButton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Expanded(
      child: Container(
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
          textColor: Colors.black,
          color: Colors.grey[100],
          onPressed: f,
        ),
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
        color: Colors.grey[100],
        onPressed: f,
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
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getNumbers(context) {
    return Container(
      // height: MediaQuery.of(context).size.height / 1.2,
      width: MediaQuery.of(context).size.width * .6,
      child: SingleChildScrollView(
          child: Table(
        border: TableBorder.all(color: Colors.white, width: 0.6),
        columnWidths: {
          0: FractionColumnWidth(.4),
          1: FractionColumnWidth(.5),
        },
        children: [
          TableRow(children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: RichText(
                          maxLines: 4,
                          text: TextSpan(
                              text: "Amount",
                              style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: SizeConfig.safeBlockVertical * 3,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: Strings.fontFamily),
                              children: <TextSpan>[
                                TextSpan(
                                  text: currentDiscountType == "RM"
                                      ? "\n" +
                                          currentDiscountType +
                                          double.parse(currentNumber)
                                              .toStringAsFixed(2)
                                      : "\n" +
                                          double.parse(currentNumber)
                                              .toStringAsFixed(2) +
                                          currentDiscountType,
                                  style: TextStyle(
                                      color: Color(0xFF0D47A1),
                                      fontSize:
                                          SizeConfig.safeBlockVertical * 4,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: Strings.fontFamily),
                                )
                              ])),
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _extraNotesTitle(),
                    ),
                    SizedBox(height: 5),
                    inputNotesView()
                  ],
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _button("Cash", () {
                            dicsountTypeClick('RM');
                          }), // using custom widget button
                          _button("%", () {
                            dicsountTypeClick('%');
                          }),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _button("7", () {
                        numberClick('7');
                      }),
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
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  Row(children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _button("1", () {
                              numberClick('1');
                            }), // using custom widget button
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
                    _button(Strings.enter, setDiscount),
                  ]),
                ],
              ),
            )
          ])
        ],
      )),
    );
  }

  Widget notesInput() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            border: isEnter && !validNotes
                ? Border.all(color: Colors.red)
                : Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        height: 200,
        padding: EdgeInsets.all(10),
        child: TextField(
          focusNode: myFocusNode,
          controller: extraNotes,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3, height: 1.2),
          maxLines: 10,
          // decoration: new InputDecoration(
          //   border: OutlineInputBorder(
          //     borderSide: BorderSide(color: Colors.greenAccent, width: 100.0),
          //   ),
          //   // hintText: product_qty.toDouble().toString(),
          // ),
          decoration: new InputDecoration(
              border: InputBorder.none,
              errorText: isEnter && !validNotes
                  ? "Please enter notes for this discount"
                  : null
              // hintText: product_qty.toDouble().toString(),
              ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(0),
        //height: 170, // MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: StaticColor.lightGrey100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[notesInput()],
          ),
        ));
  }

  Widget _extraNotesTitle() {
    return Text(
      Strings.notesAndQty,
      style: TextStyle(
          fontSize: SizeConfig.safeBlockVertical * 3,
          fontWeight: FontWeight.w400,
          color: StaticColor.colorGrey800),
    );
  }
}
