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
        case .unsoloAll: return .unsoloAll
        case .unlockAll: return .unlockAll
        case .lockAll: return .lockAll
        case .undo: return .undo
        case .redo: return .redo
        case .resetAll: return .resetAll
        case .copy: return .copy(fromCellIndex: cellIndex)
        case .paste: return .paste(toCellIndex: cellIndex)
        case .reset: return .reset(cellIndex: cellIndex)

        // consider adding cell index?
        case .toggleSelect: return .pinSelection
        case .toggleMute: return .mute(cellIndex: cellIndex)
        case .toggleSolo: return .solo(cellIndex: cellIndex)
        case .toggleLock: return .lock(cellIndex: cellIndex)

        case .toggleTransientMaster: return .toggleTransientMaster(cellIndex: cellIndex)
        case .toggleLofi:  return .toggleLofi(cellIndex: cellIndex)
        case .toggleAmpEnvelope: return .toggleAmpEnvelope(cellIndex: cellIndex)

        // Ignored
        case .tune: throw DecodeError.ignored(mapping)

        case .pitch, .volume, .pan, .speed, .fineSpeed, .start1, .start2,
             .filterLow, .filterHigh, .attack, .hold, .decay, .sustain,
             .release, .transientAttack, .transientSustain,
             .fineTune, .lofiBits, .lofiHertz, .lofiNoise,
             .lofiColor, .lofiOut, .reverbSend, .delaySend, .velocity,
             .envOrder, .formant, .loopStart, .loopStartFine, .loopLength,
             .loopLengthFine:
            guard let parameter = MidiInputMapping.parameter(mapping: mapping, midiCC: midiCC) else {
                throw DecodeError.ignored(mapping)
            }
            return .updateCellParameter(cellIndex: cellIndex, parameter: parameter)
        }
    }
}

// MARK: PARAMETER
extension MidiInputMapping {

    static func parameter(mapping: MidiInputMapping, midiCC: MidiControllerChange) -> Cell.Parameter? {
        switch mapping {

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

        case .attack: return .attack(midiCC.ratio)
        case .hold: return .hold(midiCC.ratio)
        case .decay: return .decay(midiCC.ratio)
        case .sustain: return .sustain(midiCC.ratio)
        case .release: return .release(midiCC.ratio)

        case .lofiBits: return .lofiBits(midiCC.ratio)
        case .lofiHertz: return .lofiHertz(midiCC.ratio)
        case .lofiNoise: return .lofiNoise(midiCC.ratio)
        case .lofiColor: return .lofiColor(midiCC.ratio)
        case .lofiOut: return .lofiOut(midiCC.ratio)

        case .pitch: return .pitch(Pitch(value: midiCC.ratio))

        // Coarse tune is intentionally ignored - only fine tune is allowed.
        case .tune: return nil

        // Performance state. Not undoable, not copied, applied directly.
        case .toggleMute, .toggleSolo, .toggleLock: return nil

        // Toggle state is owned internally and not by the controller.
        case .toggleTransientMaster, .toggleLofi, .toggleAmpEnvelope: return nil

        // Master / kit-level actions, handled by the caller.
        case .unsoloAll,
             .lockAll,
             .unlockAll,
             .toggleSelect,
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

        var message: String {
            switch self {
            case .unmappedCC(let ccNumber):
                return "No input mapping for CC \(ccNumber)."
            case .ignored(let mapping):
                return "Input \(mapping) is intentionally ignored."
            }
        }
    }
}
