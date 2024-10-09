import 'package:flutter/material.dart';
import 'bluetooth_controller.dart';

void main() {
  runApp(DotMatrixControllerApp());
}

class DotMatrixControllerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Matrix Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BluetoothControllerScreen(),
    );
  }
}
