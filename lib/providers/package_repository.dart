// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

import '../models/package_content_record.dart';

class PackageRepository {
  Future<List<PackageContentRecord>?> parseContent(String filePath) async {
    return [
      PackageContentRecord(
        fileName: 'dummy',
        size: 0,
        type: 'dummytype',
      )
    ];
  }
}

final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  final fileSystemRepository = PackageRepository();
  return fileSystemRepository;
});
