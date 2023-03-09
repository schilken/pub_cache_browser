// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchOptions {
  final String searchWord;
  final bool caseSensitive;
  final bool filterEnabled;
  SearchOptions(
    this.searchWord,
    this.caseSensitive,
    this.filterEnabled,
  );

  SearchOptions copyWith({
    String? searchWord,
    bool? caseSensitive,
    bool? filterEnabled,
  }) {
    return SearchOptions(
      searchWord ?? this.searchWord,
      caseSensitive ?? this.caseSensitive,
      filterEnabled ?? this.filterEnabled,
    );
  }
}

class SearchOptionsNotifier extends Notifier<SearchOptions> {
  @override
  SearchOptions build() {
    return SearchOptions('', false, false);
  }

  Future<void> setSearchWord(String newString) async {
    state = state.copyWith(searchWord: newString);
  }

  Future<void> setCaseSensitiv(bool newBool) async {
    state = state.copyWith(caseSensitive: newBool);
  }

  Future<void> setFilterEnabled(bool newBool) async {
    state = state.copyWith(filterEnabled: newBool);
  }
}

final searchOptionsNotifier =
    NotifierProvider<SearchOptionsNotifier, SearchOptions>(
        SearchOptionsNotifier.new);
