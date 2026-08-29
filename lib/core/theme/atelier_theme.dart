import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AtelierColors extends ThemeExtension<AtelierColors> {
  const AtelierColors({
    required this.stone,
    required this.raised,
    required this.muted,
    required this.ivory,
    required this.ivoryMuted,
    required this.brass,
    required this.brassBright,
    required this.terracotta,
    required this.teal,
    required this.dateTint,
    required this.cashTint,
    required this.expenseTint,
    required this.calculatedTint,
    required this.identityTint,
  });

  final Color stone;
  final Color raised;
  final Color muted;
  final Color ivory;
  final Color ivoryMuted;
  final Color brass;
  final Color brassBright;
  final Color terracotta;
  final Color teal;
  final Color dateTint;
  final Color cashTint;
  final Color expenseTint;
  final Color calculatedTint;
  final Color identityTint;

  static const atelier = AtelierColors(
    stone: Color(0xFF1C1814),
    raised: Color(0xFF2A241E),
    muted: Color(0xFF3A332C),
    ivory: Color(0xFFF6F1E8),
    ivoryMuted: Color(0xFFE8DFD0),
    brass: Color(0xFFC4A574),
    brassBright: Color(0xFFD4BC8C),
    terracotta: Color(0xFFB85C38),
    teal: Color(0xFF4A7C74),
    dateTint: Color(0xFFF0D9B5),
    cashTint: Color(0xFFD5E6E2),
    expenseTint: Color(0xFFE8C9BC),
    calculatedTint: Color(0xFFE9D9A8),
    identityTint: Color(0xFFD7E3EA),
  );

  @override
  AtelierColors copyWith({
    Color? stone,
    Color? raised,
    Color? muted,
    Color? ivory,
    Color? ivoryMuted,
    Color? brass,
    Color? brassBright,
    Color? terracotta,
    Color? teal,
    Color? dateTint,
    Color? cashTint,
    Color? expenseTint,
    Color? calculatedTint,
    Color? identityTint,
  }) {
    return AtelierColors(
      stone: stone ?? this.stone,
      raised: raised ?? this.raised,
      muted: muted ?? this.muted,
      ivory: ivory ?? this.ivory,
      ivoryMuted: ivoryMuted ?? this.ivoryMuted,
      brass: brass ?? this.brass,
      brassBright: brassBright ?? this.brassBright,
      terracotta: terracotta ?? this.terracotta,
      teal: teal ?? this.teal,
      dateTint: dateTint ?? this.dateTint,
      cashTint: cashTint ?? this.cashTint,
      expenseTint: expenseTint ?? this.expenseTint,
      calculatedTint: calculatedTint ?? this.calculatedTint,
      identityTint: identityTint ?? this.identityTint,
    );
  }

  @override
  AtelierColors lerp(ThemeExtension<AtelierColors>? other, double t) {
    if (other is! AtelierColors) return this;
    return AtelierColors(
      stone: Color.lerp(stone, other.stone, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      ivory: Color.lerp(ivory, other.ivory, t)!,
      ivoryMuted: Color.lerp(ivoryMuted, other.ivoryMuted, t)!,
      brass: Color.lerp(brass, other.brass, t)!,
      brassBright: Color.lerp(brassBright, other.brassBright, t)!,
      terracotta: Color.lerp(terracotta, other.terracotta, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      dateTint: Color.lerp(dateTint, other.dateTint, t)!,
      cashTint: Color.lerp(cashTint, other.cashTint, t)!,
      expenseTint: Color.lerp(expenseTint, other.expenseTint, t)!,
      calculatedTint: Color.lerp(calculatedTint, other.calculatedTint, t)!,
      identityTint: Color.lerp(identityTint, other.identityTint, t)!,
    );
  }
}

TextTheme _atelierText(Color ivory, Color muted) {
  final plex = GoogleFonts.ibmPlexSansArabicTextTheme();
  return plex.copyWith(
    displayLarge: GoogleFonts.cairo(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      color: ivory,
      height: 1.1,
    ),
    headlineMedium: GoogleFonts.ibmPlexSansArabic(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: ivory,
      height: 1.35,
    ),
    titleLarge: GoogleFonts.ibmPlexSansArabic(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ivory,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.ibmPlexSansArabic(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ivory,
      height: 1.45,
    ),
    bodyLarge: GoogleFonts.ibmPlexSansArabic(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ivory,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.ibmPlexSansArabic(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ivory,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.ibmPlexSansArabic(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: muted,
      height: 1.45,
    ),
    labelLarge: GoogleFonts.ibmPlexSansArabic(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: ivory,
    ),
  );
}

ThemeData buildAtelierTheme() {
  const colors = AtelierColors.atelier;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.stone,
    canvasColor: colors.stone,
    dividerColor: colors.muted,
    colorScheme: ColorScheme.dark(
      surface: colors.stone,
      primary: colors.brass,
      secondary: colors.teal,
      error: colors.terracotta,
      onPrimary: colors.stone,
      onSurface: colors.ivory,
      outline: colors.brass.withValues(alpha: 0.45),
    ),
    textTheme: _atelierText(colors.ivory, colors.ivoryMuted),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.stone,
      foregroundColor: colors.brass,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: colors.brass),
      titleTextStyle: GoogleFonts.ibmPlexSansArabic(
        color: colors.brass,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.raised,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(
      color: colors.muted.withValues(alpha: 0.7),
      thickness: 0.6,
      space: 1,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.brass),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.brass,
      foregroundColor: colors.stone,
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: colors.brass,
      labelColor: colors.stone,
      unselectedLabelColor: colors.ivoryMuted,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.raised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: colors.ivoryMuted.withValues(alpha: 0.7)),
      labelStyle: GoogleFonts.ibmPlexSansArabic(
        color: colors.ivory,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.brass.withValues(alpha: 0.45)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.brass.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC4A574), width: 1.4),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.raised,
      contentTextStyle: GoogleFonts.ibmPlexSansArabic(color: colors.ivory),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.raised,
      titleTextStyle: GoogleFonts.ibmPlexSansArabic(
        color: colors.ivory,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    extensions: const [colors],
  );
}

extension AtelierContext on BuildContext {
  AtelierColors get atelier =>
      Theme.of(this).extension<AtelierColors>() ?? AtelierColors.atelier;
}
