//
//  MidiCC.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/9/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

enum MidiCCValueMap {
    case pitch(pitch: Pitch)
    case volume(value: Double), pan(value: Double)
    case speed(value: Speed), fineSpeed(value: Double)
    case start1(value: Double), start2(value: Double)
    case filterHigh(value: Double), filterLow(value: Double)
    case attack(value: Double), hold(value: Double), decay(value: Double), sustain(value: Double), release(value: Double), enableAttackEnvelope(value: Bool)
    case transientAttack(value: Double), transientSustain(value: Double), enableTransientMaster(value: Bool)
    case tune(value: Double), fineTune(value: Double)
    case lofiBits(value: Double), lofiHertz(value: Double), lofiNoise(value: Double), lofiColor(value: Double), lofiOut(value: Double), enableLofi(value: Bool)
    case reverbSend(value: Double), delaySend(value: Double)
    case velocity(value: Double)
    case envOrder(value: Double), formant(value: Double)
    
    case mute(value: Bool), solo(value: Bool), unsoloAll
    case isEditingLocked(value: Bool), lockAll, unlockAll
    
    case isSelectionLocked(value: Bool)
    case copy, paste
    
    case reset, resetAll
    
    case undo, redo
    
    case loopStart(value: Double), loopStartFine(value: Double)
    case loopLength(value: Double), loopLengthFine(value: Double)
    
    init(midiCCInterface: MidiCCInterface, midiCC: MidiControllerChange) throws {
        switch midiCCInterface {
        case .pitch:
            let pitch = Pitch(value: midiCC.ratio)
            self = .pitch(pitch: pitch)
        case .volume: self = .volume(value: midiCC.ratio)
        case .pan: self = .pan(value: midiCC.ratio)
        case .speed:

            throw NSError(domain: "SPEED NEEDS TWO MIDI CCs", code: 234, userInfo: nil)
        //self = .speed(value: midiCC.ratio)
        case .fineSpeed: self = .fineSpeed(value: midiCC.ratio)
        case .start1: self = .start1(value: midiCC.ratio)
        case .start2: self = .start2(value: midiCC.ratio)
        case .filterLow: self = .filterLow(value: midiCC.ratio)
        case .filterHigh: self = .filterHigh(value: midiCC.ratio)
        case .attack: self = .attack(value: midiCC.ratio)
        case .hold: self = .hold(value: midiCC.ratio)
        case .decay: self = .decay(value: midiCC.ratio)
        case .sustain: self = .sustain(value: midiCC.ratio)
        case .release: self = .release(value: midiCC.ratio)
        case .enableAttackEnvelope:
            self = .enableAttackEnvelope(value: midiCC.bool)
        case .transientAttack: self = .transientAttack(value: midiCC.ratio)
        case .transientSustain: self = .transientSustain(value: midiCC.ratio)
        case .enableTransientMaster:
            self = .enableTransientMaster(value: midiCC.bool)
        case .tune: self = .tune(value: midiCC.ratio)
        case .fineTune: self = .fineTune(value: midiCC.ratio)
        case .lofiBits: self = .lofiBits(value: midiCC.ratio)
        case .lofiHertz: self = .lofiHertz(value: midiCC.ratio)
        case .lofiNoise: self = .lofiNoise(value: midiCC.ratio)
        case .lofiColor: self = .lofiColor(value: midiCC.ratio)
        case .lofiOut: self = .lofiOut(value: midiCC.ratio)
        case .enableLofi: self = .enableLofi(value: midiCC.bool)
        case .reverbSend: self = .reverbSend(value: midiCC.ratio)
        case .delaySend: self = .delaySend(value: midiCC.ratio)
        case .velocity: self = .velocity(value: midiCC.ratio)
        case .envOrder: self = .envOrder(value: midiCC.ratio)
        case .formant: self = .formant(value: midiCC.ratio)
        
        case .mute: self = .mute(value: midiCC.bool)
        case .solo: self = .solo(value: midiCC.bool)
        case .unsoloAll: self = .unsoloAll
        case .lock: self = .isEditingLocked(value: midiCC.bool)
        case .unlockAll: self = .unlockAll
        case .lockAll: self = .lockAll
        case .select: self = .isSelectionLocked(value: midiCC.bool)
        case .copy:
            guard midiCC.bool
                else {
                    throw NSError(domain: "Not a trigger", code: 234, userInfo: nil)
            }
            self = .copy
        case .paste:
            guard midiCC.bool
                else {
                    throw NSError(domain: "Not a trigger", code: 234, userInfo: nil)
            }
            self = .paste
        case .undo:
            guard midiCC.bool
                else {
                    throw NSError(domain: "Not a trigger", code: 234, userInfo: nil)
            }
            self = .undo
        case .redo:
            guard midiCC.bool
                else {
                    throw NSError(domain: "Not a trigger", code: 234, userInfo: nil)
            }
            self = .redo
        case .reset: self = .reset
        case .resetAll: self = .resetAll
        case .loopStart:
            self = .loopStart(value: midiCC.ratio)
        case .loopStartFine:
            self = .loopStartFine(value: midiCC.ratio)
        case .loopLength:
            self = .loopLength(value: midiCC.ratio)
        case .loopLengthFine:
            self = .loopLengthFine(value: midiCC.ratio)
        default: throw NSError(domain: "no matching midi interface", code: 234, userInfo: nil)
        }
    }
 
