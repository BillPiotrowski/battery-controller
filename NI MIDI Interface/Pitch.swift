//
//  Pitch.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/8/20.
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
        let bipolarPitchRange = Pitch.bipolarPitchRange(
            fromValue: fromValue
        )
        return bipolarPitchRange + Pitch.pitchOffset
    }
    static func bipolarPitchRange(fromValue: Double) -> Int {
        let extendToPitchRange = fromValue * Double(Pitch.range)
        let offsetExtendedPitchRange = extendToPitchRange - Double(Pitch.rangeOffset)
        return Int(offsetExtendedPitchRange.rounded())
    }
    static func ratio(fromNoteNumber: Int) -> Double {
        let temp = fromNoteNumber - Pitch.pitchOffset
        let temp2 = temp + Pitch.rangeOffset
        return Double(temp2) / Double(Pitch.range)
    }
    var controllerValue: Double {
        return Pitch.ratio(fromNoteNumber: noteNumber)
    }
    var controllerMidiValue: Int {
        print("NOTE NUMBER: \(noteNumber)")
        print("ratio: \(controllerValue)")
        return Int(controllerValue * 127)
    }
}

extension Pitch: Equatable {

}
