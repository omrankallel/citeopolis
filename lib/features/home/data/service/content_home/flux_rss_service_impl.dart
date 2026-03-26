import 'package:dartz/dartz.dart';
import 'package:xml/xml.dart';

import '../../../../../core/constants/service.dart';
import '../../../../../core/http/http_client.dart';
import '../../../domain/modals/content_home/flux_xml_rss_channel.dart';
import 'flux_rss_service.dart';

class FluxRSSServiceImpl implements FluxRSSService {
  @override
  Future<Either<String, FluxXmlRSSChannel>> fetchRSSFeed(String url) async {
    try {
      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);
        final rssElement = document.getElement('rss');

        if (rssElement == null) {
          return const Left('Élément RSS non trouvé dans le document XML');
        }

        final channelElement = rssElement.getElement('channel');

        if (channelElement == null) {
          return const Left('Élément channel non trouvé dans le RSS');
        }

        final channel = FluxXmlRSSChannel.fromXml(channelElement);
        return Right(channel);
      } else {
        return Left('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Erreur lors de la récupération du flux RSS: $e');
    }
  }
}
