import 'package:flutter/material.dart';
import 'package:shelp/screens/bills/billsscreen.dart';
import 'package:shelp/screens/family/familyscreen.dart';
import 'package:shelp/screens/items/itemsscreen.dart';
import 'package:shelp/screens/login/loginscreen.dart';
import 'package:shelp/screens/profile/profilescreen.dart';
import 'package:shelp/signup/signupscreen.dart';
import 'package:shelp/screens/items/itemsdetailsscreen.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/login': (BuildContext context) => LoginScreen(),
  '/signup': (BuildContext context) => SignUpScreen(),
  '/items': (BuildContext context) => ItemsScreen(),
  '/items-details': (BuildContext context) => ItemsDetailsScreen(),
  '/bills': (BuildContext context) => BillsScreen(),
  '/family': (BuildContext context) => FamilyScreen(),
  '/profile': (BuildContext context) => ProfileScreen()
};
