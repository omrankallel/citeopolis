enum FavoriteType {
  notification('notification'),
  tileContent('tile_content'),
  tileQuickAccess('tile_quick_access'),
  tileMap('tile_map'),
  tileXml('tile_xml'),
  tileUrl('tile_url'),
  repeater('repeater'),
  buildPageCarrousel('build_page_carrousel'),
  buildPageEvent('build_page_event'),
  buildPageNews('build_page_news'),
  buildPagePublication('build_page_publication'),
  buildPageQuickAccess('build_page_quick_access');

  const FavoriteType(this.value);
  final String value;

  static FavoriteType? fromString(String value) {
    for (FavoriteType type in FavoriteType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
