extension StringX on String {
  String capitalize() {
    if (length > 0) {
      return '${this[0].toUpperCase()}${substring(1)}';
    }

    return this;
  }

  double parseDouble([double defaultValue = 0.0]) => double.tryParse(replaceAll(RegExp(r'[^0-9\.]'), '')) ?? defaultValue;
}

extension EnumToString on Enum {
  String get value => toString().split('.').last;
}
