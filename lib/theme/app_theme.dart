import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colors that differ between light and dark. Read with
/// `context.colors`; use these instead of raw `Color(0x...)` / `Colors.white`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background behind cards.
  final Color background;

  /// Cards, sheets, dialogs.
  final Color surface;

  /// Filled inputs, chips, segmented backgrounds.
  final Color fill;

  /// Hairlines and borders.
  final Color border;

  /// Main text and icons.
  final Color textPrimary;

  /// Secondary text.
  final Color textSecondary;

  /// Placeholders and disabled hints.
  final Color textMuted;

  /// Primary buttons and selected chips; always carries white content.
  final Color primary;

  /// Tinted background for error / overdue content.
  final Color dangerSoft;

  /// Text on [dangerSoft].
  final Color dangerStrong;

  /// Tinted background for warnings.
  final Color warningSoft;

  /// Text on [warningSoft].
  final Color warningStrong;

  /// Tinted background for success / in-stock content.
  final Color successSoft;

  /// Text on [successSoft].
  final Color successStrong;

  /// Tinted background for informational content.
  final Color infoSoft;

  /// Text on [infoSoft].
  final Color infoStrong;

  /// Lime/matcha highlight: active states, primary call-to-action, progress.
  /// Always carries [onAccent] content, never white.
  final Color accent;

  /// Content color on [accent].
  final Color onAccent;

  /// Accent-colored text/icons on a plain surface (lime in dark, matcha in light).
  final Color accentStrong;

  /// Switch/toggle track when off.
  final Color trackOff;

  /// Card shadow color (design variable `shadow`).
  final Color shadow;
  const AppColors({
    required this.background,
    required this.surface,
    required this.fill,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.dangerSoft,
    required this.dangerStrong,
    required this.warningSoft,
    required this.warningStrong,
    required this.successSoft,
    required this.successStrong,
    required this.infoSoft,
    required this.infoStrong,
    this.accent = const Color(0xFFC8F169),
    this.onAccent = const Color(0xFF1B2406),
    this.accentStrong = const Color(0xFF4D7C0F),
    this.trackOff = const Color(0xFFD4D8DE),
    this.shadow = const Color(0x0F18181B),
  });
  static const light = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Colors.white,
    fill: Color(0xFFF1F3F6),
    border: Color(0xFFE9EBEF),
    textPrimary: Color(0xFF18181B),
    // Both pass WCAG AA (4.5:1) on background, surface and fill.
    textSecondary: Color(0xFF5F5F68),
    textMuted: Color(0xFF686872),
    primary: Color(0xFF18181B),
    dangerSoft: Color(0xFFFFE9E4),
    dangerStrong: Color(0xFF9F2D1C),
    warningSoft: Color(0xFFFFF3C4),
    warningStrong: Color(0xFF7A4B07),
    successSoft: Color(0xFFEAF8CC),
    successStrong: Color(0xFF3F6212),
    infoSoft: Color(0xFFE4F0FF),
    infoStrong: Color(0xFF1D4ED8),
    accentStrong: Color(0xFF4D7C0F),
    trackOff: Color(0xFFD4D8DE),
    shadow: Color(0x0F18181B),
  );
  static const dark = AppColors(
    background: Color(0xFF0B0B0D),
    surface: Color(0xFF18181B),
    fill: Color(0xFF27272A),
    border: Color(0xFF3F3F46),
    textPrimary: Color(0xFFF4F4F5),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF909098),
    primary: Color(0xFF52525B),
    dangerSoft: Color(0xFF3A1A1C),
    dangerStrong: Color(0xFFFCA5A5),
    warningSoft: Color(0xFF3A2B0E),
    warningStrong: Color(0xFFFCD34D),
    successSoft: Color(0xFF0F2E22),
    successStrong: Color(0xFF6EE7B7),
    infoSoft: Color(0xFF16233B),
    infoStrong: Color(0xFF93C5FD),
    accentStrong: Color(0xFFC8F169),
    trackOff: Color(0xFF3F3F46),
    shadow: Color(0x59000000),
  );

  /// Soft, wide drop shadow for white cards; no borders.
  List<BoxShadow> get cardShadow => [
    BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8)),
  ];
  static AppColors of(BuildContext context) {
    final theme = Theme.of(context);
    // Keep the static [AppTones] in step with the theme being built.
    AppTones.sync(theme.brightness);
    return theme.extension<AppColors>() ?? light;
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? fill,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? dangerSoft,
    Color? dangerStrong,
    Color? warningSoft,
    Color? warningStrong,
    Color? successSoft,
    Color? successStrong,
    Color? infoSoft,
    Color? infoStrong,
    Color? accent,
    Color? onAccent,
    Color? accentStrong,
    Color? trackOff,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      fill: fill ?? this.fill,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerStrong: dangerStrong ?? this.dangerStrong,
      warningSoft: warningSoft ?? this.warningSoft,
      warningStrong: warningStrong ?? this.warningStrong,
      successSoft: successSoft ?? this.successSoft,
      successStrong: successStrong ?? this.successStrong,
      infoSoft: infoSoft ?? this.infoSoft,
      infoStrong: infoStrong ?? this.infoStrong,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentStrong: accentStrong ?? this.accentStrong,
      trackOff: trackOff ?? this.trackOff,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      dangerStrong: Color.lerp(dangerStrong, other.dangerStrong, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningStrong: Color.lerp(warningStrong, other.warningStrong, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successStrong: Color.lerp(successStrong, other.successStrong, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      infoStrong: Color.lerp(infoStrong, other.infoStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      trackOff: Color.lerp(trackOff, other.trackOff, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// `context.colors` shorthand for [AppColors.of].
extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}

/// Builds the app theme for one brightness from the [AppColors] tokens.
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colors = isDark ? AppColors.dark : AppColors.light;
  final primary = colors.primary;
  const onPrimary = Colors.white;

  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF18181B),
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: colors.fill,
        onSecondary: colors.textPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: isDark
            ? colors.border
            : const Color(0xFFE2E8F0),
      );

  OutlineInputBorder outline([Color? color, double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: color == null
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );

  return base.copyWith(
    extensions: [colors],
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    ),
    textTheme: _textTheme(base.textTheme, colors),
    cardTheme: CardThemeData(
      shadowColor: const Color(0xFF1F2A44).withValues(alpha: 0.08),
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.primary,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: onPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        disabledBackgroundColor: colors.fill,
        disabledForegroundColor: colors.textMuted,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border, width: 1.5),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.accent,
      foregroundColor: colors.onAccent,
      elevation: 0,
      highlightElevation: 0,
      extendedTextStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: colors.fill,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.fill,
      selectedColor: colors.accent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerColor: colors.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: TextStyle(
        color: colors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: TextStyle(
        color: colors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      border: outline(),
      enabledBorder: outline(),
      focusedBorder: outline(primary),
      errorBorder: outline(const Color(0xFFEF4444)),
      focusedErrorBorder: outline(const Color(0xFFEF4444)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.onAccent
            : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.accent
            : colors.trackOff,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => Colors.transparent,
      ),
    ),
  );
}

TextTheme _textTheme(TextTheme base, AppColors c) {
  TextStyle s(
    double size,
    FontWeight w, {
    double? ls,
    double? h,
    Color? color,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: w,
    letterSpacing: ls,
    height: h,
    color: color ?? c.textPrimary,
  );
  // Sizes/weights are the ones used by the design frames.
  return GoogleFonts.plusJakartaSansTextTheme(base)
      .apply(bodyColor: c.textPrimary, displayColor: c.textPrimary)
      .copyWith(
        displaySmall: s(40, FontWeight.w800, ls: -1.5, h: 1.1), // hero stat
        headlineMedium: s(26, FontWeight.w800, ls: -0.6), // screen title
        headlineSmall: s(22, FontWeight.w800, ls: -0.4), // greeting / metric
        titleLarge: s(18, FontWeight.w800), // section / sheet title
        titleMedium: s(15, FontWeight.w700), // card / row title
        titleSmall: s(14, FontWeight.w700),
        bodyLarge: s(15, FontWeight.w600), // input value, settings row
        bodyMedium: s(14, FontWeight.w500),
        bodySmall: s(13, FontWeight.w500, color: c.textSecondary),
        labelLarge: s(15, FontWeight.w700), // button label
        labelMedium: s(12, FontWeight.w600, color: c.textSecondary), // caption
        labelSmall: s(
          11,
          FontWeight.w800,
          ls: 1,
          color: c.textSecondary,
        ), // overline
      );
}

/// Muted accent tones for icons, tags and progress, with the dark values from
/// the design. They are getters backed by the active theme brightness, which
/// [AppColors.of] (`context.colors`) and `MaterialApp.builder` keep in sync, so
/// existing `AppTones.xxx` call sites follow light/dark automatically (they
/// cannot be `const`).
abstract final class AppTones {
  static bool _dark = false;
  static void sync(Brightness b) => _dark = b == Brightness.dark;

  static Color get coral =>
      _dark ? const Color(0xFFFCA5A5) : const Color(0xFFD64535);
  static Color get amber =>
      _dark ? const Color(0xFFFCD34D) : const Color(0xFFB86E00);
  static Color get matcha =>
      _dark ? const Color(0xFFBEF264) : const Color(0xFF4D7C0F);
  static Color get sky =>
      _dark ? const Color(0xFF93C5FD) : const Color(0xFF2F6FCB);
  static Color get lilac =>
      _dark ? const Color(0xFFC4B5FD) : const Color(0xFF7C5CD6);
  static Color get slate =>
      _dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B);

  static Color get coralSoft =>
      _dark ? const Color(0xFF3A1A1C) : const Color(0xFFFFE9E4);
  static Color get amberSoft =>
      _dark ? const Color(0xFF3A2B0E) : const Color(0xFFFFF3C4);
  static Color get matchaSoft =>
      _dark ? const Color(0xFF1E2A0C) : const Color(0xFFEAF8CC);
  static Color get skySoft =>
      _dark ? const Color(0xFF16233B) : const Color(0xFFE4F0FF);
  static Color get lilacSoft =>
      _dark ? const Color(0xFF251E3B) : const Color(0xFFEFEAFF);
  static Color get slateSoft =>
      _dark ? const Color(0xFF27272A) : const Color(0xFFEEF1F5);

  /// Content on the always-dark "Action required" banner (`primary` stays dark
  /// in both themes), so these do not flip with the brightness.
  static const coralOnDark = Color(0xFFFCA5A5);
  static const amberOnDark = Color(0xFFFCD34D);
  static const textOnDark = Color(0xD9FFFFFF);

  /// Aliases kept for existing call sites.
  static Color get limeSoft => matchaSoft;
  static Color get sandSoft => amberSoft;

  static const ink = Color(0xFF1E293B);
  static const mist = Color(0xFFF1F3F6);
}
