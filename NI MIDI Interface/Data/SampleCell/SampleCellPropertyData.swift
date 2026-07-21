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
    var speed: Speed
    //var fineSpeed: Double
    var filterLow: Double
    var filterHigh: Double
    var transientAttack: Double
    var transientSustain: Double
    var enableTransientMaster: Bool
    var tune: Double
    var fineTune: Double
    var reverbSend: Double
    var delaySend: Double
    var velocity: Double
    var envOrder: Double
    var formant: Double
    
    var loopStart: Double
    var loopStartFine: Double
    var loopLength: Double
    var loopLengthFine: Double
    
    init(
        start1: Double,
        start2: Double,
        volume: Double,
        pan: Double,
        speed: Speed,
        //fineSpeed: Double,
        filterLow: Double,
        filterHigh: Double,
        transientAttack: Double,
        transientSustain: Double,
        enableTransientMaster: Bool,
        tune: Double,
        fineTune: Double,
        reverbSend: Double,
        delaySend: Double,
        velocity: Double,
        envOrder: Double,
        formant: Double,
        loopStart: Double,
        loopStartFine: Double,
        loopLength: Double,
        loopLengthFine: Double
    ){
        self.start1 = start1
        self.start2 = start2
        self.volume = volume
        self.pan = pan
        self.speed = speed
        //self.fineSpeed = fineSpeed
        self.filterLow = filterLow
        self.filterHigh = filterHigh
        self.transientAttack = transientAttack
        self.transientSustain = transientSustain
        self.enableTransientMaster = enableTransientMaster
        self.tune = tune
        self.fineTune = fineTune
        self.reverbSend = reverbSend
        self.delaySend = delaySend
        self.velocity = velocity
        self.envOrder = envOrder
        self.formant = formant
        self.loopStart = loopStart
        self.loopStartFine = loopStartFine
        self.loopLength = loopLength
        self.loopLengthFine = loopLengthFine
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
        let speed = try Speed(dictionary: dictionary)
        /*
        let fineSpeed = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.fineSpeed.rawValue
        )
 */
        let filterLow = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.filterLow.rawValue
        )
        let filterHigh = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.filterHigh.rawValue
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
        
        let loopStart = try? Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.loopStart.rawValue
        )
        let loopStartFine = try? Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.loopStartFine.rawValue
        )
        let loopLength = try? Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.loopLength.rawValue
        )
        let loopLengthFine = try? Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.loopLengthFine.rawValue
        )
        
        self.init(
            start1: start1,
            start2: start2,
            volume: volume,
            pan: pan,
            speed: speed,
            //fineSpeed: fineSpeed,
            filterLow: filterLow,
            filterHigh: filterHigh,
            transientAttack: transientAttack,
            transientSustain: transientSustain,
            enableTransientMaster: enableTransientMaster,
            tune: tune,
            fineTune: fineTune,
            reverbSend: reverbSend,
            delaySend: delaySend,
            velocity: velocity,
            envOrder: envOrder,
            formant: formant,
            loopStart: loopStart ?? SampleCellPropertyData.default.loopStart,
            loopStartFine: loopStartFine ?? SampleCellPropertyData.default.loopStartFine,
            loopLength: loopLength ?? SampleCellPropertyData.default.loopLength,
            loopLengthFine: loopLengthFine ?? SampleCellPropertyData.default.loopLengthFine
        )
    }
    
    
}

extension SampleCellPropertyData: WriteableData {
    var dictionary: [String : Any] {
        var dictionary: [String: Any] = [
            Property.start1.rawValue: start1,
            Property.start2.rawValue: start2,
            Property.volume.rawValue: volume,
            Property.pan.rawValue: pan,
            Property.speed.rawValue: speed.dictionary,
            //Property.fineSpeed.rawValue: fineSpeed,
            Property.filterLow.rawValue: filterLow,
            Property.filterHigh.rawValue: filterHigh,
            Property.transientAttack.rawValue: transientAttack,
            Property.transientSustain.rawValue: transientSustain,
            Property.enableTransientMaster.rawValue: enableTransientMaster,
            Property.tune.rawValue: tune,
            Property.fineTune.rawValue: fineTune,
            Property.reverbSend.rawValue: reverbSend,
            Property.delaySend.rawValue: delaySend,
            Property.velocity.rawValue: velocity,
            Property.envOrder.rawValue: envOrder,
            Property.formant.rawValue: formant,
            Property.loopStart.rawValue: loopStart,
            Property.loopStartFine.rawValue: loopStartFine,
            Property.loopLength.rawValue: loopLength,
            Property.loopLengthFine.rawValue: loopLengthFine,
        ]
        dictionary.merge(speed.dictionary) { (_, new) -> Any in
            return new
        }
        return dictionary
    }
    
    
}


extension SampleCellPropertyData {
    enum Property: String {
        
        case start1 = "start1"
        case start2 = "start2"
        case volume = "volume"
        case pan = "pan"
        case speed = "speed"
        //case fineSpeed = "fineSpeed"
        case filterLow = "filterLow"
        case filterHigh = "filterHigh"
        case transientAttack = "transientAttack"
        case transientSustain = "transientSustain"
        case enableTransientMaster = "enableTransientMaster"
        case tune = "tune"
        case fineTune = "fineTune"
        case reverbSend = "reverbSend"
        case delaySend = "delaySend"
        case velocity = "velocity"
        case envOrder = "envOrder"
        case formant = "formant"

        case loopStart = "loopStart"
        case loopStartFine = "loopStartFine"
        case loopLength = "loopLength"
        case loopLengthFine = "loopLengthFine"
    }
    
    static let `default` = SampleCellPropertyData(
        start1: 0,
        start2: 0,
        volume: 0.8,
        pan: 0.5,
        speed: Speed.default,
        //fineSpeed: 0.5,
        filterLow: 0,
        filterHigh: 1,
        transientAttack: 0.5,
        transientSustain: 0.5,
        enableTransientMaster: false,
        tune: 0.5,
        fineTune: 0.5,
        reverbSend: 0,
        delaySend: 0,
        velocity: 0,
        envOrder: 0.4,
        formant: 0.5,
        loopStart: 0,
        loopStartFine: 0,
        loopLength: 1,
        loopLengthFine: 1
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



// Synthesized. Every stored property is already Equatable.
// Lets cell state be compared as a whole – see `BatteryCellParameterTests`.
extension SampleCellPropertyData: Equatable {}
