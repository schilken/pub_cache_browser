import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
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
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _createDetails(_defaultFolder),
    );
  }

  Future<List<DetailRecord>> _createDetails(String directory) async {
    if (_packageMap.isEmpty) {
      _fillPackageMap(directory);
    }
    if (_packageSizeMap.isEmpty) {
      await _fillPackageSizeMap();
    }
    final fullList = await _updateDetails();
    var filteredList = fullList;
    if (highlights.isNotEmpty) {
      //  && _searchOptions.filterEnabled) {
      filteredList = _filteredDetails(
        fullList,
        highlights,
      );
    }
    return filteredList..sort(_sorter);
  }

  Future<void> _fillPackageSizeMap() async {
    state = const AsyncValue.loading();
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

  Future<List<DetailRecord>> _updateDetails() async {
    for (final packageName in _packageMap.keys) {
      final totalSize = _packageSizeMap[packageName];
      _packageMap[packageName] =
          _packageMap[packageName]!.copyWith(
        sizeInKB: totalSize,
        versions: _packageMap[packageName]!.versions..sort(sortVersions),
      );

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

  int sortVersions(String r1, String r2) {
    return Version.parse(r2).compareTo(Version.parse(r1));
  }

  Tuple2<String, String>? splitName(String nameWithVersion) {
    final parts = nameWithVersion.split('-');
    if (parts.length != 2) {
      return null;
    }
    return Tuple2<String, String>(parts.first, parts.last);
  }

  int _sorter(DetailRecord a, DetailRecord b) {
    if (_sortOrder == SortOrder.versionCount.displayName) {
      return b.versionCount.compareTo(a.versionCount);
    } else if (_sortOrder == SortOrder.diskUsage.displayName) {
      return b.sizeInKB.compareTo(a.sizeInKB);
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
//    _cache.clear();
    _packageMap.clear();
    _packageSizeMap.clear();
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
      for (var ix = 0; ix < highlights.length && !isContained; ix++) {
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

  Future<void> removeOldVersions() async {
    var numberOfRemovedPackageVersions = 0;
    final packages = await _createDetails(_defaultFolder);
    final sizeBefore = packages.fold<int>(0, (sum, r) => sum + r.sizeInKB);
    for (final package in packages) {
      for (final version in package.versions.sublist(1)) {
        final packagePathName =
            p.join(_defaultFolder, '${package.packageName}-$version');
        ref.read(fileSystemRepositoryProvider).removeFolder(packagePathName);
        numberOfRemovedPackageVersions++;
      }
    }
    final packagesAfter = await _createDetails(_defaultFolder);
    final sizeAfter = packagesAfter.fold<int>(0, (sum, r) => sum + r.sizeInKB);
    BotToast.showText(
      text:
          '$numberOfRemovedPackageVersions version removed, Disk Space freed: ${sizeBefore - sizeAfter}',
      duration: const Duration(seconds: 3),
      align: const Alignment(0, 0.3),
    );
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
      return records.fold(0, (sum, r) => sum + r.sizeInKB);
    },
    orElse: () => 0,
  );
});
