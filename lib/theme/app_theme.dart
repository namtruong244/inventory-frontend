import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colors that differ between light and dark. Read with
/// `context.colors`; use these instead of raw `Color(0x...)` / `Colors.white`.
@immutable
class AppColors extends ThemeExtension<AppColors> {  /// Page background behind cards.
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
  });
  static const light = AppColors(
    background: Color(0xFFF8F9FA),
    surface: Colors.white,
    fill: Color(0xFFF4F4F6),
    border: Color(0xFFE4E4E7),
    textPrimary: Color(0xFF18181B),
    // Both pass WCAG AA (4.5:1) on background, surface and fill.
    textSecondary: Color(0xFF5F5F68),
    textMuted: Color(0xFF6E6E78),
    primary: Color(0xFF18181B),
    dangerSoft: Color(0xFFFEF2F2),
    dangerStrong: Color(0xFF991B1B),
    warningSoft: Color(0xFFFEF3C7),
    warningStrong: Color(0xFF92400E),
    successSoft: Color(0xFFECFDF5),
    successStrong: Color(0xFF047857),
    infoSoft: Color(0xFFEFF6FF),
    infoStrong: Color(0xFF1D4ED8),
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
  );
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;
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
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF18181B),
    brightness: brightness,
  ).copyWith(
    primary: primary,
    onPrimary: onPrimary,
    secondary: isDark ? colors.fill : const Color(0xFFF1F5F9),
    onSecondary: colors.textPrimary,
    surface: colors.surface,
    onSurface: colors.textPrimary,
    surfaceContainerHighest: isDark ? colors.border : const Color(0xFFE2E8F0),
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
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dialogTheme: DialogThemeData(backgroundColor: colors.surface),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: colors.surface),
    dividerColor: colors.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      hintStyle: TextStyle(
        color: colors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      border: outline(),
      enabledBorder: outline(),
      focusedBorder: outline(primary),
      errorBorder: outline(const Color(0xFFEF4444)),
      focusedErrorBorder: outline(const Color(0xFFEF4444)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? onPrimary : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : null,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.transparent : null,
      ),
    ),
  );
}
