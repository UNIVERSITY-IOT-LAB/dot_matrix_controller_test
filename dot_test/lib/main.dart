import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/bluetooth.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothService()),
      ],
      child: MaterialApp(
        title: 'Dot Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,  // 기본 색상 설정
          visualDensity: VisualDensity.adaptivePlatformDensity, // 기본 스타일
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
