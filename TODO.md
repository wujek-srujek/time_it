# TODO

1. More modes (current: AMRAP for rounds):
   1. Stopwatch:
      1. Basically AMRAP, but with time counted up instead of down.
      1. With round registering and summary.
   1. Intervals:
      1. Multiple intervals (reorderable list) of different duration possible.
      1. Possible to define how many times to repeat the interval sequence.
      1. No round registering like in AMRAP.
      1. No summary (as no round registering).
   1. EMOM (we don't really do this one):
      1. Basically a single interval with no predefined round count.
      1. With round registering (to allow pacing optimizations).
1. Support landscape mode properly.
1. Version info.
1. I18n.
1. Mode config peristence.
   1. Mmaybe even workout mamagement?
   1. Possible to add/edit/delete/use 'workouts'.
   1. Separate for each  mode.
1. Improve timer: currently a ~10x second refresh rate is used all the time, but
   it is actually only needed when fraction seconds are displayed. Start the
   timer with e.g. 2x sec and than change dynamically?
1. Navigator 2.0?
