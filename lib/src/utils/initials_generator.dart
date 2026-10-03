String generateInitials(String? value) {
  final input = value?.trim() ?? '';

  if (input.isEmpty) {
    return '?';
  }

  final parts = input
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.length == 1) {
    final word = parts.first;

    if (word.length == 1) {
      return word.toUpperCase();
    }

    return word.substring(0, 1).toUpperCase();
  }

  return '${parts.first.substring(0, 1)}'
          '${parts.last.substring(0, 1)}'
      .toUpperCase();
}
