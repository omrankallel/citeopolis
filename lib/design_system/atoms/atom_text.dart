import 'package:flutter/material.dart';

class AtomText extends StatelessWidget {
  const AtomText({
    required this.data,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
        data,
        style: style ?? Theme.of(context).textTheme.headlineSmall,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
}
