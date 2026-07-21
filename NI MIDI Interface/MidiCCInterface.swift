//
//  SampleProperty.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

enum MidiInputMapping: Int, CaseIterable {
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
