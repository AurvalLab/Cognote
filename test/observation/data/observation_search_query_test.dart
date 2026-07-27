import 'package:cognote/src/observation/data/observation_search_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'normalizes whitespace and classifies terms by Unicode scalar count',
    () {
      final query = ObservationSearchQuery.compile('  蓝雪花   AI  ');

      expect(query.normalized, '蓝雪花 AI');
      expect(query.longTerms, ['蓝雪花']);
      expect(query.shortTerms, ['AI']);
    },
  );

  test('quotes FTS phrases and doubles embedded double quotes', () {
    final query = ObservationSearchQuery.compile('a"b OR NOT');

    expect(query.matchExpression, '"a""b" AND "NOT"');
    expect(query.matchVariables, ['a"b', 'NOT']);
  });

  test(
    'short terms use parameterized instr predicates and never empty match',
    () {
      final query = ObservationSearchQuery.compile('AI %_');

      expect(query.matchExpression, isNull);
      expect(query.shortTerms, ['AI', '%_']);
      expect(query.shortTextPredicate, contains('instr('));
      expect(query.shortTextPredicate, isNot(contains('LIKE')));
      expect(query.shortTextVariables, ['AI', '%_']);
    },
  );

  test('mixed terms require both FTS and literal short-term predicates', () {
    final query = ObservationSearchQuery.compile('蓝雪花 AI');

    expect(query.matchExpression, '"蓝雪花"');
    expect(query.matchVariables, ['蓝雪花']);
    expect(query.shortTextPredicate, contains('instr('));
    expect(query.shortTextVariables, ['AI']);
  });

  test(
    'snippet uses Unicode scalar boundaries and case-insensitive English fallback',
    () {
      final raw = '前缀😀😀😀😀😀😀😀😀😀😀 Plant observation 结尾';
      final snippet = ObservationSearchQuery.snippet(raw, ['plant']);

      expect(snippet.runes.length, lessThanOrEqualTo(160));
      expect(snippet, contains('Plant'));
      expect(snippet, isNot(contains('<b>')));
    },
  );

  test(
    'snippet truncates both sides without splitting emoji and stays within 160 scalars',
    () {
      final raw =
          '${List.filled(120, '😀').join()}命中内容${List.filled(120, '🌱').join()}';

      final snippet = ObservationSearchQuery.snippet(raw, ['命中内容']);

      expect(snippet.runes.length, lessThanOrEqualTo(160));
      expect(snippet, startsWith('…'));
      expect(snippet, endsWith('…'));
      expect(snippet, contains('命中内容'));
      expect(snippet, isNot(contains('\uFFFD')));
    },
  );
}
