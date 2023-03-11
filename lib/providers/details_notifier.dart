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
        'DetailsNotifier.build _defaultFolder: $_defaultFolder, _sortOrder: $_sortOrder, _searchOptions: $_searchOptions ');
    return null;
  }

  List<String> get highlights => _searchOptions.searchWord.isNotEmpty
      ? _searchOptions.searchWord
          .split(' ')
          .where((item) => item.isNotEmpty)
          .toList()
      : [];

  Future<void> scan() async {
    _packageMap.clear();
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _createDetails(_defaultFolder),
    );
  }

  Future<List<DetailRecord>> _createDetails(String directory) async {
    _fillPackageMap(directory);
    await _fillPackageSizeMap();
    final fullList = await _enhanceDetailsWithSize();
    var filteredList = fullList;
    if (highlights.isNotEmpty) {
      //  && _searchOptions.filterEnabled) {
      filteredList = _filteredDetails(
        fullList,
        highlights,
      )..sort(sorter);
    }
    return filteredList;
  }

  Future<void> _fillPackageSizeMap() async {
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
  }

  Future<List<DetailRecord>> _enhanceDetailsWithSize() async {
    for (final packageName in _packageMap.keys) {
      final totalSize = _packageSizeMap[packageName];
      _packageMap[packageName] =
          _packageMap[packageName]!.copyWith(sizeInKB: totalSize);
    }
    return _packageMap.values.toList();
  }

  void _fillPackageMap(String directory) {
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

  List<DetailRecord> _filteredDetails(
    List<DetailRecord> fullList,
    List<String> highlights,
  ) {
    final filteredList = <DetailRecord>[];
    for (final detail in fullList) {
      final joinedDetails = detail.packageName;
      var isContained = false;
      for (var ix = 0;
          ix < highlights.length && !isContained;
          ix++) {
        if (joinedDetails.contains(highlights[ix])) {
          isContained = true;
        }
      }
      if (isContained == true) {
        filteredList.add(detail);
      }
    }
    return filteredList;
  }
  
}

final detailsNotifier =
    AsyncNotifierProvider<DetailsNotifier, List<DetailRecord>?>(
  DetailsNotifier.new,
);

final totalSizeProvider = Provider<int>((ref) {
  final diskUsageAsyncValue = ref.watch(detailsNotifier);
  return diskUsageAsyncValue.maybeMap<int>(
      data: (data) {
        final records = data.value ?? [];
        return records.fold(0, (sum, r) => sum + (r.sizeInKB ?? 0));
      },
    orElse: () => 0,
  );
});
