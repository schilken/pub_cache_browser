import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_constants.dart';
import 'providers.dart';

class PreferencesRepository {

  PreferencesRepository(this._prefs);
  final SharedPreferences _prefs;

  String get detailDisplayMode =>
      _prefs.getString('detailDisplayMode') ??
      DetailDisplayMode.heatMap.displayName;

  Future<void> setDetailDisplayMode(String value) async {
    await _prefs.setString('detailDisplayMode', value);
  }

  String get timeRange =>
      _prefs.getString('timeRange') ?? DateRange.halfYear.displayName;

  Future<void> setTimeRange(String value) async {
    await _prefs.setString('timeRange', value);
  }

  String get sortOrder =>
      _prefs.getString('sortOrderxxx') ?? SortOrder.projectName.displayName;

  Future<void> setSortOrder(String value) async {
    await _prefs.setString('sortOrder', value);
  }

  Future<void> toggleSearchOption(String option, bool value) async {
    await _prefs.setBool(option, value);
  }

  bool getSearchOption(String option) {
    return _prefs.getBool(option) ?? false;
  }

  Future<void> setDefaultFolder(String path) async {
    await _prefs.setString('defaultFolder', path);
  }

  String get defaultFolder {
    return _prefs.getString('defaultFolder') ?? '.';
  }

  Future<void> setCommitterName(String name) async {
    await _prefs.setString('committerName', name);
  }

  String get committerName {
    return _prefs.getString('committerName') ?? '';
  }

  List<String> get ignoredFolders {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    return ignoredFolders;
  }

  List<String> get excludedProjects {
    final excludedProjects = _prefs.getStringList('excludedProjects') ?? [];
    return excludedProjects;
  }

  Future<void> addIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.add(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
  }

  Future<void> removeIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.remove(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
  }

  Future<void> addExcludedProject(String projectName) async {
    final excludedProjects = _prefs.getStringList('excludedProjects') ?? [];
    excludedProjects.add(projectName);
    await _prefs.setStringList('excludedProjects', excludedProjects);
  }

  Future<void> removeExcludedProject(String projectName) async {
    final excludedProjects = _prefs.getStringList('excludedProjects') ?? [];
    excludedProjects.remove(projectName);
    await _prefs.setStringList('excludedProjects', excludedProjects);
  }
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(
    ref.read(sharedPreferencesProvider),
  ),
);
