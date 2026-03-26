import 'package:dartz/dartz.dart';

import '../../../domain/modals/content_home/flux_xml_rss_channel.dart';

abstract class FluxRSSService  {
  Future<Either<String, FluxXmlRSSChannel>> fetchRSSFeed(String url);
}
