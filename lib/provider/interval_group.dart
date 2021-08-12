import 'package:meta/meta.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

@immutable
class IntervalGroup {
  final List<IntervalDefinition> intervalDefinitions;
  final int repetitions;

  const IntervalGroup({
    this.intervalDefinitions = const [],
    this.repetitions = 1,
  })  : assert(intervalDefinitions.length >= 1),
        assert(repetitions >= 1);

  IntervalGroup.single(IntervalDefinition intervalDefinition)
      : this(intervalDefinitions: [intervalDefinition]);

  int get intervalCount =>
      repetitions *
      intervalDefinitions.fold(
        0,
        (previousValue, element) => previousValue + element.repetitions,
      );
}
