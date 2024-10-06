import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dot_matrix_controller/services/bluetooth_service.dart';

class ConnectionStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bluetoothService, child) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bluetoothService.isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Status: ${bluetoothService.connectionStatus}',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}