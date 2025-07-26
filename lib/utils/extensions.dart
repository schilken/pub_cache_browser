extension IntInKb on int {
  String get toKilobytes {
    if (this < 1024 * 10) {
      return '$this byte';
    } else {
      final kb = this ~/ 1024;
      return '$kb KB';
    }
  }
}

extension IntInMB on int {
  String get toMegaBytes {
    final mb = this ~/ 1024;
    if (mb > 0) {
      return '$mb MB';
    }
    return '$this kB';
  }
}
