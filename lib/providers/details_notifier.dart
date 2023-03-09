import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;

import '../app_constants.dart';
import '../models/detail_record.dart';
import 'providers.dart';

typedef AsyncResult = AsyncValue<List<DetailRecord>?>;

class DetailsNotifier extends AsyncNotifier<List<DetailRecord>?> {
  late MemoryCache _cache;

  late FileSystemRepository _fileSystemRepository;
  final _records = <DetailRecord>[];

  late SearchOptions _searchOptions;
  late String _defaultFolder;
  late String _sortOrder;
//  late String _displayMode;
//  late SettingsState _settings;
//  final _sectionsMap = <String, List<String>>{};

  List<String> _fileList = [];

  @override
  FutureOr<List<DetailRecord>?> build() async {
//    print('DetailsNotifier.build');
    _fileSystemRepository = ref.read(fileSystemRepositoryProvider);

    _cache = ref.watch(cacheProvider);
    _sortOrder = ref.watch(sortOrderNotifier);
    // _displayMode = ref.watch(displayModeNotifier);
    // _settings = ref.watch(settingsNotifier);
    _searchOptions = ref.watch(searchOptionsNotifier);
    _defaultFolder = ref.watch(defaultFolderNotifier);
    Future.delayed(const Duration(milliseconds: 1), scan);
    return null;
  }

  Future<void> scan() async {
    _records.clear();
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _fileSystemRepository.getPackageDirectories(_defaultFolder),
    );
    _records.addAll(state.value ?? []);
  }

  Future<void> refreshFileList() async {
    _cache.clear();
    _fileList = [];
    await scan();
  }

  List<String> get _highlights => _searchOptions.searchWord.isNotEmpty
      ? _searchOptions.searchWord.split(' ')
      : ['@-@'];


  List<DetailRecord> _filterDetails(
      List<DetailRecord> fullList, List<String> highLights) {
    final filteredList = <DetailRecord>[];
    final mayBeLowerCasedHighlights = _searchOptions.caseSensitive
        ? highLights
        : highLights.map((word) => word.toLowerCase()).toList();
    for (final detail in fullList) {
      final joinedDetails = detail.directoryPath;
      final mayBeLowerCasedCommits = _searchOptions.caseSensitive
          ? joinedDetails
          : joinedDetails.toLowerCase();
      var isContained = false;
      for (var ix = 0;
          ix < mayBeLowerCasedHighlights.length && !isContained;
          ix++) {
        if (mayBeLowerCasedCommits.contains(mayBeLowerCasedHighlights[ix])) {
          isContained = true;
        }
      }
      if (isContained == true) {
        filteredList.add(detail);
      }
    }
    return filteredList;
  }

  // Future<List<DetailRecord>> _getAllDetails() async {
  //   if (_fileList.isEmpty) {
  //     _fileList = await _fileSystemRepository.getPackages(_defaultFolder);
  //   }
  //   final details = _fileList.map((pathName) {
  //     return DetailRecord(
  //       packageName: p.basename(pathName),
  //       directoryPath: p.dirname(p.join(_defaultFolder, pathName)),
  //     );
  //   }).toList();
  //   if (_sortOrder == SortOrder.projectName.displayName) {
  //     details.sort((a, b) => a.packageName.compareTo(b.packageName));
  //   }
  //   return details;
  // }

  // void removeMessage() {
  //   log.i('removeMessage');
  //   state = DetailsState.loaded(
  //     details: [],
  //     fileCount: 0,
  //     highlights: _highlights,
  //   );
  // }
}

final detailsNotifier =
    AsyncNotifierProvider<DetailsNotifier, List<DetailRecord>?>(
  DetailsNotifier.new,
);

