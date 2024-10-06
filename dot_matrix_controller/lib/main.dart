import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dot_matrix_controller/screens/home_screen.dart';
import 'package:dot_matrix_controller/services/bluetooth_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BluetoothService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Matrix Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: HomeScreen(),
    );
  }
}