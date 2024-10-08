import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService extends ChangeNotifier {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _statusMessage = 'Disconnected';
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  List<BluetoothDevice> _devicesList = [];

  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  List<BluetoothDevice> get devicesList => _devicesList;

  Future<void> initialize() async {
    await checkAndRequestPermissions();
  }

  Future<bool> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();

      print("Android Permission statuses: $statuses");
      return statuses.values.every((status) => status.isGranted);
    } else if (Platform.isIOS) {
      // iOS에서는 실제로 블루투스 기능을 사용해야 권한 요청이 표시됩니다.
      return true;
    }
    return true;
  }

  Future<void> startDiscovery() async {
    _devicesList.clear();
    _updateStatus('Scanning for devices...');

    _discoveryStreamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final existingIndex = _devicesList.indexWhere((element) => element.address == r.device.address);
      if (existingIndex >= 0) {
        _devicesList[existingIndex] = r.device;
      } else {
        _devicesList.add(r.device);
      }
      notifyListeners();
    });

    _discoveryStreamSubscription?.onDone(() {
      _updateStatus('Scan completed');
    });
  }

  Future<void> stopDiscovery() async {
    await _discoveryStreamSubscription?.cancel();
    _discoveryStreamSubscription = null;
  }

  Future<List<BluetoothDevice>> getAvailableDevices() async {
    await startDiscovery();
    // 5초 동안 기기를 탐색합니다. 필요에 따라 시간을 조정하세요.
    await Future.delayed(Duration(seconds: 5));
    await stopDiscovery();
    return _devicesList;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!_isConnected) {
      try {
        _updateStatus('Connecting to ${device.name}...');

        _connection = await BluetoothConnection.toAddress(device.address);
        
        _isConnected = true;
        _updateStatus('Connected to ${device.name}');

        _connection!.input!.listen(_onDataReceived).onDone(() {
          disconnect();
        });
      } catch (e) {
        _isConnected = false;
        _updateStatus('Failed to connect to ${device.name}');
        print('Connection error: $e');
      }
    }
  }

  void disconnect() {
    if (_isConnected) {
      _connection?.dispose();
      _connection = null;
      _isConnected = false;
      _updateStatus('Disconnected');
    }
  }

  void sendCommand(String command) {
    if (_isConnected && _connection != null) {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      _connection!.output.allSent.then((_) {
        print('Command sent: $command');
      });
    } else {
      print('Not connected to any device');
    }
  }

  void _onDataReceived(Uint8List data) {
    print('Data received: ${String.fromCharCodes(data)}');
    // Handle incoming data here if needed
  }

  void _updateStatus(String status) {
    _statusMessage = status;
    notifyListeners();
  }

  @override
  void dispose() {
    stopDiscovery();
    disconnect();
    super.dispose();
  }
}