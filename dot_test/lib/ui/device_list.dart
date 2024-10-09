import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return ListView.builder(
      itemCount: bluetoothService.scanResults.length,
      itemBuilder: (context, index) {
        final device = bluetoothService.scanResults[index];
        return ListTile(
          title: Text(device.device.name.isNotEmpty ? device.device.name : 'Unknown Device'),
          subtitle: Text(device.device.id.toString()),
          onTap: () {
            bluetoothService.connectToDevice(device.device);
          },
        );
      },
    );
  }
}
