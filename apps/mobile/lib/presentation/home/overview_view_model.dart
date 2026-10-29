import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/entities/recycling_statistics.dart';
import '../../domain/usecases/overview_use_cases.dart';
import '../common/local_stream_view_model.dart';

/// Refreshes civil-day statistics on resume and while the app stays open.
class OverviewViewModel extends LocalStreamViewModel<RecyclingStatistics>
    with WidgetsBindingObserver {
  OverviewViewModel(OverviewUseCases overview)
    : super(overview.watchStatistics) {
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now();
      if (now.day != _day.day ||
          now.month != _day.month ||
          now.year != _day.year) {
        _day = now;
        reload();
      }
    });
  }
  late final Timer _timer;
  DateTime _day = DateTime.now();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) reload();
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
