import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/dashboard.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO',
      theme: ThemeData(
      ),
      home: Dashboard(),
    );
  }
}
