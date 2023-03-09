import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_constants.dart';
import 'providers.dart';

class SortOrderNotifier extends Notifier<String> {
  late PreferencesRepository _preferencesRepository;

  @override
  String build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    final currentValue = _preferencesRepository.sortOrder;
    return currentValue;
  }

  static final sortOrders = <String>[
    SortOrder.projectName.displayName,
//    SortOrder.diskUsage.displayName,
  ];

  Future<void> setValue(String newValue) async {
    await _preferencesRepository.setSortOrder(newValue);
    state = newValue;
  }
}

final sortOrderNotifier =
    NotifierProvider<SortOrderNotifier, String>(SortOrderNotifier.new);
