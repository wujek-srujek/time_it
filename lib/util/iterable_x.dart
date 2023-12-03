extension IterableX<T> on Iterable<T> {
  /// Creates an [Iterable] over elements together with their next element.
  ///
  /// The last element in this iterable has no next element so it is `null`.
  Iterable<(T, T?)> withNext() sync* {
    final firstIterator = iterator;
    final secondIterator = skip(1).iterator;

    while (firstIterator.moveNext()) {
      final first = firstIterator.current;
      final second = secondIterator.moveNext() ? secondIterator.current : null;

      yield (first, second);
    }
  }
}
