import '../../../map/domain/modals/tile_map.dart';
import '../../../map/domain/modals/xml_map.dart';
import '../../../tile/domain/modals/tile_content.dart';
import '../../../tile/domain/modals/tile_quick_access.dart';
import '../../../tile/domain/modals/tile_url.dart';
import '../../../tile/domain/modals/tile_xml.dart';
import '../../../tile/domain/modals/xml/xml_article.dart';
import '../../../tile/domain/modals/xml/xml_directory.dart';
import '../../../tile/domain/modals/xml/xml_event.dart';
import '../../../tile/domain/modals/xml/xml_publication.dart';
import '../modals/favorite.dart';

class FavoriteFactory {
  static const String tileContentType = 'fo_tup';
  static const String tileQuickAccessType = 'fo_tua';
  static const String tileMapType = 'fo_tuc';
  static const String tileUrlType = 'fo_tul';
  static const String tileXmlType = 'fo_tux';
  static const String tileXmlArticleType = 'fo_tux_article';
  static const String tileXmlDirectoryType = 'fo_tux_directory';
  static const String tileXmlPublicationType = 'fo_tux_publication';
  static const String tileXmlEventType = 'fo_tux_event';

  static Favorite fromTileContent(TileContent tile) => Favorite(
        id: 'tile_content_${tile.id}',
        type: tileContentType,
        title: tile.results?.titleTile ?? 'Contenu sans titre',
        subtitle: tile.results?.descTile,
        imageUrl: tile.results?.imgTile,
        localImagePath: tile.results?.localPath,
        originalData: tile.toJson(),
        createdAt: DateTime.now(),
      );

  static Favorite fromTileQuickAccess(TileQuickAccess tile) => Favorite(
        id: 'tile_quick_access_${tile.id}',
        type: tileQuickAccessType,
        title: 'Accès rapide',
        subtitle: '${tile.results?.data?.length ?? 0} éléments',
        originalData: tile.toJson(),
        createdAt: DateTime.now(),
      );

  static Favorite fromTileMap(TileMap tileMap, MapXml mapXml) => Favorite(
        id: 'tile_map_${tileMap.id}_${mapXml.title.hashCode}',
        type: tileMapType,
        title: tileMap.results?.titleTile ?? 'Carte sans titre',
        subtitle: '${tileMap.results?.numberElement ?? 0} éléments',
        createdAt: DateTime.now(),
        originalData: {
          'tileMap': tileMap.toJson(),
          'mapXml': mapXml.toJson(),
        },
      );

  static Favorite fromTileXml(TileXml tile) => Favorite(
        id: 'tile_xml_${tile.id}',
        type: tileXmlType,
        title: tile.results?.titleTile ?? 'XML sans titre',
        subtitle: '${tile.results?.numberElement ?? 0} éléments',
        originalData: tile.results!.toJson(),
        createdAt: DateTime.now(),
      );

  static Favorite fromTileUrl(TileUrl tile) => Favorite(
        id: 'tile_url_${tile.id}',
        type: tileUrlType,
        title: tile.results?.titleTile ?? 'URL sans titre',
        subtitle: tile.results?.urlTile,
        originalData: tile.toJson(),
        createdAt: DateTime.now(),
      );

  static Favorite fromArticleXml(TileXml tileXml, Article article) => Favorite(
        id: 'tile_xml_${tileXml.id}_${article.title.hashCode}',
        type: tileXmlArticleType,
        title: article.title,
        subtitle: tileXml.results?.titleTile,
        imageUrl: article.mainImage,
        originalData: {
          'tileXmlId': tileXml.id,
          'tileXmlTitle': tileXml.results?.titleTile,
          'tileXmlUrl': tileXml.results?.urlTile,
          'article': {
            'title': article.title,
            'category': article.category,
            'mainImage': article.mainImage,
            'summary': article.summary,
            'pubDate': article.pubDate,
            'updateDate': article.updateDate,
            'imageCaption': article.imageCaption,
            'content': article.content,
          },
        },
        createdAt: DateTime.now(),
      );

  static Favorite fromDirectoryXml(TileXml tileXml, Directory directory) => Favorite(
        id: 'tile_xml_${tileXml.id}_directory_${directory.title.hashCode}',
        type: tileXmlDirectoryType,
        title: directory.title,
        subtitle: tileXml.results?.titleTile,
        imageUrl: directory.title,
        originalData: {
          'tileXmlId': tileXml.id,
          'tileXmlTitle': tileXml.results?.titleTile,
          'tileXmlUrl': tileXml.results?.urlTile,
          'directory': {
            'title': directory.title,
            'category': directory.category,
            'summary': directory.summary,
            'pubDate': directory.pubDate,
            'updateDate': directory.updateDate,
            'mainImage': directory.mainImage,
            'imageCaption': directory.imageCaption,
            'content': directory.content,
            'location': directory.location.toJson(),
            'additionalInformation': directory.additionalInformation,
            'schedule': directory.schedule.map((e) => e.toJson()).toList(),
            'website': directory.website,
            'phone1': directory.phone1,
            'phone2': directory.phone2,
            'email': directory.email,
            'contact': directory.contact.toJson(),
            'facebook': directory.facebook,
            'twitter': directory.twitter,
            'instagram': directory.instagram,
            'linkedin': directory.linkedin,
            'youtube': directory.youtube,
          },
        },
        createdAt: DateTime.now(),
      );

  static Favorite fromPublicationXml(TileXml tileXml, Publication publication) => Favorite(
        id: 'tile_xml_${tileXml.id}_${publication.title.hashCode}',
        type: tileXmlPublicationType,
        title: publication.title,
        subtitle: tileXml.results?.titleTile,
        imageUrl: publication.mainImage,
        originalData: {
          'tileXmlId': tileXml.id,
          'tileXmlTitle': tileXml.results?.titleTile,
          'tileXmlUrl': tileXml.results?.urlTile,
          'publication': {
            'title': publication.title,
            'category': publication.category,
            'mainImage': publication.mainImage,
            'summary': publication.summary,
            'pubDate': publication.pubDate,
            'updateDate': publication.updateDate,
            'imageCaption': publication.imageCaption,
            'content': publication.content,
            'downloadFile': publication.downloadFile.toJson(),
          },
        },
        createdAt: DateTime.now(),
      );

  static Favorite fromEventXml(TileXml tileXml, Event event) => Favorite(
        id: 'tile_xml_${tileXml.id}_${event.title.hashCode}',
        type: tileXmlEventType,
        title: event.title,
        subtitle: tileXml.results?.titleTile,
        imageUrl: event.mainImage,
        originalData: {
          'tileXmlId': tileXml.id,
          'tileXmlTitle': tileXml.results?.titleTile,
          'tileXmlUrl': tileXml.results?.urlTile,
          'event': {
            'title': event.title,
            'category': event.category,
            'summary': event.summary,
            'pubDate': event.pubDate,
            'updateDate': event.updateDate,
            'eventStartDate': event.eventStartDate,
            'eventEndDate': event.eventEndDate,
            'eventStartTime': event.eventStartTime,
            'eventEndTime': event.eventEndTime,
            'mainImage': event.mainImage,
            'imageCaption': event.imageCaption,
            'content': event.content,
            'location': event.location.toJson(),
          },
        },
        createdAt: DateTime.now(),
      );
}
