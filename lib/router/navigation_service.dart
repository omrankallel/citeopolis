import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_history.dart';
import 'routes.dart';

class NavigationService {
  static void go(BuildContext context, WidgetRef ref, String route, {Object? extra}) {
    ref.read(routeHistoryProvider.notifier).reset(route, extra: extra);
    GoRouter.of(context).go(route, extra: extra);
  }

  static void push(BuildContext context, WidgetRef ref, String route, {Object? extra}) {
    ref.read(routeHistoryProvider.notifier).push(route, extra: extra);
    GoRouter.of(context).push(route, extra: extra);
  }

  static void back(BuildContext context, WidgetRef ref) {
    ref.read(routeHistoryProvider.notifier).pop();

    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      ref.read(routeHistoryProvider.notifier).reset(Paths.contentHome);
      router.go(Paths.contentHome);
    }
  }
}