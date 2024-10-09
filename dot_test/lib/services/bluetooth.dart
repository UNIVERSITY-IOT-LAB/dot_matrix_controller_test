import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;  // flutter_blue_plus 패키지에 별칭 추가
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class BluetoothService extends ChangeNotifier {
  final fbp.FlutterBluePlus flutterBlue = fbp.FlutterBluePlus();  // flutter_blue_plus 인스턴스
  List<fbp.ScanResult> scanResults = [];
  fbp.BluetoothDevice? connectedDevice;
  fbp.BluetoothCharacteristic? characteristic;

  // 블루투스 초기화: 지원 여부 확인 및 On/Off 상태 처리
  void initializeBluetooth() async {
    if (await fbp.FlutterBluePlus.isSupported == false) {
      print("이 장치는 블루투스를 지원하지 않습니다.");
      return;
    }

    // 블루투스 상태 확인 및 On/Off 상태 처리
    var subscription = fbp.FlutterBluePlus.adapterState.listen((fbp.BluetoothAdapterState state) {
      print(state);
      if (state == fbp.BluetoothAdapterState.on) {
        // 블루투스가 켜져 있을 때 스캔을 시작할 준비
        print("블루투스가 켜져 있습니다.");
      } else {
        print("블루투스가 꺼져 있습니다.");
      }
    });

    // 안드로이드에서 블루투스를 켜는 코드 (iOS에서는 사용자가 직접 켜야 함)
    if (Platform.isAndroid) {
      await fbp.FlutterBluePlus.turnOn();
    }

    subscription.cancel(); // 중복 구독 방지
  }

  // 장치 스캔
  void scanForDevices() async {
    if (fbp.FlutterBluePlus.isScanningNow == true) {
      Fluttertoast.showToast(msg: "이미 스캔 중입니다.");
      return;
    }

    fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // 스캔 결과 구독
    var subscription = fbp.FlutterBluePlus.scanResults.listen((results) {
      if (results.isNotEmpty) {
        scanResults = results;
        notifyListeners();  // UI 업데이트를 위한 상태 변경
      }
    });

    await fbp.FlutterBluePlus.isScanning.where((isScanning) => isScanning == false).first;
    subscription.cancel(); // 스캔 완료 후 구독 해제
  }

  // 장치 연결
  Future<void> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
      Fluttertoast.showToast(msg: "연결됨: ${device.name}");

      discoverServices();  // 연결 후 서비스 탐색
    } catch (e) {
      Fluttertoast.showToast(msg: "연결 실패: $e");
    }
  }

  // 서비스 탐색 및 특성 확인
  void discoverServices() async {
    if (connectedDevice != null) {
      List<fbp.BluetoothService> services = await connectedDevice!.discoverServices();
      for (var service in services) {
        for (var c in service.characteristics) {
          if (c.properties.write) {
            characteristic = c;
          }
        }
      }

      if (characteristic != null) {
        Fluttertoast.showToast(msg: "장치와의 통신 준비 완료");
      } else {
        Fluttertoast.showToast(msg: "쓰기가 가능한 특성을 찾지 못했습니다.");
      }
    }
  }

  // 데이터 전송
  Future<void> sendData(String data) async {
    if (characteristic != null) {
      try {
        await characteristic!.write(data.codeUnits, withoutResponse: true);
        Fluttertoast.showToast(msg: "데이터 전송 완료");
      } catch (e) {
        Fluttertoast.showToast(msg: "데이터 전송 실패: $e");
      }
    } else {
      Fluttertoast.showToast(msg: "연결된 장치가 없습니다.");
    }
  }

  // 장치 연결 해제
  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      Fluttertoast.showToast(msg: "장치 연결 해제됨");
      connectedDevice = null;
      characteristic = null;
      notifyListeners();  // UI 업데이트를 위한 상태 변경
    }
  }
}
