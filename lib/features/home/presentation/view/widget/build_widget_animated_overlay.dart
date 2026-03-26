import 'package:flutter/material.dart';

class WidgetAnimatedOverlay extends StatefulWidget {
  final AnimationController animationController;
  final LayerLink layerLink;
  final VoidCallback onDismiss;
  final Widget child;

  const WidgetAnimatedOverlay({
    required this.animationController,
    required this.layerLink,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  @override
  State<WidgetAnimatedOverlay> createState() => _WidgetAnimatedOverlayState();
}

class _WidgetAnimatedOverlayState extends State<WidgetAnimatedOverlay> with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: GestureDetector(
          onTap: () async {
            await widget.animationController.reverse();
            widget.onDismiss();
          },
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) => Stack(
              children: [
                CompositedTransformFollower(
                  link: widget.layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(-125, -144),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
