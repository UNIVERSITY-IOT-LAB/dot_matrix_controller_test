import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dot Matrix Controller'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              bluetoothService.scanForDevices();
            },
            child: const Text('블루투스 장치 검색'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: bluetoothService.scanResults.isEmpty
                ? const Center(child: Text("스캔된 장치가 없습니다."))
                : ListView.builder(
                    itemCount: bluetoothService.scanResults.length,
                    itemBuilder: (context, index) {
                      final device = bluetoothService.scanResults[index].device;
                      return ListTile(
                        title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                        subtitle: Text(device.id.toString()),
                        onTap: () {
                          bluetoothService.connectToDevice(device);
                        },
                      );
                    },
                  ),
          ),
          if (bluetoothService.connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  bluetoothService.disconnectDevice();
                },
                child: const Text('장치 연결 해제'),
              ),
            ),
        ],
      ),
    );
  }
}
