import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/connectivity_provider.dart';
import '../../../domain/repositories/thematic/thematic_repository.dart';
import '../../service/thematic/thematic_service.dart';
import '../../service/thematic/thematic_service_impl.dart';
import 'thematic_repository_impl.dart';

final thematicProvider = Provider<ThematicService>((_) => ThematicServiceImpl());

final thematicRepositoryProvider = Provider<ThematicRepository>(
      (ref) => ThematicRepositoryImpl(
    ref.watch(thematicProvider),
    ref.watch(connectivityServiceProvider),
  ),
);
