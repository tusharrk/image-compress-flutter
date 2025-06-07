import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final String? initialValue;
  final String? helperText;
  final String? counterText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final bool isFloatinglabel;
  final bool isFilled;
  final bool isDense;

  const AppTextField({
    required this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.initialValue,
    this.helperText,
    this.counterText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.isFloatinglabel = true,
    this.isFilled = false,
    this.isDense = false,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;
  var borderRadius = const BorderRadius.all(Radius.circular(10));

  late OutlineInputBorder outLineBorder;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;

    outLineBorder = OutlineInputBorder(borderRadius: borderRadius);

    if (widget.isFilled) {
      outLineBorder = OutlineInputBorder(
          borderRadius: borderRadius, borderSide: BorderSide.none);
    }
    if (widget.errorText != null) {
      outLineBorder = OutlineInputBorder(borderRadius: borderRadius);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isFloatinglabel)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(widget.label ?? ''),
          ),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          initialValue: widget.initialValue,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.isFloatinglabel ? null : widget.label,
            hintText: widget.hintText,
            helperText: widget.helperText,
            counterText: widget.counterText,
            errorText: widget.errorText,
            alignLabelWithHint: true,
            isDense: widget.isDense,
            filled: widget.isFilled,
            floatingLabelBehavior: widget.isFloatinglabel
                ? FloatingLabelBehavior.never
                : FloatingLabelBehavior.auto,
            border: outLineBorder,
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() {
                      _obscureText = !_obscureText;
                    }),
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(widget.suffixIcon),
                        onPressed: widget.onSuffixTap,
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
