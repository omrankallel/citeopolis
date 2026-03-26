import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/term_data_module.dart';
import '../usecases/term_use_case.dart';
import '../usecases/term_use_case_impl.dart';

final termUseCaseProvider = Provider<TermUseCase>(
  (ref) => TermUseCaseImpl(ref.watch(termRepositoryProvider)),
);

final updateTerm = StateProvider<bool>((ref) => false);
final idTerm = StateProvider<int>((ref) => -1);
final updateDetailTermQuickAccess = StateProvider<bool>((ref) => false);
