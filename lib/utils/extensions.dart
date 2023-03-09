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
