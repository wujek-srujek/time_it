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

  IntervalsSequence copyWith({
    List<IntervalDefinition>? newIntervalDefinitions,
    int? newRepetitions,
  }) =>
      IntervalsSequence(
        intervalDefinitions: newIntervalDefinitions ?? intervalDefinitions,
        repetitions: newRepetitions ?? repetitions,
      );
}
