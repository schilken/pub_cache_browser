import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import '../app_constants.dart';
import '../models/detail_record.dart';
import 'disk_usage_repository.dart';
import 'providers.dart';

typedef AsyncResult = AsyncValue<List<DetailRecord>?>;

class DetailsNotifier extends AsyncNotifier<List<DetailRecord>?> {
  late MemoryCache _cache;

  late FileSystemRepository _fileSystemRepository;
  late DiskUsageRepository _diskUsageRepository;

  late SearchOptions _searchOptions;
  late String _defaultFolder;
  late String _sortOrder;
//  late String _displayMode;
//  late SettingsState _settings;
//  final _sectionsMap = <String, List<String>>{};

  final Map<String, DetailRecord> _packageMap = {};
  final Map<String, int> _packageSizeMap = {};

  @override
  FutureOr<List<DetailRecord>?> build() async {
    _fileSystemRepository = ref.read(fileSystemRepositoryProvider);
    _diskUsageRepository = ref.read(diskUsageRepositoryProvider);
    _cache = ref.watch(cacheProvider);
    _sortOrder = ref.watch(sortOrderNotifier);
    // _displayMode = ref.watch(displayModeNotifier);
    // _settings = ref.watch(settingsNotifier);
    _searchOptions = ref.watch(searchOptionsNotifier);
    _defaultFolder = ref.watch(defaultFolderNotifier);
    Future.delayed(const Duration(milliseconds: 1), scan);
    print(
        'DetailsNotifier.build _defaultFolder: $_defaultFolder, _sortOrder: $_sortOrder');
    return null;
  }

  Future<void> scan() async {
    _packageMap.clear();
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _createDetails(_defaultFolder),
    );
  }

  Future<void> addPackageSizes() async {
    state = const AsyncValue.loading();
    _packageSizeMap.clear();
    final diskUsageRecords =
        await _diskUsageRepository.scanDiskUsage(_defaultFolder);
    for (final diskUsageRecord in diskUsageRecords) {
      final nameAndVersion = splitName(diskUsageRecord.packageName);
      if (nameAndVersion == null) {
        continue;
      }
      _packageSizeMap.update(
        nameAndVersion.item1,
        (totalSize) => totalSize + diskUsageRecord.size,
        ifAbsent: () => diskUsageRecord.size,
      );
    }
    state = await AsyncResult.guard(
      () => _enhanceDetails(_defaultFolder),
    );
  }

  Future<List<DetailRecord>> _enhanceDetails(String directory) async {
    for (final packageName in _packageMap.keys) {
      final totalSize = _packageSizeMap[packageName];
      _packageMap[packageName] =
          _packageMap[packageName]!.copyWith(sizeInKB: totalSize);
    }
    return Future.value(
      _packageMap.values.toList()..sort(sorter),
    );
  }

  Future<List<DetailRecord>> _createDetails(String directory) async {
    final directoryNames =
        _fileSystemRepository.getPackageDirectories(directory);
    for (final packageVersion in directoryNames) {
      final nameAndVersion = splitName(packageVersion);
      if (nameAndVersion == null) {
        continue;
      }
      _packageMap.update(
        nameAndVersion.item1,
        (package) => _update(
          package,
          nameAndVersion.item2,
        ),
        ifAbsent: () => DetailRecord(
          packageName: nameAndVersion.item1,
          directoryPath: p.split(directory).last,
          versionCount: 1,
          versions: [nameAndVersion.item2],
        ),
      );
    }
    return Future.value(
      _packageMap.values.toList()..sort(sorter),
    );
  }

  Tuple2<String, String>? splitName(String nameWithVersion) {
    final parts = nameWithVersion.split('-');
    if (parts.length != 2) {
      return null;
    }
    return Tuple2<String, String>(parts.first, parts.last);
  }

  int sorter(DetailRecord a, DetailRecord b) {
    if (_sortOrder == SortOrder.versionCount.displayName) {
      return b.versionCount.compareTo(a.versionCount);
    }
    return a.packageName.compareTo(b.packageName);
  }

  DetailRecord _update(DetailRecord record, String versionString) {
    return record.copyWith(
      versionCount: record.versionCount + 1,
      versions: record.versions..add(versionString),
    );
  }

  Future<void> refreshFileList() async {
    _cache.clear();
    _packageMap.clear();
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
