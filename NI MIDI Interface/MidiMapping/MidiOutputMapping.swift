import Foundation

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
