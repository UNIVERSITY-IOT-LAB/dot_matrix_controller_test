import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:dot_matrix_controller/services/bluetooth_service.dart';
import 'package:dot_matrix_controller/widgets/connection_status.dart';
import 'package:dot_matrix_controller/widgets/shape_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dot Matrix Controller')),
      body: Consumer<BluetoothService>(
        builder: (context, bluetoothService, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConnectionStatus(status: bluetoothService.statusMessage),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: Text(bluetoothService.isConnected ? 'Disconnect' : 'Connect'),
                  onPressed: () async {
                    if (bluetoothService.isConnected) {
                      bluetoothService.disconnect();
                    } else {
                      bool permissionsGranted = await bluetoothService.checkAndRequestPermissions();
                      if (permissionsGranted) {
                        // 스캔 시작
                        await bluetoothService.startDiscovery();
                        // 5초 동안 스캔
                        await Future.delayed(Duration(seconds: 5));
                        // 스캔 중지
                        await bluetoothService.stopDiscovery();
                        // 발견된 기기 목록 표시
                        final devices = bluetoothService.devicesList;
                        _showDeviceList(context, devices, bluetoothService);
                      } else {
                        _showPermissionDeniedDialog(context);
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                ShapeButton(
                  label: 'Circle',
                  onPressed: bluetoothService.isConnected
                      ? () => bluetoothService.sendCommand('C')
                      : null,
                ),
                ShapeButton(
                  label: 'Triangle',
                  onPressed: bluetoothService.isConnected
                      ? () => bluetoothService.sendCommand('T')
                      : null,
                ),
                ShapeButton(
                  label: 'Square',
                  onPressed: bluetoothService.isConnected
                      ? () => bluetoothService.sendCommand('S')
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeviceList(BuildContext context, List<BluetoothDevice> devices, BluetoothService service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a device'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(devices[index].name ?? "Unknown device"),
                  subtitle: Text(devices[index].address),
                  onTap: () {
                    service.connectToDevice(devices[index]);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text('This app needs Bluetooth and Location permissions to function. Please grant the permissions in the settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}