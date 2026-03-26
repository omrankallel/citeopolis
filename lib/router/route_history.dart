import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteEntry {
  final String route;
  final Object? extra;

  RouteEntry(this.route, {this.extra});
}

class RouteHistoryNotifier extends StateNotifier<List<RouteEntry>> {
  RouteHistoryNotifier() : super([]);

  void push(String route, {Object? extra}) {
    state = [...state, RouteEntry(route, extra: extra)];
  }

  void reset(String route, {Object? extra}) {
    state = [RouteEntry(route, extra: extra)];
  }

  void pop() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
    }
  }

  RouteEntry? get previous => state.length > 1 ? state[state.length - 2] : null;

  RouteEntry? get current => state.isNotEmpty ? state.last : null;

  bool get canGoBack => state.length > 1;
}

final routeHistoryProvider = StateNotifierProvider<RouteHistoryNotifier, List<RouteEntry>>(
  (ref) => RouteHistoryNotifier(),
);
