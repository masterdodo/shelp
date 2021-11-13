import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.green[200],
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
