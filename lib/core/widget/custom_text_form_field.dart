import 'package:flutter/material.dart';

typedef MyValidator = String? Function(String?);

class CustomTextFormField extends StatefulWidget {
  final MyValidator validator;
  final TextEditingController controller;
  final TextInputType keyBoardType;
  final bool obscureText;
  final IconData? iconData;
  final String hintText;
  final double fontSize;
  final Color textColor;

  /// 🎨 ألوان البوردر
  final Color? borderColor;
  final Color? focusedBorderColor;

  final Color? backGround;
  final bool isObscured;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String?)? onSaved;

  const CustomTextFormField({
    super.key,
    required this.validator,
    required this.controller,
    this.keyBoardType = TextInputType.text,
    this.obscureText = false,
    this.iconData,
    required this.hintText,
    this.fontSize = 14.0,
    this.textColor = Colors.black,
    this.borderColor,
    this.focusedBorderColor,
    this.suffixIcon,
    this.prefixIcon,
    this.backGround,
    this.isObscured = false,
    this.onSaved,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool hidden = widget.isObscured;

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: widget.onSaved,
      validator: widget.validator,
      controller: widget.controller,
      keyboardType: widget.keyBoardType,
      obscureText: hidden,
      cursorColor:
          widget.focusedBorderColor ?? Theme.of(context).primaryColor,
      style: TextStyle(
        fontSize: widget.fontSize,
        color: widget.textColor,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: widget.backGround != null,
        fillColor: widget.backGround,

        // ================= BORDERS =================
        border: widget.borderColor == null
            ? InputBorder.none
            : _border(widget.borderColor!),

        enabledBorder: widget.borderColor == null
            ? InputBorder.none
            : _border(widget.borderColor!),

        focusedBorder: widget.borderColor == null
            ? InputBorder.none
            : _border(
                widget.focusedBorderColor ??
                    widget.borderColor!,
              ),

        // ================= ICONS =================
        prefixIcon: widget.prefixIcon ??
            (widget.iconData != null
                ? Icon(widget.iconData, color: Colors.grey)
                : null),

        suffixIcon: widget.isObscured
            ? IconButton(
                icon: Icon(
                  hidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => hidden = !hidden),
              )
            : widget.suffixIcon,

        // ================= ERROR =================
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
        errorMaxLines: 2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
