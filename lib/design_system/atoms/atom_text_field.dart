import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_fonts.dart';
import '../../core/constants/colors.dart';

class AtomTextField extends StatefulWidget {
  final TextEditingController? fieldController;
  final String? hintText;
  final double? width;
  final String? label;
  final int maxLines;
  final GestureTapCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? textInputFormatter;
  final bool withScroll;
  final ValueChanged<String>? onChanged;
  final ScrollController? scrollController;
  final bool isPassword;
  final bool addClearButton;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextStyle? hintStyle;
  final Color? borderColor;
  final bool? validator;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final bool isDarkMode;

  const AtomTextField({
    this.fieldController,
    this.scrollController,
    this.hintText,
    this.width,
    this.label,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.withScroll = false,
    this.isPassword = false,
    this.addClearButton = false,
    this.keyboardType,
    this.textInputFormatter,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.hintStyle,
    this.borderColor,
    this.validator,
    this.floatingLabelBehavior,
    this.isDarkMode = true,
    super.key,
  });

  @override
  AtomTextFieldState createState() => AtomTextFieldState();
}

class AtomTextFieldState extends State<AtomTextField> {
  bool _obscureText = true;
  bool _showClearButton = false;

  @override
  void initState() {
    _obscureText = widget.isPassword;
    _showClearButton = widget.fieldController != null && widget.fieldController!.text.isNotEmpty;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.fieldController != null && widget.addClearButton) {
      widget.fieldController!.addListener(_updateClearButtonVisibility);
    }
  }

  @override
  void dispose() {
    if (widget.fieldController != null && widget.addClearButton) {
      widget.fieldController!.removeListener(_updateClearButtonVisibility);
    }
    super.dispose();
  }

  void _updateClearButtonVisibility() {
    final isNotEmpty = widget.fieldController != null && widget.fieldController!.text.isNotEmpty;
    if (_showClearButton != isNotEmpty) {
      setState(() {
        _showClearButton = isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        scrollController: widget.scrollController,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.textInputFormatter ?? [],
        maxLines: widget.maxLines,
        controller: widget.fieldController,
        obscureText: _obscureText,
        validator: (value) {
          if (widget.validator ?? false) {
            if (value!.isEmpty) {
              return '';
            }
            return null;
          } else {
            return null;
          }
        },
        cursorColor: onPrimaryDark,
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.bodySmall,
          labelText: widget.label,
          helperMaxLines: 1,
          errorMaxLines: 1,
          hintMaxLines: 1,
          floatingLabelBehavior: widget.floatingLabelBehavior,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? primaryDark : primaryLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? primaryDark : primaryLight,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? outlineVariantDark : outlineVariantLight,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.bodyLarge,
          suffixStyle: AppFonts.poppinsBRegular,
          hoverColor: Colors.white,
          focusColor: Colors.white,
          prefixStyle: AppFonts.poppinsBRegular,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.isPassword
              ? InkWell(
                  onTap: () => setState(() => _obscureText = !_obscureText),
                  child: Icon(
                    !_obscureText ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                    color: kNeutralColor,
                  ),
                )
              : widget.addClearButton && _showClearButton
                  ? InkWell(
                      onTap: () {
                        widget.fieldController!.clear();
                        widget.onChanged?.call('');
                      },
                      child: const Icon(
                        Icons.clear,
                        size: 16,
                        color: kNeutralColor900,
                      ),
                    )
                  : widget.suffixIcon,
          alignLabelWithHint: true,
          errorStyle: const TextStyle(height: 0.01, fontSize: 28),
          isDense: true,
        ),
      );
}
