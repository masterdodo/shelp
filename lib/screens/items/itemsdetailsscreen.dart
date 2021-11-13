import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelp/screens/login/loginscreen.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'components/category.dart';
import 'components/items_db.dart';
import 'components/store.dart';

class ItemsDetailsScreen extends StatefulWidget {
  final List<dynamic> itemsList;
  final List<dynamic> storesList;
  final List<dynamic> categoriesList;
  final String name;

  const ItemsDetailsScreen(
      {Key key,
      this.itemsList,
      this.name,
      this.storesList,
      this.categoriesList})
      : super(key: key);

  @override
  _ItemsDetailsScreenState createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return Scaffold(
        backgroundColor: Color(0xffA5D6A7),
        appBar: AppBar(
          backgroundColor: Color(0xffA5D6A7),
          shadowColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 40, bottom: 20),
              child: Row(
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              ),
            ),
            Flexible(
                child: ((widget.itemsList.isNotEmpty)
                    ? (ListView.builder(
                        itemCount: widget.itemsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showItemDIalog(
                                        widget.itemsList[index],
                                        (widget.storesList.firstWhere(
                                            (store) =>
                                                store.id ==
                                                widget.itemsList[index].storeId,
                                            orElse: () => new Store("", ""))),
                                        (widget.categoriesList.firstWhere(
                                            (category) =>
                                                category.id ==
                                                widget.itemsList[index]
                                                    .categoryId,
                                            orElse: () =>
                                                new Category("", ""))));
                                  },
                                  child: Text(
                                    widget.itemsList[index].name,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                                FlatButton(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red[600],
                                  ),
                                  onPressed: () {
                                    deleteItem(widget.itemsList[index].id);
                                    setState(() {
                                      widget.itemsList.removeAt(index);
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ))
                    : Expanded(child: Text("No Items")))),
          ],
        ),
      );
    } else {
      return LoginScreen();
    }
  }

  void _showItemDIalog(dynamic item, dynamic store, dynamic category) {
    slideDialog.showSlideDialog(
        context: context,
        pillColor: Colors.black,
        backgroundColor: Color(0xffd6ffda),
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
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                        ]),
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
                        ]),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
