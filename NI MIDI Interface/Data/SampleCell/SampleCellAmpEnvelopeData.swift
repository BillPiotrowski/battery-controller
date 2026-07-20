//
//  SampleCellAmpFilterData.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/24/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellAmpEnvelopeData: ReadableData {
    
    var attack: Double
    var hold: Double
    var decay: Double
    var sustain: Double
    var release: Double
    var enableAmpEnv: Bool
    
    init(
        attack: Double,
        hold: Double,
        decay: Double,
        sustain: Double,
        release: Double,
        enableAttackEnvelope: Bool
    ){
        self.attack = attack
        self.hold = hold
        self.decay = decay
        self.sustain = sustain
        self.release = release
        self.enableAmpEnv = enableAttackEnvelope        
    }
    
    init(dictionary: [String : Any]) throws {
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
            key: Property.enableAmpEnv.rawValue
        )
        self.init(
            attack: attack,
            hold: hold,
            decay: decay,
            sustain: sustain,
            release: release,
            enableAttackEnvelope: enableAttackEnvelope
        )
    }
}

// MARK: WRITABLE
extension SampleCellAmpEnvelopeData: WriteableData {
    var dictionary: [String : Any] {
        return [
            Property.attack.rawValue: attack,
            Property.hold.rawValue: hold,
            Property.decay.rawValue: decay,
            Property.sustain.rawValue: sustain,
            Property.release.rawValue: release,
            Property.enableAmpEnv.rawValue: enableAmpEnv
        ]
    }
}

// MARK: DEFAULT
extension SampleCellAmpEnvelopeData {
    static let `default` = SampleCellAmpEnvelopeData(
        attack: 0.05,
        hold: 0.2,
        decay: 0.2,
        sustain: 1,
        release: 0.05,
        enableAttackEnvelope: true
    )
}

// MARK: DEFINITIONS
extension SampleCellAmpEnvelopeData {
    enum Property: String {
        case attack = "attack"
        case hold = "hold"
        case decay = "decay"
        case sustain = "sustain"
        case release = "release"
        case enableAmpEnv = "enableAmpEnv"
    }
}

// MARK: SAMPLE PROP
extension SampleCellAmpEnvelopeData: SampleCellPropertyProtocol {
    var outputValues: [String: MidiCCValueMap] {
        return [
            Property.attack.rawValue: .attack(value: attack),
            Property.hold.rawValue: .hold(value: hold),
            Property.decay.rawValue: .decay(value: decay),
            Property.sustain.rawValue: .sustain(value: sustain),
            Property.release.rawValue: .release(value: release),
            Property.enableAmpEnv.rawValue:
                .enableAttackEnvelope(value: enableAmpEnv)
        ]
    }
    
}

