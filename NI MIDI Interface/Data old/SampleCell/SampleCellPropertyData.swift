//
//  SampleCellData.swift
//  NI MIDI Doubleerface
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellPropertyData: ReadableData {
    
    
    var start1: Double
    var start2: Double
    var volume: Double
    var pan: Double
    var speed: Double
    var fineSpeed: Double
    var pitch: Pitch
    var filterLow: Double
    var filterHigh: Double
    var attack: Double
    var hold: Double
    var decay: Double
    var sustain: Double
    var release: Double
    var enableAttackEnvelope: Bool
    var transientAttack: Double
    var transientSustain: Double
    var enableTransientMaster: Bool
    var tune: Double
    var fineTune: Double
    var lofiBits: Double
    var lofiHertz: Double
    var lofiNoise: Double
    var lofiColor: Double
    var lofiOut: Double
    var enableLofi: Bool
    var reverbSend: Double
    var delaySend: Double
    var velocity: Double
    var envOrder: Double
    var formant: Double
    
    init(
        start1: Double,
        start2: Double,
        volume: Double,
        pan: Double,
        speed: Double,
        fineSpeed: Double,
        pitch: Pitch,
        filterLow: Double,
        filterHigh: Double,
        attack: Double,
        hold: Double,
        decay: Double,
        sustain: Double,
        release: Double,
        enableAttackEnvelope: Bool,
        transientAttack: Double,
        transientSustain: Double,
        enableTransientMaster: Bool,
        tune: Double,
        fineTune: Double,
        lofiBits: Double,
        lofiHertz: Double,
        lofiNoise: Double,
        lofiColor: Double,
        lofiOut: Double,
        enableLofi: Bool,
        reverbSend: Double,
        delaySend: Double,
        velocity: Double,
        envOrder: Double,
        formant: Double
    ){
        self.start1 = start1
        self.start2 = start2
        self.volume = volume
        self.pan = pan
        self.speed = speed
        self.fineSpeed = fineSpeed
        self.pitch = pitch
        self.filterLow = filterLow
        self.filterHigh = filterHigh
        self.attack = attack
        self.hold = hold
        self.decay = decay
        self.sustain = sustain
        self.release = release
        self.enableAttackEnvelope = enableAttackEnvelope
        self.transientAttack = transientAttack
        self.transientSustain = transientSustain
        self.enableTransientMaster = enableTransientMaster
        self.tune = tune
        self.fineTune = fineTune
        self.lofiBits = lofiBits
        self.lofiHertz = lofiHertz
        self.lofiNoise = lofiNoise
        self.lofiColor = lofiColor
        self.lofiOut = lofiOut
        self.enableLofi = enableLofi
        self.reverbSend = reverbSend
        self.delaySend = delaySend
        self.velocity = velocity
        self.envOrder = envOrder
        self.formant = formant
    }
    
    init(){
        self.init(
            start1: SampleCellPropertyData.default.start1,
            start2: SampleCellPropertyData.default.start2,
            volume: SampleCellPropertyData.default.volume,
            pan: SampleCellPropertyData.default.pan,
            speed: SampleCellPropertyData.default.speed,
            fineSpeed: SampleCellPropertyData.default.fineSpeed,
            pitch: SampleCellPropertyData.default.pitch,
            filterLow: SampleCellPropertyData.default.filterLow,
            filterHigh: SampleCellPropertyData.default.filterHigh,
            attack: SampleCellPropertyData.default.attack,
            hold: SampleCellPropertyData.default.hold,
            decay: SampleCellPropertyData.default.decay,
            sustain: SampleCellPropertyData.default.sustain,
            release: SampleCellPropertyData.default.release,
            enableAttackEnvelope: SampleCellPropertyData.default.enableAttackEnvelope,
            transientAttack: SampleCellPropertyData.default.transientAttack,
            transientSustain: SampleCellPropertyData.default.transientSustain,
            enableTransientMaster: SampleCellPropertyData.default.enableTransientMaster,
            tune: SampleCellPropertyData.default.tune,
            fineTune: SampleCellPropertyData.default.fineTune,
            lofiBits: SampleCellPropertyData.default.lofiBits,
            lofiHertz: SampleCellPropertyData.default.lofiHertz,
            lofiNoise: SampleCellPropertyData.default.lofiNoise,
            lofiColor: SampleCellPropertyData.default.lofiColor,
            lofiOut: SampleCellPropertyData.default.lofiOut,
            enableLofi: SampleCellPropertyData.default.enableLofi,
            reverbSend: SampleCellPropertyData.default.reverbSend,
            delaySend: SampleCellPropertyData.default.delaySend,
            velocity: SampleCellPropertyData.default.velocity,
            envOrder: SampleCellPropertyData.default.envOrder,
            formant: SampleCellPropertyData.default.formant
        )
    }
    
    init(dictionary: [String : Any]) throws {

        let start1 = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.start1.rawValue
        )
        let start2 = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.start2.rawValue
        )
        let volume = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.volume.rawValue
        )
        let pan = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.pan.rawValue
        )
        let speed = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.speed.rawValue
        )
        let fineSpeed = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.fineSpeed.rawValue
        )
        let noteNumber = try Self.asIntIn(
            dictionary: dictionary,
            key: Property.pitch.rawValue
        )
        let pitch = Pitch(noteNumber: noteNumber)
        let filterLow = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.filterLow.rawValue
        )
        let filterHigh = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.filterHigh.rawValue
        )
        let attack = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.attack.rawValue
        )
        let hold = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.hold.rawValue
        )
        let decay = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.decay.rawValue
        )
        let sustain = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.sustain.rawValue
        )
        let release = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.release.rawValue
        )
        let enableAttackEnvelope = try Self.asBoolIn(
            dictionary: dictionary,
            key: Property.enableAttackEnvelope.rawValue
        )
        let transientAttack = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.transientAttack.rawValue
        )
        let transientSustain = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.transientSustain.rawValue
        )
        let enableTransientMaster = try Self.asBoolIn(
            dictionary: dictionary,
            key: Property.enableTransientMaster.rawValue
        )
        let tune = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.tune.rawValue
        )
        let fineTune = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.fineTune.rawValue
        )
        let lofiBits = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.lofiBits.rawValue
        )
        let lofiHertz = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.lofiHertz.rawValue
        )
        let lofiNoise = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.lofiNoise.rawValue
        )
        let lofiColor = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.lofiColor.rawValue
        )
        let lofiOut = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.lofiOut.rawValue
        )
        let enableLofi = try Self.asBoolIn(
            dictionary: dictionary,
            key: Property.enableLofi.rawValue
        )
        let reverbSend = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.reverbSend.rawValue
        )
        let delaySend = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.delaySend.rawValue
        )
        let velocity = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.velocity.rawValue
        )
        let envOrder = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.envOrder.rawValue
        )
        let formant = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.formant.rawValue
        )
        
        self.init(
            start1: start1,
            start2: start2,
            volume: volume,
            pan: pan,
            speed: speed,
            fineSpeed: fineSpeed,
            pitch: pitch,
            filterLow: filterLow,
            filterHigh: filterHigh,
            attack: attack,
            hold: hold,
            decay: decay,
            sustain: sustain,
            release: release,
            enableAttackEnvelope: enableAttackEnvelope,
            transientAttack: transientAttack,
            transientSustain: transientSustain,
            enableTransientMaster: enableTransientMaster,
            tune: tune,
            fineTune: fineTune,
            lofiBits: lofiBits,
            lofiHertz: lofiHertz,
            lofiNoise: lofiNoise,
            lofiColor: lofiColor,
            lofiOut: lofiOut,
            enableLofi: enableLofi,
            reverbSend: reverbSend,
            delaySend: delaySend,
            velocity: velocity,
            envOrder: envOrder,
            formant: formant
        )
    }
    
    
}

