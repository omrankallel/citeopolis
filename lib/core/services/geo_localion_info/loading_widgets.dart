import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const LoadingText({
    required this.width,
    this.height = 16,
    this.borderRadius,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      );
}

class LoadingTextLines extends StatelessWidget {
  final List<double> widths;
  final double height;
  final double spacing;
  final Color? color;

  const LoadingTextLines({
    required this.widths,
    this.height = 16,
    this.spacing = 8,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widths.length; i++) ...[
            LoadingText(
              width: widths[i],
              height: height,
              color: color,
            ),
            if (i < widths.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
}

class AnimatedLoadingText extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;

  const AnimatedLoadingText({
    required this.width,
    this.height = 16,
    this.borderRadius,
    this.baseColor,
    super.key,
  });

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.baseColor ?? Colors.grey[300])?.withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
        ),
      );
}

class LoadingImage extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? child;

  const LoadingImage({
    required this.width,
    required this.height,
    this.borderRadius,
    this.backgroundColor,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: child ??
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
      );
}

class LoadingDescription extends StatelessWidget {
  final bool isDarkMode;
  final int lines;
  final double spacing;

  const LoadingDescription({
    required this.isDarkMode,
    this.lines = 3,
    this.spacing = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];

    return LoadingTextLines(
      widths: [
        double.infinity,
        if (lines > 1) MediaQuery.of(context).size.width * 0.7,
        if (lines > 2) MediaQuery.of(context).size.width * 0.5,
        if (lines > 3) MediaQuery.of(context).size.width * 0.8,
      ].take(lines).toList(),
      height: 14,
      spacing: spacing,
      color: baseColor,
    );
  }
}

extension LoadingExtensions on Widget {
  Widget withLoading({
    required bool isLoading,
    double? width,
    double? height,
    Color? loadingColor,
  }) {
    if (!isLoading) return this;

    return LoadingText(
      width: width ?? 100,
      height: height ?? 16,
      color: loadingColor,
    );
  }
}
