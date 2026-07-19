//
//  SampleCellSampleData.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/25/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellSampleData: ReadableData {
    var pitch: Pitch
    
    init(
        pitch: Pitch
    ){
        self.pitch = pitch
    }
    
    init(dictionary: [String : Any]) throws {
        let noteNumber = try Self.asIntIn(
            dictionary: dictionary,
            key: Property.pitch.rawValue
        )
        let pitch = Pitch(noteNumber: noteNumber)
        self.init(
            pitch: pitch
        )
    }
}

extension SampleCellSampleData: WriteableData {
    var dictionary: [String : Any] {
        return [
            Property.pitch.rawValue: pitch.noteNumber
        ]
    }
}

extension SampleCellSampleData {
    static let `default` = SampleCellSampleData(
        pitch: Pitch(value: 0.5)
    )
}

extension SampleCellSampleData {
    enum Property: String {
        case pitch = "pitch"
    }
}


extension SampleCellSampleData: SampleCellPropertyProtocol {
    var outputValues: [String : MidiCCValueMap] {
        return [
            Property.pitch.rawValue: .pitch(pitch: pitch)
        ]
    }
}

