//
//  SampleProperty.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

enum MidiInputMapping: Int {
    case pitch = 14
    case volume = 13
    case pan = 17
    case speed = 18
    case fineSpeed = 45
    case start1 = 11
    case start2 = 12
    case filterLow = 15
    case filterHigh = 16
    case attack = 21
    case hold = 25
    case decay = 22
    case sustain = 23
    case release = 24

    // not working??
    case enableAttackEnvelope = 52

    case transientAttack = 27
    case transientSustain = 28
    case enableTransientMaster = 53

    // Not working??
    case tune = 26

    case fineTune = 46
    case lofiBits = 31
    case lofiHertz = 32
    case lofiNoise = 33
    case lofiColor = 34
    case lofiOut = 35
    case enableLofi = 51
    case reverbSend = 36
    case delaySend = 37
    case velocity = 38

    // Not sure this is connected or what it is?
    case envOrder = 41

    case formant = 42
    case mute = 62
    case solo = 63
    case unsoloAll = 67

    // Not confident locks are working as intended.
    case lock = 64
    case lockAll = 65
    case unlockAll = 66

    case select = 68
    case copy = 43
    case paste = 44
    case reset = 61
    case resetAll = 69
    case undo = 73
    case redo = 74  
    
    // Not confident this is working.
    case loopStart = 81
    case loopStartFine = 82
    case loopLength = 83
    case loopLengthFine = 84
}

enum MidiOutputMapping: Int {
    case volume = 59
    case pan = 60
    case speed = 28
    case fineSpeed = 32
    
    case speed1 = 75
    case speed2 = 76
    case speed3 = 77
    case speed4 = 78
    
    case start1 = 21
    case start2 = 22
    case filterLow = 40
    case filterHigh = 41
    case attack = 25
    case hold = 29
    case decay = 26
    case sustain = 27
    case release = 30
    case enableAttackEnvelope = 72
    case transientAttack = 42
    case transientSustain = 43
    case enableTransientMaster = 45
    case tune = 44
    case fineTune = 46
    case lofiBits = 51
    case lofiHertz = 52
    case lofiNoise = 53
    case lofiColor = 54
    case lofiOut = 55
    case enableLofi = 71
    case reverbSend = 56
    case delaySend = 57
    case velocity = 58
    case envOrder = 61
    case formant = 62
    
    case loopStart = 81
    case loopStartFine = 82
    case loopLength = 83
    case loopLengthFine = 84
}

enum MidiCCInterface: CaseIterable {
    case pitch
    case volume, pan
    case speed, fineSpeed
    case start1, start2
    case filterHigh, filterLow
    case attack, hold, decay, sustain, release, enableAttackEnvelope
    case transientAttack, transientSustain, enableTransientMaster
    case tune, fineTune
    case lofiBits, lofiHertz, lofiNoise, lofiColor, lofiOut, enableLofi
    case reverbSend, delaySend
    case velocity
    case envOrder, formant
    case mute, solo, unsoloAll
    case lock, lockAll, unlockAll
    case select
    case copy, paste
    case reset, resetAll
    case undo, redo
    case loopStart, loopStartFine
    case loopLength, loopLengthFine
    
    init(inputNumber: MidiControlChangeNumber) throws {
        for sampleProperty in MidiCCInterface.allCases {
            guard sampleProperty.controllerMidiCCNumber == inputNumber
                else { continue }
            //print("MATCH!")
            self = sampleProperty
            return
        }
        //print("NO MATCH!")
        throw NSError(domain: "Does not match", code: 234, userInfo: nil)
    }
    
