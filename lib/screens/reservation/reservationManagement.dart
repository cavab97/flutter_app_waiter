import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Reservation.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/screens/reservation/addEditReservation.dart';
import 'package:timezone/timezone.dart';

class ReservationMgmt extends StatefulWidget {
  ReservationMgmt({
    this.onClose,
    this.onArrived,
  });
  final Function onClose;
  final Function onArrived;
  @override
  _ReservationMgmtState createState() => _ReservationMgmtState();
}

class SampleRes {
  String resNo;
  String memNo;
  String cusName;
  DateTime resFrom;
  DateTime resTo;
  String tableNo;
  int pax;
  String remark;
  bool isArr;
}

class _ReservationMgmtState extends State<ReservationMgmt> {
  DateTime firstDate = DateTime.now().subtract(Duration(days: 90));
  FocusNode fromDateFocusNode = new FocusNode();
  FocusNode toDateFocusNode = new FocusNode();
  FocusNode keywordFocusNode = new FocusNode();
  TextEditingController searchController = new TextEditingController();
  DateTime fromDateTime =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDateTime = DateTime.now();
  bool test = false;
  List<SampleRes> sampleRes = [];
  List<TablesDetails> tableList = [];
  Reservation selectedReservation;
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890 ';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  List<Reservation> reservationList = [];
  int terminalID;
  @override
  void initState() {
    super.initState();
    afterInit();
  }

  afterInit() async {
    int tID = int.tryParse(await CommunFun.getTeminalKey());
    String branchID = await CommunFun.getbranchId();
    List<TablesDetails> tables = await localAPI.getTables(branchID);
    List<Reservation> resList = await localAPI.getReservationList();

    resList.sort(
      (Reservation a, Reservation b) => a.resFrom.compareTo(b.resFrom),
    );
    setState(() {
      terminalID = tID;
      tableList = tables;
      reservationList = resList;
    });

    generateSampleData();
  }

  generateSampleData() {
    setState(() {
      sampleRes.clear();
    });
    for (int index = 1; index <= 10; index++) {
      SampleRes newSample = new SampleRes();
      newSample.resNo = 'TS-RS' + index.toString().padLeft(5, '0');
      newSample.memNo = 'MBM' + index.toString().padLeft(5, '0');
      newSample.cusName = getRandomString(15);
      newSample.resFrom =
          DateTime.now().subtract(Duration(days: _rnd.nextInt(30)));
      newSample.resTo =
          DateTime.now().subtract(Duration(days: _rnd.nextInt(30)));
      newSample.tableNo = _rnd.nextInt(tableList.length - 1).toString();
      newSample.pax = _rnd.nextInt(20);
      newSample.remark = getRandomString(_rnd.nextInt(150));
      newSample.isArr = _rnd.nextBool();
      sampleRes.add(newSample);
    }
    setState(() {
      sampleRes;
    });
  }

  filterReservation() {
    setState(() {
      sampleRes = sampleRes.where((SampleRes reservation) {
        return reservation.resFrom.isAfter(fromDateTime) &&
            reservation.resTo.isBefore(toDateTime) &&
            keyWordContain(reservation);
      }).toList();
      if (!sampleRes.contains(selectedReservation)) {
        selectedReservation = null;
      }
    });
  }

