import 'package:flutter/material.dart';

/// Tokens semánticos de color (docs/DISENO.md). Los widgets usan estos
/// nombres, nunca colores fijos, para que el modo oscuro sea coherente.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.brand,
    required this.brandStrong,
    required this.onBrandStrong,
    required this.accent,
    required this.onAccent,
    required this.notice,
    required this.onNotice,
    required this.iconBadge,
  });

  static const AppPalette light = AppPalette(
    background: Color(0xFFF5F7F1),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFDDE5D9),
    text: Color(0xFF17392D),
    textMuted: Color(0xFF53675A),
    brand: Color(0xFF087554),
    brandStrong: Color(0xFF064B38),
    onBrandStrong: Color(0xFFFFFFFF),
    accent: Color(0xFFC2EB63),
    onAccent: Color(0xFF193B24),
    notice: Color(0xFFEDF4DF),
    onNotice: Color(0xFF29452C),
    iconBadge: Color(0xFFE7F0DE),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0D1914),
    surface: Color(0xFF17281F),
    border: Color(0xFF334B3E),
    text: Color(0xFFEFF6F0),
    textMuted: Color(0xFFB6C9BC),
    brand: Color(0xFF78D5A5),
    brandStrong: Color(0xFF144D39),
    onBrandStrong: Color(0xFFFFFFFF),
    accent: Color(0xFFC2EB63),
    onAccent: Color(0xFF193B24),
    notice: Color(0xFF263D27),
    onNotice: Color(0xFFE1EFD2),
    iconBadge: Color(0xFF233D2D),
  );

  final Color background;
  final Color surface;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color brand;
  final Color brandStrong;
  final Color onBrandStrong;
  final Color accent;
  final Color onAccent;
  final Color notice;
  final Color onNotice;
  final Color iconBadge;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? text,
    Color? textMuted,
    Color? brand,
    Color? brandStrong,
    Color? onBrandStrong,
    Color? accent,
    Color? onAccent,
    Color? notice,
    Color? onNotice,
    Color? iconBadge,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      onBrandStrong: onBrandStrong ?? this.onBrandStrong,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      notice: notice ?? this.notice,
      onNotice: onNotice ?? this.onNotice,
      iconBadge: iconBadge ?? this.iconBadge,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      onBrandStrong: Color.lerp(onBrandStrong, other.onBrandStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      notice: Color.lerp(notice, other.notice, t)!,
      onNotice: Color.lerp(onNotice, other.onNotice, t)!,
      iconBadge: Color.lerp(iconBadge, other.iconBadge, t)!,
    );
  }
}
