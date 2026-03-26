import 'package:flutter/material.dart';

class AtomIndicator extends StatelessWidget {
  const AtomIndicator({
    required this.width,
    required this.color,
    required this.borderColor,
    this.height,
    super.key,
  });

  final double width;
  final double? height;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 20.0),
        width: width,
        height: height ?? 12.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: borderColor,
          ),
          color: color,
        ),
      );
}
