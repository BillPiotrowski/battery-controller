//
//  Speed.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 6/5/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct Speed: ReadableData {
    var course: Double
    var fine: Double
    
    init(
        course: Double,
        fine: Double
    ){
        self.course = course
        self.fine = fine
    }
    
    init(dictionary: [String : Any]) throws {
        let course = try Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.course.rawValue,
            previousKey: "speed"
        )
        let fine = try? Self.asDoubleIn(
            dictionary: dictionary,
            key: Property.fine.rawValue
        )
        self.init(
            course: course,
            fine: fine ?? Speed.default.fine
        )
    }
}

extension Speed: WriteableData {
    var dictionary: [String : Any] {
        return [
            Property.course.rawValue: course,
            Property.fine.rawValue: fine
        ]
    }
}

extension Speed {
    enum Property: String {
        case course = "course"
        case fine = "fine"
    }
}

extension Speed {
    func midiCCs(channel: Int) -> MidiControllerChange {
        return MidiControllerChange(
            ccNumber: midiCCNumber,
            value: midiValue,
            channel: channel
        )
        
    }
    private var offset: Double {
        let bipolar = fine - 0.5
        return bipolar * Speed.fineScale
    }
    private var offsetSpeed: Double {
        let offsetSpeed = course + offset
        switch offsetSpeed {
        case ..<0: return 0
        case 1...: return 1
        default: return offsetSpeed
        }
    }
    private var midiValue: Int {
        guard offsetSpeed < 1
            else {
                return 127
        }
        let remainder = offsetSpeed.truncatingRemainder(
            dividingBy: 0.25
        )
        let scaled = remainder * 4
        return Int(scaled * 127)
    }
    private var midiCCNumber: Int {
        let divided = offsetSpeed / 0.25
        let integer = divided.rounded(.down)
        
        
        switch integer {
        case ..<1: return MidiOutputMapping.speed1.rawValue
        case 1: return MidiOutputMapping.speed2.rawValue
        case 2: return MidiOutputMapping.speed3.rawValue
        case 3...: return MidiOutputMapping.speed4.rawValue
        default: return MidiOutputMapping.speed4.rawValue
        }
    }
    private static let fineScale: Double = 0.25
}

extension Speed: Equatable {
    
}

extension Speed {
    static let `default` = Speed(course: 0.5, fine: 0.5)
}
