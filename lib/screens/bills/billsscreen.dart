import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelp/components/bottomnavbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelp/components/listitem.dart';
import 'package:shelp/screens/items/components/item.dart';
import 'package:shelp/screens/items/components/items_db.dart';
import 'package:shelp/screens/login/loginscreen.dart';

import 'components/bill.dart';
import 'components/bills_db.dart';

class BillsScreen extends StatefulWidget {
  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<dynamic> billsList = [];
  List<dynamic> itemsList = [];
  List<ListItem> listItemList = [];
  List<String> famAccUsers = [];
  String familyId = "";

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return Scaffold(
        backgroundColor: Color(0xffB2EBF2),
        floatingActionButton: addBillButton(firebaseUser),
        body: Padding(
          padding: const EdgeInsets.only(top: 75),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Row(
                  children: [
                    Text(
                      "Bills",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.reference().onValue,
                  builder:
                      (BuildContext context, AsyncSnapshot<Event> snapshot) {
                    if (snapshot.hasData) {
                      Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                      itemsList = [];
                      billsList = [];
                      famAccUsers = [];
                      familyId = "";

                      map["profiles"]?.forEach((k, v) {
                        if (v["userId"] == firebaseUser.uid) {
                          familyId = v["family"];
                        }
                      });

                      if (familyId == "") {
                        famAccUsers.add(firebaseUser.uid);
                      } else {
                        map["family-accounts"]?.forEach((k, v) {
                          if (k == familyId) {
                            famAccUsers = List<String>.from(v["users"]);
                          }
                        });
                      }

                      map["items"]?.forEach((k, v) =>
                          (famAccUsers.contains(v["userId"]))
                              ? itemsList.add(Item.withId(
                                  k,
                                  v["name"],
                                  v["userId"],
                                  v["storeId"],
                                  v["categoryId"],
                                  v["price"]))
                              : null);
                      map["bills"]?.forEach((k, v) =>
                          (v["userId"] == firebaseUser.uid)
                              ? billsList.add(Bill.withId(k, v["userId"],
                                  v["timeAndDay"], v["text"], v["fullPrice"]))
                              : null);
                      return Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25),
                          child: (billsList.isNotEmpty)
                              ? (ListView.builder(
                                  itemCount: billsList.length,
                                  itemBuilder: (BuildContext context,
                                          int index) =>
                                      billItem(context, index, firebaseUser),
                                ))
                              : Text(
                                  "No Bills",
                                  style: TextStyle(fontSize: 25),
                                ));
                    }
                    return Container();
                  },
                ),
              ),
              BottomNavBar()
            ],
          ),
        ),
      );
    } else {
      return LoginScreen();
    }
  }

  showDeleteConfirmDialog(BuildContext context, String id) {
    Widget cancelButton = FlatButton(
      color: Colors.blue,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget deleteButton = FlatButton(
      color: Colors.red[400],
      child: Text("Delete"),
      onPressed: () {
        deleteBill(id);
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Delete bill"),
      content: Text("Are you sure you want to delete the bill?"),
      actions: [cancelButton, deleteButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Widget billItem(BuildContext context, int index, User firebaseUser) {
    return GestureDetector(
      onTap: () {
        billDetails(firebaseUser, billsList[index]);
      },
      onLongPress: () {
        showDeleteConfirmDialog(context, billsList[index].id);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (index + 1).toString() + ".  " + billsList[index].timeAndDay,
                  style: TextStyle(fontSize: 20),
                ),
                Icon(Icons.arrow_forward)
              ],
            ),
            Divider(
              color: Color(0xff444444),
            )
          ],
        ),
      ),
    );
  }

  Padding addBillButton(User firebaseUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 45, right: 5),
      child: FloatingActionButton(
        onPressed: () => addBillMethod(firebaseUser),
        child: Icon(Icons.add),
        backgroundColor: Color(0xff0ea1a1),
      ),
    );
  }

  Future<dynamic> addBillMethod(User firebaseUser) {
    TextEditingController fullPriceController = new TextEditingController();
    listItemList = [];
    itemsList.forEach((el) {
      listItemList.add(ListItem<Item>(el));
    });

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Bill",
                      style: TextStyle(fontSize: 25, color: Color(0xff79b3ba)),
                    ),
                    (listItemList.isNotEmpty)
                        ? Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: listItemList.length,
                              itemBuilder: _getListItemTile,
                            ),
                          )
                        : Container(
                            child: Text("No items"),
                          ),
                    TextField(
                      controller: fullPriceController,
                      decoration: InputDecoration(labelText: "Full Price"),
                    ),
                    RaisedButton(
                      color: Color(0xffB2EBF2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                      onPressed: () {
                        if (listItemList.any((el) => el.isSelected)) {
                          List<ListItem> selectedList = listItemList
                              .where((el) => el.isSelected)
                              .toList();
                          String x = "";
                          selectedList.forEach((el) {
                            x += el.data.name +
                                "_" +
                                ((el.data.price != "") ? el.data.price : "/") +
                                "\n";
                            deleteItem(el.data.id);
                          });
                          x = x.substring(0, x.length - 1);
                          addBill(Bill(
                              firebaseUser.uid,
                              DateTime.now().toString().substring(0, 19),
                              x,
                              fullPriceController.text));
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("Add"),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return StatefulBuilder(builder: (context, setState) {
      return GestureDetector(
        onTap: () {
          if (listItemList.any((el) => el.isSelected)) {
            setState(() {
              listItemList[index].isSelected = !listItemList[index].isSelected;
            });
          }
        },
        onLongPress: () {
          setState(() {
            listItemList[index].isSelected = true;
          });
        },
        child: Container(
          color:
              listItemList[index].isSelected ? Color(0x66bbf0e7) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  listItemList[index].data.name,
                  style: TextStyle(fontSize: 30, color: Color(0xff555555)),
                ),
                Text(
                  ((listItemList[index].data.price != "")
                          ? listItemList[index].data.price
                          : "/") +
                      " €",
                  style: TextStyle(fontSize: 30, color: Color(0xff555555)),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  List<dynamic> billItemsList = [];

  Future<dynamic> billDetails(User firebaseUser, Bill bill) {
    bool showItems = false;
    billItemsList = [];
    List<String> a = bill.text.split("\n");
    a.forEach((el) {
      List temp = el.split("_");
      billItemsList.add([temp[0], temp[1]]);
    });

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bill",
                      style: TextStyle(fontSize: 25, color: Color(0xff79b3ba)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Full price",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          bill.fullPrice + " €",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          bill.timeAndDay.substring(8, 10) +
                              "." +
                              bill.timeAndDay.substring(5, 7) +
                              "." +
                              bill.timeAndDay.substring(0, 4),
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Time",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          bill.timeAndDay.substring(11, 19),
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Divider(
                      height: 20,
                      color: Colors.black,
                      thickness: 3,
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          showItems = !showItems;
                        });
                      },
                      child: Text(
                        ((showItems) ? "Hide" : "Show") + " Bill items",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    (billItemsList.isNotEmpty && showItems)
                        ? Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: billItemsList.length,
                              itemBuilder: _getBillDetails,
                            ),
                          )
                        : Container(),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _getBillDetails(BuildContext context, int index) {
    return GestureDetector(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                billItemsList[index][0],
                style: TextStyle(fontSize: 30, color: Color(0xff555555)),
              ),
              Text(
                billItemsList[index][1] + " €",
                style: TextStyle(fontSize: 30, color: Color(0xff555555)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
