import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dot_matrix_controller/services/bluetooth_service.dart';
import 'package:dot_matrix_controller/widgets/shape_button.dart';
import 'package:dot_matrix_controller/widgets/connection_status.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dot Matrix Controller'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings screen
            },
          ),
        ],
      ),
      body: Consumer<BluetoothService>(
        builder: (context, bluetoothService, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConnectionStatus(),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(bluetoothService.isConnected ? '연결 해제' : '연결 하기'),
                onPressed: () => bluetoothService.isConnected
                    ? bluetoothService.disconnect()
                    : bluetoothService.connectToDevice(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bluetoothService.isConnected ? Colors.red : Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
              ),
              SizedBox(height: 40),
              Text(
                '도형 선택:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShapeButton(
                    icon: 'assets/icons/circle.svg',
                    label: '동그라미',
                    onPressed: () => bluetoothService.sendCommand('C'),
                    isEnabled: bluetoothService.isConnected,
                  ),
                  ShapeButton(
                    icon: 'assets/icons/triangle.svg',
                    label: '세모',
                    onPressed: () => bluetoothService.sendCommand('T'),
                    isEnabled: bluetoothService.isConnected,
                  ),
                  ShapeButton(
                    icon: 'assets/icons/square.svg',
                    label: '네모',
                    onPressed: () => bluetoothService.sendCommand('S'),
                    isEnabled: bluetoothService.isConnected,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}