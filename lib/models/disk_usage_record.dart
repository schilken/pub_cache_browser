class DiskUsageRecord {
  final String packageName;
  final int size;
  DiskUsageRecord({
    required this.packageName,
    required this.size,
  });

  DiskUsageRecord copyWith({
    String? packageName,
    int? size,
    bool? isSelected,
  }) {
    return DiskUsageRecord(
      packageName: packageName ?? this.packageName,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(covariant DiskUsageRecord other) {
    if (identical(this, other)) return true;

    return other.packageName == packageName && other.size == size;
  }

  @override
  int get hashCode => packageName.hashCode ^ size.hashCode;
}
