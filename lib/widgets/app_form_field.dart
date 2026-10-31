import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/e2e.dart';

class AppFormField extends StatelessWidget {
  /// E2E selector for the input (see [e2eId]).
  final String? id;
  final String label;
  final String? hintText;

  /// Small muted line under the input ("Required").
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const AppFormField({
    super.key,
    this.id,
    required this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.prefixText,
    this.prefixStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    OutlineInputBorder border([Color? color]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: 1.5),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        _tag(
          TextFormField(
            controller: controller,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: validator,
            maxLines: maxLines,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
            // Material insets helper/error text by the 16pt content padding; pull it
            // back so it lines up with the label above the field.
            errorBuilder: (context, error) => Transform.translate(
              offset: const Offset(-20, 0),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: c.dangerStrong,
                ),
              ),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: c.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              helper: helperText == null
                  ? null
                  : Transform.translate(
                      offset: const Offset(-20, 0),
                      child: Text(
                        helperText!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: c.textMuted,
                        ),
                      ),
                    ),
              filled: true,
              fillColor: c.fill,
              constraints: maxLines == 1
                  ? const BoxConstraints(minHeight: 52)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              prefixText: prefixText,
              prefixStyle:
                  prefixStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: border(),
              enabledBorder: border(),
              focusedBorder: border(c.primary),
              errorBorder: border(c.dangerStrong),
              focusedErrorBorder: border(c.dangerStrong),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tag(Widget field) => id == null ? field : e2eId(id!, field);
}