extension SampleCellPropertyData: WriteableData {
    var dictionary: [String : Any] {
        return [
            Property.start1.rawValue: start1,
            Property.start2.rawValue: start2,
            Property.volume.rawValue: volume,
            Property.pan.rawValue: pan,
            Property.speed.rawValue: speed,
            Property.fineSpeed.rawValue: fineSpeed,
            Property.pitch.rawValue: pitch.noteNumber,
            Property.filterLow.rawValue: filterLow,
            Property.filterHigh.rawValue: filterHigh,
            Property.attack.rawValue: attack,
            Property.hold.rawValue: hold,
            Property.decay.rawValue: decay,
            Property.sustain.rawValue: sustain,
            Property.release.rawValue: release,
            Property.enableAttackEnvelope.rawValue: enableAttackEnvelope,
            Property.transientAttack.rawValue: transientAttack,
            Property.transientSustain.rawValue: transientSustain,
            Property.enableTransientMaster.rawValue: enableTransientMaster,
            Property.tune.rawValue: tune,
            Property.fineTune.rawValue: fineTune,
            Property.lofiBits.rawValue: lofiBits,
            Property.lofiHertz.rawValue: lofiHertz,
            Property.lofiNoise.rawValue: lofiNoise,
            Property.lofiColor.rawValue: lofiColor,
            Property.lofiOut.rawValue: lofiOut,
            Property.enableLofi.rawValue: enableLofi,
            Property.reverbSend.rawValue: reverbSend,
            Property.delaySend.rawValue: delaySend,
            Property.velocity.rawValue: velocity,
            Property.envOrder.rawValue: envOrder,
            Property.formant.rawValue: formant
        ]
    }
    
    
}


