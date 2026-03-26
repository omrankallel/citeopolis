import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/content_home/content_home_data_module.dart';
import '../../usecases/content_home/content_home_use_case.dart';
import '../../usecases/content_home/content_home_use_case_impl.dart';


final contentHomeUseCaseProvider = Provider<ContentHomeUseCase>(
  (ref) => ContentHomeUseCaseImpl(ref.watch(contentHomeRepositoryProvider)),
);

final updateContentHome = StateProvider<bool>((ref) => false);
