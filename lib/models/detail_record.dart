// ignore_for_file: public_member_api_docs, sort_constructors_first
class DetailRecord {
  final String packageName;
  final String directoryPath;

  DetailRecord({
    required this.packageName,
    required this.directoryPath,
  });

  DetailRecord copyWith({
    String? packageName,
    String? directoryPath,
    DateTime? latestCommit,
  }) {
    return DetailRecord(
      packageName: packageName ?? this.packageName,
      directoryPath: directoryPath ?? this.directoryPath,
    );
  }

  @override
  bool operator ==(covariant DetailRecord other) {
    if (identical(this, other)) return true;

    return other.packageName == packageName &&
        other.directoryPath == directoryPath;
  }

  @override
  int get hashCode => packageName.hashCode ^ directoryPath.hashCode;
}
