// ignore_for_file: public_member_api_docs, sort_constructors_first
class Detail {
  final String fileName;
  final String directoryPath;

  Detail({
    required this.fileName,
    required this.directoryPath,
  });

  Detail copyWith({
    String? fileName,
    String? directoryPath,
    DateTime? latestCommit,
  }) {
    return Detail(
      fileName: fileName ?? this.fileName,
      directoryPath: directoryPath ?? this.directoryPath,
    );
  }
}
