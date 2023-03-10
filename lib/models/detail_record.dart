import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DetailRecord {
  final String packageName;
  final String directoryPath;
  final int versionCount;
  final List<String> versions;
  int? sizeInKB;

  DetailRecord({
    required this.packageName,
    required this.directoryPath,
    required this.versionCount,
    required this.versions,
    this.sizeInKB,
  });

  DetailRecord copyWith({
    String? packageName,
    String? directoryPath,
    int? versionCount,
    List<String>? versions,
    int? sizeInKB,
  }) {
    return DetailRecord(
      packageName: packageName ?? this.packageName,
      directoryPath: directoryPath ?? this.directoryPath,
      versionCount: versionCount ?? this.versionCount,
      versions: versions ?? this.versions,
      sizeInKB: sizeInKB ?? this.sizeInKB,
    );
  }

  @override
  bool operator ==(covariant DetailRecord other) {
    if (identical(this, other)) return true;
  
    return other.packageName == packageName &&
        other.directoryPath == directoryPath &&
        other.versionCount == versionCount &&
        listEquals(other.versions, versions);
  }

  @override
  int get hashCode {
    return packageName.hashCode ^
        directoryPath.hashCode ^
        versionCount.hashCode ^
        versions.hashCode;
  }

  @override
  String toString() {
    return 'DetailRecord(packageName: $packageName, directoryPath: $directoryPath, versionCount: $versionCount, versions: $versions)';
  }
}
