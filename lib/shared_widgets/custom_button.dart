import 'package:badges/badges.dart' as bdg;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../core/constants/app_fonts.dart';
import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';
import '../core/enums/enums.dart' show ButtonEnum;

class CustomButtons extends StatelessWidget {
  final ButtonEnum? buttonEnum;
  final VoidCallback onPressed;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? child;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool withBorder;
  final bool loading;
  final bool disabled;
  final Icon? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? disabledColor;
  final Size? minimumSize;
  final EdgeInsets? padding;
  final String? badgeValue;

  const CustomButtons.elevateSecondary({
    required this.onPressed,
    this.title,
    this.titleStyle,
    this.child,
    this.width,
    this.height,
    this.loading = false,
    this.disabled = false,
    this.borderRadius = RadiusSize.regular,
    this.withBorder = false,
    this.borderColor,
    this.disabledColor,
    this.buttonColor,
    this.icon,
    super.key,
  })  : buttonEnum = ButtonEnum.elevateSecondary,
        iconSize = null,
        iconColor = null,
        minimumSize = null,
        padding = null,
        badgeValue = null;

  const CustomButtons.elevatePrimary({
    required this.onPressed,
    this.title,
    this.titleStyle,
    this.child,
    this.width,
    this.height,
    this.loading = false,
    this.disabled = false,
    this.borderRadius = RadiusSize.regular,
    this.withBorder = false,
    this.borderColor,
    this.buttonColor,
    this.disabledColor,
    super.key,
  })  : buttonEnum = ButtonEnum.elevatePrimary,
        icon = null,
        iconSize = null,
        iconColor = null,
        minimumSize = null,
        padding = null,
        badgeValue = null;

  const CustomButtons.text({
    required this.onPressed,
    this.title,
    this.titleStyle,
    this.child,
    this.disabled = false,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.borderRadius = RadiusSize.regular,
    this.withBorder = false,
    this.borderColor,
    this.padding,
    this.minimumSize,
    super.key,
  })  : buttonEnum = ButtonEnum.text,
        loading = false,
        width = null,
        height = null,
        buttonColor = null,
        disabledColor = null,
        badgeValue = null;

  const CustomButtons.icon({
    required this.onPressed,
    this.icon,
    this.child,
    this.disabled = false,
    this.borderRadius = RadiusSize.regular,
    this.withBorder = false,
    this.borderColor,
    this.iconSize,
    this.iconColor,
    this.badgeValue,
    super.key,
  })  : assert(
          icon != null || child != null,
          'please provide an icon or a child',
        ),
        buttonEnum = ButtonEnum.icon,
        title = null,
        titleStyle = null,
        width = null,
        height = null,
        loading = false,
        buttonColor = null,
        disabledColor = null,
        minimumSize = null,
        padding = null;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = width ?? MediaQuery.of(context).size.width;

