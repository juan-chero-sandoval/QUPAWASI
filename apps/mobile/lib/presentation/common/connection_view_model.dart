import 'dart:async';

import 'package:flutter/widgets.dart';

enum InternetState { unknown, online, offline }

class ConnectionViewModel extends ChangeNotifier with WidgetsBindingObserver {
  ConnectionViewModel({Stream<bool>? changes, this.check}) {
    WidgetsBinding.instance.addObserver(this);
    _subscription = changes?.listen((online) {
      _generation++;
      _set(online ? InternetState.online : InternetState.offline);
    }, onError: (Object _) => _set(InternetState.unknown));
    refresh();
  }
  final Future<bool> Function()? check;
  StreamSubscription<bool>? _subscription;
  InternetState state = InternetState.unknown;
  int _generation = 0;
  bool _disposed = false;
  Future<void> refresh() async {
    if (check == null) return;
    final generation = ++_generation;
    try {
      final online = await check!().timeout(const Duration(seconds: 8));
      if (generation == _generation) {
        _set(online ? InternetState.online : InternetState.offline);
      }
    } catch (_) {
      if (generation == _generation) _set(InternetState.unknown);
    }
  }

  void _set(InternetState value) {
    if (_disposed || state == value) return;
    state = value;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
