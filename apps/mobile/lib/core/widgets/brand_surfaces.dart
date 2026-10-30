import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Superficie protagonista: solo saldos e identidad, no todas las tarjetas.
class BrandSurface extends StatelessWidget {
  const BrandSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.brandStrong, Color.lerp(p.brandStrong, p.brand, .12)!],
        ),
        boxShadow: [
          BoxShadow(
            color: p.brandStrong.withValues(alpha: .12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -90,
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: p.onBrandStrong.withValues(alpha: .10),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -90,
            top: -120,
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: p.onBrandStrong.withValues(alpha: .07),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.highlighted = false,
  });
  final String label;
  final IconData? icon;
  final bool highlighted;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final foreground = highlighted ? p.onAccent : p.onNotice;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? p.accent : p.notice,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            ExcludeSemantics(child: Icon(icon, size: 15, color: foreground)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontFamily: 'WorkSans',
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanEmblem extends StatelessWidget {
  const ScanEmblem({super.key, this.size = 144});
  final double size;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.notice,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: p.brand.withValues(alpha: .25)),
        ),
        child: Icon(
          Icons.qr_code_2_rounded,
          size: size * .65,
          color: p.brandStrong,
        ),
      ),
    );
  }
}
