import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/map/domain/modals/tile_map.dart';
import '../../features/tile/domain/modals/tile.dart';
import '../../features/tile/domain/modals/tile_content.dart';
import '../../features/tile/domain/modals/tile_detail_helper.dart';
import '../../features/tile/domain/modals/tile_quick_access.dart';
import '../../features/tile/domain/modals/tile_url.dart';
import '../../features/tile/domain/modals/tile_xml.dart';
import '../utils/tile_redirect_service.dart';

extension TileExtension on Tile {
  T? getTypedDetails<T>() {
    final details = TileDetailHelper.getTypedDetails(this);
    return details is T ? details : null;
  }

  bool get hasDetails => TileDetailHelper.hasDetails(this);

  String? get detailTitle => TileDetailHelper.getTitleFromDetails(this);

  String? get detailUrl => TileDetailHelper.getUrlFromDetails(this);

  String? get detailImage => TileDetailHelper.getImageFromDetails(this);

  bool get isUrlTile => type?.slug?.toLowerCase() == 'fo_tul';

  bool get isQuickAccessTile => type?.slug?.toLowerCase() == 'fo_tua';

  bool get isContentTile => type?.slug?.toLowerCase() == 'fo_tup';

  bool get isMapTile => type?.slug?.toLowerCase() == 'fo_tuc';

  bool get isXmlTile => type?.slug?.toLowerCase() == 'fo_tux';

  TileUrl? get urlDetails => getTypedDetails<TileUrl>();

  TileQuickAccess? get quickAccessDetails => getTypedDetails<TileQuickAccess>();

  TileContent? get contentDetails => getTypedDetails<TileContent>();

  TileMap? get mapDetails => getTypedDetails<TileMap>();

  TileXml? get xmlDetails => getTypedDetails<TileXml>();
}
extension TileRedirectExtension on BuildContext {
  Future<void> redirectToTile(WidgetRef ref, String idTile, bool withScaffold) async {
    final service = TileRedirectService();
    await service.redirectToTile(this, ref, idTile, withScaffold);
  }
}