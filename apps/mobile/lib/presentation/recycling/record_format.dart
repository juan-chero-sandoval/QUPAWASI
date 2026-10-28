import 'package:flutter/material.dart';

import '../../domain/entities/recycling_record.dart';

/// Presentación común de registros: fechas en hora local y materiales.
abstract final class RecordFormat {
  static String dateTime(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final strings = MaterialLocalizations.of(context);
    final date = strings.formatMediumDate(local);
    final time = strings.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$date, $time';
  }

  static IconData materialIcon(RecyclingMaterial material) =>
      switch (material) {
        RecyclingMaterial.pet => Icons.local_drink_outlined,
        RecyclingMaterial.aluminum => Icons.inventory_2_outlined,
      };

  static String quantity(RecyclingMaterial material, int quantity) =>
      '${material.label} × $quantity';
}
