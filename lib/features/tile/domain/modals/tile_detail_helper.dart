import 'tile.dart';
import 'tile_content.dart';
import '../../../map/domain/modals/tile_map.dart';
import 'tile_quick_access.dart';
import 'tile_url.dart';
import 'tile_xml.dart';

class TileDetailHelper {
  static dynamic getTypedDetails(Tile tile) {
    if (tile.details == null || tile.type?.slug == null) {
      return null;
    }

    switch (tile.type!.slug!.toLowerCase()) {
      case 'fo_tul':
        return TileUrl.fromJson({
          'type': tile.details!['type'],
          'slug': tile.details!['slug'],
          'id': tile.details!['id'],
          'id_project': tile.details!['id_project'],
          'results': tile.details!['results'],
        });

      case 'fo_tua':
        return TileQuickAccess.fromJson({
          'type': tile.details!['type'],
          'slug': tile.details!['slug'],
          'id': tile.details!['id'],
          'id_project': tile.details!['id_project'],
          'results': tile.details!['results'],
        });

      case 'fo_tup':
        return TileContent.fromJson({
          'type': tile.details!['type'],
          'slug': tile.details!['slug'],
          'id': tile.details!['id'],
          'id_project': tile.details!['id_project'],
          'results': tile.details!['results'],
        });

      case 'fo_tuc':
        return TileMap.fromJson({
          'type': tile.details!['type'],
          'slug': tile.details!['slug'],
          'id': tile.details!['id'],
          'id_project': tile.details!['id_project'],
          'results': tile.details!['results'],
        });

      case 'fo_tux':
        return TileXml.fromJson({
          'type': tile.details!['type'],
          'slug': tile.details!['slug'],
          'id': tile.details!['id'],
          'id_project': tile.details!['id_project'],
          'results': tile.details!['results'],
        });

      default:
        return tile.details;
    }
  }

  static bool hasDetails(Tile tile) => tile.details != null && tile.details!.isNotEmpty;

  static String? getTitleFromDetails(Tile tile) {
    final typedDetails = getTypedDetails(tile);

    if (typedDetails is TileUrl) {
      return typedDetails.results?.titleTile;
    } else if (typedDetails is TileQuickAccess) {
      return (typedDetails.results?.data ?? []).isNotEmpty ? typedDetails.results!.data!.first.title : null;
    } else if (typedDetails is TileContent) {
      return typedDetails.results?.titleTile;
    } else if (typedDetails is TileMap) {
      return typedDetails.results?.titleTile;
    } else if (typedDetails is TileXml) {
      return typedDetails.results?.titleTile;
    }

    return null;
  }

  static String? getUrlFromDetails(Tile tile) {
    final typedDetails = getTypedDetails(tile);

    if (typedDetails is TileUrl) {
      return typedDetails.results?.urlTile;
    } else if (typedDetails is TileQuickAccess) {
      return (typedDetails.results?.data ?? []).isNotEmpty == true ? typedDetails.results!.data!.first.urlLink : null;
    } else if (typedDetails is TileMap) {
      return typedDetails.results?.urlTile;
    } else if (typedDetails is TileXml) {
      return typedDetails.results?.urlTile;
    }

    return null;
  }

  static String? getImageFromDetails(Tile tile) {
    final typedDetails = getTypedDetails(tile);

    if (typedDetails is TileContent) {
      return typedDetails.results?.imgTile;
    }

    return null;
  }
}
