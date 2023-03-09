// ignore_for_file: public_member_api_docs, sort_constructors_first
class EpubContentRecord {
  EpubContentRecord({
    required this.fileName,
    required this.size,
    required this.type,
  });

  final String fileName;
  final int size;
  final String type;

  EpubContentRecord copyWith({
    String? fileName,
    int? size,
    String? type,
  }) {
    return EpubContentRecord(
      fileName: fileName ?? this.fileName,
      size: size ?? this.size,
      type: type ?? this.type,
    );
  }
}
