import 'package:test/test.dart';
import 'package:time_it/util/iterable_x.dart';

void main() {
  group('withNext', () {
    <List<int>, List<Pair<int, int?>>>{
      []: [],
      [0]: [
        Pair(0, null),
      ],
      [0, 1, 2, 3]: [
        Pair(0, 1),
        Pair(1, 2),
        Pair(2, 3),
        Pair(3, null),
      ],
    }.forEach((input, expected) {
      test('works for $input', () {
        expect(
          input.withNext(),
          expected,
        );
      });
    });
  });

  group('enumerate', () {
    <List<String>, List<Pair<int, String>>>{
      []: [],
      ['a']: [
        Pair(0, 'a'),
      ],
      ['a', 'b', 'c', 'd']: [
        Pair(0, 'a'),
        Pair(1, 'b'),
        Pair(2, 'c'),
        Pair(3, 'd'),
      ],
    }.forEach((input, expected) {
      test('works for $input', () {
        expect(
          input.enumerate(),
          expected,
        );
      });
    });
  });
}
