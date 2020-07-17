import 'package:flutter/material.dart';
import './home_page.dart';

main(List<String> args) {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
      primaryColor: Colors.red[300],
      accentColor: Colors.red[300],
    ),
  ));
}
