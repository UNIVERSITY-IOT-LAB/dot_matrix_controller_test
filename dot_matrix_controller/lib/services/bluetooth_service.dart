import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _connectionStatus = '연결되지 않음';

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
      print('장치 연결');
      this._connection = _connection;
      _isConnected = true;
      _connectionStatus = '연결됨';
      notifyListeners();

      _connection.input!.listen(_onDataReceived).onDone(() {
        disconnect();
      });
    }).catchError((error) {
      print('연결할 수 없습니다. 예외가 발생했습니다.');
      print(error);
      _showErrorDialog(context, '장치에 연결하지 못했습니다.');
    });
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
    _isConnected = false;
    _connectionStatus = '연결 끊김';
    notifyListeners();
  }

  void sendCommand(String command) {
    if (_connection != null && _isConnected) {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      _connection!.output.allSent.then((_) {
        print('Command sent: $command');
      });
    } else {
      print('기기와 연결되어있지 않습니다.');
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
          title: const Text('장치 선택'),
          children: devices.map((device) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, device);
              },
              child: Text(device.name ?? "알 수 없는 장치"),
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
        title: Text('권한 설정'),
        content: Text('이 앱이 작동하려면 블루투스 및 위치 권한이 필요합니다.'),
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
        title: Text('장치를 찾을 수 없습니다.'),
        content: Text('페어링된 Bluetooth 장치를 찾을 수 없습니다. 장치를 페어링하고 다시 시도하십시오.'),
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