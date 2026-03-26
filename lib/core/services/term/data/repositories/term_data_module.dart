import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../network/connectivity_provider.dart';
import '../../domain/repositories/term_repository.dart';
import '../service/term_service.dart';
import '../service/term_service_impl.dart';
import 'term_repository_impl.dart';

final termProvider = Provider<TermService>((_) => TermServiceImpl());

final termRepositoryProvider = Provider<TermRepository>(
  (ref) => TermRepositoryImpl(
    ref.watch(termProvider),
    ref.watch(connectivityServiceProvider),
  ),
);
