import 'dart:async';

/// Fires events ('ticks') at regular, configurable intervals.
///
/// Exposes the ticks as a [stream] passing itself as the event.
///
/// It is possible to configure a [limit], and when it is reached, the ticker
/// will automatically [dispose] itself.
///
/// This code is heavily influenced by Quiver's `CountdownTimer` and adapted to
/// the needs of this app (mostly the optional [limit]).
class Ticker {
  static const _thresholdMs = 4;

  final Duration? limit;

  final StreamController<Ticker> _streamController;
  final Stopwatch _stopwatch;

  Timer? _timer;

  Ticker({this.limit})
      : _stopwatch = Stopwatch(),
        _streamController = StreamController<Ticker>(sync: true);

  /// Starts the ticker with [refreshInterval] between ticks.
  void start({required Duration refreshInterval}) {
    assert(!isDisposed);
    assert(!isRunning);

    _timer = Timer.periodic(refreshInterval, _tick);
    _stopwatch.start();
  }

  /// Stops the ticker.
  ///
  /// It adds a new event, even if the next tick isn't due yet, so that its
  /// listeners can get accurate data.
  void stop() {
    assert(!isDisposed);
    assert(isRunning);

    _timer!.cancel();
    _timer = null;
    _stopwatch.stop();
    _streamController.add(this);
  }

  /// Disposes the ticker.
  ///
  /// The ticker is no longer usable after being disposed. If it is running at
  /// the time this method is called, it is [stop]ped first. Calling this
  /// method completes the underlying stream.
  void dispose() {
    assert(!isDisposed);

    if (isRunning) {
      stop();
    }

    unawaited(_streamController.close());
  }

  Stream<Ticker> get stream => _streamController.stream;

  /// The elapsed time, i.e. total time this ticker spent in running state.
  Duration get elapsed => _stopwatch.elapsed;

  /// The remaining time until [limit], if defined, `null` otherwise.
  Duration? get remaining => limit != null ? limit! - _stopwatch.elapsed : null;

  bool get isRunning => _stopwatch.isRunning;

  bool get isDisposed => _streamController.isClosed;

  void _tick(Timer timer) {
    final remainingMs = remaining?.inMilliseconds;
    _streamController.add(this);
    if (remainingMs != null) {
      // Timers may have a 4ms resolution (web).
      if (remainingMs < _thresholdMs) {
        dispose();
      }
    }
  }
}
