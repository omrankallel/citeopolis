import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/thematic/thematic_data_module.dart';
import '../../usecases/thematic/thematic_use_case.dart';
import '../../usecases/thematic/thematic_use_case_impl.dart';

final thematicUseCaseProvider = Provider<ThematicUseCase>(
  (ref) => ThematicUseCaseImpl(ref.watch(thematicRepositoryProvider)),
);

final updateThematic = StateProvider<bool>((ref) => false);
