import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/feed_data_module.dart';
import '../usecases/feed_use_case.dart';
import '../usecases/feed_use_case_impl.dart';

final feedUseCaseProvider = Provider<FeedUseCase>(
  (ref) => FeedUseCaseImpl(ref.watch(feedRepositoryProvider)),
);

final updateFeed = StateProvider<bool>((ref) => false);
final idFeed = StateProvider<int>((ref) => -1);
final updateDetailFeedQuickAccess = StateProvider<bool>((ref) => false);
