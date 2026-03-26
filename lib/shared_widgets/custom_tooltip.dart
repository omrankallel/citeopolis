import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../core/constants/app_fonts.dart';
import '../core/constants/assets.dart';
import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';

class CustomTooltip extends StatelessWidget {
  const CustomTooltip({
    required this.hasError,
    required this.widget,
    this.alignmentText = TextAlign.center,
    this.message,
    this.overrideMessage,
    this.errorWidget,
    this.padding,
    this.offset,
    this.backgroundColor,
    this.errorColor,
    this.isModal,
    this.openOnHover,
    this.showDuration,
    super.key,
    this.msg = 'There is no line selected',
    this.width = 165,
  }) : assert(
          message != null || overrideMessage != null,
          'Please provide either a message or overrideMessage',
        );

  final TextAlign? alignmentText;
  final String? message;
  final String? msg;
  final Widget widget;
  final Widget? overrideMessage;
  final Widget? errorWidget;
  final bool hasError;
  final EdgeInsets? padding;
  final double? offset;
  final double? width;
  final Color? backgroundColor;
  final Color? errorColor;
  final bool? isModal;
  final bool? openOnHover;
  final Duration? showDuration;

  @override
  Widget build(BuildContext context) => JustTheTooltip(
        offset: offset ?? 0,
        isModal: isModal ?? false,
        showDuration: showDuration,
        content: Padding(
          padding: hasError ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: overrideMessage ??
              (hasError
                  ? Container(
                      width: width,
                      // height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(RadiusSize.regular),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: width,
                            height: 5,
                            decoration: BoxDecoration(
                              color: errorColor ?? kWarningSystemColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(RadiusSize.regular),
                                topRight: Radius.circular(RadiusSize.regular),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(Paddings.large),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  Assets.iconsError,
                                  colorFilter: ColorFilter.mode(errorColor ?? kWarningSystemColor, BlendMode.srcIn),
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(
                                  width: Paddings.regular,
                                ),
                                Expanded(
                                  child: errorWidget ??
                                      Text(
                                        msg!,
                                        style: AppFonts.poppinsL1SemiBold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      message!,
                      textAlign: alignmentText,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: kNeutralColor100,
                          ),
                    )),
        ),
        tailLength: 8,
        tailBaseWidth: 14,
        backgroundColor: hasError ? kNeutralColor100 : backgroundColor ?? kSecondaryColor,
        preferredDirection: AxisDirection.up,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(Paddings.regular),
          child: widget,
        ),
      );
}
