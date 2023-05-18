# TODO

1. Decide what to do with Riverpod - either upgrade, or get rid of.
1. Skipping to the next interval, going back to the previous one.
   1. With swiping?
1. 'Intervals' mode setup mamagement:
   1. add/edit/delete/use setup.
   1. Using just fills the current setup and allows further modifications
      (transient unless saved explicitly).
1. EMOM:
   1. Basically an interval sequence with one interval and unlimited sequence
      repetitions.
   1. With round registering and summary (for pacing info).
   1. Registering a round within a minute of the start of the interfval is a
      signal that the round was completed and the workout should continue to the
      next round the next minute.
   1. Failing to register a round within the interval completes the workout.
1. I18n.
1. Improve timer: currently a ~10x second refresh rate is used all the time, but
   it is actually only needed when fraction seconds are displayed. Start the
   timer with e.g. 2x sec and than change dynamically?
1. Navigator 2.0?
