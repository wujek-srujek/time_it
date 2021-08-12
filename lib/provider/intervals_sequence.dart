import 'package:meta/meta.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

@immutable
class IntervalsSequence {
  final List<IntervalDefinition> intervalDefinitions;
  final int repetitions;

  const IntervalsSequence({
    this.intervalDefinitions = const [],
    this.repetitions = 1,
  }) : assert(repetitions > 0);

  IntervalsSequence.single(IntervalDefinition intervalDefinition)
      : this(intervalDefinitions: [intervalDefinition]);

  IntervalsSequence copyWith({
    List<IntervalDefinition>? newIntervalDefinitions,
    int? newRepetitions,
  }) =>
      IntervalsSequence(
        intervalDefinitions: newIntervalDefinitions ?? intervalDefinitions,
        repetitions: newRepetitions ?? repetitions,
      );

  int get intervalsCount =>
      repetitions *
      intervalDefinitions.fold(
        0,
        (previousValue, element) => previousValue + element.repetitions,
      );
}
