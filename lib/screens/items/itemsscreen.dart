import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelp/components/bottomnavbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelp/screens/items/components/categories_db.dart';
import 'package:shelp/screens/items/components/category.dart';
import 'package:shelp/screens/items/components/store.dart';
import 'package:shelp/screens/items/components/stores_db.dart';
import 'package:shelp/screens/items/components/item.dart';
import 'package:shelp/screens/items/components/items_db.dart';
import 'package:shelp/screens/items/itemsdetailsscreen.dart';
import 'package:shelp/screens/login/loginscreen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class ItemsScreen extends StatefulWidget {
  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<dynamic> itemsList = [];
  List<dynamic> storesList = [];
  List<dynamic> byStoreList = [];
  List<dynamic> emptyStoresList = [];
  List<dynamic> categoriesList = [];
  List<dynamic> byCategoryList = [];
  List<dynamic> emptyCategoriesList = [];
  List<String> famAccUsers = [];
  String storeValue;
  String categoryValue;
  String orderValue;
  String familyId = "";
  bool fabIsOpen;

  @override
  void initState() {
    super.initState();
    orderValue = "None";
    fabIsOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      return Scaffold(
        backgroundColor: Color(0xffA5D6A7),
        floatingActionButton: addButtons(firebaseUser),
        body: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Shopping Cart",
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text("Order By:"),
                  ),
                  DropdownButton<String>(
                    value: orderValue,
                    onChanged: (String val) {
                      setState(() {
                        orderValue = val;
                      });
                    },
                    items: <String>["None", "Stores", "Categories"]
                        .map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Flexible(
                fit: FlexFit.tight,
                child: StreamBuilder(
                    stream: FirebaseDatabase.instance.reference().onValue,
                    builder:
                        (BuildContext context, AsyncSnapshot<Event> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.snapshot.value != null) {
                          Map<dynamic, dynamic> map =
                              snapshot.data.snapshot.value;

                          itemsList = [];
                          storesList = [];
                          byStoreList = [];
                          emptyStoresList = [];
                          categoriesList = [];
                          byCategoryList = [];
                          emptyCategoriesList = [];
                          familyId = "";
                          famAccUsers = [];

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
                          map["stores"]?.forEach((k, v) => (famAccUsers
                                  .contains(v["userId"]))
                              ? storesList
                                  .add(Store.withId(k, v["name"], v["userId"]))
                              : null);
                          map["categories"]?.forEach((k, v) => (famAccUsers
                                  .contains(v["userId"]))
                              ? categoriesList.add(
                                  Category.withId(k, v["name"], v["userId"]))
                              : null);

                          storesList.forEach((store) {
                            var contain =
                                itemsList.where((el) => el.storeId == store.id);
                            if (contain.isNotEmpty) {
                              emptyStoresList.add(store);
                              byStoreList.add([store.id, contain]);
                            }
                          });

                          categoriesList.forEach((category) {
                            var contain = itemsList
                                .where((el) => el.categoryId == category.id);
                            if (contain.isNotEmpty) {
                              emptyCategoriesList.add(category);
                              byCategoryList.add([category.id, contain]);
                            }
                          });

                          return ((orderValue == "None")
                              ? ((itemsList.isNotEmpty)
                                  ? (ListView.builder(
                                      itemCount: itemsList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  _showItemDIalog(
                                                      itemsList[index],
                                                      (storesList.firstWhere(
                                                          (store) =>
                                                              store.id ==
                                                              itemsList[index]
                                                                  .storeId,
                                                          orElse: () =>
                                                              new Store(
                                                                  "", ""))),
                                                      (categoriesList.firstWhere(
                                                          (category) =>
                                                              category.id ==
                                                              itemsList[index]
                                                                  .categoryId,
                                                          orElse: () =>
                                                              new Category(
                                                                  "", ""))));
                                                },
                                                child: Text(
                                                  itemsList[index].name,
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ),
                                              FlatButton(
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red[600],
                                                ),
                                                onPressed: () => deleteItem(
                                                    itemsList[index].id),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ))
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: (Text(
                                        "No Items",
                                        style: TextStyle(fontSize: 25),
                                      )),
                                    ))
                              : (orderValue == "Stores")
                                  ? ((emptyStoresList.isNotEmpty)
                                      ? (GridView.builder(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10),
                                          itemCount: emptyStoresList.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var storeItems = byStoreList
                                                .firstWhere((store) =>
                                                    store[0] ==
                                                    emptyStoresList[index]
                                                        .id)[1]
                                                .toList();

                                            return GestureDetector(
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    ItemsDetailsScreen(
                                                  name: emptyStoresList[index]
                                                      .name,
                                                  itemsList: storeItems,
                                                  storesList: emptyStoresList,
                                                  categoriesList:
                                                      emptyCategoriesList,
                                                ),
                                              )),
                                              onLongPress: () => print(
                                                  giveMeStringForFour(
                                                      storeItems)),
                                              child: Card(
                                                margin: EdgeInsets.all(5.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                borderOnForeground: false,
                                                clipBehavior: Clip.antiAlias,
                                                color: Color(0xffc8e6c9),
                                                child: GridTile(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        emptyStoresList[index]
                                                            .name,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Divider(),
                                                      Text(
                                                        (storeItems.length < 5)
                                                            ? (giveMeString(
                                                                storeItems))
                                                            : (giveMeStringForFour(
                                                                storeItems)),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ))
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25),
                                          child: (Text(
                                            "No Stores",
                                            style: TextStyle(fontSize: 25),
                                          )),
                                        ))
                                  : (orderValue == "Categories")
                                      ? ((emptyCategoriesList.isNotEmpty)
                                          ? (GridView.builder(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              itemCount:
                                                  emptyCategoriesList.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                var categoryItems =
                                                    byCategoryList
                                                        .firstWhere((category) =>
                                                            category[0] ==
                                                            emptyCategoriesList[
                                                                    index]
                                                                .id)[1]
                                                        .toList();

                                                return GestureDetector(
                                                  onTap: () => Navigator.of(
                                                          context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        ItemsDetailsScreen(
                                                      name: emptyCategoriesList[
                                                              index]
                                                          .name,
                                                      itemsList: categoryItems,
                                                      storesList:
                                                          emptyStoresList,
                                                      categoriesList:
                                                          emptyCategoriesList,
                                                    ),
                                                  )),
                                                  onLongPress: () => print(
                                                      giveMeStringForFour(
                                                          categoryItems)),
                                                  child: Card(
                                                    margin: EdgeInsets.all(5.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    borderOnForeground: false,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    color: Color(0xffc8e6c9),
                                                    child: GridTile(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            emptyCategoriesList[
                                                                    index]
                                                                .name,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Divider(),
                                                          Text(
                                                            (categoryItems
                                                                        .length <
                                                                    5)
                                                                ? (giveMeString(
                                                                    categoryItems))
                                                                : (giveMeStringForFour(
                                                                    categoryItems)),
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                            textAlign: TextAlign
                                                                .center,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ))
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 25),
                                              child: (Text(
                                                "No Categories",
                                                style: TextStyle(fontSize: 25),
                                              )),
                                            ))
                                      : null);
                        }
                      }
                      return Container();
                    }),
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

  String giveMeString(List<dynamic> seznam) {
    String x = "";
    seznam.forEach((el) {
      x = x + el.name + "\n";
    });
    return x.substring(0, x.length - 1);
  }

  String giveMeStringForFour(List<dynamic> seznam) {
    String x = "";
    seznam.asMap().forEach((i, el) {
      if (i < 4) {
        x = x + el.name + "\n";
      }
    });
    x = x.substring(0, x.length - 1);
    return x + "...";
  }

  void _showItemDIalog(dynamic item, dynamic store, dynamic category) {
    slideDialog.showSlideDialog(
        context: context,
        pillColor: Colors.black,
        backgroundColor: Color(0xffd6ffda),
        child: Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 20),
                    child: Text(
                      item.name,
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: Text(
                        ((item.price == "") ? " / " : item.price) + " €",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Store\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ((store.name == "") ? "/" : store.name))
                        ],
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Category\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ((category.name == "") ? "/" : category.name))
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  SpeedDial addButtons(User firebaseUser) {
    return SpeedDial(
      marginRight: 18,
      marginBottom: 60,
      child: (fabIsOpen) ? Icon(Icons.close) : Icon(Icons.add),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.3,
      onOpen: () {
        setState(() {
          fabIsOpen = true;
        });
      },
      onClose: () {
        setState(() {
          fabIsOpen = false;
        });
      },
      tooltip: "Add Items",
      heroTag: "add-items-hero-tag",
      backgroundColor: Colors.green[800],
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          backgroundColor: Colors.green[700],
          label: "Item",
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () => itemAddDialog(firebaseUser),
        ),
        SpeedDialChild(
          child: Icon(Icons.store),
          backgroundColor: Colors.green,
          label: "Store",
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () => storeAddDialog(firebaseUser),
        ),
        SpeedDialChild(
          child: Icon(Icons.category_outlined),
          backgroundColor: Colors.green[300],
          label: "Category",
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () => categoryAddDialog(firebaseUser),
        ),
      ],
    );
  }

  Future itemAddDialog(User firebaseUser) {
    TextEditingController _name = TextEditingController();
    bool nameEmptyError = false;
    bool storeCheck = false;
    bool categoryCheck = false;
    storeValue = (storesList.isEmpty) ? "None" : storesList[0].id;
    categoryValue = (categoriesList.isEmpty) ? "None" : categoriesList[0].id;
    TextEditingController _price = TextEditingController();
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
                      "Add Item",
                      style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: _price,
                      decoration: InputDecoration(labelText: "Price"),
                    ),
                    AbsorbPointer(
                      absorbing: storesList.isEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Store: ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w300),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: storeCheck,
                                onChanged: (bool val) {
                                  setState(() {
                                    storeCheck = val;
                                  });
                                },
                              ),
                              Opacity(
                                opacity: (storeCheck) ? 1 : 0.3,
                                child: AbsorbPointer(
                                  absorbing: !storeCheck,
                                  child: DropdownButton<dynamic>(
                                    value: storeValue,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          .unfocus();
                                    },
                                    onChanged: (dynamic val) {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        storeValue = val;
                                      });
                                    },
                                    items: (storesList.isNotEmpty)
                                        ? (storesList.map<DropdownMenuItem>(
                                            (dynamic value) {
                                            return DropdownMenuItem<dynamic>(
                                              value: value.id,
                                              child: Text(value.name),
                                            );
                                          }).toList())
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AbsorbPointer(
                      absorbing: categoriesList.isEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Category: ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w300),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: categoryCheck,
                                onChanged: (bool val) {
                                  setState(() {
                                    categoryCheck = val;
                                  });
                                },
                              ),
                              Opacity(
                                opacity: (categoryCheck) ? 1 : 0.3,
                                child: AbsorbPointer(
                                  absorbing: !categoryCheck,
                                  child: DropdownButton<dynamic>(
                                    value: categoryValue,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          .unfocus();
                                    },
                                    onChanged: (dynamic val) {
                                      setState(() {
                                        categoryValue = val;
                                      });
                                    },
                                    items: (categoriesList.isNotEmpty)
                                        ? (categoriesList.map<DropdownMenuItem>(
                                            (dynamic value) {
                                            return DropdownMenuItem<dynamic>(
                                              value: value.id,
                                              child: Text(value.name),
                                            );
                                          }).toList())
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      color: Color(0xffA5D6A7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                      onPressed: () {
                        if (_name.text.isNotEmpty) {
                          setState(() {
                            nameEmptyError = false;
                          });
                          addItem(new Item(
                              _name.text,
                              firebaseUser.uid,
                              (storeCheck) ? storeValue : "",
                              (categoryCheck) ? categoryValue : "",
                              (_price.text != "") ? _price.text : ""));
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            nameEmptyError = true;
                          });
                        }
                      },
                      child: Text("Add"),
                    ),
                    ((nameEmptyError)
                        ? Text(
                            "Name can't be empty!",
                            style: TextStyle(color: Colors.red[300]),
                          )
                        : Container()),
                  ],
                ),
              );
            },
          );
        });
  }

  Future storeAddDialog(User firebaseUser) {
    TextEditingController _name = TextEditingController();
    bool nameEmptyError = false;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Store",
                    style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(labelText: "Store Name"),
                  ),
                  RaisedButton(
                    color: Color(0xffA5D6A7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)),
                    onPressed: () {
                      if (_name.text.isNotEmpty) {
                        setState(() {
                          nameEmptyError = false;
                        });
                        addStore(new Store(_name.text, firebaseUser.uid));
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          nameEmptyError = true;
                        });
                      }
                    },
                    child: Text("Add"),
                  ),
                  ((nameEmptyError)
                      ? Text(
                          "Name can't be empty!",
                          style: TextStyle(color: Colors.red[300]),
                        )
                      : Container()),
                ],
              ),
            );
          });
        });
  }

  Future categoryAddDialog(User firebaseUser) {
    TextEditingController _name = TextEditingController();
    bool nameEmptyError = false;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Category",
                    style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(labelText: "Category Name"),
                  ),
                  RaisedButton(
                    color: Color(0xffA5D6A7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)),
                    onPressed: () {
                      if (_name.text.isNotEmpty) {
                        setState(() {
                          nameEmptyError = false;
                        });
                        addCategory(new Category(_name.text, firebaseUser.uid));
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          nameEmptyError = true;
                        });
                      }
                    },
                    child: Text("Add"),
                  ),
                  ((nameEmptyError)
                      ? Text(
                          "Name can't be empty!",
                          style: TextStyle(color: Colors.red[300]),
                        )
                      : Container()),
                ],
              ),
            );
          });
        });
  }
}
