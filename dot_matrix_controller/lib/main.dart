import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dot_matrix_controller/services/bluetooth_service.dart';
import 'package:dot_matrix_controller/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final bluetoothService = BluetoothService();
  await bluetoothService.initialize();

  runApp(~
    ChangeNotifierProvider(
      create: (context) => bluetoothService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Matrix Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}