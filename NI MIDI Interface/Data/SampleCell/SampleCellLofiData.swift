//
//  SampleCellLofiData.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/24/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellLoFiData: ReadableData {
    
    var bits: Double
    var hertz: Double
    var noise: Double
    var color: Double
    var out: Double
    var enable: Bool
    
    init(
        bits: Double,
        hertz: Double,
        noise: Double,
        color: Double,
        out: Double,
        enable: Bool
    ){
        self.bits = bits
        self.hertz = hertz
        self.noise = noise
        self.color = color
        self.out = out
        self.enable = enable
    }
    
    init(dictionary: [String : Any]) throws {
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
        
        self.init(
            bits: lofiBits,
            hertz: lofiHertz,
            noise: lofiNoise,
            color: lofiColor,
            out: lofiOut,
            enable: enableLofi
        )
    }
}

extension SampleCellLoFiData: WriteableData {
    var dictionary: [String : Any] {
        return [
            Property.lofiBits.rawValue: bits,
            Property.lofiHertz.rawValue: hertz,
            Property.lofiNoise.rawValue: noise,
            Property.lofiColor.rawValue: color,
            Property.lofiOut.rawValue: out,
            Property.enableLofi.rawValue: enable
        ]
    }
}

extension SampleCellLoFiData: SampleCellPropertyProtocol {
    var outputValues: [String : MidiCCValueMap] {
        return [
            Property.lofiBits.rawValue: .lofiBits(value: bits),
            Property.lofiHertz.rawValue: .lofiHertz(value: hertz),
            Property.lofiNoise.rawValue: .lofiNoise(value: noise),
            Property.lofiColor.rawValue: .lofiColor(value: color),
            Property.lofiOut.rawValue: .lofiOut(value: out),
            Property.enableLofi.rawValue: .enableLofi(value: enable)
        ]
    }
}

// MARK: DEFAULT
extension SampleCellLoFiData {
    static let `default` = SampleCellLoFiData(
        bits: 0.4,
        hertz: 0.4,
        noise: 0,
        color: 0.5,
        out: 0.8,
        enable: false
    )
}

extension SampleCellLoFiData {
    enum Property: String {
        case lofiBits = "lofiBits"
        case lofiHertz = "lofiHertz"
        case lofiNoise = "lofiNoise"
        case lofiColor = "lofiColor"
        case lofiOut = "lofiOut"
        case enableLofi = "enableLofi"
    }
}

// Synthesized. Every stored property is already Equatable.
// Lets cell state be compared as a whole – see `BatteryCellParameterTests`.
extension SampleCellLoFiData: Equatable {}
