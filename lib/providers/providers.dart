import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'app_commands.dart';
export 'default_folder_notifier.dart';
export 'details_notifier.dart';
export 'display_mode_notifier.dart';
export 'file_system_repository.dart';
export 'memory_cache.dart';
export 'preferences_repository.dart';
export 'search_options_notifier.dart';
export 'settings_notifier.dart';
export 'sort_order_notifier.dart';
export 'time_range_notifier.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
  name: 'SharedPreferencesProvider',
);
