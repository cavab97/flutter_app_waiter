import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';

class PINPage extends StatefulWidget {
  // PIN Enter PAGE
  PINPage({Key key}) : super(key: key);

  @override
  _PINPageState createState() => _PINPageState();
}

class _PINPageState extends State<PINPage> {
  var pinNumber = "";
  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  addINPin(val) {
    if (pinNumber.length < 4) {
      var currentpinNumber = pinNumber;
      currentpinNumber += val;
      print(currentpinNumber);
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

  clockInwithPIN() {
    if (pinNumber.length >= 4) {
      //TODO : API CALL for clockin
      Navigator.pushNamed(context, Constant.DashboardScreen);
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(Strings.pin_validation_message),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: Center(
          child: Container(
            //page background image
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white),
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      imageview(context), // Part 1 image with logo
                      getNumbers(context) // Part 2  Muber keypade
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget imageview(context) {
    return Container(
        width: MediaQuery.of(context).size.width / 2.9,
        decoration: BoxDecoration(
          color: Colors.grey,
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
                  height: 110.0,
                  child: Image.asset(
                    "assets/headerlogo.png",
                    fit: BoxFit.contain,
                  ),
                ))));
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.grey)),
        height: MediaQuery.of(context).size.height / 8.7,
        minWidth: MediaQuery.of(context).size.width / 9.9,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getNumbers(context) {
    // Numbers buttons
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width / 2.8,
        margin: EdgeInsets.only(left: 70),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      Strings.pin_Number,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                    )
                  ]),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    pinNumber.length >= 1
                        ? Icons.lens
                        : Icons.panorama_fish_eye,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                  Icon(
                    pinNumber.length >= 2
                        ? Icons.lens
                        : Icons.panorama_fish_eye,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                  Icon(
                    pinNumber.length >= 3
                        ? Icons.lens
                        : Icons.panorama_fish_eye,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                  Icon(
                    pinNumber.length >= 4
                        ? Icons.lens
                        : Icons.panorama_fish_eye,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
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
                height: 10,
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
                height: 10,
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
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _button("Clock\nIN", () {
                    clockInwithPIN();
                  }),
                  _button("0", () {
                    addINPin("0");
                  }),
                  _button("Clock\nOUT", () {}),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {
                          clearPin();
                        },
                        child: Text("Clear",
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 30,
                                fontWeight: FontWeight.w600)))
                  ])
            ],
          ),
        ),
      ),
    );
  }
}

class KeyboardVisibilityNotification {}
