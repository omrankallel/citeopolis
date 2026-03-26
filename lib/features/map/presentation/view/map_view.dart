import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/modals/tile_map.dart';
import '../viewmodel/map_view_model.dart';
import 'widgets/map_view_wrapper.dart';

class MapView extends ConsumerStatefulWidget {
  final TileMap tileMap;

  const MapView({
    required this.tileMap,
    super.key,
  });

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  @override
  void initState() {
    ref.read(mapProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MapViewWrapper(
        withScaffold: false,
        tileMap: widget.tileMap,
      );
}
