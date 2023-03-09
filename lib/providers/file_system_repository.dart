// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

// find . -type d -name "build" -size +100cM -exec du -s -k  {}  \;
class FileSystemRepository {
  String? currentDirectory;

  Future<List<String>> getEpubFiles(String directory) async {
    log.i('getEpubFiles $directory');
    const executable = 'find';
    final arguments = [
      '.',
      '-type',
      'f',
      '-name',
      '*.epub',
    ];
    final process = await Process.run(
      executable,
      arguments,
      workingDirectory: directory,
    );
    if (process.exitCode != 0) {
      debugPrint('stderr: ${process.stderr}');
      return [];
    } else {
      final lines = (process.stdout as String).split('\n');
      return lines;
    }
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
