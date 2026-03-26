import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/menu/menu_data_module.dart';
import '../../usecases/menu/menu_use_case.dart';
import '../../usecases/menu/menu_use_case_impl.dart';


final menuUseCaseProvider = Provider<MenuUseCase>(
  (ref) => MenuUseCaseImpl(ref.watch(menuRepositoryProvider)),
);

final updateMenu = StateProvider<bool>((ref) => false);
