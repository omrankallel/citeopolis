import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/modals/tile_map.dart';
import '../viewmodel/map_view_model.dart';
import 'widgets/map_view_wrapper.dart';

class MapViewWithScaffold extends ConsumerStatefulWidget {
  final TileMap tileMap;

  const MapViewWithScaffold({
    required this.tileMap,
    super.key,
  });

  @override
  ConsumerState<MapViewWithScaffold> createState() => _MapViewWithScaffoldState();
}

class _MapViewWithScaffoldState extends ConsumerState<MapViewWithScaffold> {
  @override
  void initState() {
    ref.read(mapProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MapViewWrapper(
        withScaffold: true,
        tileMap: widget.tileMap,
      );
}
