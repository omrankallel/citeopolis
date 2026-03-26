import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_provider.dart';

class ConnectivityWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityWrapper({required this.child, super.key});

  @override
  ConsumerState<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends ConsumerState<ConnectivityWrapper> {
  bool _isOverlayReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isOverlayReady = true;
          });
          ref.read(connectivityProvider).setContext(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOverlayReady) {
      ref.listen<ConnectivityProvider>(connectivityProvider, (previous, next) {
        if (mounted) {
          next.setContext(context);
        }
      });
    }

    return widget.child;
  }
}