    switch (buttonEnum) {
      case ButtonEnum.elevatePrimary:
        return ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                side: buttonColor != null
                    ? withBorder
                        ? BorderSide(
                            color: borderColor ?? kNeutralColor700,
                          )
                        : BorderSide.none
                    : BorderSide.none,
              ),
            ),
            elevation: WidgetStateProperty.all(0),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            minimumSize: WidgetStateProperty.all(
              Size(
                buttonWidth,
                height ?? 45,
              ),
            ),
            backgroundColor: disabled ? WidgetStateProperty.all(disabledColor ?? kNeutralColor600) : WidgetStateProperty.all(buttonColor ?? surfaceLight),
          ),
          onPressed: disabled || loading
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed();
                },
          child: loading
              ? const SizedBox(
                  height: 35,
                  child: Padding(
                    padding: EdgeInsets.all(Paddings.small),
                    child: SpinKitFadingCircle(
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                )
              : child == null
                  ? Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: titleStyle ?? AppFonts.poppinsBSemiBold.copyWith(color: disabled && disabledColor != null ? kNeutralColor800 : kNeutralColor100, fontSize: 16),
                    )
                  : SizedBox(
                      width: (width ?? 200) - 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (title != null) ...[
                            const SizedBox(width: Paddings.regular),
                            Text(
                              title ?? '',
                              textAlign: TextAlign.center,
                              style: titleStyle ?? AppFonts.poppinsBSemiBold.copyWith(color: kNeutralColor100),
                            ),
                            const SizedBox(width: Paddings.regular),
                          ],
                          child!,
                        ],
                      ),
                    ),
        );
      case ButtonEnum.elevateSecondary:
        return ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                side: BorderSide(
                  color: borderColor ?? kNeutralColor700,
                ),
              ),
            ),
            minimumSize: WidgetStateProperty.all(
              Size(
                buttonWidth,
                height ?? 45,
              ),
            ),
            backgroundColor: disabled ? WidgetStateProperty.all(disabledColor ?? kNeutralColor600) : WidgetStateProperty.all(buttonColor ?? kNeutralColor100),
          ),
          onPressed: disabled || loading
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed();
                },
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(Paddings.small),
                  child: CircularProgressIndicator(
                    color: kNeutralColor900,
                  ),
                )
              : icon != null
                  ? SizedBox(
                      width: buttonWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Center(
                              child: Text(
                                title ?? '',
                                style: titleStyle ?? AppFonts.poppinsBSemiBold.copyWith(color: const Color(0XFFb30c0d)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: Paddings.regular),
                            child: icon,
                          ),
                        ],
                      ),
                    )
                  : child ??
                      Text(
                        title ?? '',
                        style: titleStyle ?? AppFonts.poppinsBSemiBold.copyWith(color: const Color(0XFFb30c0d), fontSize: 16),
                      ),
        );
      case ButtonEnum.text:
        return TextButton(
          onPressed: disabled ? null : onPressed,
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all(padding),
            minimumSize: minimumSize != null ? WidgetStateProperty.all(minimumSize) : null,
          ),
          child: child ??
              (icon != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          color: iconColor ?? kNeutralColor800,
                        ),
                        const SizedBox(
                          width: Paddings.small,
                        ),
                        Text(
                          title ?? '',
                          style: disabled
                              ? AppFonts.helveticaH2Regular.copyWith(color: kNeutralColor600)
                              : titleStyle ??
                                  AppFonts.helveticaH2Regular.copyWith(
                                    color: kNeutralColor800,
                                  ),
                        ),
                      ],
                    )
                  : Text(
                      title ?? '',
                      style: disabled
                          ? AppFonts.helveticaH2Regular.copyWith(color: kNeutralColor600)
                          : titleStyle ??
                              AppFonts.helveticaH2Regular.copyWith(
                                color: kNeutralColor800,
                              ),
                    )),
        );
      case ButtonEnum.icon:
        return badgeValue != null
            ? _WrapWithBadge(
                widget: IconButton(
                  icon: icon ?? child!,
                  disabledColor: kNeutralColor600,
                  iconSize: iconSize != null && iconSize! > 0 ? iconSize! : 16.0,
                  color: iconColor ?? kNeutralColor900,
                  onPressed: disabled ? null : onPressed,
                ),
                badgeValue: badgeValue!,
              )
            : SizedBox(
                child: IconButton(
                  icon: icon ?? child!,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  disabledColor: kNeutralColor600,
                  iconSize: iconSize != null && iconSize! > 0 ? iconSize! : 16.0,
                  color: iconColor ?? kNeutralColor900,
                  onPressed: disabled ? null : onPressed,
                ),
              );
      default:
        return const Text(
          'Please specify your button type with the constructor e.g. RanDevButtons.elevatePrimary(...)',
          softWrap: true,
        );
    }
  }
}

class _WrapWithBadge extends StatelessWidget {
  final Widget widget;
  final String badgeValue;

  const _WrapWithBadge({required this.widget, required this.badgeValue});

  @override
  Widget build(BuildContext context) => bdg.Badge(
        badgeContent: Center(
          child: Text(
            badgeValue,
            style: AppFonts.poppinsI2Regular.copyWith(
              color: kNeutralColor100,
            ),
          ),
        ),
        badgeStyle: const bdg.BadgeStyle(
          badgeColor: kWarningNotificationColor,
        ),
        badgeAnimation: const bdg.BadgeAnimation.rotation(
          animationDuration: Duration.zero,
        ),
        position: bdg.BadgePosition.topEnd(top: -5, end: 8),
        child: widget,
      );
}
