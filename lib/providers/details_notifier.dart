import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;

import '../app_constants.dart';
import '../models/detail.dart';
import 'providers.dart';

part 'details_notifier.freezed.dart';

@freezed
class DetailsState with _$DetailsState {
  const DetailsState._();

  const factory DetailsState.inProgress() = _InProgress;

  const factory DetailsState.loaded({
    required List<Detail> details,
    required int fileCount,
    String? message,
    String? commandAsString,
    List<String>? highlights,
  }) = _Loaded;
}

class DetailsNotifier extends Notifier<DetailsState> {
  late MemoryCache _cache;

  late FileSystemRepository _fileSystemRepository;

  late SearchOptions _searchOptions;
  late String _defaultFolder;
  late String _sortOrder;
//  late String _displayMode;
//  late SettingsState _settings;
//  final _sectionsMap = <String, List<String>>{};

  List<String> _fileList = [];

  @override
  DetailsState build() {
//    print('DetailsNotifier.build');
    _fileSystemRepository = ref.read(fileSystemRepositoryProvider);

    _cache = ref.watch(cacheProvider);
    _sortOrder = ref.watch(sortOrderNotifier);
    // _displayMode = ref.watch(displayModeNotifier);
    // _settings = ref.watch(settingsNotifier);
    _searchOptions = ref.watch(searchOptionsNotifier);
    _defaultFolder = ref.watch(defaultFolderNotifier);
    Future.delayed(const Duration(milliseconds: 1), scanFolder);
    return const DetailsState.inProgress();
  }

  Future<void> refreshFileList() async {
    _cache.clear();
    _fileList = [];
    await scanFolder();
  }

  List<String> get _highlights => _searchOptions.searchWord.isNotEmpty
      ? _searchOptions.searchWord.split(' ')
      : ['@-@'];

  Future<void> scanFolder() async {
    debugPrint('scanGitLogsOfAllProjects');
    state = const DetailsState.inProgress();
    var details = await _getAllDetails();
    if (_searchOptions.filterEnabled) {
      details = _filterDetails(details, _highlights);
    }
    state = DetailsState.loaded(
      details: details,
      fileCount: details.length,
      highlights: _highlights,
    );
  }

  List<Detail> _filterDetails(List<Detail> fullList, List<String> highLights) {
    final filteredList = <Detail>[];
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

  Future<List<Detail>> _getAllDetails() async {
    if (_fileList.isEmpty) {
      _fileList = await _fileSystemRepository.getEpubFiles(_defaultFolder);
    }
    final details = _fileList.map((pathName) {
      return Detail(
        fileName: p.basename(pathName),
        directoryPath: p.dirname(p.join(_defaultFolder, pathName)),
      );
    }).toList();
    if (_sortOrder == SortOrder.projectName.displayName) {
      details.sort((a, b) => a.fileName.compareTo(b.fileName));
    }
    return details;
  }

  void removeMessage() {
    log.i('removeMessage');
    state = DetailsState.loaded(
      details: [],
      fileCount: 0,
      highlights: _highlights,
    );
  }
}

final detailsNotifier =
    NotifierProvider<DetailsNotifier, DetailsState>(DetailsNotifier.new);
