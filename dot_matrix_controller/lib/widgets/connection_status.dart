import 'package:flutter/material.dart';

class ConnectionStatus extends StatelessWidget {
  final String status;

  const ConnectionStatus({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: status == 'Connected' ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        'Status: $status',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}