import 'package:flutter/material.dart';

class CustomFadeInAnimation extends StatefulWidget {
  const CustomFadeInAnimation({
    required this.child,
    required this.delay,
    this.isTop = true,
    super.key,
  });

  final Widget child;
  final double delay;
  final bool isTop;

  @override
  State<CustomFadeInAnimation> createState() => _CustomFadeInAnimationState();
}

class _CustomFadeInAnimationState extends State<CustomFadeInAnimation> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late Animation<double> animation2;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: (500 * widget.delay).round()),
      vsync: this,
    );
    animation2 = Tween<double>(begin: widget.isTop ? -40 : 40, end: 0).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    controller.forward();
    return Transform.translate(
      offset: Offset(
        0,
        animation2.value,
      ),
      child: Opacity(
        opacity: animation.value,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
