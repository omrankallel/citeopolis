import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/preloader_data_module.dart';
import '../usecases/preloader_use_case.dart';
import '../usecases/preloader_use_case_impl.dart';

final preloaderUseCaseProvider = Provider<PreloaderUseCase>(
  (ref) => PreloaderUseCaseImpl(ref.watch(preloaderRepositoryProvider)),
);

final updatePreloader = StateProvider<bool>((ref) => false);
