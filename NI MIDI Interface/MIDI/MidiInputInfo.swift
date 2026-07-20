//
//  MidiInputInfo.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/8/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

class MidiInputInfo {
    // MAKE WEAK?
    let midiSource: MidiSource
    let active: Bool
    
    init(
        midiSource: MidiSource,
        active: Bool
    ){
        self.midiSource = midiSource
        self.active = active
    }
}
extension MidiInputInfo {
    var uid: Int32 {
        return midiSource.uniqueID
    }
    var name: String {
        return midiSource.name
    }
}




