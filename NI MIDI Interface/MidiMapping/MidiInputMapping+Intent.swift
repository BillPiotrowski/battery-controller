import Foundation

// MARK: DECODE
extension MidiInputMapping {

    static func intent(
        from midiCC: MidiControllerChange,
        cellIndex: Int
    ) throws -> Intent {
        guard let mapping = MidiInputMapping(rawValue: midiCC.ccNumber) else {
            throw DecodeError.unmappedCC(midiCC.ccNumber)
        }

        switch mapping {

        // MARK: Kit-wide
        case .unsoloAll: try requireOn(mapping, midiCC); return .unsoloAll
        case .unlockAll: try requireOn(mapping, midiCC); return .unlockAll
        case .lockAll:   try requireOn(mapping, midiCC); return .lockAll
        case .undo:      try requireOn(mapping, midiCC); return .undo
        case .redo:      try requireOn(mapping, midiCC); return .redo
        case .resetAll:  try requireOn(mapping, midiCC); return .resetAll
        case .copy:      try requireOn(mapping, midiCC); return .copy(fromCellIndex: cellIndex)
        case .paste:     try requireOn(mapping, midiCC); return .paste(toCellIndex: cellIndex)
        case .reset:     try requireOn(mapping, midiCC); return .reset(cellIndex: cellIndex)

        // MARK: Selection / performance state
        case .select: return .select(cellIndex: cellIndex, midiCC.bool)
        case .mute:   return .mute(cellIndex: cellIndex, isMuted: midiCC.bool)
        case .solo:   return .solo(cellIndex: cellIndex, isSoloed: midiCC.bool)
        case .lock:   return .lock(cellIndex: cellIndex, isLocked: midiCC.bool)

        // MARK: Ignored
        case .tune: throw DecodeError.ignored(mapping)

        // MARK: Cell parameters
        case .pitch, .volume, .pan, .speed, .fineSpeed, .start1, .start2,
             .filterLow, .filterHigh, .attack, .hold, .decay, .sustain,
             .release, .enableAttackEnvelope, .transientAttack, .transientSustain,
             .enableTransientMaster, .fineTune, .lofiBits, .lofiHertz, .lofiNoise,
             .lofiColor, .lofiOut, .enableLofi, .reverbSend, .delaySend, .velocity,
             .envOrder, .formant, .loopStart, .loopStartFine, .loopLength,
             .loopLengthFine:
            guard let parameter = MidiInputMapping.parameter(mapping: mapping, midiCC: midiCC) else {
                throw DecodeError.ignored(mapping)
            }
            return .updateCellParameter(cellIndex: cellIndex, parameter: parameter)
        }
    }

    private static func requireOn(
        _ mapping: MidiInputMapping,
        _ midiCC: MidiControllerChange
    ) throws {
        guard midiCC.bool else {
            throw DecodeError.unexpectedMomentaryValue(mapping, midiCC.value)
        }
    }
}

// MARK: PARAMETER
extension MidiInputMapping {

    static func parameter(mapping: MidiInputMapping, midiCC: MidiControllerChange) -> Cell.Parameter? {
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

// MARK: ERROR
extension MidiInputMapping {
    enum DecodeError: ScorepioError {
        case unmappedCC(MidiControlChangeNumber)
        case ignored(MidiInputMapping)
        case unexpectedMomentaryValue(MidiInputMapping, MidiControlChangeValue)

        var message: String {
            switch self {
            case .unmappedCC(let ccNumber):
                return "No input mapping for CC \(ccNumber)."
            case .ignored(let mapping):
                return "Input \(mapping) is intentionally ignored."
            case .unexpectedMomentaryValue(let mapping, let value):
                return "Momentary input \(mapping) expected 127, received \(value)."
            }
        }
    }
}
