import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoryCache {
  String _gitLogCache = '';
  bool get hasGitLogData => _gitLogCache.isNotEmpty;
  void saveGitLogData(String data) => _gitLogCache = data;
  String get gitLogData => _gitLogCache;

  String _diskUsageLogLogCache = '';
  bool get hasDiskUsageLogData => _diskUsageLogLogCache.isNotEmpty;
  void saveDiskUsageLogData(String data) => _diskUsageLogLogCache = data;
  String get diskUsageLogData => _diskUsageLogLogCache;

  void clear() {
    _gitLogCache = '';
    _diskUsageLogLogCache = '';
  }
}

final cacheProvider = Provider((ref) => MemoryCache());
