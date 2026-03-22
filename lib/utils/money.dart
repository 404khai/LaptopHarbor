class Money {
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final cleaned = value
          .replaceAll('₦', '')
          .replaceAll('\$', '')
          .replaceAll(',', '')
          .trim();
      final parsed = double.tryParse(cleaned);
      if (parsed != null) return parsed.round();
    }
    return 0;
  }

  static String _withCommas(int value) {
    final negative = value < 0;
    final s = value.abs().toString();
    final chars = <String>[];
    var group = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      chars.add(s[i]);
      group++;
      if (group == 3 && i != 0) {
        chars.add(',');
        group = 0;
      }
    }
    final reversed = chars.reversed.join();
    return negative ? '-$reversed' : reversed;
  }

  static String ngn(dynamic value) {
    final v = _toInt(value);
    return '₦${_withCommas(v)}';
  }
}

