import 'package:flutter/material.dart';

class AtomChip extends StatelessWidget {
  const AtomChip({
    required this.data,
    required this.selectedColor,
    required this.borderColor,
    this.backgroundColor = Colors.transparent,
    this.isSelected = false,
    this.style,
    this.onSelected,
    super.key,
  });

  final String data;
  final Color backgroundColor;
  final Color selectedColor;
  final Color borderColor;
  final TextStyle? style;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
        selected: isSelected,
        backgroundColor: backgroundColor,
        selectedColor: selectedColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected ? BorderSide.none : BorderSide(color: borderColor),
        ),
        label: Text(
          data,
          style: style ?? Theme.of(context).textTheme.labelLarge,
        ),
        onSelected: onSelected,
      );
}
