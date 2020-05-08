//
//  BatteryCell.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct Pitch {
    let noteNumber: CustomMIDINoteNumber
    
    
    init(noteNumber: CustomMIDINoteNumber){
        self.noteNumber = noteNumber
    }
    init(value: Double){
        self.init(noteNumber: Pitch.noteNumber(fromValue: value))
    }
    
    static let range: Int = 56
    static var rangeOffset: Int {
        return Pitch.range / 2
    }
    static let pitchOffset: Int = 36
    
    static func noteNumber(fromValue: Double) -> CustomMIDINoteNumber {
        let temp1 = fromValue * Double(Pitch.range)
        let temp2 = temp1 - Double(Pitch.rangeOffset)
        let temp3 = temp2.rounded()
        let temp4 = Int(temp3) + Pitch.pitchOffset
        return temp4
    }
}

class BatteryCell {
    private let midi: MIDI
    let channelIndex: Int
    private (set) var sampleCellData: SampleCellData
    private weak var samplerOutputSelection: MidiDeviceSelection?
    /*
    private (set) var start1: Int
    private (set) var start2: Int
    private (set) var volume: Int
    private (set) var pan: Int
    private (set) var speed: Int
    private (set) var fineSpeed: Int
    private (set) var pitch: Pitch
    private (set) var filterLow: Int
    private (set) var filterHigh: Int
    private (set) var attack: Int
    private (set) var hold: Int
    private (set) var decay: Int
    private (set) var sustain: Int
    private (set) var release: Int
    private (set) var enableAttackEnvelope: Int
    private (set) var transientAttack: Int
    private (set) var transientSustain: Int
    private (set) var enableTransientMaster: Int
    private (set) var tune: Int
    private (set) var fineTune: Int
    private (set) var lofiBits: Int
    private (set) var lofiHertz: Int
    private (set) var lofiNoise: Int
    private (set) var lofiColor: Int
    private (set) var lofiOut: Int
    private (set) var enableLofi: Int
    private (set) var reverbSend: Int
    private (set) var delaySend: Int
    private (set) var velocity: Int
    private (set) var envOrder: Int
    private (set) var formant: Int
    */
    
