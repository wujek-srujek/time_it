import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

@immutable
class IntervalGroup with EquatableMixin {
  final List<IntervalDefinition> intervalDefinitions;
  final int repetitions;

  // The constructor can be `const` but then it still cannot be called in a
  // `const` context, the compiler fails with:
  // `The property 'length' can't be accessed on ... in a constant expression.`
  // So, as the `const` constructor is useless anyway, let's disable the lint
  // here once and for all (otherwise, it would be necessary to disable lints
  // in all places that would be supposed to but could not use the `const`
  // constructor).
  // ignore: prefer_const_constructors_in_immutables
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
