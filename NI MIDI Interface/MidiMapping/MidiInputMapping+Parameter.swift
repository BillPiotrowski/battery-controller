import Foundation

// MARK: DECODE
extension MidiInputMapping {

    /// Decodes an incoming CC in to a cell parameter.
    ///
    /// Returns `nil` for anything that is not a cell parameter – master actions,
    /// performance state, and deliberately ignored CCs.
    ///
    /// TODO: When we build the kit, we may want to consider a parent to BatteryCell.Parameter – something like Kit Parameter and return that.
    static func parameter(mapping: MidiInputMapping, midiCC: MidiControllerChange) -> BatteryCell.Parameter? {
        switch mapping {

        // MARK: Property
        case .start1: return .start1(midiCC.ratio)
        case .start2: return .start2(midiCC.ratio)
        case .volume: return .volume(midiCC.ratio)
        case .pan: return .pan(midiCC.ratio)
        case .speed: return .speedCoarse(midiCC.ratio)
        case .fineSpeed: return .speedFine(midiCC.ratio)
        case .filterLow: return .filterLow(midiCC.ratio)
        case .filterHigh: return .filterHigh(midiCC.ratio)
        case .transientAttack: return .transientAttack(midiCC.ratio)
        case .transientSustain: return .transientSustain(midiCC.ratio)
        case .enableTransientMaster: return .enableTransientMaster(midiCC.bool)
        case .fineTune: return .fineTune(midiCC.ratio)
        case .reverbSend: return .reverbSend(midiCC.ratio)
        case .delaySend: return .delaySend(midiCC.ratio)
        case .velocity: return .velocity(midiCC.ratio)
        case .envOrder: return .envOrder(midiCC.ratio)
        case .formant: return .formant(midiCC.ratio)
        case .loopStart: return .loopStart(midiCC.ratio)
        case .loopStartFine: return .loopStartFine(midiCC.ratio)
        case .loopLength: return .loopLength(midiCC.ratio)
        case .loopLengthFine: return .loopLengthFine(midiCC.ratio)

        // MARK: Amp Envelope
        case .attack: return .attack(midiCC.ratio)
        case .hold: return .hold(midiCC.ratio)
        case .decay: return .decay(midiCC.ratio)
        case .sustain: return .sustain(midiCC.ratio)
        case .release: return .release(midiCC.ratio)
        case .enableAttackEnvelope: return .enableAmpEnvelope(midiCC.bool)

        // MARK: Lo-Fi
        case .lofiBits: return .lofiBits(midiCC.ratio)
        case .lofiHertz: return .lofiHertz(midiCC.ratio)
        case .lofiNoise: return .lofiNoise(midiCC.ratio)
        case .lofiColor: return .lofiColor(midiCC.ratio)
        case .lofiOut: return .lofiOut(midiCC.ratio)
        case .enableLofi: return .enableLofi(midiCC.bool)

        // MARK: Sample
        case .pitch: return .pitch(Pitch(value: midiCC.ratio))

        // MARK: Not a cell parameter

        // Coarse tune is intentionally ignored - only fine tune is allowed.
        case .tune: return nil

        // Performance state. Not undoable, not copied, applied directly.
        case .mute, .solo, .lock: return nil

        // Master / kit-level actions, handled by the caller.
        case .unsoloAll,
             .lockAll,
             .unlockAll,
             .select,
             .copy,
             .paste,
             .reset,
             .resetAll,
             .undo,
             .redo:
            return nil
        }
    }
}