extension SampleCellPropertyData {
    enum Property: String {

        case start1 = "start1"
        case start2 = "start2"
        case volume = "volume"
        case pan = "pan"
        case speed = "speed"
        case fineSpeed = "fineSpeed"
        case pitch = "pitch"
        case filterLow = "filterLow"
        case filterHigh = "filterHigh"
        case attack = "attack"
        case hold = "hold"
        case decay = "decay"
        case sustain = "sustain"
        case release = "release"
        case enableAttackEnvelope = "enableAttackEnvelope"
        case transientAttack = "transientAttack"
        case transientSustain = "transientSustain"
        case enableTransientMaster = "enableTransientMaster"
        case tune = "tune"
        case fineTune = "fineTune"
        case lofiBits = "lofiBits"
        case lofiHertz = "lofiHertz"
        case lofiNoise = "lofiNoise"
        case lofiColor = "lofiColor"
        case lofiOut = "lofiOut"
        case enableLofi = "enableLofi"
        case reverbSend = "reverbSend"
        case delaySend = "delaySend"
        case velocity = "velocity"
        case envOrder = "envOrder"
        case formant = "formant"
    }
    
    static let `default` = SampleCellPropertyData(
        start1: 0,
        start2: 0,
        volume: 0.8,
        pan: 0.5,
        speed: 0.5,
        fineSpeed: 0.5,
        pitch: Pitch(value: 0.5),
        filterLow: 0,
        filterHigh: 1,
        attack: 0.05,
        hold: 0.2,
        decay: 0.2,
        sustain: 1,
        release: 0.05,
        enableAttackEnvelope: true,
        transientAttack: 0.5,
        transientSustain: 0.5,
        enableTransientMaster: false,
        tune: 0.5,
        fineTune: 0.5,
        lofiBits: 0.4,
        lofiHertz: 0.4,
        lofiNoise: 0,
        lofiColor: 0.5,
        lofiOut: 0.8,
        enableLofi: false,
        reverbSend: 0,
        delaySend: 0,
        velocity: 0,
        envOrder: 0.4,
        formant: 0.5
    )
}














protocol MidiCCValueProtocol {
    var MidiCCValue: MidiControlChangeValue { get }
}

extension Bool: MidiCCValueProtocol {
    var MidiCCValue: MidiControlChangeValue {
        switch self {
        case true: return 127
        case false: return 0
        }
    }
}
extension Double: MidiCCValueProtocol {
    var MidiCCValue: MidiControlChangeValue {
        let temp = self * 127
        return Int(temp.rounded())
    }
}


