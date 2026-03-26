import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/memory/data_state.dart';
import '../../core/network/connectivity_provider.dart';

class AtomStatus extends ConsumerWidget {
  final DataState? dataState;

  const AtomStatus({
    super.key,
    this.dataState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider);

    final hasConnection = dataState?.hasConnection ?? isConnected;
    final isFromCache = dataState?.isFromCache ?? false;

    if (hasConnection && !isFromCache) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasConnection ? Colors.orange.withOpacity(0.9) : Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasConnection ? Icons.cached : Icons.offline_bolt,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              hasConnection ? 'Données mises en cache' : 'Mode hors ligne',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
