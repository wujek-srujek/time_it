import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:time_it/provider/interval_group.dart';
import 'package:time_it/provider/intervals_setup.dart';

void main() {
  group('IntervalsSetup', () {
    for (final (index, stateCreator) in [
      () => IntervalsSetup(
            const [],
            hasIntervals: true,
          ),
      () => IntervalsSetup(
            const [
              GroupedIntervalsSetupItem(
                IntervalDefinitionItem(
                  IntervalDefinition(seconds: 1),
                ),
                group: 0,
                isFirst: true,
                isLast: true,
              ),
            ],
            hasIntervals: false,
          ),
      () => IntervalsSetup(
            const [
              GroupedIntervalsSetupItem(
                IntervalGroupItem(),
                group: 0,
                isFirst: true,
                isLast: true,
              ),
              GroupedIntervalsSetupItem(
                IntervalGroupItem(),
                group: 1,
                isFirst: true,
                isLast: true,
              ),
              GroupedIntervalsSetupItem(
                IntervalDefinitionItem(
                  IntervalDefinition(seconds: 1),
                ),
                group: 1,
                isFirst: false,
                isLast: true,
              ),
            ],
            hasIntervals: false,
          ),
    ].indexed) {
      test("$index. creation fails for inconsistent 'hasIntervals'", () {
        expect(
          stateCreator,
          throwsA(isA<AssertionError>()),
        );
      });
    }

    for (final (index, config) in [
      _SetupTestConfig(
        input: [
          _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
        ],
        expected: [
          IntervalGroup(
            intervalDefinitions: const [
              IntervalDefinition(seconds: 1),
            ],
          ),
        ],
      ),
      _SetupTestConfig(
        input: [
          _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
          _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
        ],
        expected: [
          IntervalGroup(
            intervalDefinitions: const [
              IntervalDefinition(seconds: 1),
              IntervalDefinition(seconds: 2),
            ],
          ),
        ],
      ),
      _SetupTestConfig(
        input: [
          _groupedGroupItem(group: 0, isFirst: true, isLast: false),
          _groupedIntervalItem(1, group: 0, isFirst: false, isLast: false),
          _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
        ],
        expected: [
          IntervalGroup(
            intervalDefinitions: const [
              IntervalDefinition(seconds: 1),
              IntervalDefinition(seconds: 2),
            ],
          ),
        ],
      ),
      _SetupTestConfig(
        input: [
          _groupedGroupItem(group: 0, isFirst: true, isLast: false),
          _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
          _groupedGroupItem(group: 1, isFirst: true, isLast: false),
          _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
        ],
        expected: [
          IntervalGroup(
            intervalDefinitions: const [
              IntervalDefinition(seconds: 1),
            ],
          ),
          IntervalGroup(
            intervalDefinitions: const [
              IntervalDefinition(seconds: 2),
            ],
          ),
        ],
      ),
      _SetupTestConfig(
        input: [
          _groupedGroupItem(group: 0, isFirst: true, isLast: false),
          _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
          _groupedGroupItem(group: 1, isFirst: true, isLast: false),
        ],
        expected: [
          IntervalGroup(
            intervalDefinitions: const [
              IntervalDefinition(seconds: 1),
            ],
          ),
        ],
      ),
    ].indexed) {
      test('$index. extracting interval groups works', () {
        expect(
          IntervalsSetup(
            config.input,
            hasIntervals: true,
          ).toIntervalGroups(),
          config.expected,
        );
      });
    }
  });

  group('IntervalsSetupNotifier', () {
    group('adding', () {
      <String, _NotifierTestConfig>{
        'an interval with no previous items': _NotifierTestConfig(
          seed: const [],
          operations: (notifier) => notifier.add(_intervalItem(1)),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
        ),
        'a group with no previous items': _NotifierTestConfig(
          seed: const [],
          operations: (notifier) => notifier.add(_groupItem()),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
        ),
        'an interval with a previous interval': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.add(_intervalItem(2)),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
          ],
        ),
        'a group with a previous interval': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.add(_groupItem()),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
        ),
        'an interval with a previous group': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.add(_intervalItem(1)),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
          ],
        ),
        'a group with a previous group': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.add(_groupItem()),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
        ),
        'an interval with multiple previous groups': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            _groupedGroupItem(group: 2, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.add(_intervalItem(1)),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            _groupedGroupItem(group: 2, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 2, isFirst: false, isLast: true),
          ],
        ),
      }.forEach((title, config) {
        test('$title works', _itemsModificationTest(config));
      });
    });

    group('removing', () {
      <String, _NotifierTestConfig>{
        'a sole interval': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(0),
          expected: const [],
        ),
        'a sole group': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(0),
          expected: const [],
        ),
        'the first of two intervals': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
          ],
          operations: (notifier) => notifier.remove(0),
          expected: [
            _groupedIntervalItem(2, group: 0, isFirst: true, isLast: true),
          ],
        ),
        'the second of two intervals': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
          ],
          operations: (notifier) => notifier.remove(1),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
        ),
        'the first of two groups': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(0),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
        ),
        'the second of two groups': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(1),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
        ),
        'an interval before a group': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(0),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
        ),
        'an interval after a group': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
          ],
          operations: (notifier) => notifier.remove(1),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
          ],
        ),
        'a group before an interval': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
          ],
          operations: (notifier) => notifier.remove(0),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
        ),
        'a group after an interval': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(1),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
          ],
        ),
        'an interval between groups': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
          operations: (notifier) => notifier.remove(1),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
          ],
        ),
        'a group between intervals': _NotifierTestConfig(
          seed: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: false),
            _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
          ],
          operations: (notifier) => notifier.remove(1),
          expected: [
            _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
            _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
          ],
        ),
        'one of multiple groups before an interval': _NotifierTestConfig(
          seed: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            _groupedGroupItem(group: 2, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 2, isFirst: false, isLast: true),
          ],
          operations: (notifier) => notifier.remove(2),
          expected: [
            _groupedGroupItem(group: 0, isFirst: true, isLast: true),
            _groupedGroupItem(group: 1, isFirst: true, isLast: false),
            _groupedIntervalItem(1, group: 1, isFirst: false, isLast: true),
          ],
        ),
      }.forEach((title, config) {
        test('$title works', _itemsModificationTest(config));
      });
    });

    group('moving', () {
      <String, int>{
        'before': 0,
        'after': 1,
      }.forEach((where, newIndex) {
        test('right $where itself is a no-op', () {
          final notifier = IntervalsSetupNotifier.seeded(
            IntervalsSetup(
              [
                _groupedGroupItem(group: 0, isFirst: true, isLast: true),
                _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              ],
              hasIntervals: false,
            ),
          );

          expect(
            notifier.stream,
            emitsDone,
          );

          notifier
            ..move(oldIndex: 0, newIndex: newIndex)
            ..dispose();
        });
      });

      group('down', () {
        <String, _NotifierTestConfig>{
          // 1
          'interval 1 from before to after interval 2': _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 0, newIndex: 2),
            expected: [
              _groupedIntervalItem(2, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            ],
          ),
          // 2
          'group 0 from before to after interval 1': _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 0, newIndex: 2),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
          ),
          // 3
          'interval 1 from before to after group 1': _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 0, newIndex: 2),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            ],
          ),
          // 4
          'group 0 from before to after group 1': _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 0, newIndex: 2),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
          ),
          // 5
          'group 1 from before to between intervals 1 and 2':
              _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 1, isFirst: false, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 3),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
          ),
          // 6
          'interval 1 from between groups 0 and 1 to after group 1':
              _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 3),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 1, isFirst: false, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
          ),
          // 7
          'interval 1 from before interval 2 to between groups 1 and 2':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 0, newIndex: 3),
            expected: [
              _groupedIntervalItem(2, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 1, isFirst: false, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
          ),
          // 8
          'interval 2 from before group 1 to between groups 1 and 2':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 3),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
          ),
          // 9
          'interval 1 from before interval 2 to after group 2':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 0, newIndex: 4),
            expected: [
              _groupedIntervalItem(2, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 2, isFirst: false, isLast: true),
            ],
          ),
          // 10
          'interval 2 from before group 1 to after groups 1 and 2':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 4),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 2, isFirst: false, isLast: true),
            ],
          ),
        }.forEach((title, config) {
          test('$title works', _itemsModificationTest(config));
        });
      });

      group('up', () {
        // These scenarios are the 'down' scenarios above in reverse.
        <String, _NotifierTestConfig>{
          // 1
          'interval 1 from after to before interval 2': _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(2, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 0),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
            ],
          ),
          // 2
          'group 0 from after to before interval 1': _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 0),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            ],
          ),
          // 3
          'interval 1 from after to before group 1': _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 0),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
          ),
          // 4
          'group 1 from after to before group 0': _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 1, newIndex: 0),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
            ],
          ),
          // 5
          'group 1 from between to before intervals 1 and 2':
              _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 2, newIndex: 1),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 1, isFirst: false, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
          ),
          // 6
          'interval 1 from after group 1 to between groups 0 and 1':
              _NotifierTestConfig(
            seed: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 1, isFirst: false, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 2, newIndex: 1),
            expected: [
              _groupedGroupItem(group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
            ],
          ),
          // 7
          'interval 1 from between groups 1 and 2 to before interval 2':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(2, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 1, isFirst: false, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 2, newIndex: 0),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
          ),
          // 8
          'interval 2 from between groups 1 and 2 to before group 1':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 1, isFirst: false, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 2, newIndex: 1),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
          ),
          // 9
          'interval 1 from after group 2 to before interval 2':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(2, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: false),
              _groupedIntervalItem(1, group: 2, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 3, newIndex: 0),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
          ),
          // 10
          'interval 2 from after groups 1 and 2 to before group 1':
              _NotifierTestConfig(
            seed: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 2, isFirst: false, isLast: true),
            ],
            operations: (notifier) => notifier.move(oldIndex: 3, newIndex: 1),
            expected: [
              _groupedIntervalItem(1, group: 0, isFirst: true, isLast: false),
              _groupedIntervalItem(2, group: 0, isFirst: false, isLast: true),
              _groupedGroupItem(group: 1, isFirst: true, isLast: true),
              _groupedGroupItem(group: 2, isFirst: true, isLast: true),
            ],
          ),
        }.forEach((title, config) {
          test('$title works', _itemsModificationTest(config));
        });
      });
    });
  });
}

