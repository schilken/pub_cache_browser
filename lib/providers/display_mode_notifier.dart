import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_constants.dart';
import 'providers.dart';

class DisplayModeNotifier extends Notifier<String> {
  late PreferencesRepository _preferencesRepository;

  @override
  String build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    final currentValue = _preferencesRepository.detailDisplayMode;
    return currentValue;
  }

  static final displayModes = <String>[
    DetailDisplayMode.heatMapWithAll.displayName,
    DetailDisplayMode.heatMap.displayName,
    DetailDisplayMode.commitMessage.displayName,
    DetailDisplayMode.diskSpaceUsage.displayName,
    DetailDisplayMode.linesOfCode.displayName,
  ];

  Future<void> setValue(String newValue) async {
    await _preferencesRepository.setDetailDisplayMode(newValue);
    state = newValue;
  }
}

final displayModeNotifier =
    NotifierProvider<DisplayModeNotifier, String>(DisplayModeNotifier.new);
