


This architecture was designed to solve a few problems:
- allow each cell to have its own track so we are not limited to 127 total CC output controls while still giving full control of pitch
- allow for a feature rich sampler. It would be ideal for Maschine to have all of these controls, but its sampler is specifically missing the stretch feature. and likely more.


## ToDo
- Kill current sound on selected instrument when pitch is changed.
- Ensure that reset / undo / redo / etc all re-send the current state to controller.


## Battery Modulator Limitation

Battery 4 does not expose sample start/end as direct MIDI-controllable
parameters. The workaround: each cell's start and end are permanently set to
the file boundaries, and modulators (with MIDI CC as the source) adjust them.
This modulator routing is baked into `Battery Instrument.nbkt` per cell and is
part of the template contract.

Consequence: modulator positions are not saved state in Battery — they only
reflect the last CC received. The app must push full parameter state for all
16 cells at session start (and on demand). A kit opened without the app will
have wrong start/end points; this is expected.