    init(sampleCellData: SampleCellData, midi: MIDI, channelIndex: Int, samplerOutputSelection: MidiDeviceSelection){
        self.sampleCellData = sampleCellData
        self.midi = midi
        self.channelIndex = channelIndex
        self.samplerOutputSelection = samplerOutputSelection
        /*
        self.start1 = BatteryCell.start1Default
        self.start2 = BatteryCell.start2Default
        self.volume = BatteryCell.volumeDefault
        self.pan = BatteryCell.pan
        self.speed = BatteryCell.speed
        self.fineSpeed = BatteryCell.fineSpeed
        self.pitch = BatteryCell.pitchDefault
        self.filterLow = BatteryCell.filterLow
        self.filterHigh = BatteryCell.filterHigh
        self.attack = BatteryCell.attack
        self.hold = BatteryCell.hold
        self.decay = BatteryCell.decay
        self.sustain = BatteryCell.sustain
        self.release = BatteryCell.release
        self.enableAttackEnvelope = BatteryCell.enableAttackEnvelope
        self.transientAttack = BatteryCell.transientAttack
        self.transientSustain = BatteryCell.transientSustain
        self.enableTransientMaster = BatteryCell.enableTransientMaster
        self.tune = BatteryCell.tune
        self.fineTune = BatteryCell.fineTune
        self.lofiBits = BatteryCell.lofiBits
        self.lofiHertz = BatteryCell.lofiHertz
        self.lofiNoise = BatteryCell.lofiNoise
        self.lofiColor = BatteryCell.lofiColor
        self.lofiOut = BatteryCell.lofiOut
        self.enableLofi = BatteryCell.enableLofi
        self.reverbSend = BatteryCell.reverbSend
        self.delaySend = BatteryCell.delaySend
        self.velocity = BatteryCell.velocity
        self.envOrder = BatteryCell.envOrder
        self.formant = BatteryCell.formant
 */
    }
    /*
    static let start1Default: Int = 0
    static let start2Default: Int = 0
    static let volumeDefault: Int = 100
    static let pitchDefault: Pitch = Pitch(value: 0.5)
    static let filterLow: Int = 0
    static let filterHigh: Int = 127
    static let attack: Int = 5
    static let hold: Int = 4
    static let decay: Int = 20
    static let sustain: Int = 127
    static let release: Int = 5
    static let enableAttackEnvelope: Int = 127
    static let transientAttack: Int = 50
    static let transientSustain: Int = 50
    static let enableTransientMaster: Int = 0
    static let tune: Int = 64
    static let fineTune: Int = 64
    static let lofiBits: Int = 4
    static let lofiHertz: Int = 50
    static let lofiNoise: Int = 50
    static let lofiColor: Int = 50
    static let lofiOut: Int = 70
    static let enableLofi: Int = 0
    static let reverbSend: Int = 0
    static let delaySend: Int = 0
    static let velocity: Int = 0
    static let envOrder: Int = 50
    static let formant: Int = 50
    static let pan: Int = 64
    static let speed: Int = 64
    static let fineSpeed: Int = 64
    */
    func set(midiCC: MidiCC, samplerDestinations: [MidiDevice]?){
        switch midiCC {
        case .pitch(let pitch): sampleCellData.pitch = pitch
        case .start1(let value): sampleCellData.start1 = value
        case .start2(let value): sampleCellData.start2 = value
        case .volume(let value): sampleCellData.volume = value
        case .filterLow(let value): sampleCellData.filterLow = value
        case .filterHigh(let value): sampleCellData.filterHigh = value
        case .attack(let value): sampleCellData.attack = value
        case .hold(let value): sampleCellData.hold = value
        case .decay(let value): sampleCellData.decay = value
        case .sustain(let value): sampleCellData.sustain = value
        case .release(let value): sampleCellData.release = value
        case .enableAttackEnvelope(let value):
            sampleCellData.enableAttackEnvelope = value
        case .transientAttack(let value):
            sampleCellData.transientAttack = value
        case .transientSustain(let value):
            sampleCellData.transientSustain = value
        case .enableTransientMaster(let value):
            sampleCellData.enableTransientMaster = value
        case .tune(let value): sampleCellData.tune = value
        case .fineTune(let value): sampleCellData.fineTune = value
        case .lofiBits(let value): sampleCellData.lofiBits = value
        case .lofiHertz(let value): sampleCellData.lofiHertz = value
        case .lofiNoise(let value): sampleCellData.lofiNoise = value
        case .lofiColor(let value): sampleCellData.lofiColor = value
        case .lofiOut(let value): sampleCellData.lofiOut = value
        case .enableLofi(let value): sampleCellData.enableLofi = value
        case .reverbSend(let value): sampleCellData.reverbSend = value
        case .delaySend(let value): sampleCellData.delaySend = value
        case .velocity(let value): sampleCellData.velocity = value
        case .envOrder(let value): sampleCellData.envOrder = value
        case .formant(let value): sampleCellData.formant = value
        case .pan(let value): sampleCellData.pan = value
        case .speed(let value): sampleCellData.speed = value
        case .fineSpeed(let value): sampleCellData.fineSpeed = value
        case .mute(let value):
            break
        case .solo(let value):
            break
        case .unsoloAll:
            break
        case .lock(let value):
            break
        case .lockAll:
            break
        case .unlockAll:
            break
        }
        guard
            let outputCC = midiCC.midiCCInterface.midiCCOutputNumber,
            let device = samplerOutputSelection?.selectedMidiDevice
            else {
                print("NO OUTPUT CC")
                return
        }
        let midiControllerChange = MidiControllerChange(
            ccNumber: outputCC,
            value: midiCC.midiCCValue,
            channel: channelIndex,
            destinationDevices: samplerDestinations
        )
        do {
            try midi.send(midiCC: midiControllerChange, devices: [device])
        } catch {
            print("ERROR!")
        }
        /*
        midi.send(
            midiCCs: MidiControllerChange(
                ccNumber: outputCC,
                value: midiCC.midiCCValue,
                channel: channelIndex,
                destinationDevices: samplerDestinations
            )
        )
 */
    }
    /*
    func set(sampleProperty: MidiCCInterface, midiCC: MidiControlChange){
        switch sampleProperty {
        case .pitch:
            self.pitch = Pitch(value: midiCC.ratio)
            return
        case .start1:
            self.start1 = midiCC.value
        case .start2:
            self.start2 = midiCC.value
        case .volume: self.volume = midiCC.value
        case .filterLow: self.filterLow = midiCC.value
        case .filterHigh: self.filterHigh = midiCC.value
        case .attack: self.attack = midiCC.value
        case .hold: self.hold = midiCC.value
        case .decay: self.decay = midiCC.value
        case .sustain: self.sustain = midiCC.value
        case .release: self.release = midiCC.value
        case .enableAttackEnvelope: self.enableAttackEnvelope = midiCC.value
        case .transientAttack: self.transientAttack = midiCC.value
        case .transientSustain: self.transientSustain = midiCC.value
        case .enableTransientMaster: self.enableTransientMaster = midiCC.value
        case .tune: self.tune = midiCC.value
        case .fineTune: self.fineTune = midiCC.value
        case .lofiBits: self.lofiBits = midiCC.value
        case .lofiHertz: self.lofiHertz = midiCC.value
        case .lofiNoise: self.lofiNoise = midiCC.value
        case .lofiColor: self.lofiColor = midiCC.value
        case .lofiOut: self.lofiOut = midiCC.value
        case .enableLofi: self.enableLofi = midiCC.value
        case .reverbSend: self.reverbSend = midiCC.value
        case .delaySend: self.delaySend = midiCC.value
        case .velocity: self.velocity = midiCC.value
        case .envOrder: self.envOrder = midiCC.value
        case .formant: self.formant = midiCC.value
        case .pan: self.pan = midiCC.value
        case .speed: self.speed = midiCC.value
        case .fineSpeed: self.fineSpeed = midiCC.value
        }
        guard let outputCC = sampleProperty.midiCCOutputNumber
            else {
                print("NO OUTPUT CC")
                return
        }
        midi.send(
            midiCC: MidiControlChange(
                ccNumber: outputCC,
                value: midiCC.value,
                channel: channelIndex
            )
        )
        
    }
 */
    
    func sendToMaschine(controllerDevice: MidiDevice) throws {
        let ccEnums = sampleCellData.getAllMidiCCs(channel: channelIndex)
        var midiCCs = [MidiControllerChange]()
        for ccEnum in ccEnums {
            let midiCC = MidiControllerChange(ccNumber: ccEnum.midiCCInterface.controllerMidiCCNumber, value: ccEnum.midiCCValue, channel: 0, destinationDevices: [controllerDevice])
            midiCCs.append(midiCC)
        }
        try midi.send(midiCCs: midiCCs, devices: [controllerDevice])
    }
}


enum MidiCC {
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
