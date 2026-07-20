


This architecture was designed to solve a few problems:
- allow each cell to have its own track so we are not limited to 127 total CC output controls while still giving full control of pitch
- allow for a feature rich sampler. It would be ideal for Maschine to have all of these controls, but its sampler is specifically missing the stretch feature. and likely more.


## ToDo
- Kill current sound on selected instrument when pitch is changed.
- Ensure that reset / undo / redo / etc all re-send the current state to controller.
- Make CoreMIDI pointers robust
- split out data types in to their own files
- move pure functions out of MIDI (and other classes possibly) and into testable isolated files.
- Migrate to newer model for defining and naming CC connections.
- Align MidiOutput.selectedUIDs: [Int32] to Set<MIDIUniqueID>, matching the fix we made to MidiInput — same duplicate-entry risk exists there, we just deliberately left it out of scope.
- Delete the dead half of the Data/ folder: DataProtocol.swift's _Data/WPData/EmbeddableData/DataError and Error.swift's GoogleErrorCode/FirebaseFunctionError/NSError extension. Confirmed via grep — zero call sites outside their own file, leftover from two other apps (Scorepio, RPG Music). Typeguard/ReadableData/WriteableData are genuinely load-bearing (53 call sites) and should stay. 
- A dead/commented-out-code sweep — BatteryCell.swift and MaschineInterface.swift still have sizable commented blocks (MIDI.swift's got cleaned as a side effect of the rewrite, those two didn't). 
- Swap scattered print() debugging for os.Logger.
- Reconsider ReactiveSwift usage, starting with the simplest spots (MidiInput/MidiOutput's Signal/Property pairs) as a candidate for @Published/Combine. This is explicitly not a "do it alongside other cleanup" item — bigger and riskier, deserves its own pass.
- convert all input buttons from toggle to trigger: ot trigger-safe (mute, solo, lock, select): these take the raw incoming value and assign it directly as the new persistent state:
- add two new pitch inputs: octave and note? for more granular input control.
- look at how undo / redo affects locked cells.


## Battery Modulator Limitation

Battery 4 does not expose sample start/end as direct MIDI-controllable
parameters. The workaround: each cell's start and end are permanently set to
the file boundaries, and modulators (with MIDI CC as the source) adjust them.
This modulator routing is baked into `Battery Instrument.nbkt` per cell and is
part of the template contract.

Consequence: modulator positions a
re not saved state in Battery — they only
reflect the last CC received. The app must push full parameter state for all
16 cells at session start (and on demand). A kit opened without the app will
have wrong start/end points; this is expected.


## Input Mapping

### Knob Pages

#### Page 1
**Buttons**
1. ADSR
2. 
3. 
4. 
5. 
6. 
7. Reset
8. Reset All

**Knobs**
1. Pitch
2. Volume
3. Pan
4. Speed
5. Fine Speed
6. Tune
7. Start 1
8. Start 2


#### Page 2
**Buttons**
1. 
2. 
3. 
4. 
5. 
6. 
7. 
8. 

**Knobs**
1. Filter Lo
2. Filter Hi
3. Attack
4. Hold
5. Decay
6. Sustain
7. Release
8. 



#### Page 3
**Buttons**
1. Enable Transient Shaper
2. Enable LoFi
3. 
4. 
5. 
6. 
7. 
8. 

**Knobs**
1. Trans Attack
2. Trans Sustain
3. Fine Tune
4. LoFi Bits
5. Lofi Hz
6. Lofi Noise
7. Lofi Color
8. Lofi Out


#### Page 4
**Buttons**
1. 
2. 
3. 
4. 
5. Lock
6. Lock All
7. Unlock All
8. Unsolo All

**Knobs**
1. Reverb Send
2. Delay Send
3. Velo
4. Env Order
5. Formant
6. 
7. 
8. 