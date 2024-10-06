import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShapeButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;

  const ShapeButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: SvgPicture.asset(
            icon,
            height: 40,
            width: 40,
            color: isEnabled ? Colors.white : Colors.grey,
          ),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            backgroundColor: isEnabled ? Theme.of(context).primaryColor : Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }
}