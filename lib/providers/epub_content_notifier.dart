import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/epub_content_record.dart';
import 'epub_repository.dart';

typedef AsyncResult = AsyncValue<List<EpubContentRecord>?>;

class EpubContentNotifier extends AsyncNotifier<List<EpubContentRecord>?> {
  EpubContentNotifier();

  late EpubRepository _epubRepository;
  final _records = <EpubContentRecord>[];

  @override
  FutureOr<List<EpubContentRecord>?> build() async {
    _epubRepository = ref.read(epubRepositoryProvider);
    return null;
  }

  Future<void> parse(String filePath) async {
    _records.clear();
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _epubRepository.parseContent(filePath),
    );
    _records.addAll(state.value ?? []);
  }


  bool get isLoading => state.isLoading;
}

final epubContentNotifier =
    AsyncNotifierProvider<EpubContentNotifier, List<EpubContentRecord>?>(() {
  return EpubContentNotifier();
});
