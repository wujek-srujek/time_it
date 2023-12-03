import 'package:test/test.dart';
import 'package:time_it/util/iterable_x.dart';

void main() {
  group('withNext', () {
    <List<int>, List<(int, int?)>>{
      []: [],
      [0]: [
        (0, null),
      ],
      [0, 1, 2, 3]: [
        (0, 1),
        (1, 2),
        (2, 3),
        (3, null),
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
}