// Helpers.

@immutable
class _SetupTestConfig {
  final List<GroupedIntervalsSetupItem> input;
  final List<IntervalGroup> expected;

  const _SetupTestConfig({
    required this.input,
    required this.expected,
  });
}

@immutable
class _NotifierTestConfig {
  final List<GroupedIntervalsSetupItem> seed;
  final void Function(IntervalsSetupNotifier) operations;
  final List<GroupedIntervalsSetupItem> expected;

  const _NotifierTestConfig({
    required this.seed,
    required this.operations,
    required this.expected,
  });
}

// Tests 'groupedItems' only, doesn't consider the whole state, there are other
// tests for that. 'hasIntervals' is asserted in the constructor so its validity
// is tested implicitly - if it's wrong, tests will fail.
void Function() _itemsModificationTest(_NotifierTestConfig config) {
  return () {
    final notifier = IntervalsSetupNotifier.seeded(
      IntervalsSetup(
        config.seed,
        hasIntervals: config.seed.any(
          (groupedItem) => groupedItem.item is IntervalDefinitionItem,
        ),
      ),
    );
    addTearDown(notifier.dispose);

    expect(
      notifier.stream.map((event) => event.groupedItems),
      emitsInOrder(<Matcher>[
        equals(config.expected),
      ]),
    );

    config.operations(notifier);
  };
}

// Helpers to avoid the verbosity of creating all the items.

IntervalDefinitionItem _intervalItem(int seconds) =>
    IntervalDefinitionItem(IntervalDefinition(seconds: seconds));

GroupedIntervalsSetupItem _groupedIntervalItem(
  int seconds, {
  required int group,
  required bool isFirst,
  required bool isLast,
}) =>
    GroupedIntervalsSetupItem(
      _intervalItem(seconds),
      group: group,
      isFirst: isFirst,
      isLast: isLast,
    );

IntervalGroupItem _groupItem() => const IntervalGroupItem();

GroupedIntervalsSetupItem _groupedGroupItem({
  required int group,
  required bool isFirst,
  required bool isLast,
}) =>
    GroupedIntervalsSetupItem(
      _groupItem(),
      group: group,
      isFirst: isFirst,
      isLast: isLast,
    );
