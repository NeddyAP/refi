import 'package:flutter/material.dart';

/// A safe text widget that automatically handles text overflow
/// Useful for ensuring text displays properly when the app is offline
/// and might show cached content, error messages, or longer localized text
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool softWrap;
  final double? textScaleFactor;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap = true,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textDirection,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  /// Factory constructor for multiline text (commonly used for descriptions)
  const SafeText.multiline(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 3,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap = true,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textDirection,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  /// Factory constructor for error messages
  const SafeText.error(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 4,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.center,
    this.softWrap = true,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textDirection,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  /// Factory constructor for titles that might be long when offline
  const SafeText.title(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap = true,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textDirection,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  /// Factory constructor for navigation and UI labels
  const SafeText.label(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap = false,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textDirection,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
      locale: locale,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Extension to provide safe text methods on strings
extension SafeTextExtension on String {
  /// Convert string to a safe single-line text widget
  Widget toSafeText({
    TextStyle? style,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
  }) {
    return SafeText(
      this,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  /// Convert string to a safe multiline text widget
  Widget toSafeMultilineText({
    TextStyle? style,
    int maxLines = 3,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
  }) {
    return SafeText.multiline(
      this,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  /// Convert string to a safe error text widget
  Widget toSafeErrorText({
    TextStyle? style,
    int maxLines = 4,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return SafeText.error(
      this,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}