import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

/// Avatar con iniciales del alias local.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.alias,
    this.radius = 24,
    this.onTap,
    this.inverted = false,
  });

  final String alias;
  final double radius;
  final VoidCallback? onTap;

  /// Usa fondo lima para colocarlo sobre una tarjeta verde oscura.
  final bool inverted;

  static String initialsOf(String alias) {
    final words = alias.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words.take(2).map((w) => w.characters.first).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: inverted ? palette.accent : palette.brandStrong,
      foregroundColor: inverted ? palette.onAccent : palette.onBrandStrong,
      child: Text(
        initialsOf(alias),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    if (onTap == null) return ExcludeSemantics(child: avatar);
    return Semantics(
      button: true,
      label: 'Abrir perfil',
      excludeSemantics: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }
}
