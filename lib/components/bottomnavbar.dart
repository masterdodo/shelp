import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: Icon(Icons.shopping_bag),
              onPressed: () {
                if (ModalRoute.of(context).settings.name != "/items") {
                  Navigator.pushNamed(context, '/items');
                }
              }),
          IconButton(
              icon: Icon(Icons.list_alt_rounded),
              onPressed: () {
                if (ModalRoute.of(context).settings.name != "/bills") {
                  Navigator.pushNamed(context, '/bills');
                }
              }),
          IconButton(
              icon: Icon(Icons.family_restroom),
              onPressed: () {
                if (ModalRoute.of(context).settings.name != "/family") {
                  Navigator.pushNamed(context, '/family');
                }
              }),
          IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                if (ModalRoute.of(context).settings.name != "/profile") {
                  Navigator.pushNamed(context, '/profile');
                }
              })
        ],
      ),
    );
  }
}
