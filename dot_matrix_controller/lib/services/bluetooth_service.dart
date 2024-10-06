import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';

  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;

  Future<bool> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> connectToDevice(BuildContext context) async {
    if (!await checkPermissions()) {
      _showPermissionDeniedDialog(context);
      return;
    }

    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    
    if (devices.isEmpty) {
      _showNoDevicesDialog(context);
      return;
    }

    BluetoothDevice? selectedDevice = await _selectDevice(context, devices);
    if (selectedDevice == null) return;

    await BluetoothConnection.toAddress(selectedDevice.address).then((_connection) {
      print('Connected to the device');
      this._connection = _connection;
      _isConnected = true;
      _connectionStatus = 'Connected';
      notifyListeners();

      _connection.input!.listen(_onDataReceived).onDone(() {
        disconnect();
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
      _showErrorDialog(context, 'Failed to connect to the device.');
    });
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
  }

  void sendCommand(String command) {
    if (_connection != null && _isConnected) {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      _connection!.output.allSent.then((_) {
        print('Command sent: $command');
      });
    } else {
      print('Not connected to any device');
    }
  }

  void _onDataReceived(Uint8List data) {
    // Handle incoming data from Arduino
    print('Data received: ${String.fromCharCodes(data)}');
  }

  Future<BluetoothDevice?> _selectDevice(BuildContext context, List<BluetoothDevice> devices) async {
    return await showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select a device'),
          children: devices.map((device) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, device);
              },
              child: Text(device.name ?? "Unknown device"),
            );
          }).toList(),
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions Required'),
        content: Text('Bluetooth and location permissions are required for this app to function.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showNoDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Devices Found'),
        content: Text('No paired Bluetooth devices were found. Please pair a device and try again.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}