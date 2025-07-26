// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/disk_usage_record.dart';

class DiskUsageRepository {
  String? currentDirectory;

  Future<List<String>> _getDiskUsage(String directory) async {
    const executable = 'du';
    final arguments = [
      '-d 1',
      '-k',
      directory,
    ];
    final process = await Process.run(
      executable,
      arguments,
//      runInShell: true,
    );
    if (process.exitCode != 0) {
      debugPrint('stderr: ${process.stderr}');
      return [];
    } else {
      final lines = (process.stdout as String).split('\n');
      return lines;
    }
  }

  DiskUsageRecord? _parseDiskUsageLine(String line) {
    final pattern = RegExp(r'([0-9-]+) *(.+)$');
    final matchLogLine = pattern.matchAsPrefix(line);
    if (matchLogLine != null) {
      final String? usageInKB = matchLogLine[1];
      final String? pathName = matchLogLine[2];
      if (usageInKB != null && pathName != null) {
        return DiskUsageRecord(
          packageName: p.basename(
            pathName.trim(),
          ),
          size: int.parse(usageInKB),
        );
      }
    }
    return null;
  }

  Future<List<DiskUsageRecord>> scanDiskUsage(String directoryPath) async {
    currentDirectory = directoryPath;
    final discUsageLines = await _getDiskUsage(
      directoryPath,
    );
    final records = discUsageLines
        .map(_parseDiskUsageLine)
        .whereType<DiskUsageRecord>()
        .cast<DiskUsageRecord>()
        .toList();
    return records;
  }
}

final diskUsageRepositoryProvider = Provider<DiskUsageRepository>((ref) {
  final diskUsageRepository = DiskUsageRepository();
  return diskUsageRepository;
});
