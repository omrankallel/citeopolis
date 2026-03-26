
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_fonts.dart';
import '../core/constants/assets.dart';
import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';
import 'custom_tooltip.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? fieldController;
  final String? hintText;
  final String? label;
  final Widget? hoverWidget;
  final List<TextInputFormatter>? textInputFormatter;
  final TextInputType? textInputType;
  final int isTextArea;
  final bool isRequired;
  final bool isPassword;
  final bool addClearButton;
  final bool? isValidator;
  final TextStyle? hintStyle;
  final bool? isWhite;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final double? height;
  final double? width;
  final FocusNode? focusNode;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final bool hasError;
  final double? textFontSize;
  final Color? textColor;
  final int? maxLength;
  final String? errorText;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.label,
    this.hoverWidget,
    this.fieldController,
    this.isValidator,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.textInputType,
    this.isTextArea = 1,
    this.hintStyle,
    this.isPassword = false,
    this.isRequired = true,
    this.readOnly = false,
    this.hasError = false,
    this.addClearButton = false,
    this.height = 35,
    this.width,
    this.focusNode,
    this.enabled = true,
    this.textFontSize,
    this.maxLength,
    this.textColor,
    this.isWhite = false,
    this.textInputFormatter,
    this.errorText,
    this.validator,
  }) : assert(
          addClearButton && fieldController != null || !addClearButton,
          'Please provide the fieldController when using addClearButton.',
        );

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool hasError = false;

  @override
  void initState() {
    _obscureText = widget.isPassword;
    hasError = widget.hasError;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasError != widget.hasError || oldWidget.errorText != widget.errorText) {
      hasError = widget.hasError || widget.errorText != null;
    }
    if (hasError && !widget.hasError && widget.errorText == null && (widget.fieldController?.text.isNotEmpty ?? false)) {
      hasError = false;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: RichText(
                    text: TextSpan(
                      text: widget.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kNeutralColor900,
                        fontFamily: 'Poppins',
                      ),
                      children: [
                        if (widget.isRequired)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: kErrorClass1Color,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.hoverWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: widget.hoverWidget,
                  ),
                if (widget.isValidator != null && widget.isValidator! && (hasError || widget.errorText != null))
                  CustomTooltip(
                    message: '',
                    errorColor: kErrorClass1Color,
                    width: 180,
                    padding: EdgeInsets.zero,
                    widget: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: SvgPicture.asset(Assets.iconsError, height: 14, width: 16),
                    ),
                    msg: widget.errorText ?? (widget.isRequired && (widget.fieldController?.text.isEmpty ?? false) ? 'This field is required!' : 'Undefined validation error!'),
                    hasError: true,
                  ),
              ],
            ),
          SizedBox(
            width: widget.width ?? MediaQuery.of(context).size.width,
            height: widget.height ?? 70,
            child: TextFormField(
              maxLength: widget.maxLength,
              style: AppFonts.poppinsBRegular.copyWith(
                color: widget.isWhite!
                    ? kNeutralColor
                    : widget.readOnly
                        ? kNeutralColor800
                        : widget.textColor ?? kNeutralColor,
                fontSize: widget.textFontSize,
              ),
              inputFormatters: widget.textInputFormatter ?? [],
              enabled: widget.enabled,
              textDirection: widget.textInputType == TextInputType.phone ? TextDirection.ltr : null,
              focusNode: widget.focusNode,
              keyboardType: widget.textInputType,
              maxLines: widget.isTextArea,
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              validator: widget.validator ??
                  (value) {
                    if (widget.isValidator ?? false) {
                      if (value!.isEmpty || widget.hasError) {
                        setState(() {
                          hasError = true;
                        });
                        return '';
                      }
                      setState(() {
                        hasError = false;
                      });
                      return null;
                    } else {
                      setState(() {
                        hasError = false;
                      });
                      return null;
                    }
                  },
              onFieldSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: InputDecoration(
                fillColor: widget.isWhite!
                    ? Colors.white
                    : widget.readOnly
                        ? kNeutralColor600
                        : kNeutralColor600,
                filled: widget.isWhite!
                    ? true
                    : widget.readOnly
                        ? true
                        : !widget.enabled,
                contentPadding: const EdgeInsets.only(
                  right: 20,
                  left: 15,
                  top: 30,
                ),
                alignLabelWithHint: true,
                errorStyle: AppFonts.poppinsI2Regular.copyWith(color: Colors.red),
                isDense: true,
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(RadiusSize.regular),
                  ),
                  borderSide: BorderSide(
                    color: Color(0XFF080d12),
                    width: 0.6,
                  ),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(RadiusSize.extraLarge),
                  ),
                  borderSide: BorderSide(
                    color: Color(0XFF080d12),
                    width: 0.8,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(RadiusSize.extraLarge),
                  ),
                  borderSide: BorderSide(
                    color: Color(0XFF080d12),
                    width: 0.6,
                  ),
                ),
                errorBorder: const OutlineInputBorder(
                  gapPadding: 0,
                  borderRadius: BorderRadius.all(
                    Radius.circular(RadiusSize.extraLarge),
                  ),
                  borderSide: BorderSide(color: Colors.red, width: 0.6),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  gapPadding: 0,
                  borderRadius: BorderRadius.all(
                    Radius.circular(RadiusSize.extraLarge),
                  ),
                  borderSide: BorderSide(color: Colors.red, width: 0.6),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(RadiusSize.extraLarge),
                  ),
                  borderSide: BorderSide(
                    color: Color(0XFF080d12),
                    width: 1.5,
                  ),
                ),
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ??
                    Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: kNeutralColor800,
                        ),
                suffixIcon: widget.isPassword
                    ? InkWell(
                        onTap: () => setState(() => _obscureText = !_obscureText),
                        child: Icon(
                          !_obscureText ? Icons.visibility : Icons.visibility_off,
                          size: widget.height != null ? 0.5 * widget.height! : null,
                          color: const Color(0XFF080d12),
                        ),
                      )
                    : widget.addClearButton
                        ? InkWell(
                            onTap: () {
                              widget.fieldController!.clear();
                              widget.onChanged?.call('');
                            },
                            child: const Icon(
                              Icons.clear,
                              size: 16,
                              color: kNeutralColor700,
                            ),
                          )
                        : widget.onTap != null
                            ? InkWell(
                                onTap: widget.onTap,
                                child: widget.suffixIcon,
                              )
                            : widget.suffixIcon,
                prefixIcon: widget.onTap != null
                    ? InkWell(
                        onTap: widget.onTap,
                        child: widget.prefixIcon,
                      )
                    : widget.prefixIcon,
              ),
              controller: widget.fieldController,
              obscureText: _obscureText,
            ),
          ),
        ],
      );
}
