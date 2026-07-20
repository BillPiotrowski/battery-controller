//
//  MidiNote.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/6/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

extension MIDINote {
    
    var cellIndex: Int? {
        //guard velocity > 0 else { return nil }
        return MIDINote.cellIndex(noteNumber: noteNumber)
    }
    static func cellIndex(noteNumber: Int) -> Int? {
        let cellIndex = noteNumber - MIDINote.cellIndexOffset
        guard
            cellIndex >= 0,
            cellIndex < 16
            else { return nil }
        return cellIndex
    }
    static let cellIndexOffset = 36
    static func noteNumber(cellIndex: Int) -> Int {
        let filteredCellIndex: Int
        if cellIndex > 16 { filteredCellIndex = 16 }
        else if cellIndex < 0 { filteredCellIndex = 0 }
        else { filteredCellIndex = cellIndex }
        return filteredCellIndex + MIDINote.cellIndexOffset
    }
}
