import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/publicity_data_module.dart';
import '../usecases/publicity_use_case.dart';
import '../usecases/publicity_use_case_impl.dart';

final publicityUseCaseProvider = Provider<PublicityUseCase>(
  (ref) => PublicityUseCaseImpl(ref.watch(publicityRepositoryProvider)),
);

final updatePublicity = StateProvider<bool>((ref) => false);
