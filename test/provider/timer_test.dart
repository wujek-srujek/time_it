import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:time_it/provider/interval_group.dart';
import 'package:time_it/provider/timer.dart';

void main() {
  for (final config in [
    const _TestConfig(
      input: [],
      expected: [],
    ),
    _TestConfig(
      input: [
        IntervalGroup(
          intervalDefinitions: const [
            IntervalDefinition(seconds: 1),
          ],
        ),
      ],
      expected: [
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 1),
            ordinal: 1,
            totalCount: 1,
          ),
        ),
      ],
    ),
    _TestConfig(
      input: [
        IntervalGroup(
          intervalDefinitions: const [
            IntervalDefinition(seconds: 1),
            IntervalDefinition(seconds: 2),
          ],
        ),
        IntervalGroup(
          intervalDefinitions: const [
            IntervalDefinition(seconds: 3, repetitions: 2),
            IntervalDefinition(seconds: 4, repetitions: 2),
          ],
          repetitions: 2,
        ),
      ],
      expected: [
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 1),
            ordinal: 1,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 2),
            ordinal: 2,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 3),
            ordinal: 3,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 3),
            ordinal: 4,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 4),
            ordinal: 5,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 4),
            ordinal: 6,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 3),
            ordinal: 7,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 3),
            ordinal: 8,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 4),
            ordinal: 9,
            totalCount: 10,
          ),
        ),
        _matches(
          const IntervalInfo(
            interval: Duration(seconds: 4),
            ordinal: 10,
            totalCount: 10,
          ),
        ),
      ],
    ),
  ]) {
    test('IntervalInfoIterable works', () {
      expect(
        IntervalInfoIterable(config.input),
        config.expected,
      );
    });
  }
}

@immutable
class _TestConfig {
  final Iterable<IntervalGroup> input;
  final Iterable<Matcher> expected;

  const _TestConfig({
    required this.input,
    required this.expected,
  });
}

Matcher _matches(IntervalInfo expected) => const TypeMatcher<IntervalInfo>()
    .having((actual) => actual.interval, 'interval', expected.interval)
    .having((actual) => actual.ordinal, 'ordinal', expected.ordinal)
    .having((actual) => actual.totalCount, 'totalCount', expected.totalCount);
