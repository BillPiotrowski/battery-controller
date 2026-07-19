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
    case speed(value: Double), fineSpeed(value: Double)
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
    case lock(value: Bool), lockAll, unlockAll
    
    
    init(midiCCInterface: MidiCCInterface, midiCC: MidiControllerChange) throws {
        switch midiCCInterface {
        case .pitch:
            let pitch = Pitch(value: midiCC.ratio)
            self = .pitch(pitch: pitch)
        case .volume: self = .volume(value: midiCC.ratio)
        case .pan: self = .pan(value: midiCC.ratio)
        case .speed: self = .speed(value: midiCC.ratio)
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
        case .lock: self = .lock(value: midiCC.bool)
        case .unlockAll: self = .unlockAll
        case .lockAll: self = .lockAll
        default: throw NSError(domain: "no matching midi interface", code: 234, userInfo: nil)
        }
    }
 
    var midiCCValue: MidiControlChangeValue {
        switch self {
        case .pitch(let pitch): return pitch.noteNumber
        case .start1(let value), .start2(let value), .volume(let value), .filterLow(let value), .filterHigh(let value), .attack(let value), .hold(let value), .decay(let value), .sustain(let value), .release(let value), .transientAttack(let value), .transientSustain(let value), .tune(let value), .fineTune(let value), .lofiBits(let value), .lofiHertz(let value), .lofiNoise(let value), .lofiColor(let value), .lofiOut(let value), .reverbSend(let value), .delaySend(let value), .velocity(let value), .envOrder(let value), .formant(let value), .pan(let value), .speed(let value), .fineSpeed(let value): return value.MidiCCValue
        case .enableAttackEnvelope(let value), .enableTransientMaster(let value), .enableLofi(let value), .mute(let value), .solo(let value), .lock(let value): return value.MidiCCValue
        case .unsoloAll, .unlockAll, .lockAll: return 127
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
        case .lock: return .lock
        case .lockAll: return .lockAll
        case .unlockAll: return .unlockAll
        }
    }
}

