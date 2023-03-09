import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/package_content_record.dart';
import 'package_repository.dart';

typedef AsyncResult = AsyncValue<List<PackageContentRecord>?>;

class PackageContentNotifier
    extends AsyncNotifier<List<PackageContentRecord>?> {
  PackageContentNotifier();

  late PackageRepository _packageRepository;
  final _records = <PackageContentRecord>[];

  @override
  FutureOr<List<PackageContentRecord>?> build() async {
    _packageRepository = ref.read(packageRepositoryProvider);
    return null;
  }

  Future<void> parse(String filePath) async {
    _records.clear();
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _packageRepository.parseContent(filePath),
    );
    _records.addAll(state.value ?? []);
  }

  bool get isLoading => state.isLoading;
}

final packageContentNotifier =
    AsyncNotifierProvider<PackageContentNotifier, List<PackageContentRecord>?>(
        () {
  return PackageContentNotifier();
});
