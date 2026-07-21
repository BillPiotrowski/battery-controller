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
