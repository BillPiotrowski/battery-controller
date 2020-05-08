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
        let cellIndex = noteNumber - 36
        guard
            cellIndex >= 0,
            cellIndex < 16
            else { return nil }
        return cellIndex
    }
}
