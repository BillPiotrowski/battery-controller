//
//  SampleCellData.swift
//  NI MIDI Doubleerface
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellData: ReadableData {
    
    
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
            start1: SampleCellData.start1Default,
            start2: SampleCellData.start2Default,
            volume: SampleCellData.volumeDefault,
            pan: SampleCellData.panDefault,
            speed: SampleCellData.speedDefault,
            fineSpeed: SampleCellData.fineSpeedDefault,
            pitch: SampleCellData.pitchDefault,
            filterLow: SampleCellData.filterLowDefault,
            filterHigh: SampleCellData.filterHighDefault,
            attack: SampleCellData.attackDefault,
            hold: SampleCellData.holdDefault,
            decay: SampleCellData.decayDefault,
            sustain: SampleCellData.sustainDefault,
            release: SampleCellData.releaseDefault,
            enableAttackEnvelope: SampleCellData.enableAttackEnvelopeDefault,
            transientAttack: SampleCellData.transientAttackDefault,
            transientSustain: SampleCellData.transientSustainDefault,
            enableTransientMaster: SampleCellData.enableTransientMasterDefault,
            tune: SampleCellData.tuneDefault,
            fineTune: SampleCellData.fineTuneDefault,
            lofiBits: SampleCellData.lofiBitsDefault,
            lofiHertz: SampleCellData.lofiHertzDefault,
            lofiNoise: SampleCellData.lofiNoiseDefault,
            lofiColor: SampleCellData.lofiColorDefault,
            lofiOut: SampleCellData.lofiOutDefault,
            enableLofi: SampleCellData.enableLofiDefault,
            reverbSend: SampleCellData.reverbSendDefault,
            delaySend: SampleCellData.delaySendDefault,
            velocity: SampleCellData.velocityDefault,
            envOrder: SampleCellData.envOrderDefault,
            formant: SampleCellData.formantDefault
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
        let transientSustain = try Self.asDoubleIn(dictionary: dictionary, key: Property.transientSustain.rawValue)
        let enableTransientMaster = try Self.asBoolIn(dictionary: dictionary, key: Property.enableTransientMaster.rawValue)
        let tune = try Self.asDoubleIn(dictionary: dictionary, key: Property.tune.rawValue)
        let fineTune = try Self.asDoubleIn(dictionary: dictionary, key: Property.fineTune.rawValue)
        let lofiBits = try Self.asDoubleIn(dictionary: dictionary, key: Property.lofiBits.rawValue)
        let lofiHertz = try Self.asDoubleIn(dictionary: dictionary, key: Property.lofiHertz.rawValue)
        let lofiNoise = try Self.asDoubleIn(dictionary: dictionary, key: Property.lofiNoise.rawValue)
        let lofiColor = try Self.asDoubleIn(dictionary: dictionary, key: Property.lofiColor.rawValue)
        let lofiOut = try Self.asDoubleIn(dictionary: dictionary, key: Property.lofiOut.rawValue)
        let enableLofi = try Self.asBoolIn(dictionary: dictionary, key: Property.enableLofi.rawValue)
        let reverbSend = try Self.asDoubleIn(dictionary: dictionary, key: Property.reverbSend.rawValue)
        let delaySend = try Self.asDoubleIn(dictionary: dictionary, key: Property.delaySend.rawValue)
        let velocity = try Self.asDoubleIn(dictionary: dictionary, key: Property.velocity.rawValue)
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

extension SampleCellData: WriteableData {
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
            Property.formant.rawValue: formant,
        
        ]
    }
    
    
}


extension SampleCellData {
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
    
    static let start1Default: Double = 0
    static let start2Default: Double = 0
    static let volumeDefault: Double = 0.8
    static let pitchDefault: Pitch = Pitch(value: 0.5)
    static let filterLowDefault: Double = 0
    static let filterHighDefault: Double = 1
    static let attackDefault: Double = 0.05
    static let holdDefault: Double = 0.2
    static let decayDefault: Double = 0.2
    static let sustainDefault: Double = 1
    static let releaseDefault: Double = 0.05
    static let enableAttackEnvelopeDefault: Bool = true
    static let transientAttackDefault: Double = 0.5
    static let transientSustainDefault: Double = 0.5
    static let enableTransientMasterDefault: Bool = false
    static let tuneDefault: Double = 0.5
    static let fineTuneDefault: Double = 0.5
    static let lofiBitsDefault: Double = 0.4
    static let lofiHertzDefault: Double = 0.4
    static let lofiNoiseDefault: Double = 0
    static let lofiColorDefault: Double = 0.5
    static let lofiOutDefault: Double = 0.8
    static let enableLofiDefault: Bool = false
    static let reverbSendDefault: Double = 0
    static let delaySendDefault: Double = 0
    static let velocityDefault: Double = 0
    static let envOrderDefault: Double = 0.4
    static let formantDefault: Double = 0.5
    static let panDefault: Double = 0.5
    static let speedDefault: Double = 0.5
    static let fineSpeedDefault: Double = 0.5
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