    var midiCCValue: MidiControlChangeValue {
        switch self {
        case .pitch(let pitch): return pitch.controllerMidiValue
        case .speed(let speed): return speed.course.MidiCCValue
        case .start1(let value), .start2(let value), .volume(let value), .filterLow(let value), .filterHigh(let value), .attack(let value), .hold(let value), .decay(let value), .sustain(let value), .release(let value), .transientAttack(let value), .transientSustain(let value), .tune(let value), .fineTune(let value), .lofiBits(let value), .lofiHertz(let value), .lofiNoise(let value), .lofiColor(let value), .lofiOut(let value), .reverbSend(let value), .delaySend(let value), .velocity(let value), .envOrder(let value), .formant(let value), .pan(let value), .fineSpeed(let value), .loopStart(let value), .loopStartFine(let value), .loopLength(let value), .loopLengthFine(let value): return value.MidiCCValue
        case .enableAttackEnvelope(let value), .enableTransientMaster(let value), .enableLofi(let value), .mute(let value), .solo(let value), .isEditingLocked(let value), .isSelectionLocked(let value): return value.MidiCCValue
        case .unsoloAll, .unlockAll, .lockAll, .copy, .paste, .reset, .resetAll, .undo, .redo: return 127
        }
        
        
    }
    
    var midiCCInterface: MidiCCInterface {
        switch self {
        case .pitch: return .pitch
        case .start1: return .start1
        case .start2: return .start2
        case .volume: return .volume
        case .filterLow: return .filterLow
        case .filterHigh: return .filterHigh
        case .attack: return .attack
        case .hold: return .hold
        case .decay: return .decay
        case .sustain: return .sustain
        case .release: return .release
        case .enableAttackEnvelope: return .enableAttackEnvelope
        case .transientAttack: return .transientAttack
        case .transientSustain: return .transientSustain
        case .enableTransientMaster: return .enableTransientMaster
        case .tune: return .tune
        case .fineTune: return .fineTune
        case .lofiBits: return .lofiBits
        case .lofiHertz: return .lofiHertz
        case .lofiNoise: return .lofiNoise
        case .lofiColor: return .lofiColor
        case .lofiOut: return .lofiOut
        case .enableLofi: return .enableLofi
        case .reverbSend: return .reverbSend
        case .delaySend: return .delaySend
        case .velocity: return .velocity
        case .envOrder: return .envOrder
        case .formant: return .formant
        case .pan: return .pan
        case .speed: return .speed
        case .fineSpeed: return .fineSpeed
        case .mute: return .mute
        case .solo: return .solo
        case .unsoloAll: return .unsoloAll
        case .isEditingLocked: return .lock
        case .lockAll: return .lockAll
        case .unlockAll: return .unlockAll
        case .isSelectionLocked: return .select
        case .copy: return .copy
        case .paste: return .paste
        case .reset: return .reset
        case .resetAll: return .resetAll
        case .undo: return .undo
        case .redo: return .redo
        case .loopStart: return .loopStart
        case .loopStartFine: return .loopStartFine
        case .loopLength: return .loopLength
        case .loopLengthFine: return .loopLengthFine
        }
    }
}

extension MidiCCValueMap: Equatable {
    static func == (lhs: MidiCCValueMap, rhs: MidiCCValueMap) -> Bool {
        switch (lhs, rhs) {
        case (let .speed(speed1), let .speed(speed2)):
            return speed1 == speed2
        default: return lhs.midiCCValue == rhs.midiCCValue
            /*
        case
            (let .start1(value1), let .start1(value2)),
            (let .start2(value1), let .start2(value2)),
            (let .volume(value1), let .volume(value2)),
            (let .filterLow(value1), let .filterLow(value2)),
            (let .filterHigh(value1), let .filterHigh(value2)),
            (let .attack(value1), let .attack(value2)),
            (let .hold(value1), let .hold(value2)),
            (let .decay(value1), let .decay(value2)),
            (let .sustain(value1), let .sustain(value2)),
            (let .release(value1), let .release(value2)),
            (let .transientAttack(value1), let .transientAttack(value2)),
            (let .transientSustain(value1), let .transientSustain(value2)),
            (let .tune(value1), let .tune(value2)),
            (let .fineTune(value1), let .fineTune(value2)),
            (let .lofiBits(value1), let .lofiBits(value2)),
            (let .lofiHertz(value1), let .lofiHertz(value2)),
            (let .lofiNoise(value1), let .lofiNoise(value2)),
            (let .lofiColor(value1), let .lofiColor(value2)),
            (let .lofiOut(value1), let .lofiOut(value2)),
            (let .reverbSend(value1), let .reverbSend(value2)),
            (let .delaySend(value1), let .delaySend(value2)),
            (let .velocity(value1), let .velocity(value2)),
            (let .envOrder(value1), let .envOrder(value2)),
            (let .formant(value1), let .formant(value2)),
            (let .pan(value1), let .pan(value2)),
            (let .speed(value1), let .speed(value2)),
            (let .fineSpeed(value1), let .fineSpeed(value2)):
            return value1 == value2
        case (.pitch(let pitch1), .pitch(let pitch2):
            return pitch1 == pitch2
            
            
            case .start1(let value), .start2(let value), .volume(let value), .filterLow(let value), .filterHigh(let value), .attack(let value), .hold(let value), .decay(let value), .sustain(let value), .release(let value), .transientAttack(let value), .transientSustain(let value), .tune(let value), .fineTune(let value), .lofiBits(let value), .lofiHertz(let value), .lofiNoise(let value), .lofiColor(let value), .lofiOut(let value), .reverbSend(let value), .delaySend(let value), .velocity(let value), .envOrder(let value), .formant(let value), .pan(let value), .speed(let value), .fineSpeed(let value): return value.MidiCCValue
        case (let .UPCA(codeA1, codeB1), let .UPCA(codeA2, codeB2)):
            return codeA1 == codeA2 && codeB1 == codeB2
            */
        }
    }
    
    
}

