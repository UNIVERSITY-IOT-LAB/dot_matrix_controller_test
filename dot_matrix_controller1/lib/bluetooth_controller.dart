import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class BluetoothControllerScreen extends StatefulWidget {
  @override
  _BluetoothControllerScreenState createState() => _BluetoothControllerScreenState();
}

class _BluetoothControllerScreenState extends State<BluetoothControllerScreen> {
  FlutterBluePlus flutterBlue = FlutterBluePlus(); // FlutterBluePlus 인스턴스 생성
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  bool isConnected = false;

  // 권한 요청
  void requestPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  // 블루투스 상태 확인
  void checkBluetoothState() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        scanForDevices();  // Bluetooth가 켜져 있으면 스캔 시작
      } else {
        print("Bluetooth is off. Please turn it on.");
      }
    });
  }

  // 장치 검색
  void scanForDevices() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4)); // 스캔 시작

    // 스캔 결과 구독
    FlutterBluePlus.scanResults.listen((result) {
      setState(() {
        scanResults = result;
      });
    });

    await Future.delayed(Duration(seconds: 4)); // 스캔 시간이 지나면 스캔 종료
    FlutterBluePlus.stopScan(); // 스캔 종료
  }

  // 선택된 장치와 연결
  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      connectedDevice = device;
    });

    await connectedDevice!.connect();
    discoverServices();
  }

  // BLE 서비스 및 특성 탐색
  void discoverServices() async {
    if (connectedDevice != null) {
      List<BluetoothService> services = await connectedDevice!.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((c) {
          if (c.properties.write) {
            characteristic = c;
          }
        });
      });
      setState(() {
        isConnected = true;
      });
    }
  }

  // 도형 데이터를 전송
  void sendShapeCommand(String shape) async {
    if (characteristic != null) {
      await characteristic!.write(utf8.encode(shape));
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions(); // 앱 실행 시 권한 요청
    checkBluetoothState(); // 블루투스 상태 확인
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dot Matrix Controller'),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
            onPressed: () {
              if (!isConnected) {
                scanForDevices(); // 블루투스 장치 검색
              }
            },
          ),
        ],
      ),
      body: isConnected
          ? buildShapeButtons() // 연결이 완료되면 도형 버튼 표시
          : buildDeviceList(),   // 연결 전에는 블루투스 기기 목록 표시
    );
  }

  // 검색된 블루투스 기기 리스트를 표시
  Widget buildDeviceList() {
    return ListView.builder(
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        final device = scanResults[index].device;
        return ListTile(
          title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
          subtitle: Text(device.id.toString()),
          onTap: () {
            connectToDevice(device); // 선택된 장치와 연결
          },
        );
      },
    );
  }

  // 도형 버튼을 표시
  Widget buildShapeButtons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose a shape to display on the matrix',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildShapeButton('Circle', 'CIRCLE', Icons.circle),
              buildShapeButton('Square', 'SQUARE', Icons.crop_square),
              buildShapeButton('Triangle', 'TRIANGLE', Icons.change_history),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildShapeButton(String label, String command, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () => sendShapeCommand(command),
        icon: Icon(icon, size: 30),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
