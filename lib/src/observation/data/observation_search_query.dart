class ObservationSearchQuery {
  const ObservationSearchQuery._({
    required this.normalized,
    required this.longTerms,
    required this.shortTerms,
  });

  final String normalized;
  final List<String> longTerms;
  final List<String> shortTerms;

  static ObservationSearchQuery compile(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    final terms = normalized.isEmpty ? const <String>[] : normalized.split(' ');
    return ObservationSearchQuery._(
      normalized: normalized,
      longTerms: [
        for (final term in terms)
          if (term.runes.length >= 3) term,
      ],
      shortTerms: [
        for (final term in terms)
          if (term.runes.isNotEmpty && term.runes.length <= 2) term,
      ],
    );
  }

  String? get matchExpression {
    if (longTerms.isEmpty) return null;
    return longTerms
        .map((term) => '"${term.replaceAll('"', '""')}"')
        .join(' AND ');
  }

  List<String> get matchVariables => List.unmodifiable(longTerms);

  String? get shortTextPredicate {
    if (shortTerms.isEmpty) return null;
    return List.filled(
      shortTerms.length,
      "instr(lower(coalesce(observations.raw_text, '')), lower(?)) > 0",
    ).join(' AND ');
  }

  List<String> get shortTextVariables => List.unmodifiable(shortTerms);

  static String snippet(String rawText, List<String> queryTerms) {
    final runes = rawText.runes.toList(growable: false);
    if (runes.length <= 160) return rawText;
    final lower = rawText.toLowerCase();
    var position = -1;
    for (final term in queryTerms) {
      final found = lower.indexOf(term.toLowerCase());
      if (found >= 0 && (position < 0 || found < position)) position = found;
    }
    if (position < 0) {
      return _prefix(rawText, 160);
    }
    final scalarPosition = rawText.substring(0, position).runes.length;
    final start = (scalarPosition - 60).clamp(0, runes.length);
    final end = (scalarPosition + 100).clamp(0, runes.length);
    final prefix = start > 0 ? 1 : 0;
    final suffix = end < runes.length ? 1 : 0;
    final available = 160 - prefix - suffix;
    final windowLength = end - start;
    final adjustedStart = start;
    final adjustedEnd = windowLength > available
        ? adjustedStart + available
        : end;
    final value = String.fromCharCodes(
      runes.sublist(adjustedStart, adjustedEnd),
    );
    return '${prefix == 1 ? '…' : ''}$value${suffix == 1 ? '…' : ''}';
  }

  static String _prefix(String value, int maxRunes) {
    final runes = value.runes.toList(growable: false);
    return String.fromCharCodes(runes.take(maxRunes));
  }
}