    var controllerMidiCCNumber: MidiControlChangeNumber {
        switch self {
        case .pitch: return 14
        case .volume: return 13
        case .pan: return 17
        case .speed: return 18
        case .fineSpeed: return 45
        case .start1: return 11
        case .start2: return 12
        case .filterLow: return 15
        case .filterHigh: return 16
        case .attack: return 21
        case .hold: return 25
        case .decay: return 22
        case .sustain: return 23
        case .release: return 24
        case .enableAttackEnvelope: return 52
        case .transientAttack: return 27
        case .transientSustain: return 28
        case .enableTransientMaster: return 53
        case .tune: return 26
        case .fineTune: return 46
        case .lofiBits: return 31
        case .lofiHertz: return 32
        case .lofiNoise: return 33
        case .lofiColor: return 34
        case .lofiOut: return 35
        case .enableLofi: return 51
        case .reverbSend: return 36
        case .delaySend: return 37
        case .velocity: return 38
        case .envOrder: return 41
        case .formant: return 42
        case .mute: return 62
        case .solo: return 63
        case .unsoloAll: return 67
        case .lock: return 64
        case .lockAll: return 65
        case .unlockAll: return 66
        case .select: return 68
        case .copy: return 43
        case .paste: return 44
        case .reset: return 61
        case .resetAll: return 69
        case .undo: return 73
        case .redo: return 74
        case .loopStart:
            return MidiInputMapping.loopStart.rawValue
        case .loopStartFine:
            return MidiInputMapping.loopStartFine.rawValue
        case .loopLength:
            return MidiInputMapping.loopLength.rawValue
        case .loopLengthFine:
            return MidiInputMapping.loopLengthFine.rawValue
        }
    }
    var midiCCOutputNumber: MidiControlChangeNumber? {
        // instead, make this an associative array with unique numbers. [Int: SampleProperty]
        switch self {
        case .pitch, .mute, .solo, .unsoloAll, .lock, .lockAll, .unlockAll, .select, .copy, .paste, .reset, .resetAll, .undo, .redo: return nil
        case .volume: return 59
        case .pan: return 60
        case .speed: return 28
        case .fineSpeed: return 32
        case .start1: return 21
        case .start2: return 22
        case .filterLow: return 40
        case .filterHigh: return 41
        case .attack: return 25
        case .hold: return 29
        case .decay: return 26
        case .sustain: return 27
        case .release: return 30
        case .enableAttackEnvelope: return 72
        case .transientAttack: return 42
        case .transientSustain: return 43
        case .enableTransientMaster: return 45
        case .tune: return 44
        case .fineTune: return 46
        case .lofiBits: return 51
        case .lofiHertz: return 52
        case .lofiNoise: return 53
        case .lofiColor: return 54
        case .lofiOut: return 55
        case .enableLofi: return 71
        case .reverbSend: return 56
        case .delaySend: return 57
        case .velocity: return 58
        case .envOrder: return 61
        case .formant: return 62
        
        case .loopStart:
            return MidiOutputMapping.loopStart.rawValue
        case .loopStartFine:
            return MidiOutputMapping.loopStartFine.rawValue
        case .loopLength:
            return MidiOutputMapping.loopLength.rawValue
        case .loopLengthFine:
            return MidiOutputMapping.loopLengthFine.rawValue
        }
    }
    
    var destination: Destination {
        switch self {
        case .attack, .hold, .decay, .sustain, .release, .enableAttackEnvelope:
            return .ampEnvelope
        case .pitch:
            return .sampleData
        case .start1, .start2, .volume, .pan, .speed, .fineSpeed, .filterLow, .filterHigh, .transientAttack, .transientSustain, .enableTransientMaster, .tune, .fineTune, .reverbSend, .delaySend, .velocity, .envOrder, .formant, .reset, .loopStart, .loopStartFine, .loopLength, .loopLengthFine:
            return .sampleCellProperty
        case .lofiBits, .lofiHertz, .lofiNoise, .lofiColor, .lofiOut, .enableLofi:
            return .loFi
        case .mute, .solo, .lock:
            return .sampleCellState
        case .unsoloAll, .lockAll, .unlockAll, .select, .copy, .paste, .resetAll, .undo, .redo:
            return .master
        }
    }
    
    
    enum Destination {
        case sampleCellProperty, sampleCellState, master, ampEnvelope, loFi, sampleData
    }
    
    /*
    static let midiCCOutputNumberDictionary: [Int: MidiCCInterface] = [
        59: .volume,
        60: .pan,
        28: .speed,
        32: .fineSpeed,
        21: .start1,
        22: .start2,
        40: .filterLow,
        41: .filterHigh,
        25: .attack,
        29: .hold,
        26: .decay,
        27: .sustain,
        30: .release,
        72: .enableAttackEnvelope,
        42: .transientAttack,
        43: .transientSustain,
        45: .enableTransientMaster,
        44: .tune,
        46: .fineTune,
        51: .lofiBits,
        52: .lofiHertz,
        53: .lofiNoise,
        54: .lofiColor,
        55: .lofiOut,
        71: .enableLofi,
        56: .reverbSend,
        57: .delaySend,
        58: .velocity,
        61: .envOrder,
        62: .formant,
    ]
 */
}
/*
enum SamplerMidiCC: Int {
    case volume = 59
    case pan = 60
    case speed = 28
    case fineSpeed = 32
    case start1 = 21
    case start2 = 22
    case filterLow = 40
    case filterHigh = 41
    case attack = 25
    case hold = 29
    case decay = 26
    case sustain = 27
    case release = 30
    case enableAttackEnvelope = 72
    case transientAttack = 42
    case transientSustain = 43
    case enableTransientMaster = 45
    case tune = 44
    case fineTune = 46
    case lofiBits = 51
    case lofiHertz = 52
    case lofiNoise = 53
    case lofiColor = 54
    case lofiOut = 55
    case enableLofi = 71
    case reverbSend = 56
    case delaySend = 57
    case velocity = 58
    case envOrder = 61
    case formant = 62
}
*/
