import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_constants.dart';
import 'providers.dart';

class TimeRangeNotifier extends Notifier<String> {
  late PreferencesRepository _preferencesRepository;

  @override
  String build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    final timeRange = _preferencesRepository.timeRange;
    return timeRange;
  }

  static final timeRanges = <String>[
    DateRange.halfYear.displayName,
    DateRange.oneYear.displayName,
    DateRange.twoYears.displayName,
  ];

  Future<void> setTimeRange(String newValue) async {
    await _preferencesRepository.setTimeRange(newValue);
    state = newValue;
  }
}

final timeRangeNotifier =
    NotifierProvider<TimeRangeNotifier, String>(TimeRangeNotifier.new);
