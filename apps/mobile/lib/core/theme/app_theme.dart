import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Ritmo visual C02: base 8, tarjetas 24, botones 18 y contenido adaptable.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double screen = 20;
  static const double cardRadius = 24;
  static const double buttonRadius = 18;
  static const double contentWidth = 720;
}

abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.brand,
          brightness: brightness,
        ).copyWith(
          primary: palette.brand,
          onPrimary: brightness == Brightness.light
              ? palette.surface
              : palette.background,
          primaryContainer: palette.notice,
          onPrimaryContainer: palette.onNotice,
          secondary: palette.brand,
          secondaryContainer: palette.iconBadge,
          onSecondaryContainer: palette.text,
          surface: palette.surface,
          onSurface: palette.text,
          onSurfaceVariant: palette.textMuted,
          outline: palette.textMuted,
          outlineVariant: palette.border,
        );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: 'WorkSans',
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    );
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      textTheme: base.textTheme
          .apply(bodyColor: palette.text, displayColor: palette.text)
          .copyWith(
            displaySmall: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 40,
              height: 1.12,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
            headlineLarge: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
            titleLarge: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
            titleMedium: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 16,
              height: 1.5,
              color: palette.text,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: palette.text,
            ),
            bodySmall: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: palette.textMuted,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'Outfit',
          fontSize: 22,
          color: palette.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: palette.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brandStrong,
          foregroundColor: palette.onBrandStrong,
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          disabledBackgroundColor: palette.iconBadge,
          disabledForegroundColor: palette.textMuted,
          shape: buttonShape,
          textStyle: const TextStyle(
            fontFamily: 'WorkSans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brand,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: buttonShape,
          side: BorderSide(color: palette.brand),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: palette.surface,
        indicatorColor: palette.accent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontFamily: 'WorkSans',
            color: palette.text,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.onAccent
                : palette.textMuted,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.brand,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: 'WorkSans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.all(16),
        labelStyle: TextStyle(color: palette.textMuted),
        helperStyle: TextStyle(
          color: palette.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.textMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.brand, width: 2),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: palette.surface,
        selectedColor: palette.notice,
        labelStyle: TextStyle(
          fontFamily: 'WorkSans',
          color: palette.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        side: BorderSide(color: palette.border),
        shape: const StadiumBorder(),
        checkmarkColor: palette.brand,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.brand,
        textColor: palette.text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: palette.text,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 14,
          height: 1.4,
          color: palette.textMuted,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.brand,
        linearTrackColor: palette.iconBadge,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: palette.text,
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.border, space: 1),
    );
  }
}
