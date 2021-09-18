import 'package:equatable/equatable.dart';

class Pair<U, V> with EquatableMixin {
  final U first;
  final V second;

  Pair(this.first, this.second);

  @override
  List<Object?> get props => [first, second];
}

extension IterableX<T> on Iterable<T> {
  /// Creates an [Iterable] over elements together with their next element.
  ///
  /// The last element in this iterable has no next element so it is `null`.
  Iterable<Pair<T, T?>> withNext() sync* {
    final firstIterator = iterator;
    final secondIterator = skip(1).iterator;

    while (firstIterator.moveNext()) {
      final first = firstIterator.current;
      final second = secondIterator.moveNext() ? secondIterator.current : null;

      yield Pair(first, second);
    }
  }

  /// Creates an [Iterable] over elements with their index.
  Iterable<Pair<int, T>> enumerate() sync* {
    var index = 0;
    for (final value in this) {
      yield Pair(index, value);

      ++index;
    }
  }
}
