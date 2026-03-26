import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tile/domain/modals/tile.dart';
import '../../router/navigation_service.dart';
import '../../router/routes.dart';
import '../config/prod_config.dart';
import '../extensions/tile_extension.dart';
import '../memory/local_storage_list_service.dart';
import '../services/injector.dart';

class TileRedirectService {
  static const int maxRedirectDepth = 10;

  Future<void> redirectToTile(
    BuildContext context,
    WidgetRef ref,
    String idTile,
    bool withScaffold, {
    Set<String>? visitedTiles,
    int depth = 0,
  }) async {
    visitedTiles ??= <String>{};

    if (depth > maxRedirectDepth || visitedTiles.contains(idTile) || idTile.isEmpty) {
      return;
    }

    visitedTiles.add(idTile);

    try {
      final tile = await _getTileById(idTile);
      if (tile?.id == null || !(tile?.publishTile ?? false)) {
        final path = withScaffold ? Paths.blankPageWithScaffold : Paths.blankPage;
        if(context.mounted){
          NavigationService.push(context, ref, path);
        }
        return;
      }
      if (context.mounted) {
        await _handleTileByType(context, ref, tile!, withScaffold, visitedTiles, depth);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'ouverture: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Tile?> _getTileById(String idTile) async {
    final storage = getIt<LocalStorageListService<Tile>>();
    final projectId = ProdConfig().projectId;
    final tiles = storage.get(projectId.toString()) ?? <Tile>[];

    try {
      return tiles.firstWhere((tile) => tile.id.toString() == idTile);
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleTileByType(
    BuildContext context,
    WidgetRef ref,
    Tile tile,
    bool withScaffold,
    Set<String> visitedTiles,
    int depth,
  ) async {
    if (tile.isContentTile) {
      await _handleContentTile(context, ref,tile, withScaffold);
    } else if (tile.isUrlTile) {
      await _handleUrlTile(context, ref, tile, withScaffold, visitedTiles, depth);
    } else if (tile.isXmlTile) {
      await _handleXmlTile(context, ref, tile, withScaffold);
    } else if (tile.isMapTile) {
      await _handleMapTile(context, ref,tile, withScaffold);
    } else if (tile.isQuickAccessTile) {
      await _handleQuickAccessTile(context, ref,tile, withScaffold);
    }
  }

  Future<void> _handleContentTile(BuildContext context,WidgetRef ref,Tile tile, bool withScaffold) async {
    final tileContent = tile.contentDetails;
    if (tileContent != null) {
      final path = withScaffold ? Paths.contentTileWithScaffold : Paths.contentTile;
      NavigationService.push(context,ref,path, extra: tileContent);
    }
  }

  Future<void> _handleUrlTile(
    BuildContext context,
    WidgetRef ref,
    Tile tile,
    bool withScaffold,
    Set<String> visitedTiles,
    int depth,
  ) async {
    final tileUrl = tile.urlDetails;
    if (tileUrl?.results == null) return;

    final typeLink = tileUrl!.results!.typeLink;

    if (typeLink == '1') {
      final nextTileId = tileUrl.results!.tile ?? '';
      if (nextTileId.isNotEmpty) {
        await redirectToTile(
          context,
          ref,
          nextTileId,
          withScaffold,
          visitedTiles: visitedTiles,
          depth: depth + 1,
        );
      }
    } else if (typeLink == '2') {
      final url = tileUrl.results!.urlTile ?? '';
      if (url.isNotEmpty) {
        final path = withScaffold ? Paths.urlTileWithScaffold : Paths.urlTile;
        NavigationService.push(context,ref,path, extra: url);
      }
    }
  }

  Future<void> _handleXmlTile(BuildContext context, WidgetRef ref, Tile tile, bool withScaffold) async {
    final tileXml = tile.xmlDetails;
    if (tileXml?.results?.feedThematic == null) return;

    final feedThematic = tileXml!.results!.feedThematic!.toLowerCase();
    final route = _getXmlTileRoute(feedThematic, withScaffold);

    NavigationService.push(context, ref, route, extra: tileXml);
  }

  Future<void> _handleMapTile(BuildContext context,WidgetRef ref,Tile tile, bool withScaffold) async {
    final tileMap = tile.mapDetails;
    if (tileMap != null) {
      final path = withScaffold ? Paths.carteWithScaffold : Paths.carte;
      NavigationService.push(context,ref,path, extra: tileMap);
    }
  }

  Future<void> _handleQuickAccessTile(BuildContext context,WidgetRef ref,Tile tile, bool withScaffold) async {
    final tileQuickAccess = tile.quickAccessDetails;
    if (tileQuickAccess != null) {
      final path = withScaffold ? Paths.quickAccessWithScaffold : Paths.quickAccess;
      NavigationService.push(context,ref,path, extra: tileQuickAccess);
    }
  }

  String _getXmlTileRoute(String feedThematic, bool withScaffold) {
    final routeMap = {
      'news': withScaffold ? Paths.articleXmlWithScaffold : Paths.articleXml,
      'articles': withScaffold ? Paths.articleXmlWithScaffold : Paths.articleXml,
      'event': withScaffold ? Paths.eventsXmlWithScaffold : Paths.eventsXml,
      'agenda': withScaffold ? Paths.eventsXmlWithScaffold : Paths.eventsXml,
      'directory': withScaffold ? Paths.directoryXmlWithScaffold : Paths.directoryXml,
      'annuaire': withScaffold ? Paths.directoryXmlWithScaffold : Paths.directoryXml,
      'downloads': withScaffold ? Paths.publicationXmlWithScaffold : Paths.publicationXml,
      'publications': withScaffold ? Paths.publicationXmlWithScaffold : Paths.publicationXml,
    };

    return routeMap[feedThematic] ?? (withScaffold ? Paths.articleXmlWithScaffold : Paths.articleXml);
  }
}
