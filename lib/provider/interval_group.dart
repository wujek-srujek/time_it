import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

@immutable
class IntervalGroup with EquatableMixin {
  final List<IntervalDefinition> intervalDefinitions;
  final int repetitions;

  IntervalGroup({
    required this.intervalDefinitions,
    this.repetitions = 1,
  })  : assert(intervalDefinitions.isNotEmpty),
        assert(repetitions >= 1);

  IntervalGroup.single(IntervalDefinition intervalDefinition)
      : this(intervalDefinitions: [intervalDefinition]);

  int get intervalCount =>
      repetitions *
      intervalDefinitions.fold(
        0,
        (accumulator, definition) => accumulator + definition.repetitions,
      );

  @override
  List<Object?> get props => [intervalDefinitions, repetitions];
}
