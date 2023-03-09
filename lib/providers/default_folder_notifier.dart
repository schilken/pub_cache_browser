import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'providers.dart';

class DefaultFolderNotifier extends Notifier<String> {
  late PreferencesRepository _preferencesRepository;

  @override
  String build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    final currentValue = _preferencesRepository.defaultFolder;
    return currentValue;
  }

  Future<void> setFolder(String fullDirectoryPath) async {
    final reducedPath = _startWithUsersFolder(fullDirectoryPath);
    await _preferencesRepository.setDefaultFolder(reducedPath);
    state = reducedPath;
  }

  String _startWithUsersFolder(String fullPathName) {
    final parts = p.split(fullPathName);
    if (parts.length > 3 && parts[3] == 'Users') {
      return '/${p.joinAll(parts.sublist(3))}';
    }
    return fullPathName;
  }

}

final defaultFolderNotifier =
    NotifierProvider<DefaultFolderNotifier, String>(DefaultFolderNotifier.new);
