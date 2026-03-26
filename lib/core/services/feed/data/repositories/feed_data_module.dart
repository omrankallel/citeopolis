import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../network/connectivity_provider.dart';
import '../../domain/repositories/feed_repository.dart';
import '../service/feed_service.dart';
import '../service/feed_service_impl.dart';
import 'feed_repository_impl.dart';

final feedProvider = Provider<FeedService>((_) => FeedServiceImpl());

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepositoryImpl(
    ref.watch(feedProvider),
    ref.watch(connectivityServiceProvider),
  ),
);