  openReservationScreen([Reservation reservation]) async {
    TablesDetails tb = tableList.first;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (reservation != null) {
          tb =
              tableList.firstWhere((ele) => ele.tableId == reservation.tableID);
          return ReservationDetail(
            isUpdate: true,
            selTable: tb,
            reservationID: reservation.resNo,
            reservation: reservation,
            onClose: (Reservation res) {
              if (this.mounted) {
                int indexOf =
                    reservationList.indexWhere((ele) => ele.id == res.id);
                setState(() {
                  reservationList[indexOf] = res;
                });
              }
            },
          );
        } else {
          return ReservationDetail(
            isUpdate: false,
            onClose: (Reservation res) {
              if (this.mounted) {
                setState(() {
                  reservationList.add(res);
                  reservationList.sort(
                    (Reservation a, Reservation b) =>
                        a.resFrom.compareTo(b.resFrom),
                  );
                });
              }
            },
          );
        }
      },
    );
  }

  keyWordContain(SampleRes sr) {
    String text = searchController.text.trim().toLowerCase();
    bool isInt = text is int;
    if (isInt && sr.pax == int.tryParse(text)) return true;
    if (sr.cusName.toLowerCase().contains(text) ||
        sr.memNo.toLowerCase().contains(text) ||
        sr.resNo.toLowerCase().contains(text) ||
        sr.tableNo.toLowerCase().contains(text)) {
      return true;
    } else if (sr.remark.toLowerCase().contains(text)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('hh:mm a, dd/MM/yyyy');
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Strings.reservation),
          Row(
            children: [
              RaisedButton.icon(
                color: Colors.white,
                icon: Icon(Icons.add),
                label: Text('New'),
                onPressed: () {
                  openReservationScreen();
                },
              ),
              SizedBox(width: 10),
              RaisedButton.icon(
                color: Colors.white,
                icon: Icon(Icons.edit),
                label: Text('Edit'),
                onPressed: selectedReservation != null
                    ? () {
                        openReservationScreen(selectedReservation);
                      }
                    : null,
              ),
              SizedBox(width: 10),
              RaisedButton.icon(
                color: Colors.white,
                icon: selectedReservation != null && selectedReservation.isArr
                    ? Icon(FontAwesomeIcons.conciergeBell)
                    : Icon(Icons.directions_walk),
                label: selectedReservation != null && selectedReservation.isArr
                    ? Text('Become Reservation')
                    : Text('Arrive ?'),
                onPressed: selectedReservation != null
                    ? () {
                        int indexOf =
                            reservationList.indexOf(selectedReservation);
                        if (sampleRes[indexOf].isArr && this.mounted) {
                          setState(() {
                            selectedReservation = null;
                            sampleRes[indexOf].isArr = false;
                          });
                        } else if (selectedReservation != null) {
                          widget.onArrived(selectedReservation);
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
              ),
              SizedBox(width: 10),
              RaisedButton.icon(
                color: Colors.red,
                icon: Icon(FontAwesomeIcons.trash),
                label: Text('Delete'),
                onPressed: selectedReservation != null
                    ? () {
                        //int index = sampleRes.indexOf(selectedReservation);
                        localAPI.removeReservationItems(selectedReservation.id);
                        if (this.mounted) {
                          setState(() {
                            reservationList.remove(selectedReservation);
                            selectedReservation = null;
                          });
                        }
                      }
                    : null,
              ),
              SizedBox(width: 10),
              RaisedButton.icon(
                color: Colors.orange,
                icon: Icon(Icons.close),
                label: Text('Close'),
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose(reservationList);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
      content: Column(
        children: [
          Container(
            height: 100,
            child: Row(children: [
              Text('Date from'),
              SizedBox(width: 10),
              Container(
                width: 140,
                child: DateTimePicker(
                  focusNode: fromDateFocusNode,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 0, right: -35),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      alignment: Alignment(1.5, 0),
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () {},
                    ),
                  ),
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  type: DateTimePickerType.date,
                  dateMask: 'dd/MM/yyyy',
                  initialValue:
                      DateTime(DateTime.now().year, DateTime.now().month, 1)
                          .toString(),
                  firstDate: firstDate,
                  lastDate: DateTime.now().add(Duration(days: 14)),
                  onChanged: (String inputText) {
                    if (this.mounted) {
                      setState(() {
                        fromDateTime = DateTime.tryParse(inputText);
                      });
                    }
                  },
                  /* onEditingComplete: () {},
                  onFieldSubmitted: (input) {},
                  validator: (val) {},
                  onSaved: (val) {}, */
                ),
              ),
              SizedBox(width: 10),
              Text('to'),
              SizedBox(width: 10),
              Container(
                width: 140,
                child: DateTimePicker(
                  focusNode: toDateFocusNode,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 0, right: -35),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      alignment: Alignment(1.5, 0),
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () {},
                    ),
                  ),
                  type: DateTimePickerType.date,
                  dateMask: 'dd/MM/yyyy',
                  initialValue: DateTime.now().toString(),
                  firstDate: firstDate,
                  lastDate: DateTime.now().add(Duration(days: 14)),
                  onChanged: (String inputText) {
                    if (this.mounted) {
                      setState(() {
                        toDateTime = DateTime.tryParse(inputText);
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 200,
                height: 50,
                child: TextFormField(
                  focusNode: keywordFocusNode,
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: 'Keyword',
                    hintText: "Enter keyword",
                    suffixIcon: IconButton(
                      alignment: Alignment(1.5, 0),
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.withOpacity(.7),
                      ),
                      onPressed: () {
                        searchController.text = "";
                        generateSampleData();
                      },
                    ),
                  ),
                  onTap: () =>
                      FocusScope.of(context).requestFocus(keywordFocusNode),
                  onFieldSubmitted: (val) => filterReservation(),
                ),
              ),
              SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(4, 3))
                ]),
                child: RaisedButton.icon(
                  color: Colors.white,
                  icon: Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  label: Text(
                    'Search',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () => filterReservation(),
                ),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      //horizontalMargin: 0
                      columns: <DataColumn>[
                        DataColumn(label: Text(Strings.reservationNo)),
                        DataColumn(label: Text(Strings.memberNo)),
                        DataColumn(label: Text(Strings.customerName)),
                        DataColumn(label: Text(Strings.reserveFrom)),
                        DataColumn(label: Text(Strings.reserveUntil)),
                        DataColumn(label: Text(Strings.tableNo)),
                        DataColumn(label: Text(Strings.pax)),
                        DataColumn(label: Text('Remark')),
                        DataColumn(label: Text("Is Arrived?")),
                      ],
                      rows: reservationList.map((Reservation reservation) {
                        TablesDetails table = tableList.firstWhere(
                            (ele) => ele.tableId == reservation.tableID);
                        return DataRow(
                          cells: [
                            DataCell(Text(reservation.resNo)),
                            DataCell(Text(reservation.customerID)),
                            DataCell(Text(reservation.customerName)),
                            DataCell(Text(formatter.format(
                                DateTime.tryParse(reservation.resFrom)))),
                            DataCell(Text(formatter.format(
                                (DateTime.tryParse(reservation.resTo))))),
                            DataCell(Text(table.tableName)),
                            DataCell(Text(reservation.pax.toString())),
                            DataCell(Container(
                                width: 200,
                                child: SingleChildScrollView(
                                  child: Text(
                                    reservation.remark ?? "",
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))),
                            DataCell(Checkbox(
                              value: reservation.isArr ?? false,
                              onChanged: (val) {},
                            )),
                          ],
                          selected: selectedReservation != null
                              ? selectedReservation == reservation
                              : false,
                          onSelectChanged: (bool selected) {
                            setState(() {
                              if (selectedReservation == reservation) {
                                selectedReservation = null;
                              } else {
                                selectedReservation = reservation;
                              }
                            });
                          },
                        );
                      }).toList(),
                      /*   [
                        DataRow(
                          cells: [
                            DataCell(Text('TS-RS000001')),
                            DataCell(Text('TS-RS000001')),
                            DataCell(Text('TS-RS000001')),
                            DataCell(Text('TS-RS000001')),
                            DataCell(Text('TS-RS000001')),
                            DataCell(Text('TS-RS000001')),
                            DataCell(Text('TS-RS000001')),
                            DataCell(
                              Container(
                                width: 200,
                                child: SingleChildScrollView(
                                  child: Text(
                                      'This is a really long text. It\'s supposed to be long so that I can figure out what in the hell is happening to the ability to have the text wrap in this datacell. So far, I haven\'t been able to figure it out.',
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            DataCell(Text('TS-RS000001')),
                          ],
                          selected: test,
                          onSelectChanged: (bool selected) {
                            setState(() {
                              test = !test;
                            });
                          },
                        ),
                      ], */
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
