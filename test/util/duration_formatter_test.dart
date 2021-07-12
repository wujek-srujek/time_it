// Ignoring redundant arguments as we want to be explicit in the test.
// ignore_for_file: avoid_redundant_argument_values

import 'package:test/test.dart';
import 'package:time_it/util/duration_formatter.dart';

void main() {
  group('forcing and padding', () {
    {
      const duration = Duration(hours: 11);

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0:0',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '11:00:00',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0:0',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '11:00:00',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '11:00:00',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0:0',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '11:00:00',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '11:0:00',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0:0',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '11:0:00',
          );
        });
      });
    }

    {
      const duration = Duration(hours: 1);

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0:0',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '01:00:00',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0:0',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '01:00:00',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '1:00:00',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0:0',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '1:00:00',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '1:0:00',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0:0',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '1:0:00',
          );
        });
      });
    }

    {
      const duration = Duration(minutes: 11);

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '11:00',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:11:0',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '00:11:00',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '11:00',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '11:00',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '11:00',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11:0',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '11:00',
          );
        });
      });
    }

    {
      const duration = Duration(minutes: 1);

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '01:00',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:1:0',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '00:01:00',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '01:00',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '01:00',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '1:00',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1:0',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '1:00',
          );
        });
      });
    }

    {
      const duration = Duration(seconds: 11);

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '11',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:0:11',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '00:00:11',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '11',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:11',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '00:11',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '11',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '11',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '11',
          );
        });
      });
    }

    {
      const duration = Duration(seconds: 1);

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '01',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:0:1',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '00:00:01',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '01',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:1',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '00:01',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '01',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '1',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '01',
          );
        });
      });
    }

    {
      const duration = Duration.zero;

      group("'$duration' is formatted correctly", () {
        test('not forcing, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '',
          );
        });

        test('not forcing, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '',
          );
        });

        test('forcing h, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:0:0',
          );
        });

        test('forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 0,
            ),
            '00:00:00',
          );
        });

        test('not forcing, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '',
          );
        });

        test('forcing m, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0:0',
          );
        });

        test('forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 0,
            ),
            '00:00',
          );
        });

        test('not forcing, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '',
          );
        });

        test('forcing s, not forcing padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 0,
            ),
            '0',
          );
        });

        test('forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 0,
            ),
            '00',
          );
        });
      });
    }
  });

  group('fractions', () {
    {
      const duration = Duration(seconds: 1, milliseconds: 666);

      group("'$duration' is formatted correctly", () {
        test('3 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 3,
            ),
            '1.666',
          );
        });

        test('2 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 2,
            ),
            '1.66',
          );
        });

        test('1 decimal place, forcing h, forcing h padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.hour,
              forceComponentPadding: TimeComponent.hour,
              decimalPlaces: 1,
            ),
            '00:00:01.6',
          );
        });
      });
    }

    {
      const duration = Duration(seconds: 1, milliseconds: 66);

      group("'$duration' is formatted correctly", () {
        test('3 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 3,
            ),
            '1.066',
          );
        });

        test('2 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 2,
            ),
            '1.06',
          );
        });

        test('1 decimal place, forcing m, forcing m padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.minute,
              forceComponentPadding: TimeComponent.minute,
              decimalPlaces: 1,
            ),
            '00:01.0',
          );
        });
      });
    }

    {
      const duration = Duration(seconds: 1, milliseconds: 6);

      group("'$duration' is formatted correctly", () {
        test('3 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 3,
            ),
            '1.006',
          );
        });

        test('2 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 2,
            ),
            '1.00',
          );
        });

        test('1 decimal place, forcing s, forcing s padding', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.second,
              forceComponentPadding: TimeComponent.second,
              decimalPlaces: 1,
            ),
            '01.0',
          );
        });
      });
    }

    {
      const duration = Duration(milliseconds: 1);

      group("'$duration' is formatted correctly", () {
        test('3 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 3,
            ),
            '001',
          );
        });

        test('2 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 2,
            ),
            '00',
          );
        });

        test('1 decimal place', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 1,
            ),
            '0',
          );
        });
      });
    }

    {
      const duration = Duration.zero;

      group("'$duration' is formatted correctly", () {
        test('3 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 3,
            ),
            '000',
          );
        });

        test('2 decimal places', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 2,
            ),
            '00',
          );
        });

        test('1 decimal place', () {
          expect(
            formatDuration(
              duration,
              forceComponent: TimeComponent.none,
              forceComponentPadding: TimeComponent.none,
              decimalPlaces: 1,
            ),
            '0',
          );
        });
      });
    }
  });
}
