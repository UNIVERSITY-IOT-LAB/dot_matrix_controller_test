import 'package:flutter/material.dart';

class ShapeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ShapeButton({Key? key, required this.label, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Send $label'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
      ),
    );
  }
}