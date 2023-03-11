// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;

import '../models/detail_record.dart';

// find . -type d -name "build" -size +100cM -exec du -s -k  {}  \;
class FileSystemRepository {
  String? currentDirectory;

  List<String> getPackageDirectories(String directory) {
    log.i('getPackageDirectories $directory');
    final dir = Directory(directory);
    final entities = dir.listSync();
    return entities
        .map((entity) => p.basename(entity.path))
        .where((packageName) => !packageName.startsWith('.'))
        .toList()
      ..sort((r1, r2) => r1.compareTo(r2));
  }

  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> writeTextFile(String filePath, String contents) async {
    try {
      final file = File(filePath);
      await file.writeAsString(contents);
      return 'ok';
    } on Exception catch (e) {
      return e.toString();
    }
  }
}

final fileSystemRepositoryProvider = Provider<FileSystemRepository>((ref) {
  final fileSystemRepository = FileSystemRepository();
  return fileSystemRepository;
});
