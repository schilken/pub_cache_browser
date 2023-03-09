// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class SettingsState {
  List<String> ignoredFolders;
  List<String> excludedProjects;
  String committerName;

  SettingsState({
    required this.ignoredFolders,
    required this.excludedProjects,
    required this.committerName,
  });

  SettingsState copyWith({
    List<String>? ignoredFolders,
    List<String>? excludedProjects,
    String? committerName,
  }) {
    return SettingsState(
      ignoredFolders: ignoredFolders ?? this.ignoredFolders,
      excludedProjects: excludedProjects ?? this.excludedProjects,
      committerName: committerName ?? this.committerName,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late PreferencesRepository _preferencesRepository;

  @override
  SettingsState build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    return SettingsState(
      ignoredFolders: _preferencesRepository.ignoredFolders,
      excludedProjects: _preferencesRepository.excludedProjects,
      committerName: _preferencesRepository.committerName,
    );
  }

  Future<void> setCommitterName(String name) async {
    await _preferencesRepository.setCommitterName(name);
    state = state.copyWith(committerName: name);
  }

  Future<void> addIgnoredFolder(String folder) async {
    await _preferencesRepository.addIgnoredFolder(folder);
    state =
        state.copyWith(ignoredFolders: _preferencesRepository.ignoredFolders);
  }

  Future<void> removeIgnoredFolder(String folder) async {
    await _preferencesRepository.removeIgnoredFolder(folder);
    state =
        state.copyWith(ignoredFolders: _preferencesRepository.ignoredFolders);
  }

  Future<void> addExcludedProject(String word) async {
    await _preferencesRepository.addExcludedProject(word);
    state = state.copyWith(
      excludedProjects: _preferencesRepository.excludedProjects,
    );
  }

  Future<void> removeExcludedProject(String word) async {
    await _preferencesRepository.removeExcludedProject(word);
    state = state.copyWith(
      excludedProjects: _preferencesRepository.excludedProjects,
    );
  }
}

final settingsNotifier =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
